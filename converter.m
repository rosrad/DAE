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

function converter(inf)
    if (nargin<1)
        inf = 'conf.ini.0';
    end
    INI = ini2struct(inf);
    % get file list
    list = filelist(INI.in.list, INI.in.feature_dir);
    if length(list)==0
        disp_err('List file', '');
    end
    % get the samples from the file list
    samples = data(list);
    
    [ave, var] = mean_var(samples);
    %fprintf('Mean : %s , Var : %s \n', ave, var);
    % normalization 
    normalization(samples, ave, var, INI.in.data_dir);
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

function normalization(data, ave, var, store_dir)
    disp('begin to normalization');
    num_files = length(data);
    if (nargin < 4)
        store_dir = '';
    end
    %TODO make this more clear
    for idx = 1:num_files
        rawdata=bsxfun(@rdivide,bsxfun(@minus,data{idx}.data,ave),var);
        rawdata=1./(1+exp(-rawdata));
        D = [];
        ext = data{idx}.ext;
        for smp_idx = 1:ext.nSamples-8
            %% fprintf(asci_wf,'%f ',rawdata([1:39],a:a+8))
            joint_smaples = rawdata(1:39,smp_idx:smp_idx+8);
            feature = joint_smaples(:);
            D = [D;feature'];
        end
        fprintf('%5d Digits of class %d_%d\n',size(D,1),idx,num_files);

        if (~isempty(store_dir))
            outfile = strcat(store_dir, data{idx}.part, '.mat');
            check_basedir(outfile);
            fprintf('Save Data to %s\n', outfile);
            save(outfile,'D', 'ext', '-mat');
        end
        clear('D');
    end
end

function samples = data (list)
    samples = {};
    for idx = 1:length(list)
        fid =fopen(list{idx}.fullpath,'r');
        if (fid == -1)
            disp_err('ReadSample', list{idx}.fullpath);
            continue;
        end
        ext.nSamples = fread(fid,1,'int','b');
        ext.sampPeriod = fread(fid,1,'int','b');
        ext.sampSize = fread(fid,1,'short','b');
        ext.parmKind = fread(fid,1,'short','b');
        rawdata = fread(fid,ext.nSamples*(ext.sampSize/4),'float','b');
        rawdata = reshape(rawdata,ext.sampSize/4,ext.nSamples);
        
        samples{idx}.part = list{idx}.part;
        samples{idx}.ext = ext;
        samples{idx}.data = rawdata;
        fclose(fid);
    end
    if (length(list) ~= length(samples))
        disp_err('Listed file missed!','');
    end
end







