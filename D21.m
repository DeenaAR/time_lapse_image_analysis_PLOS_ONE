%% D21

%make scatter plots of possibly-correlating properties 
%%%%%%%%%%inputs%%%%%%%%%%%%%%%%%%%%
% folder where the csv file is:
Data_Folder='C:\';
% not an input:
cd(Data_Folder)
% csv file name:
All_Data=csvread('zero_progeny.csv');
property_names = readtable('no_filters_property_names.csv','ReadVariableNames',false);
%column the generation property belongs to:
generation_column = 20;
% colors of the generations, for some reason in reverse order.  Can't
% contain generations that don't exist for a specific dataset.

    % for all 7 generations:
    generation_colors = vertcat([1 0.396 0.435],[0.996 0.584 0.360],[1 0.898 0.415],...
        [0.627 0.862 0.384],[0.286 0.803 0.956],[0.188 0.435 0.819],[0.631 0.607 0.858]);

    % for no first generation:
%     generation_colors = vertcat([0.996 0.584 0.360],[1 0.898 0.415],...
%     [0.627 0.862 0.384],[0.286 0.803 0.956],[0.188 0.435 0.819],[0.631 0.607 0.858]);

savefigures=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sort the data matrix by generation:
All_Data = sortrows(All_Data,generation_column);
generation_vector = All_Data(:,generation_column);

%info/legend for coloring by generation
num_cells=length(All_Data);
num_generations=max(generation_vector);
real_generation_colors = generation_colors(unique(generation_vector),:);

gen_legend_vector = cell(num_cells,1);
generation_legend = {'1st generation', '2nd generation', '3rd generation',...
    '4th generation', '5th generation', '6th generation', '7th generation'};

mkdir(Data_Folder, 'plots');
Plot_Folder = fullfile(Data_Folder, 'plots');
property_names_spaces = table2array(property_names);
property_names_spaces = strrep(property_names_spaces,'_',' '); 
property_names = table2array(property_names);
for Xcount = 1:(size(All_Data,2)-1)
    for Ycount = (Xcount+1):size(All_Data,2)
        X = All_Data(:,Xcount);
        Y = All_Data(:,Ycount);
        Xproperty = property_names_spaces(Xcount,1);
        Yproperty = property_names_spaces(Ycount,1);
        
        this_figure = figure('Color', [1 1 1]);
        for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
        end
        gscatter(X,Y,gen_legend_vector, generation_colors);
        title([Yproperty ' vs ' Xproperty],'FontWeight','bold','FontSize',16)
        ylabel(Yproperty,'FontWeight','bold','FontSize',16)
        xlabel(Xproperty,'FontWeight','bold','FontSize',16)
        legend('location','eastoutside')
        if savefigures==1
            set(gcf,'Position',[100 100 700 500]);
            X_underscore_property = property_names{Xcount,1};
            Y_underscore_property = property_names{Ycount,1};
            plot_name = strcat(Y_underscore_property, '_vs_', X_underscore_property);
            print(this_figure,fullfile(Plot_Folder,plot_name),'-dpng', '-r0');
            close all
        end
    end
end

      
        