function feature_vetor = get_feature_vetor(csi_trace,index)
%% Initialize variables
M=60;N=0;
csi=zeros(3,30,M-N);
point=128;
time_csi=zeros(3,point,M-N);
time_csi_abs=zeros(3,point,M-N);
csi_point=zeros(3,point,M-N);

%% 
for i=(N+1):M
    csi_entry = csi_trace{i};
    csientry = get_scaled_csi(csi_entry);
    perm = csi_entry.perm;
    for k=1:3
        if perm(k)==1
            csi(1,:,i-N)=csientry(1,perm(k),:);
            time_csi(1,:,i-N)=ifft(csi(1,:,i-N),point);
            time_csi_abs(1,:,i-N)=abs(time_csi(1,:,i-N));
        elseif perm(k)==2
            csi(2,:,i-N)=csientry(1,perm(k),:);
            time_csi(2,:,i-N)=ifft(csi(2,:,i-N),point);
            time_csi_abs(2,:,i-N)=abs(time_csi(2,:,i-N));
        elseif perm(k)==3
            csi(3,:,i-N)=csientry(1,perm(k),:);
            time_csi(3,:,i-N)=ifft(csi(3,:,i-N),point);
            time_csi_abs(3,:,i-N)=abs(time_csi(3,:,i-N));
        end
    end
    %滤波处理
    for k=1:point
        if(time_csi_abs(1,k,i-N))<0.2*max(time_csi_abs(1,:,i-N))
            time_csi(1,k,i-N)=0;
        end
        if(time_csi_abs(2,k,i-N))<0.2*max(time_csi_abs(2,:,i-N))
            time_csi(2,k,i-N)=0;
        end
        if(time_csi_abs(3,k,i-N))<0.2*max(time_csi_abs(3,:,i-N))
            time_csi(3,k,i-N)=0;
        end
    end
    time_csi(1,[40:128],i-N)=zeros(1,89);
    time_csi(2,[40:128],i-N)=zeros(1,89);
    time_csi(3,[40:128],i-N)=zeros(1,89);
    time_csi(1,[40:(128-(40-24))],i-N)=zeros(1,73);
    time_csi(2,[40:(128-(40-24))],i-N)=zeros(1,73);
    time_csi(3,[40:(128-(40-24))],i-N)=zeros(1,73);
    for k=1:3
        csi_point(k,:,i-N)=fft(time_csi(k,:,i-N),point);
        csi(k,:,i-N)=csi_point(k,[1:30],i-N);
    end
    %作图（时域频域）
%     hold on
%     plot(db(abs(squeeze(csi(1,:,i-N)))),'r')
%     hold on
%     plot(db(abs(squeeze(csi(2,:,i-N)))),'b')
%     hold on
%     plot(db(abs(squeeze(csi(3,:,i-N)))),'g')
%     xlabel('Subcarrier index');
%     ylabel('SNR [dB]');
end

%% 
numcases=1; %how to group data
numdims=90; %visible nodes
numbatches=(M-N)/numcases;
data_batch = zeros(numcases, numdims, numbatches);
for b=1:numbatches
    for c=1:numcases
        %三天线实虚部分开180节点输入
        %         batchdata(c,:,b) = [real(squeeze(csi(1,:,(b-1)*numcases+c))) imag(squeeze(csi(1,:,(b-1)*numcases+c))) real(squeeze(csi(2,:,(b-1)*numcases+c))) imag(squeeze(csi(2,:,(b-1)*numcases+c))) real(squeeze(csi(3,:,(b-1)*numcases+c))) imag(squeeze(csi(3,:,(b-1)*numcases+c)))];
        %三天线90个节点输入
        data_batch(c,:,b) = [(abs(squeeze(csi(1,:,(b-1)*numcases+c)))) (abs(squeeze(csi(2,:,(b-1)*numcases+c)))) (abs(squeeze(csi(3,:,(b-1)*numcases+c))))];
        %三天线串放一个package作为输入30节点
        %         batchdata(3*c-2,:,b) = [(abs(squeeze(csi(1,:,(b-1)*numcases+c))))];
        %         batchdata(3*c-1,:,b) = [(abs(squeeze(csi(2,:,(b-1)*numcases+c))))];
        %         batchdata(3*c,:,b) = [(abs(squeeze(csi(3,:,(b-1)*numcases+c))))];
        %90节点18分段输入
        %         batchdata(c,:,b) = [(sum(abs(squeeze(csi(1,[1:5],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(1,[6:10],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(1,[11:15],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(1,[16:20],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(1,[21:25],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(1,[26:30],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(2,[1:5],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(2,[6:10],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(2,[11:15],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(2,[16:20],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(2,[21:25],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(3,[26:30],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(3,[1:5],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(3,[6:10],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(3,[11:15],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(3,[16:20],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(3,[21:25],(b-1)*numcases+c))))) (sum(abs(squeeze(csi(3,[26:30],(b-1)*numcases+c)))))];
        %时域最高点输入
        %         batchdata(c,:,b) = [max(abs(squeeze(time_csi(1,:,(b-1)*numcases+c)))) max(abs(squeeze(time_csi(2,:,(b-1)*numcases+c)))) max(abs(squeeze(time_csi(3,:,(b-1)*numcases+c))))];
    end
end
data_batch=data_batch/max(max(max(data_batch)));
feature_vetor = data_batch(:,:,index);