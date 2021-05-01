function [U, S] = pca(X,dim)
%PCA Run principal component analysis on the dataset X
%   [U, S, X] = pca(X) computes eigenvectors of the covariance matrix of X
%   Returns the eigenvectors U, the eigenvalues (on diagonal) in S
%   Inputs:
%       X = dataset matrix
%       dim = dimensionality of the problem, how many vectors should be output.

% Initialize
[n,~] = size(X);    % n is the number of training examples/images
% m is the number of pixels in each image
%U = zeros(m);
%S = zeros(m);

% Compute the covariance matrix
Sigma = 1/n * (X' * X);
% Use singular value decomposition to compute eigenvectors and eigenvalues.
opts = struct('tol',1.E-8,'maxit',300,'gvk',10,'idisp',0);
[U, S, ~] = lmsvd(Sigma,dim,opts);

end