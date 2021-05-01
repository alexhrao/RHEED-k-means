function variance = calculateVariance(X_approx,X)
%CALCULATEVARIANCE Calculate the variance retained after running PCA on a dataset
%   variance = calculateVariance(X_approx, X) computes the variance retained
%              on image set X after PCA is used to compress the image set into
%              D eigenvectors.
%   Returns the variance as a double from 0-1, where 1 is equivalent to 100%
%             variance retained
%   Inputs:
%       X = the recovered matrix after projecting the data onto D eigenvectors
%       X = dataset matrix
%       dim = dimensionality of the problem, how many vectors should be output.

% Initialize
[~,m] = size(X);    % n is the number of training examples/images
% m is the number of pixels in each image

% Compute the average squared projection error
projErr = 0;
% Compute the total variation in the data
varT = 0;
for i = 1:m
    projErr = projErr + (1/m)*norm(X(:,i) - X_approx(:,i)).^2;
    varT = varT + (1/m)*norm(X(:,i)).^2;
end

% Calculate the variance retained as 1 - (average sq projection error/total
% variation in the data).
variance = 1 - (projErr/varT);

end