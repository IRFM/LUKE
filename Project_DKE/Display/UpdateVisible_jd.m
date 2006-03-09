function UpdateVisible_jd(hObject, eventdata, handles, axes, selectedgraphs)
%
% This function updates the visible state of selected graphs
%
Visiblegraphs = [];
for iGraph = 1:length(handles.graphs),
    if isequal(handles.graphs{iGraph}.axes,axes)...
     & min(abs(selectedgraphs - iGraph)) == 0,
        Visiblegraphs = [Visiblegraphs,isequal(get(handles.graphs{iGraph}.hgraph,'visible'),'on')]; 
    end
end
%
if max(Visiblegraphs) == 0,
    set(hObject,'value',0,'visible','on');
elseif min(Visiblegraphs) == 1,
    set(hObject,'value',1,'visible','on');
else
    set(hObject,'visible','off')
end
%
