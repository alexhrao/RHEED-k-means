function kmeans(run, directory, write_dir, innerCoords, fps, D, NUM_CLUSTERS)
% KMEANS
% Runs a full k-means algorithm several times over the input run.
% All video files must have been decomposed into .bmp files in the same directory
% as the input video, using the processVideo function.
%
% Inputs:
%   run = The growth number and folder name in the main directory (string)
%   directory = The read directory containing the video and image files (string)
%   write_dir = The output directory for the data (string)
%   fps = The number of frames per second of the exported .avi video
%         (int, default = 2)
%   D = The reduced dimension of the problem after running PCA
%       (int, default = 5)
%   NUM_CLUSTERS = The maximum number of clusters k-means will run
%                 (int, default=5)
%

% Start timer
tic;

%% ============================= LOAD DATA =============================== %%
if nargin < 5
    fps = 2;
    D = 5;
    NUM_CLUSTERS = 5;
elseif nargin < 6
    D = 5;
    NUM_CLUSTERS = 5;
elseif nargin < 7
    NUM_CLUSTERS = 5;
end
% Load the data into memory.
% Concatendate the main and image directories
directory = [directory run '\'];
% Create a new directory for the output data
[~, ~] = mkdir(write_dir,run);
% Add the new folder into the write directory path.
write_dir = [write_dir, run, '\'];

fprintf('\nLoading Processed Images.\n');
% Load the processed STO-STO images into variable X. X is a matrix of the
% unrolled bitmap images, so that each row contains each pixel of an individual
% bitmap image.
% Also load the following
% variables:
% im_height, im_width  = the height and width of the processed images.
% num_bmp_files = the number of bmp files in the directory
% num_files = the total number of files found in the directory
% idx_bmp = an array that gives the index of each bmp file in the file array
% files = a string array with each filename in the directory.
tStart = tic;
try
    [X, im_height, im_width, num_bmp_files, ~, idxbmp, files, peaks] = ...
        loadImages(directory, innerCoords);
catch
    fprintf('Error loading images, check the folder name and path.\n');
    return;
end
% calculate average intensity over time
ag = mean(peaks, 1:3);
% Trim X so that the algorithm is not run over blank pixels (zero intensity)
[X, ind_zero_col] = trimData(X);
tElapsed = toc(tStart);
fprintf(['Time Elapsed: ' num2str(tElapsed) ' seconds.\n']);
runName = strsplit(directory, filesep);
if isempty(runName{end})
    runName = runName{end-1};
else
    runName = runName{end};
end
% Start a text file that summarizes the run, KMEANS RUN SUMMARY.txt.
try
    fid = fopen([write_dir, 'KMEANS RUN SUMMARY.txt'], 'a');
    fprintf(fid, '\r\n----------------------------------------------------\r\n');
    fprintf(fid, 'Run started at %s\r\n', datestr(clock()));
    fprintf(fid, 'Run - %s\r\n', run);
    fprintf(fid, 'Directory - %s\r\n', directory);
    fprintf(fid, '\r\nFILE DATA\r\n');
    fprintf(fid, 'Time to load image data - %f seconds\r\n', tElapsed);
    fprintf(fid, 'Image width - %d pixels\r\n', im_width);
    fprintf(fid, 'Image height - %d pixels\r\n', im_height);
    fprintf(fid, 'Total features per image - %d\r\n', im_height*im_width);
    fprintf(fid, 'Number of images in series - %d\r\n', num_bmp_files);
    fprintf(fid, 'Frames per secondo (fps) - %d\r\n', fps);
    fclose(fid);
catch
    warning('Error in writing run summary to file.\n');
    fclose(fid);
end

fprintf('Done Loading Processed Images.\n');

%% =================== PRINCIPLE COMPONENT ANALYSIS ======================= %%
for D = D:D
    fprintf('\nPerforming principle component analysis.\n');
    % Normalize the features
    [X_norm, mu, sigma] = featureNormalize(X);
    % Choose the dimensions of the new problem.

    % Run PCA
    tStart = tic;
    [U, S] = pca(X_norm,D);
    tElapsed = toc(tStart);
    fprintf(['Time Elapsed: ' num2str(tElapsed) ' seconds.\n']);

    % Visualize the first D eigenvectors
    % Re-pad the columns with pixels that are 0.
    U_disp = repadData(U', ind_zero_col);

    % Project the data into a reduced number of dimesions using the first x
    % eigenvectors of U
    Z = projectData(X_norm, U, D);

    % Display the eigenvectors and plot the eigenvalues as a time series and save to
    % file.
    fVecs = figure('Position', [50 0 (2*im_width + 30) (1.5 * im_height * D + 30)]);
    fVals = figure('Position', [50 0 (2*im_width + 30) (im_height * D + 30)]);
    fFft = figure();
    time = linspace(0,size(Z,1)/fps,size(Z,1));
    maxZ = max(Z, [], 'all');
    minZ = min(Z, [], 'all');
    ag = ag(:);

    Y = fft(ag);
    L = floor(length(ag)/2) * 2;
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    % guess 30 FPS? could pump in i suppose
    Fs = 30;
    f = Fs*(0:(L/2)) / L;
    plot(f,P1);
    title('Single-Sided Amplitude Spectrum of X(t)');
    xlabel('f (Hz)');
    ylabel('|P1(f)|');
    saveas(fFft, [write_dir sprintf('FFT_D%d.fig', D)]);
    saveas(fFft, [write_dir sprintf('FFT_D%d.jpg', D)]);

    fComb = figure('Position', [50 0 (4*im_width + 30) (im_height + 30)]);
    ag_range = max(ag) - min(ag);
    ag_norm = minZ + ((ag - min(ag)) .* ((maxZ - minZ) ./ ag_range)); 
    plot(time', Z, time, ag_norm);
    compNames = cell(1, D);
    for d = 1:D
        compNames{d} = sprintf('Component %d', d);
    end
    legend(compNames{:}, 'Average RHEED Intensity (Normalized)');
    title(['Combined Eigenvalues for ' runName]);
    saveas(fComb, [write_dir sprintf('Eigenvalues_combined_D%d.fig', D)]);
    saveas(fComb, [write_dir sprintf('Eigenvalues_combined_D%d.jpeg', D)]);
    xlPayload = [{'Time (s)'}, compNames, {'Average RHEED Intensity', 'Average RHEED Intensity (Normalized)'}; ...
        [num2cell(time'), num2cell(Z(:, 1:D)), num2cell(ag), num2cell(ag_norm)]];
    writecell(xlPayload, [write_dir, 'Eigenvalue_D' num2str(D) '_' runName '.xlsx']);
    for i = 1:D
        % Plot eigenvectors to single plot
        figure(fVecs);
        subplot(D, 1, i);
        displayImage(U_disp(i,:), im_height, im_width);
        axis equal;
        title(['Eigenvector' num2str(i) ' for ' runName]);

        % Individually plot the eigenvectors
        fVec = figure();
        displayImage(U_disp(i,:), im_height, im_width);
        axis equal;
        title(['Eigenvector' num2str(i)]);
        saveas(fVec, sprintf('%sEigenvector_D%d_i%d.jpeg', write_dir, D, i));
        hgsave(fVec, sprintf('%sEigenvector_D%d_i%d.ofig', write_dir, D, i));
        saveas(fVec, sprintf('%sEigenvector_D%d_i%d.fig', write_dir, D, i));

        % Plot the eigenvalues to a single plot
        figure(fComb);
        figure(fVals);
        subplot(D, 1, i);
        plot(time, Z(:,i), 'or', 'MarkerSize', 1);
        axis([0 time(end) min(Z(:,i)) max(Z(:,i))]);
        xlabel('Time (s)');
        ylabel('Response (a.u.)');
        title(['Component ' num2str(i) ' for ' runName]);

        % Individually plot the eigenvalues as a function of time
        fVal = figure();
        plot(time,Z(:,i), 'or', 'MarkerSize', 1);
        axis([0 time(end) min(Z(:,i)) max(Z(:,i))]);
        title(['Component ' num2str(i) ' for ' runName]);
        xlabel('Time (s)');
        ylabel('Response (a.u.)');
        saveas(fVal, sprintf('%sEigenvalue_D%d_i%d.jpeg', write_dir, D, i));
        saveas(fVal, sprintf('%sEigenvalue_D%d_i%d.fig', write_dir, D, i));
    end

    % Save the composite images to file.
    saveas(fVecs, [write_dir sprintf('Eigenvectors_D%d.jpg', D)]);
    saveas(fVals, [write_dir sprintf('Eigenvalues_D%d.jpg', D)]);
    saveas(fVecs, [write_dir sprintf('Eigenvectors_D%d.fig', D)]);
    saveas(fVals, [write_dir sprintf('Eigenvalues_%Dd.fig', D)]);
    %print(1, [write_dir, 'Eigenvectors.jpeg']); %, ['-S ', num2str(2*im_width + 30), ...
    %',' ,num2str(1.5 * im_height * D + 30)]);

    %print(2, [write_dir, 'Eigenvalues.jpeg']);% , ['-S ', num2str(2*im_width + 30), ...
    %',' ,num2str(im_height * D + 30)]);


    % Save the eigenvectors and their visualization to file
    save([write_dir, 'eigenvectorsD' num2str(D) '.mat'], 'U', 'U_disp', 'D', ...
        'S', 'Z');

    % Plot the original first image and the recovered first image.
    X_rec = recoverData(Z, U, D);

    % Calculate the variance retained.
    variance = calculateVariance(X_rec,X_norm);
    fprintf('With D = %d, %f%% of the variance is retained.\n', D, variance*100);

    % Un-normalize the recovered image and repad zeros as needed.
    X_rec = featureDenormalize(X_rec, mu, sigma);
    X_rec = repadData(X_rec, ind_zero_col);

    % Output PCA data to KMEANS RUN SUMMARY.txt
    try
        fid = fopen([write_dir, sprintf('KMEANS RUN SUMMARY_D%d.txt', D)], 'a');
        fprintf(fid, '\r\nPCA DATA\r\n');
        fprintf(fid, 'Time to run PCA - %f seconds\r\n', tElapsed);
        fprintf(fid, 'Reduced dimensions D - %d\r\n', D);
        fprintf(fid, 'Variance retained - %f\r\n', variance);
        fprintf(fid, 'Eigenvalues - \r\n');
        fprintf(fid, '%f\r\n', diag(S));
        fclose(fid);
    catch
        warning('Error in writing run summary to file.\n');
        fclose(fid);
    end

    % Create a plot of the original first image vs. the reconstructed image after
    % PCA
    fPCA = figure();
    subplot(2,1,1);
    displayImage(X(1,:), im_height, im_width);
    title(['Original Image for ' runName]);
    subplot(2,1,2);
    displayImage(X_rec(1,:), im_height, im_width);
    title(['Recovered Image after PCA for ' runName]);
    saveas(fPCA, [write_dir, 'Recovered Image_D' num2str(D) '.jpeg']);
    saveas(fPCA, [write_dir, 'Recovered Image_D' num2str(D) '.fig']);
end
fprintf('Finished PCA.\n');

%% ======================== K-MEANS CLUSTERING ============================ %%
fprintf('\nStarting K-Means Clustering.\n');
% Implement K-Means Clustering on the images.
[n, m] = size(Z);   % n is the number of training examples/images
% m is the number of pixels in each image (or features in
%    each image decomposition)

% K = 10; % Number of clusters
max_iters = 20;  % Maximum number of iterations of k-means algorithm
num_runs = 100;

% Output Kmeans data to KMEANS RUN SUMMARY.txt
try
    fid = fopen([write_dir, 'KMEANS RUN SUMMARY.txt'], 'a');
    fprintf(fid, '\r\nKMEANS DATA\r\n');
    fclose(fid);
catch
    warning('Error in writing run summary to file.\n');
    fclose(fid);
end

% Run K means for cluster sizes from 1 to max_clusters and calculate the cost
% function.
tElapsed = zeros(1, NUM_CLUSTERS);

parfor K = 1:NUM_CLUSTERS
    % Initialize the indices and cost matrices
    indices = zeros(n,num_runs);
    cost = zeros(num_runs,1);
    fprintf('Running K-means with K = %d...\n', K);
    tStart = tic;
    % Intialize the centroids matrix.
    centroids = zeros(K, m, num_runs);
    
    % Run K means num_runs times with different initial centroids to prevent
    % finding local optima
    for i = 1:num_runs
        % Initialize the centroids
        initial_centroids = initializeCentroids(Z, K);
        % Run K means
        [centroids(:,:,i), indices(:,i), cost(i)] = ...
            runKMeans(Z, initial_centroids, max_iters);
    end
    
    % Find the run with the smallest cost function.
    [~, bestRun] = min(cost);
    
    % Assign the run with the minimized cost function as the best cluster.
    cluster = centroids(:,:,bestRun);
    idx = indices(:,bestRun);
    costFunc(K) = cost(bestRun);
    
    % Output the data to a text file and the average cluster images to image
    % files
    % Create a new folder in the directory for the data
    [~, ~] = mkdir(write_dir, ['k' num2str(K)]);
    cluster_dir = [write_dir, 'k', num2str(K), '/'];
    % Create the reconstructed images matrix
    cluster_rec = recoverData(cluster, U, D);
    cluster_rec = featureDenormalize(cluster_rec, mu, sigma);
    cluster_rec = repadData(cluster_rec, ind_zero_col);
    
    % Create the text file name
    fname = ['k-means-' num2str(K) ' ' run '.txt'];
    fname = strrep(fname, ':', '-');
    fid = fopen([cluster_dir, fname], 'w');
    
    % Create the file header
    fprintf(fid, [fname, ' ', datestr(clock()), '\n']);
    fprintf(fid, ['K-means algorithm, K = ', num2str(K), '\n']);
    
    % Output each file name under the header of each cluster number
    for i = 1:K
        fprintf(fid, ['Cluster ', num2str(i),':\n']);
        
        cluster_indices = find(idx == i);
        cluster_size = length( cluster_indices );
        for j = 1:cluster_size
            % Print the filename of the image to file
            tmp = {files(idxbmp(cluster_indices)).name}; %#ok<PFBNS>
            fprintf(fid, [tmp{j}, '\n']);
        end
        
        % Reconstruct each image and save it, as both .bmp and as a .mat file
        image = uint8(reshape(cluster_rec(i,:), im_height, im_width));
        im_name = ['cluster', num2str(i)];
        imwrite(image, [cluster_dir, im_name, '.bmp'], 'bmp');
        saver([cluster_dir, im_name, '.mat'], image);
        %save([cluster_dir, im_name, '.mat'],'image');
    end
    fclose(fid);
    
    tElapsed(K) = toc(tStart);
    fprintf(['Time Elapsed: ' num2str(tElapsed(K)) ' seconds.\n']);
    
end

for K = 1:NUM_CLUSTERS
    % Output Kmeans data to KMEANS RUN SUMMARY.txt
    try
        fid = fopen([write_dir, 'KMEANS RUN SUMMARY.txt'], 'a');
        fprintf(fid, 'K = %d\r\n', K);
        fprintf(fid, 'Time to run - %f seconds\r\n', tElapsed(K));
        fprintf(fid, 'Cost - %f\r\n\r\n', costFunc(K));
        fclose(fid);
    catch
        warning('Error in writing run summary to file.\n');
    end
end


% Plot the cost function as a function of cluster size K
fCost = figure();
plot(costFunc,'LineWidth',2);
title(['Cost function as a function of number of clusters K for ' runName]);
xlabel('Number of Clusters K');
ylabel('Cost');
saveas(fCost, [write_dir, 'Cost Function.jpeg']);

% Save the cost function to .mat file
save([write_dir, 'costFunc.mat'], 'costFunc');

fprintf('\nFinished K-Means Clustering.\n');

toc;

end

function saver(fname, image)
    save(fname, 'image');
end