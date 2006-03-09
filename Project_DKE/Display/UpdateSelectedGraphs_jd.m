function SelectedGraphs = UpdateSelectedGraphs_jd(hObject, eventdata, handles, axes, visible)
%
% This function finds the indexes of selected graphs based on the listbox 
% user selection.
%
graphtypes = get(hObject,'String');
graphtypesselected = graphtypes(get(hObject,'Value'));
%
SelectedGraphs = [];
%
for iGraph = 1:length(handles.graphs),
    for iList = 1:length(graphtypesselected),
        if isequal(handles.graphs{iGraph}.axes,axes)...
         & isequal(handles.graphs{iGraph}.type,graphtypesselected{iList}),
            SelectedGraphs = [SelectedGraphs,iGraph];
        end
    end
end
%
UpdateVisible_jd(visible, [], handles, axes, SelectedGraphs);
%
