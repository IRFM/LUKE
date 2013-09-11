function iluke_update_state(s)
%
% This function recursively update the state of objects
%
if isfield(s,'handle'),
    if isfield(s,'state')
        set(s.handle,'Enable',s.state);
    end
    if isfield(s,'string')
        set(s.handle,'String',s.string);
    end
elseif isstruct(s),
    %
    fnames = fieldnames(s);
    %
    for ifield = 1:length(fnames),
        %
        iluke_update_state(s.(fnames{ifield}))
        %
    end
end
%
