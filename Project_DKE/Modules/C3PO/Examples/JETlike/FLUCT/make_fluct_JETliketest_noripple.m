%
% Parameters for testing the effect of density or magnetic field fluctuations on ray trajectories
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
clear all
close all
clc
%
id_fluct = 'test_noripple';%Plasma fluctuations identifier
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
% Core plasma fluctuations inside the separatrix
%
naequilp.core.fluct.type = {'ne'};%Type of fluctuations or modulations ('ne': electron density, 'B': magnetic field) {1,nfluct_types}
naequilp.core.fluct.model = [1];%Statistical ne fluctuation model (>= 1) : [1,nfluct_types]
                        %    - (1) -> 3-D Gaussian model (rho,theta,phi), relative epsi values (benchmark of C3PO)
                        %    - (2) -> 3-D Gaussian model (rho,theta,phi), absolute epsi values (m)
                        %    - (3) -> 2-D Gaussian drift-wave like model global (rho,curtheta), absolute epsi values (m)
                        %    - (4) -> 1-D Gaussian drift-wave like model local (curtheta), absolute epsi values (m)
                        %    - (5) -> 1-D Gaussian drift-wave like model local (cn,cm), absolute epsi values (m)
                        %    - (6) -> 2-D Gaussian drift-wave like model local (rho,cn,cm), absolute epsi values (m)
                        %    - (7) -> *** NOT IMPLEMENTED *** 2-D Gaussian drift-wave like model local (rho,lperp), absolute epsi values (m)
naequilp.core.fluct.sigmar_max = [0.7];%Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
naequilp.core.fluct.sigmar_hwhm = [0.1];%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
naequilp.core.fluct.sigmar_rho = [1];%Radial location where the relative fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
naequilp.core.fluct.polmode = [0.0];%HFS/LFS relative fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
%
naequilp.core.fluct.epsi_rho = [0.01];%
naequilp.core.fluct.epsi_theta = [0.01];%theta direction is perp direction for models 3 & 4
naequilp.core.fluct.epsi_phi = [0.2];%useless for models 3 & 4
%
naequilp.core.fluct.lmin = [1];%
naequilp.core.fluct.mmin = [1];%for perp direction for models 3 & 4
naequilp.core.fluct.nmin = [1];%useless for models 3 & 4
%
naequilp.core.fluct.lmax = [50];%
naequilp.core.fluct.mmax = [50];%for perp direction for models 3 & 4
naequilp.core.fluct.nmax = [5];%useless for models 3 & 4%
%
% Edge plasma fluctuations outside the separatrix (for LH wave only, run with run_lukert or a specific script)
%
naequilp.edge.fluct.dtn = Inf;%Gaussian time correlation model, edge_dtn = 2.14*t_correlation (if edge_dtn is Inf, no fluctuations)
naequilp.edge.fluct.hwhm_npar = 0.1;%Gaussian distribution (if hwhm is NaN or empty, no fluctuations)
%
% -------------------------------------------------------------------------
%
% Load structures
%
if exist('id_ripple'),
    if ~isempty(id_ripple),
        [equil,ripple] = load_structures_yp('equil',id_equil,path_equil,'ripple',id_ripple,'');
        naequilp.core.ripple = ripple;
    else
        [equil] = load_structures_yp('equil',id_equil,path_equil);
    end
else
    [equil] = load_structures_yp('equil',id_equil,path_equil);  
end
%
[fluct] = fluctstruct_yp(equil,id_fluct,naequilp);
%
% Data saving
%
save_str = ['FLUCT_',id_equil,'_',id_fluct,'.mat'];
eval(['save ',save_str,' fluct']);
%
info_dke_yp(2,'Plasma fluctuations saved');
%
% load('../EQUIL/EQUILV_JETliketest.mat');
%
% [fluct] = fluctphase_yp(fluct,0);%Mersenne-Twitter pseudorandom generator -> 0, Matlab rand (reset by clock) -> 1
% [fluct_fit] = fitfluct_yp(fluct);
% testfitfluct_yp(equil_fit,fluct,fluct_fit,0.8);


