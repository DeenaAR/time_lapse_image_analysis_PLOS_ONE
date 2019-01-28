%% D22 Written by Nina Manning under the supervision of Deena Rennerfeldt

%%
% Calculate the distance of each mitotic event from center of colony and
% makes plots
% Import colony_cell_area.mat as handles & 
% mitotic_events_location.mat as handles2 &
% colony_confluency.csv as a numeric matrix, colonyconfluency

%%%%%%%%%%%%%%%%%%%%%%%%%%%inputs%%%%%%%%%%%%%%%
% specify whether or not to save the figures desired and a path to save
% them to
print_figure = 0; %flag as 1 to save
    save_path = 'C:\';
    colony = 'T45C23';
% change to where you want to save the spreadsheet
cd('C:\');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculates the colony's center
% sets up variables
location_Y_colony = handles.Measurements.expanded_cells.Location_Center_Y;  
location_X_colony = handles.Measurements.expanded_cells.Location_Center_X;
Y_avg_colony = zeros([(length(location_Y_colony)) 1]);
X_avg_colony = zeros([(length(location_X_colony)) 1]);

% iterates through all Y locations and finds the average
for i = 1:length(location_Y_colony) %for each time point
    Y = 0;
    for j = 1:length(location_Y_colony{1,i})
        Y = Y + location_Y_colony{1,i}(j);
    end
    Y = Y/j;
    Y_avg_colony(i,1) = Y;
end

% iterates through all X locations and finds the average
for i = 1:length(location_X_colony)
    X = 0;
    for j = 1:length(location_X_colony{1,i}) 
        X = X + location_X_colony{1,i}(j);
    end
    X = X/j;
    X_avg_colony(i,1) = X;
end

% calculates the average location of mitotic events
% sets up variables
location_Y_mitotic = handles2.Measurements.mitotic_events.Location_Center_Y;
location_X_mitotic = handles2.Measurements.mitotic_events.Location_Center_X;
Y_avg_mitotic = zeros([(length(location_Y_mitotic)) 1]);
X_avg_mitotic = zeros([(length(location_X_mitotic)) 1]);

% iterates through all Y locations and finds the average
for i = 1:length(location_Y_mitotic)
    Y = 0; 
    for j = 1:length(location_Y_mitotic{1,i})
        if isempty(location_Y_mitotic{1,i})
            Y_avg_mitotic(i,1) = 0;
        end
        if length(location_Y_mitotic{1,i}) == 1
            Y_avg_mitotic(i,1) = location_Y_mitotic{1,i}(j);
        end     
        if length(location_Y_mitotic{1,i}) > 1
            Y = Y + location_Y_mitotic{1,i}(j);
            if j == length(location_Y_mitotic{1,i})
                Y = Y/j;
                Y_avg_mitotic(i,1) = Y;
            end
        end      
    end
end

% iterates through all X locations and finds the average
for i = 1:length(location_X_mitotic)
    X = 0; 
    for j = 1:length(location_X_mitotic{1,i})
        if isempty(location_X_mitotic{1,i})
            X_avg_mitotic(i,1) = 0;
        end
        if length(location_X_mitotic{1,i}) == 1
            X_avg_mitotic(i,1) = location_X_mitotic{1,i}(j);
        end        
        if length(location_X_mitotic{1,i}) > 1
            X = X + location_X_mitotic{1,i}(j);
            if j == length(location_X_mitotic{1,i})
                X = X/j;
                X_avg_mitotic(i,1) = X;
            end
        end      
    end
end

% calculates distances of mitotic events to center of colony
% iterates through the average X&Y locations
% if there is no mitotic event, sets to NaN for plotting purposes
% if there is a mitotic event, finds the difference between the coordinates
% by the absolute value of the difference of the colony and mitotic location
for i = 1:length(Y_avg_mitotic)
    if Y_avg_mitotic(i,1) == 0
        Y_avg_differences(i,1) = NaN;
    elseif Y_avg_mitotic(i,1) ~= 0
        Y_avg_differences(i,1) = abs(Y_avg_colony(i,1) - Y_avg_mitotic(i,1));
    end
    if X_avg_mitotic(i,1) == 0
    	X_avg_differences(i,1) = NaN;
    elseif X_avg_mitotic(i,1) ~= 0
    	X_avg_differences(i,1) = abs(X_avg_colony(i,1) - X_avg_mitotic(i,1));
    end
end

% calculates total distances of mitotic events 
% by the square root of the sum of the squares
total_avg_distances = sqrt((Y_avg_differences).^2 + (X_avg_differences).^2);

%% plot avg distances versus confluency

% transposes the colony confluecy so that it is in one column
colony_confluency = transpose(colonyconfluency);
% calculates the colony confluency as a percentage
colony_confluency_percentage = colony_confluency*100;

% plots
figure(1)
scatter(colony_confluency_percentage, total_avg_distances, 36, [0.4 0.0 0.6], 'filled');
title('Colony Confluency vs Avg Distances of Mitotic Events from Center of Colony');
xlabel('Colony Confluency');
ylabel('Avg Distance of Mitotic Events from Center of Colony');

%% plots all distances versus confluency
% sets up variables
Y_all_mitotic = transpose(location_Y_mitotic);
X_all_mitotic = transpose(location_X_mitotic);
% 50 is just an arbitrary number to create a matrix of zeros
% (represents the number of possible mitotic events at one time point)
Y_all_mitotic_matrix = zeros([length(Y_all_mitotic) 50]);
X_all_mitotic_matrix = zeros([length(X_all_mitotic) 50]);

% iterates through Y locations
% if there is no mitotic event, sets to NaN for plotting
% if there is 1 or more mitotic events, saves distance data in 
%   row corresponding to timepoint and in the column corespoinding to number 
%   of mitotic event(s) 
for i = 1:length(Y_all_mitotic)
    for j = 1:length(Y_all_mitotic{i,1})
        if isempty(Y_all_mitotic{i,1})
            Y_all_mitotic_matrix(i,1) = NaN;
        elseif j == 1
            Y_all_mitotic_matrix(i,1) = Y_all_mitotic{i,1}(j);
        elseif j > 1
            Y_all_mitotic_matrix(i,j) = Y_all_mitotic{i,1}(j);
        end
    end
end

% same as above for X locations
for i = 1:length(X_all_mitotic)
    for j = 1:length(X_all_mitotic{i,1})
        if isempty(X_all_mitotic{i,1})
            X_all_mitotic_matrix(i,1) = NaN;
        elseif j == 1
            X_all_mitotic_matrix(i,1) = X_all_mitotic{i,1}(j);
        elseif j > 1
            X_all_mitotic_matrix(i,j) = X_all_mitotic{i,1}(j);
        end
    end
end

% sets up an empty colony_confluency matrix and an empty timepoints matrix 
% based on the size of Y_mitotic_matrix
[m, n] = size(Y_all_mitotic_matrix);
Y_all_differences= zeros([m n]);
X_all_differences = zeros([m n]);
colony_confluency_matrix = zeros([m n]);
timepoints_matrix = zeros([m n]);

% creates an array of timepoints
timepoints = zeros([(length(colony_confluency_percentage)) 1]);
for i = 1:length(colony_confluency_percentage)
    timepoints(i,1) = i;
end

% iterates through X&Y matrixes
% if there is not a mitotic event, sets to NaN
% if there is a mitotic event, calculates the differences in distances and
% also duplicates the confluency for that timepoint in colony_confluency_matrix
for i = 1:m
    for j = 1:n
        if Y_all_mitotic_matrix(i,j) == 0
            Y_all_differences(i,j) = NaN;
            colony_confluency_matrix(i,j) = NaN;
            timepoints_matrix(i,j) = NaN;
        elseif X_all_mitotic_matrix(i,j) ~= 0
            Y_all_differences(i,j) = abs(Y_avg_colony(i,1) - Y_all_mitotic_matrix(i,j));
            colony_confluency_matrix(i,j) = colony_confluency_percentage(i);
            timepoints_matrix(i,j) = timepoints(i);
        end
        if X_all_mitotic_matrix(i,j) == 0
            X_all_differences(i,j) = NaN;
            colony_confluency_matrix(i,j) = NaN;
            timepoints_matrix(i,j) = NaN;
        elseif X_all_mitotic_matrix(i,j) ~= 0
            X_all_differences(i,j) = abs(X_avg_colony(i,1) - X_all_mitotic_matrix(i,j));
            colony_confluency_matrix(i,j) = colony_confluency_percentage(i);
            timepoints_matrix(i,j) = timepoints(i);
        end
   end
end

% calculates the total distances and creates an empty array for the total
% confluency and mitotic events
total_all_distances = sqrt((Y_all_differences).^2 + (X_all_differences).^2);
confluency_all_mitotic_plot = [];

% iterates through the colony_confluency_matrix
% if there is one or more events, saves data in confluency_all_mitotic_plot
% column 1 = confluency
% column 2 = total distances
% column 3 = timepoint
for i = 1:m
    for j = 1:n
        if isnan(colony_confluency_matrix(i,j)) == false
            confluency_all_mitotic_plot(end+1,1) = colony_confluency_matrix(i,j);
            confluency_all_mitotic_plot(end,2) = total_all_distances(i,j);
            confluency_all_mitotic_plot(end,3) = timepoints_matrix(i,j);
        end
    end
end

% plots
figure(2)
scatter(confluency_all_mitotic_plot(:,1), confluency_all_mitotic_plot(:,2), 36, 'b', 'filled')
title('Colony Confluency vs Total Distances of Mitotic Events from Center of Colony');
xlabel('Colony Confluency');
ylabel('Total Distances of Mitotic Events from Center of Colony');

%% plot in a 3d scatter plot confluency, time, avg distances of mitotic events
% from center of colony

% plots
figure(3)
colormap cool
scatter3(confluency_all_mitotic_plot(:,3), confluency_all_mitotic_plot(:,2), confluency_all_mitotic_plot(:,1), 36, confluency_all_mitotic_plot(:,1), 'filled')
title('Colony Confluency vs Total Distances of Mitotic Events from Center of Colony at a Timepoint');
xlabel('Timepoint');
ylabel('Total Distances of Mitotic Events from Colony Center');
zlabel('Colony Confluency');
colorbar('westoutside');

%% plot 2d scatterplot of total distances and colony confluency 
%       with colorbar representing confluency

% plots
dist_plot = figure('Color', [1 1 1]);
cmap = flipud(colormap('bone'));
colormap(cmap);
scatter(confluency_all_mitotic_plot(:,3)/96, confluency_all_mitotic_plot(:,2)*.645, 60, confluency_all_mitotic_plot(:,1), 'filled','MarkerEdgeColor',[0 0 0]);
xlabel('Time (Days)','FontWeight','bold','FontSize',16);
ylabel({'Distance of Mitotic Event'; 'from Colony Center (\mum)'},'FontWeight','bold','FontSize',16);
cbar = colorbar('southoutside');
cbar.Label.String = 'Colony Confluency (%)';

if print_figure == 1
save_name = strcat(colony, '_mitotic_analysis');
cd(save_path)
    print(gcf, save_name, '-dpng', '-r1000');
    savefig(dist_plot,save_name)
end

%% plot timepoints versus confluency

% plots
con_plot = figure('Color', [1 1 1]);
cmap = flipud(colormap('bone'));
colormap(cmap);
scatter(timepoints/96, colony_confluency_percentage, 36, colony_confluency_percentage, 'filled','MarkerEdgeColor',[0 0 0]);
cbar = colorbar('southoutside');
cbar.Label.String = 'Colony Confluency';
xlabel('Time (Days)','FontWeight','bold','FontSize',16);
ylabel('Colony Confluency (%)','FontWeight','bold','FontSize',16);

if print_figure == 1
save_name = strcat(colony, '_confluency');
cd(save_path)
    print(gcf, save_name, '-dpng', '-r1000');
    savefig(con_plot,save_name)
end


%% export a spreadsheet of confluency_all_mitotic_plot

T = table(confluency_all_mitotic_plot(:,1), confluency_all_mitotic_plot(:,2), confluency_all_mitotic_plot(:,3));
T.Properties.VariableNames{'Var1'} = 'ColonyConfluency';
T.Properties.VariableNames{'Var2'} = 'MitoticDistances';
T.Properties.VariableNames{'Var3'} = 'Timepoint';

writetable(T,['confluency_distances_time' colony],'FileType','spreadsheet');

%%
disp('done :)')
