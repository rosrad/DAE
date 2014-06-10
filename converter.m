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

function converter()
    INI = ini2struct('conf.ini');
    % get file list
    list = filelist(INI.input.testlist, INI.input.feature_dir);
    if length(list)==0
        disp_err('List file', '');
    end
    % get the samples from the file list
    samples = data(list);
    
    [ave, var] = mean_var(samples);
    %fprintf('Mean : %s , Var : %s \n', ave, var);
    % normalization 
    normalization(samples, ave, var);
end

function [ave, var] = mean_var(data)
    % calculate the mean and varinace 
    total = [];
    for idx = 1:length(data)
        total = [total,data{idx}.data];
    end
    ave=mean(total,2);
    var=std(total,0,2);
end

function normalization(data, ave, var)
    disp('begin to normalization');
    num_files = length(data);
    %TODO make this more clear
    for idx = 1:num_files
        rawdata=bsxfun(@rdivide,bsxfun(@minus,data{idx}.data,ave),var);
        rawdata=1./(1+exp(-rawdata));
        D = [];
        num_smples = size(data{idx}.data,2);
        for smp_idx = 1:num_smples-8
            %% fprintf(asci_wf,'%f ',rawdata([1:39],a:a+8))
            joint_smaples = rawdata(1:39,smp_idx:smp_idx+8);
            feature = joint_smaples(:);
            D = [D;feature'];
        end
        fprintf('%5d Digits of class %d_%d\n',size(D,1),idx,num_files);
        save([data{idx}.file,'.mat'],'D','-mat');
        clear('D');
    end
end

function list = filelist(file, basedir)
    list = {};
    fid = fopen(file);
    if (fid == -1)
        disp(fprintf('[Error] [Read FileList] %s', file));
        return;
    end
    items = textscan(fid, '%s', 'delimiter', '\n');
    subitems = items{1};
    
    for idx = 1:length(subitems)
        list{end+1} = strcat(basedir, '/', subitems{idx});
        %fprintf('%s\n', list{idx});
    end
    fclose(fid);
end

function disp_err(msg, ext)
    type = 1;
    msg_type = {'Warning', 'Dead'};
    disp(sprintf('[%s] [%s] [%s]', msg_type{type}, msg, ext))
end

function samples = data (list)
    samples = {};
    for idx = 1:length(list)
        fid =fopen(list{idx},'r');
        if (fid == -1)
            disp_err('ReadSample', list{idx});
            continue;
        end
        nSamples = fread(fid,1,'int','b');
        sampPeriod = fread(fid,1,'int','b');
        sampSize = fread(fid,1,'short','b');
        parmKind = fread(fid,1,'short','b');
        rawdata = fread(fid,nSamples*(sampSize/4),'float','b');
        rawdata = reshape(rawdata,sampSize/4,nSamples);
        samples{end+1} = struct('file',list{idx}, 'data', rawdata);
        fclose(fid);
    end
    if (length(list) ~= length(samples))
        disp_err('Listed file missed!','');
    end
end

