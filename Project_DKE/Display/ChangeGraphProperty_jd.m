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