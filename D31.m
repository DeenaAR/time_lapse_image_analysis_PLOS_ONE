%% D31 Written by Nina Manning under the supervision of Deena Rennerfeldt

%% computes area of a single cell with background removed
% converts images to binary using imbinarize
% then computes area using bwarea

%% TODO defining variables

% directory to where the images are located
% do not use a backslash at the end of the pathway
pathway = 'C:\';

% name you would like to save file as (.csv)
savefilename = 'C18.csv';

% image file extension ex: '*.jpg'
image_extension = '*.jpg';

% image scale conversion factor, (um (microns)/pixels)^2
conversion_factor = 0.408;

%% set up and loading images

% changes directory to where the images are located
cd(pathway);

% gets list of all files in this directory w/ specified extension
imagefiles = dir(image_extension);      % DIR returns as a structure array
nfiles = length(imagefiles);            % Number of files found

%% iterating through images and computing area of cell

% reads files, converts to grayscale then binary, computes area
for i = 1:nfiles
    currentfilename = imagefiles(i).name;
	currentimage = imread(currentfilename);
    % this was commented out by Deena 1-8-18 after running .jpgs that
    % appeared to already be in grayscale
%     if strcmp(image_extension,'*.jpg') == 1 || strcmp(image_extension,'*.jpeg') == 1
%         currentimage = rgb2gray(currentimage); % converts to grayscale
%     end
	currentimage = imbinarize(currentimage); % converts to binary
	areas(i,1) = bwarea(currentimage);
end

%% exporting csv of cell areas

% converting to um (microns) from pixels
areas = areas*conversion_factor;

% initializing cell array with image names & diameter
areas_labeled = cell(nfiles, 2);

% adds names of images and diameters of cell to diameters_labeled
for i = 1:nfiles
   [pathstr,name,ext] = fileparts(imagefiles(i).name);
   areas_labeled{i,1} = name;
   areas_labeled{i,2} = areas(i,1);
end

areas_labeled = sortrows(areas_labeled, 1); % sorts based off image #

% saves csv of areas
fid = fopen(savefilename,'w');
for k=1:size(areas_labeled,1)
    fprintf(fid,'%s,%f\n',areas_labeled{k,:});
end
fclose('all');

disp('done');
