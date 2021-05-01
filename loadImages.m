function [X, im_height, im_width, num_bmp_files, num_files, idxbmp, files, peaks] ...
    = loadImages(directory, innerCoords)
% LOADIMAGES
% Load a directory of images into a data matrix, X, in which the number of
% columns represents the flattened pixels in each images and the rows represent
% each frame in the sequence.
%
% Inputs:
%   directory = The directory in which the images are stored. (string)
%
% Outputs:
%   X = The image matrix, size (num_frames x number of pixels)
%   im_height = The height in pixels of each image in the sequence (int)
%   im_width = The width in pixels of each image in the sequence (int)
%   num_bmp_files = The number of frames in the sequence (int)
%   num_files = The number of files in the directory (int)
%   idxbmp = The index values of the bitmap files in the files vector
%   files = A string vector of the files in the directory
%   peaks = A matrix of peak values, height x width x 1 x num_frames

%% ============================= LOAD IMAGES =============================== %%
% Load the images in a single matrix X.
% Only load greyscale bitmap files - tifs are too large.

% Load the entire directory of processed images into the X data matrix
files = dir(directory);
files([files.isdir]) = [];
num_files = length(files);

% idx is a logical array which reads true for bitmap files in the directory
file_idx = cell2mat( cellfun(@(x) endsWith(lower(x),'.bmp'), {files.name}, ...
    'UniformOutput', false) );
% idxbmp contains the index values of bitmap files in 'files'
idxbmp = find(file_idx);
num_bmp_files = length(idxbmp);

% Read the first image from the directory into Octave
img = imread([directory files(idxbmp(1)).name]);

% Initialize the X data matrix
[im_height,im_width] = size(img);

X = zeros(num_bmp_files,im_width*im_height);
peak = img(innerCoords(3):innerCoords(4), innerCoords(1):innerCoords(2), 1);
peaks = zeros(size(peak, 1), size(peak , 2), 1, num_bmp_files, 'uint8');
% Save some time, go ahead and store the first image.
X(1,:) = img(:);
peaks(:, :, :, 1) = peak;
for i = 2:num_bmp_files
    % Read each processed image in and store it in X
    img = imread([directory files(idxbmp(i)).name]);
    % extract central peak
    peaks(:, :, :, i) = img(innerCoords(3):innerCoords(4), innerCoords(1):innerCoords(2), 1);
    X(i,:) = img(:);
end
end
