% Initialize variables
clear;
csi_entry = [];
index = -1;                     % The index of the plots which need shadowing
broken_perm = 0;                % Flag marking whether we've encountered a broken CSI yet
triangle = [1 3 6];             % What perm should sum to for 1,2,3 antennas

probability = 0;

load SVMModel.mat;

csi_trace = read_bf_file('csi_data/go_go01.dat');
num_package = length(csi_trace);

first_ant_csi = ones(30,1)*nan;
second_ant_csi = ones(30,1)*nan;
third_ant_csi = ones(30,1)*nan;

first_ph_csi = ones(30,1)*nan;  
second_ph_csi = ones(30,1)*nan;
third_ph_csi = ones(30,1)*nan;

for k = 1:60
    csi_entry = csi_trace{k};
    
    perm = csi_entry.perm;
    Nrx = csi_entry.Nrx;
    csi_entry.csi(:,perm(1:Nrx),:) = csi_entry.csi(:,1:Nrx,:);
    
    index = mod(index+1, 10);
    
    csi = get_scaled_csi(csi_entry);%CSI data
    %You can use the CSI data here.
    feature_vetor = get_feature_vetor(csi_trace,k);
    yfit = SVMModel.predictFcn(feature_vetor);
    if yfit == 1
        probability = probability+1;
    end
    
    % CSI Amplitude
    csia=abs(squeeze(csi(1,:,:)).');
    first_ant_csi(:,k)=csia(:,1);           
    second_ant_csi(:,k)=csia(:,2);
    third_ant_csi(:,k)=csia(:,3);
        
    %This plot will show graphics about recent 10 csi packets
    clf;
    subplot(1,2,1);
    t1=0;m1=zeros(30,1);
    p = plot(t1,m1,'MarkerSize',5);
    xlabel('Subcarrier index');
    ylabel('CSI Amplitude');
    if yfit == 0
        backColor = [0.1 0.8 0.2 0.1];set(gca, 'color', backColor);
    else
        backColor = [0.8 0.2 0.1 0.2];set(gca, 'color', backColor);
    end
    set(gcf,'units','normalized','position',[0.1 0.1 0.6 0.6]);
    set(p(index*3 + 1),'XData', [1:30], 'YData', first_ant_csi(:,k), 'color', 'b', 'linestyle', '-');
    if Nrx > 1
        set(p(index*3 + 2),'XData', [1:30], 'YData', second_ant_csi(:,k), 'color', 'g', 'linestyle', '-');
    end
    if Nrx > 2
        set(p(index*3 + 3),'XData', [1:30], 'YData', third_ant_csi(:,k), 'color', 'r', 'linestyle', '-');
    end
    axis([1,30,0,40]);
    % drawnow;
    
%     subplot(3,1,2);
%     axis([1,30,-10,30]);
%     t2=0;
%     m2=zeros(30,1);
%     p2 = plot(t2,m2,'MarkerSize',5);
%     xlabel('Subcarrier index');
%     ylabel('CSI Raw Phase');
%     set(p2(index*3 + 1),'XData', [1:30], 'YData',first_rph_csi(:,k), 'color', 'b', 'linestyle', '-');
%     if Nrx > 1
%         set(p2(index*3 + 2),'XData', [1:30], 'YData', second_rph_csi(:,k), 'color', 'g', 'linestyle', '-');
%     end
%     if Nrx > 2
%         set(p2(index*3 + 3),'XData', [1:30], 'YData', third_rph_csi(:,k), 'color', 'r', 'linestyle', '-');
%     end
%     axis([1,30,-5,5]);
    
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

probability = probability/60