%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Looks for correlations of interest (defined by coefficient_threshold and
% pval_threshold) in a table of variables (columns) and observations
% (rows).  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

%%%%%inputs%%%%%
% folder where the csv file is:
Data_Folder='C:\';
% not an input:
cd(Data_Folder)
% csv file name:
All_Data=csvread('5_and_6.csv');
% p value desired (p < ?):
pval_threshold = 0.05;
% table of property names (should be in data folder)
property_names = readtable('no_filters_property_names.csv','ReadVariableNames',false);
% correlation coefficient desired (coeff > ?):
coefficient_threshold = 0.6;
%%%%%%%%%%%%%%%%

% get the property names 
property_names = table2array(property_names);
%%%%%% more inputs %%%%%%
%add property names that were added (optional; comment out if not)
% property_names{87,1} = 'birth_time_point'; %time point PCAgrid_input was taken
% property_names{end+1,1} = 'colony_number';
%%%%%%%%%%%%%%%%%%%%%%%%%

%% To make one pairwise comparison:
% (The .csv file must only contain numeric values:counter2)
% Divide_Data=csvread('max_size_number_descendants_no_senescence.csv');
% X = Divide_Data(:,1);
% Y = Divide_Data(:,2);
% [Pearson_RHO,Pearson_PVAL] = corr(X,Y,'type','Pearson')
% [Spearman_RHO,Spearman_PVAL] = corr(X,Y,'type','Spearman')

%% To make several comparisons
% replace NaNs with 0s
All_Data(isnan(All_Data)) = 0;
% tables of correlation coefficients and p values:
Spearman_table = zeros(size(All_Data,2),size(All_Data,2));
Spearman_pval_table = zeros(size(All_Data,2),size(All_Data,2));
Pearson_table = zeros(size(All_Data,2),size(All_Data,2));
Pearson_pval_table = zeros(size(All_Data,2),size(All_Data,2));
 
 for counter1 = 1:size(All_Data,2) 
     for counter2 = 1:size(All_Data,2)
         X = All_Data(:,counter2);
         Y = All_Data(:,counter1);
         [Pearson_RHO,Pearson_PVAL] = corr(X,Y,'type','Pearson');
         Pearson_table(counter1,counter2) = Pearson_RHO;
         Pearson_pval_table(counter1,counter2) = Pearson_PVAL;
         [Spearman_RHO,Spearman_PVAL] = corr(X,Y,'type','Spearman');
         Spearman_table(counter1,counter2) = Spearman_RHO;
         Spearman_pval_table(counter1,counter2) = Spearman_PVAL;
     end
 end
 % find correlates of interest
 Spearman_correlativescount = 1;
 Pearson_correlativescount = 1;
 Spearman_correlatives_keep = cell(100,4);
 Pearson_correlatives_keep = cell(100,4);
 
 for columncount = 1:size(All_Data,2)
     for rowcount = 1:size(All_Data,2)
         if Spearman_pval_table(rowcount,columncount)<pval_threshold && abs(Spearman_table(rowcount,columncount))>coefficient_threshold;
            Spearman_correlatives_keep{Spearman_correlativescount,1} = property_names(rowcount,1);
            Spearman_correlatives_keep{Spearman_correlativescount,2} = property_names(columncount,1);
            Spearman_correlatives_keep{Spearman_correlativescount,3} = Spearman_table(rowcount,columncount);
            Spearman_correlatives_keep{Spearman_correlativescount,4} = Spearman_pval_table(rowcount,columncount);
            
            Spearman_correlativescount = Spearman_correlativescount + 1;
         end
         if Pearson_pval_table(rowcount,columncount)<pval_threshold && abs(Pearson_table(rowcount,columncount))>coefficient_threshold
            Pearson_correlatives_keep{Pearson_correlativescount,1} = property_names(rowcount,1);
            Pearson_correlatives_keep{Pearson_correlativescount,2} = property_names(columncount,1);
            Pearson_correlatives_keep{Pearson_correlativescount,3} = Pearson_table(rowcount,columncount);
            Pearson_correlatives_keep{Spearman_correlativescount,4} = Pearson_pval_table(rowcount,columncount);
            
            Pearson_correlativescount = Pearson_correlativescount + 1;
         end
     end
 end
 
%  *sigh* This is to remove instances of variables correlating with each
%  other, since I can't get the "unique" function to work
% clear rowcount
% 
Spearman_correlatives_keep = cell2table(Spearman_correlatives_keep);
% this is a matrix of rows that are duplicates; the first row always has a
% duplicate:
Spearman_delete(1,1) = 1;
property1 = [];
property2 = [];
comparison_table = Spearman_correlatives_keep(:,1:2);
comparison_table = table2cell(comparison_table);
for rowcount = 2:size(Spearman_correlatives_keep,1)
   property1 = comparison_table{rowcount,1};
   property2 = comparison_table{rowcount,2};
    if strcmp(property1,property2) == 1
        Spearman_delete(1,end+1) = rowcount;
    end
end
%eliminate the duplicates:
Spearman_correlatives_keep(Spearman_delete,:) = [];

clear property1 property2 comparison_table
%now for the Pearson table:
Pearson_correlatives_keep = cell2table(Pearson_correlatives_keep);
% this is a matrix of rows that are duplicates; the first row always has a
% duplicate:
Pearson_delete(1,1) = 1;
property1 = [];
property2 = [];
comparison_table = Pearson_correlatives_keep(:,1:2);
comparison_table = table2cell(comparison_table);

for rowcount = 2:size(Pearson_correlatives_keep,1)
     property1 = comparison_table{rowcount,1};
     property2 = comparison_table{rowcount,2};
    if strcmp(property1,property2) == 1
        Pearson_delete(1,end+1) = rowcount;
    end
end
%eliminate the duplicates:
Pearson_correlatives_keep(Pearson_delete,:) = [];

%% make pretty and save
% Spearman_correlatives_keep=array2table(Spearman_correlatives_keep);
Spearman_correlatives_keep.Properties.VariableNames = {'Variable' 'Correlating_Variable' 'Spearman_Coefficient' 'p_Value'};
% Pearson_correlatives_keep=array2table(Pearson_correlatives_keep);
Pearson_correlatives_keep.Properties.VariableNames = {'Variable' 'Correlating_Variable' 'Pearson_Coefficient' 'p_Value'};

%saaaave. 
% writetable(Spearman_correlatives_keep,'test_Spearman_correlatives_kept.csv')%,'Delimiter',',','QuoteStrings',true)
% writetable(Pearson_correlatives_keep,'test_Pearson_correlatives_kept.csv')
