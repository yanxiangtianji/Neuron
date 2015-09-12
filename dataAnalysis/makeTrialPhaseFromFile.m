function res=makeTrialPhaseFromFile(fn_h,fn_e, ...
  cueIDs,trialRng,timeOffBeg,timeOffEnd,entPhase,offsetS2E=0)

%nCue=length(cueIDs);
%nTri=size(trialRng,1);

%trialInfo=zeros(nTri,2,nCue);
trialInfo=genTrialInfo(readCue(fn_h),cueIDs,trialRng,false);
trialInfo(:,1,:)+=timeOffBeg; trialInfo(:,2,:)+=timeOffEnd;
event=readEvent(fn_e);

%res=zeros(nTri,nCue,nRat);
res=makeTrialPhase(trialInfo,event,entPhase,offsetS2E);


end
