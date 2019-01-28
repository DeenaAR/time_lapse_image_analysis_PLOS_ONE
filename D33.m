%% D33
%% 
%  Computes area, generation, and location of cells at last time point
%  Contains code adapted from Nina Manning's D31 and
%  D32  

% To run, it must have cell lineage information, which is created with
% D32.  In other words, LIA must be done for time lapse
% before this analysis can be done.  This code assumes the cell generation
% is in the 6th column of the lineage data csv.  see D32
% for mor info.

%% Input

% directory to where the images and lineage info are located
image_path = 'C:\';

% main path you would like to save in (a subfolder will be made)
main_save_path = 'C:\';
% name of the subfolder to be made (where all output will go)
save_tag = '1-10-18';
% name of this colony/image set
colony_name = 'T94C28';

% image file extension ex: '*.jpg'
image_extension = '*.jpg';

% image scale conversion factor, (um (microns)/pixels)^2
conversion_factor = 0.408;

%% set up and loading images

% make a subfolder to save this analysis
mkdir(main_save_path, save_tag)
save_path = fullfile(main_save_path, save_tag);

% change directory to where the images are located
cd(image_path);

% gets list of all files in this directory w/ specified extension
image_files = dir(image_extension);      % DIR returns as a structure array
num_files = length(image_files);            % Number of files found

% load the csv containing the lineage information
lineage_data = csvread(fullfile(image_path, 'cell_lineage_data.csv'));

% initializing cell array with image names & area
area_matrix = zeros(num_files, 5);

% reads files, converts to binary, computes area
for image_count = 1:num_files
    % open the image
    file_name = image_files(image_count).name;
	current_image = imread(file_name);
	% convert image to binary
    current_image = imbinarize(current_image);
	% find the cell ID
    [~,cell_ID,~] = fileparts(image_files(image_count).name);
    cell_ID = str2num(cell_ID);
    % measure cell area
    cell_area = bwarea(current_image)*conversion_factor;
    % find the x and y coordinates of the cell's centroid
    coordinates = regionprops(current_image,'centroid');
    coordinates = coordinates(1,1);
    x_coord = coordinates.Centroid(1);
    y_coord = coordinates.Centroid(2);
    % find the generation of this cell, as determined by
    % create_lineagetree.m
    lineage_row = find(lineage_data(:,1) == cell_ID);
    generation = lineage_data(lineage_row,6);
    
    % add everything to the data array:
    area_matrix(image_count,1) = cell_ID;
    area_matrix(image_count,2) = cell_area;
    area_matrix(image_count,3) = x_coord;
    area_matrix(image_count,4) = y_coord;
    area_matrix(image_count,5) = generation;
end

%% make a plot representing the data

% wild olive color scheme, Day 7 version
color_array={[255 101 111]/255, [254 125 101]/255, [254 149 92]/255, [254 189 99]/255, [255 229 106]/255, [213 224 102]/255, [160 220 98]/255, [116 212 171]/255, [73 205 244]/255, [60 158 226]/255, [48 111 209]/255};

% get the RGB color codes for each cell based on its generation
cell_colors = color_array(area_matrix(:,5));
% add the RGB values to the area_array
area_matrix(:,6) = cellfun(@(v) v(1), cell_colors(:,:));
area_matrix(:,7) = cellfun(@(v) v(2), cell_colors(:,:));
area_matrix(:,8) = cellfun(@(v) v(3), cell_colors(:,:));

% make and save the visualization
glyph = figure('Color', [1 1 1]);
scatter(area_matrix(:,3),area_matrix(:,4), area_matrix(:,2)./50, area_matrix(:, 6:8),'filled','MarkerEdgeColor',[0 0 0], 'LineWidth',0.5)
title(colony_name)
% determine the axis limits, which should be the size of the images
% analyzed to keep the scale the same across all datasets:
axes_limits = [0 size(current_image,2) 0 size(current_image,1)];
axis(axes_limits)
% get rid of the tick labels for downstream editing:
set(gca,'XTick',[],'YTick',[])

% save the glyph
set(gcf,'Position',[100 100 820 785])
figure_name = fullfile(save_path, strcat(colony_name, '_glyph'));
print(figure_name,'-painters','-dpng','-r1000');

% save the data matrix as a csv
csvwrite(fullfile(save_path,strcat(colony_name, '_final_area.csv')),area_matrix);

% save the data matrix as a table with headers
table_headers = {'cell_ID', 'area', 'x_coordinate','y_coordinate', 'generation','color_R','color_G','color_B'};

area_table = array2table(area_matrix);
area_table.Properties.VariableNames = table_headers;

writetable(area_table, fullfile(save_path,strcat(colony_name, '_final_area.xlsx')))
