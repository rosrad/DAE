function makebatch()
%this is a new make batch filename
%% caculate the sum of all samples from the filelist
    fg = conf();
    filelist = fg.train_list;
    disp(filelist);
    fid = fopen(filelist);
    if (fid == -1)
        disp(['Error : cannot open file list', filelist]);
        return;
    end
    sample_map = {};
    index = 0;
    sum = 0;
    disp('############ Map File Begin ##############');
    while 1
        filename = fgetl(fid);
        if ~ischar(filename)
            break;
        end
        cap = read_num(filename);
        index = index+1;
        sum = sum+cap;
        sample_map{index,1} = sum;
        sample_map{index,2} = filename;
        sample_map{index,3} = cap;
    end
    fclose(fid);
    disp('############ Map File End ##############');
    %% make the batch map
    rand('state',0);
    randlist = randperm(sum);
    sample_list = {};
    disp('############ Build Batch Begin ##############');
    for n = 1:length(randlist)
        %disp(sprintf('Batch No %d', n));
        for idx = 1:length(sample_map)
            num = randlist(n);
            if num <= sample_map{idx,1} 
                sample_list{n,1}=sample_map{idx,2}; %the features file
                sample_list{n,2}=sample_map{idx,3} + num - sample_map{idx,1}; % offset in
                                                                              %        disp(sprintf('Batch No %d  Offset : %d ,File: %s\n', num,sample_list{n,2},sample_list{n,1}));
                break;
            end
        end
    end
    disp(sprintf('Builded Batch %d'),size(sample_list,1));
    disp('############ Build Batch End ##############');
    save(sample_list, 'sample_list');
end

function n = read_num(filename)
    fg = conf();
    file_path = [fg.env_train_dir, filename, '.mat'];
    load(file_path);
    n = size(D, 1);
end