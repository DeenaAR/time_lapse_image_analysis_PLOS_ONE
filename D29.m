%% D29, based on code written by Matt Whitfield and modified by Deena Rennerfeldt

% general pipeline: 
% 1. montage (MATLAB)
% 2. flatten (CellProfiler, flattengrid.cp)
% 3. adjust brightness/contrast (GIMP, brightness = 80 contrast = 109
    % "not_as_super_contrast")
% 4. pad (MATLAB)
% 5. overlay (this code)

%notes:
% path1 = ID path
% files = list of ID files in the ID path

% path2 = path to adjusted bottom images (which need to be the same size as
% the ID files)
% files2 = list of bottom images

% colors = structure with 3 fields (colors.R, colors.G, colors.B) = the RGB
% values, in ordered by whatever you're overlaying with (generation,
% progeny, etc.)  It's an imput and should be designated as such.

% want to have option to either create overlays for all time points or
% create overlays for a specified bottom images and ID files folder pair.

wow_factor = 2; %parameter that changes how strongly the colors appear (lower = less transparent)
%upload colony output file
cell_tracking_figures_for_other_analyses
close all

% for generation:
% colors.R=[255 254 255 160 73 48 161]; %wild olive color scheme
% colors.G=[101 149 229 220 205 111 155];
% colors.B=[111 92 106 98 244 209 219];

% for progeny:
colors.R=[128 4 214 255];
colors.G=[2 120 71 183];
colors.B=[55 120 0 51];

% realtimept = 374; % the actual time point you're overlaying

% path 1 should be the path to an IDs folder.  It is specified in
% cell_tracking_figures, but you can specify it here if you just want to
% run makemovie_v3.  
clear files
% Go to path 1:
% cd(path1)
% call the .mat files in path1:
% files = dir('*.mat');
ID_path='C:\';
cd(ID_path);
ID_files = dir('*.mat');
image_path='C:\';
cd(image_path);
image_files = dir('*.jpg');
savepath='C:\';


% looks like for now I have to put in a specific file name...should fix
% this to cycle through
for file_counter = 1:374


ID_file = ID_files(file_counter);
image_file = image_files(file_counter);

%Probably needed when looping through:
clear cframe cImage cImage2 cImage3 grain cc jj docells grain4 grain5 grain3 celli j

% Define grain as a matrix of zeros to cut down computing time:
grain = zeros([5070 6720], 'uint16');
% Define colors array (looks like splitC from the analyzedataforDeena code
% (if you read as columns):

% Make overlay images:
% for timept=1:length(files)
%     timept = 1;
    cd(ID_path);
    cframe=open(ID_file.name);
%     cframe=open(char(ID_file(file_counter,1))); % the ID file as a structure
    cImage=uint16(cframe.Image); % the actual file; a matrix of the pixels each cell occupies
%     if timept==1
        numcells=max(max(cImage)); %the number of starting cells
%     end
    cImage2=cImage./cImage; % 0s and 1s
    cc = bwconncomp(cImage, 8); %generates pixel id list...linear indext of all pixels in each region
    % linear indexing: goes down each column, so the first pixel in the
    % second column is image height (px) + 1 (5071 in this case)
    jj=cell2struct(cc.PixelIdxList,'blah',1); %turns that list into a structure with a field name 'blah'... each row is a cell, and the contents are all the pixels that cell occupies
    
    cd(image_path);
    cframe3=imread(image_file.name); % the original image
    cImage3=uint8(cframe3);  %
    cImage3 = imadjust(cImage3,[0; 1],[0; 0.7]);
    
   
      grain = cImage3;

        grain4.R=grain; %R component of original image (set to the pixel value of the original image here)
        grain4.G=grain; 
        grain4.B=grain;

     for celli=1:numcells %for each starting cell - even though it counts up to the total number of cells in the image, which might have made sense for Matt's experiment ??

        
        docells=find(labelgrid{1,file_counter}==celli); % location in the labelgrid matrix (at the specified time point) that has all the cells matching this starting cell #.  labelgrid is a list of cell's progeny #, ordered by object number at that time point.  
        docellN=RealN(file_counter).num(find(RealN(file_counter).label==celli)); %unique numbers (uniqueN) of all the cells in this progeny present in the bottom image
        if isempty(docells)==0 
            for j=1:length(docells) % for each cell in the bottom image belonging to this progeny
                pxIDs=find(cImage==docells(j)); %pixels this cell occupies
                yposIDs=floor(pxIDs./5070)+1; %used to be 2560, changed for my images (5070xtimept0); y coordinates for all pixels this cell occupies
                xposIDs=rem(pxIDs,5070); % 
                gen=RealN(file_counter).gen(find(RealN(file_counter).parent==docells(j))); %generation of this cell (presumably, not sure what RealN.parent actually is)
                progeny = labelgrid{1,file_counter}(docells(j)) ;
               
                %changes the pixel values:
%                 %for generation:
%                 grain4.R(pxIDs) = grain4.R(pxIDs)+colors.R(gen)/2;
%                 grain4.G(pxIDs) = grain4.G(pxIDs)+colors.G(gen)/2;
%                 grain4.B(pxIDs) = grain4.B(pxIDs)+colors.B(gen)/2;
% %                
                
                %for progeny:
                grain4.R(pxIDs) = grain4.R(pxIDs)+colors.R(progeny)/wow_factor;
                grain4.G(pxIDs) = grain4.G(pxIDs)+colors.G(progeny)/wow_factor;
                grain4.B(pxIDs) = grain4.B(pxIDs)+colors.B(progeny)/wow_factor;
                
                
                
                    %this is the first time grain3 is mentioned I think...
                grain3(:,:,1)=grain4.R;
                grain3(:,:,2)=grain4.G;
                grain3(:,:,3)=grain4.B;
            end
        end
     end 
   

% savepath should be the path you want the overlaid images and movie to be
% saved to.
cd(savepath)

figure()
imshow(grain3)
FileName=image_file.name;
% FileName_mat = cell2mat(FileName);
name_end = strfind(FileName,'.jpg')-1;
save_name = cell2mat(cellstr([FileName(1:name_end) '_overlay']));
set(gcf,'Position',[100 100 672 507])
print(gcf, save_name, '-dpng', '-r1000');
close all


%     if file_counter<10
%         imwrite(grain3,save_name_test,'Quality',100)  
%     elseif timept<100
%         imwrite(grain3,['tt0' num2str(file_counter) '.jpg'],'Quality',50) 
%     else
%         imwrite(grain3,['tt' num2str(file_counter) '.jpg'],'Quality',50) 
%     end
% %           saveas(gcf,[ 't' num2str(timept)],'jpg')
%         pause
%    pause  
%    close
% end 
end

