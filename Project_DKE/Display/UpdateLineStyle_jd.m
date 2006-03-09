function UpdateLineStyle_jd(hObject, eventdata, handles, axes, selectedgraphs)
%
% This function updates the line properties of the selected graphs in axes.
%
NumberOfLineStyles = 0;
for iGraph = 1:length(handles.graphs),
    if isequal(handles.graphs{iGraph}.axes,axes)...
     & min(abs(selectedgraphs - iGraph)) == 0,
        NumberOfLineStyles = NumberOfLineStyles + 1;
        LineStyles{NumberOfLineStyles} = get(handles.graphs{iGraph}.hgraph,'linestyle');
    end
end
%
if isempty(LineStyles),
    set(hObject,'Value',1);
    return
end
%
LineStyleRef = LineStyles{1};
for iLineStyle = 2:length(LineStyles),
    if ~isequal(LineStyleRef,LineStyles{iLineStyle}),
        set(hObject,'Value',1);
        return
    end
end
%
if isequal(LineStyleRef,'-'),
    set(hObject,'Value',3);
elseif isequal(LineStyleRef,'--'),
    set(hObject,'Value',4);
elseif isequal(LineStyleRef,':'),
    set(hObject,'Value',5);
elseif isequal(LineStyleRef,'-.'),
    set(hObject,'Value',6);
elseif isequal(LineStyleRef,'none'),
    set(hObject,'Value',7);
end
%
