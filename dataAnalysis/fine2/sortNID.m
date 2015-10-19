function idx=sortNID(rtm_mat,method=@sum)
  [~,idx]=sort(method(rtm_mat));
end
