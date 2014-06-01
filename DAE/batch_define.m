%% this m-file give the information of the batch
function [batchsize numdims batchnum] = batch_define(type)
    path = sprintf('sample_list_%s', type);
    load(path);
    batchsize = 256;
    sample_size = size(sample_list,1); 
    batchnum = fix(sample_size/batchsize);
    numdims = size(readsample(sample_list{1},sample_list{1}), 2);
end

function sample = readsample(filename, idx)
    fg = conf();
    file_path = [fg.env_train_dir, filename, '.mat'];
    load(file_path);
    sample = D(idx,:);
end