function varargout = showObjects(varargin)
% SHOWOBJECTS M-file for showObjects.fig
%      SHOWOBJECTS, by itself, creates a new SHOWOBJECTS or raises the existing
%      singleton*.
%
%      H = SHOWOBJECTS returns the handle to a new SHOWOBJECTS or the handle to
%      the existing singleton*.
%
%      SHOWOBJECTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOWOBJECTS.M with the given input arguments.
%
%      SHOWOBJECTS('Property','Value',...) creates a new SHOWOBJECTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before showObjects_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to showObjects_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help showObjects

% Last Modified by GUIDE v2.5 31-Jan-2012 10:54:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @showObjects_OpeningFcn, ...
                   'gui_OutputFcn',  @showObjects_OutputFcn, ...
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


% --- Executes just before showObjects is made visible.
function showObjects_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to showObjects (see VARARGIN)

% Choose default command line output for showObjects
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global File Objects PartSequence SaveStruct NumStructs;
PartSequence = zeros(1, 16);
SaveStruct = struct('name', {}, 'type', {}, 'orientation', {}, 'location', {}, 'triangles', {});
NumStructs = 0;
axes(handles.axes1);
cla;
managePopupmenus(0)

% UIWAIT makes showObjects wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = showObjects_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(1) = PartNo;
PartSequence(2:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu2,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(2)


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(2) = PartNo;
PartSequence(3:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu3,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(3)

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(3) = PartNo;
PartSequence(4:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu4,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(4)

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(4) = PartNo;
PartSequence(5:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu5,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(5)

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(5) = PartNo;
PartSequence(6:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu6,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(6)

% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(6) = PartNo;
PartSequence(7:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu7,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(7)

% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(7) = PartNo;
PartSequence(8:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu8,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(8)

% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(8) = PartNo;
PartSequence(9:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu9,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(9)

% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu9.
function popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu9
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(9) = PartNo;
PartSequence(10:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu10,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(10)

% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(10) = PartNo;
PartSequence(11:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu11,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(11)

% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu11.
function popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu11
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(11) = PartNo;
PartSequence(12:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu12,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(12)

% --- Executes during object creation, after setting all properties.
function popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu12.
function popupmenu12_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu12
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(12) = PartNo;
PartSequence(13:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu13,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(13)

% --- Executes during object creation, after setting all properties.
function popupmenu12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu13.
function popupmenu13_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu13
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(13) = PartNo;
PartSequence(14:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu14,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(14)

% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu14.
function popupmenu14_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu14
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(14) = PartNo;
PartSequence(15:end) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu15,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(15)

% --- Executes during object creation, after setting all properties.
function popupmenu14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu15.
function popupmenu15_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu15 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu15
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(15) = PartNo;
PartSequence(16) = 0;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

if ~isempty(CurrStruct.struct)
    for i = 1:length(CurrStruct.struct)
        len = length(CurrStruct.struct(i).name);
        StringArr(i, 1:len) = CurrStruct.struct(i).name;
    end
else
    StringArr = 'No More Parts';
end
set(handles.popupmenu16,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(16)

% --- Executes during object creation, after setting all properties.
function popupmenu15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu16.
function popupmenu16_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu16 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu16
global Objects PartSequence;
PartNo = get(hObject,'Value');
PartName = get(hObject,'String');
PartSequence(16) = PartNo;
CurrStruct = getCurrentObject();
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));

% if ~isempty(CurrStruct.struct)
%     for i = 1:length(CurrStruct.struct)
%         len = length(CurrStruct.struct(i).name);
%         StringArr(i, 1:len) = CurrStruct.struct(i).name;
%     end
% else
%     StringArr = 'No More Parts';
% end
% set(handles.popupmenu2,'String',StringArr,'Value',1,'Visible','on');
% managePopupmenus(2)

% --- Executes during object creation, after setting all properties.
function popupmenu16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % % % % % plotH = handles.axes1;
% % % % % % orignalAxes = gca;
% % % % % % uicontrol('parent',gcf)
% % % % % 
% % % % % % %Create a ne figure
% % % % % % newFig = figure(1);
% % % % % % %Create a copy of the axes
% % % % % % newA = copyobj(orignalAxes,newFig);
% % % % % % %copy the plot across
% % % % % % % newPlotH = copyobj(plotH,newA);

CurrStruct = getCurrentObject();
pos = CurrStruct.positions;
tri = CurrStruct.triangles;
figure(1);
trimesh(tri', pos(1, :), pos(2, :), pos(3, :));


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SaveStruct NumStructs;
CurrStruct = getCurrentObject();
NumStructs = NumStructs + 1;
SaveStruct(NumStructs).name = CurrStruct.name;
SaveStruct(NumStructs).location = CurrStruct.positions;
SaveStruct(NumStructs).triangles = CurrStruct.triangles;
SaveStruct(NumStructs).type = str2double(get(handles.edit1, 'String'));
SaveStruct(NumStructs).orientation = str2double(get(handles.edit3, 'String'));



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)

global File Objects;

% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[File Path filterinex] = uigetfile('E:\directed study\warehouse\*.dae');
File(1:end-4)
filename = strcat(Path, File);
Objects = getObjectsFromCollada(filename);
axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
for i = 1:length(Objects)
    len = length(Objects(i).name);
    StringArr(i, 1:len) = Objects(i).name;
    pos = Objects(i).positions;
    tri = Objects(i).triangles;
    trimesh(tri', pos(1, :), pos(2, :), pos(3, :));
    hold on
end
hold off;
set(handles.popupmenu1,'String',StringArr,'Value',1,'Visible','on');
managePopupmenus(1)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Objects PartSequence;

axes(handles.axes1);
cla;
set(handles.axes1,'Visible','on');
for i = 1:length(Objects)
    pos = Objects(i).positions;
    tri = Objects(i).triangles;
    trimesh(tri', pos(1, :), pos(2, :), pos(3, :));
    hold on
end
hold off;

function managePopupmenus(index)

MaxPopupmenus = 16;
handles = guihandles;
PopupmenuHandles = [handles.popupmenu1;
                  handles.popupmenu2;
                  handles.popupmenu3;
                  handles.popupmenu4;
                  handles.popupmenu5;
                  handles.popupmenu6;
                  handles.popupmenu7;
                  handles.popupmenu8;
                  handles.popupmenu9;
                  handles.popupmenu10;
                  handles.popupmenu11;
                  handles.popupmenu12;
                  handles.popupmenu13;
                  handles.popupmenu14;
                  handles.popupmenu15;
                  handles.popupmenu16];
              
for i = index + 1:MaxPopupmenus
    set(PopupmenuHandles(i), 'Visible', 'off');
end

function OutStruct = getCurrentObject()
global Objects PartSequence;
OutStruct = Objects(PartSequence(1));
i = 2;
while PartSequence(i) ~= 0
    OutStruct = OutStruct.struct(PartSequence(i));
    i = i + 1;
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SaveStruct File;
File(1:end-4)
save(File(1:end-4), 'SaveStruct');
