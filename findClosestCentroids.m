function idx = findClosestCentroids(X, centroids)
%FINDCLOSESTCENTROIDS computes the centroid memberships for every example
%   idx = FINDCLOSESTCENTROIDS (X, centroids) returns the closest centroids
%   in idx for a dataset X where each row is a single example. idx = m x 1
%   vector of centroid assignments (i.e. each entry in range [1..K])
%

% Set K

% Initialize
[n, ~] = size(X);   % n is the number of training examples/images
% m is the number of pixels in each image
idx = zeros(n,1);


for i = 1:n
    % Find the closest centroid to the example by taking the Euclidian norm
    % Ignore the square root since it's just finding the minimum anyway
    dist = sum( (X(i, :) - centroids).^2, 2 );
    [~, idx(i)] = min(dist);
end

end
