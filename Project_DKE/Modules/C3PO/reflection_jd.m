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
function [P_ref,N_ref,E_ref] = reflection_jd(equil,P_end,N_end,E_end)
%
% This function calculates the reflection on vessel
%
if isfield(equil,'tokamak') && isfield(equil,'shotnum') && isfield(equil,'shotime'),
    tokamak = equil.tokamak;
    shotnum = equil.shotnum;
    shotime = equil.shotime;
else
    istru = find(equil.id == '_');
    if length(istru) >= 2,
        tokamak = equil.id(1:istru(1)-1);
        shotnum = equil.id(istru(1)+1:istru(2)-1);
        shotime = equil.id(istru(2)+1:end);
    else           
        error('-----> Shot number information missing');
    end
end
%
if ~ischar(shotime),
    shotime = num2str(shotime);
end
%
if strcmp(tokamak,'TCV'),
    %
    addpath('/home/gnesin')
    %
    %save('rayend.mat','shotnum','shotime','P_end','K_end','E_end');
    %
    [P_ref,N_ref,E_ref] = reflect_tcv(shotnum,shotime,P_end,N_end,E_end);
    %
end
    