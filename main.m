% main.m
% Main script for PCA/K-means analysis of RHEED .avi videos. Automates the video
% decomposition, PCA, k-means, and analysis scripts into one file.

% Load packages and clear the workspace
%pkg load image;
%pkg load video;
function main(videoPath)

%% ============================ INPUT DATA ==================================%%
%%%%% Modify the following variables before running this file %%%%%

% Note that the file must be in .avi format
% XWindowSize = 300;                         % in pixels (default = 250)
% YWindowSize = 320;                         % in pixels (default = 160)
% cropImageAtTime = 10;                      % in seconds (default = 10)

D = 5;                 % The reduced dimension of the problem after running PCA.
NUM_CLUSTERS = 5;      % The maximum number of clusters k-means will run

SAVEAS = 'sample';     % The name of the output plots when they are
% saved to the directory.
displayImages = true;  % true indicates that images should be displayed next
% to the time plot of the cluster data.
if nargin == 0
    videoPath = '';
else
    videoPath = char(videoPath);
    [path, name, ext] = fileparts(videoPath);
    if isempty(path)
        path = pwd;
    end
    videoPath = [path filesep name ext];
end
%% ==========================================================================%%

% Run the automated video frame decomposition script to crop images.

[video_directory, run, fps, innerCoords] = processVideo(videoPath);
% Determine the output directory for k-means data.
mkdir(video_directory,'k-means');
output_directory = [video_directory,'k-means\'];

% Run PCA and k-means clustering.
for d = 2:D
    kmeans(run, video_directory, output_directory, innerCoords, fps, d, NUM_CLUSTERS);
end

% Plot the PCA and k-means data
analyzeKMeans(run, output_directory, fps, SAVEAS, displayImages);
end