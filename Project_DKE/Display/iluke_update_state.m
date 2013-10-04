function iluke_update_state(s,visible)
%
% This function recursively update the state of objects
%
if isfield(s,'handle'),
    if isfield(s,'highlight'),
        if s.highlight,
            set(s.handle,'BackgroundColor',[0 0.75 0]);
        else
            set(s.handle,'BackgroundColor',[0.701961 0.701961 0.701961]);
        end
    end
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
    if isfield(s,'visible')
        set(s.handle,'Visible',s.visible);
    elseif nargin > 1
        set(s.handle,'Visible',visible);
    end
elseif isstruct(s),
    %
    fnames = fieldnames(s);
    %
    for ifield = 1:length(fnames),
        %
        if isfield(s,'state') && isfield(s.(fnames{ifield}),'handle'),
            s.(fnames{ifield}).state = s.state;
        end
        %    
        if isfield(s,'visible'),
            iluke_update_state(s.(fnames{ifield}),s.visible)
        elseif nargin > 1
            iluke_update_state(s.(fnames{ifield}),visible)
        else
            iluke_update_state(s.(fnames{ifield}))
        end
        %
    end
end
%
