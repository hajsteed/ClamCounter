function [frq, avgCoi, avgCfs, x, y, icfs_norm] = waveletTransform(rotatedImage, scaleRatio)

newImage = rotatedImage;
if size(newImage, 3) == 3
    newImage = newImage(:, :, 1:3);  % Ensure it's an RGB image
end
newImage = rgb2gray(newImage);
newImage = im2double(newImage);

[numRows, numCols] = size(newImage);

% Define the spatial dimensions
y = linspace(0,numRows/scaleRatio,numRows); % (start, #um, #pixels) (in microns)
x = linspace(0,numCols/scaleRatio,numCols); % (start, #um, #pixels) (in microns)

dx = x(2); % Spatial step size

% Pre allocate space
[cfs,frq,coi] = cwt(newImage(1,:), 1/dx);
[m,n] = size(cfs);
cwtResult = zeros(m,n);
coiResult = zeros(size(coi,1));

% Wavelet transform on the image
parfor row = 1:numRows
% Computes wavelet for each row
[cfs,frq,coi] = cwt(newImage(row,:), 1/dx);

% Assign result to cwtResult and coiResult
cwtResult=cwtResult+cfs;
coiResult=coiResult+coi;

end

% Average across the 3rd dimension
avgCfs = cwtResult/numCols;
% Average along the 2nd dimension (columns)
avgCoi = coiResult/numCols; 

% Averaged wavelet inversion
icfs = icwt(avgCfs);

% Normalise amplitudes
icfs_norm = (icfs-min(icfs))./(max(icfs)-min(icfs));

end


