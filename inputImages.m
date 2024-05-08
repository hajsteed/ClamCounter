function [imageFiles,numImages,pathin,scaleRatio] = inputImages()

    % Default path
    defaultPath = pwd;

    % Check if lastPath exists in preferences
    if ispref('MyImageProcessingApp', 'lastUsedPath')
        lastPath = getpref('MyImageProcessingApp', 'lastUsedPath');
        if isfolder(lastPath)
            defaultPath = lastPath;
        end
    end

    % Determines image folder
    pathin = uigetdir(defaultPath, 'Select Folder');

   % Save the selected path
    if pathin ~= 0
        setpref('MyImageProcessingApp', 'lastUsedPath', pathin);
    end

    % Specify the acccepted image formats
    imageFormats = {'*.jpg', '*.png', '*.tif', '*.bmp', '*.gif', '*.jpeg'};

    % Search for the images in the folder
    imageFiles = [];
    for i = 1:length(imageFormats)
        imageFiles = [imageFiles; dir(fullfile(pathin, imageFormats{i}))];
    end

    numImages = numel(imageFiles);
    imageNames = cell(numImages, 1);
    
    for i = 1:numImages
        [~, imageName, ~] = fileparts(imageFiles(i).name);
        imageNames{i} = imageName;
    end


    % Input dialog box to enter scale bar value
    prompt = 'Enter ratio of pixels/micrometer:';
    dlgTitle = 'pix/μm';
    numLines = 1;
    defaultVal = {'0'};  % Default value as a string
    options = struct('Resize', 'on', 'Interpreter', 'none');
    scaleValue = inputdlg(prompt, dlgTitle, numLines, defaultVal, options);


    % Convert the input to a numeric value
    scaleRatio = str2double(scaleValue{1});

    % Check if the conversion was successful and the input is a number
    if isnan(scaleRatio)
        % Handle the case when the input is not a valid number
        error('Invalid input. Please enter a numeric value.');
    end
end