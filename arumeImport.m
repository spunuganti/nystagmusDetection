
%%
projectPath = '/mnt/sai/DATA/AVERTnystagmus/AvertNystagmusArumeProject';

%% create new project
arume = Arume('nogui');
[parentPath, projectName] = fileparts(projectPath);
arume.newProject(parentPath,projectName);

%% OR load existing project
arume = Arume('nogui');
arume.loadProject(projectPath);

%%

dataLocation = '/mnt/sai/DATA/AVERTnystagmus/Raw&SPVTestData';
folders = struct2table(dir('/mnt/sai/DATA/AVERTnystagmus/Raw&SPVTestData'));
allTable = readtable('/mnt/sai/DATA/AVERTnystagmus/NystagmusData.xlsx');
% idx = find(allTable.NumMatches==1);

idx = [5;13;30;36;54;61;70;92;99;104;116;124;127;170;183;216;227;228;245;250;251;268;269;272;312;313;319;323;346;350;356;367;372;403;412;437;451;462;467;475;476;478;498;503;533;540];

temp = allTable;
temp.PatientID = categorical(temp.PatientID);
temp.NewTestName = categorical(temp.NewTestName);
idx = find(temp.PatientID=='101-127' & temp.NewTestName=='Deny_GazeR');
clear temp

for i = 1:numel(idx)
    
    subject = strrep(allTable.PatientID(idx(i)),'-','_');
    subject = strjoin({'S',subject{1}},'_');
    
    if ~isequal(subject,'S_103_151')
    sessionCode = char(allTable.NewTestName(idx(i)));
    
    f_raw = find(contains(folders.name,subject) & contains(folders.name,sessionCode) & contains(folders.name,'RAW'));
    f_spv = find(contains(folders.name,subject) & contains(folders.name,sessionCode) & contains(folders.name,'SPV'));
  
    if isempty(f_raw) || isempty(f_spv) || numel(f_raw)>1 || numel(f_spv)>1
        error('Error finding correct Raw / SPV File');
    end
    
    options =[];
    options.RawDataFile = char(fullfile(dataLocation,folders.name(f_raw)));
    options.SpvDataFile = char(fullfile(dataLocation,folders.name(f_spv)));
    
    session = arume.importSession( 'EyeTrackingOtosuite',  subject, sessionCode, options );
        
    fprintf('Session Created For subject: %s test: %s i= %d\n',subject,sessionCode,i);
    else
        continue
    end
end

%%
session.experimentDesign.Plot_VOG_SaccadeTraces
session.experimentDesign.Plot_VOG_MainSequence
session.experimentDesign.Plot_VOG_DebugCleaning
session.experimentDesign.Plot_Example

%%  Re Analysis For checking

% False Positives
% indices = [5;13;30;36;54;61;72;94;101;106;118;126;129;173;186;224;235;236;254;259;260;277;278;282;323;324;330;334;359;363;369;381;386;420;429;454;468;482;487;495;496;498;519;524;554;561];

%False Negatives only in QP_SP
% indices = [306;358;363;370;406;410;411;415;473;482;541;555];
tic
indics=locs;
for i = 1:length(indics)
    
   session = arume.currentProject.sessions(1,indics(i));
   temp = strsplit(session.currentRun.LinkedFiles.vogRawDataFile,'_');
   if ~isequal(strjoin({temp{1},temp{2},temp{3}},'_'),session.subjectCode)
       error('FILES NOT THAT OF CURRENT SUBJECT');
   end
   disp(session.subjectCode);
   clear temp;  
   
%    arume.prepareAnalysis(session);
   opt = arume.getDefaultAnalysisOptions(session);
   opt.Prepare_Samples_Table = 1;
   opt.Prepare_Session_Table = 1;
   opt.Detect_Quik_and_Slow_Phases = 1;
   opt.SPV_Simple = 1;
   opt.SPV_QP_SP = 1;
   opt.HeadVelCorr = 1;
   opt.TestsData = TestsData;
%    opt.SPV_IBDT = 0;
   arume.runDataAnalyses(opt,session);
   disp(i) 
end
toc
%%

for i=512:numel(arume.currentProject.sessions)
    session = arume.currentProject.sessions(1,i);
    temp = strsplit(session.currentRun.LinkedFiles.vogRawDataFile,'_');
    if ~isequal(strjoin({temp{1},temp{2},temp{3}},'_'),session.subjectCode)
        error('FILES NOT THAT OF CURRENT SUBJECT');
    end
    clear temp;
    
    opt = arume.getDefaultAnalysisOptions(session);
    opt.Prepare_Samples_Table = 1;
    opt.Prepare_Trial_Table = 1;
    opt.Prepare_Session_Table = 1;
    opt.Detect_Quik_and_Slow_Phases = 1;
    opt.SPV_Simple = 1;
    opt.SPV_QP_SP = 1;
    opt.HeadVelCorr =1;
    arume.runDataAnalyses(opt,session);
    disp(i)    
end


%% Accounting for the head velocity <- Include code snippets

% first put nans where the position data was removed?
clean.HeadQ1(isnan(clean.RightX) | isnan(clean.RightY)) = nan;
clean.HeadQ2(isnan(clean.RightX) | isnan(clean.RightY)) = nan;
clean.HeadQ3(isnan(clean.RightX) | isnan(clean.RightY)) = nan;
clean.HeadQ4(isnan(clean.RightX) | isnan(clean.RightY)) = nan;
%%
% filtering the head data firstly

headq1 = interp1(clean.Time(~isnan(clean.HeadQ1)),clean.HeadQ1(~isnan(clean.HeadQ1)),clean.Time,'pchip');
HeadQ1=clean.HeadQ1; HeadQ1 = headq1;
plotLo(clean.Time,[clean.HeadQ1,HeadQ1]);

sig =  clean.HeadQ1( ~isnan(clean.HeadQ1));
xdd = wden(sig,'sqtwolog','s','mln',5,'db6');
figure; a1 = subplot(211);plot(sig);a2 = subplot(212); plot(xdd);
linkaxes([a1 a2],'xy');
clean.HeadQ1(~isnan(clean.HeadQ1)) = xdd;
sig =  clean.HeadQ2( ~isnan(clean.HeadQ2));
xdd = wden(sig,'sqtwolog','s','mln',5,'db6');
figure; a1 = subplot(211);plot(sig);a2 = subplot(212); plot(xdd);
linkaxes([a1 a2],'xy');
clean.HeadQ2(~isnan(clean.HeadQ2)) = xdd;
sig =  clean.HeadQ3( ~isnan(clean.HeadQ3));
xdd = wden(sig,'sqtwolog','s','mln',5,'db6');
figure; a1 = subplot(211);plot(sig);a2 = subplot(212); plot(xdd);
linkaxes([a1 a2],'xy');
clean.HeadQ3(~isnan(clean.HeadQ3)) = xdd;
sig =  clean.HeadQ4( ~isnan(clean.HeadQ4));
xdd = wden(sig,'sqtwolog','s','mln',5,'db6');
figure; a1 = subplot(211);plot(sig);a2 = subplot(212); plot(xdd);
linkaxes([a1 a2],'xy');
clean.HeadQ4(~isnan(clean.HeadQ4)) = xdd;
%%
% Also maybe remove the last sample since its always giving a very huge
% value

% Compute the angular velocity
q = quaternion([clean.HeadQ1,clean.HeadQ2,clean.HeadQ3,clean.HeadQ4]);
q = Normalizen(q);
[omega,axis] = OmegaAxis(q,clean.Time);
figure;plot(omega)
mn=nanmean(omega);
sd=nanstd(omega);
mn+1*sd
mn+2*sd
mn+3*sd
mn+4*sd %% <- mostly going to use this threshold

% filtering the omega angular velocity
temp = sgolayfilt(omega(~isnan(omega)),1,21); 
chk = omega; chk(~isnan(chk))=temp; clear temp;
% chk(chk<0)=nan; % since all values of omega are positive 
plotLo(clean.Time,[omega',chk',clean.HeadQ1]);
% TO DO: better implementation than thresholding like peak detection maybe?
mn=nanmean(chk); 
sd=nanstd(chk);
mn+1*sd
mn+2*sd
mn+3*sd
mn+4*sd


