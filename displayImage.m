function displayImage(colVec,row,col)
% DISPLAYIMAGE Display a 2D greyscale bitmap image
% displayImage(colVec, row, col) takes a column vector representing a
%   greyscale image and re-wraps it back into a matrix and then displays it.
%
% Inputs:
%     colVec = a 1D array of pixel intensity values
%     row = the number of row pixels in the original image
%     col = the number of column pixels in the original image
% Outputs:
%    <none>

% Reformat the column array
image = reshape(colVec, row, col);
clim = [min(colVec), max(colVec)];
scale_factor = 0.6;
if (abs(clim(2)) > abs(clim(1)))
    clim(1) = scale_factor*clim(1);
else
    clim(2) = scale_factor*clim(2);
end

imagesc(image, clim);
axis off;
colormap(jet);
colorbar;
end
