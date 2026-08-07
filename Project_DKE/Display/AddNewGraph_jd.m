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
function [handles,SelectedGraphs] = AddNewGraph_jd(hObject, eventdata, handles, axes, listbox, visible, selectedgraphs)
% 
% This function adds a new graph to axes and stores it in handles
%
graph = AddGraph_jd(axes, [], handles);
%
SelectedGraphs = selectedgraphs;
%
if ~isempty(graph)
    %
    % add graph to the list of graphs
    %
    handles.graphs{length(handles.graphs) + 1} = graph;
    %
    UpdateListOfGraphs_jd(listbox, [], handles, axes);
    %
    NewInListIndex = length(get(listbox,'String'));
    %
    set(listbox,'Value',NewInListIndex)
    %
    SelectedGraphs = length(handles.graphs);
    %
    UpdateVisible_jd(visible, [], handles, axes, SelectedGraphs);
    %
end
