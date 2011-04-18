function [P_ref,N_ref,E_ref] = reflection_jd(equil,P_end,N_end,E_end)
%
% This function calculates the reflection on vessel
%
if isfield(equil,'shotnum') && isfield(equil,'shotime'),
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
if strcmp(tokamak,'TCV'),
    %
    addpath('/home/gnesin')
    %
    %save('rayend.mat','shotnum','shotime','P_end','K_end','E_end');
    [P_ref,N_ref,E_ref] = reflect_tcv(shotnum,shotime,P_end,N_end,E_end);
    %
end
    