function realtime_analysis()
load SVMtrainedModel.mat;
while 1
    %% Build a TCP Server and wait for connection
    port = 8090;
    t = tcpip('0.0.0.0', port, 'NetworkRole', 'server');
    t.InputBufferSize = 1024;
    t.Timeout = 15;
    fprintf('Waiting for connection on port %d\n',port);
    fopen(t);
    fprintf('Accept connection from %s\n',t.RemoteHost);
    
    %% Set plot parameters
    clf;
    axis([1,30,-10,30]);
    t1=0;
    m1=zeros(30,1);
    
    %%  Starting in R2014b, the EraseMode property has been removed from all graphics objects.
    %%  https://mathworks.com/help/matlab/graphics_transition/how-do-i-replace-the-erasemode-property.html
    [VER DATESTR] = version();
    if datenum(DATESTR) > datenum('February 11, 2014')
        p = plot(t1,m1,'MarkerSize',5);
    else
        p = plot(t1,m1,'EraseMode','Xor','MarkerSize',5);
    end
    
    xlabel('Subcarrier index');
    ylabel('SNR (dB)');
    
    %% Initialize variables
    csi_trace = cell(60,1);
    ct_index = 1;
    init_flag = 0;
    yfit = 0;
    csi_entry = [];
    index = -1;                     % The index of the plots which need shadowing
    broken_perm = 0;                % Flag marking whether we've encountered a broken CSI yet
    triangle = [1 3 6];             % What perm should sum to for 1,2,3 antennas
    
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
        else
            if field_len <= t.InputBufferSize  % skip all other info
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
        if init_flag == 0
            csi_trace{ct_index} = csi_entry;
            ct_index = ct_index + 1;
            if ct_index == 61
                init_flag = 1;
            end
        else
            for i=1:59
                csi_trace{i} = csi_trace{i+1};
            end
            csi_trace{60} = csi_entry;
            feature_vetor = get_feature_vetor(csi_trace);
            feature_vetor = (reshape(feature_vetor,450,1)).';
            yfit = SVMtrainedModel.predictFcn(feature_vetor)
        end
        
        %This plot will show graphics about recent 10 csi packets
        if yfit == 0
            backColor = [0.1 0.8 0.2 0.1];set(gca, 'color', backColor);
        else
            backColor = [0.8 0.2 0.1 0.2];set(gca, 'color', backColor);
        end
        set(p(index*3+1),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,1,:)).')), 'color', 'b', 'linestyle', '-');
        if Nrx > 1
            set(p(index*3 + 2),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,2,:)).')), 'color', 'g', 'linestyle', '-');
        end
        if Nrx > 2
            set(p(index*3 + 3),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,3,:)).')), 'color', 'r', 'linestyle', '-');
        end
        axis([1,30,15,35]);
        drawnow;
        
        csi_entry = [];
    end
    %% Close file
    fclose(t);
    delete(t);
end

end