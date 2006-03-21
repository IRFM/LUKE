%**************************************************************************************************************
%************************************** MAGNETIC RIPPLE PARAMETERS ********************************************
%**************************************************************************************************************
% Create the local file RIPPLE_id_equil.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
%
id_equil = 'TScirc';%For loading the plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%For the magnetic  ripple losses, the loss frequency must be very large compared to the reference frequency. Therefore it is always enforced in the code to 1000*nhu_ref
%Consequently, the ripple parameter is just a flag which indicates if magnetic ripple calculations are considered or not. Calculations are only valid for Tore Supra tokamak
%so the first two letters must be TS to be recognized in the calculations. See main_dke_yp.m
ripple = '';%No magnetic ripple if empty
%
%*****************************************************************************************************************
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' succesfully loaded');
end
%
eval(['save RIPPLE_',id_equil,'.mat ripple']);