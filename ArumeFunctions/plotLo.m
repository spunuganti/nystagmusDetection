function plotLo(x,y)

n = size(y,2);

if n == 2
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    %%% For 2x1
    left= 0.05;
    bottom1=0.5;
    bottom2=0.1;
    width=0.9;
    height=0.40; % which is also bottom1-bottom2
    
    axes('Position',[left bottom1 width height]);
    plot(x, y(:,1),'LineWidth',2);
    ystr = {'Ordinate'};
    hy1 = ylabel(ystr);
    set(gca, 'fontsize', 12);
    set(hy1, 'fontsize', 12);
    set(gca, 'XTickLabel', [],'XTick',[])
    
    axes('Position',[left bottom2 width height])
    plot(x,y(:,2),'LineWidth',2);
    hx2=xlabel('Time in seconds');
    hy2=ylabel('Ordinate');
    set(gca, 'fontsize', 12);
    set(hx2, 'fontsize', 12);
    set(hy2, 'fontsize', 12);
    ha=get(gcf,'children');
    linkaxes(ha,'x')
    
elseif n == 3
    
%     figure('units','normalized','outerposition',[0 0 1 1]);
%     a1=subplottight(3,1,1); plot(x,y(:,1),'LineWidth',2);
%     a2=subplottight(3,1,2); plot(x,y(:,2),'LineWidth',2);
%     a3=subplottight(3,1,3); plot(x,y(:,3),'LineWidth',2);
%     linkaxes([a1 a2 a3],'x')
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    %%% For 3x1
    left= 0.05;
    bottom1=0.65;
    bottom2=0.35;
    bottom3=0.1;
    width=0.9;
    height=0.30; % which is also bottom1-bottom2
    
    axes('Position',[left bottom1 width height]);
    plot(x, y(:,1),'LineWidth',2);
    ystr = {'Ordinate'};
    hy1 = ylabel(ystr);
    set(gca, 'fontsize', 11);
    set(hy1, 'fontsize', 11);
    set(gca, 'XTickLabel', [],'XTick',[])
    
    axes('Position',[left bottom2 width height])
    plot(x,y(:,2),'LineWidth',2);
    hy2=ylabel('Ordinate');
    set(gca, 'fontsize', 11);
    set(hy2,'fontsize', 11);
    
    axes('Position',[left bottom3 width height])
    plot(x,y(:,3),'LineWidth',2);
    hx3=xlabel('Time in seconds');
    hy3=ylabel('Ordinate');
    set(gca, 'fontsize', 11);
    set(hx3, 'fontsize', 11);
    set(hy3, 'fontsize', 11);
    ha=get(gcf,'children');
    linkaxes(ha,'x')
    

elseif n== 4
    
    %%% For 2x2
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(2,2,1),plot(x,y(:,1),'LineWidth',2),set(gca,'xtick',[],'ytick',[])
    subplot(2,2,2),plot(x,y(:,2),'LineWidth',2),set(gca,'xtick',[],'ytick',[])
    subplot(2,2,3),plot(x,y(:,3),'LineWidth',2),set(gca,'xtick',[],'ytick',[])
    subplot(2,2,4),plot(x,y(:,4),'LineWidth',2),set(gca,'xtick',[],'ytick',[])
    ha=get(gcf,'children');
    set(ha(1),'position',[.5 .1 .4 .4])
    set(ha(2),'position',[.1 .1 .4 .4])
    set(ha(3),'position',[.5 .5 .4 .4])
    set(ha(4),'position',[.1 .5 .4 .4])
    linkaxes(ha,'x')
    
elseif n== 5
    
    %%% For 2x1
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    %%% For 2x1
    left= 0.05;
    bottom1=0.5;
    bottom2=0.1;
    width=0.9;
    height=0.40; % which is also bottom1-bottom2
    
    axes('Position',[left bottom1 width height]);
    plot(x, y(:,1),'LineWidth',2);
    ystr = {'Ordinate'};
    hy1 = ylabel(ystr);
    set(gca, 'fontsize', 11);
    set(hy1, 'fontsize', 11);
    set(gca, 'XTickLabel', [],'XTick',[])
    
    axes('Position',[left bottom2 width height])
    plot(x,y(:,2),'LineWidth',2); hold on;
    plot(x,y(:,3),'LineWidth',2); hold on;
    plot(x,y(:,4),'LineWidth',2); hold on;
    plot(x,y(:,5),'LineWidth',2); hold on;
    hx2=xlabel('Time in Seconds');
    hy2=ylabel('Position');
    set(gca, 'fontsize', 11);
    set(hx2, 'fontsize', 11);
    set(hy2, 'fontsize', 11);
    ha=get(gcf,'children');
    linkaxes(ha,'x')
    
    
end
