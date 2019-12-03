% Initialize variables
clear;
csi_entry = [];
index = -1;                     % The index of the plots which need shadowing
broken_perm = 0;                % Flag marking whether we've encountered a broken CSI yet
triangle = [1 3 6];             % What perm should sum to for 1,2,3 antennas

for k = 1:500
    csi_trace = read_bf_file('sample_data/test.dat');
    csi_entry = csi_trace{k};
    
    perm = csi_entry.perm;
    Nrx = csi_entry.Nrx;
    csi_entry.csi(:,perm(1:Nrx),:) = csi_entry.csi(:,1:Nrx,:);
    
    index = mod(index+1, 10);
    
    csi = get_scaled_csi(csi_entry);%CSI data
    %You can use the CSI data here.
    csia=abs(squeeze(csi(1,:,:)).');
    first_ant_csi(:,k)=csia(:,1);           
    second_ant_csi(:,k)=csia(:,2);
    third_ant_csi(:,k)=csia(:,3);
    
    csip=angle(squeeze(csi(1,:,:)).');
    first_ph_csi(:,k)=csip(:,1);           
    second_ph_csi(:,k)=csip(:,2);
    third_ph_csi(:,k)=csip(:,3);
    %This plot will show graphics about recent 10 csi packets
    clf;
    subplot(2,1,1);
    axis([1,30,-10,30]);
    t1=0;
    m1=zeros(30,1);
    p = plot(t1,m1,'MarkerSize',5);
    xlabel('Subcarrier index');
    ylabel('Amplitude');
    set(p(index*3 + 1),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,1,:)).')), 'color', 'b', 'linestyle', '-');
    if Nrx > 1
        set(p(index*3 + 2),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,2,:)).')), 'color', 'g', 'linestyle', '-');
    end
    if Nrx > 2
        set(p(index*3 + 3),'XData', [1:30], 'YData', db(abs(squeeze(csi(1,3,:)).')), 'color', 'r', 'linestyle', '-');
    end
    axis([1,30,0,40]);
    % drawnow;
    
    subplot(2,1,2);
    axis([1,30,-10,30]);
    t2=0;
    m2=zeros(30,1);
    p2 = plot(t2,m2,'MarkerSize',5);
    xlabel('Subcarrier index');
    ylabel('Raw Phase');
    set(p2(index*3 + 1),'XData', [1:30], 'YData',first_ph_csi(:,k), 'color', 'b', 'linestyle', '-');
    if Nrx > 1
        set(p2(index*3 + 2),'XData', [1:30], 'YData', second_ph_csi(:,k), 'color', 'g', 'linestyle', '-');
    end
    if Nrx > 2
        set(p2(index*3 + 3),'XData', [1:30], 'YData', third_ph_csi(:,k), 'color', 'r', 'linestyle', '-');
    end
    axis([1,30,-5,5]);
    drawnow;
    
    csi_entry = [];
end

