function [fnlSpike,fnlBeh,fnlEvn]=makeFileListOfFolder(pre)
  fnls=dir([pre,'/*-spike.txt']);
  fnlb=dir([pre,'/*-beh.txt']);
  fnle=dir([pre,'/*-event.txt']);
  nFile=length(fnls);
  fnlSpike=cell(nFile,1);fnlBeh=cell(nFile,1);
  for i=1:nFile;
    fnlSpike(i)=[pre,'/',fnls(i).name];
    fnlBeh(i)=[pre,'/',fnlb(i).name];
  end;
  nFile=length(fnle);
  fnlEvn=cell(nFile,1);
  for i=1:nFile;
    fnlEvn(i)=[pre,'/',fnle(i).name];
  end
end
