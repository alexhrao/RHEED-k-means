function centroids = computeCentroids(X, idx, K)
%COMPUTECENTROIDS returns the new centroids by computing the means of the
%data points assigned to each centroid.
%   centroids = COMPUTECENTROIDS(X, idx, K) returns the new centroids by
%   computing the means of the data points assigned to each centroid. It is
%   given a dataset X where each column is a single data point, a vector
%   idx of centroid assignments (i.e. each entry in range [1..K]) for each
%   example, and K, the number of centroids. It will return a matrix
%   centroids, where each column of centroids is the mean of the data points
%   assigned to it.
%
%    Inputs:
%           X = Input dataset matrix
%           idx = Vector input of centroid assignments (int)
%           K = The number of centroids
%

% Initialize values
[~, m] = size(X);   % n is the number of training examples/images
% m is the number of pixels in each image
centroids = zeros(K,m);

% Go over every cluster and compute mean of all points that belong to it.
% Concretely, the column vector centroids(:, i) should contain the mean of the
% data points assigned to cluster i.
for i = 1:K
    % find all points assigned to the cluster i
    c = idx == i;
    % calculate the mean for each pixel
    centroids(i, :) = mean(X(c,:), 1);
end


end
