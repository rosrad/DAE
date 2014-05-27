fprintf('a\n');
fg = conf()
%%%%%%%%%%%%%%%%set value%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filenamelist_tr=cell(20000,1);
num1ch_tr=0;

flist = fopen(fg.train_list);
filename = fgetl(flist);
while ischar(filename)
    num1ch_tr=num1ch_tr+1;
    filenamelist_tr{num1ch_tr}=filename;
    filename=fgetl(flist);
end
fclose(flist);

load [fg.weight_dir, 'REVERB_challenge/it50_u1024/it100/mnist_weights_dim351.mat'];
%%%%%%%%%%%%%%%%load data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputdata=[];
fprintf('calculate output now...\n');
numdims = 351;

for i = 1:num1ch_tr
    f=fopen([fg.features_input_dir, filenamelist_tr{i}],'r');
    nSamples = fread(f,1,'int','b')-8;
    load(['../data/train/total_environment',filenamelist_tr{i},'.mat']);
    data = D;
    data=[data ones(nSamples,1)];
    w1probs = 1./(1 + exp(-data*w1)); w1probs = [w1probs  ones(nSamples,1)];
    w2probs = w1probs*w2; w2probs = [w2probs  ones(nSamples,1)];
    w3probs = 1./(1 + exp(-w2probs*w3)); w3probs = [w3probs  ones(nSamples,1)];
    dataout = 1./(1+exp(-w3probs*w4));
    outputdata = [outputdata; dataout(:,313:351)];
    clear data;
    fclose(f);
end;
%%%%%%%%%%%%%%%%write data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('write data now...');
nowframe=1;
output39dim=zeros(size(outputdata,2),size(outputdata,1));
output39dim([1:39],:)=outputdata';

i=1;
incurrect=0;
flist = fopen(fg.train_list);
filename = fgetl(flist);
while ischar(filename);
    f=fopen([fg.features_input_dir,filename],'r');%1ch far

    nSamples = fread(f,1,'int','b')-8;
    load([fg.train_dir,filenamelist_tr{i},'.mat']);
    if nSamples~=size(D,1)
        disp(nSamples);
        disp(size(D,1));
        %pause;
        incurrect=incurrect+1;
    end

    sampPeriod = fread(f,1,'int','b');
    sampSize = fread(f,1,'short','b');
    parmKind = fread(f,1,'short','b');
    D=fopen([fg.features_output_dir,filename],'w');
    fwrite(D,nSamples,'int','b');
    fwrite(D,sampPeriod,'int','b');
    fwrite(D,sampSize,'short','b');
    fwrite(D,parmKind,'short','b');
    fwrite(D,output39dim(:,nowframe:nowframe+nSamples-1),'float32','b');
    nowframe=nowframe+nSamples;
    fclose(f);
    fclose(D);
    filename = fgetl(flist);
    i=i+1;
end

fclose(flist);
disp(nowframe);
fprintf('missframe=');
disp(incurrect);

