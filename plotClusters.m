function plotClusters(cluster, fps, image)
% PLOTCLUSTERS
% Given a cluster structure array, plotKMeans generates a time series plot
% of the clusters
% Inputs:
%		cluster = a structure array, used in tandem with function readKMeans
%   fps = the number of frames per second in the exported video file/image
%         series.
%   image = the function can take any number of images alongside the cluster,
%           although they should be input in the correct order to match cluster
%           numbers and as a 3D image array with dimensions Jxim_heightxim_width
%           where J should correspond to the number of clusters K.

% Set up the plot window.
K = length(cluster);
colors = {[0, 0, 1], [0, 0.5, 0], [1, 0, 0], [0.75, 0, 0.75], ...
    [0, 0.75, 0.75], [0.75, 0.75, 0], [0.25, 0.25, 0.25], [0.5 0.2 0.55], ...
    [0, 1, 0.3], [0.85, 0.3, 0.1]};
outer_pad = 0.15;
inner_pad = 0.04;

if nargin > 2
    figure("position", [100 100 1200 1200]);
    numImages = size(image,1);
    rows = 2;
    columns = ceil(numImages/2) + 2;
    im_height = size(image, 2);
    im_width = size(image, 3);
    
    for i = 1:numImages
        % Set up the subplot
        left = (1/rows)*(1-rem(i,2)) + (1-rem(i,2))*inner_pad + rem(i,2)*outer_pad;
        bottom = (columns - 2 - ceil(i/2))/columns;
        width = (1/rows) - outer_pad;
        height = (1/columns) - inner_pad;
        subplot('Position', [left bottom width height]);
        
        % Display the image in the subplot
        imagesc( squeeze( image(i,:,:) ), 'CDataMapping', 'scaled' );
        axis off;
        %title(['Cluster ' num2str(i)], 'Position', [175 200]);
        text(0.05*im_width, 0.2*im_height, ['Cluster ' num2str(i)], 'Color', ...
            'white','FontSize',20);
    end
    
    % Set up subplot for K cluster plot
    %  subplot('Position', [pad (columns - 2)+(0.5*pad) (2/columms - pad) (1-2*pad)]);
    subplot(columns, rows, 1:4);
else
    figure("position", [100 100 1200 600]);
end

maxVal = 0.1;
hold on;
for i = 1:K
    % Create a vector the same size as the cluster with only values of K
    y = i*ones(size(cluster(i).times));
    % Plot the clusters as a function of time.
    plot(cluster(i).times./fps,y,'o', 'MarkerEdgeColor', colors{1}, ...
        'MarkerFaceColor', colors{1});
    
    % Determine the maximum time value to set the upper x limit
    if max(cluster(i).times) > maxVal
        maxVal = max(cluster(i).times);
    end
    
    % Circularly shift the colors over 1 index.
    colors = circshift(colors, 1);
end

set(gca,"FontSize", 16);
set(gca,"FontName", "Times New Roman");
ylim([0 K+1]);
xlim([0 maxVal/fps]);
yticks(linspace(1,K,K));
ylabel('Cluster', 'FontName', 'Times New Roman', 'FontSize', 20);
xlabel('Time (seconds)', 'FontName', 'Times New Roman', 'FontSize', 20);
title(['K Means Clustering, K = ',num2str(K)], 'FontName', ...
    'Times New Roman', 'FontSize', 20);

hold off;

