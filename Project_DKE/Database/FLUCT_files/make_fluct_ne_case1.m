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
% Parameters for testing the effect of density or magnetic field fluctuations on ray trajectories
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
clear all
close all
clc
%
id_fluct = 'ne_case1';%Plasma fluctuations identifier
%
% Core density fluctuations
%
fluctparam.id = id_fluct;
%
fluctparam.fluct.type = {'ne'};%Type of fluctuations or modulations ('ne': electron density, 'B': magnetic field) {1,nfluct_types}
fluctparam.fluct.model = [5];%Statistical ne fluctuation model (>= 1) : [1,nfluct_types]
                        %    - (1) -> 3-D Gaussian model (rho,theta,phi), relative epsi values (benchmark of C3PO)
                        %    - (2) -> 3-D Gaussian model (rho,theta,phi), absolute epsi values (m)
                        %    - (3) -> 2-D Gaussian drift-wave like model global (rho,curtheta), absolute epsi values (m)
                        %    - (4) -> 1-D Gaussian drift-wave like model local (curtheta), absolute epsi values (m)
                        %    - (5) -> 1-D Gaussian drift-wave like model local (cn,cm), absolute epsi values (m)
                        %    - (6) -> 2-D Gaussian drift-wave like model local (rho,cn,cm), absolute epsi values (m)
                        %    - (7) -> *** NOT IMPLEMENTED *** 2-D Gaussian drift-wave like model local (rho,lperp), absolute epsi values (m)
fluctparam.fluct.sigmar_max = [1];%Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
fluctparam.fluct.sigmar_hwhm = [0.01];%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
fluctparam.fluct.sigmar_rho = [1];%Radial location where the relative fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
fluctparam.fluct.polmode = [0.1];%HFS/LFS relative fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
%
fluctparam.fluct.epsi_rho = [1];%
fluctparam.fluct.epsi_theta = [0.01];%theta direction is perp direction for models 3 & 4
fluctparam.fluct.epsi_phi = [0.01];%useless for models 3 & 4
%
fluctparam.fluct.lmin = [1];%
fluctparam.fluct.mmin = [1];%for perp direction for models 3 & 4
fluctparam.fluct.nmin = [1];%useless for models 3 & 4
%
fluctparam.fluct.lmax = [2];%
fluctparam.fluct.mmax = [1000];%for perp direction for models 3 & 4
fluctparam.fluct.nmax = [200];%useless for models 3 & 4
%
% =========================================================================
%
% Data saving
%
save_str = ['FLUCT_',id_fluct,'.mat'];
eval(['save ',save_str,' fluctparam']);
%
info_dke_yp(2,'Plasma fluctuations parameters saved');
