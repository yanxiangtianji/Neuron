function CMmat=trainTestW(fn_train,fn_test,D,lambda=0,Winit=0)

%rData=readRawSpike(fn_spike);%   dMin=0.0001;    dUnit=0.0001;
rData=readRaw(fn_train);%   dMin=1; dUnit=1;
[W]=learnW(rData,D,lambda,Winit);
rData=readRaw(fn_test);
CMmat=testW(W,rData,D);

end
