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
function UpdateVisible_jd(hObject, eventdata, handles, axes, selectedgraphs)
%
% This function updates the visible state of selected graphs
%
Visiblegraphs = [];
for iGraph = 1:length(handles.graphs),
    if isequal(handles.graphs{iGraph}.axes,axes)...
     & min(abs(selectedgraphs - iGraph)) == 0,
        Visiblegraphs = [Visiblegraphs,isequal(get(handles.graphs{iGraph}.hgraph,'visible'),'on')]; 
    end
end
%
if max(Visiblegraphs) == 0,
    set(hObject,'value',0,'visible','on');
elseif min(Visiblegraphs) == 1,
    set(hObject,'value',1,'visible','on');
else
    set(hObject,'visible','off')
end
%
