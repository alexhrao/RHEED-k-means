function X_approx = featureDenormalize(X_norm, mu, sigma)
%FEATUREDENORMALIZE De-normalizes the features in X_norm
%   FEATURENORMALIZE(X_norm, mu, sigma) returns a version of X where the
%     features have been un-normalized.

X_approx = bsxfun(@times, X_norm, sigma);
X_approx = bsxfun(@plus, X_approx, mu);


% ============================================================

end