%******************************************************************************************************************
%************************************************ OHMIC EFIELD PROFILE ********************************************
%******************************************************************************************************************
% Create the local file OHM_id_equil.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
%
id_ohm = 'OHM_p001_flat';
%
id_equil = 'TScyl';%For loading the plasma equilibrium
path_equil = '../EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Normlized Ohmic electric field profile calculation
% (WARNING: norm_ref = 0 by default when multiple radial positions are studied simultaneously, whatever the value in this file 
% -> normalization with pth_ref*nhuth_ref/e)
% 
epsi0 = 0.01;%Flux surface averaged core Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e) 
epsia = 0.01;%Flux surface averaged edge Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e)
eepsi = 0;%Exponent for Ohmic electric field (WARNING: psi coordinate and not rho)
%
norm_ref = 1;%Normalization procedure for the ohmic electric field: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
%
%*****************************************************************************************************************
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
[ohm] = ohm_profile_yp(equil,epsi0,epsia,eepsi,norm_ref);
%
eval(['save OHM_',id_equil,'_',id_ohm,'.mat ohm']);


