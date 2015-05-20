n_c1=54;    n_c2=52;
fn_c1=cell(n_c1,1);   fn_c2=cell(n_c2,1);
fn_r1=cell(n_c1,1);   fn_r2=cell(n_c2,1);
fn_prefix='../data/real/st/';   %fn_prefix='../data/real/st3-6/';
for i=1:n_c1    fn_c1(i)=[fn_prefix,'cue1_',num2str(i-1),'.txt']; end
for i=1:n_c2    fn_c2(i)=[fn_prefix,'cue2_',num2str(i-1),'.txt']; end
for i=1:n_c1    fn_r1(i)=[fn_prefix,'rest1_',num2str(i-1),'.txt'];    end
for i=1:n_c2    fn_r2(i)=[fn_prefix,'rest2_',num2str(i-1),'.txt'];    end

n=19;
m=40;

fnlist=cell(m,4);
fnlist(:,1)=fn_c1(1:m);fnlist(:,2)=fn_c2(1:m);fnlist(:,3)=fn_r1(1:m);fnlist(:,4)=fn_r2(1:m);
cue_name={'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'};


%dMin=0.0001;    dUnit=0.0001;  %for readRawSpike
%dMin=1; dUnit=1;    %readRaw
%[D,Ainit,Winit]=init(n,dMin,dUnit);

lambdaA=1;
lambdaW=1;
vanishTime95=2000;   %it takes 200ms(time unit in data file is 0.1ms) to degrade 95%.
fRep=-log(0.05)/vanishTime95;
