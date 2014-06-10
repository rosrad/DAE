fprintf('a\n');
ini = ini2struct('conf.ini');
%%%%%%%%%%%%%%%%set value%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filenamelist_tr=cell(20000,1);
num1ch_tr=0;

flist = fopen(ini.input.train_list);
filename = fgetl(flist);
while ischar(filename)
    num1ch_tr=num1ch_tr+1;
    filenamelist_tr{num1ch_tr}=filename;
    filename=fgetl(flist);
end
fclose(flist);

load(ini.input.weight);
%%%%%%%%%%%%%%%%load data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputdata=[];
fprintf('calculate output now...\n');
numdims = 351;

for i = 1:num1ch_tr
    f=fopen([ini.input.feature_dir, filenamelist_tr{i}],'r');
    nSamples = fread(f,1,'int','b')-8;
    load([ini.input.env_train_dir,filenamelist_tr{i},'.mat']);
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
flist = fopen(ini.input.train_list);
filename = fgetl(flist);
while ischar(filename);
    disp(filename);
    [f,msg]=fopen([ini.input.feature_dir,filename],'r');
    disp(msg);
    nSamples = fread(f,1,'int','b')-8;
    load([ini.input.env_train_dir,filenamelist_tr{i},'.mat']);
    if nSamples~=size(D,1)
        disp(nSamples);
        disp(size(D,1));
        %pause;
        incurrect=incurrect+1;
    end

    sampPeriod = fread(f,1,'int','b');
    sampSize = fread(f,1,'short','b');
    parmKind = fread(f,1,'short','b');
    % type make the parent directories
    file = strjoin({ini.output.dae_feature,filename}, '');
    disp(file);
    parts=strsplit(file,'/');
    dir = strjoin({parts{1:end-1}}, '/');
    system(sprintf('mkdir -p %s', dir));
    D=fopen(file,'w');
    
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

