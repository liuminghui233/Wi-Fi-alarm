%READ_BF_SOCKET Reads in a file of beamforming feedback logs.
%   This version uses the *C* version of read_bfee, compiled with
%   MATLAB's MEX utility.
%
% (c) 2008-2011 Daniel Halperin <dhalperi@cs.washington.edu>
%
%   Modified by Renjie Zhang, Bingxian Lu.
%   Email: bingxian.lu@gmail.com

function realtime_analysis()

while 1
    %% Build a TCP Server and wait for connection
    port = 8090;
    t = tcpip('0.0.0.0', port, 'NetworkRole', 'server');
    t.InputBufferSize = 1024;
    t.Timeout = 15;
    fprintf('Waiting for connection on port %d\n',port);
    fopen(t);
    fprintf('Accept connection from %s\n',t.RemoteHost);
    
    %% Initialize variables
    csi_entry = [];
    index = -1;                     % The index of the plots which need shadowing
    broken_perm = 0;                % Flag marking whether we've encountered a broken CSI yet
    triangle = [1 3 6];             % What perm should sum to for 1,2,3 antennas
    
    first_ant_csi = ones(30,1)*nan;
    second_ant_csi = ones(30,1)*nan;
    third_ant_csi = ones(30,1)*nan;
    
    first_ph_csi = ones(30,1)*nan;
    second_ph_csi = ones(30,1)*nan;
    third_ph_csi = ones(30,1)*nan;
    %% Process all entries in socket
    % Need 3 bytes -- 2 byte size field and 1 byte code
    while 1
        % Read size and code from the received packets
        s = warning('error', 'instrument:fread:unsuccessfulRead');
        try
            field_len = fread(t, 1, 'uint16');
        catch
            warning(s);
            disp('Timeout, please restart the client and connect again.');
            break;
        end
        
        code = fread(t,1);
        % If unhandled code, skip (seek over) the record and continue
        if (code == 187) % get beamforming or phy data
            bytes = fread(t, field_len-1, 'uint8');
            bytes = uint8(bytes);
            if (length(bytes) ~= field_len-1)
                fclose(t);
                return;
            end
        else if field_len <= t.InputBufferSize  % skip all other info
                fread(t, field_len-1, 'uint8');
                continue;
            else
                continue;
            end
        end
        
        if (code == 187) % (tips: 187 = hex2dec('bb')) Beamforming matrix -- output a record
            csi_entry = read_bfee(bytes);
            
            perm = csi_entry.perm;
            Nrx = csi_entry.Nrx;
            if Nrx > 1 % No permuting needed for only 1 antenna
                if sum(perm) ~= triangle(Nrx) % matrix does not contain default values
                    if broken_perm == 0
                        broken_perm = 1;
                        fprintf('WARN ONCE: Found CSI (%s) with Nrx=%d and invalid perm=[%s]\n', filename, Nrx, int2str(perm));
                    end
                else
                    csi_entry.csi(:,perm(1:Nrx),:) = csi_entry.csi(:,1:Nrx,:);
                end
            end
        end
        
        index = mod(index+1, 10);
        
        csi = get_scaled_csi(csi_entry);%CSI data
        %You can use the CSI data here.
        
        % CSI Amplitude
        csia=abs(squeeze(csi(1,:,:)).');
        first_ant_csi(:,k)=csia(:,1);
        second_ant_csi(:,k)=csia(:,2);
        third_ant_csi(:,k)=csia(:,3);
        
        % CSI Phase
        csis =  squeeze(csi(1,:,:)).';
        [csilt, ~] = linear_transform(csis.');
        csip = angle(csilt.');
        first_ph_csi(:,k)=csip(:,1);
        second_ph_csi(:,k)=csip(:,2);
        third_ph_csi(:,k)=csip(:,3);
        
        %This plot will show graphics about recent 10 csi packets
        clf;
        subplot(1,2,1);
        t1=0;m1=zeros(30,1);
        p1 = plot(t1,m1,'MarkerSize',5);
        xlabel('Subcarrier index');
        ylabel('CSI Amplitude');
        set(gcf,'units','normalized','position',[0.1 0.1 0.6 0.6]);
        set(p1(index*3 + 1),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,1,:)).')), 'color', 'b', 'linestyle', '-');
        if Nrx > 1
            set(p1(index*3 + 2),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,2,:)).')), 'color', 'g', 'linestyle', '-');
        end
        if Nrx > 2
            set(p1(index*3 + 3),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,3,:)).')), 'color', 'r', 'linestyle', '-');
        end
        axis([1,30,0,40]);
        
        subplot(1,2,2);
        t2=0; m2=zeros(30,1);
        p2 = plot(t2,m2,'MarkerSize',5);
        xlabel('Subcarrier index');
        ylabel('CSI Phase');
        set(p2(index*3 + 1),'XData', [1:30], 'YData',first_ph_csi(:,k), 'color', 'b', 'linestyle', '-');
        if Nrx > 1
            set(p2(index*3 + 2),'XData', [1:30], 'YData', second_ph_csi(:,k), 'color', 'g', 'linestyle', '-');
        end
        if Nrx > 2
            set(p2(index*3 + 3),'XData', [1:30], 'YData', third_ph_csi(:,k), 'color', 'r', 'linestyle', '-');
        end
        axis([1,30,-0.5,0.5]);
        
        drawnow;
        
        csi_entry = [];
    end
    %% Close file
    fclose(t);
    delete(t);
end

end