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

% This program fine-tunes an autoencoder with backpropagation.
% Weights of the autoencoder are going to be saved in mnist_weights.mat
% and trainig and test reconstruction errors in mnist_error.mat
% You can also set maxepoch, default value is 200 as in our paper.  
fg = conf()
maxepoch=100;
fprintf(1,'\nFine-tuning deep autoencoder by minimizing cross entropy error. \n');
fprintf(1,'60 batches of 1000 cases each. \n');

load(fg.mnistweights);

load(fg.batchdata);
load(fg.clean_batchdata);

[numcases numdims numbatches]=size(batchdata);
N=numcases; 

%%%%%%%%%% END OF PREINITIALIZATIO OF WEIGHTS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

l1=size(w1,1)-1;
l2=size(w2,1)-1;
l3=size(w3,1)-1;
l4=size(w4,1)-1;
l5=l1; 
test_err=[];
train_err=[];


for epoch = 1:maxepoch
    
    W1=gpuArray(w1);
    W2=gpuArray(w2);
    W3=gpuArray(w3);
    W4=gpuArray(w4);

    %%%%%%%%%%%%%%%%%%%% COMPUTE TRAINING RECONSTRUCTION ERROR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [t_err]=calcprop_g(batchdata,W1,W2,W3,W4);
    train_err(epoch)=gather(t_err);
    %%%%%%%%%%%%%%%%%%%% COMPUTE TEST RECONSTRUCTION ERROR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [t_err]=calcprop_g(clean_batchdata,W1,W2,W3,W4);
    test_err(epoch)=gather(t_err);
    
    
    fprintf(1,'Before epoch %d Train squared error: %6.3f Test squared error: %6.3f \t \t \n',epoch,train_err(epoch),test_err(epoch));
    %%%%%%%%%%%%%% END OF COMPUTING TEST RECONSTRUCTION ERROR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    tt=0;
    for batch = 1:numbatches/10
        fprintf(1,'epoch %d batch %d\r',epoch,batch);

        %%%%%%%%%%% COMBINE 10 MINIBATCHES INTO 1 LARGER MINIBATCH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tt=tt+1; 
        data=[];
        data_test=[];
        for kk=1:10
            data=[data 
                  batchdata(:,:,(tt-1)*10+kk)]; 
            data_test=[data_test
                       clean_batchdata(:,:,(tt-1)*10+kk)];
        end 

        %%%%%%%%%%%%%%% PERFORM CONJUGATE GRADIENT WITH 3 LINESEARCHES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        max_iter=3;
        VV = gpuArray([w1(:)' w2(:)' w3(:)' w4(:)']');
        Dim = [l1; l2; l3; l4; l5;];
        
        A = gpuArray(data);
        B = gpuArray(data_test);
        [X2, fX2] = minimize(VV,'CG_MNIST',max_iter,Dim,A,B);
        X = gather(X2);
        fX = gather(fX2); 
        
        w1 = reshape(X(1:(l1+1)*l2),l1+1,l2);
        xxx = (l1+1)*l2;
        w2 = reshape(X(xxx+1:xxx+(l2+1)*l3),l2+1,l3);
        xxx = xxx+(l2+1)*l3;
        w3 = reshape(X(xxx+1:xxx+(l3+1)*l4),l3+1,l4);
        xxx = xxx+(l3+1)*l4;
        w4 = reshape(X(xxx+1:xxx+(l4+1)*l5),l4+1,l5);

        %%%%%%%%%%%%%%% END OF CONJUGATE GRADIENT WITH 3 LINESEARCHES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end
    save([fg.weight_dir, '/REVERB_challenge/it50_u1024/it100/mnist_weights_dim351'], 'w1', 'w2', 'w3', 'w4', '-v7.3');
    if epoch==50
        save([fg.weight_dir, '/REVERB_challenge/it50_u1024/it50/mnist_weights_dim351_ep50'], 'w1', 'w2', 'w3', 'w4', '-v7.3');
    end

end



