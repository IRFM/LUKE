function handles = ChangeLineStyle_jd(hObject, eventdata, handles, axes, selectedgraphs)
%
% This function changes the line properties of the selected graphs in axes.
%
NewLinestyleindex = get(hObject,'Value');
%
if NewLinestyleindex == 3,
    NewLinestyle = '-';
elseif NewLinestyleindex == 4,
    NewLinestyle = '--';
elseif NewLinestyleindex == 5,
    NewLinestyle = ':';
elseif NewLinestyleindex == 6,
    NewLinestyle = '-.';
elseif NewLinestyleindex == 7,
    NewLinestyle = 'none';
else
    return
end
%
LineStyles = [];
for iGraph = 1:length(handles.graphs),
    if isequal(handles.graphs{iGraph}.axes,axes)...
     & min(abs(selectedgraphs - iGraph)) == 0,
        set(handles.graphs{iGraph}.hgraph,'linestyle',NewLinestyle) 
    end
end
%