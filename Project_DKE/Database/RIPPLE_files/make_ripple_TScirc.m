%**************************************************************************************************************
%************************************** MAGNETIC RIPPLE PARAMETERS ********************************************
%**************************************************************************************************************
% Create the local file RIPPLE_id_equil.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
%
id_equil = 'TScirc';
id_ripple = 'TSspecific';
%
ripple.id = id_ripple;
ripple.equil_id = id_equil;
%
%For the magnetic  ripple losses, the loss frequency must be very large compared to the reference frequency. Therefore it is always enforced in the code to 1000*nhu_ref
%Consequently, the ripple parameter is just a flag which indicates if magnetic ripple calculations are considered or not. Calculations are only valid for Tore Supra tokamak
%so the first two letters must be TS to be recognized in the calculations. See main_dke_yp.m
%
ripple.mode = 1;%No magnetic ripple if empty
%
%
%*************************************************************************************************************