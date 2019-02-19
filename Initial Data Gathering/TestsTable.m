%% To make individual mat files corresponding to the test performed

clearvars

load('/mnt/sai/DATA/AVERTnystagmus/testNames.mat');
folders = dir('/mnt/sai/DATA/AVERTnystagmus/AllData');
foldertoSave = '/mnt/sai/DATA/AVERTnystagmus/IndividualTestData2';
TestsData = table();
num_times_gazebeatsvel = 1;

for i= 1:numel(folders)
    
    if folders(i).name(1) == '.'
       continue; 
    end
    
    subjFolder = fullfile(folders(i).folder,folders(i).name);
    subjFile = dir(fullfile(subjFolder,'*.xml'));
     for j=1:numel(subjFile)
        subjFilename = fullfile(subjFolder,subjFile(j).name);     
        TestsData= genData(subjFilename,foldertoSave,testNames);
%         TestsData = [TestsData;testsTable];
        clear TestsData;   
        disp(i)
%         num_times_gazebeatsvel = num_times+num_times_gazebeatsvel;
     end
     
     fclose all;
    
end

%% To make one big table having the details

clearvars

load('/mnt/sai/DATA/AVERTnystagmus/testNames.mat');
folders = dir('/mnt/sai/DATA/AVERTnystagmus/AllData');
% foldertoSave = '/mnt/sai/DATA/AVERTnystagmus/TestsData/';
TestsData = table();
num_times_gazebeatsvel = 0;

for i= 1:numel(folders)
    
    if folders(i).name(1) == '.'
       continue; 
    end
    
    subjFolder = fullfile(folders(i).folder,folders(i).name);
    subjFile = dir(fullfile(subjFolder,'*.xml'));
     for j=1:numel(subjFile)
        subjFilename = fullfile(subjFolder,subjFile(j).name);     
        [testsTable,num_times] = genData(subjFilename,testNames);
        TestsData = [TestsData;testsTable];
        clear testsTable;   
        disp(i)
        num_times_gazebeatsvel = num_times+num_times_gazebeatsvel;
     end
     
     fclose all;    
end

writetable(TestsData,'TestsData1.mat');

pause;

%%  Changing the original test name to the new test name in the big table

for i=1:height(TestsData)
if contains(TestsData.VisionDenied{i},'true')
prefix = {'Deny'};
else
prefix = {'Fix'};
end
testName = testNames.New(contains(testNames.Original,TestsData.TestType(i)));
if isempty(testName)
continue;
end
newName = strjoin({prefix{1},testName{1}},'_');
TestsData.NewTestName(i) = {newName};
end


%% To make two different files corresponding to SPV and Raw data as per each test performed

% clearvars

load('/mnt/sai/DATA/AVERTnystagmus/testNames.mat');
foldertoSave = '/mnt/sai/DATA/AVERTnystagmus/Raw&SPVTestData3';
folders = struc2table(dir('/mnt/sai/DATA/AVERTnystagmus/IndividualTestData12Tests'));

% [~,~,raw] = xlsread('/mnt/sai/DATA/AVERTnystagmus/Nystagmus-Validation-Total (03292017).xlsx');
% patientIDs = raw(1, 11:end);
% clear raw

file_names = cell(numel(folders),0);
for i =1:numel(folders)
file_names{i}=folders(i).name;
end

suffix={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','AA','BB','CC','DD','EE','FF','GG','HH','II','JJ','KK','LL','MM','NN','OO','PP','QQ','RR','SS'};

count = 0; 

 for i = 1:numel(patientIDs)  
     
    Index = find(contains(folder.name,patientIDs{i}));
    count = count + numel(Index); 
    
    for j=1:numel(Index)
        
        load(fullfile(folders.folder(Index(j)),folders.name(Index(j))));
        
        if contains(TestsTable.VisionDenied,'true')
            prefix = {'Deny'};
        else
            prefix = {'Fix'};
        end
        
        testName = testNames.New(contains(testNames.Original,TestsTable.TestType));
        patientID = strrep(TestsTable.PatientID,'-','_');
        
        if isempty(testName)
            disp(i)
            disp('No such test')
            continue;
        end
        
        filename_raw = strjoin({'S',patientID{1},suffix{j},prefix{1},testName{1},'RAW'},'_');
        filename_spv = strjoin({'S',patientID{1},suffix{j},prefix{1},testName{1},'SPV'},'_');
        
        clear patientID testName prefix
        
        raw = TestsTable.RawData{1};
        spv = TestsTable.XmlData{1};
        
        save(fullfile(foldertoSave,filename_raw),'raw');
        save(fullfile(foldertoSave,filename_spv),'spv');
        
        clear raw spv filename_raw filename_spv
        
    end
    
    disp(i)
     
 end

%%
