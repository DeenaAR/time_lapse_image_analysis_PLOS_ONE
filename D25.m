%% D25: Written by Nina Manning under the supervision of Deena Rennerfeldt
% Get coordinates of cell's attachment
% image #, montage X coordinate, montage Y coordinate, 
% original X coordintate, original Y coordinate

%% TODO defining variables

% directory to where the images are located
% do not use a backslash at the end of the pathway
pathway = 'C:\';

% name you wish to save the file as (.csv)
savefilename = 'dish5.csv';

% image file extension ex: '*.jpg'
image_extension = '*.png';

% expected average radius range of dots
% calculated from taking manual measurements
Rmin = 9;
Rmax = 25;

%% set up and loading images

% changes directory to where the images are located
cd(pathway);

% gets list of all files in this directory w/ specified extension
imagefiles = dir(image_extension);      % DIR returns as a structure array
nfiles = length(imagefiles);            % Number of files found

%% iterating through images and finding coordinates

coordinates_labeled = []; % intializing array
% identifies circles and their center's coordinates
for i = 1:nfiles
    currentfilename = imagefiles(i).name; % gets current filename
    image = imread(currentfilename); % reads file
    image = rgb2gray(image); % converts to gray
    image = imbinarize(image); % converts to binary
    [rows,columns] = size(image);
    
    [centers,~] = imfindcircles(image, [Rmin Rmax]);
    if ~isempty(centers) % if there is at least 1 cell
        for j = 1:length(centers(:,1)) % iterate through cells
            
            coordinates_labeled(end+1,1) = i; % label image number
            
            % factor to adjust by to get coordinates in whole montage
            x_factor = i;
            y_factor = 1;
            while x_factor > 14
                x_factor = x_factor - 14; % finds column position
                y_factor = y_factor + 1; % finds row position
            end
            
            % coordinates adjusted for whole montage
            coordinates_labeled(end,2) = round(centers(j,1)) + columns*(14-x_factor); % x_coor
            coordinates_labeled(end,3) = round(centers(j,2)) + rows*(14-y_factor); % y_coor
            
            coordinates_labeled(end,4) = round(centers(j,1)); % original x_coor
            coordinates_labeled(end,5) = round(centers(j,2)); % original y_coor
        end
    end
end

%% saving csv file of image number and coordiantes

% saves csv of image number and coordinates
csvwrite(savefilename, coordinates_labeled);

disp('done');