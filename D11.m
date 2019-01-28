%%D11: written by Matt Whitfield and lightly edited by Deena Rennerfeldt

function [parentgrid,labelgrid,areagrid,xlocgrid,ylocgrid,numcells,neighbors,eccentricity,integrateddistance,formfactor]=getdata6(handles1,dotouch,grid)
if dotouch==0
   neighbors=0;
end
if grid==1
    parentgrid=handles1.Measurements.RelabeledCells.TrackObjects_ParentObjectNumber_50;
%     ParentObjectNumber_50 is an array of the parent object labels for 
%     each object at each time point.  50 is the maximum distance, in 
%     pixels, for an object in the previous time point to be considered the 
%     "parent object" of a given object in the current time point.  This 
%     distance is specified in the TrackObjects module of CellProfiler.
    labelgrid=handles1.Measurements.RelabeledCells.TrackObjects_Label_50;
    areagrid=handles1.Measurements.RelabeledCells.AreaShape_Area;
    xlocgrid=handles1.Measurements.RelabeledCells.AreaShape_Center_X;
    ylocgrid=handles1.Measurements.RelabeledCells.AreaShape_Center_Y;
    numcells=cell2mat(handles1.Measurements.Image.Count_cells);
    eccentricity=handles1.Measurements.RelabeledCells.AreaShape_Eccentricity;
    formfactor=handles1.Measurements.RelabeledCells.AreaShape_FormFactor;
    integrateddistance=handles1.Measurements.RelabeledCells.TrackObjects_IntegratedDistance_50;
    if dotouch==1
        neighbors(1).t=handles1.Measurements.RelabeledCells.Neighbors_PercentTouching_5;
        neighbors(1).n=handles1.Measurements.RelabeledCells.Neighbors_NumberOfNeighbors_5;
        neighbors(2).t=handles1.Measurements.RelabeledCells.Neighbors_PercentTouching_10;
        neighbors(2).n=handles1.Measurements.RelabeledCells.Neighbors_NumberOfNeighbors_10;
        neighbors(3).t=handles1.Measurements.RelabeledCells.Neighbors_PercentTouching_15;
        neighbors(3).n=handles1.Measurements.RelabeledCells.Neighbors_NumberOfNeighbors_15;
        neighbors(4).t=handles1.Measurements.RelabeledCells.Neighbors_PercentTouching_20;
        neighbors(4).n=handles1.Measurements.RelabeledCells.Neighbors_NumberOfNeighbors_20;
    end     
    numcells=cell2mat(handles1.Measurements.Image.Count_cells);
end