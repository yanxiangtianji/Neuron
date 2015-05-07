################
#given referenced W to get A
function [Aarr,Warr,CMarr]=whole_list_AW(fn_list,n_trial,n,D,Ainit,Wref,lambdaA,panW)
  Aarr=cell(n_trial,1);   #Adjacent (n*n)
  Warr=cell(n_trial,1);   #Weight (n*n)
  CMarr=cell(n_trial,1);  #Confusion Matrix (n*4)
  for i=1:n_trial
    rData=readRaw(cell2mat(fn_list(i)));
    %rData=pickDataByTime(rData,30000,60000);
    [A,W,CM]=trainARefW(rData,D,lambdaA,panW,Ainit,Wref);
    Aarr(i)=A;
    Warr(i)=W;
    CMarr(i)=CM;
  end
end

lambdaA=1;panW=10;
for i=1:4
  tic;[Aarr(:,i),Warr(:,i),CMarr(:,i)]=whole_list_AW(fnlist(:,i),m,n,D,A,W,lambdaA,panW);toc;
end

save('data_rw_1.mat','D','A','W','lambdaA','panW','lambdaA','Aarr','Warr','CMarr')


################
#given fixed W to get A
function [Aarr,CMarr]=whole_list_AW(fn_list,n_trial,n,D,Ainit,Wgiven,lambdaA)
  Aarr=cell(n_trial,1);   #Adjacent (n*n)
  CMarr=cell(n_trial,1);  #Confusion Matrix (n*4)
  for i=1:n_trial
    rData=readRaw(cell2mat(fn_list(i)));
    %rData=pickDataByTime(rData,30000,60000);
    [A,CM]=trainAFixW(rData,D,lambdaA,Ainit,Wgiven);
    Aarr(i)=A;
    CMarr(i)=CM;
  end
end

lambdaA=1;
for i=1:4
  tic;[Aarr(:,i),CMarr(:,i)]=whole_list_AW(fnlist(:,i),m,n,D,A,W,lambdaA);toc;
end

save('data_fw_1.mat','D','Ainit','W','lambdaA','Aarr','CMarr')


