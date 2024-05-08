global allPeakData; 
allPeakData = {};
mainScript();
function mainScript()

    % Create an empty map to cache data
    imageCache = containers.Map('KeyType', 'char', 'ValueType', 'any');

    % Select the images to be inputted
    [imageFiles,numImages,pathin,scaleRatio] = inputImages();

    % Selects the starting image position. 1 gives the first image in the folder
    a = 1;

    % Next and previous buttons
    uicontrol('Style', 'pushbutton', 'String', 'Next', 'Position', [1800 42 50 20],...
        'Callback', @(src, ~) processImage(src.UserData + 1, imageFiles, scaleRatio), 'UserData', a, 'Tag', 'nextBtn');
    uicontrol('Style', 'pushbutton', 'String', 'Previous', 'Position', [1750 42 50 20],...
        'Callback', @(src, ~) processImage(max(src.UserData - 1, 1), imageFiles, scaleRatio), 'UserData', a, 'Tag', 'prevBtn');
    
    % Call initial processing
    processImage(a, imageFiles, scaleRatio, imageCache);
end

function processImage(index, imageFiles, scaleRatio, imageCache, sliderValueText)
global allPeakData;
   
    % Get the full filename (including the path)
    namestrin = fullfile(imageFiles(index).folder, imageFiles(index).name);
    fieldName = sprintf('img%d', index);
   
    % Read the image
    image = imread(char(namestrin));

      if ishandle(gcf)
        close(gcf);
      end

    % Remove the scalebar
    [croppedImage] = removeScaleBar(image);

    % Rotate the image
    ImageRotator(croppedImage);
    % Wait for rotation to be finished
    uiwait;
    % Update rotatedImage before wavelet transform
    rotatedImage = getappdata(0, 'imageData');

    % Perform wavelet transform
    [frq, avgCoi, avgCfs, x, y, icfs_norm] = waveletTransform(rotatedImage, scaleRatio);
 
    % Min distance between peaks
    minSeparation = 25 * 2; 
    % Peak finding algorithm
    TF = islocalmax(icfs_norm, 'MinSeparation', minSeparation);

    
    % Get maximum indexes
    icfs_max = icfs_norm(TF);
    x_max = x(TF);

    % Calculate the peak data
    numPeaks = sum(TF);
    peakDistances = diff(x_max);
    peakDistances = round(peakDistances * 100) / 100;

    % Check if there's already data for this index
    if isfield(allPeakData, fieldName)
        % Append new peak distances
        allPeakData.(fieldName).peakDistances = ...
            [allPeakData.(fieldName).peakDistances, peakDistances];
    else
        % Create new entry
        allPeakData.(fieldName) = struct('numPeaks', numPeaks, 'peakDistances', peakDistances);
    end

    %%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%
    % Display the figure in full screen
    fig = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1], 'NumberTitle', 'off');
    annotation('textbox', [0.515, 0.98, 0, 0], 'String', ['Image ', num2str(index)], ...
        'FitBoxToText', 'on', 'HorizontalAlignment', 'center', 'FontSize', 10);

    % set(gcf,'color','w');
    % Wavelet transform plot
    subplot(2, 2, 1);
    pcolor(x, 1./frq, (abs(avgCfs)).^2);
    hold on
    plot(x, 1./avgCoi, '--k', 'Linewidth', 2);
    shading interp
    set(gca, 'yscale', 'log');
    title('Wavelet transform')
    xlabel('Shell length $(\mu m)$', 'Interpreter', 'Latex');
    ylabel('Wavelength $(\mu m)$', 'Interpreter', 'Latex');

    % Original shell plot
    subplot(2, 2, 3);
    imagesc(x,y,rotatedImage)
    title('Original shell')
    xlabel('Shell length $(\mu m)$', 'Interpreter', 'Latex');
    ylabel('Shell width $(\mu m)$', 'Interpreter', 'Latex');
   

    % Averaged, inverted wavelet plot
    subplot(2, 2, 4);
    hPlot = plot(x, icfs_norm,'Linewidth', 2); % Store the plot handle
    axis tight
    hold on
    hPeaks = plot(x_max, icfs_max, 'ro');
    %, MarkerSize=10, LineWidth=2
    ylabel('Amplitude $(\mu m)$', 'Interpreter', 'Latex');
    xlabel('Shell length $(\mu m)$', 'Interpreter', 'Latex');
    title('Inverted wavelet transform');

    % Create the minimum separation slider
    slider = uicontrol('Style', 'slider', 'Position', [1250 42 300 20],... %1250 or 0 first enrty
        'Min', 0, 'Max', 200, 'Value', minSeparation, 'SliderStep', [0.01 0.1]);
   
    % Create the text 'Peak Separation Distance'
    uicontrol('Style', 'text', 'Position', [1100 40 150 20],...
        'String', 'Peak Separation Distance', 'HorizontalAlignment', 'left');
   
    % Create the text for the value of minimum separation
    sliderValueText = uicontrol('Style', 'text', 'Position', [1570 42 100 20],...
        'String', ['Value: ', num2str(round(minSeparation))], 'HorizontalAlignment', 'left');

    % Create the next and previous buttons with new callback functions
    uicontrol('Style', 'pushbutton', 'String', 'Next', 'Position', [1800 42 50 20],...
        'Callback', @(src, ~) nextButtonCallback(src, imageFiles, scaleRatio, imageCache), 'UserData', index, 'Tag', 'nextBtn');
    uicontrol('Style', 'pushbutton', 'String', 'Previous', 'Position', [1750 42 50 20],...
        'Callback', @(src, ~) prevButtonCallback(src, imageFiles, scaleRatio, imageCache), 'UserData', index, 'Tag', 'prevBtn');

    % Add a button to add peaks
    uicontrol('Style', 'pushbutton', 'String', 'Add peak', 'Position', [1850 72 50 20],...
        'Callback', @(src, ~) addPeak(icfs_norm, x, hPlot, hPeaks, numPeaks, peakDistances, sliderValueText, index));

    % Add a button to remove peaks
    uicontrol('Style', 'pushbutton', 'String', 'Remove Peak', 'Position', [1750, 72, 100, 20], ...
        'Callback', @(src, evnt) removePeak(icfs_norm, x, hPlot, hPeaks, numPeaks, peakDistances, sliderValueText, index));

    % Add an "Export" button to the figure
    uicontrol('Style', 'pushbutton', 'String', 'Export', 'Position', [1850 42 50 20],...
        'Callback', @(src, ~) exportToExcel(allPeakData), 'Tag', 'exportBtn');

    % Slider callback property
    set(slider, 'Callback', @(src, ~) recalculatePeaksAndRedraw(src, icfs_norm, x, hPlot, hPeaks, sliderValueText, index));
    
    % Call updateFigure to set up the figure
    updateFigure(icfs_norm, x, hPlot, hPeaks, numPeaks, peakDistances, sliderValueText, index);

    % Plot the number of peaks and peak distances
    subplot(2, 2, 2);
    bar(peakDistances);
    xlabel('Peak Index / Day count', 'Interpreter', 'Latex');
    ylabel('Distance between peaks $(\mu m)$', 'Interpreter', 'Latex');
    title(['Number of peaks: ' num2str(numPeaks)]);
end

% A function to handle the behaviour of the 'next' button. If the image is
% not the last in the folder, increments the image index by -1.
function nextButtonCallback(src, imageFiles, scaleRatio, imageCache)
    global allPeakData;
    currentFig = gcf;

    % Check if the current image is the last one
    if src.UserData >= numel(imageFiles)
        disp('This is the last image.');
        return;  % Exit the function if it's the last image
    end

    % Increment the index and process the next image
    src.UserData = src.UserData + 1;
    processImage(src.UserData, imageFiles, scaleRatio, imageCache);

    % Close the current figure
    if ishandle(currentFig)
        close(currentFig);
    end
end



% A function to handle the behaviour of the 'previous' button. If the image is not the first
% in the folder, increments the image index by -1.
% function prevButtonCallback(src, imageFiles, scaleRatio, imageCache)
%  global allPeakData;
%  allPeakData = allPeakData(1:end - 1);
%     currentFig = gcf;
%     processImage(max(src.UserData - 1, 1), imageFiles, scaleRatio, imageCache);  
%         % Close the current figure (subplot figure)
% if ishandle(currentFig)
%     close(currentFig);
% end
% end
function prevButtonCallback(src, imageFiles, scaleRatio, imageCache)
    global allPeakData;
    currentFig = gcf;
    
    % Calculate the new index
    newIndex = src.UserData - 1;
    
    % Check if the newIndex is valid
    if newIndex > 1
        % Proceed with processing the previous image
        allPeakData = allPeakData(1:end - 1);
        processImage(newIndex, imageFiles, scaleRatio, imageCache);  
        
        % Close the current figure (subplot figure)
        if ishandle(currentFig)
            close(currentFig);
        end
        
        % Update the current image index stored in UserData
        src.UserData = newIndex;
    else
        % Display an error message if no previous image exists
        errordlg('No previous image found', 'Navigation Error');
    end
end

function addPeak(icfs_norm, x, hPlot, hPeaks, numPeaks, peakDistances, sliderValueText, index)
    global allPeakData;

    % Define a valid field name for the struct based on the index
    fieldName = sprintf('img%d', index);

    % Use ginput to get the coordinates of the clicked point
    [X, ~] = ginput(1);

    % Get the x coordinates and y coordinates of the existing peaks
    x_peaks = hPeaks.XData;
    y_peaks = hPeaks.YData;

    % Calculate the distances between the clicked point and the existing peaks
    dists = abs(x_peaks - X);

    % Find the index of the closest peak
    [~, idx] = min(dists);

    % If the clicked point is to the right of the closest peak, increment the index
    if X > x_peaks(idx)
        idx = idx + 1;
    end

    % Insert the new peak into the list
    x_peaks = [x_peaks(1:idx-1), X, x_peaks(idx:end)];

    % Interpolate the y values of the plot at the new x values
    y_new = interp1(hPlot.XData, hPlot.YData, X, 'linear', 'extrap');
    y_peaks = [y_peaks(1:idx-1), y_new, y_peaks(idx:end)];

    % Update the plot with new peaks
    hPeaks.XData = x_peaks;
    hPeaks.YData = y_peaks;

    % Recalculate the peak distances and update the bar plot
    peakDistances = diff(sort(x_peaks));
    numPeaks = numel(x_peaks); % Count the number of peaks including the new one

    % Save updated peak data back to the global struct
    allPeakData.(fieldName) = struct('numPeaks', numPeaks, 'peakDistances', peakDistances);

    % Update the figure with the latest value
    updateFigure(icfs_norm, x, hPlot, hPeaks, numPeaks, peakDistances, sliderValueText, index);
end

function removePeak(icfs_norm, x, hPlot, hPeaks, numPeaks, peakDistances, sliderValueText, index)
    global allPeakData;

    % Define a valid field name for the struct based on the index
    fieldName = sprintf('img%d', index);

    % Use ginput to get the coordinates of the clicked point
    [X, ~] = ginput(1);

    % Get the x coordinates of the existing peaks
    x_peaks = hPeaks.XData;

    % Calculate the distances between the clicked point and the existing peaks
    dists = abs(x_peaks - X);

    % Find the index of the closest peak
    [~, idx] = min(dists);

    % Remove the closest peak from the list
    x_peaks(idx) = [];  % Remove the x-coordinate of the peak
    y_peaks = hPeaks.YData;
    y_peaks(idx) = [];  % Remove the y-coordinate of the peak

    % Update the plot with the remaining peaks
    hPeaks.XData = x_peaks;
    hPeaks.YData = y_peaks;

    % Recalculate the peak distances
    peakDistances = diff(sort(x_peaks));
    numPeaks = numel(x_peaks); % Update the number of peaks

    % Save updated peak data back to the global struct
    allPeakData.(fieldName) = struct('numPeaks', numPeaks, 'peakDistances', peakDistances);

    % Update the figure with the latest value
    updateFigure(icfs_norm, x, hPlot, hPeaks, numPeaks, peakDistances, sliderValueText, index);
end

function recalculatePeaksAndRedraw(src, icfs_norm, x, hPlot, hPeaks, sliderValueText, index)
    global allPeakData;
    
    % Define a valid field name for the struct based on the index
    fieldName = sprintf('img%d', index);

    % Recalculate the peaks based on the new slider value
    newMinSeparation = src.Value;
    TF = islocalmax(icfs_norm, 'MinSeparation', newMinSeparation);
    icfs_max = icfs_norm(TF);
    x_max = x(TF);

    % Update the peaks plot
    hPeaks.XData = x_max;
    hPeaks.YData = icfs_max;

    % Recalculate the peak data
    numPeaks = sum(TF);
    peakDistances = diff(x_max);
    peakDistances = round(peakDistances * 100) / 100;

    % Update the slider value text
    set(sliderValueText, 'String', ['Value: ', num2str(round(newMinSeparation))]);
    updateFigure(icfs_norm, x, hPlot, hPeaks, numPeaks, peakDistances, sliderValueText, index);

    % Save updated peak data back to the global struct
    allPeakData.(fieldName) = struct('numPeaks', numPeaks, 'peakDistances', peakDistances);

    % Optionally refresh the displayed data or logs
    fprintf('Updated %s: %d peaks, %d distances\n', fieldName, numPeaks, length(peakDistances));
end

% Exports the growth line data to an spreadsheet named 'SHELL_DATA.xlsx'
function exportToExcel(allPeakData)
    global allPeakData;

    % Initialize an empty cell array for storing peak distances
    peakDistancesArray = {};

    % Extract field names from the struct
    fieldNames = fieldnames(allPeakData);

    % Loop through each field to access peak distance data
    for i = 1:length(fieldNames)
        fieldName = fieldNames{i};
        currentData = allPeakData.(fieldName).peakDistances;
        peakDistancesArray{end+1} = currentData(:);  % Ensure data is a column vector
    end

    % Concatenate all peak distance data into a single column vector
    peakDistancesVector = vertcat(peakDistancesArray{:});

    % Create header and data array for Excel
    title = {'Distance between peaks $(\mu m)$'};  % Make sure this is a 1x1 cell array

    % Prepare the data for export
    if isempty(peakDistancesVector)
        disp('No data to export.');
        return;
    end
        
    % Concatenate title and data
    dataCellArray = [title; num2cell(peakDistancesVector)];

    % Specify the Excel file name and path
    filename = fullfile(pwd, 'SHELL_DATA.xlsx');

    % Write data to Excel
    writecell(dataCellArray, filename, 'Sheet', 1);

    % Display a confirmation message
    disp(['Data exported to Excel file: ', filename]);
    msgbox('Growth data exported', 'Success');
end

