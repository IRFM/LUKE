function UpdatePlotOfGraphs_jd(hObject, eventdata, handles)
%
% This function updates the list of graphs in listbox
%
%
ListOfGraphs = [];
for iGraph = 1:length(handles.graphs),
    ListOfGraphs(iGraph) = handles.graphs{iGraph}.hgraph;
end        
%
ListOfPlots = get(hObject,'Children');
%
for iPlot = 1:length(ListOfPlots),
    if isempty(ListOfGraphs) | min(abs(ListOfGraphs - ListOfPlots(iPlot))) ~= 0
        delete(ListOfPlots(iPlot))
    end
end
%
if isempty(get(hObject,'Children'))
    delete(get(hObject,'xlabel'));
    delete(get(hObject,'ylabel'));
    delete(get(hObject,'zlabel'));
end
