%script make_equil_ITER_Scen4
%
% This script creates the equil strucure for CMOD to be used by DKE
%   based on the eqdsk file and some profile data
%
clear all
close all
%
% ITER signs (clockwise from top)
%
basestr ='ITER';
%
signs.Ip = 1;
signs.Bt = 1;
%
% path
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath] = load_structures_yp('dkepath',id_dkepath,path_dkepath);
%
% file name
%
id_equil = 'Scen4';
source_path = 'Source_files/';
%
eqdsk_file = [id_equil,'.efit'];
eqdsk_path = source_path;
%
profname = [eqdsk_path,id_equil,'.prof'];
type = 0.2;
Zeff = NaN;
%
display_mode = 0;
p_opt = -1;
dispname = 'ITER Scenario 4';
savename = 'ITER_Scen4';
%
% RZ2PT options
%
opt.sfac = 10;% factor for (x,y) supergrid
opt.axenforce = true;% option to enforce center position and psi value in supergrid
%
% --------------------------------------------------------------
%
[equil_magnetic,mrho,mspsin,mspsinT,mp_magnetic] = equil_magnetic_EFIT_jd([eqdsk_path,eqdsk_file],display_mode,p_opt,dispname,savename,opt);
equil_prof = equil_prof_jd(profname,type,mrho,mspsin,mspsinT,display_mode,p_opt,dispname,savename,Zeff);
%
% signs
%
if signs.Ip*equil_magnetic.psi_apRp(end) < 0,
    equil_magnetic.psi_apRp = -equil_magnetic.psi_apRp;
    equil_magnetic.ptBx = -equil_magnetic.ptBx;
    equil_magnetic.ptBy = -equil_magnetic.ptBy;
end
%
if signs.Bt*equil_magnetic.ptBPHI(1,1) < 0,
    equil_magnetic.ptBPHI = -equil_magnetic.ptBPHI;
end
%
equil = conc_struct_jd(equil_magnetic,equil_prof);
%
equil.signs = signs;
equil.id = [basestr,'_',id_equil];
%
savestr = ['EQUIL_',equil.id];
save(savestr,'equil');
disp(['equilibrium saved in file ',savestr,'.'])