%% D32 Written by Nina Manning under the supervision of Deena Rennerfeldt
%% Create cell lineage tree
% creates a cell lineage tree based off Cell IDs, division times, and
% parents
%
close all 
% clear all

%% TODO Set Up
% loading excel file of Cell IDs, Parents,and Birth Timepts and
% loading csv of area information with Cell ID and area before division 10
% timepoints

% path where the files are located
% pathway = 'D:\Trial_9-4\time_lapse_LIA\Joana\time_lapse\Colony_18';
% name of the primary file
primaryfilename = 'C18_LIA_worksheet.xlsx';
% name of the files with area information
% areabefore_filename = 'areas_before.csv';
areaafter_filename = 'C18.csv';
number_timepts = 759; % replace if different

% flag to save the figures
save = false;
save_name = 'T94C18_thick';
% specify the resolotion in the form '-r#', where # is the resolution and
% the single quotes are needed
resolution = '-r500';

%%
% changes directory
cd(pathway);
% reads in files
[~, ~, original_data] = xlsread(primaryfilename);
% area_before = csvread(areabefore_filename);
area_after = csvread(areaafter_filename);
%% Formatting Data
% converts labeling system from padded image numbers to timepoints
% removes unnecessary info from xlsx file
% stores info in cell_info array
% cell_info(:,1) is the cell id
% cell_info(:,2) is the cell's parent
% cell_info(:,3) is the cell's birth timepoint
% cell_info(:,4) is the cell's division timepoint
% cell_info(:,5) is the parent's area before division 10timepts prior
% cell_info(:,6) is the cell's generation
% cell_info(:,7) is the cell's y-coordinate for plotting
% cell_info(:,8) is the cell's y-factor for scaling in plotting
% cell_info(:,9) is the cell's area 10 timepoints after birth
% cell_info(:,10) is whether the cell crawls out of view and timepoint
% cell_info(:,11) is the cell's lifetime (*technically,the number of time
% points analyzed for that cell, as not all cells divide, etc.)
% cell_info(:,12) is whether the cell dies and timepoint

% extracting info from original_data and 
% converting from cell arrary to ordinary array (all one type)
cell_ids = cell2mat(original_data(2:end,1));
parents = cell2mat(original_data(2:end,2));

% converting image names into timepoints using function convertImageNames
birth_times = string(original_data(2:end,3));
birth_times = convertImageNames(birth_times);
crawls_off = string(original_data(2:end,4));
crawls_off = convertImageNames(crawls_off);
dies = string(original_data(2:end,5));
dies = convertImageNames(dies);

% enumerates the Cell IDs in order, in a column vector
cell_info = (1:1:max(cell_ids))';

% adds parent's Cell ID and birth time to the correct Cell ID in cell_info
for i = 1:length(cell_ids)
    cell_info(cell_ids(i),2) = parents(i);
    cell_info(cell_ids(i),3) = birth_times(i);
    cell_info(cell_ids(i),10) = crawls_off(i);
    cell_info(cell_ids(i),12) = dies(i);
end

% Adding division time to cell_info(:,4)
for i = 2:length(parents)
    cell_info(parents(i),4) = birth_times(i);
end

% % % Adding parent's area before division to cell_info(:,5)
% % for i = 1:length(area_before(:,1))
% %     cell_info(cell_info(:,2)==area_before(i,1),5) = area_before(i,2);
% % end

% Adding cell's area after birth to cell_info(:,9)
for i = 1:length(area_after(:,1))
    cell_info(cell_info(:,1)==area_after(i,1),9) = area_after(i,2);
end


% for cells that crawl off, die, or don't divide
for i = 1:length(cell_info(:,1))
    if cell_info(i,4) == 0 && cell_info(i,10) == 0 && cell_info(i,12) == 0
        cell_info(i,4) = number_timepts; % cells that don't divide
    elseif cell_info(i,4) == 0 && cell_info(i,10) ~= 0
        cell_info(i,4) = cell_info(i,10); % cells that crawl off
    elseif cell_info(i,4) == 0 && cell_info(i,12) ~= 0
        cell_info(i,4) = cell_info(i,12); % cells that die
    end
end

% sorts according to birth time
cell_info = sortrows(cell_info,3);

% labeling generation, cell_info(:,6)
generation = 1;
cell_info(1,6) = generation; % first cell is generation 1
for i = 2:length(cell_info(:,1))
    parent = cell_info(i,2);
    % generation is parent's generation + 1
    cell_info(i,6) = cell_info(cell_info(:,1)==parent,6)+1;
end

% number of cells in each generation
cells_generation = zeros(max(cell_info(:,6)),1); % initializes array
for i = 1:max(cell_info(:,6))
    % sums # of cells in each generation
    cells_generation(i,1) = sum(cell_info(:,6)==i);
end

% y-coordinates and vertical bars for plotting
% y-coordinate is cell_info(:,7)
% the y-factor is a scaling factor
% y_factor is cell_info(:,8)
vertical_bars = zeros(length(cell_info(:,1)),3); % initializes array
ymax = 10000; % range for plotting, can adjust if necessary
cell_info(1,7) = ymax/2; % first y-coordinate is half the range
for i = 2:length(cell_info(:,1))
    
    % initial scaling factor
    y_factor = ymax/(cells_generation(cell_info(i,6),1)*1.75);
    cell_info(i,8) = y_factor; % adds y-factor to the cell_info array
    
    % current parent's info
    parents_ycoord = cell_info(cell_info(:,1)==cell_info(i,2),7);
    parents_yfact = cell_info(cell_info(:,1)==cell_info(i,2),8);
    
    % adjusting y-factor according to generation
    % if second generation, 
    % increases width of branches relative to original y-factor
    if cell_info(i,6) == 2 
        y_factor = ymax/3.5;    
    % below are adjustments to the y-factor for more recent generations,
    % when the plot starts to become crowded, it decreaseds the width of 
    % which branches are added, may be adjusted if necessary
    elseif cell_info(i,6) > 6 % sixth generation decreased by 1/3
        y_factor = parents_yfact/3;
    elseif cell_info(i,6) > 7 % seventh generation decreased by 1/5
        y_factor = parents_yfact/5;
    elseif cell_info(i,6) > 8 % eigth generation decreased by 1/7
        y_factor = parents_yfact/7;
    elseif cell_info(i,6) > 9 % ninth generation decreased by 1/9
        y_factor = parents_yfact/9;
    end
    
    % if the Cell ID is even, it becomes the first branch from the parent 
    % on the lineage tree
    if mod(cell_info(i,1),2) == 0
        cell_info(i,7) = parents_ycoord + y_factor;
        vertical_bars(i,1) = cell_info(i,7);
        vertical_bars(i,3) = cell_info(i,3);
        
    % if the Cell ID is odd, it becomes the second branch from the parent
    % on the lineage tree
    elseif mod(cell_info(i,1),2) ~= 0
        cell_info(i,7) = parents_ycoord - y_factor;
        vertical_bars(i-1,2) = cell_info(i,7);
    end
end
% vertical_bars ends up in a weird format with the relavent
% information only in every other row, and the rest 0s
% so sets 0s to NaNs for plotting
vertical_bars(vertical_bars(:)==0) = NaN;

%% Plotting

% RGB color values
colors = {[255 101 111]/255, [254 125 101]/255, [254 149 92]/255, [254 189 99]/255, [255 229 106]/255, [213 224 102]/255, [160 220 98]/255, [116 212 171]/255, [73 205 244]/255, [60 158 226]/255, [48 111 209]/255, [104 111 209]/255, [161 155 219]/255, [219 219 227]/255};

% this is a good plot for quickly checking if the original excel file was
% done correctly, each node should only have two branches
% binary tree
node_plot = figure('Color', [1 1 1]);
nodes(cell_info(:,1)) = cell_info(:,2); 
treeplot(nodes)
if save
    set(node_plot,'Position',[100 50 1800 1000]) 
    print(fullfile(pathway, strcat(save_name, '_nodes')), '-dpng', resolution)
end

% lineage tree without area information
tree_plot = figure('Color', [1 1 1]);
for i = 1:length(cell_info(:,1))
    % horizontal line for lifespan of a cell
    plot([cell_info(i,7) cell_info(i,7)], [cell_info(i,3)/96 cell_info(i,4)/96], 'color', colors{cell_info(i,6)},'LineWidth',2);
    hold on
    % vertical line for divisions on the tree 
    plot([vertical_bars(i,1) vertical_bars(i,2)], [vertical_bars(i,3)/96 vertical_bars(i,3)/96], 'color', colors{cell_info(i,6)});
    hold on
end
% title('Cell Lineage Tree');
% xlabel('Cell');
ylabel('Time (Days)');
set ( gca, 'ydir', 'reverse', 'xtick',[] ) % reverse y-axis
axis([-1500 ymax+1500 0 number_timepts/96+0.5]);
hold off

if save
    set(tree_plot,'Position',[100 50 1800 1000]) 
    print(fullfile(pathway, strcat(save_name, '_no_area')), '-dpng', resolution)
end


% lineage tree with area before information
% figure
% for i = 1:length(cell_info(:,1))
%    
%     % area shapes
%     if mod(i,2) == 0 && i < 261
%         % average y coordinate of the vertical bar
%         ave_y = (vertical_bars(i,1)+vertical_bars(i,2))/2;
%         % bottom left 'corner' of shape
%         bottom_l = [ave_y-cell_info(i,5)/50 vertical_bars(i,3)/100-0.2-cell_info(i,5)/20000];
%         % dimensions based off of area of parent 10 before division
%         dim = [cell_info(i,5)/25 cell_info(i,5)/15000];
%         % plotting shape
%         % 'cur', [0 0] is rectangular
%         % 'cur', [1 1] is circular
%         rectangle('Position', [bottom_l(1) bottom_l(2) dim(1) dim(2)],'cur', [1 1], 'facecolor', colors{cell_info(i,6)}, 'edgecolor', colors{cell_info(i,6)});
%         hold on
%     end    
%     
%     % horizontal line for lifespan of a cell
%     plot([cell_info(i,7) cell_info(i,7)], [cell_info(i,3)/100 cell_info(i,4)/100], 'color', colors{cell_info(i,6)});
%     hold on
%     
%     % vertical line for divisions on the tree 
%     plot([vertical_bars(i,1) vertical_bars(i,2)], [vertical_bars(i,3)/100 vertical_bars(i,3)/100], 'color', colors{cell_info(i,6)});
%     hold on
% end
% title('Cell Lineage Tree W/ Parents Area Before Birth');
% xlabel('Cell');
% ylabel('Time (Days)');
% set ( gca, 'ydir', 'reverse' ) % reverse y-axis
% axis([-1500 ymax+1500 0 number_timepts/100+0.5]);
% hold off

% lineage tree with area after information
area_plot = figure('Color', [1 1 1]);
for i = 1:length(cell_info(:,1))
   
    % area shapes
    if cell_info(i,9) ~= 0
        % y coordinate of the cell
        ycoor = cell_info(i,7);
        % bottom left 'corner' of shape
        bottom_l = [ycoor-cell_info(i,9)/40 cell_info(i,3)/96+0.05];
        % dimensions based off of area of cell 10 timepts after birth
        dim = [cell_info(i,9)/20 cell_info(i,9)/15000];
        % plotting shape
        % 'cur', [0 0] is rectangular
        % 'cur', [1 1] is circular
        rectangle('Position', [bottom_l(1) bottom_l(2) dim(1) dim(2)],'cur', [1 1], 'facecolor', colors{cell_info(i,6)}, 'edgecolor', colors{cell_info(i,6)});
        hold on
    end    
    
    % horizontal line for lifespan of a cell
    plot([cell_info(i,7) cell_info(i,7)], [cell_info(i,3)/96 cell_info(i,4)/96], 'color', colors{cell_info(i,6)});
    hold on
    
    % vertical line for divisions on the tree 
    plot([vertical_bars(i,1) vertical_bars(i,2)], [vertical_bars(i,3)/96 vertical_bars(i,3)/96], 'color', colors{cell_info(i,6)});
    hold on
end
% title('Cell Lineage Tree W/ Area After Birth');
% xlabel('Cell');
ylabel('Time (Days)');
set ( gca, 'ydir', 'reverse' ) % reverse y-axis
axis([-1500 ymax+1500 0 number_timepts/96+0.5]);
hold off

if save
    set(area_plot,'Position',[100 50 1800 1000]) 
    print(fullfile(pathway, strcat(save_name, '_with_area')), '-dpng', resolution)   
end

% save spreadsheet of cell_info
csvwrite(fullfile(pathway,'cell_lineage_data.csv'),cell_info)

%% Functions

% convertImageNames
% converts padded_names into timepoints
function timepts = convertImageNames(padded_names)
timepts = zeros(length(padded_names),1);
for i = 1:length(padded_names)
    id = strsplit(padded_names(i),'_');
    switch id(1)
        case '2x2'
            timepts(i) = str2double(id(2));
        case '2x2a'
            timepts(i) = str2double(id(2));
        case '3x3' 
            timepts(i) = str2double(id(2)) + 185;
        case '3x3a' 
            timepts(i) = str2double(id(2)) + 185;
        case '4x4' 
            timepts(i) = str2double(id(2)) + 185 + 95;
        case '4x4a' 
            timepts(i) = str2double(id(2)) + 185 + 95;
        case '5x5a'
            timepts(i) = str2double(id(2)) + 185 + 95 + 382;
        case '5x5b'
            timepts(i) = str2double(id(2)) + 185 + 95 + 382 + 5;
        case '5x5c'
            timepts(i) = str2double(id(2)) + 185 + 95 + 382 + 5 + 82;
    end
end
end