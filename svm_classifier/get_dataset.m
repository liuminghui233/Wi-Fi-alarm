flag = 0;
for type = 0:2
    if type == 1
        label = 1;
        labels = ones(96,1);
    else
        label = 0;
        labels = zeros(96,1);
    end
    for index = 1:6
        filename = ['csi_data/','0',int2str(type),'00',int2str(index),'.dat'] 
        batch_data = get_batch_data(filename, 0, 96);
        
        if flag == 0
            dataset =[labels (reshape(batch_data,90,96)).'];
            flag = 1;
        else
          dataset =  cat(1,dataset,[labels (reshape(batch_data,90,96)).']);
        end
    end
end

save dataset
