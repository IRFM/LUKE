%
% Parameters for testing the effect of fluctuations on ray trajectories
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
clear all
close all
clc
%
id_fluct = 'naequilp_ne5';%Fluctuations identifier
%
% Path parameters
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Equilibrium parameters
%
load ('../before_luke@TS_32299_100.0117.mat','equil');%data file from cronos
%
% Non axisymmetric perturbation of the toroidal MHD equilibrium for any rf waves
%
fluctuations.naequilp.fluct.type = {'ne'};%Type of fluctuations or modulations ('ne': electron density, 'B': magnetic field) {1,nfluct_types}
fluctuations.naequilp.fluct.model = [5];%Statistical ne fluctuation model (>= 1) : [1,nfluct_types]
                        %    - (1) -> 3-D Gaussian model (rho,theta,phi), relative epsi values (benchmark of C3PO)
                        %    - (2) -> 3-D Gaussian model (rho,theta,phi), absolute epsi values (m)
                        %    - (3) -> 2-D Gaussian drift-wave like model global (rho,curtheta), absolute epsi values (m)
                        %    - (4) -> 1-D Gaussian drift-wave like model local (curtheta), absolute epsi values (m)
                        %    - (5) -> 1-D Gaussian drift-wave like model local (cn,cm), absolute epsi values (m)
                        %    - (6) -> 2-D Gaussian drift-wave like model local (rho,cn,cm), absolute epsi values (m)
                        %    - (7) -> *** NOT IMPLEMENTED *** 2-D Gaussian drift-wave like model local (rho,lperp), absolute epsi values (m)
fluctuations.naequilp.fluct.sigmar_max = [NaN];%Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
fluctuations.naequilp.fluct.sigmar_hwhm = [NaN];%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
fluctuations.naequilp.fluct.sigmar_rho = [1];%Radial location where the relative fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
fluctuations.naequilp.fluct.polmode = [0.1];%HFS/LFS relative fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
%
fluctuations.naequilp.fluct.epsi_rho = [1];%
fluctuations.naequilp.fluct.epsi_theta = [0.01];%theta direction is perp direction for models 3 & 4
fluctuations.naequilp.fluct.epsi_phi = [0.01];%useless for models 3 & 4
%
fluctuations.naequilp.fluct.lmin = [1];%
fluctuations.naequilp.fluct.mmin = [1];%for perp direction for models 3 & 4
fluctuations.naequilp.fluct.nmin = [1];%useless for models 3 & 4
%
fluctuations.naequilp.fluct.lmax = [2];%
fluctuations.naequilp.fluct.mmax = [1000];%for perp direction for models 3 & 4
fluctuations.naequilp.fluct.nmax = [200];%useless for models 3 & 4
%
% Perturbation of the launched npar for the LH wave only (simulate possible diffraction of the LH wave in the SOL by edge density fluctuations)
%
fluctuations.npar0_lh.fluct.dtn = Inf;%1;%Gaussian time correlation model, edge_dtn = 2.14*t_correlation (if edge_dtn is Inf, no fluctuations)
fluctuations.npar0_lh.fluct.hwhm_npar = 0.1;%Gaussian distribution (if hwhm is NaN or empty, no fluctuations)
%
% -------------------------------------------------------------------------
%
[fluct] = fluctstruct_yp(equil,id_fluct,fluctuations);
%
% Data saving
%
save_str = ['FLUCT_',equil.id,'_',id_fluct,'.mat'];
eval(['save ',save_str,' fluct']);
%
info_dke_yp(2,'Fluctuations structure saved');
