function [data, pixelData] = LoadRawData(dataFile)  

    if ( ~exist(dataFile, 'file') )
        error( ['Data file ' dataFile ' does not exist.']);
    end
    
    load(dataFile)   
      
    if ismember('TR', raw.Properties.VariableNames)
        varnames = {'Time', 'RightX' , 'RightY', 'HeadQ1','HeadQ2','HeadQ3','HeadQ4','RightT','FrameNumberRaw'};
        raw(:,end-1:end)=[];
    else
        varnames = {'Time', 'RightX' , 'RightY', 'HeadQ1','HeadQ2','HeadQ3','HeadQ4','FrameNumberRaw'};
    end
    
    raw.FrameNumber = [0;cumsum(round(diff(raw.Time)./median(diff(raw.Time))))];
    if min(diff(raw.FrameNumber))~=1
        error('Ovrlapping time stamps:Min difference in consecutive stamps is not 1')
    end
    
    pixelData = table();
    pixelData.RightSeconds = raw.Time;
    pixelData.RightX = raw.HRpix;
    pixelData.RightY = raw.VRpix;
    pixelData.RightFrameNumberRaw = raw.FrameNumber;
    
    raw.HRpix = []; raw.VRpix = [];  
    
    data = raw;
    data.Properties.VariableNames = varnames;
    
    clear raw

end