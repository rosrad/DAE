%% this file is used to read batch data from the new batchlist

function data = readbatch(index)
    load('batch_list');
    batchsize = 256;
    data = [];
    if index > size(sample_list,1)/batchsize
        fprintf('Error : out of the batch size\n');
        return
    end
    baseidx= (index-1)*batchsize;
    for idx = 1:batchsize
        disp(sprintf('Offset: %d , File: %s', sample_list{baseidx+idx,2}, sample_list{baseidx+idx,1}));
        sample = readsample(sample_list{baseidx+idx,1},sample_list{baseidx+idx,2});
        data = [data;sample];
    end
    %save(['batch_data_',num2str(index)], 'data');
end

function sample = readsample(filename, idx)
    fg = conf();
    file_path = [fg.env_train_dir, filename, '.mat'];
    load(file_path);
    sample = D(idx,:);
end