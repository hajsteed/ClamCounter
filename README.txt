This is an open source software package developed by Harry Steed under the School of Mathematics, Cardiff University.

The package sets out to automate the process of counting and measuring the width of daily growth lines in giant clam shells. 
Currently, identifying and measuring these lines is a lengthy process, requiring experts to manually count and label each image. 
This package utilises the wavelet transform to detect and highlight these features within the image.

REQUIRED TOOLBOXES:

Signal processing toolbox.
Parallel computing toolbox.

BEFORE EXECUTING:

Please ensure your folder ONLY contains images you wish to be analysed (only image file types are problematic).

The scale ratio should be determined by the user for each set of images. This should be inputted in units of pixels/micrometers 
and the value must remain constant for all images in the folder. If different images of the same shell have different scale ratios, 
they should be analysed separately.


EXECUTING THE SCRIPT:

Ensure the function scripts are in the correct folder path.
Open the script "main.m" in MATLAB.
Execute the script.
Navigate to your image folder and press select folder.
Enter the scale ratio in the pop-up box.
Perform rotation on your image so that the width of the lines varies along the horizontal.
Rotation increments are available in 1,45, and 90 degrees both clockwise (CW) and counterclockwise (CCW).

Below, the left is an example of how the lines should be oriented.



           ||||||                    -----
CORRECT =  ||||||       INCORRECT =  -----
           ||||||                    -----
  

Press 'save' once your image is correctly aligned.

Move the 'Peak Separation Distance' slider to modify the minimum required distance between peaks.
Press the 'Add Peak' button to manually add a peak.
Press the 'Remove Peak' button to manually remove a peak.
Press 'Next' to store the data and move to the next image.
Press 'Previous' to return to the previous image.
Press 'Export' to store the data into an XLSX spreadsheet named 'SHELL_DATA'.
The shell data file is stored in the current working directory.


The outputted figure displays the wavelet transform of the image, the data regarding the peaks, the original shell image, and
the averaged and inverted transform. The number of peaks corresponds to the number of lines detected throughout the image and
the distances between them represents the width of the lines.