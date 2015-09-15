function trialPhase=makeTrialPhaseFromFiles(fnlb,fnle,fmap,entPhase,nTri,mthd4initEvent='offset')

nRat=length(fnlb);
[nCue,nPha]=size(entPhase);
trialPhase=zeros(nTri,nCue,nRat);%value is the number of phase in [0,nPha-1]
for i=1:nRat;
  trialPhase(:,:,i)=makeTrialPhaseFromFile( ...
    fnlb(i),fnle(fmap(i)),1:nCue,1:nTri,0,0,entPhase,mthd4initEvent);
end

end
