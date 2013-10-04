function [s,sobj,cleartags] = iluke_status(s,status,sobj,mode,cleartags)
%
% mode = 0 : input structures
% mode = 1 : output structures
%
if status <= 0,% s does not exist
    %
    if status < 0 % s cannot exist
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
    if isempty(s) % s did not exist
        sobj.text.string = '< empty >';
    else % s must be cleared
        sobj.text.string = '< outdated >';
        s = '';
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
        if status > 1 % ohm is not saved
            sobj.text.string = '< not saved >';
        end
        %
        sobj.make.state = 'on';
        sobj.load.state = 'on';
        sobj.save.state = 'on';
    else
        sobj.run.state = 'on';
    end
    %
    sobj.clear.state = 'on';
    sobj.disp.state = 'on';    
end
%
if status == 0,% s does not exist
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

