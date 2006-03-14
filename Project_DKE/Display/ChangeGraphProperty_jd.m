function ChangeGraphProperty_jd(hObject, eventdata, handles, axes, selectedgraphs, property, listofitems)
%
% This function changes any property of the selected graphs in axes.
%
NewPropertyItemIndex = get(hObject,'Value');
%
if NewPropertyItemIndex > 2,
    NewProperty = listofitems{NewPropertyItemIndex - 2};
else
    return
end
%
for iGraph = 1:length(handles.graphs),
    if isequal(handles.graphs{iGraph}.axes,axes)...
     & min(abs(selectedgraphs - iGraph)) == 0,
        set(handles.graphs{iGraph}.hgraph,property,NewProperty) 
    end
end
%