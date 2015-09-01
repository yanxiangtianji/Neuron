function [fnlSpike,fnlBeh]=makeFileListOfFolder(pre)
  fnls=dir([pre,'/*-spike.txt']);
  fnlb=dir([pre,'/*-beh.txt']);
  nFile=length(fnls);
  fnlSpike=cell(nFile,1);fnlBeh=cell(nFile,1);
  for i=1:nFile;
    fnlSpike(i)=[pre,'/',fnls(i).name];
    fnlBeh(i)=[pre,'/',fnlb(i).name];
  end;
  
end
