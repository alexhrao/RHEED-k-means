%% RHEED Runner
NUM_CLUSTER = 5;
VID_DIR = 'F:\RHEED Videos\';

vidDirs = dir(VID_DIR);
vidDirs(1:2) = [];
vidDirsInfo = vidDirs([vidDirs.isdir]);
vidDirs = fullfile({vidDirsInfo.folder}, {vidDirsInfo.name});
wState = warning('off');
vidDirs(1) = [];
for d = 1:length(vidDirs)
    vidsInfo = dir(vidDirs{d});
    vidsInfo(~endsWith({vidsInfo.name}, '.avi', 'IgnoreCase', true)) = [];
    vids = fullfile({vidsInfo.folder}, {vidsInfo.name});
    for v = 1:length(vids)
        close all
        fprintf(1, 'Analyzing Video %s...', vidsInfo(v).name);
        try
            [~, vName, ~] = fileparts(vidsInfo(v).name);
            dst = fullfile('data', [vidDirsInfo(d).name '_' vName]);
            mkdir(dst);
            diary(fullfile('data', [vidDirsInfo(d).name '_' vName], 'diary.txt'));
            diary on;
            main(vids{v});
            copyfile(fullfile(vidDirs{d}, 'k-means', vName, '*.jpeg'), dst);
            copyfile(fullfile(vidDirs{d}, 'k-means', vName, '*.jpg'), dst);
            copyfile(fullfile(vidDirs{d}, 'k-means', vName, '*.fig'), dst);
            copyfile(fullfile(vidDirs{d}, 'k-means', vName, '*.xlsx'), dst);
            for k = 1:NUM_CLUSTER
                kDst = fullfile('data', [vidDirsInfo(d).name '_' vName], sprintf('k%d', k));
                mkdir(kDst);
                copyfile(fullfile(vidDirs{d}, 'k-means', vName, sprintf('k%d', k)), kDst);
            end
            fprintf(1, 'Done!\n');
        catch
            fprintf(2, 'Failed!\n');
        end
        diary off;
        clc;
    end
end
warning(wState);