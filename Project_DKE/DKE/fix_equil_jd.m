function equil = fix_equil_jd(equil,opt_gui)
%
if isfield(equil,'info') && all(isfield(equil.info,{'shotnum','shottime'})),
    equil.shotnum = equil.info.shotnum;
    equil.shotime = equil.info.shotime;
    equil = rmfield(equil,'info');
    return
end
%    
istru = find(equil.id == '_');
if length(istru) >= 2,
    equil.shotnum = equil.id(istru(1)+1:istru(2)-1);
    if length(istru) >= 3,
        equil.shotime = equil.id(istru(2)+1:istru(3)-1);
    else
        equil.shotime = equil.id(istru(2)+1:end);
    end
else    
    equil.shotnum = '';
    equil.shotime = '';
end
%
if opt_gui,
    equil.shotnum = input_dke_yp('Please provide the shot number',equil.shotnum);
    equil.shotime = input_dke_yp('Please provide the shot time',equil.shotime);
end
%
