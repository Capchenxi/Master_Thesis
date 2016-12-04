%Before exacute this GUI you should define global variables i=0;k=0;fpts=[]

function varargout = pick_pts_2d(varargin)
% PICK_PTS_2D MATLAB code for pick_pts_2d.fig
%      PICK_PTS_2D, by itself, creates a new PICK_PTS_2D or raises the existing
%      singleton*.
%
%      H = PICK_PTS_2D returns the handle to a new PICK_PTS_2D or the handle to
%      the existing singleton*.
%
%      PICK_PTS_2D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PICK_PTS_2D.M with the given input arguments.
%
%      PICK_PTS_2D('Property','Value',...) creates a new PICK_PTS_2D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pick_pts_2d_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pick_pts_2d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pick_pts_2d

% Last Modified by GUIDE v2.5 30-Oct-2016 14:18:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pick_pts_2d_OpeningFcn, ...
                   'gui_OutputFcn',  @pick_pts_2d_OutputFcn, ...
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


% --- Executes just before pick_pts_2d is made visible.
function pick_pts_2d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pick_pts_2d (see VARARGIN)

% Choose default command line output for pick_pts_2d
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

clc;

set( handles.edit1, 'String', pwd )
data.handles = handles;
    data.StartFolder = pwd;
    data.mouse_position_last = [ 0, 0 ];
    data.mouse_position = [ 0, 0 ];
    data.clickpos = [ 0, 0 ];
    data.currentpos = [ 0, 0 ];
    data.axes_size = [ 100, 100 ];
    data.Image = 0;
    data.Nt = 0;    % number of triangles
    data.Np = 0;    % number of points
    data.id = 0;    % serial # for each point
    data.h_tri = -1;
    data.h_pts = -1;
    data.h_mark = -1;
    data.h_idx = -1;
    data.h_image = -1;
    data.h_table = -1;
    data.moveflag = 0;
    data.inRangeX = 0;
    data.inRangeY = 0;
    data.Finished_Poses = [];
    data.filename = [];
    data.CurrentFolder = [];
    data.suffix = [];
    data.Pose = [];
    data.trep = [];
    data.SAVED = 0;
    setMyData(data);
    set(gcf, 'WindowButtonDownFcn', @getMousePositionOnImage);

% UIWAIT makes pick_pts_2d wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pick_pts_2d_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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


% --------------------------------------------------------------------
function menu_load_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
P = get(0,'PointerLocation');
    data = getMyData();
    if data.Np ~= 0
        h_w = warndlg('Please reset before loading!', 'Warning Dialog', 'modal');
        uiwait(h_w);
        set(0,'PointerLocation',P);
        return;
    end
    StartFolder = pwd;
    CurrentFolder = get( handles.edit1, 'String' );
    [ filename, pathname ] = uigetfile({'*.jpg', 'JPG';'*.png', 'PNG';'*.*', 'All files (*.*)'}, 'Choose a image file', CurrentFolder );
    if isequal(filename,0) || isequal(pathname,0)
        disp('No valid file selected!');
        set(0,'PointerLocation',P);
        return;
    end
    data.Image = im2double( imread( fullfile( pathname, filename ) ) );
    [ h, w, ~ ] = size(data.Image);
%     if h > 1280 || w > 1280
%         h_w = warndlg('Image must be 1280x1280!', 'Warning Dialog', 'modal');
%         uiwait(h_w);
%         set(0,'PointerLocation',P);
%         return;
%     end
    % load the pose number of the model
    setMyData(data);
    display_photo();
    set(0,'PointerLocation',P);


% --------------------------------------------------------------------
function menu_reset_Callback(hObject, eventdata, handles)
% hObject    handle to menu_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 global i k fpts
    i = 0;
    k = 0;
    fpts = [];
    h_w = warndlg('The GUI has been reset!', 'Warning Dialog', 'modal');
    uiwait(h_w);



% --------------------------------------------------------------------
function menu_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  folder = get(handles.edit1,'String');
  global fpts;
  uisave( {'fpts'}, 'fpts' );
  
  function getMousePositionOnImage(src, event)
  handles = guidata(src);

  cursorPoint = get(handles.axes1, 'CurrentPoint');
  curX = cursorPoint(1,1);
  curY = cursorPoint(1,2);

  xLimits = get(handles.axes1, 'xlim');
  yLimits = get(handles.axes1, 'ylim');

    if (curX > min(xLimits) && curX < max(xLimits) && curY > min(yLimits) && curY < max(yLimits))
        global i fpts
        i = i+1;
        disp(['Cursor coordinates are ( ' num2str(curX) ', ' num2str(curY) ').']); 
        fpts(i,1) = curX;
        fpts(i,2) = curY;
        plot(fpts(i,1),fpts(i,2),'r*');
        set(handles.uitable1,'Data',fpts);
    else
        disp('Cursor is outside bounds of image.');  
    end

    function setMyData(data)
    % Store data struct in figure
    setappdata(gcf,'data2d',data);
    function [ data ] = getMyData()
    % Get data struct stored in figure
    data = getappdata( gcf, 'data2d' );
    
    function display_photo()
    data = getMyData();
    data.h_image = imshow(data.Image, 'InitialMagnification', 'fit'); hold on;
    data.axes_size = get(data.handles.axes1,'PlotBoxAspectRatio');
    % set(get(data.handles.axes1,'Children'),'ButtonDownFcn','Align2DFeatureGUI(''axes1_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
    setMyData(data);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global i k fpts
k = k+1;
temp = get(handles.axes1,'Children');
set(temp(k),'visible','off');
% temp = fpts(i,1:2);
% set(temp,'visible','off');
fpts(i,:) = [];
i = i-1;
set(handles.uitable1,'Data',fpts);
