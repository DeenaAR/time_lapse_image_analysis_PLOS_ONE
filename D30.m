%% D30

data_path=('C:\');
% where to save the table(s)
save_path = ('C:\');
% what to name the table
save_name = 'T45C22';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mkdir(save_path, save_name);
save_path = fullfile(save_path,[save_name,'\']);
Files = dir(fullfile(data_path, '*.mat'));

for colcount = 1:length(Files)
    
    % go through the file names in the data folder to determine
    % the colony names and load the data files
    FileName = Files(colcount).name; 
    colony_name_start = strfind(FileName,'T4')+7;
    colony_name_end = strfind(FileName,'.mat')-1;
    colony_underscore_name = cellstr(FileName(1:colony_name_end));
    colony_name = strrep(colony_underscore_name, '_', ' ')
    colony_number = str2double(FileName([2 3 5 6])); 
    
    % open the CellProfiler output file 
    load(fullfile(data_path, FileName));
        
    % call get_all_properties function to make the Data array and the
    % all_array.  Colonies which have a cell disappear require a
    % specialized version of get_all_properties.
    if colony_number == 4536
       get_all_properties_v5_el_square_ball
    elseif colony_number == 4352
       get_all_properties_v5_divine_rapier
    elseif colony_number == 4336
       get_all_properties_v5_super_hashtag_wounded
    else
       get_all_properties_v5
    end
    
    final_time = size(all_array,2);
    
    %set up an array of RGB values (0 to 1) for each generation:
%     color_array = ...
%         {[1 0.396 0.435],... %1st generation color
%         [0.996 0.584 0.360],... %2nd generation
%         [1 0.898 0.415],... %3rd generation
%         [0.627 0.862 0.384],... %4th generation
%         [0.286 0.803 0.956],... %5th generation
%         [0.188 0.435 0.819],... %6th generation
%         [0.631 0.607 0.858]}'; %7th generation
%     %use for Day 7 glyphs:    
    color_array={[255 101 111]/255, [254 125 101]/255, [254 149 92]/255, [254 189 99]/255, [255 229 106]/255, [213 224 102]/255, [160 220 98]/255, [116 212 171]/255, [73 205 244]/255, [60 158 226]/255, [48 111 209]/255};
    
    % create a table for all the cell properties used in the plot:
    glyph_table = [];

    % find max/min coordinate values in raw data at final time point (in px):
    pixel_x_min = ...
        min(handles.Measurements.RelabeledCells.AreaShape_Center_X{1,final_time});
    pixel_x_max = ...
        max(handles.Measurements.RelabeledCells.AreaShape_Center_X{1,final_time});
    pixel_y_min = ...
        min(handles.Measurements.RelabeledCells.AreaShape_Center_Y{1,final_time});
    pixel_y_max = ...
        max(handles.Measurements.RelabeledCells.AreaShape_Center_Y{1,final_time});

    % find the cell properties
    x_final_tmpt = all_array(final_time).AreaShape_Center_X;
    y_final_tmpt = all_array(final_time).AreaShape_Center_Y;    
    area_final_tmpt = all_array(final_time).AreaShape_Area;


    % scale x,y, and area; put in glyph table
    glyph_table(:,1) =  x_final_tmpt;
    % (glyph_x_max - glyph_x_min)*(x_final_tmpt - pixel_x_min)...
    %             /(pixel_x_max - pixel_x_min) + glyph_x_min;

    glyph_table(:,2) =  y_final_tmpt;
    % (glyph_y_max - glyph_y_min)*(y_final_tmpt - pixel_y_min)...
    %     /(pixel_y_max - pixel_y_min) + glyph_y_min;

    glyph_table(:,3) = area_final_tmpt./50;

    glyph_table(:,4) = RealN(final_time).gen;

    % get rid of rows with zeros
    row_delete = [];
    row_delete = find(glyph_table(:,4) == 0);
    glyph_table(row_delete,:) = [];

    % add in the RGB values corresponding to each generation
    cell_colors = color_array(glyph_table(:,4));
    glyph_table(:,5) = cellfun(@(v) v(1), cell_colors(:,:));
    glyph_table(:,6) = cellfun(@(v) v(2), cell_colors(:,:));
    glyph_table(:,7) = cellfun(@(v) v(3), cell_colors(:,:));


    % scale the axes to match all the other colonies
    x_span = pixel_x_max - pixel_x_min;
    y_span = pixel_y_max - pixel_y_min;

    %the ammount of extra axis to add to each side:
    x_padding = (4000 - x_span)/2;
    y_padding = (4000 - y_span)/2;

    % the axes ranges:
    x_axis_min = pixel_x_min - x_padding;
    x_axis_max = pixel_x_max + x_padding;
    y_axis_min = pixel_y_min - y_padding;
    y_axis_max = pixel_y_max + y_padding;



    this_glyph = figure('Color', [1 1 1]);
%     scatter(glyph_table(:,1),glyph_table(:,2), glyph_table(:,3), ...
%         glyph_table(:,5:7),'filled')
    % note: if outlines on data points are desired, use the following:
    scatter(glyph_table(:,1),glyph_table(:,2),glyph_table(:,3),glyph_table(:,5:7),'filled','MarkerEdgeColor',[0 0 0],'LineWidth',0.5)
    axis([x_axis_min x_axis_max y_axis_min y_axis_max])
    title(colony_name)
    set(gcf,'Position',[100 100 820 785])

    figure_name = char(strcat(fullfile(save_path), colony_underscore_name, '_glyph'));
    print(figure_name,'-painters','-dpng','-r1000');

    clear Data RealN Parents glyph_table cell_colors row_delete
    close all

end
%%%%%%
