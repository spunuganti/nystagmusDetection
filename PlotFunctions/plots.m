%% ROC curve for Otosuite, Simple, QP_SP algos

load('/mnt/sai/DATA/AVERTnystagmus/TestsData.mat'); % /smb://10.17.101.33/vorlab/DATA/AVERTnystagmus
countdisc = 0;
countexc = 0;
results = table();                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
warning('off','all')

%** inds = [1:241,243:572]'; % 14th Jan Edit: i=242 has LabelMatchingV = 0;

for i=1:572
    
%**     i = inds(j);
    subjID = arume.currentProject.sessions(1, i).subjectCode;
    
    results.patientID{i,1} = subjID;
    temp = split(subjID,'_');
    subjID = strjoin({temp{2},temp{3}},'-');
    clear temp
    test = arume.currentProject.sessions(1, i).sessionCode;
    
    idx = find(categorical(TestsData.PatientID) == subjID & categorical(TestsData.NewTestName) == test);
    if numel(idx)~=1
        error('No Matching Subject & Test Found')
    end
       
    % ??WhY?? 
    if TestsData.LabelMatchH(idx) ==0 || TestsData.LabelMatchV(idx) ==0 || isempty(arume.currentProject.sessions(1,i).analysisResults)
%         error('CountDiscrepancy')
        countdisc = countdisc+1;
        continue
    end
    
    results.subjID{i,1} = subjID;
    results.session{i,1} = test;                                                                                                                                                                                                        
    
    sigsxy = {'RightX','RightY'};
    methods = {'SPV_QP_SP','SPV_Simple','SPV_Otosuite'};
    sigshv = {'H','V'};
    
    for j=1:numel(methods)
        if j~=3
            for k=1:numel(sigsxy)
                nom = strjoin({methods{j},sigsxy{k}},'_');

%%% Window Time and taking max of three points in the same direction in that
% window


%%% Mean of three values at the max value point                
%                 [~,ndx] = nanmax(abs(arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k})));
%                 if ndx~=numel(arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k}))
%                     if ndx~=1
%                         results.(nom)(i,1) = nanmean(arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k})(ndx-1:ndx+1,1));
%                     else
%                         results.(nom)(i,1) = nanmean(arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k})(ndx:ndx+1,1));
%                     end
%                 elseif ndx==numel(arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k}))
%                     results.(nom)(i,1) = nanmean(arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k})(ndx-1:ndx,1));
%                 end                    

%%% Just max value
%                 [~,ndx] = nanmax(abs(arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k})));
%                 results.(nom)(i,1) = arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k})(ndx,1);
          
%%% Mean of first three max values
                [~,ndx] = sort((abs(arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k}))),'descend','MissingPlacement','last');
                results.(nom)(i,1) = nanmean(arume.currentProject.sessions(1,i).analysisResults.(methods{j}).(sigsxy{k})(ndx(1:3),1));
            end
        else
            for k=1:numel(sigshv)
                nom = strjoin({methods{j},sigsxy{k}},'_');
                results.(nom)(i,1) = TestsData.(strjoin({'peak',sigshv{k}},''))(idx);
            end
        end
    end
    
    for k = 1:numel(sigshv)
        if categorical(TestsData.(['ManualResult' sigshv{k}])(idx))=='No'
            results.(['Manual_' sigsxy{k}])(i,1) = -1;
        elseif categorical(TestsData.(['ManualResult' sigshv{k}])(idx))=='Yes'
            results.(['Manual_' sigsxy{k}])(i,1) = 1;
        end
    end
    
end

disp('Results Table Done...');
%%
results=results(~cellfun(@isempty,results.subjID),:);
inds=(abs(results.SPV_Otosuite_RightX)>=900 | abs(results.SPV_Otosuite_RightY)>=900);
% % results(inds,:)=[];
results.SPV_Otosuite_RightX(inds,:) = 0; 
results.SPV_Otosuite_RightY(inds,:) = 0; 
results(isnan(results.SPV_QP_SP_RightX) | isnan(results.SPV_QP_SP_RightY),:)=[]; % | isnan(results.SPV_Simple_RightX) | isnan(results.SPV_Simple_RightY),:) = [];

clear subjID test nom ndx countdisc countexc

%% To get the indices of False cases

% inds = find(Pt.SessionCode=='Deny_DixL' | Pt.SessionCode=='Deny_DixR' | Pt.SessionCode=='Deny_RollL' | Pt.SessionCode=='Deny_RollR');

sigsxy = {'RightX','RightY'};
methods = {'SPV_QP_SP','SPV_Simple','SPV_Otosuite'};

inds = find(contains(results.session,'Dix') | contains(results.session,'Roll'));
indices=[];
for j = 1
    for k = 2
        indices = [indices;find(results.(['Manual_' sigsxy{k}])(inds,:)==1)];% & abs(results.([methods{j} '_' sigsxy{k}])(inds,:))<10)];
    end
end
indices = unique(indices);
inds = inds(indices);

Pt = arume.currentProject.sessionsTable;

sub = table;
sub.patientID = results.patientID(inds);
sub.session = results.session(inds);
sub2 = table;
sub2.patientID = Pt.Subject(1:572);
sub2.session = Pt.SessionCode(1:572);
[~,locs]=intersect(sub2,sub,'rows');

clear Pt sub sub2 indices i j k sigshv
%% %% ROC Curves %%
% For Both Tests
rates = table();

for j = 1:numel(methods)
    for k = 1:numel(sigsxy)
        [rates.([methods{j} '_' sigsxy{k} 'TP']), rates.([methods{j} '_' sigsxy{k} 'FP'])] = roc(results.(['Manual_' sigsxy{k}]),abs(results.([methods{j} '_' sigsxy{k}])));
    end
end

figure;
subplot(231)
plot(rates.SPV_QP_SP_RightXFP,rates.SPV_QP_SP_RightXTP,'LineWidth',2); hold on
plot(rates.SPV_Simple_RightXFP,rates.SPV_Simple_RightXTP,'LineWidth',2); hold on
plot(rates.SPV_Otosuite_RightXFP,rates.SPV_Otosuite_RightXTP,'LineWidth',2); hold on
legend('QP_SP','Simple','Otosuite');
xlabel('False Positive Rate','FontName','Kinnari');
ylabel('True Positive Rate','FontName','Kinnari');
title('All Tests Horizontal','FontName','Kinnari');
subplot(234)
plot(rates.SPV_QP_SP_RightYFP,rates.SPV_QP_SP_RightYTP,'LineWidth',2); hold on
plot(rates.SPV_Simple_RightYFP,rates.SPV_Simple_RightYTP,'LineWidth',2); hold on
plot(rates.SPV_Otosuite_RightYFP,rates.SPV_Otosuite_RightYTP,'LineWidth',2); hold on
legend('QP_SP','Simple','Otosuite');
xlabel('False Positive Rate','FontName','Kinnari');
ylabel('True Positive Rate','FontName','Kinnari');
title('All Tests Vertical','FontName','Kinnari');

% For Gaze Tests
rates=table();
inds = find(contains(results.session,'Gaze'));

for j = 1:numel(methods)
    for k = 1:numel(sigsxy)
        [rates.([methods{j} '_' sigsxy{k} 'TP']), rates.([methods{j} '_' sigsxy{k} 'FP'])] = roc(results.(['Manual_' sigsxy{k}])(inds),abs(results.([methods{j} '_' sigsxy{k}])(inds)));
    end
end

subplot(232)
plot(rates.SPV_QP_SP_RightXFP,rates.SPV_QP_SP_RightXTP,'LineWidth',2); hold on
plot(rates.SPV_Simple_RightXFP,rates.SPV_Simple_RightXTP,'LineWidth',2); hold on
plot(rates.SPV_Otosuite_RightXFP,rates.SPV_Otosuite_RightXTP,'LineWidth',2); hold on
legend('QP_SP','Simple','Otosuite');
xlabel('False Positive Rate','FontName','Kinnari');
ylabel('True Positive Rate','FontName','Kinnari');
title('Gaze Tests Horizontal','FontName','Kinnari');
subplot(235)
plot(rates.SPV_QP_SP_RightYFP,rates.SPV_QP_SP_RightYTP,'LineWidth',2); hold on
plot(rates.SPV_Simple_RightYFP,rates.SPV_Simple_RightYTP,'LineWidth',2); hold on
plot(rates.SPV_Otosuite_RightYFP,rates.SPV_Otosuite_RightYTP,'LineWidth',2); hold on
legend('QP_SP','Simple','Otosuite');
xlabel('False Positive Rate','FontName','Kinnari');
ylabel('True Positive Rate','FontName','Kinnari');
title('Gaze Tests Vertical','FontName','Kinnari');

%%
% For Dynamic Tests
rates=table();
inds = find(contains(results.session,'Dix') | contains(results.session,'Roll'));
% inds = inds(1:135);
for j = 1:numel(methods)
    for k = 1:numel(sigsxy)
        [rates.([methods{j} '_' sigsxy{k} 'TP']), rates.([methods{j} '_' sigsxy{k} 'FP'])] = roc(results.(['Manual_' sigsxy{k}])(inds,:),abs(results.([methods{j} '_' sigsxy{k}])(inds,:)));
    end
end

subplot(121)
plot(rates.SPV_QP_SP_RightXFP,rates.SPV_QP_SP_RightXTP,'LineWidth',2); hold on
plot(rates.SPV_Simple_RightXFP,rates.SPV_Simple_RightXTP,'LineWidth',2); hold on
plot(rates.SPV_Otosuite_RightXFP,rates.SPV_Otosuite_RightXTP,'LineWidth',2); hold on
legend('QP_SP','Simple','Otosuite');
xlabel('False Positive Rate','FontName','Kinnari');
ylabel('True Positive Rate','FontName','Kinnari');
title('Dynamic Tests Horizontal','FontName','Kinnari');
grid on
subplot(122)
plot(rates.SPV_QP_SP_RightYFP,rates.SPV_QP_SP_RightYTP,'LineWidth',2); hold on
plot(rates.SPV_Simple_RightYFP,rates.SPV_Simple_RightYTP,'LineWidth',2); hold on
plot(rates.SPV_Otosuite_RightYFP,rates.SPV_Otosuite_RightYTP,'LineWidth',2); hold on
legend('QP_SP','Simple','Otosuite');
xlabel('False Positive Rate','FontName','Kinnari');
ylabel('True Positive Rate','FontName','Kinnari');
title('Dynamic Tests Vertical','FontName','Kinnari');
grid on

%% %% Bar Graphs Showing the categories %%
% For both tests
classes=table();
map = brewermap(4,'Set1');

for j = 1:numel(methods)
    for k = 1:numel(sigsxy)
        classes.([methods{j} '_' sigsxy{k}])(1,1) =  numel(find(results.(['Manual_' sigsxy{k}])==1 & abs(results.([methods{j} '_' sigsxy{k}]))>=10)); %TP
        classes.([methods{j} '_' sigsxy{k}])(2,1) =  numel(find(results.(['Manual_' sigsxy{k}])==-1 & abs(results.([methods{j} '_' sigsxy{k}]))<10)); %TN
        classes.([methods{j} '_' sigsxy{k}])(3,1) =  numel(find(results.(['Manual_' sigsxy{k}])==-1 & abs(results.([methods{j} '_' sigsxy{k}]))>=10)); %FP
        classes.([methods{j} '_' sigsxy{k}])(4,1) =  numel(find(results.(['Manual_' sigsxy{k}])==1 & abs(results.([methods{j} '_' sigsxy{k}]))<10)); %FN
    end
end

classes.Manual_RightX(1,1) = numel(find(results.Manual_RightX>0));
classes.Manual_RightX(2,1) = numel(find(results.Manual_RightX<0));
classes.Manual_RightX(3:4,1) = 0;

classes.Manual_RightY(1,1) = numel(find(results.Manual_RightY>0));
classes.Manual_RightY(2,1) = numel(find(results.Manual_RightY<0));
classes.Manual_RightY(3:4,1) = 0;

figure
subplot(231) 
b=bar([classes.SPV_QP_SP_RightX';classes.SPV_Simple_RightX';classes.SPV_Otosuite_RightX';classes.Manual_RightX'],'stacked');
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('All Tests Horizontal','FontName','Kinnari');
xticklabels({'QP SP','Simple','Otosuite','Manual'})
% colormap(map)
subplot(234) 
b=bar([classes.SPV_QP_SP_RightY';classes.SPV_Simple_RightY';classes.SPV_Otosuite_RightY';classes.Manual_RightY'],'stacked');
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('All Tests Vertical','FontName','Kinnari');
xticklabels({'QP SP','Simple','Otosuite','Manual'})
% colormap(map)

% For Gaze Tests
inds = find(contains(results.session,'Gaze'));
classes=table();

for j = 1:numel(methods)
    for k = 1:numel(sigsxy)
        classes.([methods{j} '_' sigsxy{k}])(1,1) =  numel(find(results.(['Manual_' sigsxy{k}])(inds,:)==1 & abs(results.([methods{j} '_' sigsxy{k}])(inds,:))>=10)); %TP
        classes.([methods{j} '_' sigsxy{k}])(2,1) =  numel(find(results.(['Manual_' sigsxy{k}])(inds,:)==-1 & abs(results.([methods{j} '_' sigsxy{k}])(inds,:))<10)); %TN
        classes.([methods{j} '_' sigsxy{k}])(3,1) =  numel(find(results.(['Manual_' sigsxy{k}])(inds,:)==-1 & abs(results.([methods{j} '_' sigsxy{k}])(inds,:))>=10)); %FP
        classes.([methods{j} '_' sigsxy{k}])(4,1) =  numel(find(results.(['Manual_' sigsxy{k}])(inds,:)==1 & abs(results.([methods{j} '_' sigsxy{k}])(inds,:))<10)); %FN
    end
end

classes.Manual_RightX(1,1) = numel(find(results.Manual_RightX(inds,:)>0));
classes.Manual_RightX(2,1) = numel(find(results.Manual_RightX(inds,:)<0));
classes.Manual_RightX(3:4,1) = 0;

classes.Manual_RightY(1,1) = numel(find(results.Manual_RightY(inds,:)>0));
classes.Manual_RightY(2,1) = numel(find(results.Manual_RightY(inds,:)<0));
classes.Manual_RightY(3:4,1) = 0;

numel(inds);
sum(classes.Manual_RightX(1:end,1));
sum(classes.Manual_RightX(1:end,1));

subplot(232) 
bar([classes.SPV_QP_SP_RightX';classes.SPV_Simple_RightX';classes.SPV_Otosuite_RightX';classes.Manual_RightX'],'stacked')
legend('TP','TN','FP','FN');
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('Gaze Tests Horizontal','FontName','Kinnari');
xticklabels({'QP SP','Simple','Otosuite','Manual'})
% colormap(map)
subplot(235) 
bar([classes.SPV_QP_SP_RightY';classes.SPV_Simple_RightY';classes.SPV_Otosuite_RightY';classes.Manual_RightY'],'stacked');
legend('TP','TN','FP','FN');
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('Gaze Tests Vertical','FontName','Kinnari');
xticklabels({'QP SP','Simple','Otosuite','Manual'})
% colormap(map)

%%
% For Dynamic Tests
inds = find(contains(results.session,'Dix') | contains(results.session,'Roll'));
sub = results(inds,:);
classes=table();

for j = 1:numel(methods)
    for k = 1:numel(sigsxy)
        classes.([methods{j} '_' sigsxy{k}])(1,1) =  numel(find(sub.(['Manual_' sigsxy{k}])==1 & abs(sub.([methods{j} '_' sigsxy{k}]))>=10)); %TP
        classes.([methods{j} '_' sigsxy{k}])(2,1) =  numel(find(sub.(['Manual_' sigsxy{k}])==-1 & abs(sub.([methods{j} '_' sigsxy{k}]))<10)); %TN
        classes.([methods{j} '_' sigsxy{k}])(3,1) =  numel(find(sub.(['Manual_' sigsxy{k}])==-1 & abs(sub.([methods{j} '_' sigsxy{k}]))>=10)); %FP
        classes.([methods{j} '_' sigsxy{k}])(4,1) =  numel(find(sub.(['Manual_' sigsxy{k}])==1 & abs(sub.([methods{j} '_' sigsxy{k}]))<10)); %FN
    end
end

classes.Manual_RightX(1,1) = numel(find(results.Manual_RightX(inds,:)>0));
classes.Manual_RightX(2,1) = numel(find(results.Manual_RightX(inds,:)<0));
classes.Manual_RightX(3:4,1) = 0;

classes.Manual_RightY(1,1) = numel(find(results.Manual_RightY(inds,:)>0));
classes.Manual_RightY(2,1) = numel(find(results.Manual_RightY(inds,:)<0));
classes.Manual_RightY(3:4,1) = 0;

numel(inds);
sum(classes.Manual_RightX(1:end,1));
sum(classes.Manual_RightX(1:end,1));


subplot(121) 
bar([classes.SPV_QP_SP_RightX';classes.SPV_Simple_RightX';classes.SPV_Otosuite_RightX';classes.Manual_RightX'],'stacked')
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('Dynamic Tests Horizontal','FontName','Kinnari');
xticklabels({'QP SP','Simple','Otosuite','Manual'})
% colormap(map)
subplot(122) 
bar([classes.SPV_QP_SP_RightY';classes.SPV_Simple_RightY';classes.SPV_Otosuite_RightY';classes.Manual_RightY'],'stacked')
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('Dynamic Tests Vertical','FontName','Kinnari');
xticklabels({'QP SP','Simple','Otosuite','Manual'})
% colormap(map)

%% %% Histograms %%%%%%

% For all tests
% map = brewermap(4,'Set2');

figure;
subplot(231)
hold on
histf(results.SPV_Otosuite_RightX,-20:0.4:20,'facecolor',map(3,:),'facealpha',.5,'edgecolor','none')
histf(results.SPV_Simple_RightX,-20:0.4:20,'facecolor',map(2,:),'facealpha',.5,'edgecolor','none')
histf(results.SPV_QP_SP_RightX,-20:0.4:20,'facecolor',map(1,:),'facealpha',.5,'edgecolor','none')
box off
axis tight
legalpha('Otosuite','Simple','QPSP','location','northwest')
legend boxoff
%%
% OR
map = brewermap(3,'Set1');
figure;
x = -20:0.9:20;
subplot(231)
[counts1, binCenters1] = hist(results.SPV_QP_SP_RightX,x);
[counts2, binCenters2] = hist(results.SPV_Simple_RightX, x);
[counts3, binCenters3] = hist(results.SPV_Otosuite_RightX,x);
plot(binCenters1,counts1,'-','Color',map(1,:),'LineWidth',2); hold on
plot(binCenters2,counts2,'-','Color',map(3,:),'LineWidth',2); 
plot(binCenters3,counts3,'-','Color',map(2,:),'LineWidth',2); 
legend('QP_SP','Simple','Otosuite');
xlabel('PeakVelocity in deg/sec','FontName','Kinnari');
ylabel('Count','FontName','Kinnari');
title('All Tests Horizontal','FontName','Kinnari');
grid minor

subplot(234)
[counts1, binCenters1] = hist(results.SPV_QP_SP_RightY, x);
[counts2, binCenters2] = hist(results.SPV_Simple_RightY, x);
[counts3, binCenters3] = hist(results.SPV_Otosuite_RightY, x);
plot(binCenters1,counts1,'-','Color',map(1,:),'LineWidth',2); hold on
plot(binCenters2,counts2,'-','Color',map(3,:),'LineWidth',2); 
plot(binCenters3,counts3,'-','Color',map(2,:),'LineWidth',2); 
legend('QP_SP','Simple','Otosuite');
xlabel('PeakVelocity in deg/sec','FontName','Kinnari');
ylabel('Count','FontName','Kinnari');
title('All Tests Horizontal','FontName','Kinnari');
grid minor

% For Gaze Tests
inds = find(contains(results.session,'Gaze'));
x = -20:0.9:20;
subplot(232)
[counts1, binCenters1] = hist(results.SPV_QP_SP_RightX(inds,:), x);
[counts2, binCenters2] = hist(results.SPV_Simple_RightX(inds,:), x);
[counts3, binCenters3] = hist(results.SPV_Otosuite_RightX(inds,:), x);
plot(binCenters1,counts1,'-','Color',map(1,:),'LineWidth',2); hold on
plot(binCenters2,counts2,'-','Color',map(3,:),'LineWidth',2); 
plot(binCenters3,counts3,'-','Color',map(2,:),'LineWidth',2); 
legend('QP_SP','Simple','Otosuite');
xlabel('PeakVelocity in deg/sec','FontName','Kinnari');
ylabel('Count','FontName','Kinnari');
title('Gaze Tests Horizontal','FontName','Kinnari');
grid minor

subplot(235)
[counts1, binCenters1] = hist(results.SPV_QP_SP_RightY(inds,:), x);
[counts2, binCenters2] = hist(results.SPV_Simple_RightY(inds,:), x);
[counts3, binCenters3] = hist(results.SPV_Otosuite_RightY(inds,:), x);
plot(binCenters1,counts1,'-','Color',map(1,:),'LineWidth',2); hold on
plot(binCenters2,counts2,'-','Color',map(3,:),'LineWidth',2); 
plot(binCenters3,counts3,'-','Color',map(2,:),'LineWidth',2); 
legend('QP_SP','Simple','Otosuite');
xlabel('PeakVelocity in deg/sec','FontName','Kinnari');
ylabel('Count','FontName','Kinnari');
title('Gaze Tests Vertical','FontName','Kinnari');
grid minor

% For Dynamic Tests

inds = find(contains(results.session,'Dix') | contains(results.session,'Roll'));
x = -20:1.5:20;
subplot(233)
[counts1, binCenters1] = hist(results.SPV_QP_SP_RightX(inds,:), x);
[counts2, binCenters2] = hist(results.SPV_Simple_RightX(inds,:), x);
[counts3, binCenters3] = hist(results.SPV_Otosuite_RightX(inds,:), x);
plot(binCenters1,counts1,'-','Color',map(1,:),'LineWidth',2); hold on
plot(binCenters2,counts2,'-','Color',map(3,:),'LineWidth',2); 
plot(binCenters3,counts3,'-','Color',map(2,:),'LineWidth',2); 
legend('QP_SP','Simple','Otosuite');
xlabel('PeakVelocity in deg/sec','FontName','Kinnari');
ylabel('Count','FontName','Kinnari');
title('Dynamic Tests Horizontal','FontName','Kinnari');
grid minor

subplot(236)
[counts1, binCenters1] = hist(results.SPV_QP_SP_RightY(inds,:), x);
[counts2, binCenters2] = hist(results.SPV_Simple_RightY(inds,:), x);
[counts3, binCenters3] = hist(results.SPV_Otosuite_RightY(inds,:), x);
plot(binCenters1,counts1,'-','Color',map(1,:),'LineWidth',2); hold on
plot(binCenters2,counts2,'-','Color',map(3,:),'LineWidth',2); 
plot(binCenters3,counts3,'-','Color',map(2,:),'LineWidth',2); 
legend('QP_SP','Simple','Otosuite');
xlabel('PeakVelocity in deg/sec','FontName','Kinnari');
ylabel('Count','FontName','Kinnari');
title('Dynamic Tests Vertical','FontName','Kinnari');
grid minor

%% Working with ProjectTable instead of results Table

inds = find(contains(results.session,'Dix') | contains(results.session,'Roll'));

Pt = arume.currentProject.sessionsTable;

sub = table;
sub.patientID = results.patientID(inds);
sub.session = results.session(inds);
sub2 = table;
sub2.patientID = Pt.Subject(1:572);
sub2.session = Pt.SessionCode(1:572);
[~,locs]=intersect(sub2,sub,'rows');

clear sub sub2 Pt

results.patientID =categorical(results.patientID);
results.session =categorical(results.session);

for i =1:numel(inds)
    if ProjectTable.Subject(locs(i)) == results.patientID(inds(i)) && ProjectTable.SessionCode(locs(i)) == results.session(inds(i))
        ProjectTable.Manual_RightX(locs(i),1) = results.Manual_RightX(inds(i),1);
        sub.Manual_RightX(i,1) = results.Manual_RightX(inds(i),1);
        ProjectTable.Manual_RightY(locs(i),1) = results.Manual_RightY(inds(i),1);        
        sub.Manual_RightY(i,1) = results.Manual_RightY(inds(i),1);        
    else
        error('no matching subject and session')
    end
end


sub = ProjectTable(locs,:);

for p =1:height(sub)
        subb = sub.SPV_QP_SP{p,1};
        for k =1:2
            [~,ndx] = sort(abs(subb.(sigsxy{k})),'descend','MissingPlacement','last');
%             [~,id]=nanmax(abs(subb.(sigsxy{k})));
            sub.(['SPV_QP_SP' 'Result' sigsxy{k}])(p,1) =nanmean(subb.(sigsxy{k})(ndx(1:3),1));
        end
    
end

for p=1:height(sub)
    for k=1:2
        if sub.Subject(p,1) == results.patientID(inds(p),1) && sub.SessionCode(p,1) == results.session(inds(p),1)
            sub.(['SPV_Otosuite' 'Result' sigsxy{k}])(p,1) = results.(['SPV_Otosuite_' sigsxy{k}])(inds(p),1);
        else
            error('no matching sub');
        end
    end    
end
        
classes = table();

for j = 1:numel(methods)
    for k = 1:numel(sigsxy)
        classes.([methods{j} '_' sigsxy{k}])(1,1) =  numel(find(sub.(['Manual_' sigsxy{k}])==1 & abs(sub.([methods{j} 'Result' sigsxy{k}]))>=10)); %TP
        classes.([methods{j} '_' sigsxy{k}])(2,1) =  numel(find(sub.(['Manual_' sigsxy{k}])==-1 & abs(sub.([methods{j} 'Result' sigsxy{k}]))<10)); %TN
        classes.([methods{j} '_' sigsxy{k}])(3,1) =  numel(find(sub.(['Manual_' sigsxy{k}])==-1 & abs(sub.([methods{j} 'Result' sigsxy{k}]))>=10)); %FP
        classes.([methods{j} '_' sigsxy{k}])(4,1) =  numel(find(sub.(['Manual_' sigsxy{k}])==1 & abs(sub.([methods{j} 'Result' sigsxy{k}]))<10)); %FN
    end
end

classes.Manual_RightX(1,1) = numel(find(results.Manual_RightX(inds,:)>0));
classes.Manual_RightX(2,1) = numel(find(results.Manual_RightX(inds,:)<0));
classes.Manual_RightX(3:4,1) = 0;

classes.Manual_RightY(1,1) = numel(find(results.Manual_RightY(inds,:)>0));
classes.Manual_RightY(2,1) = numel(find(results.Manual_RightY(inds,:)<0));
classes.Manual_RightY(3:4,1) = 0;

numel(inds);
sum(classes.Manual_RightX(1:end,1));
sum(classes.Manual_RightX(1:end,1));


subplot(121) 
bar([classes.SPV_QP_SP_RightX';classes.SPV_Simple_RightX';classes.SPV_Otosuite_RightX';classes.Manual_RightX'],'stacked')
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('Dynamic Tests Horizontal','FontName','Kinnari');
xticklabels({'QP SP','Simple','Otosuite','Manual'})
legend('TP','TN','FP','FN');
% colormap(map)
subplot(122) 
bar([classes.SPV_QP_SP_RightY';classes.SPV_Simple_RightY';classes.SPV_Otosuite_RightY';classes.Manual_RightY'],'stacked')
xlabel('Classes','FontName','Kinnari');
ylabel('#Number of Classififcations','FontName','Kinnari');
title('Dynamic Tests Vertical','FontName','Kinnari');
xticklabels({'QP SP','Simple','Otosuite','Manual'})

% ROC
rates=table();

for j = 1:numel(methods)
    for k = 1:numel(sigsxy)
        [rates.([methods{j} '_' sigsxy{k} 'TP']), rates.([methods{j} '_' sigsxy{k} 'FP'])] = roc(sub.(['Manual_' sigsxy{k}])(:,1),abs(sub.([methods{j} 'Result' sigsxy{k}])(:,1)));
    end
end

subplot(121)
plot(rates.SPV_QP_SP_RightXFP,rates.SPV_QP_SP_RightXTP,'LineWidth',2); hold on
plot(rates.SPV_Simple_RightXFP,rates.SPV_Simple_RightXTP,'LineWidth',2); hold on
plot(rates.SPV_Otosuite_RightXFP,rates.SPV_Otosuite_RightXTP,'LineWidth',2); hold on
legend('QP_SP','Simple','Otosuite');
xlabel('False Positive Rate','FontName','Kinnari');
ylabel('True Positive Rate','FontName','Kinnari');
title('Dynamic Tests Horizontal','FontName','Kinnari');
subplot(122)
plot(rates.SPV_QP_SP_RightYFP,rates.SPV_QP_SP_RightYTP,'LineWidth',2); hold on
plot(rates.SPV_Simple_RightYFP,rates.SPV_Simple_RightYTP,'LineWidth',2); hold on
plot(rates.SPV_Otosuite_RightYFP,rates.SPV_Otosuite_RightYTP,'LineWidth',2); hold on
legend('QP_SP','Simple','Otosuite');
xlabel('False Positive Rate','FontName','Kinnari');
ylabel('True Positive Rate','FontName','Kinnari');
title('Dynamic Tests Vertical','FontName','Kinnari');



%% For validating Otosuite results and finding threshold using plots

% load('/mnt/sai/DATA/AVERTnystagmus/TestsDataNew.mat');
% 
% TestsData.ParentTestName = categorical(TestsData.ParentTestName);
% TestsData.OTOSuiteResultH = categorical(TestsData.OTOSuiteResultH);
% TestsData.OTOSuiteResultV = categorical(TestsData.OTOSuiteResultV);
% 
% idxGaze = find(TestsData.ParentTestName=='VW_GazeTest');
% idxDyn = find(TestsData.ParentTestName=='VW_DynamicTest');
% 
% subplot(221); gscatter(TestsData.Parameters(idxGaze,:).AvgSPVHR,TestsData.peakH(idxGaze),TestsData.OTOSuiteResultH(idxGaze));
% subplot(222); gscatter(TestsData.Parameters(idxGaze,:).AvgSPVVR,TestsData.peakV(idxGaze),TestsData.OTOSuiteResultV(idxGaze));
% subplot(223); gscatter(TestsData.Parameters(idxDyn,:).AvgSPVHR,TestsData.peakH(idxDyn),TestsData.OTOSuiteResultH(idxDyn));
% subplot(224); gscatter(TestsData.Parameters(idxDyn,:).AvgSPVVR,TestsData.peakV(idxDyn),TestsData.OTOSuiteResultV(idxDyn));
% 



%% Combining all the data into TestsData table

% load('/mnt/sai/DATA/AVERTnystagmus/TestsDataNew.mat');
% allTable = readtable('/mnt/sai/DATA/AVERTnystagmus/NystagmusData.xlsx');
% sigshv = {'H','V'};
% 
% for i=1:height(TestsData)
%     
%     TestsData.peakH(i) = TestsData.peakH(i)*10;
%     TestsData.peakV(i) = TestsData.peakV(i)*10;
%     
%     patientID = TestsData.PatientID(i);
%     session = TestsData.NewTestName(i);
%     
%     idx = find(contains(allTable.PatientID,patientID) & contains(allTable.NewTestName,session) & allTable.NumMatches == 1);
%     if numel(idx)~=1
%         error('No Matching File Found in allTable')
%     end
%     
%     TestsData.ManualResultH(i) = allTable.ManualResultH(idx);
%     TestsData.ManualResultV(i) = allTable.ManualResultV(idx);
%     
% end


%% OOOTHHHEERRR CODEEEE CHECK OUT THIS PLACE WHEN YOU ARE LOOKING FOR PIECCES OF CODE

% TO CONVERT 'S_100_100' TO 100-100
%     results.patientID{i,1} = subjID;
%     temp = split(subjID,'_');
%     subjID = strjoin({temp{2},temp{3}},'-');
%     clear temp
%     test = arume.currentProject.sessions(1, i).sessionCode;







