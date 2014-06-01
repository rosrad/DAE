%% this file is used to read batch data from the new batchlist
function data =  readbatches(env)
    data_path = sprintf('batch_data_%s',env);
    
    if exist(fullfile('~/work_q/DAE/', [data_path,'.mat']), 'file')
        load(data_path);
        return;
    end
    [batchsize dims batchnum] = batch_define(env);
    for idx = 1:3
        disp(sprintf('batch No %d / %d', idx, batchnum));
        data(:,:,idx) = readbatch(env,idx);
    end
    save(data_path, 'data');
end

function data = readbatch(env,index)
    path = sprintf('sample_list');
    load(path);
    batchsize = 256;
    data = [];
    if index > size(sample_list,1)/batchsize
        fprintf('Error : out of the batch size\n');
        return
    end
    baseidx= (index-1)*batchsize;
    for idx = 1:batchsize
        fprintf('.');
        %disp(sprintf('Index: %d , Offset: %d , File: %s', idx, sample_list{baseidx+idx,2}, sample_list{baseidx+idx,1}));
        sample = readsample(sample_list{baseidx+idx,1},sample_list{baseidx+idx,2});
        data = [data;sample];
    end
    fprintf('\n');
    %save(['batch_data_',num2str(index)], 'data');
end

function sample = readsample(filename, idx)
    fg = conf();
    file_path = [fg.train_dir,env, filename, '.mat'];
    load(file_path);
    sample = D(idx,:);
end