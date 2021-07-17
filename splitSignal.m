%% splitSignal: Split a signal into periods
%
% P = splitSignal('Time', T, 'Values', X will split signal with time vector T and value
% vector X into periods P. Each period in P is a structure with fields tt
% for time and xx for value. A default window of 4 seconds is used,
% defaulting to 30 FPS
%
% P = splitSignal('Video', V) will read the video file in path V, and
% calculate the average peak values (i.e., T, X) to then chunk the signal
% accordingly. P will have all the fields of before, but will also have a
% field ff, the frames associated with a given period. If the inner/outer
% coordinates are not given (see options), then a text file will be looked
% for in the directory; if that is not found, an error is thrown.
%
% P = splitSignal(___, 'Name', Value) will also process optional arguments:
%
% * 'Window': The window to use; defaults to 6 seconds at 30 frames per
% second (so 180)
% * 'InnerCoords': The inner coordinates to use
% * 'OuterCoords': The outer coordinates to use
%
function periods = splitSignal(options)
arguments
    options.Time double = [];
    options.Values double = [];
    options.Video char = '';
    options.Window double = 6*30;
    options.InnerCoords double = [];
    options.OuterCoords double = [];
end
if isempty(options.Time) && isempty(options.Video)
    error('Must provide data');
end
if ~isempty(options.Video)
    reader = VideoReader(options.Video);
    [fpath, vname, ~] = fileparts(options.Video);
    coordPath = [fpath, filesep, vname, filesep ,vname,'_coords.txt'];
    if ~isempty(options.InnerCoords) && ~isempty(options.OuterCoords)
        x1 = options.OuterCoords(1);
        x2 = options.OuterCoords(2);
        y1 = options.OuterCoords(3);
        y2 = options.OuterCoords(4);
        cx1 = options.InnerCoords(1);
        cx2 = options.InnerCoords(2);
        cy1 = options.InnerCoords(3);
        cy2 = options.InnerCoords(4);
    elseif isfile(coordPath)
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
        error('Cannot process video without framing information');
    end
    tt = linspace(0, reader.NumFrames / reader.FrameRate, reader.NumFrames);
    frame = reader.readFrame();
    frames = zeros(length(y1:y2), length(x1:x2), 1, reader.NumFrames, 'like', frame);
    peaks = zeros(length(cy1:cy2), length(cx1:cx2), 1, reader.NumFrames, 'like', frame);
    reader = VideoReader(options.Video);
    for f = 1:reader.NumFrames
        image = reader.readFrame();
        if size(image, 3) == 3
            bwimage = rgb2gray(image);
        else
            bwimage = image;
        end
        % Crop the image based on the parameters determined from the first frame.
        frames(:, :, :, f) = bwimage(y1:y2,x1:x2);
        % Crop inner coords
        peaks(:, :, :, f) = frames(cy1:cy2, cx1:cx2, :, f);
    end
    xx = mean(peaks, 1:3);
    xx = xx(:);
else
    tt = options.Time;
    xx = options.Values;
end
    
window = options.Window;
% start at beginning; look for lowest within 4 seconds
% from there, continue looking for next lowest within 4 seconds
curr = 1;
periods = [];
while curr <= length(tt)
    % look for lowest w/i window
    windowMask = curr:min(curr + window, length(tt));
    % find trough
    [~, ind] = min(xx(windowMask));
    periods(end+1).tt = tt(curr:curr+ind-1);
    periods(end).xx = xx(curr:curr+ind-1);
    if ~isempty(options.Video)
        periods(end).ff = frames(:, :, :, curr:curr+ind-1);
    end
    curr = curr + ind + 1;
end
end