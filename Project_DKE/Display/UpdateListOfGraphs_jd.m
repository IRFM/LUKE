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
