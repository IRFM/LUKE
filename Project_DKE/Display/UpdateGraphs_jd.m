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
function UpdateGraphs_jd(hObject, eventdata, handles, axes, selectedgraphs)
%
% This function updates all properties of the selected graphs in axes.
%
Children = get(hObject,'children');
%
for iChild = 1:length(Children),
    %
    PropertyList = get(Children(iChild),'string');
    if ~iscell(PropertyList)
        continue
    end
    %
    PropertyStyle = PropertyList{1};
    %
    % update line style
    %
    if isequal(PropertyStyle,'Line style'),
        %
        UpdateGraphProperty_jd(Children(iChild), [], handles, axes, selectedgraphs, 'linestyle', handles.listoflinestyles)
        %
    elseif isequal(PropertyStyle,'Line width'),
        %
        UpdateGraphProperty_jd(Children(iChild), [], handles, axes, selectedgraphs, 'linewidth', handles.listoflinewidths)
        %
    elseif isequal(PropertyStyle,'Line color'),
        %
        UpdateGraphProperty_jd(Children(iChild), [], handles, axes, selectedgraphs, 'color', handles.listoflinecolors)
        %
    elseif isequal(PropertyStyle,'Marker style'),
        %
        UpdateGraphProperty_jd(Children(iChild), [], handles, axes, selectedgraphs, 'marker', handles.listofmarkerstyles)
        %
    elseif isequal(PropertyStyle,'Marker size'),
        %
        UpdateGraphProperty_jd(Children(iChild), [], handles, axes, selectedgraphs, 'markersize', handles.listofmarkersizes)
        %
    elseif isequal(PropertyStyle,'Marker color'),
        %
        UpdateGraphProperty_jd(Children(iChild), [], handles, axes, selectedgraphs, 'markeredgecolor', handles.listofmarkercolors)
        %
    end
end





