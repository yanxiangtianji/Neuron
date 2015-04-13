function testW(W,X,y)

p=predictW(W,X);
cm=test(p,y);
showCM(cm);

end