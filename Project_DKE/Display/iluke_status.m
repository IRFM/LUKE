function [s,sobj,cleartags] = iluke_status(s,status,sobj,mode,curtime,cleartags)
%
% mode = 0 : input structures
% mode = 1 : output structures
%
% clear outdated structures
%
sname = inputname(1);
%
if mode > 1,%sdiag
    fnames = fieldnames(sobj);
    fnames(strcmp(fnames,'title')) = [];
    fnames(strcmp(fnames,'text')) = [];
end    
%
if iscell(s),
    mask = status <= 0;
    if any(mask),
        if iscell(s(mask(1))),
            s(mask) = {{}};%waves & wavestructs
        else
            s(mask) = {[]};
        end
    end
    %
    % setup string
    %
    if mode <= 1,
        if curtime > 0,
            if status(curtime) <= 0,
                sobj.text.string = '< empty >';
                if ~any(strcmp(cleartags{2+curtime},'all')) && ~any(strcmp(cleartags{2+curtime},sname)),
                    cleartags{2+curtime} = [cleartags{2+curtime},sname];
                end
            elseif ~isfield(s{curtime},'filename') || isempty(s{curtime}.filename), % s is not saved
                sobj.text.string = '< not saved >';
            else
                sobj.text.string = s{curtime}.filename;
            end            
        elseif curtime == 0,
            ns = sum(status > 0);
            if ns == 0,
                sobj.text.string = '< empty >';
            else
                sobj.text.string = [num2str(ns),' structures'];
            end
        else
            sobj.text.string = '< empty >';
        end
    end
    %        
elseif status <= 0,
    s = [];
    if mode <= 1,
        sobj.text.string = '< empty >';
    end
elseif mode <= 1 && ~isfield(s,'filename') || isempty(s.filename), % s is not saved
    sobj.text.string = '< not saved >';
elseif mode <= 1
    sobj.text.string = s.filename;
end
%
% setup action state
%
if isempty(status),
    status = -1;% s cannot exist
elseif curtime > 0,
    status = status(curtime);% status for a given time
else
    status = max(status);% status for multiple times
end
%
if status < 0,% s cannot exist except for mode == -1 (new equil)
    if mode == -1,% equil can always be built
        sobj.make.state = 'on';
        sobj.load.state = 'on';
    elseif mode == 0,
        sobj.make.state = 'off';
        sobj.load.state = 'off';
    elseif mode == 1,
        sobj.run.state = 'off';
    else
        for ifield = 1:length(fnames),
            sobj.(fnames{ifield}).state = 'off';
        end
    end
else% s can be built
    if mode <= 0,
        sobj.make.state = 'on';
        sobj.load.state = 'on';
    elseif mode == 1,
        sobj.run.state = 'on';
    else
        for ifield = 1:length(fnames),
            sobj.(fnames{ifield}).state = 'on';
        end
    end
end
%
if mode <= 1,
    if status <= 0,% s does not exist
        if mode <= 0,
            sobj.save.state = 'off';
        end
        sobj.clear.state = 'off';
        sobj.disp.state = 'off';
    else% s exists
        if mode <= 0,
            sobj.save.state = 'on';
        end
        sobj.clear.state = 'on';
        sobj.disp.state = 'on';    
    end
    %
    if status == 0,% s does not exist
        if mode <= 0,
            sobj.make.highlight = true;
        else
            sobj.run.highlight = true;
        end
    else
        if mode <= 0,
            sobj.make.highlight = false;
        else
            sobj.run.highlight = false;
        end
    end  
else
    for ifield = 1:length(fnames),
        if status == 0,% s does not exist
            sobj.(fnames{ifield}).highlight = true;
        else
            sobj.(fnames{ifield}).highlight = false;
        end      
    end
end
%  

