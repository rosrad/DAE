%this a config file for DAE file
function fg=conf()
    fg.work_dir=''
    fg.source_dir=''
    fg.tmp_dir=''
    fg.env = 'reverb_only'
    fg.flist_dir= ''
    fg.train_list=[fg.flist_dir, '/1ch/SimData_tr_for_1ch_A.lst'];
    fg.clean_list=[fg.flist_dir, '/clean_train/si_tr.lst'];
    fg.features_input_dir='';
    fg.features_output_dir='';
    fg.para_tmp=[fg.tmp_dir, 'para'];
    fg.batchdata_dir=[fg.para_tmp, 'batchdata'];
end