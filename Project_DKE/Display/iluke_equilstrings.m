function [lukeobj,equil] = iluke_equilstrings(lukeobj,equil)
%
if isfield(equil,'tokamak') && isfield(equil,'shotnum') && isfield(equil,'shotime'),
    lukeobj.tokamak.string = equil.tokamak;
    lukeobj.shotnum.string = equil.shotnum;
    lukeobj.shotime.string = equil.shotime;
else
    isep = find(equil.id == '_');
    if length(isep) >= 2,
        equil.tokamak = equil.id(1:isep(1) - 1);
        equil.shotnum = equil.id(isep(1) + 1:isep(2) - 1);
        if length(isep) > 2,
            equil.shotime = equil.id(isep(2) + 1:isep(3) - 1);
        else
            equil.shotime = equil.id(isep(2) + 1:end);
        end
        %
        lukeobj.tokamak.string = equil.tokamak;
        lukeobj.shotnum.string = equil.shotnum;
        lukeobj.shotime.string = equil.shotime;
    else
        equil.tokamak = '';
        equil.shotnum = '';
        equil.shotime = '';
        %
        lukeobj.tokamak.string = '< ? >';
        lukeobj.shotnum.string = '< ? >';
        lukeobj.shotime.string = '< ? >';
    end
end
