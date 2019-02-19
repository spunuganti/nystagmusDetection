function [xmlData,num_times_gazebeatVel] = getXmlData(currentTest)

xmlData = table();  
        
   % Getting timestamps present in the parent node of the current TestType 
   timeNodes = currentTest.getParentNode.getElementsByTagName('TimeMs'); 
     
   % Total number of data points 
   n = timeNodes.getLength; 
   
   % Getting all the velocity labels present in the parent node of the current TestType 
   velNodes = currentTest.getParentNode.getElementsByTagName('Velocity');
   if velNodes.getLength~=timeNodes.getLength
       num_times_gazebeatVel = 1;
   else
       num_times_gazebeatVel = 0;
   end
   
   hr = []; tr = []; vr = []; TimeHR = [];  TimeVR = []; TimeTR = [];
   
   for j = 0:n-1
     
      if ~contains(char(timeNodes.item(j).getParentNode.getTagName),'Velocity')
      
      % Getting velocity and time stamps for Horizontal component
      if strcmp(timeNodes.item(j).getParentNode.getElementsByTagName('Signal').item(0).getFirstChild.getData,'HR')
         hr(end+1) = str2double(timeNodes.item(j).getParentNode.getElementsByTagName('Velocity').item(0).getFirstChild.getData);
         TimeHR(end+1) = str2double(timeNodes.item(j).getFirstChild.getData); 
      end
      
      % Getting velocity and time stamps for Vertical component
      if strcmp(timeNodes.item(j).getParentNode.getElementsByTagName('Signal').item(0).getFirstChild.getData,'VR')
         vr(end+1) = str2double(timeNodes.item(j).getParentNode.getElementsByTagName('Velocity').item(0).getFirstChild.getData); 
         TimeVR(end+1) = str2double(timeNodes.item(j).getFirstChild.getData); 
      end  
           
      % Getting velocity and time stamps for Vertical component
      if strcmp(timeNodes.item(j).getParentNode.getElementsByTagName('Signal').item(0).getFirstChild.getData,'TR')
         tr(end+1) = str2double(timeNodes.item(j).getParentNode.getElementsByTagName('Velocity').item(0).getFirstChild.getData); 
         TimeTR(end+1) = str2double(timeNodes.item(j).getFirstChild.getData) ;
      end  
      
      end      
   end
      
   TimeHR = TimeHR'; TimeVR = TimeVR'; hr = hr'; vr = vr'; tr = tr'; TimeTR = TimeTR'; 
      
   % Accounting for missing data points
   Time = [500:1000:max([max(TimeHR),max(TimeVR),max(TimeTR)])]';
   
   idx = ismember(Time,TimeHR);
   HR = nan(length(Time),1);
   HR(idx) = hr;
   HR = HR.*0.1;
   
   idx = ismember(Time,TimeVR);
   VR = nan(length(Time),1);
   VR(idx) = vr;
   VR = VR.*0.1;
   
   idx = ismember(Time,TimeTR);
   TR = nan(length(Time),1);
   TR(idx) = tr;
   TR = TR.*0.1;
   
xmlData.Time = Time.*0.001;
xmlData.HR = HR;
xmlData.VR = VR;
xmlData.TR = TR;

end


