%% Appendix D1: converting a list of coordinates to an n-by-n fields of view grid coordinate list 
% written by Matt Whitfield and lightly edited by Deena Rennerfeldt

%% load file
grid=5; %2 for 2x2
cd('C:\')
filename = 'C:\list_for_5x5a.stg';
gridsize=zeros(1,15)+grid;

delimiter = ',';
startRow = 2;
% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
% Open the text file.
fileID = fopen(filename,'r');
% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
% Close the text file.
fclose(fileID);
% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5,6,7,8,9,10,11,12,13]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

% Create output variable
stage = cell2mat(raw);
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me R;

%%
Dangle=-.5;
L=867;
W=660;
Rangle=Dangle/360*2*3.14159;
xstep=cos(Rangle)*L;
ystep=sin(Rangle)*L;
Dxstep=cos(Rangle-3.14159/2)*W;
% Dxstep=0;
Dystep=-sin(Rangle-3.14159/2)*W;
% xstep=867;
% ystep=0;
% Dxstep=0;
% Dystep=660;
numcells=stage(3,1);
startx=zeros(1,numcells);
starty=zeros(1,numcells);
startz=zeros(1,numcells);
for i=1:numcells
    startx(i)=stage(3+i,2)-L*((grid-1)/2);
    starty(i)=stage(3+i,3)-W*((grid-1)/2);
    startz(i)=stage(3+i,4);
end

FID = fopen('5x5a_output.STG', 'w');
fprintf(FID,'"Stage Memory List", Version 6.0\r\n');
fprintf(FID,'0, 0, 0, 0, 0, 0, 0, "um","um"\r\n');
fprintf(FID,'0\r\n');
fprintf(FID,[num2str(sum(gridsize.^2)),'\r\n']);
counter=1;
for k=1:length(gridsize)
    offsetpx=-8;   % To account for vertical misalignment between first and 2nd columns of images (in order of image acquisition)
    offset=zeros(gridsize(k),gridsize(k));
    offset(:,1)=offsetpx;
    gridx=zeros(gridsize(k),gridsize(k));
    gridy=zeros(gridsize(k),gridsize(k));
    gridx(1,1)=startx(k);
    gridy(1,1)=starty(k);
    for i=1:gridsize(k)
        for j=1:gridsize(k)
            gridx(i,j)=startx(k)+xstep*(j-1)-Dxstep*(i-1)+offset(i,j);
            gridy(i,j)=starty(k)+ystep*(j-1)+Dystep*(i-1);
            fprintf(FID,'"Position%d", %5.0f, %5.0f, %5.0f, 0, %5.0f, FALSE, -9999, TRUE, TRUE, 0, -1, ""\r\n',counter,gridx(i,j),gridy(i,j),startz(k),startz(k));
            counter=counter+1;
        end
    end
end
% orderx=[1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5];
% ordery=[1 2 3 4 5 5 4 3 2 1 1 2 3 4 5 5 4 3 2 1 1 2 3 4 5];
% for i=1:25
%         fprintf(FID,'"Position%d", %5.0f, %5.0f, %5.0f, 0, %5.0f, FALSE, -9999, TRUE, TRUE, 0, -1, ""\r\n',counter,gridx(orderx(counter),ordery(counter)),gridy(orderx(counter),ordery(counter)),startz,startz);
%         counter=counter+1;
% end
fclose(FID);
%  plot(gridx,gridy,'o');

