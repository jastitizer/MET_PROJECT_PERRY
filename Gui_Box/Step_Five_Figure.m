function varargout = Step_Five_Figure(varargin)
% STEP_FIVE_FIGURE MATLAB code for Step_Five_Figure.fig
%      STEP_FIVE_FIGURE, by itself, creates a new STEP_FIVE_FIGURE or raises the existing
%      singleton*.
%
%      H = STEP_FIVE_FIGURE returns the handle to a new STEP_FIVE_FIGURE or the handle to
%      the existing singleton*.
%
%      STEP_FIVE_FIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STEP_FIVE_FIGURE.M with the given input arguments.
%
%      STEP_FIVE_FIGURE('Property','Value',...) creates a new STEP_FIVE_FIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Step_Five_Figure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Step_Five_Figure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Step_Five_Figure

% Last Modified by GUIDE v2.5 16-Jan-2016 20:35:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Step_Five_Figure_OpeningFcn, ...
                   'gui_OutputFcn',  @Step_Five_Figure_OutputFcn, ...
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


% --- Executes just before Step_Five_Figure is made visible.
function Step_Five_Figure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Step_Five_Figure (see VARARGIN)

% Choose default command line output for Step_Five_Figure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Step_Five_Figure wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Step_Five_Figure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global parameters
parameters.directory = get(findobj('Tag','directoryEdit'),'String');
parameters.prefix = get(findobj('Tag','prefixEdit'), 'String');
parameters.suffix= get(findobj('Tag','suffixEdit'), 'String');
parameters.datestart = get(findobj('Tag','startdateEdit'),'String');
parameters.dateend = get(findobj('Tag','enddateEdit'), 'String');
parameters.records_per_file = str2double(get(findobj('Tag','numrowsEdit'),'String'));
parameters.ukoln_toggle = get(findobj('Tag','ukoln_toggle'),'Value');
varargout{1} = parameters ;
% The figure can be deleted now
delete(handles.figure1);



function frontpgEdit_Callback(hObject, eventdata, handles)
% hObject    handle to frontpgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frontpgEdit as text
%        str2double(get(hObject,'String')) returns contents of frontpgEdit as a double


% --- Executes during object creation, after setting all properties.
function frontpgEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frontpgEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in frontpgBrowseButton.
function frontpgBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to frontpgBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,filePath,~] = uigetfile('.html');
global parameters
set(findobj('Tag','frontpgEdit'),'String',[filePath,fileName]);
parameters.frontpg_filename = fileName;
parameters.frontpg_filepath = [filePath,fileName];

function templateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to templateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of templateEdit as text
%        str2double(get(hObject,'String')) returns contents of templateEdit as a double


% --- Executes during object creation, after setting all properties.
function templateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to templateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in templateBrowseButton.
function templateBrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to templateBrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global parameters 
[fileName,filePath,~] = uigetfile('.html');
set(findobj('Tag','templateEdit'),'String',[filePath,fileName]);
parameters.template_filename = fileName;
parameters.template_filepath = [filePath,fileName];


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in goButton.
function goButton_Callback(hObject, eventdata, handles)
% hObject    handle to goButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set guiFlow to forward and close
global parameters 
parameters.guiFlow = 1;
close();



function homePathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to homePathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of homePathEdit as text
%        str2double(get(hObject,'String')) returns contents of homePathEdit as a double


% --- Executes during object creation, after setting all properties.
function homePathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to homePathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in homeBroseButton.
function homeBroseButton_Callback(hObject, eventdata, handles)
% hObject    handle to homeBroseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get path for 'home' button on webpage. 
[~,filePath,~] = uigetfile('.html');
set(findobj('Tag','homePathEdit'),'String',filePath);
global parameters
parameters.home_filepath = filePath;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
% The GUI is still in UIWAIT, us UIRESUME
uiresume(hObject);
else
% The GUI is no longer waiting, just close it
delete(hObject);
end


% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, handles)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global parameters 
parameters.guiFlow = -1;
close
