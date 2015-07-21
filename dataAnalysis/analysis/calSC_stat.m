function [sc_mean,sc_std,sc_skew,sc_kurtosis]=calSC_stat(rDataList,winSize,resLength=0)
  [nTri,nNeu,nCue]=size(rDataList);
  if(resLength<=0) resLength=ceil(findMaxTime(rDataList)/winSize); end;
  sc1=zeros(resLength,nNeu,nCue); sc2=zeros(resLength,nNeu,nCue);
  sc3=zeros(resLength,nNeu,nCue); sc4=zeros(resLength,nNeu,nCue);
  for cid=1:nCue;
    for nid=1:nNeu;
      for tid=1:nTri;
        t=discretize(rDataList(tid,nid,cid),winSize,0,resLength,'count');
        sc1(:,nid,cid)+=t; sc2(:,nid,cid)+=t.^2;
        sc3(:,nid,cid)+=t.^3; sc4(:,nid,cid)+=t.^4;
      end;
    end;
  end
  sc1/=nTri; sc2/=nTri; sc3/=nTri; sc4/=nTri;
  sc_mean=sc1;
  sc_std=sqrt(sc2-sc1.^2);
  sc_skew=(sc3-3*sc1.*sc_std.^2-sc1.^3)./sc_std.^3;
  sc_kurtosis=(sc4-4*sc3.*sc1+6*sc2.*sc1.^2-3*sc1.^4)./sc_std.^4;
end
