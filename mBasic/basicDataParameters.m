n_c1=54;    n_c2=52;
fn_c1=cell(n_c1,1);   fn_c2=cell(n_c2,1);
fn_r1=cell(n_c1,1);   fn_r2=cell(n_c2,1);
if(exist('fn_prefix','var')==0)
  fn_prefix='../data/real/st/';
  %fn_prefix='../data/real/st3-6/';
end
for i=1:n_c1    fn_c1(i)=[fn_prefix,'cue1_',num2str(i-1),'.txt']; end
for i=1:n_c2    fn_c2(i)=[fn_prefix,'cue2_',num2str(i-1),'.txt']; end
for i=1:n_c1    fn_r1(i)=[fn_prefix,'rest1_',num2str(i-1),'.txt'];    end
for i=1:n_c2    fn_r2(i)=[fn_prefix,'rest2_',num2str(i-1),'.txt'];    end

clear i
%clear fn_prefix

nNeu=19;
if(exist('nTri','var')==0)
  nTri=40;
  %nTri=50;
end
if(exist('nCue','var')==0)
  nCue=4;
end

cue_name={'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'};

timeUnit2ms=10;
triLength=10000*timeUnit2ms;

%type: fnlist=cell(nTri,nCue);
fnlist=makeFileList(nTri,fn_c1,fn_c2,fn_r1,fn_r2);
