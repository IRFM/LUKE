% script iluke_manage

if ~strcmp(lukeobj.tokamak.string,'TS'),
    %
    status.ripple = -1;
    %
    [ripple,lukeobj.ripple,cleartags] = iluke_status(ripple,status.ripple,lukeobj.ripple,0,cleartags);
    %
end

lukeobj.data.disp.state = 'off';

