%
% Parameters for testing the effect of density or magnetic field fluctuations on ray trajectories
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
id_fluct = 'test';%Plasma fluctuations identifier
%
% Path parameters
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Equilibrium parameters
%
id_equil = 'JETh77';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Density fluctuations (kpar = 0 fluctuation spectrum model)
%
struct_ne.type = 'ne';%Type of fluctuations or modulations [1,1]
struct_ne.model = [1,1];%Statistical ne fluctuation model (>= 1) : (1) -> Gaussian, (2) -> ... [1,nfluct_types]
struct_ne.sigmar_max = [0.3,0.1];%Maximum value of the relative ne fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
struct_ne.sigmar_hwhm = [0.2,0.3];%Radial half width at half maximum of the relative ne fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
struct_ne.sigmar_rho = [1,1];%Radial location where the relative ne fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
struct_ne.polmode = [0.2,1];%HFS/LFS relative ne fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
struct_ne.kperpc = [300,100];%Inverse of the correlation length of ne fluctuations perpendicular to the magnetic field (ap^(-1) unit) [1,nfluct_types]
struct_ne.kperpref = [0,0];%ne fluctuations reference perpendicular wave vector with respect to the local magnetic field direction (ap^(-1) unit) [1,nfluct_types]
struct_ne.raperp = [0.01,0.01];%Minimum relative amplitude considered in the Fourier series expansion [1,nfluct_types]
struct_ne.nkperp = [200,600];%Number of points for describing the kperp power spectrum (odd number) [1,nfluct_types]
%
% Magnetic field fluctuations (kpar = 0 fluctuation spectrum model)
%
struct_B.type = 'Bperp';%Type of fluctuations or modulations [1,1]
struct_B.model = [1,1];%Statistical Bperp fluctuation model (>= 1) : (1) -> Gaussian, (2) -> ... [1,nfluct_types]
struct_B.sigmar_max = [5e-3,1e-4];%Maximum value of the relative Bperp fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
struct_B.sigmar_hwhm = [0.3,0.2];%Radial half width at half maximum of the relative Bperp fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
struct_B.sigmar_rho = [0,1];%Radial location where the relative Bperp fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
struct_B.polmode = [1,0.3];%HFS/LFS relative Bperp fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
struct_B.kperpc = [300,200];%Inverse of the correlation length of Bperp fluctuations perpendicular to the magnetic field (ap^(-1) unit) [1,nfluct_types]
struct_B.kperpref = [0,0];%Bperp fluctuations reference perpendicular wave vector with respect to the local magnetic field direction (ap^(-1) unit) [1,nfluct_types]
struct_B.raperp = [0.01,0.01];%Minimum relative amplitude considered in the Fourier series expansion [1,nfluct_types]
struct_B.nkperp = [300,200];%Number of points for describing the kperp power spectrum (odd number) [1,nfluct_types]
%
% -------------------------------------------------------------------------
%
% Load structures
%
[equil] = load_structures_yp('equil',id_equil,path_equil);
%
% =========================================================================
%
[fluct] = fluctstruct_yp(equil,id_fluct,struct_ne,struct_B);
%
% Data saving
%
save_str = ['FLUCT_',id_equil,'_',id_fluct,'.mat'];
eval(['save ',save_str,' fluct']);
%
info_dke_yp(2,'Plasma fluctuations saved');
