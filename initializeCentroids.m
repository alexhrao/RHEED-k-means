function initial_centroids = initializeCentroids(X, K)
%INITIALIZECENTROIDS chooses random centroids
%   init_centroids = INITIALIZECENTROIDS (X, K) chooses K random examples from
%   X and returns them as a vector of K examples

[n, m] = size(X);   % n is the number of training examples/images
% m is the number of pixels in each image

initial_centroids = zeros(K, m);  % Initialize

for ind = 1:K
    % Randomly pick an example from X
    in_bounds = false;
    % Ensure that the random number is within the bounds of the X indices.
    while ~in_bounds
        rand_img = round(rand*n);
        if rand_img >= 1 && rand_img <= n
            in_bounds = true;
        end
    end
    
    initial_centroids(ind,:) = X(rand_img,:);
end

end
