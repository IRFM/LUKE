function varargout = display_dke(varargin)
% DISPLAY_DKE M-file for display_dke.fig
%      DISPLAY_DKE, by itself, creates a new DISPLAY_DKE or raises the existing
%      singleton*.
%
%      H = DISPLAY_DKE returns the handle to a new DISPLAY_DKE or the handle to
%      the existing singleton*.
%
%      DISPLAY_DKE('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in DISPLAY_DKE.M with the given input arguments.
%
%      DISPLAY_DKE('Property','Value',...) creates a new DISPLAY_DKE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before display_dke_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to display_dke_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help display_dke

% Last Modified by GUIDE v2.5 14-Mar-2006 13:19:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @display_dke_OpeningFcn, ...
                   'gui_OutputFcn',  @display_dke_OutputFcn, ...
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


% --- Executes just before display_dke is made visible.
function display_dke_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to display_dke (see VARARGIN)

% Choose default command line output for display_dke
handles.output = hObject;

% ------------- My Changes --------------
%
handles.scenarios = {};
handles.graphs = {};
handles.selectedgraphs1 = [];
handles.selectedgraphs2 = [];
%
[handles.listofgraphtypes,...
 handles.listoflinestyles,...
 handles.listoflinewidths,...
 handles.listoflinecolors,...
 handles.listofmarkerstyles,...
 handles.listofmarkersizes,...
 handles.listofmarkercolors]...
    = GetGraphProperties_jd;
%
UpdateVisible_jd(handles.visible1, [], handles, handles.axes1, handles.selectedgraphs1);
UpdateVisible_jd(handles.visible2, [], handles, handles.axes2, handles.selectedgraphs2);
%
set(handles.modifypanel1,'visible','off')
set(handles.modifypanel2,'visible','off')
%
% --------- End of My Changes -----------

%
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes display_dke wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = display_dke_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%
% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
%
% This function calls a submenu.
%

% --------------------------------------------------------------------
function Load_Callback(hObject, eventdata, handles)
%
% This function loads a scenario resulting from DKE calculations.
%
[filename,pathname] = uigetfile('RESULTS_*.mat','Load DKE Scenario');
%
if filename == 0,
    return
else
    filename = [pathname,filename];
end
%
NumberOfScenarios = length(handles.scenarios);
%
for iScenario = 1:NumberOfScenarios,
    if isequal(handles.scenarios{iScenario}.name,filename),
        h = warndlg('The scenario you are trying to load is already in memory','Existing scenario');
        return
    end
end
%
load(filename,'equil');
%
handles.scenarios{NumberOfScenarios + 1}.name = filename; 
%
guidata(hObject,handles);
%

% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
%
% This function opens a worspace previously saved.
%
[filename,pathname] = uigetfile('.dke','Open Saved Workspace');
%
if filename == 0,
    return
end
%
load([pathname,filename],'scenarios','graphs','listofgraphtypes','selectedgraphs1','selectedgraphs2','-mat')
%
handles.scenarios = scenarios;
handles.graphs = graphs;
handles.listofgraphtypes = listofgraphtypes;
handles.selectedgraphs1 = selectedgraphs1;
handles.selectedgraphs2 = selectedgraphs2;
%
UpdateListOfGraphs_jd(handles.listbox1, eventdata, handles, handles.axes1)
UpdateListOfGraphs_jd(handles.listbox2, eventdata, handles, handles.axes2)
%
guidata(hObject,handles);
%

% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)
%
% This function saves the current worspace.
%
[filename,pathname] = uiputfile('.dke','Save Workspace','display_workspace');
%
if filename == 0,
    return
end
%
scenarios = handles.scenarios;
graphs = handles.graphs;
listofgraphtypes = handles.listofgraphtypes;
selectedgraphs1 = handles.selectedgraphs1;
selectedgraphs2 = handles.selectedgraphs2;
%
save([pathname,filename],'scenarios','graphs','listofgraphtypes','selectedgraphs1','selectedgraphs2','-mat')
%

% --------------------------------------------------------------------
function Print_Callback(hObject, eventdata, handles)
%
% This function prints the main window.
%
%printdlg('-crossplatform',handles.figure1)
printdlg(handles.figure1)
%
% --------------------------------------------------------------------
function Exit_Callback(hObject, eventdata, handles)
%
% This function closes display_dke.
%
close(handles.figure1)
%

% --------------------------------------------------------------------
function Tools_Callback(hObject, eventdata, handles)
% hObject    handle to Tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
%
% This function finds and writes the indexes of selected graphs
%
selectedgraphs1 = UpdateSelectedGraphs_jd(hObject, [], handles, handles.axes1, handles.visible1);
%
handles.selectedgraphs1 = selectedgraphs1;
%
UpdateGraphs_jd(handles.modifypanel1, [], handles, handles.axes1, handles.selectedgraphs1);
%
guidata(hObject,handles);
%

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
%
% This function finds and writes the indexes of selected graphs
%
selectedgraphs2 = UpdateSelectedGraphs_jd(hObject, [], handles, handles.axes2, handles.visible2);
%
handles.selectedgraphs2 = selectedgraphs2;
%
UpdateGraphs_jd(handles.modifypanel2, [], handles, handles.axes2, handles.selectedgraphs2);
%
guidata(hObject,handles);
%

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in new1.
function new1_Callback(hObject, eventdata, handles)
% 
% This function adds a new graph to axes1 and stores it in handles
%
[handles,selectedgraphs1] = AddNewGraph_jd(hObject, [], handles, handles.axes1, handles.listbox1, handles.visible1, handles.selectedgraphs1);
%
handles.selectedgraphs1 = selectedgraphs1;
%
UpdateGraphs_jd(handles.modifypanel1, [], handles, handles.axes1, handles.selectedgraphs1);
%
guidata(hObject,handles);
%

% --- Executes on button press in new2.
function new2_Callback(hObject, eventdata, handles)
% 
% This function adds a new graph to axes2 and stores it in handles
%
[handles,selectedgraphs2] = AddNewGraph_jd(hObject, [], handles, handles.axes2, handles.listbox2, handles.visible2, handles.selectedgraphs2);
%
handles.selectedgraphs2 = selectedgraphs2;
%
UpdateGraphs_jd(handles.modifypanel2, [], handles, handles.axes2, handles.selectedgraphs2);
%
guidata(hObject,handles);
%

% --- Executes on button press in remove1.
function remove1_Callback(hObject, eventdata, handles)
%
% This function erase selected graphs from axes1
%
[handles,selectedgraphs1] = RemoveGraph_jd(hObject, [], handles, handles.axes1, handles.listbox1, handles.visible1, handles.selectedgraphs1);
%
handles.selectedgraphs1 = selectedgraphs1;
%
UpdateGraphs_jd(handles.modifypanel1, [], handles, handles.axes1, handles.selectedgraphs1);
%
guidata(hObject,handles);
%

% --- Executes on button press in remove2.
function remove2_Callback(hObject, eventdata, handles)
%
% This function erase selected graphs from axes2
%
[handles,selectedgraphs2] = RemoveGraph_jd(hObject, [], handles, handles.axes2, handles.listbox2, handles.visible2, handles.selectedgraphs2);
%
handles.selectedgraphs2 = selectedgraphs2;
%
UpdateGraphs_jd(handles.modifypanel2, [], handles, handles.axes2, handles.selectedgraphs2);
%
guidata(hObject,handles);
%

% --- Executes on button press in visible1.
function visible1_Callback(hObject, eventdata, handles)
%
%  This function inverts the visible status of selected graphs on axes1
%
ChangeVisible_jd(hObject, [], handles, handles.axes1, handles.selectedgraphs1)
%

% --- Executes on button press in visible2.
function visible2_Callback(hObject, eventdata, handles)
%
%  This function inverts the visible status of selected graphs on axes1
%
ChangeVisible_jd(hObject, [], handles, handles.axes2, handles.selectedgraphs2)
%

% --- Executes on button press in modify1.
function modify1_Callback(hObject, eventdata, handles)
% 
% Sets the modify panel to visible instead of the result panel
% 
if isequal(get(hObject,'string'),'Modify')
    set(handles.modifypanel1,'visible','on')
    set(hObject,'string','Hide')
else
    set(handles.modifypanel1,'visible','off')
    set(hObject,'string','Modify')
end
%

% --- Executes on button press in modify2.
function modify2_Callback(hObject, eventdata, handles)
% 
% Sets the modify panel to visible instead of the result panel
% 
if isequal(get(hObject,'string'),'Modify')
    set(handles.modifypanel2,'visible','on')
    set(hObject,'string','Hide')
else
    set(handles.modifypanel2,'visible','off')
    set(hObject,'string','Modify')
end
%

% --- Executes on selection change in linestyle1.
function linestyle1_Callback(hObject, eventdata, handles)
%
% This function changes the line properties of the selected graphs in axes1.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes1, handles.selectedgraphs1, 'linestyle', handles.listoflinestyles);
%

% --- Executes during object creation, after setting all properties.
function linestyle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linestyle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in linestyle2.
function linestyle2_Callback(hObject, eventdata, handles)
%
% This function changes the line properties of the selected graphs in axes2.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes2, handles.selectedgraphs2, 'linestyle', handles.listoflinestyles);
%

% --- Executes during object creation, after setting all properties.
function linestyle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linestyle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in linewidth1.
function linewidth1_Callback(hObject, eventdata, handles)
%
% This function changes the line width of the selected graphs in axes1.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes1, handles.selectedgraphs1, 'linewidth', handles.listoflinewidths);
%

% --- Executes during object creation, after setting all properties.
function linewidth1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linewidth1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in linewidth2.
function linewidth2_Callback(hObject, eventdata, handles)
%
% This function changes the line width of the selected graphs in axes2.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes2, handles.selectedgraphs2, 'linewidth', handles.listoflinewidths);
%

% --- Executes during object creation, after setting all properties.
function linewidth2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linewidth2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in linecolor1.
function linecolor1_Callback(hObject, eventdata, handles)
%
% This function changes the line color of the selected graphs in axes1.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes1, handles.selectedgraphs1, 'color', handles.listoflinecolors);
%

% --- Executes during object creation, after setting all properties.
function linecolor1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linecolor1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in linecolor2.
function linecolor2_Callback(hObject, eventdata, handles)
%
% This function changes the line color of the selected graphs in axes2.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes2, handles.selectedgraphs2, 'color', handles.listoflinecolors);
%

% --- Executes during object creation, after setting all properties.
function linecolor2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linecolor2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in markerstyle1.
function markerstyle1_Callback(hObject, eventdata, handles)
%
% This function changes the marker style of the selected graphs in axes1.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes1, handles.selectedgraphs1, 'marker', handles.listofmarkerstyles);
%

% --- Executes during object creation, after setting all properties.
function markerstyle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markerstyle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in markerstyle2.
function markerstyle2_Callback(hObject, eventdata, handles)
%
% This function changes the marker style of the selected graphs in axes2.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes2, handles.selectedgraphs2, 'marker', handles.listofmarkerstyles);
%

% --- Executes during object creation, after setting all properties.
function markerstyle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markerstyle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in markersize1.
function markersize1_Callback(hObject, eventdata, handles)
%
% This function changes the marker size of the selected graphs in axes1.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes1, handles.selectedgraphs1, 'markersize', handles.listofmarkersizes);
%

% --- Executes during object creation, after setting all properties.
function markersize1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markersize1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in markersize2.
function markersize2_Callback(hObject, eventdata, handles)
%
% This function changes the marker size of the selected graphs in axes1.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes2, handles.selectedgraphs2, 'markersize', handles.listofmarkersizes);
%

% --- Executes during object creation, after setting all properties.
function markersize2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markersize2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in markercolor1.
function markercolor1_Callback(hObject, eventdata, handles)
%
% This function changes the marker color of the selected graphs in axes1.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes1, handles.selectedgraphs1, 'markeredgecolor', handles.listofmarkercolors);
ChangeGraphProperty_jd(hObject, [], handles, handles.axes1, handles.selectedgraphs1, 'markerfacecolor', handles.listofmarkercolors);
%

% --- Executes during object creation, after setting all properties.
function markercolor1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markercolor1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in markercolor2.
function markercolor2_Callback(hObject, eventdata, handles)
%
% This function changes the marker color of the selected graphs in axes1.
%
ChangeGraphProperty_jd(hObject, [], handles, handles.axes2, handles.selectedgraphs2, 'markeredgecolor', handles.listofmarkercolors);
ChangeGraphProperty_jd(hObject, [], handles, handles.axes2, handles.selectedgraphs2, 'markerfacecolor', handles.listofmarkercolors);
%

% --- Executes during object creation, after setting all properties.
function markercolor2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markercolor2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


