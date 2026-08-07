% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
