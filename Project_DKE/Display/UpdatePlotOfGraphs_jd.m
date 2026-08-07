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
function UpdatePlotOfGraphs_jd(hObject, eventdata, handles)
%
% This function updates the list of graphs in listbox
%
%
ListOfGraphs = [];
for iGraph = 1:length(handles.graphs),
    ListOfGraphs(iGraph) = handles.graphs{iGraph}.hgraph;
end        
%
ListOfPlots = get(hObject,'Children');
%
for iPlot = 1:length(ListOfPlots),
    if isempty(ListOfGraphs) | min(abs(ListOfGraphs - ListOfPlots(iPlot))) ~= 0
        delete(ListOfPlots(iPlot))
    end
end
%
if isempty(get(hObject,'Children'))
    delete(get(hObject,'xlabel'));
    delete(get(hObject,'ylabel'));
    delete(get(hObject,'zlabel'));
end
