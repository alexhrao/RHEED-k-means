function [X_trim,ind_zero_col] = trimData(X)
%TRIMDATA cuts out columns of data in which all of the pixels are zero.
%   X_trim = TRIMDATA(X) removes columns in a data matrix that are all zeros.
%   Inputs:
%       X = data matrix
%   Outputs:
%       X_trim = trimmed data matrix with no columns of zeros
%       ind_zero_col = a row array of the indices of the columns that have been
%                      removed, necessary for repadding later.

% If all of the pixels are 0 in the same spot for an image, trim off that column
col_all_zeros = ~any(X);
ind_zero_col = find(col_all_zeros);
X_trim = X;
X_trim(:,ind_zero_col) = [];

end