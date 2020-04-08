clear;
load('csi01af.mat');
num_package = 100;
for i=1:num_package %这里是取的数据包的个数
        csi_entry = csi_trace{i};
        csi = get_scaled_csi(csi_entry); %提取csi矩阵    
        csi =csi(1,:,:);
        csi1=abs(squeeze(csi).');          %提取幅值(降维+转置)
        
        %只取一根天线的数据
        first_ant_csi(:,i)=csi1(:,1);           %直接取第一列数据(不需要for循环取)
        second_ant_csi(:,i)=csi1(:,2);
        third_ant_csi(:,i)=csi1(:,3);
        first_avg_ant_csi(i) = 0;
        second_avg_ant_csi(i) = 0;
        third_avg_ant_csi(i) = 0;
        for k=1:30
            first_avg_ant_csi(i) = first_avg_ant_csi(i) + first_ant_csi(k,i);
            second_avg_ant_csi(i) = second_avg_ant_csi(i) + second_ant_csi(k,i);
            third_avg_ant_csi(i) = third_avg_ant_csi(i) + third_ant_csi(k,i);
        end
        first_avg_ant_csi(i) = first_avg_ant_csi(i)/30;
        second_avg_ant_csi(i) = second_avg_ant_csi(i)/30;
        third_avg_ant_csi(i) = third_avg_ant_csi(i)/30;
end
figure(2)
plot(first_avg_ant_csi.')
% hold on;
% plot(second_ant_csi.')
% hold on;
% plot(third_ant_csi.')

xlabel('time stamp');
ylabel('CSI Amplitude (dB)');
% hold on;
% plot(second_ant_csi.')
% hold on;
% plot(third_ant_csi.')