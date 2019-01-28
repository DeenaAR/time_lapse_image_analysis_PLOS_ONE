%% D23 Written by Nina Manning under the supervision of Deena Rennerfeldt

% calculates confluency of colony
% import colony_area.csv as a cell array colonyarea and colony_cell_area.mat as handles
% exports a csv file with the confluencies

% change to where you want the spreadsheet to be saved
pathway = 'C:\';
cd(pathway);

% creates an array of the area of the cells in the colony
for i = 1:length(handles.Measurements.Image.AreaOccupied_AreaOccupied_expanded_cells)
    colony_cell_area{i} = handles.Measurements.Image.AreaOccupied_AreaOccupied_expanded_cells{i};
end

% corrects formating of the cells, cell to matlab data
colony_cell_area = cell2mat(colony_cell_area);
colony_area = cell2mat(colonyarea);

% creates an array of the confluency at each timepoint by dividing the
% total area of the cells in the colony by the total area of the colony
 for i = 1:length(handles.Measurements.Image.AreaOccupied_AreaOccupied_expanded_cells)
     confluency{i} = rdivide(colony_cell_area(i),colony_area(i));
 end
 
% creates a csv file with the confluency of the colony at each time point
csvwrite('colony_confluency.csv', confluency);

disp('colony_confluency.csv exported');