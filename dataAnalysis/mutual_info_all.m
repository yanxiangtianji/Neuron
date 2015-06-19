% Mutual information for all columns of Data
function M = mutual_info_all(Data)
  [rows,cols] = size(Data);
  M = zeros(cols,cols);
  % Loop through each pair of columns in the alignment
  for i = 1:cols-1
    for j = i+1:cols
      % Calculate the mutual information between two specific columns
      M(i,j) = mutual_info(Data(:,i),Data(:,j));
    end
  end
  
end

