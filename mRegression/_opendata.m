

prefix='../data/real/crcns/';
suffixData='_data.txt';
suffixIdx='_idx.mat';

data=readRaw([prefix,'pvc3_1',suffixData]);
timeUint2ms=100;  %10us
data=readRaw([prefix,'pvc3_2',suffixData]);
timeUint2ms=100;  %10us
data=readRaw([prefix,'mt1',suffixData]);
timeUint2ms=1; %1ms

n=length(data);
dMean=0.1*timeUint2ms*(2.5-1)/(2.5-2);%mean value of power-law distribution(alpha=2.5, Xmin=1)
[D,Ainit,Winit]=init(n,1,dMean,0);
vanishTime95=200*timeUint2ms;   %it takes 200ms(time unit in data file is 0.1ms) to degrade 95%.
fRep=-log(0.05)/vanishTime95;

lambdaA=1;
lambdaW=1;

[A,W,CM]=trainAW(data,D,lambdaA,lambdaW,fRep,Ainit,Winit);
save('data_pvc3_1.mat','D','Ainit','Winit','A','W','CM')

