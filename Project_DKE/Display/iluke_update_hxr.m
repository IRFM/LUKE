%
% external_hxr
%
if isfield(external,'hxr'),% include data from external structure if available
    %
    external_hxr = external.hxr;
    %
else
    %
    external_hxr = [];% no external structure
    %
end 
%
if ~isempty(external_hxr),
    lukeobj.hxrcam.import.state = 'on';
    lukeobj.hxrexp.import.state = 'on';
else
    lukeobj.hxrcam.import.state = 'off';
    lukeobj.hxrexp.import.state = 'off';
end
if isempty(hxr.cam),
    %
    lukeobj.hxrcam.select.visible = 'off';
    %
    if ~isempty(external_hxr),
        lukeobj.hxrcam.import.highlight = true;
        lukeobj.hxrcam.load.highlight = false;
    else
        lukeobj.hxrcam.load.highlight = true;
        lukeobj.hxrcam.import.highlight = false;
    end
    %
else
    %
    lukeobj.hxrcam.select.visible = 'on';
    %
    lukeobj.hxrcam.import.highlight = false;
    lukeobj.hxrcam.load.highlight = false;
    %
end
if isempty(hxr.exp),
    %
    if ~isempty(external_hxr),
        lukeobj.hxrexp.import.highlight = true;
        lukeobj.hxrexp.load.highlight = false;
    else
        lukeobj.hxrexp.load.highlight = true;
        lukeobj.hxrexp.import.highlight = false;
    end
    %
else
    %
    lukeobj.hxrexp.import.highlight = false;
    lukeobj.hxrexp.load.highlight = false;
    %
end
