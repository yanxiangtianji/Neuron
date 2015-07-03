#file parameters:
addpath('../mBasic/')
basicDataParameters();

#training parameters:

%dMin=0.0001;    dUnit=0.0001;  %for readRawSpike
%dMin=1; dUnit=1;    %readRaw
%[D,Ainit,Winit]=init(nNeu,dMin,dUnit);

lambdaA=1;
lambdaW=1;
vanishTime95=200*timeUnit2ms;   %it takes 200ms(time unit in data file is 0.1ms) to degrade 95%.
fRep=-log(0.05)/vanishTime95;
