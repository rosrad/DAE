function translate_mfcc(inf)
%this is the function that used for translate the original mfcc
%feature files using the DAE algorithm
    if (nargin<1)
        inf = 'conf.ini.0'
    end
    INI = ini2struct(inf);
    list = filelist(INI.in.list, INI.in.data_dir, 'mat');
    translate(list, INI);
end

function translate(list, ini)
    for idx = 1:length(list)
        load(list{idx}.fullpath, 'D', 'ext');
        outfile = strcat(ini.out.dae_dir, '/', list{idx}.base);
        fprintf('[==>]%s\n',outfile)
        check_basedir(outfile);
        para = restruct_paras(ext.nSamples-8, ini.in.weight);
        out = dae_calc(D, para);
        % be careful , we neet transposition the out data from the dae.
        write_feature(outfile, ext, out');
    end
end

function para = restruct_paras(nSmp, weight_file)
    load(weight_file);             
    layers = 4;
    for idx = 1:layers 
        eval(sprintf('para.W{%d} = w%d;', idx, idx));
    end
    %fprintf('w1 Same : %d\n', isequal(para.W{1}, w1));
    %fprintf('w2 Same : %d\n', isequal(para.W{2}, w2));
    %fprintf('w3 Same : %d\n', isequal(para.W{3}, w3));
    %fprintf('w4 Same : %d\n', isequal(para.W{4}, w4));
    para.nsmp = nSmp;
end

function out = dae_calc(in, para)
%this algorithm is using the trained parameters to get a dae
%disreverbed feature.
% TODO need to make the weight more clear
    layers = 4;
    tmp = [in ones(para.nsmp,1)];
    for idx = 1:layers
        if (idx == layers)
            output = exp_map(tmp, para.W{idx},false);
        end
        if idx ~= (layers/2)
            tmp = exp_map(tmp, para.W{idx});
        else
            tmp = line_map(tmp, para.W{idx});
        end
    end
    %here we just use the last 39 as the feature.
    %TODO Why I did not understand ?
    dimension = 39;
    num = size(output,2);
    out = output(:,num-dimension+1:num);
end

function out = line_map(in, weight)
    out = in*weight;
    out = [out  ones(size(out,1),1)];
end
function out = exp_map(in, weight, append)
    out = 1./(1 + exp(-in*weight)); 
    if (nargin == 2)
        append = true;
    end
    if (append)
        out = [out  ones(size(out,1),1)];
    end
end

function write_feature(outfile, ext, data)
    fid=fopen(outfile,'w');
    if (fid == -1)
        disp_err('Cannot Write outfile', sprintf('ErrorFile:%s', outfile));
        return;
    end
    fwrite(fid,ext.nSamples,'int','b');
    fwrite(fid,ext.sampPeriod,'int','b');
    fwrite(fid,ext.sampSize,'short','b');
    fwrite(fid,ext.parmKind,'short','b');
    fwrite(fid,data,'float32','b');
    fclose(fid);
end
