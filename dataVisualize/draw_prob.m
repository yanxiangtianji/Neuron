function draw_prob(folder)

close all;

p1=load([folder,'/', 'cue1_prob.txt']);
figure(1);imagesc(p1);caxis([0,1]);colormap(jet);colorbar;
saveas(gcf,[folder,'/',  'cue1_prob.png'])

p2=load([folder,'/', 'cue2_prob.txt']);
figure(2);imagesc(p2);caxis([0,1]);colormap(jet);colorbar;
saveas(gcf,[folder,'/', 'cue2_prob.png'])

end
