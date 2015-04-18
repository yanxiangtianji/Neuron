function cm=testOneAW(Avec,Wvec,X,y)

p=predictAW(Avec,Wvec,X);
cm=test(p,y);
%showCM(cm);

end