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
%
% Create the local file TRANSP_INIT.mat
% 
% by J. Decker EPFL-CRPP <joan.decker@epfl.ch> and Y.Peysson CEA-IRFM <yves.peysson@cea.fr>
%
clear all
%
id_transpfaste = 'INIT';
%
Dr0 = 0;% Core radial diffusion coefficient (m^2/s)
pDr = 0;% Coefficient for the Dr radial profile
Vr0 = 0;% Core radial pinch coefficient (m/s)
pVr = 0;% Coefficient for the Vr radial profile
%
Dr_model = 0;% Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
Vr_model = 0;% Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
vparmin = 3.0;% Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
%
norm_ref = 1;% Normalization procedure for the lower limit of the parallel velocity dependence of the radial diffusion and pinch: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
%
%*****************************************************************************************************************
%
transpfaste.id = id_transpfaste;
%
transpfaste.Dr0 = Dr0;
transpfaste.pDr = pDr;
transpfaste.Vr0 = Vr0;
transpfaste.pVr = pVr;
%
transpfaste.Dr_model = Dr_model;
transpfaste.Vr_model = Vr_model; 
transpfaste.vparmin = vparmin;%Normalized units
transpfaste.norm_ref = norm_ref;
%
eval(['save TRANSP_',id_transpfaste,'.mat transpfaste']);
