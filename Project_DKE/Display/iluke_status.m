function [s,sobj,cleartags] = iluke_status(s,status,sobj,mode,cleartags)
%
% mode = 0 : input structures
% mode = 1 : output structures
%
if iscell(s),% clear outdated structures
    s(status <= 0) = {[]};
    ns = sum(status > 0);
    if ns == 0,
        sobj.text.string = '< empty >';
    else
        sobj.text.string = [num2str(ns),' structures'];
    end;
end
%
if max(status) <= 0,% s does not exist
    %
    if max(status) < 0 % s cannot exist
        if mode == 0,
            sobj.make.state = 'off';
            sobj.load.state = 'off';
        else
            sobj.run.state = 'off';
        end
    else % s can be built
        if mode == 0,
            sobj.make.state = 'on';
            sobj.load.state = 'on';
        else
            sobj.run.state = 'on';
        end
    end
    %
    if ~iscell(s),
        if isempty(s), % s did not exist
            sobj.text.string = '< empty >';
        else % s must be cleared
            sobj.text.string = '< outdated >';
            s = [];
        end
    else
        
    end
    % s does not exist
    if mode == 0,
        sobj.save.state = 'off';
    end
    sobj.clear.state = 'off';
    sobj.disp.state = 'off';
    %
    sname = inputname(1);
    %
    if ~any(strcmp(cleartags,sname)),
        cleartags = [cleartags,sname];
    end
    %        
else % s exists
    %
    if mode == 0,
        sobj.make.state = 'on';
        sobj.load.state = 'on';
        sobj.save.state = 'on';
    else
        sobj.run.state = 'on';
    end
    %
    sobj.clear.state = 'on';
    sobj.disp.state = 'on';    
    %
    if ~iscell(s), 
        if ~isfield(sobj,'filename') || isempty(sobj.filename), % s is not saved
            sobj.text.string = '< not saved >';
        else
            sobj.text.string = sobj.filename;
        end            
    end
    %
end
%
if max(status) == 0,% s does not exist
    if mode == 0,
        sobj.make.highlight = true;
    else
        sobj.run.highlight = true;
    end
else
    if mode == 0,
        sobj.make.highlight = false;
    else
        sobj.run.highlight = false;
    end
end    

