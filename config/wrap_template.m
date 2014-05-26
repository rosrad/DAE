function wrap_template(cmd)
%% this a template for warp some INSTRUCTIONS
addpath('/home/14/ren/work/experiment/reverb14_kaldi_baseline/');

%%Generate_mcTrainData_cut('/CDShare/Corpus/REVERB/wsjcam0');
%%cmd = ['Generate_mcTrainData_cut ',  '/CDShare/Corpus/REVERB/wsjcam0/']
try
    eval(cmd)
catch err
    
    disp(err)
    
end