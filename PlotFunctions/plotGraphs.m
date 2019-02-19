function plotGraphs(session,var)

clean = session.samplesDataTable.Properties.UserData.cleanedData;
raw = session.samplesDataTable.Properties.UserData.calibratedData;
resampled = session.samplesDataTable;


% Creating the Labels and Legends
ylabels = {'Position','Velocity','SPV','HAV'};
legends=cell(4,1);
legends{1,1} = {'Raw','Clean','QP','SP'};
legends{2,1} = {'Raw','Clean','QP','SP'};
legends{3,1} = {'Otosuite','QP_SP','Simple'};

% Colors
map = brewermap(7,'Oranges');
greens = brewermap(4,'Greens');
purple = [0.4940    0.1840    0.5560];
pink = [0.6350    0.0780    0.1840];
orange = [0.8500    0.3250    0.0980];
pair = brewermap(12,'Paired');
blues = colormap('jet');
%%%%%% USING PANEL %%%%%%%%%%
p=panel();
p.pack({28.57 28.57 28.57 14.29}, {[]});

% set margins
p.de.margin = 0;
% p(1,1).marginbottom = 12;
% p(2).marginleft = 20;
p.margin = [15 11 2 2];

p.select('all');
ha = p.de.axis;

sigsxy={'X','Y'};
sigshv={'H','V'};

for ii = 1:4
    
    p(ii,1).select();
    
    % Axis Labels
    set(get(ha(1,ii),'YLabel'), 'String', ylabels{ii})
%     a = get(gca,'YTickLabel');
%     set(gca,'YTickLabel',a,'fontsize',1)
%     set(ha(ii),'YTickLabel','');
    axis tight
    if ii==4
        hold all
        % SORT OUT THE ANGULAR VELOCITY CALCULATION
        % Raw Head Angular Velocity
        plot(raw.Time, raw.HeadAngularVel,'LineWidth',2,'Color',pair(9,:));
        
        % Resampled Head Angular Velocity
        plot(resampled.Time, session.samplesDataTable.Properties.UserData.ResampledHeadAngularVel,...
            'LineWidth',2, 'Color',pair(10,:));
        
        % Plotting the Threshold
         y = session.sessionDataTable.HeadVelThresh;
         line(get(ha(ii),'XLim'), [y y], 'LineStyle','--','Color',pair(10,:),'HandleVisibility','off');
        
        % X and Y Axes
         set(get(ha(ii),'XLabel'), 'String', 'Time in Seconds')
        %         set(gca,'YTickLabel',a,'fontsize',1)
        
        
    else
        set(ha(ii),'XTickLabel','');
        
        % Plotting
        if ii==1
            hold all
            % Raw Data
            plot(raw.Time, raw.(['Right' sigsxy{var}]),'LineWidth',1,'Color',pair(9,:));
            % Resampled Data
            plot(resampled.Time,resampled.(['Right' sigsxy{var}]),'LineWidth',2.5,'Color', pair(10,:));
            % QP Data
            qps = nan(height(resampled),1);
            qps(resampled.QuikPhase==1) = resampled.(['Right' sigsxy{var}])(resampled.QuikPhase==1);
            plot(resampled.Time,qps,'LineWidth',4,'Color',blues(32,:));
            % SP Data
            sps = nan(height(resampled),1);
            sps(resampled.SlowPhase==1) = resampled.(['Right' sigsxy{var}])(resampled.SlowPhase==1);
            plot(resampled.Time,sps,'LineWidth',2,'Color',pair(4,:));
            legend('Raw','Clean','QP','SP');
            
            clear qps sps
            
        elseif ii==2
            hold all
            % Raw Data
            plot(raw.Time, [0;diff(raw.(['Right' sigsxy{var}]))./diff(raw.Time)],'LineWidth',1,'Color',pair(9,:));
            
            % Resampled Data
            plot(resampled.Time,[0;diff(resampled.(['Right' sigsxy{var}])).*500],'LineWidth',2,'Color',pair(10,:));
            
            % QP Data
            qp = session.analysisResults.QuickPhases ;
            qps = nan(height(resampled),1);
            for k=1:height(qp)
                qps(qp.StartIndex(k):qp.EndIndex(k)) = resampled.(['RightVel' sigsxy{var}])(qp.StartIndex(k):qp.EndIndex(k));
            end
            
            plot(resampled.Time,qps,'LineWidth',4,'Color',blues(32,:));
            
            % SP Data
            sp = session.analysisResults.SlowPhases  ;
            sps = nan(height(resampled),1);
            for k=1:height(sp)
                sps(sp.StartIndex(k):sp.EndIndex(k)) = resampled.(['RightVel' sigsxy{var}])(sp.StartIndex(k):sp.EndIndex(k));
            end
            plot(resampled.Time,sps,'LineWidth',2,'Color',pair(4,:));
            
            clear qp sp sps qps
            
        elseif ii==3
            hold all
            % Otosuite
            plot(session.analysisResults.SPV_Otosuite.Time, session.analysisResults.SPV_Otosuite.([sigsxy{var}]),'-s','LineWidth',2,'Color',pair(8,:),'MarkerSize',6);%,'MarkerFaceColor',map(2,:));
            % Simple
            plot(session.analysisResults.SPV_Simple.Time, session.analysisResults.SPV_Simple.(['Right' sigsxy{var}]),'-O','LineWidth',2,'Color',pair(2,:),'MarkerSize',6);%,'MarkerFaceColor',[0.3010    0.7450    0.9330]);
            % QP_SP
            plot(session.analysisResults.SPV_QP_SP.Time, session.analysisResults.SPV_QP_SP.(['Right' sigsxy{var}]),'-^','LineWidth',2,'Color',pair(6,:),'MarkerSize',6);%,'MarkerFaceColor',pair(5,:));
            
            legend('Otosuite','Simple','QP_SP');
            
            x = session.sessionDataTable.(['SPV_Otosuite_PeakSPVTime' sigshv{var} 'Rms']);
            line([x x],get(ha(ii),'YLim'),'LineStyle','--','Color',pair(8,:),'HandleVisibility','off');
            
            x = session.sessionDataTable.(['SPV_Simple_PeakSPVTime' sigshv{var} 'Rms']);
            line([x x],get(ha(ii),'YLim'),'LineStyle','--','Color',pair(2,:),'HandleVisibility','off');
            
            x = session.sessionDataTable.(['SPV_QP_SP_PeakSPVTime' sigshv{var} 'Rms']);
            line([x x],get(ha(ii),'YLim'),'LineStyle','--','Color',pair(6,:),'HandleVisibility','off');

        end
    end
    
    
end




temp = split(session.subjectCode,'_');
subjID = strjoin({temp{:}},'-');
clear temp

temp = split(session.sessionCode,'_');
sessionID = strjoin({temp{:}},'-');
clear temp

txt = sprintf('%s %s %s',subjID,sessionID,sigsxy{var});
suptitle(txt);

linkaxes([ha(1,1) ha(1,2) ha(1,3) ha(1,4)],'x')


% For Testing
% so then we might want to set something on them.
% set(h_axes, 'color', [0 0 0]);










