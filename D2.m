%% Appendix D2: relocating images according to petri dish location, stitching, and making a movie 
% Written by Matt Whitfield and lightly edited by Deena Rennerfeldt

timer=tic;

%% Inputs
clear all
pathbase='C:\';
bkwd=1; % for changing orientation of camera, stay at 1 unless camera rotated. 0 should fix things if camera rotated 180

% Delete the "To Delete" folder
if exist('C:\To Delete')
        rmdir('C:\To Delete','s')
end        

% Change this to reflect which colony each 'spot' corresponds to each time
% experiment stopped or gridsize changed, add a new entry
foldername{1}='2x2a';
colonyname(1).a=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40];
foldername{2}='3x3a';
colonyname(2).a=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40];
foldername{3}='3x3b';
colonyname(3).a=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40];



%% Extract info based on file names and move images into folder structure grouped by colony
cd(pathbase);
% set up file storage structure
if exist('Data by Colony','dir')~=7
    mkdir(pathbase, 'Data by Colony');
end
if exist('To Delete','dir')~=7
    mkdir(pathbase, 'To Delete');
end
cd([pathbase 'Data by Colony']);
for i=1:length(colonyname(1).a)
    if exist(['Colony_' num2str(i)],'dir')~=7
    	mkdir([pathbase 'Data by Colony'], ['Colony_' num2str(i)]);
    end 
end
cd(pathbase);
% Read in info about all current images sitting in folder
images=dir('*.tif*');
for i=1:length(images)
    trial=images(i).name;
    if isempty(regexp(trial,'thumb','ONCE'))==0
        % delete thumb file
        FileRename([pathbase images(i).name],[pathbase 'To Delete\' images(i).name])
    else
        % What is the experiment set name and index
        indexS=strfind(trial,'_g')+2;
        temp=strfind(trial(indexS:end),'_');
        indexE=temp(1)+indexS-2;
        setname=trial(indexS:indexE);
        setindex=strmatch(setname,foldername); % Which foldername does this match

        % What is the gridsize (assume square grid)
        gridsize2=str2num(setname(1))^2;

        % What is the spot #
        indexS=strfind(trial,'_s')+2;
        temp=strfind(trial(indexS:end),'_');
        indexE=temp(1)+indexS-2;
        spotnum=str2num(trial(indexS:indexE));

        % Which colony does this image belong to
        destination=colonyname(setindex).a(ceil(spotnum/gridsize2));

        cd([pathbase 'Data by Colony\Colony_' num2str(destination)])
        if exist(setname,'dir')~=7
            mkdir([pathbase 'Data by Colony\Colony_' num2str(destination)], setname);
        end
        try
            FileRename([pathbase images(i).name],[pathbase 'Data by Colony\Colony_' num2str(destination) '\' setname '\' images(i).name])
        catch exception
            FileRename([pathbase images(i).name],[pathbase 'Data by Colony\Colony_' num2str(destination) '\' setname '\' images(i).name])
        end
        
    end
%     elapsedtime=toc(timer);
%     if elapsedtime>3500
%         exit
%     end
end

%% Read in info about each colony (round down to full time points)

cd([pathbase 'Data by Colony'])
colonies=dir('*Colony*');
colonies=struct2cell(colonies)';
for k=1:size(colonies,1)
    starti=strfind(colonies{k,1},'y_')+2;
    colonies{k,6}=str2double(colonies{k,1}(starti:end));
end
colonies=sortrows(colonies,6);
numcolonies=size(colonies,1);

foldergridsize(1:numcolonies)=struct('x',zeros(1,10),'y',zeros(1,10));
numtimepts(1:numcolonies)=struct('a',zeros(1,10));
starttime(1:numcolonies)=struct('a',zeros(1,10));
foldergridname(1:numcolonies)=struct('a',[]);
for i=1:numcolonies
    foldergridname(i).a=cell(1,10);
end
% offsets(1:numcolonies)=struct('a',struct('x',[],'y',[]));       
UC(1:10)=struct('x', zeros(1,25),'y',zeros(1,25));
offsets(1:numcolonies)=struct('a', UC);

biggestgridsize(1:numcolonies)=struct('x',[],'y',[]);
gridpxls(1:numcolonies)=struct('x',[],'y',[]);
gridsize(1:numcolonies)=struct('x',[],'y',[]);
centering(1:numcolonies)=struct('x',[],'y',[]);
timepts=zeros(1,numcolonies);
newimage(1:numcolonies)=struct('a',[]);
singleimagepxls.x=1024;
singleimagepxls.y=1344;
cellf = @(fun, arr) cellfun(fun, num2cell(arr), 'uniformoutput',0);
    
for colonynum=1:numcolonies
    newpathbase=[pathbase 'Data by Colony\' colonies{colonynum,1} '\'];
    cd(newpathbase);
    if exist('Analysis','dir')~=7
        mkdir(newpathbase, 'Analysis');
    end
    pathA=[newpathbase '\Analysis\'];  
    folders=dir('*x*');
    for i=1:length(folders)
        index=strfind(folders(i).name,'x');
        foldergridsize(colonynum).x(i)=str2num(folders(i).name(index-1)); %#ok<*ST2NM>
        foldergridsize(colonynum).y(i)=str2num(folders(i).name(index+1));
        foldergridname(colonynum).a{i}=folders(i).name;
        for j=1:(foldergridsize(colonynum).x(i)* foldergridsize(colonynum).y(i))
            offsets(colonynum).a(i).x(j)=(floor((j-1)/foldergridsize(colonynum).x(i)));
            offsets(colonynum).a(i).y(j)=(rem(j-1,foldergridsize(colonynum).x(i)));
        end
        offsets(colonynum).a(i).x=offsets(colonynum).a(i).x(1:foldergridsize(colonynum).x(i)* foldergridsize(colonynum).y(i));
        offsets(colonynum).a(i).y=offsets(colonynum).a(i).y(1:foldergridsize(colonynum).x(i)* foldergridsize(colonynum).y(i));
        % If image montage taken backwards
        if bkwd==1
            offsets(colonynum).a(i).x=fliplr(offsets(colonynum).a(i).x);
            offsets(colonynum).a(i).y=fliplr(offsets(colonynum).a(i).y);
        end
        images=cellf(@(f) char(f.toString()), list(java.io.File([newpathbase folders(i).name]))); 
%         images=cellf(@(f) char(f.toString()), java.io.File([newpathbase folders(i).name]).list()); 
        
        numtimepts(colonynum).a(i)=floor(length(images)/(foldergridsize(colonynum).x(i)*foldergridsize(colonynum).y(i)));
        for k=1:size(images,1)
            starti=strfind(images{k,1},'_t')+2;
            endi=strfind(images{k,1},'.')-1;
            images{k,2}=str2double(images{k,1}(starti:endi));
        end
        images=sortrows(images,2);
        images=images(1:numtimepts(colonynum).a(i)*(foldergridsize(colonynum).x(i)*foldergridsize(colonynum).y(i)));
        if isempty(images)==1
            return
        end
        index1=strfind(images{1,1},'t');
        index2=strfind(images{1,1},'.');
        starttime(colonynum).a(i)=str2num(images{1,1}(index1+1:index2-1));
        cd(newpathbase);
    end
    biggestgridsize(colonynum).x=max(foldergridsize(colonynum).x(i));
    biggestgridsize(colonynum).y=max(foldergridsize(colonynum).y(i));
    gridpxls(colonynum).x=biggestgridsize(colonynum).x*singleimagepxls.x;
    gridpxls(colonynum).y=biggestgridsize(colonynum).y*singleimagepxls.y;
    newimage(colonynum).a=uint16(zeros(gridpxls(colonynum).x,gridpxls(colonynum).y));
    largestgrid=5;
    biggestgridsize(colonynum).x=largestgrid;
    biggestgridsize(colonynum).y=largestgrid;
    gridpxls(colonynum).x=biggestgridsize(colonynum).x*singleimagepxls.x;
    gridpxls(colonynum).y=biggestgridsize(colonynum).y*singleimagepxls.y;
    largeblankimage=uint16(zeros(largestgrid*singleimagepxls.x,largestgrid*singleimagepxls.y));
    for i=1:length(folders)
        centering(colonynum).x=horzcat(centering(colonynum).x,zeros(1,numtimepts(colonynum).a(i))+(biggestgridsize(colonynum).x-foldergridsize(colonynum).x(i))/2*singleimagepxls.x);
        centering(colonynum).y=horzcat(centering(colonynum).y,zeros(1,numtimepts(colonynum).a(i))+(biggestgridsize(colonynum).y-foldergridsize(colonynum).y(i))/2*singleimagepxls.y);
        gridsize(colonynum).x=horzcat(gridsize(colonynum).x,zeros(1,numtimepts(colonynum).a(i))+foldergridsize(colonynum).x(i));
        gridsize(colonynum).y=horzcat(gridsize(colonynum).y,zeros(1,numtimepts(colonynum).a(i))+foldergridsize(colonynum).y(i));
    end
    timepts(colonynum)=length(gridsize(colonynum).x);
    colonynum
%     elapsedtime=toc(timer);
%     if elapsedtime>3500
%         exit
%     end
end
THRESH=struct('cutoffL',[],'cutoffH',[],'cutoffASP',[],'cutoffLN',[],'adjustL',[],'adjustH',[],'sigmaN',[],'level',[],'sigmacanny',[],'canny',[],'cellfraction',[],'cannystep',[],'nucleusratio',[],'cannydivide',[],'bright',[],'guessmult',[]);
warning('off','images:initSize:adjustingMag')

% Elapsed time is 55.544931 seconds.

%% Make initial montage of spots

cd([pathbase 'Data by Colony'])
colonies=dir('*Colony*');
colonies=struct2cell(colonies)';
for k=1:size(colonies,1)
    starti=strfind(colonies{k,1},'y_')+2;
    colonies{k,6}=str2double(colonies{k,1}(starti:end));
end
colonies=sortrows(colonies,6);

numcolonies=size(colonies,1);
small=1;
pad=1;
howoften=1;
if small~=1
    fldname='Initial montage - small';
else
    fldname='Initial montage';
end
fldname2='Initial montage - small';
for colonynum=1:numcolonies
    newdata=0;
    newpathbase=[pathbase 'Data by Colony\' colonies{colonynum,1} '\'];
    cd(newpathbase);
    pathA=[newpathbase '\Analysis\'];  
    folders=dir('*x*');
    cd(pathA)
    if exist(fldname,'dir')~=7
        mkdir(pathA, fldname);
    end
    if exist(fldname2,'dir')~=7
        mkdir(pathA, fldname2);
    end
    cd([pathA fldname])
    alreadyrun=dir('*Time*');
    if pad==1
        pad2=largeblankimage;
    else
        pad2=0;
    end
    for i=1:length(folders)
        
        path2=[newpathbase folders(i).name];
        cd(path2)
        if i==1
            sumbase=0;
        else
        	sumbase=sum(numtimepts(colonynum).a(1:i-1));
        end
        for timept=starttime(colonynum).a(i):howoften:starttime(colonynum).a(i)+numtimepts(colonynum).a(i)-1
            sumtime=sumbase+timept-starttime(colonynum).a(i)+1;
            if timept<10
                leading0s='000';
            elseif timept<100
                leading0s='00';
            elseif timept<1000
                leading0s='0';
            else
                leading0s='';
            end
            cd([pathA fldname2])
            if isempty(dir(['Colony_' num2str(colonynum) '_' char(foldergridname(colonynum).a(i)) '_Time' leading0s num2str(timept) '*']))==1
                cd(path2)
                rawmontage5(pathA,foldergridsize,foldergridname,timept,offsets,i,colonynum,bkwd,small,fldname,fldname2,singleimagepxls,pad2,centering,sumtime)
                close all
                fprintf([num2str(colonynum) ':' num2str(i) ':' num2str(timept) '\n'])
                newdata=1;  
            end
        end
    end
%     newdata=1;
    if newdata==1
        % Make video of each colony
        cd([pathA fldname2])
        images=dir('*.tif*');
        imageNames = {images.name}';
        outputVideo = VideoWriter(fullfile(pathA,['Colony ' num2str(colonynum) '.avi']));
        outputVideo.FrameRate = ceil(10/howoften);
        open(outputVideo)

        for ii = 1:length(imageNames)
            img = imread(imageNames{ii});
%             img=imresize(img,.1);
%             img=imadjust(img,stretchlim(img,[0.0001 0.9999]),[]);
            writeVideo(outputVideo,img)
        end
        close(outputVideo)
    end
%     elapsedtime=toc(timer);
%     if elapsedtime>3500
%         exit
%     end
end

