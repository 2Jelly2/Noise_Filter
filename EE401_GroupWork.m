function varargout = EE401_GroupWork(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',  mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @EE401_GroupWork_OpeningFcn, ...
    'gui_OutputFcn',  @EE401_GroupWork_OutputFcn, ...
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

function EE401_GroupWork_OpeningFcn(hObject, eventdata, handles, varargin)
[s,fs] = audioread('/samples/Counting-16-44p1-mono-15secs.wav');
handles.s=(s(:,1)-mean(s(:,1)))/max(abs(s(:,1)-mean(s(:,1))));
handles.fs=fs;
handles.N=length(handles.s);
handles.time=(0:handles.N-1)/fs;
handles.PAs=0;
handles.vSNR=1.5;
handles.output = hObject;
guidata(hObject, handles);

function varargout = EE401_GroupWork_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function WF_Sample_Callback(hObject, eventdata, handles)
audioNo=get(handles.WF_Sample,'Value');
switch audioNo
    case 1
        audioName='/samples/Counting-16-44p1-mono-15secs.wav';
    case 2
        audioName='/samples/WashingMachine-16-44p1-stereo-10secs.wav';
    case 3
        audioName='/samples/TrainWhistle-16-44p1-mono-9secs.wav';
    case 4
        audioName='/samples/FunkyDrums-48-stereo-25secs.mp3';
    case 5
        [file,path]=uigetfile({'*.wav;*.mp3;*.ogg;*.flac','Audio Files';'*.*','All files'});
            if ~isequal(file,0)
                audioName=strcat(path,file);
             end
end
if ~isequal(audioName,0)
    [s,fs] = audioread(audioName);
end
handles.s=(s(:,1)-mean(s(:,1)))/max(abs(s(:,1)-mean(s(:,1))));
handles.fs=fs;
handles.N=length(handles.s);
handles.time=(0:handles.N-1)/handles.fs;
guidata(hObject, handles);

function WF_Sample_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PA_for_WF_Callback(hObject, eventdata, handles)
[file,path]=uigetfile({'*.wav;*.mp3;*.ogg','Audio Files';'*.*','All files'});
if ~isequal(file,0)
    PaF=strcat(path,file);
    PAs = audioread(PaF);
    handles.PAs=(PAs-mean(PAs))/max(abs(PAs-mean(PAs)));
    guidata(hObject, handles);
end

function calWFfactor_Callback(hObject, eventdata, handles)
WFcalWay=get(handles.useNA,'Value');
s=handles.s;
fs=handles.fs;
handles.time=(0:length(s)-1)/fs;
handles.dspA1=0;
r1=0;
if WFcalWay==1
    SNR = handles.vSNR;
    r2=randn(size(s));
    b=fir1(31,0.5);
    r21=filter(b,1,r2);
    r1=add_noisedata(s,r21,fs,fs,SNR);
elseif handles.PAs~=0
    r1=handles.PAs;
end
if r1~=0
    h_length = 100;
    desired_signal = s;
    observed_signal = r1;
    handles.h = Weiner_filter( h_length,desired_signal,observed_signal);
    handles.r1=r1;
    set(handles.ftInfo,'String','HAVE got a factor')
    set(handles.nrInfo,'String','Select an audio')
    dispS(handles,1);
end
guidata(hObject, handles);

function filterNoisyAudio_Callback(hObject, eventdata, handles)
[file,path]=uigetfile({'*.wav;*.mp3;*.ogg','Audio Files';'*.*','All files'});
if ~isequal(file,0)
    PaF=strcat(path,file);
    [r1,fs] = audioread(PaF);
    handles.r1(:,1)=(r1(:,1)-mean(r1(:,1)))/max(abs(r1(:,1)-mean(r1(:,1))));
    handles.N=length(r1);
    handles.time=(0:handles.N-1)/fs;
    handles.dspA1=1;
    dispS(handles,1);
end
    guidata(hObject, handles);

function filterGivenAudio_Callback(hObject, eventdata, handles)
WFcalWay=get(handles.useNA,'Value');
s=handles.s;
fs=handles.fs;
N=handles.N;
handles.time=(0:length(s)-1)/fs;
handles.dspA1=0;
r1=0;
if WFcalWay==1
    SNR = handles.vSNR;
    r2=randn(size(s));
    b=fir1(31,0.5);
    r21=filter(b,1,r2);
    r1=add_noisedata(s,r21,fs,fs,SNR);
elseif handles.PAs~=0
    r1=handles.PAs;
end
if r1~=0
    h_length = 100;
    h = zeros(h_length,1);
    miu = 1e-4;
    y_out = zeros(size(s));
    Ntimes = 3;
    err2 = zeros(length(s)*Ntimes,1);
    counter = 1;
    handles.yL=LMS_filter( h_length, h, Ntimes, y_out, err2, counter, s, N, r1, miu );
    handles.r1=r1;
    dispS(handles,2);
end
guidata(hObject, handles);

function filterCustomAudio_Callback(hObject, eventdata, handles)
[file,path]=uigetfile({'*.wav;*.mp3;*.ogg','Audio Files';'*.*','All files'});
if ~isequal(file,0)
    PaF=strcat(path,file);
    [r1,fs] = audioread(PaF);
    handles.r1(:,1)=(r1(:,1)-mean(r1(:,1)))/max(abs(r1(:,1)-mean(r1(:,1))));
    handles.N=length(r1);
    handles.time=(0:handles.N-1)/fs;
    handles.dspA1=1;
    
    h_length = 100;
    h = zeros(h_length,1);
    miu = 1e-4;
    y_out = zeros(size(rl));
    Ntimes = 3;
    err2 = zeros(length(s)*Ntimes,1);
    counter = 1;
    handles.yL=LMS_filter( h_length, h, Ntimes, y_out, err2, counter, s, N, r1, miu );
    handles.r1=r1;
    
    dispS(handles,2);
end
guidata(hObject, handles);

function SNR_Callback(hObject, eventdata, handles)
handles.vSNR=str2num(get(handles.SNR,'String'));
guidata(hObject, handles);

function dispS(handles,type)
if type==1
    y=filter(handles.h,1,handles.r1);
else
    y=handles.yL;
end
output = y;
axes(handles.axes1);
if handles.dspA1==0
    plot(handles.time,handles.s,'k'); ylim([-1 1 ]);
    title('Original Signal');
else
    cla;
    text(0.5,0,'not Available','HorizontalAlignment','center');
end
axes(handles.axes2); plot(handles.time,handles.r1,'k'); ylim([-1 1 ]);
ylabel('Amplitude');title('Polluted Signal');
axes(handles.axes3); plot(handles.time,output,'k'); ylim([-1 1 ]);
title('Filtered Signal');
xlabel('Time/s'); 

function useNA_Callback(hObject, eventdata, handles)
set(handles.useNA,'Value',1);
if get(handles.usePS,'Value')==1
    set(handles.usePS,'Value',0);
end

function usePS_Callback(hObject, eventdata, handles)
set(handles.usePS,'Value',1);
if get(handles.useNA,'Value')==1
    set(handles.useNA,'Value',0);
end


function SNR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
