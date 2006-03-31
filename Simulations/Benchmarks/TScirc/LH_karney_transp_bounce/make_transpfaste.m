%********************************************************************************************************************************
%************************************** FAST ELECTRON TRANSPORT COEFFICIENTS PROFILE ********************************************
%********************************************************************************************************************************
% Create the local file TRANSPFASTE_id_equil.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
%
id_transpfaste = 'MagneticTurbulence';
%
Dr0 = 1;%Core radial diffusion coefficient (m^2/s)
pDr = 0;%Coefficient for the Dr radial profile
Vr0 = 0;%Core radial pinch coefficient (m/s)
pVr = 0;%Coefficient for the Vr radial profile
%
Dr_model = 0;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
vparmin = 3.5;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
%
%*****************************************************************************************************************
%
transpfaste.Dr0 = Dr0;
transpfaste.pDr = pDr;
transpfaste.Vr0 = Vr0;
transpfaste.pVr = pVr;
%
transpfaste.Dr_model = Dr_model;
transpfaste.Vr_model = Vr_model; 
transpfaste.vparmin = vparmin;%Normalized units
%
eval(['save TRANSPFASTE_',id_transpfaste,'.mat transpfaste']);
