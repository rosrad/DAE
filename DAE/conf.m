%this a config file for DAE file
function fg=conf()
    fg.work_dir='/home/14/ren/work_q/DAE/work/';
    fg.source_dir=[fg.work_dir, '/source/'];
    fg.tmp_dir=[fg.work_dir, '/tmp/'];
    fg.env = 'reverb_only';
    fg.flist_dir=[fg.source_dir, '/flist/'];
    fg.train_list=[fg.flist_dir, '/1ch/SimData_tr_for_1ch_A.lst'];
    %fg.train_list=[fg.flist_dir, '/1ch/test.lst'];
    fg.clean_list=[fg.flist_dir, '/clean_train/si_tr.lst'];
    fg.features_input_dir='/home/14/ren/work/data/reverb_task/telephone/tmp/REVERBWSJCAM0/features/MFCC_0_D_A_Z_CEPLIFTER_1/';
    fg.features_output_dir='/home/14/ren/work/data/reverb_task/telephone/tmp/REVERBWSJCAM0/features/MFCC_0_D_A_Z_CEPLIFTER_1/dae/';
    fg.para=[fg.tmp_dir, '/para/'];
    fg.batchdata_dir=[fg.para, '/batchdata/'];
    fg.train_dir=[fg.para, '/train/'];
    fg.env_train_dir=[fg.train_dir, fg.env, '/'];
    fg.batchdata_env_dir=[fg.batchdata_dir, fg.env];
    fg.batchdata=[fg.batchdata_env_dir,'/batchdata.mat'];
    fg.clean_batchdata=[fg.batchdata_env_dir,'/clean_batchdata.mat'];
    fg.train_clean_dir=[fg.para, '/train/clean/'];
    fg.weight_dir = [fg.para, '/weight/'];
    fg.mnistweights = [fg.weight_dir, 'REVERB_challenge/it50_u1024/mnistweights_dim351'];
    dirs = {fg.flist_dir, fg.train_dir, fg.batchdata_env_dir, fg.weight_dir};
    for dir=dirs
        system(sprintf('mkdir  -p %s', dir{:}));
    end
end