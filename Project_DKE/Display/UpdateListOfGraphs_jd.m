function UpdateListOfGraphs_jd(hObject, eventdata, handles, axes)
%
% This function updates the list of graphs in listbox
%
%
ListOfGraphs{1} = 'Click "New" to display results';%Default text
iList = 0;
for iGraph = 1:length(handles.graphs),
    if isequal(handles.graphs{iGraph}.axes,axes),
        iList = iList+1;
        ListOfGraphs{iList} = handles.graphs{iGraph}.type;
    end
end        
%
set(hObject,'string',ListOfGraphs)
