function idx=sortRowID(rtm_mat,method=@sum)
  [~,idx]=sortrows([method(rtm_mat(:,:))',(1:size(rtm_mat,2))']);
end
