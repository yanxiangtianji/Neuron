function draw_pattern(ptn,doUni=1)

%close all;

n_row=2;
n_col=2;

m=cell2mat(ptn(1));
s=cell2mat(ptn(2));
skew=cell2mat(ptn(3));
kurtosis=cell2mat(ptn(4));

cb='auto';
if doUni
	cb_max=max(max(m+s));
	cb_min=min(min(m-s));
	cb_max=max(cb_max,abs(cb_min));
	if cb_min<0
		cb_min=-cb_max;
	else
		cb_min=0;
	end
	cb=[cb_min cb_max];
end
cb

%figure(1);
i=1;
subplot(n_row,n_col,i++);imagesc(m);caxis([-1 1]);colorbar;
subplot(n_row,n_col,i++);imagesc(s);caxis('auto');colorbar;

%subplot(n_row,n_col,i++);imagesc(m+s);caxis(cb);colorbar;
%subplot(n_row,n_col,i++);imagesc(m-s);caxis(cb);colorbar;

subplot(n_row,n_col,i++);imagesc(skew);caxis('auto');colorbar;
subplot(n_row,n_col,i++);imagesc(kurtosis);caxis('auto');colorbar;

end