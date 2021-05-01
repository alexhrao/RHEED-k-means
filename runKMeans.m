function [centroids, idx, cost] = runKMeans(X, initial_centroids, ...
                                      max_iters)
%RUNKMEANS runs the K-Means algorithm on data matrix X, where each row of X
%is a single example
%   [centroids, idx] = RUNKMEANS(X, initial_centroids, max_iters, ...
%   plot_progress) runs the K-Means algorithm on data matrix X, where each 
%   row of X is a single example. It uses initial_centroids used as the
%   initial centroids. max_iters specifies the total number of interactions 
%   of K-Means to execute. runkMeans returns centroids, a mxK matrix of the 
%   computed centroids and idx, a m x 1 vector of centroid assignments 
%   (i.e. each entry in range [1..K])

% Initialize values
[n, ~] = size(X);   % n is the number of training examples/images
                    % m is the number of pixels in each image
K = size(initial_centroids, 1);
centroids = initial_centroids;
%previous_centroids = centroids;
idx = zeros(1,n);

% Run K-Means
for i=1:max_iters
    
    % Output progress
%    fprintf('K-Means iteration %d/%d...\n', i, max_iters);
%    if exist('OCTAVE_VERSION')
%        fflush(stdout);
%    end
    
    % For each example in X, assign it to the closest centroid
    idx = findClosestCentroids(X, centroids);
    
    % Assign the old centroids to a variable to check is the centroid membership
    % is changing over time.
    previous_centroids = centroids;
    
    % Given the memberships, compute new centroids
    centroids = computeCentroids(X, idx, K);
    
    if previous_centroids == centroids
      break;
    end
    
end

% Calculate the cost of this KMeans run.
cost = 0;
for i=1:n
  cost = cost + (norm( X(i,:) - centroids(idx(i),:) ))^2;
end
cost = cost/n;

end