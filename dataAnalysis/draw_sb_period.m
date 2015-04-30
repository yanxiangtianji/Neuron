function draw_sb_period(mat,doABS=false,drawOrg=false,drawRemoved=true)

close all;
total=size(mat,1)*size(mat,2);
n_row=3;
n_col=3;
n_per_page=n_row*n_col;
n_page=ceil(total/n_per_page);

% n=size(mat,1);
% idx=(sum(mat)!=0)(:) & (sum(mat,2)!=0)(:);
% mat2=mat(idx,idx);

% figure(1)
% imagesc(mat);colorbar;
% figure(2)
% imagesc(mat2);colorbar;

%org
if drawOrg
	left=total;
	for p=1:n_page
		name=sprintf("complete - %d",p);
		figure('name',name);
		for i=1:min(left,n_per_page)
			m_i=i+(p-1)*n_per_page;
			m=cell2mat(mat(m_i));
			if doABS
				m=abs(m);
			end
			subplot(n_row,n_col,i);imagesc(m);colorbar;
		end
		left-=n_per_page;
	end
end
%adjust (remove 0 & move significant ones to up left)
if drawRemoved
	left=total;
	for p=1:n_page
		name=sprintf("cleared - %d",p);
		figure('name',name);
		for i=1:min(left,n_per_page)
			m_i=i+(p-1)*n_per_page;
			m=cell2mat(mat(m_i));
			if doABS
				m=abs(m);
			end
			m=adjust(m);
			subplot(n_row,n_col,i);imagesc(m);caxis([0,1]);colorbar;
		end
		left-=n_per_page;
	end
end

end

function res=adjust(mat)
%both move_largest and remove_zero
	[s,idx]=sort(sum(mat),'descend');
	idx=idx(find(s>0));
	res=mat(idx,idx);
end

function res=remove_zero(mat)
	idx=(sum(mat)!=0)(:) & (sum(mat,2)!=0)(:);
	res=mat(idx,idx);
end

function res=move_largest(mat)
	res=mat(idx,idx);
end
