function showCM(cm)

tp=cm(1);
fn=cm(2);
fp=cm(3);
tn=cm(4);

real_1=tp+fn;   real_0=fp+tn;
pred_1=tp+fp;   pred_0=fn+tn;
true=tp+tn;     false=fp+fn;
pos=tp+fp;      neg=fn+tn;
total=pos+neg;

disp("Confusion Matrix:");
disp("\tR=1\tR=0\tTotal");
disp(sprintf("P=1\t%d\t%d\t%d",tp,fp,pred_1));
disp(sprintf("P=0\t%d\t%d\t%d",fn,tn,pred_0));
disp(sprintf("Total\t%d\t%d\t%d",real_1,real_0,total));

acc=true/total;
if(pred_1!=0)   prec=tp/pred_1;
else    prec=0;
end
if(real_1!=0)   rec=tp/real_1;
else    rec=0;
end
if(tp+neg!=0)   f1=2*tp/(2*tp+false);
else    f1=0;
end
disp(sprintf("Accurancy=%f",acc));
disp(sprintf("Precision=%f",prec));
disp(sprintf("Recall=%f",rec));
disp(sprintf("F1 score=%f",f1));

end
