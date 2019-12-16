function feature_vetor = get_feature_vetor(csi_entry)

csi=zeros(3,30);
point=128;
time_csi=zeros(3,point);
time_csi_abs=zeros(3,point);
csi_point=zeros(3,point);

csientry = get_scaled_csi(csi_entry);
perm = csi_entry.perm;
for k=1:3
    if perm(k)==1
        csi(1,:)=csientry(1,perm(k));
        time_csi(1,:)=ifft(csi(1,:),point);
        time_csi_abs(1,:)=abs(time_csi(1,:));
    elseif perm(k)==2
        csi(2,:)=csientry(1,perm(k));
        time_csi(2,:)=ifft(csi(2,:),point);
        time_csi_abs(2,:)=abs(time_csi(2,:));
    elseif perm(k)==3
        csi(3,:)=csientry(1,perm(k));
        time_csi(3,:)=ifft(csi(3,:),point);
        time_csi_abs(3,:)=abs(time_csi(3,:));
    end
end
%ÂË²¨´¦Àí
for k=1:point
    if(time_csi_abs(1,k))<0.2*max(time_csi_abs(1,:))
        time_csi(1,k)=0;
    end
    if(time_csi_abs(2,k))<0.2*max(time_csi_abs(2,:))
        time_csi(2,k)=0;
    end
    if(time_csi_abs(3,k))<0.2*max(time_csi_abs(3,:))
        time_csi(3,k)=0;
    end
end
time_csi(1,[40:128])=zeros(1,89);
time_csi(2,[40:128])=zeros(1,89);
time_csi(3,[40:128])=zeros(1,89);
time_csi(1,[40:(128-(40-24))])=zeros(1,73);
time_csi(2,[40:(128-(40-24))])=zeros(1,73);
time_csi(3,[40:(128-(40-24))])=zeros(1,73);
for k=1:3
    csi_point(k,:)=fft(time_csi(k,:),point);
    csi(k,:)=csi_point(k,[1:30]);
end

numcases=1; %how to group data
numdims=90; %visible nodes
data_batch = zeros(numcases, numdims);
data_batch(1,:) = [(abs(squeeze(csi(1,:)))) (abs(squeeze(csi(2,:)))) (abs(squeeze(csi(3,:))))];
data_batch=data_batch/max(max(data_batch));

feature_vetor = data_batch;