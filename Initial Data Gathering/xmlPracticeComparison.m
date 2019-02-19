
tree = xmlread('L_M_2016_03_28_17_20_19.xml');
allGazeTests = tree.getElementsByTagName('VW_DynamicTest');

x = allGazeTests.item(0);

% a = x.getElementsByTagName('PatientUID');
% element = a.item(0);
% PatientID = element.getFirstChild.getData;
% 
% TestType = allGazeTests.item(0).getElementsByTagName('TestType').item(0).getFirstChild.getData;

TotalBeats = x.getElementsByTagName('VW_DynamicBeat');

for i = 0:TotalBeats.getLength-1
    if strcmp(TotalBeats.item(i).getElementsByTagName('Signal').item(0).getFirstChild.getData,'HR')
        disp('yes')
        vel(i+1,1) = str2num(TotalBeats.item(i).getElementsByTagName('Velocity').item(0).getFirstChild.getData);
        time(i+1,1) = str2num(TotalBeats.item(i).getElementsByTagName('TimeMs').item(0).getFirstChild.getData);
    end
end

% if min(diff(time)) < 0
%     dt = diff(time);
%     dt(dt<0) = min(dt(dt>0));
%     t = cumsum([time(1);dt]);
% else
%     t = time;
% end

vel = vel.*0.1;
figure
subplot(211)
plot(time,vel)
title('SPV Vel from OTOSuite')
xlabel('Time in ms')
ylabel('HR SPV Deg/sec')
%%

rawData = csvread('L_M_2016_03_28_17_20_19.csv',127800,0,[127800,0,129675,8]);
% for 749 dynamic test 123292,0,[123292,0,125549,8]; rawData(729:end,:),downsample rate is 61
% for 750 dynamic test 127800,0,[127800,0,129675,8]; rawData(500:end,:); downsample rate is 65

rawData = rawData(500:end,:);
rawData = array2table(rawData, 'VariableNames',{'Time','HR','VR','W','X','Y','Z','HRpix','VRpix'});

rawVel = diff(rawData.HR)./diff(rawData.Time);
V = downsample(rawVel,65);
T = downsample(rawData.Time,65);

subplot(212)
plot(T,V)
title('SPV Vel from RawData')
xlabel('Time in ms')
ylabel('HR SPV Deg/sec')

figure
plot((rawData.Time-rawData.Time(1))./10000000,rawData.HR,'.')
tt = (rawData.Time-rawData.Time(1))./10000000;
vv = diff(rawData.HR)./diff(tt);
vv(end+1)=0;
acc = diff(vv)./diff(tt);
acc(end+1)=0;
plot(tt,acc)
figure
plot(sqrt(rawData.X.^2+rawData.Y.^2+rawData.Z.^2))
plot(rawData.X)