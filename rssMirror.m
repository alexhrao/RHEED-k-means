function rss = rssMirror(func)
%RSSMIRROR Compute the mean square error between a function mirrored around each
%     point in the function.
%   Outputs:
%         rss = returns an array of the residual square values for the function
%         mirrored around each point.
%   Inputs:
%         func = the function to mirror and calulate the MSE of

sz = length(func);

% Initialize the RSS array
rss = zeros(1, sz);
% Iterate through the xmarginal
for i=1:sz
    % Initialize the mirror array and define the parts of the array below and
    % above the point that is the mirror "center"
    mirror = zeros(1,sz);
    lower = flip(func(1:i));
    upper = flip(func(i + 1:end));
    if i <= length(upper)
        % if the length of upper is too large, then pad the sides of the arrays with
        % zeros.
        shift = length(upper) - i;
        mirror = [mirror zeros(1,shift)]; %#ok<AGROW>
        func2 = [zeros(1,shift) func];
        mirror(1:length(upper)) = upper;
        mirror(i + shift) = func(i);
        mirror(i + shift + 1:i + shift + length(lower)) = lower;
    elseif i >= length(lower)
        % if the length of lower is too large, then pad the sides of the arrays with
        % zeros.
        shift = i + length(lower) - sz;
        mirror = [zeros(1,shift) mirror]; %#ok<AGROW>
        func2 = [func zeros(1,shift)];
        mirror(i - length(upper):i - 1) = upper;
        mirror(i) = func(i);
        mirror(i + 1:i + length(lower)) = lower;
    else
        mirror(i - length(upper):i - 1) = upper;
        mirror(i) = func(i);
        mirror(i + 1:i + length(lower)) = lower;
        func2 = func;
    end
    % Calculate the RSS value between the original xmarginal and a curve mirrored
    % from the point.
    rss(i) = (1/sz)*sum((func2 - mirror).^2);
end

end
