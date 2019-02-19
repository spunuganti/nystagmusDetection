function rawData = getRawData(rawFile, testUID, parentTest, torsionUID)

fid=fopen(rawFile);
rawImport=textscan(fid,'%s','collectoutput',1,'delimiter','\n');

torsionUID;

str = strjoin({'<TestUID>',testUID,'</TestUID>'},'');
start = find(contains(rawImport{1,1},str),1); % start index for the vel & position values
temp = rawImport{1,1}(start+1:end); 

stop = find(contains(temp,'<'),1); % stop index for the vel & position values
if isempty(stop)
    stop = length(temp)+1; % when the last test is reached
end

str = strjoin({'>',torsionUID},'');
startTR = find(contains(temp,str),1); % start index for torsion data
temp = rawImport{1,1}(startTR+start+1:end);
stopTR = find(contains(temp,'<'),1); % stop index for the vel & position values
if isempty(stopTR)
    stopTR = length(temp)+1; % when the last test is reached
end

clear temp;

% Getting the vel and position data from the raw csv file only for required tests
if contains(parentTest,'HI') 
    variables = {'Time','RALP','LARP','Lateral','Hvel','Vvel'};
    hrvrData = array2table(csvread(rawFile,start,0,[start,0,stop+start-2,5]),...
    'VariableNames',variables);
elseif contains(parentTest,'VOR')
    variables = {'Time','HRvel','VRvel','W','X','Y','Z','HRpix','VRpix'};
    hrvrData = array2table(csvread(rawFile,start,0,[start,0,stop+start-2,8]),...
    'VariableNames',variables);                            
else
    variables = {'Time','HR','VR','W','X','Y','Z','HRpix','VRpix'};    
    hrvrData = array2table(csvread(rawFile,start,0,[start,0,stop+start-2,8]),...
    'VariableNames',variables);                             
end

if ~isempty(startTR)

% Getting the torsion data from the raw csv file
torsionData = array2table(csvread(rawFile,startTR+start,0,[startTR+start,0,stopTR+startTR+start-2,1]),...
    'VariableNames',{'Time','TR'});

size(torsionData);
size(hrvrData);

a = hrvrData.Time; b = torsionData.Time;
a1= round(a./10000); b1= round(b./10000);

% if size(torsionData,1)<= size(hrvrData,1)    
    count=1; 
    idx1 = find(b1>=a1(1)-10 & b1<=a1(1)+10);
    TR(1) = torsionData.TR(1);
    time(1) = b1(1);
    for i = 2:numel(a1)
        idx2 = find(b1>=a1(i)-10 & b1<=a1(i)+10);
        if ~isempty(intersect(idx2,idx1))
            idx = setdiff(idx2,idx1);
            if isempty(idx)
               idx = intersect( idx1,idx2);
            end
            if numel(idx)>1 
                TR(i) = NaN;
                time(i) = NaN;
            elseif numel(idx) ==1
                TR(i) = torsionData.TR(idx);
                time(i) = b1(idx);
                count = count+1;           
            end       
        else
            if numel(idx2)==1
                TR(i) = torsionData.TR(idx2);
                time(i) = b1(idx2);
                count = count+1;
            else
                TR(i) = NaN;
                time(i) = NaN;
            end
        end
        if time(i-1)==time(i)
           TR(i) = NaN; 
           time(i) = NaN;
        end
        idx1 = idx2;
    end
% elseif size(torsionData,1)>size(hrvrData,1)  
%     error( 'Error torsion data');
% end
hrvrData.TR = TR';
hrvrData.TRtime = time';
hrvrData.TRverificationTime = a1;
end

hrvrData.Time = (hrvrData.Time-hrvrData.Time(1))./10000000;
rawData = hrvrData;
fclose all;

return














