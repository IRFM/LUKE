% script iluke_manage

if ~strcmp(lukeobj.tokamak.string,'TS'),
    %
    status.ripple = -1;
    %
    [ripple,lukeobj.ripple,cleartags] = iluke_status(ripple,status.ripple,lukeobj.ripple,0,cleartags);
    %
end

if ~strcmp(lukeobj.tokamak.string,'TCV'),
    %
    lukeobj.angles.load.state = 'off';
    %
end

lukeobj.data.disp.state = 'off';

lukeobj.r5x2.run.state = 'off';

