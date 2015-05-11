################

#helper:
function A=binA2pnA(Aorg, dif=5)
  A=Aorg*2-1;
  A=A.*rand(size(Aorg))*dif;
end

################
#given referenced W to get A
function [Aarr,Warr,CMarr]=whole_list_AW(fn_list,n_trial,n,D,Ainit,Wref,lambdaA,penW)
  Aarr=cell(n_trial,1);   #Adjacent (n*n)
  Warr=cell(n_trial,1);   #Weight (n*n)
  CMarr=cell(n_trial,1);  #Confusion Matrix (n*4)
  for i=1:n_trial
    rData=readRaw(cell2mat(fn_list(i)));
    %rData=pickDataByTime(rData,30000,60000);
    [A,W,CM]=trainARefW(rData,D,lambdaA,penW,Ainit,Wref);
    Aarr(i)=A;
    Warr(i)=W;
    CMarr(i)=CM;
  end
end

lambdaA=1;penW=10;
for i=1:4
  tic;[Aarr(:,i),Warr(:,i),CMarr(:,i)]=whole_list_AW(fnlist(:,i),m,n,D,binA2pnA(A),Wref,lambdaA,penW);toc;
end

save('data_rw_1.mat','D','A','Wref','lambdaA','penW','lambdaA','Aarr','Warr','CMarr')


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
  tic;[Aarr(:,i),CMarr(:,i)]=whole_list_AW(fnlist(:,i),m,n,D,binA2pnA(A),Wgiven,lambdaA);toc;
end

save('data_fw_1.mat','D','A','Wgiven','lambdaA','Aarr','CMarr')


