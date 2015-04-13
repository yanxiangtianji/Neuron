function draw_ptn(folder,prefix='',fn_list=[],suffix='',subtitle='-second')

%if length(fn_list)==1
%  fn_list=uint16((fn_list(1)-1) * rand(3));
%elseif length(fn_list)!=9
%  return
%end

close all;

for i=1:9
  idx=num2str(fn_list(i));
  subplot(3,3,i),imagesc(al2mat([folder,prefix,idx,suffix,'.txt'])),caxis([0 1]),xlabel([idx,subtitle]);
end

end


#draw_ptn('if2_trial/','cue1_',0:9,'_static','-trial')
#draw_ptn('if2_trial/','cue1_0_',0:9,'','-second')