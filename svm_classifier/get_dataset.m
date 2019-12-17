flag = 0;
for type = 0:1
    if type > 0
        label = 1;
        labels = ones(40,1);
    else 
        label = 0;
        labels = zeros(40,1);
    end
    for index = 1:6
        filename = ['csi_data/','0',int2str(type),'00',int2str(index),'.dat'] 
        batch_data = get_batch_data(filename, 0, 200);
        
        if flag == 0
            dataset90 =[labels (reshape(batch_data,450,40)).'];
            flag = 1;
        else
          dataset90 =  cat(1,dataset90,[labels (reshape(batch_data,450,40)).']);
        end
    end
end

save dataset;

