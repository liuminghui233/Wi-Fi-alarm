flag = 0;
for type = 0:7
    if type > 0
        label = 1;
        labels = ones(60,1);
    else 
        label = 0;
        labels = zeros(60,1);
    end
    for index = 1:3
        filename = ['csi_data/','0',int2str(type),'00',int2str(index),'.dat'] 
        batch_data = get_batch_data(filename, 0, 60);
        
        if flag == 0
            dataset90 =[labels (reshape(batch_data,90,60)).'];
            flag = 1;
        else
          dataset90 =  cat(1,dataset90,[labels (reshape(batch_data,90,60)).']);
        end
    end
end

save dataset90;

