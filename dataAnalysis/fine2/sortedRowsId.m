function idx=sortedRowsId(rtm_mat,method=@sumsq)
  [~,idx]=sortrows([method(rtm_mat(:,:))',(1:size(rtm_mat,2))']);
end
