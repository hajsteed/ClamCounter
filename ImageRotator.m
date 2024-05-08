function ImageRotator(croppedImage)
% Create copies of croppedImage
img = croppedImage;
I = croppedImage;

% Pre-processing of the image
I = I(:, :, 1:3);
I = rgb2gray(I);
I = im2double(I);

% Fourier transform the image
fourier_image = abs(fftshift(fft2(I - mean(I(:)))));
% Pick out the largest 10 indices of the Fourier transform
[~,MaxIndices] = maxk(fourier_image(:),10);

% Pre-allocate space
Temp_matrix=zeros(size(fourier_image));
Temp_matrix(MaxIndices)=1;

% Principal component analysis on the largest coefficients to calculate
% rotation angle and rotate croppedImage accordingly
PCA_coefficients = pca(Temp_matrix);

if size(PCA_coefficients, 1) >= 2 || size(PCA_coefficients, 2) >= 1   
rotationAngle = atan2d(PCA_coefficients(1, 1), PCA_coefficients(2, 1)) - 90;
else
rotationAngle = 0;
end

% Initial rotation of croppedImage
rotatedImage = imrotate(croppedImage, rotationAngle, 'bilinear', 'loose');

% Store data in 'appdata'
setappdata(0, 'originalImage', img);%
setappdata(0, 'rotationAngle', rotationAngle); 
setappdata(0, 'imageData', rotatedImage);%

% Button definitions
buttonCW1 = uicontrol('Style', 'pushbutton', 'String', '1° CW',...
    'Position', [300 10 50 30], 'Callback', @rotateClockwise1);

buttonCW45 = uicontrol('Style', 'pushbutton', 'String', '45° CW',...
    'Position', [350 10 50 30], 'Callback', @rotateClockwise45);

buttonCW90 = uicontrol('Style', 'pushbutton', 'String', '90° CW',...
    'Position', [400 10 50 30], 'Callback', @rotateClockwise90);

buttonCCW1 = uicontrol('Style', 'pushbutton', 'String', '1° CCW',...
    'Position', [200 10 50 30], 'Callback', @rotateCounterclockwise1);

buttonCCW45 = uicontrol('Style', 'pushbutton', 'String', '45° CCW',...
    'Position', [150 10 50 30], 'Callback', @rotateCounterclockwise45);

buttonCCW90 = uicontrol('Style', 'pushbutton', 'String', '90° CCW',...
    'Position', [100 10 50 30], 'Callback', @rotateCounterclockwise90);

buttonSave = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [500 10 50 30], 'Callback', @saveRotatedImage);
% 
buttonZero = uicontrol('Style', 'pushbutton', 'String', 'Zero',...
     'Position', [10 10 50 30], 'Callback', @zeroImage);

% buttonReset = uicontrol('Style', 'pushbutton', 'String', 'Reset',...
%     'Position', [50 10 50 30], 'Callback', @resetImage);


    % Create an axes for displaying the image
    hAxes = axes('Units', 'normalized', 'Position', [0.1 0.2 0.8 0.7]);

    % Display the initial image
    imshow(rotatedImage, 'Parent', hAxes);
    axis(hAxes, 'tight'); % Set axes limits to fit the image

    % Rotation buttons %
    % Rotate by 1 degree clockwise
    function rotateClockwise1(~, ~)
        rotateImage(-1);
    end

     % Rotate by 45 degrees clockwise
    function rotateClockwise45(~, ~)
        rotateImage(-45);
    end

    % Rotate by 90 degrees clockwise
    function rotateClockwise90(~, ~)
        rotateImage(-90);
    end
    
    % Rotate by 1 degree clockwise counter-clockwise
    function rotateCounterclockwise1(~, ~)
        rotateImage(1);
    end
    
    % Rotate by 90 degrees counter-clockwise
    function rotateCounterclockwise45(~, ~)
        rotateImage(45);
    end
   
    % Rotate by 90 degrees counter-clockwise
    function rotateCounterclockwise90(~, ~)
        rotateImage(90);
    end

    % Save button callback function
    function saveRotatedImage(~, ~)
        % Store rotated image, update rotatedImage
        rotatedImage = getappdata(0, 'imageData');
        assignin('base', 'rotatedImage', rotatedImage);
      close(gcf);
    end
 
% Zero button callback function. Sets the initial rotation angle to zero
function zeroImage(src, event)
    hAxes = gca;
    originalImage = getappdata(0, 'originalImage');  % Retrieve the original image stored in appdata

    % Since we are "zeroing" the image, set the rotation angle to 0
    rotationAngle = 0;  
    setappdata(0, 'rotationAngle', rotationAngle);  % Store the zero rotation angle in appdata

    % Rotate the original image by 0 degrees (which does nothing but ensures consistency)
    rotatedImage = imrotate(originalImage, rotationAngle, 'bilinear', 'loose');
    imshow(rotatedImage, 'Parent', hAxes);  % Display the reset image
    axis(hAxes, 'tight');  % Adjust axes to fit the image

    % Update 'appdata' with the reset image data
    setappdata(0, 'imageData', rotatedImage);
end


% % Reset button callback function
% function resetImage(~,~)
%     % Retrieve the initial rotation angle
%     initialRotationAngle = getappdata(0, 'rotationAngle');
% 
%     % Reset the rotation angle
%     setappdata(0, 'rotationAngle', initialRotationAngle);
% 
%     % Update the displayed image and set axes limits
%     rotatedImage = imrotate(img, initialRotationAngle, 'bilinear', 'loose');
%     hAxes = gca;
%     imshow(rotatedImage, 'Parent', hAxes);
%     axis(hAxes, 'tight'); % Set axes limits to fit the rotated image
% 
%     % Store updated image data in 'appdata'
%     setappdata(0, 'imageData', rotatedImage);
% end

% Rotate the image using imrotate based on 'direction'
function rotateImage(direction)
    % Update total rotation angle from 'appdata'
 
    rotatedImage = getappdata(0, 'rotatedImage');
    rotationAngle = rotationAngle + direction;
    rotatedImage = imrotate(croppedImage, rotationAngle, 'bilinear', 'loose');

    % Update the displayed image and set axes limits
    hAxes = gca;
    imshow(rotatedImage, 'Parent', hAxes);
    axis(hAxes, 'tight'); % Set axes limits to fit the rotated image

    % Store updated image data in 'appdata'
    setappdata(0, 'imageData', rotatedImage);
end
end

    

