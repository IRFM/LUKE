function [handles,SelectedGraphs] = AddNewGraph_jd(hObject, eventdata, handles, axes, listbox, visible, selectedgraphs)
% 
% This function adds a new graph to axes and stores it in handles
%
graph = AddGraph_jd(axes, [], handles);
%
SelectedGraphs = selectedgraphs;
%
if ~isempty(graph)
    %
    % add graph to the list of graphs
    %
    handles.graphs{length(handles.graphs) + 1} = graph;
    %
    UpdateListOfGraphs_jd(listbox, [], handles, axes);
    %
    NewInListIndex = length(get(listbox,'String'));
    %
    set(listbox,'Value',NewInListIndex)
    %
    SelectedGraphs = length(handles.graphs);
    %
    UpdateVisible_jd(visible, [], handles, axes, SelectedGraphs);
    %
end
