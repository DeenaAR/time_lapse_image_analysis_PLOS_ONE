%% D15 
% performs PCA for a folder of CellProfiler output files by utilizing 
% D11-D14. 
%% outline
%%% pooled cells%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Max area time pointpooled_max_area_normalized_gen
%   PCA, not z-scored
%       colored by k-means clusters
%       colored by generation
%       colored by colony
%   PCA, z-scored
%       colored by k-means clusters
%       colored by generation
%       colored by colony
%   scree plots
%       not z-scored
%       z-scored
% Birth time point
%   PCA, not z-scored
%       colored by k-means clusters
%       colored by generation
%       colored by colony
%   PCA, z-scored
%       colored by k-means clusters
%       colored by generation
%       colored by colony
%   scree plots
%       not z-scored
%       z-scored
% Averaged properties (all time points)
%   PCA, not z-scored
%       colored by k-means clusters
%       colored by generation
%       colored by colony
%   PCA, z-scored
%       colored by k-means clusters
%       colored by generation
%       colored by colony
%   scree plots
%       not z-scored
%       z-scored
%%% individual colonies%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Birth time point (YES I KNOW I SWITCHED THE ORDER) :P
%   PCA, not z-scored
%       colored by k-means clusters
%       colored by generation
%   PCA, z-scored
%       colored by k-means clusters
%       colored by generation
%   scree plots
%       not z-scored
%       z-scored
% Max area time point
%   PCA, not z-scored
%       colored by k-means clusters
%       colored by generation
%   PCA, z-scored
%       colored by k-means clusters
%       colored by generation
%   scree plots
%       not z-scored
%       z-scored
% Averages
%   PCA, not z-scored
%       colored by k-means clusters
%       colored by generation
%   PCA, z-scored
%       colored by k-means clusters
%       colored by generation
%   scree plots
%       not z-scored
%       z-scored



%% PCA
%%%%% caveats
%  relies on generation being the 85th column in the PCA input grids
%  relies on colony number being the last column in the raw data
%  must run combine_PCAgrids.m, which has its own set of inputs (can
%       specify below)
%%%%%

%%%combine_PCAgrids.m inputs%%%%%%%
base_path='C:\';
% specify date stamp (MM-DD-YY)
date_stamp = '6-2-17';
% specify path to CellProfiler output files
data_path='C:\';
% specify the color matrix (R, G, and B are the 1st, 2nd, and 3rd columns,
% respectively.  Values must be 0 to 1.

%color scheme 7 generations:
gen_colors(:,1) = [1	0.996	1	0.627	0.286	0.188	0.631]; 
gen_colors(:,2) = [0.396	0.584	0.898	0.862	0.803	0.435	0.607];
gen_colors(:,3) = [0.435	0.36	0.415	0.384	0.956	0.819	0.858];    
 
%color scheme 11 generations:
% gen_colors(:,1) = [255/255	254/255	254/255	254/255 255/255	213/255 160/255 116/255 73/255 60/255 48/255]; 
% gen_colors(:,2) = [101/255	125/255	149/255	189/255 229/255	224/255 220/255 212/255 205/255 158/255 111/255];
% gen_colors(:,3) = [111/255	101/255	92/255	99/255 106/255	102/255 98/255 171/255 244/255 226/255 209/255];  

% specify the marker size for the plots.  note that scatter and gscatter
% have different values for the same-sized marker.  Currently the marker
% size in scatter plots is twice that of gscatter markers.
marker_size = 20;

%flag to remove certain variables
remove_var = 1;
    
    % if removing, specify the column numbers to eliminate:
    deleted_variables = [7	15	18	20	22	24 26 27 28	32	34	35	46	51	54	62	64	66	67	68	69	70	71	73 75 76	78	80 81 82	85 87];
    %normally generation is the 85th column, but if columns are removed it
    %will be different: 
    generation_column = 85; 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

combine_PCAgrids

%%%%more inputs%%%%
% go to the folder with all the PCA input grids:
startpath = fullfile(base_path, char(date_stamp));
savefigures = 1;  %flag to save all figures

%%%%%%%%%%%%%%

% make a subfolder to put all the plots in:
mkdir(startpath, 'plots');
plotpath = fullfile(startpath, 'plots');

mkdir(plotpath, 'scree_plots');
mkdir(plotpath, 'pooled_cells');
mkdir(plotpath, 'colonies');

%% Start with pooled cell data
cd(startpath);
%%%% grid of all properties at maximum area time point:
pooled_max_raw_data = csvread('PCA_input_max_area_time_point.csv');

%not sure this is needed...I think combine_PCAgrids already does this:
pooled_max_raw_data(isnan(pooled_max_raw_data)) = 0; %***consider using 'Rows', 'complete' as name pair values: http://www.mathworks.com/help/stats/pca.html#bti6r20-1 

%find the generation of the cells
generation_vector = pooled_max_raw_data(:,generation_column);
num_generations=length(unique(generation_vector));
generation_legend = {'1st generation', '2nd generation', '3rd generation',...
    '4th generation', '5th generation', '6th generation', '7th generation',...
    '8th generation', '9th generation', '10th generation','11th generation'};

%find the colony of the cells
colony_vector = pooled_max_raw_data(:,end);
num_colonies=length(unique(colony_vector));
colony_legend = cell(1,num_colonies);


%remove superfluous variables:
if remove_var ==1
    pooled_max_raw_data(:,deleted_variables) = [];
end


num_cells = size(pooled_max_raw_data,1);  
num_variables = size(pooled_max_raw_data,2);
gen_legend_vector = cell(num_cells,1);
col_legend_vector = cell(num_cells,1);
% before z-scoring:
% (scores are observations, coeffs are variables):
[coeff,score,latent] = pca(pooled_max_raw_data);
first_two_PCs = [score(:,1),score(:,2)];

max_area_PCA_coeff = [];
max_area_PCA_coeff(:,1) = coeff(:,1);
max_area_PCA_coeff(:,2) = coeff(:,2);

%determine the number of clusters for k-means clustering:
num_clusters = round(sqrt(num_cells/2));
[cidx2,~] = kmeans(first_two_PCs,num_clusters,'dist','sqeuclidean');


% make/save PCA plot colored by cluster:
pooled_max_PCA = figure('Color', [1 1 1]);
    for i = 1:num_clusters
        clust = find(cidx2==i);
        scatter(first_two_PCs(clust,1),first_two_PCs(clust,2),marker_size*4,'.');
        hold on
    end     
    title('pooled, k-means clustered; t = max area',...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(pooled_max_PCA,[fullfile(plotpath, ...
                'pooled_cells/pooled_max_area_k-means')],'-dpng', '-r0');
        end
        
% make/save PCA plot colored by generation

pooled_max_PCA_gen = figure('Color', [1 1 1]);
    % group by generation:
    for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
    end
    gscatter(first_two_PCs(:,1),first_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
    title('pooled, grouped by generation; t = max area','FontWeight',...
        'bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(pooled_max_PCA_gen,[fullfile(plotpath, ...
                'pooled_cells/pooled_max_area_generation')],'-dpng', '-r1000');
        end
        
% % make/save PCA plot colored by colony

Files = dir(fullfile('1st_time_point', '*.csv'));

 for colcount = 1:num_colonies
    FileName = Files(colcount).name; 
    % go through the file names in the 1st_time_point folder to determine
    % the colony names
    colony_name_start = strfind(FileName,'T4')+7;
    colony_name_end = strfind(FileName,'_PCAgrid')-1;
    colony_underscore_name = cellstr(FileName(1:colony_name_end));
    colony_name = strrep(colony_underscore_name, '_', ' ');
    colony_number = str2double(FileName([2 3 5 6])); 
    % make a list of the colony names for the legend used later:
    colony_legend(colcount) = colony_name;
    colony_number_legend(colcount) = colony_number;
    % find all the cells belonging to this colony number:
    col = find(colony_vector==colony_number);
    col_legend_vector(col,1) = colony_legend(colcount);
 end
 pooled_max_PCA_col = figure('Color', [1 1 1]);
 gscatter(first_two_PCs(:,1),first_two_PCs(:,2),col_legend_vector, colorcube,'.',marker_size);
 title({'pooled, grouped by colony;' 't = max area'},'FontWeight',...
        'bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(pooled_max_PCA_col,fullfile(plotpath, ...
                'pooled_cells/pooled_max_area_colony'),'-dpng', '-r0');
        end
     
        
% z-score max area time point data:
zscore_max_area = zscore(pooled_max_raw_data);
[z_coeff,z_score,z_latent] = pca(zscore_max_area);
zfirst_two_PCs = [z_score(:,1),z_score(:,2)];

[zcidx2,zcmeans2] = kmeans(zfirst_two_PCs,num_clusters,'dist','sqeuclidean');

z_pooled_max_PCA = figure('Color', [1 1 1]);
    for i = 1:num_clusters
            zclust = find(zcidx2==i);
            scatter(zfirst_two_PCs(zclust,1),zfirst_two_PCs(zclust,2),marker_size*4,'.');
            hold on
    end     
    title('pooled, normalized, k-means clustered; t = max area',...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(z_pooled_max_PCA,fullfile(plotpath, ...
                'pooled_cells/pooled_max_area_normalized_k-means'),...
                '-dpng', '-r0');
        end
  % get PC coefficients:
  max_area_PCA_coeff(:,3) = z_coeff(:,1);
  max_area_PCA_coeff(:,4) = z_coeff(:,2);
  max_area_PCA_coeff = array2table(max_area_PCA_coeff);
  max_area_PCA_coeff.Properties.VariableNames = {'PC1' 'PC2' ...
      'PC1_normalized' 'PC2_normalized'};
  
  max_area_property_names = property_names;
  max_area_property_names{end+1,1} = 'max_area_time_point';
  max_area_property_names{end+1,1} = 'colony_number';
  
  if remove_var == 1
     max_area_property_names(deleted_variables,:) = [];
  end

  max_area_PCA_coeff.Properties.RowNames = max_area_property_names;
  writetable(max_area_PCA_coeff,'max_area_PCA_coeff.csv', ...
      'WriteRowNames',true)

  % group by generation:
   zpooled_max_PCA_gen = figure('Color', [1 1 1]); 
   gscatter(zfirst_two_PCs(:,1),zfirst_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
   title({'pooled, normalized, grouped by generation;'; 't = max area'},...
       'FontWeight','bold','FontSize',16)
   ylabel('PC2','FontWeight','bold','FontSize',16)
   xlabel('PC1','FontWeight','bold','FontSize',16)
   legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(zpooled_max_PCA_gen,fullfile(plotpath, ...
                'pooled_cells/pooled_max_area_normalized_generation'),...
                '-dpng', '-r1000');
        end
     % group by colony:
   zpooled_max_PCA_col = figure('Color', [1 1 1]); 
   gscatter(zfirst_two_PCs(:,1),zfirst_two_PCs(:,2),col_legend_vector, colorcube,'.',marker_size);
   title({'pooled, normalized, grouped by colony;'; 't = max area'},...
       'FontWeight','bold','FontSize',16)
   ylabel('PC2','FontWeight','bold','FontSize',16)
   xlabel('PC1','FontWeight','bold','FontSize',16)
   legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(zpooled_max_PCA_col,fullfile(plotpath, ...
                'pooled_cells/pooled_max_area_normalized_colony'),...
                '-dpng', '-r1000');
        end
   
        
%%% make scree plots
cumulative_variance = zeros(size(latent,1),2);
cumulative_variance(:,1) = 1:size(latent,1);
cumulative_variance(:,2) = cumsum(latent)./sum(latent)*100;
scree_pooled_max = figure('Color', [1 1 1]);
bar(cumulative_variance(1:10,1),cumulative_variance(1:10,2))
title('pooled; t = max area','FontWeight','bold','FontSize',16)
    ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
        'FontSize',16)
    xlabel('Principal Component','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(scree_pooled_max,[fullfile(plotpath, ...
                'scree_plots/pooled_max_area')],'-dpng', '-r0');
        end
        
% z-score:
zcumulative_variance = zeros(size(latent,1),2);
zcumulative_variance(:,1) = 1:size(latent,1);
zcumulative_variance(:,2) = cumsum(z_latent)./sum(z_latent)*100;

% scree plot of normalized PCs
z_scree_pooled_max = figure('Color', [1 1 1]);
bar(zcumulative_variance(1:10,1),zcumulative_variance(1:10,2))
title('pooled, normalized; t = max area','FontWeight','bold','FontSize',16)
    ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
        'FontSize',16)
    xlabel('Principal Component','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(z_scree_pooled_max,fullfile(plotpath,...
                'scree_plots/pooled_max_area_normalized'),'-dpng', '-r0');
        end
  
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%% grid of all properties at birth (1st) time point:
pooled_1st_raw_data = csvread('PCA_input_1st_time_point.csv');
pooled_1st_raw_data(isnan(pooled_1st_raw_data)) = 0;

%remove superfluous variables:
if remove_var ==1
    pooled_1st_raw_data(:,deleted_variables) = [];
end

%%% before z-scoring:
% (scores are observations, coeffs are variables):
[coeff,score,latent] = pca(pooled_1st_raw_data);
first_two_PCs = [score(:,1),score(:,2)];

%start the coefficient table
birth_tmpt_PCA_coeff = [];
birth_tmpt_PCA_coeff(:,1) = coeff(:,1);
birth_tmpt_PCA_coeff(:,2) = coeff(:,2);

%determine the number of clusters for k-means clustering:
num_clusters = round(sqrt(num_cells/2));
[cidx2,~] = kmeans(first_two_PCs,num_clusters,'dist','sqeuclidean');

% make/save PCA plot colored by cluster:
pooled_1st_PCA = figure('Color', [1 1 1]);
    for i = 1:num_clusters
        clust = find(cidx2==i);
        scatter(first_two_PCs(clust,1),first_two_PCs(clust,2),marker_size*4,'.');
        hold on
    end     
    title('pooled, k-means clustered; t = 1st time point',...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(pooled_1st_PCA,fullfile(plotpath, ...
                'pooled_cells/pooled_1st_tmpt_k-means'),'-dpng', '-r0');
        end
        
pooled_1st_PCA_gen = figure('Color', [1 1 1]);
    % group by generation:
    for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
    end
    gscatter(first_two_PCs(:,1),first_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
    title({'pooled, grouped by generation;';'t = 1st time point'},...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(pooled_1st_PCA_gen,[fullfile(plotpath, ...
                'pooled_cells/pooled_1st_tmpt_generation')],'-dpng', '-r1000');
        end
        
% % make/save PCA plot colored by colony
Files = dir(fullfile('1st_time_point', '*.csv'));
% colony_legend = cell(1,num_colonies);

 pooled_1st_PCA_col = figure('Color', [1 1 1]);
 gscatter(first_two_PCs(:,1),first_two_PCs(:,2),col_legend_vector, colorcube,'.',marker_size);
 title({'pooled, grouped by colony;' 't = 1st time point'},'FontWeight',...
        'bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(pooled_1st_PCA_col,fullfile(plotpath, ...
                'pooled_cells/pooled_1st_tmpt_colony'),'-dpng', '-r0');
        end
         
%%% z-score:
zscore_1st_area = zscore(pooled_1st_raw_data);
[z_coeff,z_score,z_latent] = pca(zscore_1st_area);
zfirst_two_PCs = [z_score(:,1),z_score(:,2)];
 
% get PC coefficients:
  birth_tmpt_PCA_coeff(:,3) = z_coeff(:,1);
  birth_tmpt_PCA_coeff(:,4) = z_coeff(:,2);
  birth_tmpt_PCA_coeff = array2table(birth_tmpt_PCA_coeff);
  birth_tmpt_PCA_coeff.Properties.VariableNames = {'PC1' 'PC2' ...
      'PC1_normalized' 'PC2_normalized'};
  birth_tmpt_property_names = max_area_property_names;
  birth_tmpt_PCA_coeff.Properties.RowNames = max_area_property_names;
  writetable(birth_tmpt_PCA_coeff,'1st_tmpt_PCA_coeff.csv', ...
      'WriteRowNames',true)

[zcidx2,~] = kmeans(zfirst_two_PCs,num_clusters,'dist','sqeuclidean');

z_pooled_1st_PCA = figure('Color', [1 1 1]);
    for i = 1:num_clusters
            zclust = find(zcidx2==i);
            scatter(zfirst_two_PCs(zclust,1),zfirst_two_PCs(zclust,2),marker_size*4,'.');
            hold on
    end     
    title({'pooled, normalized, k-means clustered;';'t = 1st time point'},...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(z_pooled_1st_PCA,fullfile(plotpath,...
                'pooled_cells/pooled_1st_tmpt_normalized_k-means'),...
                '-dpng', '-r0');
        end
  % group by generation:
   zpooled_1st_PCA_gen = figure('Color', [1 1 1]); 
   gscatter(zfirst_two_PCs(:,1),zfirst_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
   title({'pooled, normalized, grouped by generation;'; ...
       't = 1st time point'},'FontWeight','bold','FontSize',16)
   ylabel('PC2','FontWeight','bold','FontSize',16)
   xlabel('PC1','FontWeight','bold','FontSize',16)
   legend('location','eastoutside')
       if savefigures==1
           set(gcf,'Position',[100 100 700 500])
           print(zpooled_1st_PCA_gen,fullfile(plotpath, ...
               'pooled_cells/pooled_1st_tmpt_normalized_generation'),...
               '-dpng', '-r1000');
       end
   % group by colony:
   zpooled_1st_PCA_col = figure('Color', [1 1 1]); 
   gscatter(zfirst_two_PCs(:,1),zfirst_two_PCs(:,2),col_legend_vector, colorcube,'.',marker_size);
   title({'pooled, normalized, grouped by colony;'; 't = 1st time point'},...
       'FontWeight','bold','FontSize',16)
   ylabel('PC2','FontWeight','bold','FontSize',16)
   xlabel('PC1','FontWeight','bold','FontSize',16)
   legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(zpooled_1st_PCA_col,fullfile(plotpath, ...
                'pooled_cells/pooled_1st_tmpt_normalized_colony'),...
                '-dpng', '-r0');
        end
        
%%% make scree plots
cumulative_variance = zeros(size(latent,1),2);
cumulative_variance(:,1) = 1:size(latent,1);
cumulative_variance(:,2) = cumsum(latent)./sum(latent)*100;
scree_pooled_1st = figure('Color', [1 1 1]);
bar(cumulative_variance(1:10,1),cumulative_variance(1:10,2))
title('pooled; t = 1st time point','FontWeight','bold','FontSize',16)
    ylabel('Cumulative Variance Represented (%)','FontWeight',...
        'bold','FontSize',16)
    xlabel('Principal Component','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(scree_pooled_1st,fullfile(plotpath,...
                'scree_plots/pooled_1st_tmpt'),'-dpng', '-r0');
        end
        
% z-score:
zcumulative_variance = zeros(size(latent,1),2);
zcumulative_variance(:,1) = 1:size(latent,1);
zcumulative_variance(:,2) = cumsum(z_latent)./sum(z_latent)*100;

% scree plot of normalized PCs
z_scree_pooled_1st = figure('Color', [1 1 1]);
bar(zcumulative_variance(1:10,1),zcumulative_variance(1:10,2))
title('pooled, normalized; t = 1st time point','FontWeight','bold',...
    'FontSize',16)
    ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
        'FontSize',16)
    xlabel('Principal Component','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(z_scree_pooled_1st,fullfile(plotpath, ...
                'scree_plots/pooled_1st_tmpt_normalized'),'-dpng', '-r0');
        end   
               
%%%%% averages %%%%%%%%%%%%%
pooled_avg_raw_data = csvread('PCA_input_averages.csv');
pooled_avg_raw_data(isnan(pooled_avg_raw_data)) = 0;

%remove superfluous variables:
if remove_var ==1
    pooled_avg_raw_data(:,deleted_variables) = [];
end

%%% before z-scoring:
% (scores are observations, coeffs are variables):
[coeff,score,latent] = pca(pooled_avg_raw_data);
first_two_PCs = [score(:,1),score(:,2)];

%start the coefficient table
averages_PCA_coeff = [];
averages_PCA_coeff(:,1) = coeff(:,1);
averages_PCA_coeff(:,2) = coeff(:,2);



%determine the number of clusters for k-means clustering:
num_clusters = round(sqrt(length(pooled_avg_raw_data)/2));
[cidx2,cmeans2] = kmeans(first_two_PCs,num_clusters,'dist','sqeuclidean');

% make/save PCA plot colored by cluster:
pooled_avg_PCA = figure('Color', [1 1 1]);
    for i = 1:num_clusters
        clust = find(cidx2==i);
        scatter(first_two_PCs(clust,1),first_two_PCs(clust,2),marker_size*4,'.');
        hold on
    end     
    title('pooled, k-means clustered; averaged properties',...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(pooled_avg_PCA,fullfile(plotpath, ...
                'pooled_cells/pooled_average_k-means'),'-dpng', '-r0');
        end
        
pooled_avg_PCA_gen = figure('Color', [1 1 1]);
    % group by generation:
    for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
    end
    gscatter(first_two_PCs(:,1),first_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
    title({'pooled, grouped by generation;';'averaged properties'},...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(pooled_avg_PCA_gen,[fullfile(plotpath, ...
                'pooled_cells/pooled_average_generation')],'-dpng', '-r0');
        end
        
% % make/save PCA plot colored by colony
 Files = dir(fullfile('averages', '*.csv'));
 pooled_avg_PCA_col = figure('Color', [1 1 1]);
 gscatter(first_two_PCs(:,1),first_two_PCs(:,2),col_legend_vector, colorcube,'.',marker_size);
 title({'pooled, grouped by colony;' 'averaged properties'},'FontWeight',...
        'bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(pooled_avg_PCA_col,fullfile(plotpath, ...
                'pooled_cells/pooled_average_colony'),'-dpng', '-r0');
        end
         
%%% z-score:
zscore_avg = zscore(pooled_avg_raw_data);
[z_coeff,z_score,z_latent] = pca(zscore_avg);
zfirst_two_PCs = [z_score(:,1),z_score(:,2)];

% get PC coefficients:
  averages_PCA_coeff(:,3) = z_coeff(:,1);
  averages_PCA_coeff(:,4) = z_coeff(:,2);
  averages_PCA_coeff = array2table(averages_PCA_coeff);
  averages_PCA_coeff.Properties.VariableNames = {'PC1' 'PC2' ...
      'PC1_normalized' 'PC2_normalized'};
  averages_property_names = max_area_property_names;
  averages_PCA_coeff.Properties.RowNames = max_area_property_names;
  writetable(averages_PCA_coeff,'averages_PCA_coeff.csv', ...
      'WriteRowNames',true)


[zcidx2,zcmeans2] = kmeans(zfirst_two_PCs,num_clusters,'dist','sqeuclidean');

z_pooled_avg_PCA = figure('Color', [1 1 1]);
    for i = 1:num_clusters
            zclust = find(zcidx2==i);
            scatter(zfirst_two_PCs(zclust,1),zfirst_two_PCs(zclust,2),marker_size*4,'.');
            hold on
    end     
    title({'pooled, normalized, k-means clustered;';'averaged properties'},...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(z_pooled_avg_PCA,fullfile(plotpath,...
                'pooled_cells/pooled_average_normalized_k-means'),...
                '-dpng', '-r0');
        end
  % group by generation:
   zpooled_avg_PCA_gen = figure('Color', [1 1 1]); 
   gscatter(zfirst_two_PCs(:,1),zfirst_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
   title({'pooled, normalized, grouped by generation;'; ...
       'averaged properties'},'FontWeight','bold','FontSize',16)
   ylabel('PC2','FontWeight','bold','FontSize',16)
   xlabel('PC1','FontWeight','bold','FontSize',16)
   legend('location','eastoutside')
       if savefigures==1
           set(gcf,'Position',[100 100 700 500])
           print(zpooled_avg_PCA_gen,fullfile(plotpath, ...
               'pooled_cells/pooled_average_normalized_generation'),...
               '-dpng', '-r1000');
       end
   % group by colony:
   zpooled_avg_PCA_col = figure('Color', [1 1 1]); 
   gscatter(zfirst_two_PCs(:,1),zfirst_two_PCs(:,2),col_legend_vector, colorcube,'.',marker_size);
   title({'pooled, normalized, grouped by colony;'; 'averaged properties'},...
       'FontWeight','bold','FontSize',16)
   ylabel('PC2','FontWeight','bold','FontSize',16)
   xlabel('PC1','FontWeight','bold','FontSize',16)
   legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(zpooled_avg_PCA_col,fullfile(plotpath, ...
                'pooled_cells/pooled_average_normalized_colony'),...
                '-dpng', '-r0');
        end
        
%%% make scree plots
cumulative_variance = zeros(size(latent,1),2);
cumulative_variance(:,1) = 1:size(latent,1);
cumulative_variance(:,2) = cumsum(latent)./sum(latent)*100;
scree_pooled_avg = figure('Color', [1 1 1]);
bar(cumulative_variance(1:10,1),cumulative_variance(1:10,2))
title('pooled; averaged properties','FontWeight','bold','FontSize',16)
    ylabel('Cumulative Variance Represented (%)','FontWeight',...
        'bold','FontSize',16)
    xlabel('Principal Component','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(scree_pooled_avg,fullfile(plotpath,...
                'scree_plots/pooled_average'),'-dpng', '-r0');
        end
        
% z-score:
zcumulative_variance = zeros(size(latent,1),2);
zcumulative_variance(:,1) = 1:size(latent,1);
zcumulative_variance(:,2) = cumsum(z_latent)./sum(z_latent)*100;

% scree plot of normalized PCs
z_scree_pooled_1st = figure('Color', [1 1 1]);
bar(zcumulative_variance(1:10,1),zcumulative_variance(1:10,2))
title('pooled, normalized; averaged properties','FontWeight','bold',...
    'FontSize',16)
    ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
        'FontSize',16)
    xlabel('Principal Component','FontWeight','bold','FontSize',16)
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(z_scree_pooled_1st,fullfile(plotpath, ...
                'scree_plots/pooled_average_normalized'),'-dpng', '-r0');
        end   
       
    
 %save tables containing the information about what variables were removed:       
 deleted_variables_table = array2table(property_names(deleted_variables,1));
 writetable(deleted_variables_table,'deleted_variables.xlsx','WriteVariableNames',false); 
 
 kept_variables_table = array2table(max_area_property_names);
 writetable(kept_variables_table,'kept_variables.xlsx','WriteVariableNames',false);
  
        

%% PCA for individual colonies

% birth time point
cd('1st_time_point');
Files = dir('*.csv');
for colcount = 1:num_colonies
    FileName = Files(colcount).name; 
    % go through the file names in the 1st_time_point folder to determine
    % the colony names
    colony_name_start = strfind(FileName,'T4')+7;
    colony_name_end = strfind(FileName,'_PCAgrid')-1;
    colony_underscore_name = cellstr(FileName(1:colony_name_end));
    colony_name = strrep(colony_underscore_name, '_', ' ');
    colony_number = str2double(FileName([2 3 5 6])); 
    
    % open the PCA input file and change NaNs to 0s
    colony_raw_data = csvread(FileName);
    colony_raw_data(isnan(colony_raw_data)) = 0;

    generation_vector = colony_raw_data(:,generation_column);
    num_generations=length(unique(generation_vector));
    num_cells = size(colony_raw_data,1);  
    gen_legend_vector = cell(num_cells,1);
    col_legend_vector = cell(num_cells,1);

    if remove_var == 1
    colony_raw_data(:,deleted_variables) = [];
    end
    
    [coeff,score,latent] = pca(colony_raw_data);
    first_two_PCs = [score(:,1),score(:,2)];

%  go to this directory to save the plots:
cd ../plots/colonies;
    
% %determine the number of clusters for k-means clustering:
    num_clusters = round(sqrt(num_cells/2));
    [cidx2,~] = kmeans(first_two_PCs,num_clusters,...
        'dist','sqeuclidean');
    % make/save PCA plot colored by cluster:
    colony_1st_PCA = figure('Color', [1 1 1]);
        for i = 1:num_clusters
            clust = find(cidx2==i);
            scatter(first_two_PCs(clust,1),first_two_PCs(clust,2),marker_size*4,'.');
            hold on
        end     
        title([char(colony_name), ', k-means clustered; t = 1st time point'],...
            'FontWeight','bold','FontSize',16)
        ylabel('PC2','FontWeight','bold','FontSize',16)
        xlabel('PC1','FontWeight','bold','FontSize',16)
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(colony_1st_PCA,fullfile([char(colony_underscore_name)...
                    '_1st_tmpt_k-means']),'-dpng', '-r0');
            end
            
    % group by generation:
    for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
    end
    
    col_1st_PCA_gen = figure('Color', [1 1 1]);
    gscatter(first_two_PCs(:,1),first_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
    title({[char(colony_name)];['grouped by generation;'];['t = 1st time point']},...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(col_1st_PCA_gen,fullfile([char(colony_underscore_name)...
                    '_1st_tmpt_gen']),'-dpng', '-r0');
        end
        
        
    %z-score
    zscore_col_1st = zscore(colony_raw_data);
    [z_coeff,z_score,z_latent] = pca(zscore_col_1st);
    zfirst_two_PCs = [z_score(:,1),z_score(:,2)];
    
    %k-means cluster
    num_clusters = round(sqrt(size(colony_raw_data,1)/2));
    [zcidx2,zcmeans2] = kmeans(zfirst_two_PCs,num_clusters,...
        'dist','sqeuclidean');
    z_colony_1st_PCA = figure('Color', [1 1 1]);
        for i = 1:num_clusters
            clust = find(zcidx2==i);
            scatter(zfirst_two_PCs(clust,1),zfirst_two_PCs(clust,2),marker_size*4,'.');
            hold on
        end     
        title({[char(colony_name)];['k-means clustered, normalized'];...
            ['t = 1st time point']},'FontWeight','bold','FontSize',16)
        ylabel('PC2','FontWeight','bold','FontSize',16)
        xlabel('PC1','FontWeight','bold','FontSize',16)
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(z_colony_1st_PCA,fullfile([char(colony_underscore_name)...
                    '_1st_tmpt_k-means_normalized']),'-dpng', '-r0');
            end
            
    %color by generation
    for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
    end
    
    z_colony_1st_PCA_gen = figure('Color', [1 1 1]);
    gscatter(zfirst_two_PCs(:,1),zfirst_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
    title({[char(colony_name)];['grouped by generation, normalized'];...
        ['t = 1st time point']},'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(z_colony_1st_PCA_gen,fullfile([char(colony_underscore_name)...
                    '_1st_tmpt_gen_normalized']),'-dpng', '-r0');
        end
 
    %%% make scree plots
    % not z-scored:
    cumulative_variance = zeros(size(latent,1),2);
    cumulative_variance(:,1) = [1:length(latent)];
    cumulative_variance(:,2) = cumsum(latent)./sum(latent)*100;
    scree_colony_1st = figure('Color', [1 1 1]);
    bar(cumulative_variance(1:10,1),cumulative_variance(1:10,2))
    title({[char(colony_name)];['t = 1st time point']},...
        'FontWeight','bold','FontSize',16)
        ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
            'FontSize',16)
        xlabel('Principal Component','FontWeight','bold','FontSize',16)
        cd ../scree_plots
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(scree_colony_1st,...
                    fullfile([char(colony_underscore_name) '_1st_tmpt']),...
                    '-dpng', '-r0');
            end
    % z-scored      
    z_cumulative_variance = zeros(size(latent,1),2);
    z_cumulative_variance(:,1) = [1:length(z_latent)];
    z_cumulative_variance(:,2) = cumsum(z_latent)./sum(z_latent)*100;
    z_scree_colony_1st = figure('Color', [1 1 1]);
    bar(z_cumulative_variance(1:10,1),z_cumulative_variance(1:10,2))
    title({[char(colony_name)];['t = 1st time point'];['normalized']},...
        'FontWeight','bold','FontSize',16)
        ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
            'FontSize',16)
        xlabel('Principal Component','FontWeight','bold','FontSize',16)
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(z_scree_colony_1st,...
                    fullfile([char(colony_underscore_name)...
                    '_1st_tmpt_normalized']), '-dpng', '-r0');
            end     
    
    cd ../../1st_time_point;
end    
 
  
% max area time point
cd ../max_area_time_point;
Files = dir('*.csv');
for colcount = 1:num_colonies
    FileName = Files(colcount).name; 
    % go through the file names in the 1st_time_point folder to determine
    % the colony names
    colony_name_start = strfind(FileName,'T4')+7;
    colony_name_end = strfind(FileName,'_PCAgrid')-1;
    colony_underscore_name = cellstr(FileName(1:colony_name_end));
    colony_name = strrep(colony_underscore_name, '_', ' ');
    colony_number = str2double(FileName([2 3 5 6])); 
    % open the PCA input file and change NaNs to 0s
    colony_raw_data = csvread(FileName);
    colony_raw_data(isnan(colony_raw_data)) = 0;
    [coeff,score,latent] = pca(colony_raw_data);
    first_two_PCs = [score(:,1),score(:,2)];

%  go to this directory to save the plots:
cd ../plots/colonies;
    
% %determine the number of clusters for k-means clustering:
    num_clusters = round(sqrt(size(colony_raw_data,1)/2));
    [cidx2,cmeans2] = kmeans(first_two_PCs,num_clusters,...
        'dist','sqeuclidean');
    % make/save PCA plot colored by cluster:
    colony_max_PCA = figure('Color', [1 1 1]);
        for i = 1:num_clusters
            clust = find(cidx2==i);
            scatter(first_two_PCs(clust,1),first_two_PCs(clust,2),marker_size*4,'.');
            hold on
        end
        title({[char(colony_name)];['k-means clustered'];['t = max area time point']},...
        'FontWeight','bold','FontSize',16)
        ylabel('PC2','FontWeight','bold','FontSize',16)
        xlabel('PC1','FontWeight','bold','FontSize',16)
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(colony_max_PCA,fullfile([char(colony_underscore_name)...
                    '_max_area_tmpt_k-means']),'-dpng', '-r0');
            end
    % group by generation:
    generation_vector = colony_raw_data(:,85);
    num_cells = length(generation_vector);
    num_generations=length(unique(generation_vector));
    gen_legend_vector = cell(num_cells,1);
    for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
    end
    
    col_max_area_PCA_gen = figure('Color', [1 1 1]);
    gscatter(first_two_PCs(:,1),first_two_PCs(:,2),gen_legend_vector, gen_colors,'.',marker_size);
    title({[char(colony_name)];['grouped by generation;'];['t = max area time point']},...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(col_max_area_PCA_gen,fullfile([char(colony_underscore_name)...
                    '_max_area_tmpt_gen']),'-dpng', '-r0');
        end
        
    %z-score
    zscore_col_max = zscore(colony_raw_data);
    [z_coeff,z_score,z_latent] = pca(zscore_col_max);
    zfirst_two_PCs = [z_score(:,1),z_score(:,2)];
    %k-means cluster
    num_clusters = round(sqrt(size(colony_raw_data,1)/2));
    [zcidx2,zcmeans2] = kmeans(zfirst_two_PCs,num_clusters,...
        'dist','sqeuclidean');
    z_colony_max_PCA = figure('Color', [1 1 1]);
        for i = 1:num_clusters
            clust = find(zcidx2==i);
            scatter(zfirst_two_PCs(clust,1),zfirst_two_PCs(clust,2),marker_size*4,'.');
            hold on
        end     
        title({[char(colony_name)];['k-means clustered, normalized'];...
            ['t = max area time point']},'FontWeight','bold','FontSize',16)
        ylabel('PC2','FontWeight','bold','FontSize',16)
        xlabel('PC1','FontWeight','bold','FontSize',16)
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(z_colony_max_PCA,fullfile([char(colony_underscore_name)...
                    '_max_area_tmpt_k-means_normalized']),'-dpng', '-r0');
            end
    %color by generation    
    gen_legend_vector = cell(num_cells,1);
    for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
    end
    
    z_colony_max_PCA_gen = figure('Color', [1 1 1]);
    gscatter(zfirst_two_PCs(:,1),zfirst_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
    title({[char(colony_name)];['grouped by generation, normalized'];...
        ['t = max area time point']},'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(z_colony_max_PCA_gen,fullfile([char(colony_underscore_name)...
                    '_max_area_tmpt_gen_normalized']),'-dpng', '-r0');
        end


 
    %%% make scree plots
    % not z-scored:
    cumulative_variance = zeros(size(latent,1),2);
    cumulative_variance(:,1) = [1:length(latent)];
    cumulative_variance(:,2) = cumsum(latent)./sum(latent)*100;
    scree_colony_max = figure('Color', [1 1 1]);
    bar(cumulative_variance(1:10,1),cumulative_variance(1:10,2))
    title({[char(colony_name)];['t = max area time point']},...
        'FontWeight','bold','FontSize',16)
        ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
            'FontSize',16)
        xlabel('Principal Component','FontWeight','bold','FontSize',16)
        cd ../scree_plots
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(scree_colony_max,...
                    fullfile([char(colony_underscore_name) '_max_area_tmpt']),...
                    '-dpng', '-r0');
            end
    % z-scored      
    z_cumulative_variance = zeros(size(latent,1),2);
    z_cumulative_variance(:,1) = [1:length(z_latent)];
    z_cumulative_variance(:,2) = cumsum(z_latent)./sum(z_latent)*100;
    z_scree_colony_max = figure('Color', [1 1 1]);
    bar(z_cumulative_variance(1:10,1),z_cumulative_variance(1:10,2))
    title({[char(colony_name)];['t = max area time point'];['normalized']},...
        'FontWeight','bold','FontSize',16)
        ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
            'FontSize',16)
        xlabel('Principal Component','FontWeight','bold','FontSize',16)
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(z_scree_colony_max,...
                    fullfile([char(colony_underscore_name)...
                    '_max_area_tmpt_normalized']), '-dpng', '-r0');
            end     
    
    cd ../../max_area_time_point;
end    
      
   
% averages
cd ../averages;
Files = dir('*.csv');
for colcount = 1:num_colonies
    FileName = Files(colcount).name; 
    % go through the file names in the 1st_time_point folder to determine
    % the colony names
    colony_name_start = strfind(FileName,'T4')+7;
    colony_name_end = strfind(FileName,'_PCAgrid')-1;
    colony_underscore_name = cellstr(FileName(1:colony_name_end));
    colony_name = strrep(colony_underscore_name, '_', ' ');
    colony_number = str2double(FileName([2 3 5 6])); 
    % open the PCA input file and change NaNs to 0s
    colony_raw_data = csvread(FileName);
    colony_raw_data(isnan(colony_raw_data)) = 0;
    [coeff,score,latent] = pca(colony_raw_data);
    first_two_PCs = [score(:,1),score(:,2)];

%  go to this directory to save the plots:
cd ../plots/colonies;
    
% %determine the number of clusters for k-means clustering:
    num_clusters = round(sqrt(size(colony_raw_data,1)/2));
    [cidx2,cmeans2] = kmeans(first_two_PCs,num_clusters,...
        'dist','sqeuclidean');
    % make/save PCA plot colored by cluster:
    colony_avg_PCA = figure('Color', [1 1 1]);
        for i = 1:num_clusters
            clust = find(cidx2==i);
            scatter(first_two_PCs(clust,1),first_two_PCs(clust,2),marker_size*4,'.');
            hold on
        end
        title({[char(colony_name)];['k-means clustered'];['averaged properties']},...
        'FontWeight','bold','FontSize',16)
        ylabel('PC2','FontWeight','bold','FontSize',16)
        xlabel('PC1','FontWeight','bold','FontSize',16)
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(colony_avg_PCA,fullfile([char(colony_underscore_name)...
                    '_average_k-means']),'-dpng', '-r0');
            end
    % group by generation:
    generation_vector = colony_raw_data(:,85);
    num_cells = length(generation_vector);
    num_generations=length(unique(generation_vector));
    gen_legend_vector = cell(num_cells,1);
    for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
    end
    
    col_avg_PCA_gen = figure('Color', [1 1 1]);
    gscatter(first_two_PCs(:,1),first_two_PCs(:,2),gen_legend_vector,gen_colors,'.',marker_size);
    title({[char(colony_name)];['grouped by generation;'];['averaged properties']},...
        'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')

        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(col_avg_PCA_gen,fullfile([char(colony_underscore_name)...
                    '_average_gen']),'-dpng', '-r0');
        end
        
    %z-score
    zscore_col_max = zscore(colony_raw_data);
    [z_coeff,z_score,z_latent] = pca(zscore_col_max);
    zfirst_two_PCs = [z_score(:,1),z_score(:,2)];
    %k-means cluster
    num_clusters = round(sqrt(size(colony_raw_data,1)/2));
    [zcidx2,zcmeans2] = kmeans(zfirst_two_PCs,num_clusters,...
        'dist','sqeuclidean');
    z_colony_avg_PCA = figure('Color', [1 1 1]);
        for i = 1:num_clusters
            clust = find(zcidx2==i);
            scatter(zfirst_two_PCs(clust,1),zfirst_two_PCs(clust,2),marker_size*4,'.');
            hold on
        end     
        title({[char(colony_name)];['k-means clustered, normalized'];...
            ['averaged properties']},'FontWeight','bold','FontSize',16)
        ylabel('PC2','FontWeight','bold','FontSize',16)
        xlabel('PC1','FontWeight','bold','FontSize',16)
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(z_colony_avg_PCA,fullfile([char(colony_underscore_name)...
                    '_average_k-means_normalized']),'-dpng', '-r0');
            end
    %color by generation    
    gen_legend_vector = cell(num_cells,1);
    for i = 1:num_generations
        gen = find(generation_vector==i);
        gen_legend_vector(gen,1) = (generation_legend(i));
    end
    
    z_colony_avg_PCA_gen = figure('Color', [1 1 1]);
    gscatter(zfirst_two_PCs(:,1),zfirst_two_PCs(:,2),gen_legend_vector, gen_colors,'.',marker_size);
    title({[char(colony_name)];['grouped by generation, normalized'];...
        ['averaged properties']},'FontWeight','bold','FontSize',16)
    ylabel('PC2','FontWeight','bold','FontSize',16)
    xlabel('PC1','FontWeight','bold','FontSize',16)
    legend('location','eastoutside')
        if savefigures==1
            set(gcf,'Position',[100 100 700 500])
            print(z_colony_avg_PCA_gen,fullfile([char(colony_underscore_name)...
                    '_average_gen_normalized']),'-dpng', '-r0');
        end


 
    %%% make scree plots
    % not z-scored:
    cumulative_variance = zeros(size(latent,1),2);
    cumulative_variance(:,1) = [1:length(latent)];
    cumulative_variance(:,2) = cumsum(latent)./sum(latent)*100;
    scree_colony_avg = figure('Color', [1 1 1]);
    bar(cumulative_variance(1:10,1),cumulative_variance(1:10,2))
    title({[char(colony_name)];['averaged properties']},...
        'FontWeight','bold','FontSize',16)
        ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
            'FontSize',16)
        xlabel('Principal Component','FontWeight','bold','FontSize',16)
        cd ../scree_plots
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(scree_colony_avg,...
                    fullfile([char(colony_underscore_name) '_average']),...
                    '-dpng', '-r0');
            end
    % z-scored      
    z_cumulative_variance = zeros(length(z_latent),2);
    z_cumulative_variance(:,1) = [1:length(z_latent)];
    z_cumulative_variance(:,2) = cumsum(z_latent)./sum(z_latent)*100;
    z_scree_colony_avg = figure('Color', [1 1 1]);
    bar(z_cumulative_variance(1:10,1),z_cumulative_variance(1:10,2))
    title({[char(colony_name)];['average'];['normalized']},...
        'FontWeight','bold','FontSize',16)
        ylabel('Cumulative Variance Represented (%)','FontWeight','bold',...
            'FontSize',16)
        xlabel('Principal Component','FontWeight','bold','FontSize',16)
            if savefigures==1
                set(gcf,'Position',[100 100 700 500])
                print(z_scree_colony_avg,...
                    fullfile([char(colony_underscore_name)...
                    'average_normalized']), '-dpng', '-r0');
            end     
    
    cd ../../averages;
end  
 
if savefigures == 1
    close all
end
