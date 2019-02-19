%% For validating otosuite results and finding threshold using plots

load('/mnt/sai/DATA/AVERTnystagmus/TestsDataNew.mat');

%Shorter Version
TestsData.ParentTestName = categorical(TestsData.ParentTestName);
TestsData.OTOSuiteResultH = categorical(TestsData.OTOSuiteResultH);
TestsData.OTOSuiteResultV = categorical(TestsData.OTOSuiteResultV);

idxGaze = find(TestsData.ParentTestName=='VW_GazeTest');
idxDyn = find(TestsData.ParentTestName=='VW_DynamicTest');

subplot(221); gscatter(TestsData.Parameters(idxGaze,:).AvgSPVHR,TestsData.peakH(idxGaze),TestsData.OTOSuiteResultH(idxGaze));
subplot(222); gscatter(TestsData.Parameters(idxGaze,:).AvgSPVVR,TestsData.peakV(idxGaze),TestsData.OTOSuiteResultV(idxGaze));
subplot(223); gscatter(TestsData.Parameters(idxDyn,:).AvgSPVHR,TestsData.peakH(idxDyn),TestsData.OTOSuiteResultH(idxDyn));
subplot(224); gscatter(TestsData.Parameters(idxDyn,:).AvgSPVVR,TestsData.peakV(idxDyn),TestsData.OTOSuiteResultV(idxDyn));

%Longer Version
grp =table();
grp.h = ones(height(TestsData),1);
grp.v = ones(height(TestsData),1);

for i = 1:height(TestsData)
    
    TestsData.peakH(i) = TestsData.Parameters(i,:).PeakSPVHR;
    TestsData.peakV(i) = TestsData.Parameters(i,:).PeakSPVVR;
    TestsData.peakT(i) = TestsData.Parameters(i,:).PeakSPVTR;
    
    if categorical(TestsData.OTOSuiteResultH(i))=='No'
        grp.h(i) = 2;
    elseif categorical(TestsData.OTOSuiteResultH(i))=='None'
        grp.h(i) = 3;
    end
    
    if categorical(TestsData.OTOSuiteResultV(i))=='No'
        grp.h(i) = 2;
    elseif categorical(TestsData.OTOSuiteResultV(i))=='None'
        grp.h(i) = 3;
    end
    
end


%% For validating the otosuite threshold of 10 deg/sec on the otosuite data
% clearvars
% close all;

 allTable = readtable('/mnt/sai/DATA/AVERTnystagmus/NystagmusData.xlsx');
 patientID = allTable.PatientID;
%  load('/home/sai/Documents/MastersResearch/Thesis/code/AvertNystagmus/Initial Data Gathering/TestData.mat');
 countH = 0;
 countV = 0;
 
 TestsData.peakH = zeros(height(TestsData),1);
 TestsData.peakV = zeros(height(TestsData),1);
 TestsData.peakT = zeros(height(TestsData),1);
 TestsData.LabelMatchH = zeros(height(TestsData),1);
 TestsData.LabelMatchV = zeros(height(TestsData),1);

 % Exporting the Manual-Otosuite Results from allTable to TestsData
 for i = 1:height(allTable)
     if allTable.NumMatches(i) == 1
         idx = find(categorical(TestsData.PatientID)==categorical(allTable.PatientID(i)) & categorical(TestsData.NewTestName)==categorical(allTable.NewTestName(i)));
         if categorical(TestsData.TestUID(idx))==categorical(allTable.MatchedTestUID(i))
             TestsData.OTOSuiteResultH{idx} = allTable.OTOSuiteResultH{i};
             TestsData.OTOSuiteResultV{idx} = allTable.OTOSuiteResultV{i};
             TestsData.ManualResultH{idx} = allTable.ManualResultH{i};
             TestsData.ManualResultV{idx} = allTable.ManualResultV{i};
         else
             error('no matched patient file')
         end
         
     end
 end

 for i=1:height(arume.currentProject.sessionsTable)
     
     filename = arume.currentProject.sessionsTable.Subject(i);
     temp = split(char(filename),'_');
     patientID = strjoin({temp{2},temp{3}},'-');
     clear temp
     
     testName = arume.currentProject.sessionsTable.SessionCode(i);
     
     idx = find(categorical(TestsData.PatientID)==patientID & categorical(TestsData.NewTestName)==testName);
     if numel(idx)~=1
         error('Did not find the corresponding test data');
     end
     
     TestsData.peakH(idx) = TestsData.Parameters(idx,:).PeakSPVHR*10;
     TestsData.peakV(idx) = TestsData.Parameters(idx,:).PeakSPVVR*10;
     TestsData.peakT(idx) = TestsData.Parameters(idx,:).PeakSPVTR*10;
     
%      TestsData.peakH(idx) = nanmean(TestsData.XmlData{idx,:}.HR);
%      TestsData.peakV(idx) = nanmean(TestsData.XmlData{idx,:}.VR);
%      TestsData.peakT(idx) = nanmean(TestsData.XmlData{idx,:}.TR);
     
     if abs(TestsData.peakH(idx))<10
         TestsData.OTOSuiteResultMatchingH{idx} = 'No';
     elseif abs(TestsData.peakH(idx))>=10 && abs(TestsData.peakH(idx))<800
         TestsData.OTOSuiteResultMatchingH{idx} = 'Yes';
     elseif abs(TestsData.peakH(idx))>800
         TestsData.OTOSuiteResultMatchingH{idx} = 'None';
     end
     
     if abs(TestsData.peakV(idx))<10 
         TestsData.OTOSuiteResultMatchingV{idx} = 'No';
     elseif abs(TestsData.peakV(idx))>=10 && abs(TestsData.peakV(idx))<800
         TestsData.OTOSuiteResultMatchingV{idx} = 'Yes';
     elseif abs(TestsData.peakV(idx))>800
         TestsData.OTOSuiteResultMatchingV{idx} = 'None';
     end
     
     if abs(TestsData.peakT(idx))<10 
         TestsData.OTOSuiteResultMatchingT{idx} = 'No';
     elseif abs(TestsData.peakT(idx))>=10 && abs(TestsData.peakT(idx))<800
         TestsData.OTOSuiteResultMatchingT{idx} = 'Yes';
     elseif abs(TestsData.peakT(idx))>800
         TestsData.OTOSuiteResultMatchingT{idx} = 'None';
     end
     
     if isequal(TestsData.OTOSuiteResultMatchingH(idx),TestsData.OTOSuiteResultH(idx))
%          disp('equalH');
         TestsData.LabelMatchH(idx) = 1;
         countH = countH + 1;
     else
         disp(['unequalH',TestsData.ParentTestName(idx), TestsData.peakH(idx),TestsData.OTOSuiteResultMatchingH(idx),TestsData.OTOSuiteResultH(idx),TestsData.Parameters(idx,:).PeakSPVHR]);
         TestsData.LabelMatchH(idx) = 0;
     end
     
     if isequal(TestsData.OTOSuiteResultMatchingV(idx),TestsData.OTOSuiteResultV(idx))
%          disp('equalV');
         TestsData.LabelMatchV(idx) = 1;
         countV = countV + 1;
     else
         disp(['unequalV',TestsData.ParentTestName(idx),TestsData.peakV(idx),TestsData.OTOSuiteResultMatchingV(idx),TestsData.OTOSuiteResultV(idx),TestsData.Parameters(idx,:).PeakSPVVR]);
         TestsData.LabelMatchV(idx) = 0;
     end
     
%      if isequal(TestsData.OTOSuiteResultMatchingT(idx),TestsData.OTOSuiteResultH(idx))
%          TestsData.LabelMatchTwH(idx) = 1;
%      else
%          TestsData.LabelMatchTwH(idx) = 0;
%      end
%      
%      if isequal(TestsData.OTOSuiteResultMatchingT(idx),TestsData.OTOSuiteResultV(idx))
%          TestsData.LabelMatchTwV(idx) = 1;
%      else
%          TestsData.LabelMatchTwV(idx) = 0;
%      end
     
 end

 
 %% For validating the arume analysisResults with the manual results
 
 load('/mnt/sai/DATA/AVERTnystagmus/TestsDataNew.mat');
 
 
 for i = 1:572

     types = {'SPV_Otosuite','SPV_QP_SP','SPV_Simple'};
     meas_label = {'Yes','No','None'};
     signals = {'X','Y','T'};
     
     results = table();
     
     for j = 1:numel(types)
         for k = 1:numel(signals)
             
             spv = nanmax(arume.currentProject.sessions(1,i).(types{j}).(signals{k}));
             
             if spv<
                 
             end
             
         end         
     end 
     
 end
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
