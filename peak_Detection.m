% Parameters
lmbda = 5;                   % Engbert and Kliegl parameter
F = 2;                       % Factor for Microsaccade Rate
Fs = 500;                    % Sampling Frequency
MinSacIntDuration = Fs*0.03; % 30ms of min Sac Interval
n = 1;                       % Number of seconds to search in for the microsacs according to obtained rate, R2

% % Position and Vel Data
% x = session.samplesDataTable.RightX;
% y = session.samplesDataTable.RightY;

% x = recording(:,2);
% x = downsample(x,2);
% x = x(1:30000);
% x = sgolayfilt(x,2,11);
% 
% y = recording(:,3);
% y = downsample(y,2);
% y = y(1:30000);
% y = sgolayfilt(y,2,11);

vx = [0;diff(x).*500];
vy = [0;diff(y).*500];


% First find all peaks in vx and vy
[pksx_p,locsx_p] = findpeaks(vx,'MinPeakDistance',MinSacIntDuration);
[pksx_n,locsx_n] = findpeaks(-vx,'MinPeakDistance',MinSacIntDuration);

[locsx,id] = sort([locsx_p;locsx_n]);
pksx = [pksx_p;-pksx_n]; pksx = pksx(id);

[pksy_p,locsy_p] = findpeaks(vy,'MinPeakDistance',MinSacIntDuration);
[pksy_n,locsy_n] = findpeaks(-vy,'MinPeakDistance',MinSacIntDuration);

[locsy,id] = sort([locsy_p;locsy_n]);
pksy = [pksy_p;-pksy_n]; pksy = pksy(id);

clear id pksy_p pksy_n locsy_p locsy_n pksx_p pksx_n locsx_p locsx_n

% Selectively removing overlapping peaks wihtin 30ms (corresponding to
% microsacs) and keeping the larger peaks (corresponding to sacs)
[locsx, pksx] = remove_OverlappingPeaks(locsx,pksx,MinSacIntDuration);
[locsy, pksy] = remove_OverlappingPeaks(locsy,pksy,MinSacIntDuration);

% Histogram to check the distribution of the data
hx = histogram(pksx,-200:5:200);
hy = histogram(pksy,-200:5:200);

% Median-based SD for peaks in x and y directions
mx = sqrt( nanmedian( (pksx - nanmedian(pksx) ).^2) );
if mx<=1e-10
    mx = sqrt( mean(pksx.^2) - (mean(pksx))^2 );
    if mx<1e-10
        error('MD Estimator VLow in X')
    end
end

my = sqrt( nanmedian( (pksy - nanmedian(pksy) ).^2) );
if my<=1e-10
    my = sqrt( mean(pksy.^2) - (mean(pksy))^2 );
    if my<1e-10
        error('MD Estimator VLow in Y')
    end
end

% Computing the threshold
rx = min(max(lmbda*mx,20),50);
ry = min(max(lmbda*my,20),50);

% Finding larger threshold main peaks
r = (vx/rx).^2 + (vy/ry).^2;

r1x = find(abs(pksx)>=rx);
r1y = find(abs(pksy)>=ry);

% mainpksx = pksx(r1x); mainlocsx = locsx(r1x);
% mainpksy = pksy(r1y); mainlocsy = locsy(r1y);

% Calculation of rate of micro-saccades, R2
R1x = numel(r1x)/(numel(isnan(vx))/Fs);
R1y = numel(r1y)/(numel(isnan(vy))/Fs);

R2x = min(max(round(R1x * F),3),7);
R2y = min(max(round(R1y * F),3),7);


%% Finding the extra peaks to feed into the clustering algo

peakslocsx = [];
peakslocsy = [];
peakspksx = [];
peakspksy = [];

cntdiscx = 0;
cntdiscy = 0;
count = 1;
strtc = [];
stpc = [];

for i = 1:Fs*n:numel(vx)
    
    start = i;
    stop = i+Fs*n-1;
    
    strtc(count) = start;
    stpc(count) = stop;
    count = count+1;
    %     Fs*n/s:Fs*n/2:numel(vx);
    %     start = max(1,i-(Fs*n/2));
    %     stop = min(i+Fs/2,numel(vx));
    
    % Getting the peak indices within the nsec period
    temp_locsx = locsx(locsx>=start & locsx<=stop);
    temp_pksx = pksx(locsx>=start & locsx<=stop);
    
    temp_locsy = locsy(locsy>=start & locsy<=stop);
    temp_pksy = pksy(locsy>=start & locsy<=stop);   
       
    % Sorting the peaks according to their values
    [~, id] = sort(abs(temp_pksx),'descend');
    sorted_pksx = temp_pksx(id);
    sorted_locsx = temp_locsx(id);
    
    [~, id] = sort(abs(temp_pksy),'descend');
    sorted_pksy = temp_pksy(id);
    sorted_locsy = temp_locsy(id);
    
    % Getting the largest peaks with R2 rate
    if ~isempty(sorted_locsx)
        if numel(sorted_locsx) >= (R2x*n)
            peakslocsx = [peakslocsx ; sorted_locsx(1:R2x*n)];
            peakspksx = [peakspksx ; sorted_pksx(1:R2x*n)];
        else
            peakslocsx = [peakslocsx ; sorted_locsx];
            peakspksx = [peakspksx ; sorted_pksx];
            cntdiscx = cntdiscx+1;
        end
    end
    
    if ~isempty(sorted_locsy)
        if numel(sorted_locsy) >= (R2y*n)
            peakslocsy = [peakslocsy ; sorted_locsy(1:R2y*n)];
            peakspksy = [peakspksy ; sorted_pksy(1:R2y*n)];
        else
            peakslocsy = [peakslocsy ; sorted_locsy];
            peakspksy = [peakspksy ; sorted_pksy];
            cntdiscy = cntdiscy+1;
        end
    end
    
end

clear id sorted_locsx sorted_locsy sorted_pksx sorted_pksy temp_locsx temp_pksx temp_locsy temp_pksy start stop sacs_x sacs_y

%% Plotting

chk = r>1;
ychk = y; xchk = x;
ychk(~chk) = nan; xchk(~chk) = nan;
vychk = vy; vxchk = vx;
vychk(~chk) = nan; vxchk(~chk) = nan;

figure;
a1 = subplot(211);plot(y);hold;plot(ychk);scatter(peakslocsy,y(peakslocsy));
legend('Y Pos','WithEllipse Thresh','Peaks')
for k =1:numel(stpc)
    line([stpc(k) stpc(k)],a1.YLim,'LineStyle','-','HandleVisibility','off');
end
a2 = subplot(212);plot(vy);hold;plot(vychk);scatter(peakslocsy,vy(peakslocsy));
legend('Y Vel','WithEllipse Thresh','Peaks')
for k =1:numel(stpc)
    line([stpc(k) stpc(k)],a2.YLim,'LineStyle','-','HandleVisibility','off');
end
linkaxes([a1 a2],'x');

figure;
a1 = subplot(211);plot(x);hold;plot(xchk);scatter(peakslocsx,x(peakslocsx));
legend('X Pos','WithEllipse Thresh','Peaks')
for k =1:numel(stpc)
    line([stpc(k) stpc(k)],a1.YLim,'LineStyle','-','HandleVisibility','off');
end
a2 = subplot(212);plot(vx);hold;plot(vxchk);scatter(peakslocsx,vx(peakslocsx));
legend('X Vel','WithEllipse Thresh','Peaks')
for k =1:numel(stpc)
    line([stpc(k) stpc(k)],a2.YLim,'LineStyle','-','HandleVisibility','off');
end
linkaxes([a1 a2],'x');

clear ychk vychk xchk vxchk chk a1 a2

%% %% Plotting with labeled data


ychk = y; xchk = x;
ychk(labels~=2) = nan; xchk(labels~=2) = nan;
vychk = vy; vxchk = vx;
vychk(labels~=2) = nan; vxchk(labels~=2) = nan;

figure;
a1 = subplot(211);plot(y);hold;plot(ychk);scatter(peakslocsy,y(peakslocsy));
legend('Y Pos','Labeled Sac','Peaks')
for k =1:numel(stpc)
    line([stpc(k) stpc(k)],a1.YLim,'LineStyle','-','HandleVisibility','off');
end
a2 = subplot(212);plot(vy);hold;plot(vychk);scatter(peakslocsy,vy(peakslocsy));
legend('Y Vel','Labeled Sac','Peaks')
for k =1:numel(stpc)
    line([stpc(k) stpc(k)],a2.YLim,'LineStyle','-','HandleVisibility','off');
end
linkaxes([a1 a2],'x');

figure;
a1 = subplot(211);plot(x);hold;plot(xchk);scatter(peakslocsx,x(peakslocsx));
legend('X Pos','Labeled Sac','Peaks')
for k =1:numel(stpc)
    line([stpc(k) stpc(k)],a1.YLim,'LineStyle','-','HandleVisibility','off');
end
a2 = subplot(212);plot(vx);hold;plot(vxchk);scatter(peakslocsx,vx(peakslocsx));
legend('X Vel','Labeled Sac','Peaks')
for k =1:numel(stpc)
    line([stpc(k) stpc(k)],a2.YLim,'LineStyle','-','HandleVisibility','off');
end
linkaxes([a1 a2],'x');

clear ychk vychk xchk vxchk chk a1 a2

