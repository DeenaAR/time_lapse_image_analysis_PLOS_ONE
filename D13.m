%% D13
% Constructs input matricies for PCA.  In each PCAgrid, the cells are rows, and 
% the columns are values for each property found in the all_array.  
%
% written by Deena Rennerfeldt
%
% Requires D12 and D11

% adds birth time point to end

% Grid descriptions:
% PCAgrid_1st_time_point: properties of all the cells at the time point of
% their birth.

% PCAgrid_max_area_time_point: properties of all the cells at time point of
% their maximum area (over the course of their lifetime).

% PCAgrid_averages: averages of property values for each cell over all time
% points it existed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%load a CP output file 
% Run get_all_properties, which uses getdata and constructs the all_array.   
 if colony_number == 4536
           get_all_properties_v5_el_square_ball
        elseif colony_number == 4352
           get_all_properties_v5_divine_rapier
        elseif colony_number == 4336
           get_all_properties_v5_super_hashtag_wounded
        else
           get_all_properties_v5
 end

%% 1st time point
PCAgrid_1st_time_point = zeros(total_cells, length(fieldnames(all_array))+1);

for timecount1=1:timepts  %for each time point
    
    %if this is the first time point, then enter the properties for the 
    %starting cells:    
    if timecount1==1 
        for cellcount1 = 1:total_cells %for each cell that ever existed
            % if the cell exists in the first time point 
            % (i.e., has nonzero value for area):
            if all_array(1).AreaShape_Area(cellcount1) ~=0 
                %then fill out each property for that cell:
                for propertycount1 = 1:length(property_names)
                    PCAgrid_1st_time_point(cellcount1,propertycount1)=...
                    all_array(1).(property_names{propertycount1})...
                    (cellcount1);
                end
                PCAgrid_1st_time_point(cellcount1,length(property_names)+1)=1;
            end
        end
    end
    
    % for all but the first time point, fill out the properties of each
    % cell at the time of its birth:
    if timecount1 ~=1 
       for cellcount2 = 1:total_cells   % for each cell
           % if the value for this cell's area was 0 in the previous time 
           % point and isn't 0 in this time point:
           if all_array(timecount1-1).AreaShape_Area(cellcount2)== 0 && ... 
                   all_array(timecount1).AreaShape_Area(cellcount2)...
                   ~=0
               %then fill out each property for that cell:
               for propertycount2 = 1:length(fieldnames(all_array))
                   PCAgrid_1st_time_point(cellcount2,propertycount2)=...
                   all_array(timecount1).(property_names{propertycount2})...
                   (cellcount2);  
               end
            % enter the "birth time point" in the next available column (FIX THIS):   
            PCAgrid_1st_time_point(cellcount2,(length(property_names)+1))=timecount1;
           end
       end
    end
 
end

% Replace all NaN with 0:
PCAgrid_1st_time_point(isnan(PCAgrid_1st_time_point)) = 0;


%% Maximum area time point
PCAgrid_max_area_time_point = zeros(total_cells, ...
    length(fieldnames(all_array))+1);

% create a table containing the areas of each cell
cell_area_table=zeros(timepts,total_cells);
clear cellcount
clear timecount
for timecount = 1:timepts
    for cellcount = 1:total_cells
        cell_area_table(timecount,cellcount)= all_array(timecount)...
        .AreaShape_Area(cellcount);
    end
end

% make a vector of the time point at which a cell is in it's maximum area
max_time_point_table=zeros(total_cells,1);

clear cellcount
clear timecount

for cellcount=1:total_cells
    [value,row] = max(cell_area_table(:,cellcount));
    max_time_point_table(cellcount,1) = row; %time point at max size
end


clear cellcount
clear propertycount
for cellcount=1:total_cells % for each cell
    for propertycount = 1:length(fieldnames(all_array)) % for each property
        %fill out the property at the time point of the cell's max area:
        PCAgrid_max_area_time_point(cellcount,propertycount) = ...
            all_array(max_time_point_table(cellcount))...
            .(property_names{propertycount})(cellcount);
    end
end
% Add the time point at max area to the PCA grid:
PCAgrid_max_area_time_point(:,(length(property_names)+1))=max_time_point_table(:,1);
% Replace all NaN with 0:
PCAgrid_max_area_time_point(isnan(PCAgrid_max_area_time_point)) = 0;


%% Average values over all time points
PCAgrid_averages = zeros(total_cells, ...
    length(fieldnames(all_array))); %+1 probably not needed

clear cellcount timecount propertycount propertycount2

for cellcount =1:total_cells    %for each cell, make a temporary new
% table; time is rows, property is columns:
    temp_property_table = zeros(timepts,size(PCAgrid_averages,2));
        for timecount = 1:timepts %for each time point
            for propertycount =1:size(PCAgrid_averages,2) %look at each property
                temp_property_table(timecount,propertycount) = ...
                    all_array(timecount).(property_names{propertycount})(cellcount);
            end
        end
        temp_property_table(isnan(temp_property_table)) = 0;
        for propertycount2=1:size(PCAgrid_averages,2)
        this_property = temp_property_table(:,propertycount2); %variable to take the mean of
        PCAgrid_averages(cellcount,propertycount2) = mean(this_property(this_property~=0));
        end
end
%eliminate the NaNs:        
PCAgrid_averages(isnan(PCAgrid_averages)) = 0;

%add birth time point:
PCAgrid_averages(:,propertycount2+1) = PCAgrid_1st_time_point(:,size(PCAgrid_1st_time_point,2));
