%
% Parameters for testing the effect fluctuations on ray trajectories
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
close all
clear fluct
%
id_fluct = 'noripple_ne1ne3B1';%Plasma fluctuations identifier
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
fluctuations.naequilp.fluct.type = {'ne','ne','B'};%Type of fluctuations or modulations ('ne': electron density, 'B': magnetic field) {1,nfluct_types}
fluctuations.naequilp.fluct.model = [1,3,1];%Statistical ne fluctuation model (>= 1) : [1,nfluct_types]
                        %    - (1) -> 3-D Gaussian model (rho,theta,phi), relative epsi values (benchmark of C3PO)
                        %    - (2) -> 3-D Gaussian model (rho,theta,phi), absolute epsi values (m)
                        %    - (3) -> 2-D Gaussian drift-wave like model global (rho,curtheta), absolute epsi values (m)
                        %    - (4) -> 2-D Gaussian drift-wave like model local (rho,curtheta), absolute epsi values (m)
                        %    - (5) -> 1-D Gaussian drift-wave like model local (cn,cm), absolute epsi values (m)
                        %    - (6) -> 2-D Gaussian drift-wave like model local (rho,cn,cm), absolute epsi values (m)
                        %    - (7) -> *** NOT IMPLEMENTED *** 2-D Gaussian drift-wave like model local (rho,lperp), absolute epsi values (m)
fluctuations.naequilp.fluct.sigmar_max = [0.3,0.1,1e-5];%Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
fluctuations.naequilp.fluct.sigmar_hwhm = [0.2,0.3,0.2];%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
fluctuations.naequilp.fluct.sigmar_rho = [1,1,0];%Radial location where the relative fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
fluctuations.naequilp.fluct.polmode = [0.2,1,0.3];%HFS/LFS relative fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
%
fluctuations.naequilp.fluct.epsi_rho = [0.02,0.03,0.04];%
fluctuations.naequilp.fluct.epsi_theta = [0.02,0.03,0.04];%theta direction is perp direction for models 3 & 4
fluctuations.naequilp.fluct.epsi_phi = [0.02,0.03,0.04];%useless for models 3 & 4
%
fluctuations.naequilp.fluct.lmin = [1,1,1];%
fluctuations.naequilp.fluct.mmin = [1,1,1];%for perp direction for models 3 & 4
fluctuations.naequilp.fluct.nmin = [1,1,1];%useless for models 3 & 4
%
fluctuations.naequilp.fluct.lmax = [10,20,30];%
fluctuations.naequilp.fluct.mmax = [30,40,50];%for perp direction for models 3 & 4
fluctuations.naequilp.fluct.nmax = [20,25,30];%useless for models 3 & 4
%
% Magnetic field fluctuations 
%
%struct_B.type = 'B';%Type of fluctuations or modulations [1,1]
%struct_B.model = [1,1];%Statistical Bperp fluctuation model (>= 1) : [1,nfluct_types]
                        %    - (1) -> 3-D Gaussian model (rho,theta,phi), relative epsi values (benchmark of C3PO)
                        %    - (2) -> 3-D Gaussian model (rho,theta,phi), absolute epsi values (m)
                        %    - (3) -> 2-D Gaussian drift-wave like model global (rho,theta), absolute epsi values (m)
                        %    - (4) -> 2-D Gaussian drift-wave like model local (rho,theta), absolute epsi values (m)
%struct_B.sigmar_max = [5e-3,1e-4];%Maximum value of the relative Bperp fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
%struct_B.sigmar_hwhm = [0.3,0.2];%Radial half width at half maximum of the relative Bperp fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
%struct_B.sigmar_rho = [0,1];%Radial location where the relative Bperp fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
%struct_B.polmode = [1,0.3];%HFS/LFS relative Bperp fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
%
%struct_B.epsi_prho = [0.2,1];%
%struct_B.epsi_theta = [0.2,1];%
%struct_B.epsi_phi = [0.2,1];%
%
%struct_B.n_rho = [10,20];%
%struct_B.n_theta = [30,40];%
%struct_B.n_phi = [20,25];%
%
%struct_B.kperpc = [300,200];%Inverse of the correlation length of Bperp fluctuations perpendicular to the magnetic field (ap^(-1) unit) [1,nfluct_types]
%struct_B.kperpref = [0,0];%Bperp fluctuations reference perpendicular wave vector with respect to the local magnetic field direction (ap^(-1) unit) [1,nfluct_types]
%struct_B.raperp = [0.01,0.01];%Minimum relative amplitude considered in the Fourier series expansion [1,nfluct_types]
%struct_B.nkperp = [300,200];%Number of points for describing the kperp power spectrum (odd number) [1,nfluct_types]
%
%  Magnetic field ripple
%
id_ripple = '';%'rippletest';%Name of the machine
%
% -------------------------------------------------------------------------
%
% Load structures
%
if exist('id_ripple') && ~isempty(id_ripple),
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
% [fluct_fit] = fitfluct_yp(fluct,1,'spline');
% testfitfluct_yp(equil_fit,fluct,fluct_fit,0.8);

