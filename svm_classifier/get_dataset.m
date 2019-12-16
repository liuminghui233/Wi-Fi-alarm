flag = 0;
for type = 0:7
    for index = 1:3
        filename = ['csi_data/','0',int2str(type),'00',int2str(index),'.dat']; 
        batch_data = get_batch_data(filename, 0, 60);
        if flag == 0
            dataset =  reshape(batch_data,450,1,12);
            flag = 1;
        else
          dataset =  cat(3,dataset,reshape(batch_data,450,1,12));
        end
    end
end


