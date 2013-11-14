function [] = make_fluct_JETliketest_norippple
%
% Parameters for testing the effect of fluctuations on ray trajectories
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
close all
%
id_fluct = 'noripple';%Plasma fluctuations identifier
%
% Path parameters
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Equilibrium parameters
%
id_equil = 'JETliketest';%For plasma equilibrium
path_equil = '../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Non axisymmetric perturbation of the toroidal MHD equilibrium for any rf waves
%
fluctuations.naequilp.fluct.type = {'ne'};%Type of fluctuations or modulations ('ne': electron density, 'B': magnetic field) {1,nfluct_types}
fluctuations.naequilp.fluct.model = [1];%Statistical ne fluctuation model (>= 1) : [1,nfluct_types]
                        %    - (1) -> 3-D Gaussian model (rho,theta,phi), relative epsi values (benchmark of C3PO)
                        %    - (2) -> 3-D Gaussian model (rho,theta,phi), absolute epsi values (m)
                        %    - (3) -> 2-D Gaussian drift-wave like model global (rho,curtheta), absolute epsi values (m)
                        %    - (4) -> 1-D Gaussian drift-wave like model local (curtheta), absolute epsi values (m)
                        %    - (5) -> 1-D Gaussian drift-wave like model local (cn,cm), absolute epsi values (m)
                        %    - (6) -> 2-D Gaussian drift-wave like model local (rho,cn,cm), absolute epsi values (m)
                        %    - (7) -> *** NOT IMPLEMENTED *** 2-D Gaussian drift-wave like model local (rho,lperp), absolute epsi values (m)
fluctuations.naequilp.fluct.sigmar_max = [0.7];%Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
fluctuations.naequilp.fluct.sigmar_hwhm = [0.1];%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
fluctuations.naequilp.fluct.sigmar_rho = [1];%Radial location where the relative fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
fluctuations.naequilp.fluct.polmode = [0.0];%HFS/LFS relative fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
%
fluctuations.naequilp.fluct.epsi_rho = [0.01];%
fluctuations.naequilp.fluct.epsi_theta = [0.01];%theta direction is perp direction for models 3 & 4
fluctuations.naequilp.fluct.epsi_phi = [0.2];%useless for models 3 & 4
%
fluctuations.naequilp.fluct.lmin = [1];%
fluctuations.naequilp.fluct.mmin = [1];%for perp direction for models 3 & 4
fluctuations.naequilp.fluct.nmin = [1];%useless for models 3 & 4
%
fluctuations.naequilp.fluct.lmax = [50];%
fluctuations.naequilp.fluct.mmax = [50];%for perp direction for models 3 & 4
fluctuations.naequilp.fluct.nmax = [5];%useless for models 3 & 4%
%
% Perturbation of the launched npar for the LH wave only (simulate possible diffraction of the LH wave in the SOL by edge density fluctuations)
%
fluctuations.npar0_lh.fluct.dtn = Inf;%Gaussian time correlation model, edge_dtn = 2.14*t_correlation (if edge_dtn is Inf, no fluctuations)
fluctuations.npar0_lh.fluct.hwhm_npar = 0.1;%Gaussian distribution (if hwhm is NaN or empty, no fluctuations)
%
% -------------------------------------------------------------------------
%
% Load structures
%
if exist('id_ripple'),
    if ~isempty(id_ripple),
        [equil,ripple] = load_structures_yp('equil',id_equil,path_equil,'ripple',id_ripple,'');
        fluctuations.naequilp.ripple = ripple;
    else
        [equil] = load_structures_yp('equil',id_equil,path_equil);
    end
else
    [equil] = load_structures_yp('equil',id_equil,path_equil);  
end
%
[fluct] = fluctstruct_yp(equil,id_fluct,fluctuations);
%
% Data saving
%
if isempty(id_fluct),
    save_str = ['FLUCT_',id_equil,'.mat'];
else
    save_str = ['FLUCT_',id_equil,'_',id_fluct,'.mat'];
end
eval(['save ',save_str,' fluct']);
%
info_dke_yp(2,'Fluctuations structure saved');
%
% load('../EQUIL/EQUILV_JETliketest.mat');
%
% [fluct] = fluctphase_yp(fluct,0);%Mersenne-Twitter pseudorandom generator -> 0, Matlab rand (reset by clock) -> 1
% [fluct_fit] = fitfluct_yp(fluct);
% testfitfluct_yp(equil_fit,fluct,fluct_fit,0.8);


