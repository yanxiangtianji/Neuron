function draw_sb_neuron(ob,do_abs=false,uni_cb=false,drawOrg=true,drawDC=false,threshold=0)

close all;
if ~drawOrg && ~drawDC
	return
end
total=size(ob,1)*size(ob,2);
n_row=3;
n_col=3;
n_per_page=n_row*n_col;
n_page=ceil(total/n_per_page);
%n=floor(sqrt(total));
%total=n*n;

cb_o='auto';
cb_d='auto';

if uni_cb
	cmax_o=0; cmin_o=0;
	cmax_d=0; cmin_d=0;
	if drawDC
		d=zeros(size(cell2mat(ob(1)),1),size(cell2mat(ob(1)),2),total);
	end
	for i=1:total
		t=cell2mat(ob(i));
		if drawOrg
			cmax_o=max(cmax_o,max(max(t)));
			cmin_o=min(cmin_o,min(min(t)));
		end
		if drawDC
			d(:,:,i)=myND_regulatory(t);
			cmax_d=max(cmax_d,max(max(d(:,:,i))));
			cmin_d=min(cmin_d,min(min(d(:,:,i))));
		end
	end
	cb_o=[cmin_o cmax_o];
	cb_d=[cmin_d cmax_d];
	if threshold~=0
		cb_o=round(cb_o./threshold)*threshold;
		cb_d=round(cb_d./threshold)*threshold;
	end
end
cb_o=[0 1]
cb_d

if drawOrg
	left=total;
	for p=1:n_page
		name=sprintf("%s - %d",'observed network',p);
		figure('name',name);
		for i=1:min(left,n_per_page)
			mat_i=i+(p-1)*n_per_page;
			mat=cell2mat(ob(mat_i));
			if do_abs
				mat=abs(mat);
			end
			%process the diagnoal
			for l=1:length(mat)	mat(l,l)=0;	end
			if threshold!=0
				mat=round(mat./threshold)*threshold;
			end
			%subplot(n_row,n_col,i);imagesc(mat);caxis(cb_o);colormap(hot);colorbar;
			%subplot(n_row,n_col,i);imagesc(mat);caxis(cb_o);colormap(gray);colorbar;
			subplot(n_row,n_col,i);imagesc(mat);caxis(cb_o);colorbar;
		end
		left-=n_per_page;
	end
end
if drawDC
	left=total;
	for p=1:n_page
		name=sprintf("%s - %d",'direct network',p);
		figure('name',name);
		for i=1:min(left,n_per_page)
			mat_i=i+(p-1)*n_per_page;
			if uni_cb	%d(:,:,i) is precomputed for cb_d
				mat=d(:,:,mat_i);
			else
				mat=myND_regulatory(cell2mat(ob(mat_i)));
			end
			if threshold!=0
				mat=round(mat./threshold)*threshold;
			end
			subplot(n_row,n_col,i);imagesc(mat);caxis(cb_d);colorbar;
		end
		left-=n_per_page;
	end
end


end