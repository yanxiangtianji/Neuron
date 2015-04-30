n1=load('1.txt'); o1=zeros(1,length(n1))+0.1;
n2=load('2.txt'); o2=zeros(2,length(n2))+0.2;
n3=load('3.txt'); o3=zeros(3,length(n3))+0.3;
n4=load('4.txt'); o4=zeros(4,length(n4))+0.4;
n5=load('5.txt'); o5=zeros(5,length(n5))+0.5;
n6=load('6.txt'); o6=zeros(6,length(n6))+0.6;
n7=load('7.txt'); o7=zeros(7,length(n7))+0.7;
n8=load('8.txt'); o8=zeros(8,length(n8))+0.8;
n9=load('9.txt'); o9=zeros(9,length(n9))+0.9;
n10=load('10.txt'); o10=zeros(1,length(n10))+1.0;
n11=load('11.txt'); o11=zeros(1,length(n11))+1.1;
n12=load('12.txt'); o12=zeros(2,length(n12))+1.2;
n13=load('13.txt'); o13=zeros(3,length(n13))+1.3;
n14=load('14.txt'); o14=zeros(4,length(n14))+1.4;
n15=load('15.txt'); o15=zeros(5,length(n15))+1.5;
n16=load('16.txt'); o16=zeros(6,length(n16))+1.6;
n17=load('17.txt'); o17=zeros(7,length(n17))+1.7;
n18=load('18.txt'); o18=zeros(8,length(n18))+1.8;
n19=load('19.txt'); o19=zeros(9,length(n19))+1.9;

hold on
plot(n1,o1,'+')
plot(n2,o2,'+')
plot(n3,o3,'+')
plot(n4,o4,'+')
plot(n5,o5,'+')
plot(n6,o6,'+')
plot(n7,o7,'+')
plot(n8,o8,'+')
plot(n9,o9,'+')
plot(n10,o10,'+')
plot(n11,o11,'+')
plot(n12,o12,'+')
plot(n13,o13,'+')
plot(n14,o14,'+')
plot(n15,o15,'+')
plot(n16,o16,'+')
plot(n17,o17,'+')
plot(n18,o18,'+')
plot(n19,o19,'+')
axis([1000,1100,0,2])
hold off