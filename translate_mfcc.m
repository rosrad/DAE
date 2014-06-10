function translate_mfcc()
%this is the function that used for translate the original mfcc
%feature files using the DAE algorithm
    ini = ini2struct('conf.ini');
    list = filelist(ini.in.testlist, ini.in.data_dir, 'mat');
    translate(list, ini.out.feature_dir)
end

function translate(list, out_basedir)
    for idx = 1:length(list)
        load(list{idx}.fullpath, 'D', 'ext');
        outfile = strcat(out_basedir, '/', list{idx}.base);
        check_basedir(outfile);
        out = dae_calc(D,ext.nSamples - 8 );
        % be careful , we neet transposition the out data from the dae.
        write_feature(outfile, ext, out');
    end
end

function out = dae_calc(in, nSamples)
%this algorithm is using the trained parameters to get a dae
%disreverbed feature.
% TODO need to make the weight more clear
    ini = ini2struct('conf.ini');
    load(ini.in.weight);             
    data=[in ones(nSamples,1)];
    w1probs = 1./(1 + exp(-data*w1)); w1probs = [w1probs  ones(nSamples,1)];
    w2probs = w1probs*w2; w2probs = [w2probs  ones(nSamples,1)];
    w3probs = 1./(1 + exp(-w2probs*w3)); w3probs = [w3probs  ones(nSamples,1)];
    output = 1./(1+exp(-w3probs*w4));
    %here we just use the last 39 as the feature.
    %TODO Why I did not understand ?
    dimension = 39;
    num = size(output,2);
    out = output(:,num-dimension+1:num);
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
