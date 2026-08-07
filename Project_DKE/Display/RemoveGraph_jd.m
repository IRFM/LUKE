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
function [handles,SelectedGraphs] = RemoveGraph_jd(hObject, eventdata, handles, axes, listbox, visible, selectedgraphs)
%
% This function erase selected graphs from axes
%
ListOfRemovedGraphs = [];
for iGraph = selectedgraphs,
    if isequal(handles.graphs{iGraph}.axes,axes),
        ListOfRemovedGraphs = [ListOfRemovedGraphs,iGraph];
    end
end
%
handles.graphs(ListOfRemovedGraphs) = [];
%
UpdateListOfGraphs_jd(listbox, [], handles, axes);
%
UpdatePlotOfGraphs_jd(axes, [], handles);
%
set(listbox,'Value',1)
%
SelectedGraphs = 1;
%
UpdateVisible_jd(visible, [], handles, axes, SelectedGraphs);
