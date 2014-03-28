% script iluke_manage

if ~strcmp(lukeobj.tokamak.string,'TS'),
    %
    status.ripple = -ones(1,ntimes);
    %
end

if ~strcmp(lukeobj.tokamak.string,'TCV'),
    %
    lukeobj.angles.load.state = 'off';
    %
end

lukeobj.data.disp.state = 'off';

lukeobj.sdiag.ECE.state = 'off';
lukeobj.sdiag.ECE.highlight = false;

