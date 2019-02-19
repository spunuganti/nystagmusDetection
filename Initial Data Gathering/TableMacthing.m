%% Variable Import

 [~,~,raw] = xlsread('/mnt/sai/DATA/AVERTnystagmus/Nystagmus-Validation-Total (03292017).xlsx');
 PaulTable = readtable('/mnt/sai/DATA/AVERTnystagmus/NystagmusData.xlsx');
 patientIDs = raw(1, 11:end);
 clear raw
 PaulTable.MatchedTestUID = zeros(1515,1); %repmat({''}, 1515, 1); 
 PaulTable.NumMatches = zeros(1515,1);
 
 %% Matching PAuls Data withh the OtosuiteData with as per the test performed
 countones = 0;
 for i = 1:numel(patientIDs)     
     testidxPaul = find(categorical(PaulTable.PatientID)==patientIDs{i});
     sub = TestsData(categorical(TestsData.PatientID)==patientIDs{i},:);
     
     for m = 1:numel(testidxPaul)
         idx = find(categorical(sub.NewTestName) == categorical(PaulTable.NewTestName(testidxPaul(m))));
         matches = numel(idx);
         %          for n = 1:numel(idx)
         %             if isequal(sub.VisionDenied(idx(n)),PaulTable.VisionDenied(testidxPaul(m)))
         %                 matches = matches+1;
         %             end
         %          end
         %
         PaulTable.NumMatches(testidxPaul(m)) = matches;
         if matches == 1
             PaulTable.MatchedTestUID(testidxPaul(m)) = str2double(sub.TestUID(idx));
             countones = countones+1;
         end
     end     
 end
 
 
%% To see between Paul's Labeling And The otosuite results

TestsData.PatientID = categorical(TestsData.PatientID);
TestsData.NewTestName = categorical(TestsData.NewTestName);
PaulTable.PatientID = categorical(PaulTable.PatientID);
PaulTable.NewTestName = categorical(PaulTable.NewTestName);
TestsData.ManualVsOTOSuiteH = repmat({''},height(TestsData),1);
TestsData.ManualVsOTOSuiteV = repmat({''},height(TestsData),1);

for i=1:height(TestsData)
   
   idx = find(PaulTable.PatientID == TestsData.PatientID(i) & PaulTable.NewTestName==TestsData.NewTestName(i));
   if numel(idx)~=1
       error('No Matching Subject and test session found')
   end
   
   TestsData.ManualVsOTOSuiteH{i,1} = PaulTable.ManualVsOTOSuiteH{idx,1};
   TestsData.ManualVsOTOSuiteV{i,1} = PaulTable.ManualVsOTOSuiteV{idx,1};
end

TestsData.ManualVsOTOSuiteH = categorical(TestsData.ManualVsOTOSuiteH);
TestsData.ManualVsOTOSuiteV = categorical(TestsData.ManualVsOTOSuiteV);

numbs = table();
binsnames = {'One','Two','Three','Four','Five','Six','Seven','Eight'};

sigshv = {'H','V'};

for k=1:numel(sigshv)
    for j=1:8
        
        if j==8
            idx = find(abs(TestsData.(['peak' sigshv{k}]))>=j*2-2 & abs(TestsData.(['peak' sigshv{k}]))<20);
        else
            idx = find(abs(TestsData.(['peak' sigshv{k}]))>=j*2-2 & abs(TestsData.(['peak' sigshv{k}]))<j*2);
        end
        
        numbs.([binsnames{j} sigshv{k}])(1,1) = numel(find(TestsData.(['ManualVsOTOSuite' sigshv{k}])(idx)=='TP')); %TP
        numbs.([binsnames{j} sigshv{k}])(2,1) = numel(find(TestsData.(['ManualVsOTOSuite' sigshv{k}])(idx)=='TN')); %TN
        numbs.([binsnames{j} sigshv{k}])(3,1) = numel(find(TestsData.(['ManualVsOTOSuite' sigshv{k}])(idx)=='FP')); %FP
        numbs.([binsnames{j} sigshv{k}])(4,1) = numel(find(TestsData.(['ManualVsOTOSuite' sigshv{k}])(idx)=='FN')); %FN
        
    end
end

subplot(121)
bar([numbs.OneH';numbs.TwoH';numbs.ThreeH';numbs.FourH';numbs.FiveH';numbs.SixH';numbs.SevenH';numbs.EightH'],'stacked');
legend('TP','TN','FP','FN');
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('All Tests Horizontal','FontName','Kinnari');
xticklabels({'0-2','2-4','4-6','6-8','8-10','10-12','12-14','14-20'})

subplot(122)
bar([numbs.OneV';numbs.TwoV';numbs.ThreeV';numbs.FourV';numbs.FiveV';numbs.SixV';numbs.SevenV';numbs.EightV'],'stacked');
legend('TP','TN','FP','FN');
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('All Tests Vertical','FontName','Kinnari');
xticklabels({'0-2','2-4','4-6','6-8','8-10','10-12','12-14','14-20'})

 %% Changing some variable names and making the FN,FP,TP,TN to Yes and No
 
PaulTable.Properties.VariableNames{'SoftwareOutcomeV'} = 'OTOSuiteResultV';
PaulTable.Properties.VariableNames{'SoftwareOutcomeH'} = 'OTOSuiteResultH';
PaulTable.Properties.VariableNames{'ManualOutcomeV'} = 'ManualVsOTOSuiteV';
PaulTable.Properties.VariableNames{'ManualOutcomeH'} = 'ManualVsOTOSuiteH';
 
PaulTable.ManualResultH = repmat({''}, 1515, 1); 
PaulTable.ManualResultV = repmat({''}, 1515, 1);

idx = contains(PaulTable.ManualVsOTOSuiteH,'TN') | contains(PaulTable.ManualVsOTOSuiteH,'FP');
PaulTable.ManualResultH(idx) = {'No'};
clear idx
idx = contains(PaulTable.ManualVsOTOSuiteH,'TP') | contains(PaulTable.ManualVsOTOSuiteH,'FN');
PaulTable.ManualResultH(idx) = {'Yes'};
clear idx
idx = contains(PaulTable.ManualVsOTOSuiteV,'TN') | contains(PaulTable.ManualVsOTOSuiteV,'FP');
PaulTable.ManualResultV(idx) = {'No'};
clear idx
idx = contains(PaulTable.ManualVsOTOSuiteV,'TP') | contains(PaulTable.ManualVsOTOSuiteV,'FN');
PaulTable.ManualResultV(idx) = {'Yes'};
clear idx


for i =1:size(PaulTable,1)
if isequal(PaulTable.ManualResultV(i),{''})
PaulTable.ManualResultV(i) = PaulTable.ManualVsOTOSuiteV(i);
end

if isequal(PaulTable.ManualResultH(i),{''})
PaulTable.ManualResultH(i) = PaulTable.ManualVsOTOSuiteH(i);
end
end

idx = find(contains(PaulTable.ManualVsOTOSuiteV,'NaN'));












 
 