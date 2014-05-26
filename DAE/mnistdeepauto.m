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


% This program pretrains a deep autoencoder for MNIST dataset
% You can set the maximum number of epochs for pretraining each layer
% and you can set the architecture of the multilayer net.

clear all
close all

maxepoch=50; %In the Science paper we use maxepoch=50, but it works just fine. 
numhid=1024; numpen=1024;

fprintf(1,'Pretraining a deep autoencoder. \n');
fprintf(1,'This uses %3i epochs \n', maxepoch);

load ../batchdata/batchdata.mat;

[numcases numdims numbatches]=size(batchdata);

fprintf(1,'Pretraining Layer 1 with RBM: %d-%d \n',numdims,numhid);
restart=1;
rbm;
vispen=vishid; hidrecbiases=hidbiases; visgenbiases=visbiases; 

fprintf(1,'\nPretraining Layer 2 with RBM: %d-%d \n',numhid,numpen);
batchdata=batchposhidprobs;
numhid=numpen;
restart=1;
rbm;
hidpen=vishid; penrecbiases=hidbiases; hidgenbiases=visbiases;

w1=[vispen; hidrecbiases];
w2=[hidpen; penrecbiases];
w3=[hidpen'; hidgenbiases];
w4=[vispen'; visgenbiases];

save weight/REVERB_challenge/it50_u1024/mnistweights_dim351 w1 w2 w3 w4 -v7.3;
