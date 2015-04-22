function CMmat=trainTestAW(fn_train,fn_test,D,lambdaA=0,lambdaW=0,Ainit=0,Winit=0)

%rData=readRawSpike(fn_spike);%   dMin=0.0001;    dUnit=0.0001;
rData=readRaw(fn_train);%   dMin=1; dUnit=1;
[A,W]=trainAW(rData,D,lambdaA,lambdaW,Ainit,Winit);
rData=readRaw(fn_test);
CMmat=testAW(A,W,rData,D);

end
