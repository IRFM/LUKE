function graph = AddGraph_jd(hObject, eventdata, handles);
%
% This function adds a graph on axes upon user call, and returns the graph 
% as an output for saving.
%
graph = [];
%
% Select a scenario
%
NumberOfScenarios = length(handles.scenarios);
%
if NumberOfScenarios == 0
    h = warndlg('There are no scenario in memory. Go to File -> Load to add a scenario','No scenario');
    return
elseif NumberOfScenarios > 1
    %
    for iScenario = 1:NumberOfScenarios,
        ListOfScenario{iScenario} = handles.scenarios{iScenario}.name;
    end
    %
    iScenario = listdlg('PromptString','Select a scenario',...
                        'SelectionMode','single',...
                        'ListString',ListOfScenario);
    %
    if isempty(iScenario)
        return
    end
else
    iScenario = 1;
end
%
scenario = handles.scenarios{iScenario}.name;
%
% Select the graph
%
ListOfGraphTypes = handles.listofgraphtypes;
NumberOfGraphs = length(handles.graphs);
%
iGraphType = listdlg('PromptString','Select a graph',...
                     'SelectionMode','single',...
                     'ListString',ListOfGraphTypes);
%
type = ListOfGraphTypes{iGraphType};                 
%
for iGraph = 1:NumberOfGraphs,
    if isequal(handles.graphs{iGraph}.type,type)...
     & isequal(handles.graphs{iGraph}.scenario,scenario)...
     & isequal(handles.graphs{iGraph}.axes,hObject),
        h = warndlg('The graph you are calling is already displayed in the current axes.','Existing graph');
        return
    end
end
%
graph.type = type;
graph.scenario = scenario;
graph.axes = hObject;
%
% Get graph data
%
[x,y,z,xlab,ylab,zlab,warnstr] = GetGraphData_jd(handles, graph);
%
if ~isempty(warnstr),
    h = warndlg(warnstr,'Operation aborted');
    graph = [];
    return
end
%
axxlab = get(get(hObject,'xlabel'),'string');
axylab = get(get(hObject,'ylabel'),'string');
axzlab = get(get(hObject,'zlabel'),'string');
%
% Print the graph
%
if isempty(z),% 2D graph
    %
    if (~isempty(axxlab) & ~isequal(axxlab,xlab)) | ~isempty(axzlab),
        h = warndlg('The graph you are calling is not compatible with the current axis.','Incompatible graph');
        graph = [];
        return
    end
    %  
    graph.hgraph = line(x,y,'parent',hObject);
    graph.cgraph = NaN;
    graph.xlab = xlab;
    graph.ylab = ylab;    
    %
    set(get(hObject,'xlabel'),'string',xlab,'fontsize',get(hObject,'fontsize'));
    %
else% 3D graph
    %
    if (~isempty(axxlab) & ~isequal(axxlab,xlab))...
     | (~isempty(axylab) & ~isequal(axylab,ylab)),
        h = warndlg('The graph you are calling is not compatible with the current axis.','Incompatible graph');
        graph = [];
        return
    end
    %
    [graph.cgraph,graph.hgraph] = contour(x,y,z,'parent',hObject);
    graph.xlab = xlab;
    graph.ylab = ylab;    
    graph.zlab = zlab;    
    %
    set(get(hObject,'xlabel'),'string',xlab,'fontsize',get(hObject,'fontsize'));
    set(get(hObject,'ylabel'),'string',ylab,'fontsize',get(hObject,'fontsize'));
end
