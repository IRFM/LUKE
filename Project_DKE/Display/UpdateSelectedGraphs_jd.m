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
function SelectedGraphs = UpdateSelectedGraphs_jd(hObject, eventdata, handles, axes, visible)
%
% This function finds the indexes of selected graphs based on the listbox 
% user selection.
%
graphtypes = get(hObject,'String');
graphtypesselected = graphtypes(get(hObject,'Value'));
%
SelectedGraphs = [];
%
for iGraph = 1:length(handles.graphs),
    for iList = 1:length(graphtypesselected),
        if isequal(handles.graphs{iGraph}.axes,axes)...
         & isequal(handles.graphs{iGraph}.type,graphtypesselected{iList}),
            SelectedGraphs = [SelectedGraphs,iGraph];
        end
    end
end
%
UpdateVisible_jd(visible, [], handles, axes, SelectedGraphs);
%
