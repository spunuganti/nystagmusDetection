function varargout = ICSgui2(varargin)
% ICSGUI2 MATLAB code for ICSgui2.fig
%      ICSGUI2, by itself, creates a new ICSGUI2 or raises the existing
%      singleton*.
%
%      H = ICSGUI2 returns the handle to a new ICSGUI2 or the handle to
%      the existing singleton*.
%
%      ICSGUI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ICSGUI2.M with the given input arguments.
%
%      ICSGUI2('Property','Value',...) creates a new ICSGUI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ICSgui2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ICSgui2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ICSgui2

% Last Modified by GUIDE v2.5 15-Jun-2017 10:50:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ICSgui2_OpeningFcn, ...
    'gui_OutputFcn',  @ICSgui2_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ICSgui2 is made visible.
function ICSgui2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ICSgui2 (see VARARGIN)

% Choose default command line output for ICSgui2
handles.output = hObject;

handles.files = {};

maindir = 'D:\AVERTDATA';
d = dir(maindir);
isub = [d(:).isdir];
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

for i=1:length(nameFolds)
    dd = fullfile(maindir,nameFolds{i});
    
    d2 = dir(dd);
    isub = [d2(:).isdir];
    nameFolds2 = {d2(isub).name}';
    nameFolds2(ismember(nameFolds2,{'.','..'})) = [];
    for j=1:length(nameFolds2)
        ddd = fullfile(dd,nameFolds2{j})
        ff = dir(fullfile(ddd,'*.xml'));
        for k=1:length(ff)
            f = ff(k);
            if (~exist(fullfile(ddd, strrep(f.name, '.xml','.mat')),'file'))
                C = loadFile(f);
                save(fullfile(ddd, strrep(f.name, '.xml','.mat')),'C');
            end
            
            handles.files{end+1} = fullfile(ddd, strrep(f.name, '.xml','.mat'));
            
        end
    end
end

set(handles.listbox2,'string',handles.files);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ICSgui2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ICSgui2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = eventdata.Source.Value;
d = handles.C.SPV{idx};
lines = {};
if ( ~isempty(d) )
    for i=1:length(d.Time)
        lines{end+1} = sprintf( '%4.1f x:%4.1f deg/s y:%4.1f deg/s', d.Time(i), d.RightX(i), d.RightY(i));
    end
end
set(handles.listbox3,'value',1);
set(handles.listbox3,'string',lines);
lines = {};
d = handles.C.SPVjom{idx};
if ( ~isempty(d) )
    for i=1:length(d.Time)
        lines{end+1} = sprintf( '%4.1f x:%4.1f deg/s y:%4.1f deg/s', d.Time(i), d.RightX(i), d.RightY(i));
    end
end
set(handles.listbox4,'value',1);
set(handles.listbox4,'string',lines);

UpdatePlots(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedFile = get(handles.listbox2,'value');
a = load(handles.files{selectedFile});
handles.C = a.C;

set(handles.listbox1,'value',1);
set(handles.listbox1,'string',strcat(num2str(handles.C.PatientUID), ':', num2str(handles.C.TestUID), ' - ', handles.C.TestType_testsTable, {' - '}, handles.C.TestType_tests2));


handles = UpdatePlots(hObject, handles);
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = UpdatePlots(hObject, handles)



i = get(handles.listbox1,'value');

if ( ~isfield(handles,'plots'))
    handles.plots = [];
end
plots = handles.plots;

if ( ~isfield(plots, 'fsummary')  || ~plots.fsummary.isvalid)
    plots.fsummary = figure('color','w');
    plots.hsummary = tight_subplot(7,4,[0 0.03],[0.05 0.05],[0.05 0.05]);
end
handles.plots = plots;

plotSummary(handles);


C = handles.C;
d = C.Data{i};


s = C.SPV{i};
if ( ( sum(strcmp(d.Properties.VariableNames,'RightX'))==0) || ...
   ( sum(strcmp(d.Properties.VariableNames,'RightY'))==0) || ...
   ( length(d.RightX) < 10))
    guidata(hObject, handles);
    return;
end


if ( ~isfield(plots, 'ftraces')  || ~plots.ftraces.isvalid)
    handles.plots.ftraces = figure('color','w');
    handles.plots.htraces = tight_subplot(4,2,0.01,[0.05 0.05],[0.05 0.05]);
end

plotTraces(handles);

guidata(hObject, handles);


%%

function plotTraces(handles)
i = get(handles.listbox1,'value');

plots = handles.plots;

C = handles.C;
d = C.Data{i};


s = C.SPV{i};
f = plots.ftraces;
h = plots.htraces;
rows = {'X' 'Y'};



cleanedData =C.CleanedData{i};
resData = C.ResData{i};

for ii=1:length(h)
    cla(h(ii))
end
set(h,'nextplot','add','yticklabelmode','auto');
    
axes(h(1));
snames = get(handles.listbox1,'string');
titleStr = snames{i};
for j=1:length(rows)
    

    title(strrep(titleStr,'_',' '));
    plot(d.Time, d.(['Right' rows{j}]));
    plot(resData.Time, resData.(['Right' rows{j}]),'linewidth',2);
    set(gca,'ylim', [-60 60]+nanmedian(d.(['Right' rows{j}])));
    
end
    ylabel('Eye position')
    legend({'Horizontal raw' 'Horizontal "clean"', 'Vertical raw' ,'Vertical "clean"'},'box','off');

    line(get(gca,'xlim'),[0 0],'color','k')
    grid on
axes(h(2));

    grid on
plot(d.Time, sum([0 0 0 0; boxcar(abs(diff(table2array(d(:,{'Q1' 'Q2' 'Q3' 'Q4'})))),10)],2)*100)
line(get(gca,'xlim'),[1 1]*nanmedian(sum([0 0 0 0; boxcar(abs(diff(table2array(d(:,{'Q1' 'Q2' 'Q3' 'Q4'})))),10)],2)*100)*3);
set(gca,'ylim', [0 3]);
ylabel('Head motion');
legend({'Head motion'},'box','off');


for j=1:length(rows)
    axes(h(j+2));
    
    grid on
    
    
    t = resData.Time;
    
    xx = resData.(['Right' rows{j}]);
    yesNo = resData.QuikPhase;
    yesNoSP = resData.SlowPhase;
    vx = resData.(['Right' 'Vel' rows{j}]);
    vxhp = resData.(['Right' 'VelHP' rows{j}]);
    vxlp = resData.(['Right' 'VelLP' rows{j}]);
    peaks = resData.(['Right' 'QuikPhasePeak' rows{j}]);
    peaksRaw = resData.(['Right' 'PeakRaw' rows{j}]);
    
    accx = resData.(['Right' 'Accel' rows{j}]);
    
    xxsac = nan(size(xx));
    xxsac(yesNo) = xx(yesNo);
    xxsacSP = nan(size(xx));
    xxsacSP(yesNoSP) = xx(yesNoSP);
    
    vxsac = nan(size(xx));
    vxsac(yesNo) = vx(yesNo);
    vxsacp = nan(size(xx));
    vxsacp(peaks) = vx(peaks);
    vxsacp1 = nan(size(xx));
    vxsacp1(peaksRaw) = vx(peaksRaw);
    
    
    accxsac = nan(size(xx));
    accxsac(yesNo) = accx(yesNo);
    accxsacp = nan(size(xx));
    accxsacp(peaks) = accx(peaks);
    
    plot(t, xx)
    plot(t, xxsac,'r','linewidth',2)
    plot(t, xxsacSP,'b','linewidth',2)
    set(gca,'ylim',[-40 40])
    ylabel([ rows{j} ' pos'])
    set(gca,'yticklabelmode','auto')
        
    
    
%     plot(d.Time, d.(['Right' rows{j}]));
%     plot(resData.Time, resData.(['Right' rows{j}]));
    set(gca,'ylim', [-30 30]+nanmedian(d.(['Right' rows{j}])));
    legend({'Eye pos.' 'QP' 'SP'},'box','off');
end

for j=1:length(rows)
    axes(h(j+4));
    
    grid on
    
    
    t = resData.Time;
    
    vx = resData.(['Right' 'Vel' rows{j}]);
    vxhp = resData.(['Right' 'VelHP' rows{j}]);
    vxlp = resData.(['Right' 'VelLP' rows{j}]);
    vxbp = resData.(['Right' 'VelBP' rows{j}]);
    
    plot(t,vx);
    plot(t,vxhp);
    plot(t,vxlp);
    plot(t,vxbp);
end


if ( isempty(s) )
    s.Time = [];
    s.RightX = [];
    s.RightY = [];
    s.Time(end+1) = -10;
    s.RightX(end+1) = 0;
    s.RightY(end+1) = 0;
end

axes(h(7));

plot(s.Time, s.RightX,'^','linewidth',2,'markersize',10);
errorbar(C.SPVjom{i}.Time, C.SPVjom{i}.RightX,C.SPVjom{i}.RightXSE,'o','linewidth',2,'markersize',10);

plot(resData.Time, resData.RightVelLPX,'linewidth',2);

set(gca,'ylim', [-35 35]);

legend({'Otosuite' 'EMFEE'},'box','off');


ylabel('Horizontal SPV (deg/s)')
xlabel('Time (s)');

set(gca,'xticklabelmode','auto')

    grid on
xl = [0 max(d.Time)];
line(xl,[0 0],'color','k')
line(xl,[-10 -10],'color','k','linestyle','--')
line(xl,[10 10],'color','k','linestyle','--')

axes(h(8));
plot(s.Time, s.RightY,'^','linewidth',2,'markersize',10);
errorbar(C.SPVjom{i}.Time, C.SPVjom{i}.RightY,C.SPVjom{i}.RightYSE,'o','linewidth',2,'markersize',10);
plot(resData.Time, resData.RightVelLPY,'linewidth',2);

legend({'Otosuite' 'EMFEE'},'box','off');
set(gca,'ylim', [-35 35]);
line(xl,[0 0],'color','k')
line(xl,[-10 -10],'color','k','linestyle','--')
line(xl,[10 10],'color','k','linestyle','--')

set(h,'xlim',xl);
set(gca,'xticklabelmode','auto')
    grid on
linkaxes(h,'x')

set(h(2:2:end),'YAxisLocation','right');

ylabel('Vertical SPV (deg/s)')
xlabel('Time (s)');

handles.plots = plots;


function plotSummary(handles)

%%
tests = { 'Spontaneous_Lateropulsion — Sitting' ...
    'Composite Gaze'  ...
    'Gaze — Center'   ...
    'Gaze — Right'    ...
    'Gaze — Left'   ...
    'Gaze — Center' ...
    'Gaze — Right' ...
    'Gaze — Left' ...
    'Spontaneous_Lateropulsion — Chin to Chest' ...
    'Headshake — Head Straight' ...
    'Dix-Hallpike — Head Right' ...
    'Dix-Hallpike — Head Left' ...
    'Roll — Rightward' ...
    'Roll — Leftward'};

visionDenied = [nan nan 0 0 0 1 1 1 nan nan nan nan nan nan];
C = handles.C;
C.TestType_tests2=categorical(C.TestType_tests2);
C.VisionDenied = categorical(C.VisionDenied)=='True';

h = handles.plots.hsummary;
for ii=1:length(h)
    cla(h(ii))
end

for iTest = 1:length(tests)
    
    
    axes(h(mod(iTest-1,7)*4 + 1 + floor((iTest-1)/7)*2));
    set(gca,'nextplot','add')
    set(gca,'ylim', [-60 60]);
    
    testTile = strrep(strrep(tests{iTest},'_', ' '),'—','-');
    if ( ~isnan(visionDenied(iTest)) && visionDenied(iTest) )
        testTile = [testTile ' - VisDen'];
    end
    text(0,50,['  ' testTile],'fontweight','bold');
    
    idxTest = max(find(C.TestType_tests2==tests{iTest} & (isnan(visionDenied(iTest)) | C.VisionDenied==visionDenied(iTest))));
    if ( isempty(idxTest) )
        continue;
    end
    
    
    resData = C.ResData{idxTest};
    d = C.Data{idxTest};
    
    if ( isempty( resData) )
        continue;
    end
   
    plot(d.Time, d.RightX);
    plot(resData.Time, resData.RightX,'linewidth',2);
    
    plot(d.Time, d.RightY);
    plot(resData.Time, resData.RightY,'linewidth',2);
    grid on
    
    ylabel('Eye pos. (deg)');
    set(gca,'yticklabelmode','auto');
    set(gca,'xtick',[0:10:length(d.Time)])
        
    if ( mod(iTest,7) == 0 )
        xlabel('Time (s)');
        set(gca,'xticklabelmode','auto')
    end
    
    
    
    axes(h(mod(iTest-1,7)*4 + 2 + floor((iTest-1)/7)*2));
    set(gca,'nextplot','add')
    
    
    spvOTO = C.SPV{idxTest};
    spvJOM = C.SPVjom{idxTest};

    plot(spvOTO.Time, spvOTO.RightX,'^','linewidth',1,'markersize',7);
    plot(spvJOM.Time, spvJOM.RightX,'o','linewidth',2,'markersize',7);
    
    plot(spvOTO.Time, spvOTO.RightY,'v','linewidth',1,'markersize',7);
    plot(spvJOM.Time, spvJOM.RightY,'o','linewidth',2,'markersize',7);
    set(gca,'ylim', [-50 50]);
    set(gca,'yticklabelmode','auto')
    set(gca,'xtick',[0:10:length(d.Time)])
    ylabel('SPV (deg/s)')
    grid on
    xl = [0 max(spvJOM.Time)];
    line(xl,[0 0],'color','k')
    line(xl,[-10 -10],'color','k','linestyle','--')
    line(xl,[10 10],'color','k','linestyle','--')
    
    if ( mod(iTest,7) == 0 )
        xlabel('Time (s)');
        set(gca,'xticklabelmode','auto')
    end
    
end




% --- Executes on button press in pushbuttonReprocess.
function pushbuttonReprocess_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=waitbar(0,'Please wait..');

i = get(handles.listbox2,'value');
snames = get(handles.listbox2,'string');
xmlfile = snames{i};
ICSGetData(xmlfile)
waitbar(1)
close(h)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=waitbar(0,'Please wait..');

i = get(handles.listbox2,'value');
snames = get(handles.listbox2,'string');
xmlfile = snames{i};

i = get(handles.listbox1,'value');

C = handles.C;
d = C.Data{i};
[cleanedData resData spvjom] = VOG.ResampleAndCleanDataICS(d);

handles.C.SPVjom{i} = spvjom;
handles.C.CleanedData{i} = cleanedData;
handles.C.ResData{i} = resData;

C = handles.C;
guidata(hObject, handles);

save(strrep(xmlfile, '.xml','.mat'),'C');
disp('Done')
UpdatePlots(hObject, handles);
waitbar(1)
close(h)