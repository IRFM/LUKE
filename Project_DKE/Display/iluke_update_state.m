function iluke_update_state(s)
%
% This function recursively update the state of objects
%
if isfield(s,'handle'),
    if isfield(s,'state')
        set(s.handle,'Enable',s.state);
    end
    if isfield(s,'value') && isfield(s,'string')
        set(s.handle,'String',s.string,'Value',s.value);
    elseif isfield(s,'string')
        set(s.handle,'String',s.string);
    elseif isfield(s,'value')
        set(s.handle,'Value',s.value);
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
