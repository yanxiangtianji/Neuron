function CMmat=trainTestAW(fn_train,fn_test,n,D,Ainit,Winit,lambda)

%rData=readRawSpike(fn_spike);%   dMin=0.0001;    dUnit=0.0001;
rData=readRaw(fn_train);%   dMin=1; dUnit=1;
[A,W]=learnAW(rData,D,lambda,Ainit,Winit);
rData=readRaw(fn_test);
CMmat=testAW(A,W,rData,D);

end
