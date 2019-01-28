%% D14

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Combine_PCAgrids creates tables meant for PCA.  Each property is a column
% (determined by D12), and each row is a cell.  Uses
% D13 to organize data for each colony, then adds those
% data to a master table with all colonies on it. A PCA input table is
% saved for each colony (for each time point analyzed by
% D13) in folders that are organized by time point. The
% master tables are saved as well.
% 
% The script cycles through a folder containing CellProfiler output files 
% (see "inputs" below).  It requires the folder of output files (data_path)
% to have uniform names in this format: T43C03_Giga_Flame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% inputs %%%%%
% specify main PCA folder
% base_path='C:\';
% % specify date stamp (MM-DD-YY)
% date_stamp = '6-14-16';
% % specify path to CellProfiler output files
% data_path='C:\';
%%%%%%%%%%%%%%%%%%

% create a PCA subfolder with a date stamp
mkdir(base_path, char(date_stamp));
% make subfolders of the date-stamped folder for each time point analyzed 
%(e.g. birth time point)
date_path = fullfile(base_path, char(date_stamp));
mkdir(date_path, '1st_time_point');
mkdir(date_path, 'max_area_time_point');
mkdir(date_path, 'averages');
% create PCA_input_X_time_point for each PCAgrid; can't specify size (don't
%    know in advance of this code):
PCA_input_1st_time_point = [];
PCA_input_max_area_time_point = [];
PCA_input_averages = [];
% other variables for later on:
cumulative_cells = 0; 
% go to the output file path
CP_Files = dir((fullfile(data_path, '*.mat')));

% for each file in that path:
for filecount = 1:length(CP_Files)
    cd(data_path);
    % load the file (output into command window)
    file_name = CP_Files(filecount).name;
    load(file_name);
    %   determine colony number (to add to PCAgrid and saving colony-specific
    %   table) from file name:
    colony_number = str2double(file_name([2 3 5 6])); 
    %   determine colony name (for saving colony-specific table) from file
    %   name:
    colony_name_start = strfind(file_name,'T4')+7;
    colony_name_end = strfind(file_name,'.mat')-1;
    colony_name = file_name(colony_name_start:colony_name_end)
    colony_long_name = file_name(1:colony_name_end);    

    % run align_cells_for_PCA_v5 to get PCAgrids:
    align_cells_for_PCA


    %add the colony number to the PCAgrids in the FINAL column
    num_properties = size(PCAgrid_1st_time_point,2);
    colony_cells = size(PCAgrid_1st_time_point,1); %# cells in this colony
    cellcount = 1;
        for cellcount = 1:colony_cells %for each row of this colony PCAgrid
            PCAgrid_1st_time_point(cellcount,(num_properties+1)) = ...
                colony_number; 
            PCAgrid_max_area_time_point(cellcount,(num_properties+1)) = ...
                colony_number; 
            PCAgrid_averages(cellcount,(num_properties+1)) = ...
                colony_number; 
        end
    % add this colony data to the combined PCA input grids:
    PCA_input_1st_time_point = vertcat(PCA_input_1st_time_point, ...
        PCAgrid_1st_time_point);
    PCA_input_max_area_time_point = vertcat(PCA_input_max_area_time_point, ...
        PCAgrid_max_area_time_point);
     PCA_input_averages = vertcat(PCA_input_averages, ...
        PCAgrid_averages);

    cumulative_cells=cumulative_cells + colony_cells;
    clear handles Data RealN cellcount Parents

    % save the PCAgrids
    % convert grids to tables:
    PCAgrid_1st_time_point = array2table(PCAgrid_1st_time_point);
    PCAgrid_max_area_time_point = array2table(PCAgrid_max_area_time_point);
    PCAgrid_averages = array2table(PCAgrid_averages);

    cd(fullfile(date_path, '1st_time_point'))
    writetable(PCAgrid_1st_time_point,...
        [char(colony_long_name) '_PCAgrid.csv'], 'WriteVariableNames',false);

    cd(fullfile(date_path, 'max_area_time_point'))
    writetable(PCAgrid_max_area_time_point,...
        [char(colony_long_name) '_PCAgrid.csv'], 'WriteVariableNames',false);

    cd(fullfile(date_path, 'averages'))
    writetable(PCAgrid_averages,...
        [char(colony_long_name) '_PCAgrid.csv'], 'WriteVariableNames',false);

end

% save the PCA_input_X_time_point tables in the date-stamped PCA folder
cd(date_path)
  PCA_input_1st_time_point = array2table(PCA_input_1st_time_point);
  PCA_input_max_area_time_point = array2table(PCA_input_max_area_time_point);
  PCA_input_averages = array2table(PCA_input_averages);

writetable(PCA_input_1st_time_point,...
    'PCA_input_1st_time_point.csv', 'WriteVariableNames',false);
writetable(PCA_input_max_area_time_point,...
    'PCA_input_max_area_time_point.csv', 'WriteVariableNames',false);
writetable(PCA_input_averages,...
    'PCA_input_averages.csv', 'WriteVariableNames',false);
property_table = array2table(property_names);
writetable(property_table,'property_names.xlsx')
