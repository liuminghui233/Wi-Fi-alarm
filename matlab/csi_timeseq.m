clear all;
csi_trace = read_bf_file('csi_data/static01.dat');
num_package = length(csi_trace);
for i=1:num_package %这里是取的数据包的个数
        csi_entry = csi_trace{i};
        csi = get_scaled_csi(csi_entry); %提取csi矩阵    
        csi =csi(1,:,:);
        csi1=abs(squeeze(csi).');          %提取幅值(降维+转置)
        
        %只取一根天线的数据
        first_ant_csi(:,i)=csi1(:,1);           %直接取第一列数据(不需要for循环取)
        second_ant_csi(:,i)=csi1(:,2);
        third_ant_csi(:,i)=csi1(:,3);
end

hold on;
plot(first_ant_csi.')
hold on;
plot(second_ant_csi.')
hold on;
plot(third_ant_csi.')