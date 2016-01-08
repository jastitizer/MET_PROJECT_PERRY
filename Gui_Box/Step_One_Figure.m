function varargout = Step_One_Figure(varargin)
% STEP_ONE_FIGURE MATLAB code for Step_One_Figure.fig
%      STEP_ONE_FIGURE, by itself, creates a new STEP_ONE_FIGURE or raises the existing
%      singleton*.
%
%      H = STEP_ONE_FIGURE returns the handle to a new STEP_ONE_FIGURE or the handle to
%      the existing singleton*.
%
%      STEP_ONE_FIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STEP_ONE_FIGURE.M with the given input arguments.
%
%      STEP_ONE_FIGURE('Property','Value',...) creates a new STEP_ONE_FIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Step_One_Figure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Step_One_Figure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%       ***FUNCTION DISCRIPTION****
% INPUTS:  NONE
% 
% OUTPUTS: MRR, output of caller function (see instructions PDF). 
% Note: output handled by MET_Package
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Step_One_Figure

% Last Modified by GUIDE v2.5 08-Jan-2016 12:39:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Step_One_Figure_OpeningFcn, ...
                   'gui_OutputFcn',  @Step_One_Figure_OutputFcn, ...
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


% --- Executes just before Step_One_Figure is made visible.
function Step_One_Figure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Step_One_Figure (see VARARGIN)

% Choose default command line output for Step_One_Figure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Step_One_Figure wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Step_One_Figure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




function directoryEdit_Callback(hObject, eventdata, handles)
% hObject    handle to directoryEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of directoryEdit as text
%        str2double(get(hObject,'String')) returns contents of directoryEdit as a double


% --- Executes during object creation, after setting all properties.
function directoryEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to directoryEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function prefixEdit_Callback(hObject, eventdata, handles)
% hObject    handle to prefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefixEdit as text
%        str2double(get(hObject,'String')) returns contents of prefixEdit as a double


% --- Executes during object creation, after setting all properties.
function prefixEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function enddateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to enddateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enddateEdit as text
%        str2double(get(hObject,'String')) returns contents of enddateEdit as a double


% --- Executes during object creation, after setting all properties.
function enddateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enddateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startdateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to startdateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startdateEdit as text
%        str2double(get(hObject,'String')) returns contents of startdateEdit as a double


% --- Executes during object creation, after setting all properties.
function startdateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startdateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function suffixEdit_Callback(hObject, eventdata, handles)
% hObject    handle to suffixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of suffixEdit as text
%        str2double(get(hObject,'String')) returns contents of suffixEdit as a double


% --- Executes during object creation, after setting all properties.
function suffixEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to suffixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numrowsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to numrowsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numrowsEdit as text
%        str2double(get(hObject,'String')) returns contents of numrowsEdit as a double


% --- Executes during object creation, after setting all properties.
function numrowsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numrowsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, handles)
% hObject    handle to browseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filePath = uigetdir();
set(findobj('Tag','directoryEdit'), 'String', filePath);

% --- Executes on button press in goButton.
function goButton_Callback(hObject, eventdata, handles)
global guiStruct
% hObject    handle to goButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guiStruct.directory = get(findobj('Tag','directoryEdit'),'String');
guiStruct.prefix = get(findobj('Tag','prefixEdit'), 'String');
guiStruct.suffix= get(findobj('Tag','suffixEdit'), 'String');
guiStruct.datestart = get(findobj('Tag','startdateEdit'),'String');
guiStruct.dateend = get(findobj('Tag','enddateEdit'), 'String');
guiStruct.records_per_file = str2double(get(findobj('Tag','numrowsEdit'),'String'));
guiStruct.ukoln_toggle = get(findobj('Tag','ukoln_toggle'),'Value');
dummer = 'dummer';

close(); 
