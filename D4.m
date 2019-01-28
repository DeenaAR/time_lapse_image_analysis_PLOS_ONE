%% Appendix D4
% calculates area of colony using bwconvhull, exports area to a csv file, 
% and saves union convex hull images

% written by Nina Manning and Deena Rennerfeldt

%% input
% specifies where the masked montages are; images should be in grayscale
masked_montages_path = 'C:\';
% specifies where to save the union convex hull images
union_path = 'C:\';

%% execute
% adds pathbases to matlab's searchable directory
addpath(masked_montages_path); 
addpath(union_path);

% calls on image files in masked_montages_path
image_files = dir((fullfile(masked_montages_path, '*.tif')));
% creates an empty array to save the colony's area
colony_area_array = zeros(1,length(image_files));

for i = 1:length(image_files)
    i    % report in command window which file MATLAB is processing
    % identifies the image to be processed
    original = imread(strcat(masked_montages_path, image_files(i).name));
    
    % converts the image into binary 
    % uses different thresholdings for different bit depths
    info = imfinfo(strcat(masked_montages_path, image_files(i).name));
    if info.BitDepth == 16
        binary = im2bw(original, 0.001);
    elseif info.BitDepth == 8
        binary = im2bw(original, 0.001);
    elseif info.BitDepth ==1
        binary = original;
    else
        binary = im2bw(original, 0.001);
    end

	% identifies the image's original file name
    file_name = image_files(i).name;

	% calls union convex hull to find the colony's total area    
    union = bwconvhull(binary);


	% saves the union convex hull image
    cd(union_path);
    imwrite(union, file_name, 'png');

	% calculates the area of the colony (in pixels) 
    % & appends colony_area_array with current area of colony
    colony_area_array(i) = bwarea(union);
end

% creates a csv file with the area of the colony at each time point
csvwrite('colony_area.csv', colony_area_array);

disp('done');