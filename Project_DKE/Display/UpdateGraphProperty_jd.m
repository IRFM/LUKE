% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
