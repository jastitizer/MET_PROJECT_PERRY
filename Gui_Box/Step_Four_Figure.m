function varargout = Step_Four_Figure(varargin)
% STEP_FOUR_FIGURE MATLAB code for Step_Four_Figure.fig
%      STEP_FOUR_FIGURE, by itself, creates a new STEP_FOUR_FIGURE or raises the existing
%      singleton*.
%
%      H = STEP_FOUR_FIGURE returns the handle to a new STEP_FOUR_FIGURE or the handle to
%      the existing singleton*.
%
%      STEP_FOUR_FIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STEP_FOUR_FIGURE.M with the given input arguments.
%
%      STEP_FOUR_FIGURE('Property','Value',...) creates a new STEP_FOUR_FIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Step_Four_Figure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Step_Four_Figure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Step_Four_Figure

% Last Modified by GUIDE v2.5 09-Jan-2016 02:31:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Step_Four_Figure_OpeningFcn, ...
                   'gui_OutputFcn',  @Step_Four_Figure_OutputFcn, ...
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


% --- Executes just before Step_Four_Figure is made visible.
function Step_Four_Figure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Step_Four_Figure (see VARARGIN)

% Choose default command line output for Step_Four_Figure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Step_Four_Figure wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Step_Four_Figure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function openPathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to openPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of openPathEdit as text
%        str2double(get(hObject,'String')) returns contents of openPathEdit as a double


% --- Executes during object creation, after setting all properties.
function openPathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to openPathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openPathButton.
function openPathButton_Callback(hObject, eventdata, handles)
% hObject    handle to openPathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  [fileName,filePath , ~] = uigetfile('.mat', 'Choose Surface Data Txt File');
set(findobj('Tag','openPathEdit'), 'String', [filePath,fileName]);


function savePathEdit_Callback(hObject, eventdata, handles)
% hObject    handle to savePathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savePathEdit as text
%        str2double(get(hObject,'String')) returns contents of savePathEdit as a double


% --- Executes during object creation, after setting all properties.
function savePathEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savePathEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savePathButton.
function savePathButton_Callback(hObject, eventdata, handles)
% hObject    handle to savePathButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global guiStruct
  [fileName,filePath , ~] = uiputfile('.mat', 'Save As');
set(findobj('Tag','savePathEdit'), 'String', [filePath,fileName]);
guiStruct.matFilePath = fileName;

% --- Executes on button press in goButton.
function goButton_Callback(hObject, eventdata, handles)
% hObject    handle to goButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global guiStruct
guiStruct.savefilepath = get(findobj('Tag','savePathEdit'),'String');
guiStruct.metarfilepath = get(findobj('Tag','openPathEdit'),'String');
guiStruct.metartype = get(findobj('Tag','metartypeEdit'),'String');
guiStruct.minuteinterval = get(findobj('Tag','intervalEdit'),'String');
close

function metartypeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to metartypeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of metartypeEdit as text
%        str2double(get(hObject,'String')) returns contents of metartypeEdit as a double


% --- Executes during object creation, after setting all properties.
function metartypeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metartypeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function intervalEdit_Callback(hObject, eventdata, handles)
% hObject    handle to intervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intervalEdit as text
%        str2double(get(hObject,'String')) returns contents of intervalEdit as a double


% --- Executes during object creation, after setting all properties.
function intervalEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
