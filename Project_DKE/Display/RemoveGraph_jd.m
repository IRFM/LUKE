function [handles,SelectedGraphs] = RemoveGraph_jd(hObject, eventdata, handles, axes, listbox, visible, selectedgraphs)
%
% This function erase selected graphs from axes
%
ListOfRemovedGraphs = [];
for iGraph = selectedgraphs,
    if isequal(handles.graphs{iGraph}.axes,axes),
        ListOfRemovedGraphs = [ListOfRemovedGraphs,iGraph];
    end
end
%
handles.graphs(ListOfRemovedGraphs) = [];
%
UpdateListOfGraphs_jd(listbox, [], handles, axes);
%
UpdatePlotOfGraphs_jd(axes, [], handles);
%
set(listbox,'Value',1)
%
SelectedGraphs = 1;
%
UpdateVisible_jd(visible, [], handles, axes, SelectedGraphs);
