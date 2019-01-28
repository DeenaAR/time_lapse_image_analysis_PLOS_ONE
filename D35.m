%% D35 Written by Nina Manning under the supervision of Deena Rennerfeldt

%% Measuring Diameter
% measures the diameter of a cell in a well 
% uses imbinarize and imfindcircles (circular Hough transform)
% saves images of the cell being measured
% saves a csv file of the diameters of the cells

%% TODO defining variables

% directory to where the images are located
% do not use a backslash at the end of the pathway
pathway = 'D:\Summer 17\Measuring Diameter\Trial_9-4\original_images';

% image file extension ex: '*.tif'
image_extension = '*.tif';

% image scale conversion factor, um (microns)/pixels
conversion_factor = 200/155;

% expected average radius range
% calculated from taking manual measurements
Rmin = 4;
Rmax = 13;

% dimensions of the area of interest where the cell is contained
% found by taking manual measurements 
% pixel coordinates, top to bottom, left to right
hmin = 472;
hmax = 550;
wmin = 637;
wmax = 715;

%% set up and loading images

% changes directory to where the images are located
cd(pathway);

% gets list of all files in this directory w/ specified extension
imagefiles = dir(image_extension);      % DIR returns as a structure array
nfiles = length(imagefiles);            % Number of files found

% saves images in the images array
for i = 1:nfiles
   currentfilename = imagefiles(i).name;
   currentimage = imread(currentfilename);
   images{i} = currentimage;
end

% create blank image of same dimensions as other images 
% (assumes all are of same size)
[height, width] = size(images{1}); % get dimensions
blank_image = imbinarize(ones(height, width)); % binary white image

%% thresholding, converting to binary, and identifying cells as circles

% creates and changes directory for saving images
mkdir circle_images
cd(strcat(pathway, '\circle_images'));

% preallocating total_radii array
total_radii = zeros(nfiles,1);

for i = 1:nfiles    
    image = images{i};
    binary = imbinarize(image, 'adaptive', 'Sensitivity', 0.635);
    cropped = blank_image;
    for h = 1 : height
        for w = 1: width
            if (hmin<h)&&(h<hmax) && (wmin<w)&&(w<wmax)
                cropped(h, w) = binary(h, w);
            end
        end
    end
    
    % might need to adjust sensitivity depending on image
    [centers,radii] = imfindcircles(cropped, [Rmin Rmax], 'ObjectPolarity', 'dark', 'Sensitivity', 0.972);
    % if there are multiple identified objects, keeps the biggest one
    % issue with sensitivity is increasing picks up smaller objects
    % use the smallest value for picking up all cells
    
    % only keeps largest circle identified
    if ~isempty(centers)
        center = centers(1,:);
        radius = radii(1);
        total_radii(i) = radius;
    end
    
    imshowpair(cropped, image, 'montage');
    viscircles(center, radius, 'Color', 'b');
    
    % save image identifying circles
    currentfilename = imagefiles(i).name;
    saveas(gcf, strcat('circles_', currentfilename));
end

%% exporting diameters as a csv file

% finding diameter from radius
diameters = 2*total_radii;
% converting to um (microns) from pixels
diameters = diameters*conversion_factor;

% initializing cell array with image names & diameter
diameters_labeled = cell(nfiles, 2);

% adds names of images and diameters of cell to diameters_labeled
for i = 1:nfiles
   [pathstr,name,ext] = fileparts(imagefiles(i).name);
   diameters_labeled{i,1} = name;
   diameters_labeled{i,2} = diameters(i);
end

% changes directory to original pathway
cd(pathway);

% saves csv of diameters
fid = fopen('diameters.csv','w');
for k=1:size(diameters_labeled,1)
    fprintf(fid,'%s,%f\n',diameters_labeled{k,:});
end
fclose('all');

disp('done');
