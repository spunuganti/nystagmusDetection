function [TestsTable,num_times_gazebeatVel] = genData(filename,foldertoSave,testNames)
% filename='L_M_2016_03_28_17_20_19.xml';

% Initializing table into which the data will be stored
TestsTable = table;
counter = 1;

% Reading the XML file
tree = xmlread(filename);

% Getting all the different tests conducted on this subject
allTests = tree.getElementsByTagName('TestType');

% Getting the patient ID
patientID = char(tree.getElementsByTagName('PatientID').item(0).getFirstChild.getData);
temp = strsplit(patientID,'-');
temp2 = strsplit(temp{3},'00');
patientID = strjoin({temp{2},temp2{2}},'-');
clear temp temp2

csvFile = strrep(filename,'.xml','.csv');
% txtFile = strrep(filename,'.xml','.txt');
% copyfile(txtFile,csvFile);

for i = 0:allTests.getLength-1 % getLength function to get the total number of tests performed on this subject
    
    %    TestsTable = table;
    
    currentTest = allTests.item(i);
    
    % Getting the Parent Test name
    parentTest = char(currentTest.getParentNode.getTagName);
    
    % Getting the TestUID number in order to import the corresponding raw data
    testUID = char(currentTest.getParentNode.getElementsByTagName('TestUID').item(0).getFirstChild.getData);
    
    % Getting the torsionUID if present
    try
        torsionUID = char(currentTest.getParentNode.getElementsByTagName('TorsionUID').item(0).getFirstChild.getData);
    catch
        torsionUID = testUID;
    end
    
    
    %    if contains(parentTest,'Gaze') || contains(parentTest,'Dynamic')
    
    % Getting the name of the particular test which is stored in this TestType label in the XML file
    testName = char(currentTest.getFirstChild.getData);
    
    testNewName = testNames.New(categorical(testNames.Original)==testName);
    
    if isempty(testNewName)
        continue;
    else
        
        % Getting type ID from the XML file
        typeID = char(currentTest.getParentNode.getElementsByTagName('TypeID').item(0).getFirstChild.getData);
        
        % Getting the patient UID
        patientUID = char(currentTest.getParentNode.getElementsByTagName('PatientUID').item(0).getFirstChild.getData);
        
        % Getting the start and stop time
        startTime = char(currentTest.getParentNode.getElementsByTagName('StartDateTime').item(0).getFirstChild.getData);
        endTime = char(currentTest.getParentNode.getElementsByTagName('EndDateTime').item(0).getFirstChild.getData);
        
        % Gettingt the Average Frame Rate
        avgFrameRate = str2double(currentTest.getParentNode.getElementsByTagName('AvgFrameRate').item(0).getFirstChild.getData);
        
        % Getting the Vision Denied
        visionDenied = char(currentTest.getParentNode.getElementsByTagName('VisionDenied').item(0).getFirstChild.getData);
        
        if contains(visionDenied,'true')
            prefix = {'Deny'};
        else
            prefix = {'Fix'};
        end
        
        testNewName = strjoin({prefix{1},testNewName{1}},'_');
        
        % Getting the num of beats averaged
        numBeatsAvged = str2double(currentTest.getParentNode.getElementsByTagName('NumBeatsAvged').item(0).getFirstChild.getData);
        
        % Getting the other parameters
        parameters = table;
        
        try
            parameters.MinSPVVR = str2double(currentTest.getParentNode.getElementsByTagName('MinSPVVR').item(0).getFirstChild.getData);
            parameters.MinSPVVR = parameters.MinSPVVR.*0.1;
        catch
            %            fprintf('No MinSPVVR for patient %s and test %s.\n',patientID, testUID);
            parameters.MinSPVVR = NaN;
        end
        
        try
            parameters.MinSPVHR = str2double(currentTest.getParentNode.getElementsByTagName('MinSPVHR').item(0).getFirstChild.getData);
            parameters.MinSPVHR = parameters.MinSPVHR .*0.1;
        catch
            %            fprintf('No MinSPVHR for patient %s and test %s.\n',patientID, testUID);
            parameters.MinSPVHR = NaN;
        end
        
        try
            parameters.MinSPVTR = str2double(currentTest.getParentNode.getElementsByTagName('MinSPVTR').item(0).getFirstChild.getData);
            parameters.MinSPVTR = parameters.MinSPVTR.*0.1;
        catch
            %            fprintf('No MinSPVTR for patient %s and test %s.\n',patientID, testUID);
            parameters.MinSPVTR = NaN;
        end
        
        try
            parameters.MaxSPVHR = str2double(currentTest.getParentNode.getElementsByTagName('MaxSPVHR').item(0).getFirstChild.getData);
            parameters.MaxSPVHR = parameters.MaxSPVHR.*0.1;
        catch
            parameters.MaxSPVHR = NaN;
        end
        
        try
            parameters.MaxSPVVR = str2double(currentTest.getParentNode.getElementsByTagName('MaxSPVVR').item(0).getFirstChild.getData);
            parameters.MaxSPVVR = parameters.MaxSPVVR.*0.1;
        catch
            %            fprintf('No MaxSPVVR for patient %s and test %s.\n',patientID, testUID);
            parameters.MaxSPVVR = NaN;
        end
        
        try
            parameters.MaxSPVTR = str2double(currentTest.getParentNode.getElementsByTagName('MaxSPVTR').item(0).getFirstChild.getData);
            parameters.MaxSPVTR = parameters.MaxSPVTR.*0.1;
        catch
            %            fprintf('No MaxSPVTR for patient %s and test %s.\n',patientID, testUID);
            parameters.MaxSPVTR = NaN;
        end
        
        try
            parameters.AvgSPVHR = str2double(currentTest.getParentNode.getElementsByTagName('AvgSPVHR').item(0).getFirstChild.getData);
            parameters.AvgSPVHR = parameters.AvgSPVHR.*0.1;
        catch
            %            fprintf('No AvgSPVHR for patient %s and test %s.\n',patientID, testUID);
            parameters.AvgSPVHR = NaN;
        end
        
        try
            parameters.AvgSPVVR = str2double(currentTest.getParentNode.getElementsByTagName('AvgSPVVR').item(0).getFirstChild.getData);
            parameters.AvgSPVVR = parameters.AvgSPVVR.*0.1;
        catch
            %            fprintf('No AvgSPVVR for patient %s and test %s.\n',patientID, testUID);
            parameters.AvgSPVVR = NaN;
        end
        
        try
            parameters.AvgSPVTR = str2double(currentTest.getParentNode.getElementsByTagName('AvgSPVTR').item(0).getFirstChild.getData);
            parameters.AvgSPVTR = parameters.AvgSPVTR.*0.1;
        catch
            %            fprintf('No AvgSPVTR for patient %s and test %s.\n',patientID, testUID);
            parameters.AvgSPVTR = NaN;
        end
        
        try
            parameters.PeakSPVHR = str2double(currentTest.getParentNode.getElementsByTagName('PeakSPVHR').item(0).getFirstChild.getData);
            parameters.PeakSPVHR = parameters.PeakSPVHR.*0.1;
        catch
            %            fprintf('No PeakSPVHR for patient %s and test %s.\n',patientID, testUID);
            parameters.PeakSPVHR = NaN;
        end
        
        try
            parameters.PeakSPVVR = str2double(currentTest.getParentNode.getElementsByTagName('PeakSPVVR').item(0).getFirstChild.getData);
            parameters.PeakSPVVR = parameters.PeakSPVVR.*0.1;
        catch
            %            fprintf('No PeakSPVVR for patient %s and test %s.\n',patientID, testUID);
            parameters.PeakSPVVR = NaN;
        end
        
        try
            parameters.PeakSPVTR = str2double(currentTest.getParentNode.getElementsByTagName('PeakSPVTR').item(0).getFirstChild.getData);
            parameters.PeakSPVTR = parameters.PeakSPVTR.*0.1;
        catch
            %            fprintf('No PeakSPVTR for patient %s and test %s.\n',patientID, testUID);
            parameters.PeakSPVTR = NaN;
        end
        
        try
            parameters.PeakSPVTimeHRms = str2double(currentTest.getParentNode.getElementsByTagName('PeakSPVTimeHRms').item(0).getFirstChild.getData);
            parameters.PeakSPVTimeHRms = parameters.PeakSPVTimeHRms.*0.001;
        catch
            %            fprintf('No PeakSPVTimeHRms for patient %s and test %s.\n',patientID, testUID);
            parameters.PeakSPVTimeHRms = NaN;
        end
        
        try
            parameters.PeakSPVTimeVRms = str2double(currentTest.getParentNode.getElementsByTagName('PeakSPVTimeVRms').item(0).getFirstChild.getData);
            parameters.PeakSPVTimeVRms = parameters.PeakSPVTimeVRms.*0.001;
        catch
            %            fprintf('No PeakSPVTimeVRms for patient %s and test %s.\n',patientID, testUID);
            parameters.PeakSPVTimeVRms = NaN;
        end
        
        try
            parameters.PeakSPVTimeTRms = str2double(currentTest.getParentNode.getElementsByTagName('PeakSPVTimeTRms').item(0).getFirstChild.getData);
            parameters.PeakSPVTimeTRms = parameters.PeakSPVTimeTRms.*0.001;
        catch
            %            fprintf('No PeakSPVTimeTRms for patient %s and test %s.\n',patientID, testUID);
            parameters.PeakSPVTimeTRms = NaN;
        end
        
        try
            parameters.SPV = str2double(currentTest.getParentNode.getElementsByTagName('SPV').item(0).getFirstChild.getData);
            parameters.SPV = parameters.SPV.*0.1;
        catch
            %            fprintf('No SPV for patient %s and test %s.\n',patientID, testUID);
            parameters.SPV = NaN;
        end
        
        try
            parameters.Amplitude = str2double(currentTest.getParentNode.getElementsByTagName('Amplitude').item(0).getFirstChild.getData);
            parameters.Amplitude = parameters.Amplitude.*0.1;
        catch
            %            fprintf('No PeakSPVTimeTRms for patient %s and test %s.\n',patientID, testUID);
            parameters.Amplitude = NaN;
        end
        
        % Getting the corresponding XML Data
        [xmlData,num_times_gazebeatVel] = getXmlData(currentTest);
        
        % Getting the corresponding raw data
        rawData = getRawData(csvFile,testUID,parentTest,torsionUID);
        
        if size(xmlData,1) == 1
            xmlData(2,:) = xmlData(1,:);
        end
        
        if size(xmlData,1) == 0
            continue
        end
        
        warning('off','last')
        TestsTable(counter,1) = {patientID};
        TestsTable(counter,2) = {patientUID};
        TestsTable(counter,3) = {parentTest};
        TestsTable(counter,4) = {testName};
        TestsTable(counter,5) = {testNewName};
        TestsTable(counter,6) = {testUID};
        TestsTable(counter,7) = {typeID};
        TestsTable(counter,8) = {avgFrameRate};
        TestsTable(counter,9) = {startTime};
        TestsTable(counter,10) = {endTime};
        TestsTable(counter,11) = {visionDenied};
        TestsTable(counter,12) = {numBeatsAvged};
        TestsTable(counter,13) = {parameters};
        TestsTable(counter,14) = {xmlData};
        TestsTable(counter,15) = {rawData};
        
        TestsTable.Properties.VariableNames = {'PatientID','PatientUID','ParentTestName','TestType','NewTestName',...
            'TestUID','TestTypeID','AvgFrameRate','StartDtTime','EndDtTime','VisionDenied','NumBeatAvged',...
            'Parameters','XmlData','RawData'};
        
        testName = strrep(testName,'/',' ');
        filename = strjoin({patientID,testUID,testName},'_');
        save(fullfile(foldertoSave,filename),'TestsTable');
        
        clear rawData xmlData
    end
    
end

% writetable(TestsTable,'NystagmusData.xlsx');
end

% testname = char(allTests.item(i).getParentNode.getTagName);    % to
% get the name of the parent node of the current TestType. For example,
% if the TestType = Gaze - Center, then its corresponding parent node
% would be VW_GazeTest since it comes under a Gaze Test

%    v = genvarname(testname);
%    eval([v 't']);

%    t2 = mergevars(t,{'HR','VR','TR','Time'},...
%                'NewVariableName',testname,'MergeAsTable',true);

% Creating Subject Folder and Saving the data to it
% p = fullfile(p,'Data.mat');
% save(p,'Tests');
