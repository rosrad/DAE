function[t_err]=calcprop_g(data, w1,w2,w3,w4);   
    err=0; 
    [numcases numdims numbatches]=(data);
    for idx = 1:numbatches
        data = gpuArray(data[:,:,idx]);
        data = [data ones(numcases,1)];
        w1probs = 1./(1 + exp(-data*w1)); w1probs = [w1probs  ones(numcases,1)];
        w2probs = w1probs*w2; w2probs = [w2probs  ones(numcases,1)];
        w3probs = 1./(1 + exp(-w2probs*w3)); w3probs = [w3probs  ones(numcases,1)];
        dataout = 1./(1 + exp(-w3probs*w4));
        err= err +  1/numcases*sum(sum( (data(:,1:end-1)-dataout).^2 )); 
    end
    t_err=err/numbatches;
end
