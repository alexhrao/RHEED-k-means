function [fpath,vname,fps,innerCoords] = processVideo(videoPath)
% PROCESSVIDEO
% Process a video into a series of bitmap images, saved in the same directory
% as the video file.

% Inputs:

%

%% ============================= LOAD VIDEO =============================== %%
% Load the video

fprintf('\nSelect a video to process.\n');
if isempty(videoPath)
    [fname, fpath, ~] = uigetfile('*.avi', 'Select a video to process.');
else
    [fpath, fname, ext] = fileparts(videoPath);
    fname = [fname ext];
    fpath = [fpath filesep];
end
% Get video parameters
[~, vname, ~] = fileparts([fpath fname]);
info = VideoReader([fpath filesep fname]);
numFrames = info.NumFrames;
num_digits = numel(num2str(numFrames));
str_format = ['%0' num2str(num_digits) '.f'];
fps = info.FrameRate;

% Process the first image to set a window for all subsequent images
%cropImageAtTime = cropImageAtTime*fps;
% Multiply seconds by fps to get frame number

% get "average" image over first 200 frames (or until end, either way)
if numFrames > 200
    imgs = info.read([1 200]);
else
    imgs = info.read([1 inf]);
end
image = uint8(mean(imgs, 4));
image = imrotate(image, -24.5, 'nearest', 'crop');
info = VideoReader([fpath fname]);
if size(image, 3) == 3
    bwimage = rgb2gray(image);
else
    bwimage = image;
end
mkdir(fpath, vname);
coordPath = [fpath,vname,'/',vname,'_coords.txt'];

if isfile(coordPath)
    lines = str2double(splitlines(fileread(coordPath)));
    x1 = lines(1);
    x2 = lines(2);
    y1 = lines(3);
    y2 = lines(4);
    cx1 = lines(5);
    cx2 = lines(6);
    cy1 = lines(7);
    cy2 = lines(8);
else
    fig = figure('Name', 'Select the RHEED Area');
    imshow(bwimage);
    rect = drawrectangle('Rotatable', false);
    while isempty(rect.Position)
        close(fig);
        fig = figure('Name', 'Select the RHEED Area');
        imshow(bwimage);
        rect = drawrectangle('Rotatable', false);
    end
    x1 = ceil(rect.Position(1));
    y1 = ceil(rect.Position(2));
    x2 = floor(rect.Position(1) + rect.Position(3));
    y2 = floor(rect.Position(2) + rect.Position(4));
    close(fig);
    peakImg = bwimage(y1:y2,x1:x2);
    fig = figure('Name', 'Select the Central Peak');
    imshow(peakImg);
    rect = drawrectangle('Rotatable', false);
    while isempty(rect.Position)
        close(fig);
        fig = figure('Name', 'Select the Central Peak');
        imshow(peakImg);
        rect = drawrectangle('Rotatable', false);
    end
    cx1 = ceil(rect.Position(1));
    cy1 = ceil(rect.Position(2));
    cx2 = floor(rect.Position(1) + rect.Position(3));
    cy2 = floor(rect.Position(2) + rect.Position(4));
    close(fig);
    fid = fopen(coordPath, 'wt');
    fprintf(fid, '%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d', x1, x2, y1, y2, cx1, cx2, cy1, cy2);
    fclose(fid);
end
innerCoords = [cx1 cx2 cy1 cy2];
% Get the boundaries of the image to crop. Ignore the last 20 pixels as that is
% the scroll window and not part of the RHEED screen.
%[x1, x2, y1, y2] = getWindow(bwimage, XWindowSize, YWindowSize);
% Crop the image
tic;
%img = bwimage(y1:y2,x1:x2);
%[im_height,im_width] = size(img);
return
% Make a new directory for the processed images named after the filename and
% save the image to the directory
mkdir(fpath, vname);

% Repeat the process for the other frames.=
p = gcp('nocreate');
if ~isempty(p)
    chunkSize = ceil(numFrames / p.NumWorkers);
    vPath = [fpath fname];
    ts = tic;
    parfor w = 1:p.NumWorkers
        vr = VideoReader(vPath); %#ok<TNMLP>
        startInd = (w - 1)*chunkSize + 1;
        stopInd = min(startInd + chunkSize, numFrames);
        if startInd <= stopInd
            frames = vr.read([startInd stopInd]);
            for i = 1:size(frames, 4)
                image = frames(:, :, :, i);
                image = imrotate(image, -24.5, 'nearest', 'crop');
                if size(image, 3) == 3
                    bwimage = rgb2gray(image);
                else
                    bwimage = image;
                end
                % Crop the image based on the parameters determined from the first frame.
                img = bwimage(y1:y2,x1:x2);
                % Save the image to file as a bitmap
                imwrite(img, [fpath,vname,'/',vname,'_',num2str(startInd - 1 + i,str_format),'.bmp']);
            end
        end
    end
    toc(ts)
else
    ts = tic;
    for i = 1:numFrames
        image = info.readFrame;
        %image = imrotate(image, -24.5, 'nearest', 'crop');
        if size(image, 3) == 3
            bwimage = rgb2gray(image);
        else
            bwimage = image;
        end
        % Crop the image based on the parameters determined from the first frame.
        img = bwimage(y1:y2,x1:x2);
        % Save the image to file as a bitmap
        imwrite(img, [fpath,'/',vname,'_',num2str(i,str_format),'.bmp']);
    end
    toc(ts)
end
toc;
fprintf('Video conversion complete. \n');
end