function [X_norm, mu, sigma] = featureNormalize(X)
%FEATURENORMALIZE Normalizes the features in X
%   FEATURENORMALIZE(X) returns a normalized version of X where
%   the mean value of each feature is 0 and the standard deviation
%   is 1.

% Subtract the mean of each pixel/feature from each column
mu = mean(X);
X_norm = bsxfun(@minus, X, mu);

% Instead of using the standard deviation, just divide each feature by 255
sigma = 255;

X_norm = bsxfun(@rdivide, X_norm, sigma);


% ============================================================

end