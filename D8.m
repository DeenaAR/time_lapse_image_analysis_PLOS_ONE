%% Appendix D8: identification of tracking errors
% this is a modified version of D10, which was written by Matt Whitfield
% It was modified by Deena Rennerfeldt for the purposes of identifying
% tracking errors.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D8.m is used to identify tracking errors from CellProfiler.  It         %
% works with D7.cp and D9.cp                                              %
%                                                                         %
% It doesn't produce figures like D10, but rather provides diagnostics for%
% error recognition via an excel spreadsheet of your object numbers.      %
%                                                                         %
% TO USE: load your CellProfiler output file.  At the bottom of this code %
% file, specify the directory you want your excel spreadsheet to go to and%
% the name of the spreadsheet (the directions are in the comments below.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set things up
clear Parents RealN Data numcell genN twin1 twin2 touching touchnum...
    genlist genname parentgrid labelgrid areagrid xlocgrid ylocgrid ...
    numcells neighbors orderstarters

parentgrid=handles.Measurements.RelabeledCells.TrackObjects_ParentObjectNumber_50;
labelgrid=handles.Measurements.RelabeledCells.TrackObjects_Label_50;
xlocgrid=handles.Measurements.RelabeledCells.Location_Center_X;
ylocgrid=handles.Measurements.RelabeledCells.Location_Center_Y;
numcells=cell2mat(handles.Measurements.Image.Count_cells);
integrateddistance=handles.Measurements.RelabeledCells.TrackObjects_IntegratedDistance_50;
numcells=cell2mat(handles.Measurements.Image.Count_cells);
%object number grid (new to this version):
objectgrid=handles.Measurements.RelabeledCells.Number_Object_Number;

                    
timepointfix=96;    % conversion factor from # of time points to days.  If 
                    % time points are 15 minutes apart, set this to 96 
                    % (i.e., there are 96 15-minute time points in a day)
                    



% The array outputs are each described below:

% parentgrid:  A "parent object" is the object in the preceeding image that
%              overlaps with the current object (i.e. it's the object/cell 
%              in the previous time point).  A "parent object number" is
%              the label assigned to the parent object.  parentgrid is an
%              array of the parent object numbers for each object at each 
%              time point
%             
% labelgrid:   An array of label numbers for each object at each time point             
%

% xlocgrid, ylocgrid:   x- and y-coordinates of the center of each object
%                       at each time point.  **Note, this is calculated
%                       differently in getdata, which uses cell area.*
% 
% numcells:   the number of cells at each time point
% 
% objectgrid: the object number of each cell (matches the number on the
%             tracked images

timepts=length(parentgrid);         % # of time points
rtime=(1:timepts)./timepointfix;    % # each time point (in days)

cells=length(parentgrid{1,1});      % # of cells at start of experiment 
cells2=cells;
cells1=0;
startcells1=0;
startcells2=cells2;
startercells=labelgrid{1,1}(find(labelgrid{1,1}~=-1)); %  each cell at start of experiment

% Initialize data storage structures
Parents(1:cells)= struct('ancestor',[],'parent',[],'leave',[],'split',[],'children',[],'twin',[],'lineage',[],'lineagetime',[],'born',[],'appear',[],'gen',1,'lifetime',0,'descend',-1,'splitsize',0);
for o=1:length(labelgrid{1,1})
    Parents(o).ancestor=labelgrid{1,1}(o);        % parent # of cells at start
end
Data(1:cells)= struct('num',[],'label',[],'gen',[],'time',[],'area',[],'small',0,'xloc',[],'yloc',[],'prec',[],'pren',[],'eccentricity',[],'formfactor',[],'migrate',[],'totaldist',[]);
%% Make RealN
% predefine RealN (saves memory)
RealN(1:timepts)=struct('object_num',[],'num',[],'label',[],'parent',0,'gen',0,'xloc',[],'yloc',[]);
% define size of first time point
RealN(1).num=(1:cells)*0;
RealN(1).label=(1:cells)*0;
RealN(1).parent=(1:cells)*0;
RealN(1).gen=(1:cells)*0;
RealN(1).xloc=(1:cells)*0;
RealN(1).yloc=(1:cells)*0;
RealN(1).object_num=(1:cells)*0;

%% Convert the raw input data into synthesized metrics
for t=1:timepts % for each time point
    for c=1:length(parentgrid{1,t})         % for each cell at a time point
        
        cellN=labelgrid{1,t}(c);        % Cell label (split cells keep parent #)
        parentN=parentgrid{1,t}(c);     % Cell label in previous time point 
        xloc=xlocgrid{1,t}(c);          % X position of center of mass
        yloc=ylocgrid{1,t}(c);          % Y position of center of mass
        object_num=objectgrid{1,t}(c);  % Object number of cells
        
        cells=cells2;
  
        indexP=find(parentgrid{1,t}==parentN);   % if two then split this time
        % i.e. if length(indexP)>1, then the cell split at this t

        % uniqueN - unique number assigned to daughter cells when cells split
        if t~=1
            uniqueN=RealN(t-1).num(find(RealN(t-1).label==cellN & RealN(t-1).parent==parentN));
            gen=RealN(t-1).gen(find(RealN(t-1).label==cellN & RealN(t-1).parent==parentN));
        else
            uniqueN=cellN;
            gen=1;
        end

        if length(indexP)>1 && t~=1 && (parentN~=0) % if cell split this time point
            cells=cells+1;
            Parents(uniqueN).split=t;               % time that cell split
            Parents(uniqueN).children=horzcat(Parents(uniqueN).children,cells);     % Unique id# of child cells 
            Parents(cells).parent=uniqueN;     % Unique id# of child cells 
            if cellN<=startcells2 || (cellN>1000 && cellN<=startcells1)  
                Parents(cellN).lineage=horzcat(Parents(cellN).lineage,cells);       % Unique id# of all cells that parent cell at start of experiment gives rise to
                Parents(cellN).lineagetime=horzcat(Parents(cellN).lineagetime,t);       % Time of splits
            end
            uniqueN=cells;                          % Assigns unique number to child cell
            Parents(uniqueN).born=t;                % time daughter cell is "born"
            gen=gen+1; 
            Parents(uniqueN).gen=gen;               % generation of daughter cell
            Parents(uniqueN).ancestor=cellN;          % original parent #
        elseif (parentN==0) && t~=1                   % when a new cell appears (not from division)
            cells=cells+1;
            uniqueN=cells;
            gen=1;
            Parents(uniqueN).gen=gen;               % generation of daughter cell
            %Parents(uniqueN).ancestor=cellN;          % original parent #
            Parents(uniqueN).appear=t;
        end

        RealN(t).num(uniqueN)=uniqueN;
        RealN(t).label(uniqueN)=cellN;
        RealN(t).parent(uniqueN)=c;  
        RealN(t).gen(uniqueN)=gen; 
        RealN(t).xloc(uniqueN)=xloc;
        RealN(t).yloc(uniqueN)=yloc;
        RealN(t).object_num(uniqueN)=object_num;

        cells2=cells;
     
    end
end


%% Export object numbers to Excel: follow directions in the comments

% Change this to the directory you want your output spreadsheed to go to:
cd('C:\')  


myTable = struct2table(RealN);
myTrimmedTable = myTable(:,1);

% Change the title below (in purple) to whatever you want it to be:
writetable(myTrimmedTable,'T45C22_1st_tracking_all.xlsx');

disp('error identification table exported');
