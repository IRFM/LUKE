function UpdateGraphProperty_jd(hObject, eventdata, handles, axes, selectedgraphs, property, listofitems)
%
% This function updates any property of the selected graphs in axes.
%
NumberOfPropertyItems = 0;
PropertyItems = {};
for iGraph = 1:length(handles.graphs),
    if isequal(handles.graphs{iGraph}.axes,axes)...
     & min(abs(selectedgraphs - iGraph)) == 0,
        NumberOfPropertyItems = NumberOfPropertyItems + 1;
        PropertyItems{NumberOfPropertyItems} = get(handles.graphs{iGraph}.hgraph,property);
    end
end
%
if isempty(PropertyItems),
    set(hObject,'Value',1);
    return
end
%
PropertyItemsRef = PropertyItems{1};
for iPropertyItems = 2:length(PropertyItems),
    if ~isequal(PropertyItemsRef,PropertyItems{iPropertyItems}),
        set(hObject,'Value',1);
        return
    end
end
%
for iItem = 1:length(listofitems),
    if isequal(PropertyItemsRef,listofitems{iItem}),
        set(hObject,'Value',iItem + 2);
    end
end
%
