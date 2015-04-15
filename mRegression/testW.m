function cm=testW(Wvec,X,y)

p=predictW(Wvec,X);
cm=test(p,y);
showCM(cm);

end