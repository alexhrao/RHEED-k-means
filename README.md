# RHEED-k-means
An Octave script to process .avi videos of RHEED, run PCA and k-means clustering analysis on the image frame time series, and plot and analyze the resulting information, as described in the paper "Machine learning analysis of perovskite oxides grown by molecular beam epitaxy", Sydney R. Provence, Suresh Thapa, Rajendra Paudel, Tristan K. Truttmann, Abhinav Prakash, Bharat Jalan, and Ryan B. Comes, Phys. Rev. Materials 4, 083807 – Published 21 August 2020.

Please note that the full analysis can be performed by running the main.m script in the repo, although individual stages of analysis can be performed through running the individual functions. SVD can be rather slow, so it is recommended to limit the crop size to as small as possible, and eliminate any unnecessary frames in the video that are not useful to analysis.

## Running k-means on a RHEED video
Updated 4/16/19
Download and install Octave (or just use Matlab if you have a license)
https://www.gnu.org/software/octave/
The scripts can be run from either the command line interface (Octave CLI) or the command line of the Octave GUI. Make sure that you are in the local directory in which the .m files are saved before running the scripts. 
 
You can change the opening path of the CLI by right clicking on the Octave CLI icon and going to “Properties.” Change the “Start in:” variable under the shortcut tab. 
 
## Process the video
This step assumes that the video has already been quasi-edited, so that the video is actually recording a growth and not just the blacked out RHEED screen (although those frames can be deleted later if not). The video needs to be exported as a .avi file. It is recommended to export the RHEED videos at 2 fps.

First, run the processVideo.m script. The following variables will potentially need to be modified in the file header:
- vname: The name of the video file input as a string, typically the growth number.
- directory: The main directory containing the RHEED video file, input as a string.
- XWindowSize: The total number of pixels the cropped images will be in terms of width (default = 251). 
- YWindowSize: The total number of pixels the cropped images will be in terms of height (default = 161).
- cropImageAtTime: The script uses a sample frame to determine the correct window for cropping the rest of the video. This can be modified for videos that weren’t edited prior to running the program. Select the time in the video to take the frame from, in seconds. (default = 10). 

*Note on XWindowSize and YWindowSize*: The larger the number of pixels included in the processed images, the longer the k-means algorithm will take to run and the more memory that will be required. Care should be taken to only include the most pertinent data, rather than trying to capture as much of the window as possible. A window that is too large will throw a memory error during principle component analysis (PCA), or potentially cause it to take a very long time to run. If in doubt, use the defaults. In order to adjust the window size, you may want to run processVideo several times, using the pop-up window of the crop window to adjust the size. Use ctrl+C in Octave/Matlab to halt the program. 

The script will take the frame of the video and use it to crop the rest of the series of images by establishing an initial window, through the getWindow.m function. The function will make an initial guess in centering the RHEED streaks, but will ask the user to confirm that the 251 × 161 window is centered in both the vertical and horizontal directions and modify the window if necessary. The classification rate of the initial guess on test images is currently about 70%. Once the window is established, the script will decompose the video into a series of .bmp images in a new folder in the directory. This process can be lengthy, processing a 30 minute video at 10 fps takes about 26 minutes.

The dependent functions needed to run processVideo.m are:
- getWindow.m (sets the relevant window to crop the image series)
- rssMirror.m (mirrors a function around itself and calculates the residuals, necessary for getWindow to make an initial guess for the window)

## Run the K Means with PCA
The main script to run the algorithm, kmeans.m, must be modified before running. The following variables need to be modified:
- run: run is a string with the growth number. If processVideo.m was used to decompose the video into .bmp files, it will also be the name of the folder containing the image series. If not, this will need to be changed to the folder name.
- directory: The main directory containing the RHEED video files, input as a string.
- write_dir: The write directory for output files, input as a string.
- D: The dimension that the data will be reduced to after running PCA, or the total number of eigenvectors that will be pulled from the singular value decomposition. For example, for a 251 × 161 image with 40,411 total pixels, choosing D = 6 (default) will reduce the number of features/pixels the k-means algorithms to the top 6 eigenvectors. All images can be reconstructed from these eigenvectors, but this will reduce the time it takes for the process to run. 
- NUM_CLUSTERS: The maximum number of clusters k-means will attempt to group. (default = 10)

The file can now be run through Octave or Matlab.

The dependent functions needed in the path or working directory to run kmeans.m are:
- loadImages.m (loads and unrolls the image series into a data matrix X)
- trimData.m (trims pixels with no intensity from the data matrix)
- featureNormalize.m (normalizes a data matrix so that all values are between -1 and 1)
- pca.m (runs PCA, returning the first D eigenvectors and diagonalized D × D matrix of eigenvalues)
- lmsvd.m (An optimized singular value decomposition (SVD) function that runs faster than Matlab/Octave’s internal svd function. Credit:      Xin Liu, Zaiwen Wen, Yin Zhang) 
- featureDenormalize.m (used to de-normalize data matrices)
- repadData.m (Repads columns that were trimmed with 0 intensity pixels for viewing)
- displayImage.m (Displays unrolled image vectors as Matlab/Octave figures)
- projectData.m (Projects the data onto a reduced number of dimensions using the first D eigenvectors obtained from PCA)
- recoverData.m (Uncompresses a compressed data matrix into the original number of pixels)
- calculateVariance.m (Calculates the variance retained from PCA after reducing to D dimensions)
- initializeCentroids.m (Randomly initializes the centroids for k-means clustering)
- runKMeans.m (Runs the k-means algorithm)
- findClosestCentroids.m
- computeCentroids.m
  
### Overview of the process
A summary of the parameters chosen for the run, the image size and number of frames used, and the time associated with running each section of the script is output to a text file in the write_dir, called “KMEANS RUN SUMMARY.txt.” All information that is displayed to the console will also be written to this text file.

#### Loading Images
All images are loaded into a single data matrix, X. This matrix takes the “unrolled” images and stores them as row vectors in X, so that each row represents one image. The dimensions of X will be the number of images m × the number of pixels per image n. All pixels with no intensity across the entire series of images (essentially, all columns in X that are all 0) are deleted from the analysis. 
 
#### Principle Component Analysis (PCA)
PCA is a method for compressing data while retaining the most statistically important features. The data matrix is first normalized so that all values are between -1 and 1, and PCA is performed using an optimized singular value decomposition (SVD) function. The data is projected onto a new data matrix, Z, using the first D eigenvectors. All eigenvectors should be displayed as a figure, and visualizations of individual eigenvectors will be saved to the output directory, along with the matrix of eigenvectors (saved as a .mat file). As PCA tends to be the most computationally intensive section, the .mat file can be used to break up the process without re-running PCA. An example of an image recovered from the eigenvectors will be displayed as a figure and saved into the output directory. 

The variance retained from reducing the image from m to D dimensions is calculated as: 
Variance Retained= 1-(Average squared projection error)/(Total variation in the data)

#### K-Means Clustering
K-means is an iterative clustering algorithm that breaks data into groups in which each individual data point is grouped into the cluster with the nearest mean. The progress of the k-mean algorithm is heavily dependent on where the clusters are initialized, and there is no guarantee that the algorithm will reach an optimized clustering for a single run. Thus, for the number of clusters K, the clusters are randomly initialized and the algorithm is run 100 times for each K. The “best” run is chosen by calculating the cost J, or average distance between each image in a cluster and the cluster centroid.

The script will automatically write the names of the images that are assigned to each cluster into a text file and save it the cluster folder in the write directory. A reconstructed “mean” image of each cluster will also be created and saved as a bitmap in the cluster folder. 

The script will run the k-means algorithm from 1 to NUM_CLUSTERS, and plot the cost function for each “best run” in the clusters as an Octave figure (this will also be saved to the write directory). This graph can be useful in determining the optimal number of clusters K for the video. From the equation above, it is apparent that the “optimal” number of clusters will always be when K = m, as the cost for this is 0. The cost function will always decrease as K increases, but plotting it can be useful for picking out an “elbow” in the curve, or a point at which the rate of cost function decrease levels out.

## Reading and Visualizing the Data
The main script to run the algorithm, analyzeKMeans.m, must be modified before running. The following variables need to be modified:
- run: run is a string with the growth number. If processVideo.m was used to decompose the video into .bmp files, it will also be the name of the folder containing the image series. If not, this will need to be changed to the folder name.
- write_dir: The directory into which the kmeans script output data files, input as a string.
- displayImages: The script can either plot the clusters in the RHEED video as a function of time alone, or it can include the average image for each cluster at the bottom of the plot. displayImages can be set to true or false to either include the images or not. (default = true)
- fps: The number of frames per second of the initial .avi video. This must be correct to properly display the times on the x-axis of the plot. (default = 2). 
- SAVEAS: The script will output a plot for each cluster and save it to the cluster directory in the write folder. Changing this string will change the plot name. Failure to change the string when re-running analyzeKMeans for the same run will result in overwriting the previous effort. (default = ‘Cluster Plot.jpeg’)

The file can now be run through Octave or Matlab. The dependent functions needed in the path to run kmeans.m are:
- readKMeans.m (loads the text file output from a k means run and stores the time sequence for each cluster in a cluster structure.)
- plotClusters.m (plots a cluster read in from readKMeans.m, along with an image matrix if included.)

All plots output from analyzeKmeans will be displayed as octave figures and saved to the write directory as .jpeg files. It is best to avoid closing the windows that pop up in Octave until the program has finished running, as prematurely closing them can throw an error if done before the plot is saved to file.



