function plotLo(x,y)

n = size(y,2);

if n == 2
    
    figure;
    %%% For 2x1   
    left= 0.15;
    bottom1=0.5;
    bottom2=0.05;
    width=0.8;
    height=0.45; % which is also bottom1-bottom2
    
    axes('Position',[left bottom1 width height]);
    plot(x, y(:,1));
    ystr = {'Ordinate'};
    hy1 = ylabel(ystr);
    set(gca, 'fontsize', 12);
    set(hy1, 'fontsize', 12);
    set(gca, 'XTickLabel', [],'XTick',[])
    
    axes('Position',[left bottom2 width height])
    plot(x,y(:,2));
    hx2=xlabel('Abscissa');
    hy2=ylabel('Ordinate');
    set(gca, 'fontsize', 12);
    set(hx2, 'fontsize', 12);
    set(hy2, 'fontsize', 12);
    ha=get(gcf,'children');
    linkaxes(ha,'x')
    
elseif n == 3
    
    figure;
    a1=subplottight(3,1,1); plot(x,y(:,1));
    a2=subplottight(3,1,2); plot(x,y(:,2));
    a3=subplottight(3,1,3); plot(x,y(:,3));    
    linkaxes([a1 a2 a3],'x')


elseif n== 4
    
    %%% For 2x2
    
    figure, subplot(2,2,1),plot(raw.X),set(gca,'xtick',[],'ytick',[])
    subplot(2,2,2),plot(raw.Y),set(gca,'xtick',[],'ytick',[])
    subplot(2,2,3),plot(raw.Z),set(gca,'xtick',[],'ytick',[])
    subplot(2,2,4),plot(raw.W),set(gca,'xtick',[],'ytick',[])
    ha=get(gcf,'children');
    set(ha(1),'position',[.5 .1 .4 .4])
    set(ha(2),'position',[.1 .1 .4 .4])
    set(ha(3),'position',[.5 .5 .4 .4])
    set(ha(4),'position',[.1 .5 .4 .4])
    linkaxes(ha,'x')
    
end
