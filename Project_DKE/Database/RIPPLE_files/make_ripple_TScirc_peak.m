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
%**************************************************************************************************************
%************************************** MAGNETIC RIPPLE PARAMETERS ********************************************
%**************************************************************************************************************
% Create the local file RIPPLE_id_equil.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
%
id_equil = 'TScirc_peak';
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
ripple.N = 18;%Number of toroidal magnetic field coils
%
% For the Yushmanov model in Reviews of Plasma Physics, p.117-241, "Diffusive Transport Processes Caused by Ripple in Tokamaks" by P.N. Yushmanov, 1990.
%
ripple.B0 = 3.2;%Vacuum toroidal magnetic field on the toroidal axis, (signed value as BPHI) (T)
ripple.R0 = 2.4;%Toroidal major radius of the toroidal magnetic field windings(m)
ripple.rn = 1.0;%Inner radius of the toroidal magnetic field windings (m)
ripple.rx = 1.48;%Outer radius of the toroidal magnetic field windings (m)
%
%*************************************************************************************************************
%
eval(['save RIPPLE_',id_equil,'_',id_ripple,'.mat ripple']);
