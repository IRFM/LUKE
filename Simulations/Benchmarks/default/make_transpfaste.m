%************************************** FAST ELECTRON TRANSPORT COEFFICIENTS PROFILE ********************************************
%******************************************************************************************************************
% Create the local file TRANSPFASTE_transpfaste_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
transpfaste_id = 'DEFAULT';%Set here the name (identifier) of the fast electron transport coefficients profile
%
% Fast electron radial transport
%
vparmin_r = 3.5;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
Dr0 = 0;%Core  radial diffusion coefficient (m^2/s)
pDr = 0;%Coefficient for the Dr radial profile
Vr0 = 0;%Core radial pinch coefficient (m/s)
pVr = 0;%Coefficient for the Vr radial profile
%
transpfaste.Dr_model = 1;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
transpfaste.Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
%
transpfaste.rho = linspace(0,1,20);%Arbitrary normalized minor radius
transpfaste.vparmin_r = vparmin_r*ones(size(transpfaste.rho));
transpfaste.Dr = Dr0*(1 + pDr*transpfaste.rho.^2);
transpfaste.Vr = Vr0*(1 + pDr*transpfaste.rho.^2);
%
% Any type of profile may be enter in the structure. WARNING: profile is always function of a normalized minor radius
%
eval(['save TRANSPFASTE_',transpfaste_id,'.mat transpfaste']);
