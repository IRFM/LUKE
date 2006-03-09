function ChangeVisible_jd(hObject, eventdata, handles, axes, selectedgraphs)
%
% This function inverts the visible status of selected graphs
%
if get(hObject,'value') == 0,
    visible = 'off';
else
    visible = 'on';
end
%
for iGraph = 1:length(handles.graphs),
    if isequal(handles.graphs{iGraph}.axes,axes)...
     & min(abs(selectedgraphs - iGraph)) == 0,
        set(handles.graphs{iGraph}.hgraph,'visible',visible); 
    end
end
