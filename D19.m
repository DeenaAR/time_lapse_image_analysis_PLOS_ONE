%% D19

% tally number of cells in each progeny and classify them as being fast,
% moderate, or slow dividers
% Written by Deena Rennerfeldt

% where the CellProfiler output files are:
data_path=('C:\');
% where to save the table(s)
save_path = ('C:\');
% what to name the table (suggest picking based on thresholds set)
save_name = 'progeny_classification';
% flag to save the tables made (1 = save)
save_tables = 1; 
% set the classification thresholds
    %below this number, the progeny is considered slow;  currently set to
    %8, which is the number of cells at Day 4 a progeny has to have to have
    %even division through the 4th generation:
mid_lower_threshold = 8; 
    %above this number, the progeny is considered high;  currently set to
    %16, which is the number of cells at Day 4 a progeny has to have to have
    %even division through the 5th generation:
mid_upper_threshold = 16;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set things up
if save_tables == 1
mkdir(save_path, save_name);
save_path = fullfile(save_path,[save_name,'\']);
end

Files = dir(fullfile(data_path, '*.mat'));


% make a matrix to fill out lineage information (unknown size) 
progeny_mat = [];
% counter for rows in progeny matrix:
cellcount_all = 1;

    %% start analysis

    for colcount = 1:length(Files)     
    FileName = Files(colcount).name; 
    colony_name_start = strfind(FileName,'T4')+7;
    colony_name_end = strfind(FileName,'.mat')-1;
    colony_underscore_name = cellstr(FileName(1:colony_name_end));
    colony_name = strrep(colony_underscore_name, '_', ' ')
    colony_number = str2double(FileName([2 3 5 6])); 
    % open the CellProfiler output file 
    load(fullfile(data_path, FileName));

    % generate Parent structure
    cell_tracking_figures_for_other_analyses

    %%%%fix Parents.lineage and Parents.descend

    % number of cells at first time point:
    initialcells = length(RealN(1).num);
    % set up a new column in Parents to have the lineage each cell:
    Parents(1).lineage_all = [];

    % go through each cell, starting with the final one and working
    % backward to the starting cells
    for kidcount = size(Parents,2):-1:(initialcells + 1)
       this_parent = Parents(kidcount).parent;
       Parents(this_parent).lineage_all(end+1) = kidcount;
        %do nothing else if this cell doesn't have children:
       if isempty(Parents(kidcount).children) 
       % if this cell DOES have children, add this cell's lineage to
       % its parent's
       else 
        Parents(this_parent).lineage_all = ...
            horzcat(Parents(kidcount).lineage_all,...
            Parents(this_parent).lineage_all);         
       end
    end
    %%%

    %%%tally the number of cells in each progeny for this colony (total and
    %%%at Day 4)
        for cellcount_colony = 1:size(Parents,2)
            if isempty(Parents(cellcount_colony).twin) == 1
                progeny_mat(cellcount_all,1) = colony_number;
                %progeny unique number:
                progeny_mat(cellcount_all,2) = cellcount_colony; 
                %number of cells in progeny (# children + 1):
                progeny_mat(cellcount_all,3) = ...
                    size(Parents(cellcount_colony).lineage_all,2) + 1; 
               
                %number of cells at Day 4
                Day_4_count = 0;
                % for each cell in this starting cell's lineage:
                for cellcount_progeny = ...
                        1:size(Parents(cellcount_colony).lineage_all,2);
                    % if this cell exists at Day 4    
                    if isempty(find(RealN(374).num == Parents(cellcount_colony).lineage_all(cellcount_progeny))) ~= 1
                        Day_4_count = Day_4_count + 1;
                    end
                end
                progeny_mat(cellcount_all,4) = Day_4_count;
                
                % correct for starting cells that never divided:
                if isempty(Parents(cellcount_colony).lineage_all) == 1
                   progeny_mat(cellcount_all,4) = Day_4_count;
                end
                
                
                % classify the progenies as slow (=1), moderate (=2), or
                % fast (=3) dividers
                if progeny_mat(cellcount_all,4) < mid_lower_threshold
                    progeny_mat(cellcount_all,5) = 1;
                elseif progeny_mat(cellcount_all,4) > mid_upper_threshold
                        progeny_mat(cellcount_all,5) = 3;
                else progeny_mat(cellcount_all,5) = 2;                   
                end
                cellcount_all = cellcount_all + 1;
            
            % if this isn't a starting cell, exit the loop    
            else               
                break
            end
        end
    end
%% save as a csv, with and without headers            
 progeny_table = array2table(progeny_mat);           
 progeny_table.Properties.VariableNames = ...
     {'Colony' 'Progeny_Number' 'Number_in_Progeny' 'Number_Cells_Day_4'...
     'Classification'};
 
cd(save_path)
writetable(progeny_table,[fullfile(save_path), save_name '.csv'], 'WriteVariableNames',false);
writetable(progeny_table,[fullfile(save_path), save_name '_with_headers.csv'], 'WriteVariableNames',true);

      