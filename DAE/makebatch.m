%this is a new make batch filename
function makebatch()
    
end
    
function make_randlist()
%% caculate the sum of all samples from the filelist
    fg = conf();
    filelist = fg.test_list;
    disp(filelist);
    fid = fopen(filelist);
    if (fid == -1)
        disp(['Error : cannot open file list', filelist]);
        return;
    end
    sample_map = {};
    index = 0;
    sum = 0;
    while 1
        filename = fgetl(fid);
        if ~ischar(filename)
            break;
        end
        file_path = [fg.features_input_dir, filename];
        nSamples = read_samples(file_path);
        index = index+1;
        cap = nSamples-8;
        sum = sum+cap;
        sample_map{index,1} = sum
        sample_map{index,2} = file_path
        sample_map{index,3} = cap
    
    end
    fclose(fid);
    %% make the batch map
    rand('state',0);
    randlist = randperm(sum)
    batchsize = 256;
    batches = sum/batchsize;
    sample_finder = {};
    
    for n = 1:length(randlist)
    
        for idx = 1:length(sample_map)
            num = randlist(n);
            if num <= sample_map{idx,1} 
                sample_finder{n,1}=sample_map{idx,2}; %the features file
                sample_finder{n,2}=sample_map{idx,3} + num - sample_map{idx,1}; % offset in
                break;
            end
        end
    end
    
    %save('batchlist', 'sample_finder');
end

function n = read_samples(features_file)
    f=fopen(features_file,'r');
    n=0;
    if f <= 0
        disp(['Error while read sample number ==> file: ', features_file]);
        return;
    end
    n = fread(f,1,'int','b');
    fclose(f);
end