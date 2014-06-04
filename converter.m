% Version 1.000
%
% Code provided by Ruslan Salakhutdinov and Geoff Hinton
%
% Permission is granted for anyone to copy, use, modify, or distribute this
% program and accompanying programs and documents for any purpose, provided
% this copyright notice is retained and prominently displayed, along with
% a note saying that the original programs are available from our
% web page.
% The programs and documents are distributed without any warranty, express or
% implied.  As the programs were written for research purposes only, they have
% not been tested to the degree that would be advisable in any important
% application.  All use of these programs is entirely at the user's own risk.

% This program reads raw MNIST files available at 
% http://yann.lecun.com/exdb/mnist/ 
% and converts them to files in matlab format 
% Before using this program you first need to download files:
% train-images-idx3-ubyte.gz train-labels-idx1-ubyte.gz 
% t10k-images-idx3-ubyte.gz t10k-labels-idx1-ubyte.gz
% and gunzip them. You need to allocate some space for this.  

% This program was originally written by Yee Whye Teh 

% Work with test files first 
fg = conf();
env = fg.env;

total_train=[];
frame=1;
i=1;
fprintf('calculate average and variance of traindata now...\n'); 
flist = fopen(fg.train_list);                                                                                                                         
filename = fgetl(flist);
while ischar(filename);
    f=fopen([fg.features_input_dir,filename],'r');
    nSamples = fread(f,1,'int','b');
    sampPeriod = fread(f,1,'int','b');
    sampSize = fread(f,1,'short','b');
    parmKind = fread(f,1,'short','b');
    rawdata = fread(f,nSamples*(sampSize/4),'float','b');
    rawdata = reshape(rawdata,sampSize/4,nSamples);
    total_train(:,frame:frame+nSamples-1)=rawdata(:,:);
    frame=frame+nSamples;
    fclose(f);
    i=i+1;
    filename=fgetl(flist);
end;
fclose(flist);

ave=mean(total_train,2);
var=std(total_train,0,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_sp=0;
filenamelist=cell(10266,1);

fprintf('get filename now...\n');

flist = fopen(fg.train_list);
filename = fgetl(flist);
while ischar(filename)
    num_sp=num_sp+1;
    filenamelist{num_sp}=filename;
    filename=fgetl(flist);
end;
fclose(flist);

fprintf('total file');
disp(num_sp);

fprintf('normalization now...\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:num_sp
    %TODO
    asci_wf = fopen([fg.train_dir,env,filenamelist{i},'.ascii'],'w');
    if (asci_wf <= 0)
        disp(sprintf('Error Read File : %s', file));
    end
    mfc_rf=fopen(['/Work/shizuokau/ueda/reverb_tools_for_asr/REVERBWSJCAM0/features/MFCC_0_D_A_Z_CEPLIFTER_1',filenamelist{i}],'r');
    nSamples = fread(mfc_rf,1,'int','b');
    sampPeriod = fread(mfc_rf,1,'int','b');
    sampSize = fread(mfc_rf,1,'short','b');
    parmKind = fread(mfc_rf,1,'short','b');
    rawdata = fread(mfc_rf,nSamples*(sampSize/4),'float','b');
    rawdata = reshape(rawdata,sampSize/4,nSamples);
    rawdata=bsxfun(@rdivide,bsxfun(@minus,rawdata,ave),var);
    rawdata=1./(1+exp(-rawdata));
    for a=1:nSamples-8
        fprintf(asci_wf,'%f ',rawdata([1:39],a:a+8));
        fprintf(asci_wf,'\n');
    end;
    fclose(asci_wf);
    fclose(mfc_rf);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('write data now...\n');

for i=1:num_sp
    D = load([fg.train_dir,env,filenamelist{i},'.ascii'],'-ascii');
    fprintf('%5d Digits of class %d_%d\n',size(D,1),i,num_sp);
    save([fg.train_dir,env,filenamelist{i},'.mat'],'D','-mat');
end;

fprintf('delete ascii data\n');
dos(['rm ',fg.train_dir,env,'/mc_train/primary_microphone/si_tr/*/*.ascii']); 