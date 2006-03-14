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





