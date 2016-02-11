function varargout = Step_Three_Figure(varargin)
% STEP_THREE_FIGURE MATLAB code for Step_Three_Figure.fig
%      STEP_THREE_FIGURE, by itself, creates a new STEP_THREE_FIGURE or raises the existing
%      singleton*.
%
%      H = STEP_THREE_FIGURE returns the handle to a new STEP_THREE_FIGURE or the handle to
%      the existing singleton*.
%
%      STEP_THREE_FIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STEP_THREE_FIGURE.M with the given input arguments.
%
%      STEP_THREE_FIGURE('Property','Value',...) creates a new STEP_THREE_FIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Step_Three_Figure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Step_Three_Figure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Step_Three_Figure

% Last Modified by GUIDE v2.5 16-Jan-2016 20:16:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Step_Three_Figure_OpeningFcn, ...
                   'gui_OutputFcn',  @Step_Three_Figure_OutputFcn, ...
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


% --- Executes just before Step_Three_Figure is made visible.
function Step_Three_Figure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Step_Three_Figure (see VARARGIN)

% Choose default command line output for Step_Three_Figure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Step_Three_Figure wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Step_Three_Figure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
global parameters
parameters.Z_threshhold = get(findobj('Tag','edgeEdit'),'String');
parameters.Z_threshhold_2 = get(findobj('Tag','reflectivityEdit'),'String');
parameters.skip4 = get(findobj('Tag','reflectivityEdit'),'String');

varargout{1} = parameters ;
% The figure can be deleted now
delete(handles.figure1);


function reflectivityEdit_Callback(hObject, eventdata, handles)
% hObject    handle to reflectivityEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of reflectivityEdit as text
%        str2double(get(hObject,'String')) returns contents of reflectivityEdit as a double


% --- Executes during object creation, after setting all properties.
function reflectivityEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reflectivityEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edgeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to edgeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edgeEdit as text
%        str2double(get(hObject,'String')) returns contents of edgeEdit as a double


% --- Executes during object creation, after setting all properties.
function edgeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edgeEdit (see GCBO)
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
global parameters 
parameters.guiFlow = 1;
close


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


% --- Executes on button press in skip4Check.
function skip4Check_Callback(hObject, eventdata, handles)
% hObject    handle to skip4Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skip4Check


% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, handles)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global parameters
parameters.guiFlow = -1;
close