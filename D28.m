%% D28
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This script adds a black border to images of different grid sizes  %%%
%%% in order to make them the same size as a 5x5 image (6720x5070).     %%%
%%% This is needed so that images of different grid sizes can be run    %%%
%%% through CellProfiler.  The only thing that needs to be specified is %%%
%%% 'pathbase'and 'pathsave', where pathbase is the folder containing   %%%
%%% the images you want to pad, and pathsave is the path to save the    %%%
%%% images to. Written by Deena Rennerfeldt.                            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% add pathbase and pathsave to matlab's searchable directory
addpath(pathbase);
addpath(pathsave)

% Call all the files in pathbase.  You may need to change the file
% extension.
Files = dir((fullfile(pathbase, '*.jpeg')));

for i = 1:length(Files) % for each file
    i % report in command window which file MATLAB is processing
    FileName = Files(i).name; % name of the given .tif file
 
    % The following adds black padding around files in the pathbase folder.
    % The grid size of the image determines how much padding to add.
    % Currently,this is set to make all images the same size as 5x5 grid 
    % (height = 5070, width = 6720).  The number of pixels added in the 
    % matrix [height width] are doubled with this function, which is why
    % this code specifies to add only half the pixel difference between a 
    % given image and the 5x5 images.
    
    image=imread(FileName);
        if ~isempty(findstr(FileName,'2x2'))
            paddedimage = padarray(image,[1521 2016],'both');
        elseif ~isempty(findstr(FileName,'3x3'))
            paddedimage = padarray(image,[1014 1344],'both');
        elseif ~isempty(findstr(FileName,'4x4'))
            paddedimage = padarray(image,[507 672],'both');    
        elseif ~isempty(findstr(FileName,'5x5')) %this is actually needed 
            paddedimage = padarray(image,[0 0],'both');  % 
        end

    %Save the file. 

    imwrite(paddedimage, [fullfile(pathsave, FileName)]);

end