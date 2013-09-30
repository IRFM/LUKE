function lukeobj = iluke_equilstrings(lukeobj,equil)
%
if isfield(equil,'tokamak') && isfield(equil,'shotnum') && isfield(equil,'shotime'),
    lukeobj.tokamak.string = equil.tokamak;
    lukeobj.shotnum.string = equil.shotnum;
    lukeobj.shotime.string = equil.shotime;
else
    isep = find(equil.id == '_');
    if length(isep) >= 2,
        lukeobj.tokamak.string = equil.id(1:isep(1) - 1);
        lukeobj.shotnum.string = equil.id(isep(1) + 1:isep(2) - 1);
        if length(isep) > 2,
            lukeobj.shotime.string = equil.id(isep(2) + 1:isep(3) - 1);
        else
            lukeobj.shotime.string = equil.id(isep(2) + 1:end);
        end
    else
        lukeobj.tokamak.string = '< ? >';
        lukeobj.shotnum.string = '< ? >';
        lukeobj.shotime.string = '< ? >';
    end
end
