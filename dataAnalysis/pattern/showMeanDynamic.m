function showMeanDynamic(rtm,rtmz,pid,rng,blRng, nPoints,tickBeg,tickEnd)
  idx=sortNID(rtmz(rng,:,pid),@sum);
  breakPoint=max(find(sum(rtmz(rng,idx,pid))<=0));
  [nBin,nNeu,~]=size(rtm);
  plot(zeros(nBin,1),'--',baselineZscore(sum(rtm(:,:,pid),2),blRng),';all;','linewidth',2,
    baselineZscore(sum(rtm(:,idx(breakPoint+1:end),pid),2),blRng),';+;',
    baselineZscore(sum(rtm(:,idx(1:breakPoint),pid),2),blRng),';-;');
  setTimeX(nPoints,tickBeg,tickEnd);grid on;legend('location','southwest')
  title('zscore of mean spike rate');xlabel('time');ylabel('zscore');
end
