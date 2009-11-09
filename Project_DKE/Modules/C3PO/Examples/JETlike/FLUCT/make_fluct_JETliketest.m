%
% Parameters for testing the role of density or magnetic field fluctuations on ray-tracing 
% This function has a benchmarking purpose only
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
clear all
close all
clc
%
id_fluct = 'dn0p3';%Plasma fluctuations identifier
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
% Magnetic field and electron density fluctuations kperp spectrum
%
dfcl = 1e-3;%Density fluctuation correlation length perpendicular to the magnetic field (m)
fnkperpspec = 1;%Density fluctuation kperp spectrum : (1) Gaussian
%
mffcl = Inf;%Magnetic field fluctuation correlation length perpendicular to the magnetic field (m)
fbkperpspec = 1;%Magnetic field fluctuation kperp spectrum : (1) Gaussian
%
% Magnetic field and electron density fluctuations profiles
%
fnmax = 0.3;%Maximum relative amplitude of the density fluctuation spectrum
dln = 0.1;%Radial decay length for density fluctuations (in normalized minor radius)
%
fbmax = 0.3e-2;%Maximum relative amplitude of the magnetic field fluctuation spectrum
dlb = 0.1;%Radial decay length for magnetic field fluctuations
%
% Numerical parameters (Monte-Carlo + plasma model)
%
ns0 = 100000;%number of time step before fluctuations are considered
xreset0 = 17;%Seed for random number generator (used if fmode = 1)
nkperproots = 2;%Maximum number of roots in kperp solution of the dispersion relation. For the cold plasma model, nkperproots = 2.WARNING : check the consistency with rayparam.tensortype = waveparam.kmode
betagridsize = 20;%Size of the grid for the angle of rotation of kperp
dtfac = 10;%Time step reduction factor to avoid multiple scattering events during the ray-tracing integration (> 1)
%
% -------------------------------------------------------------------------
%
% Load structures
%
[equil] = load_structures_yp('equil',id_equil,path_equil);
%
% =========================================================================
%
fluct.id = id_fluct;
%
%
% Plasma fluctuation numerical parameters (Monte-Carlo + plasma model)
%
fluct.ns0 = ns0;
fluct.xreset0 = xreset0;
fluct.nkperproots = nkperproots; 
fluct.betagridsize = betagridsize;
fluct.dtfac = dtfac;
%
fluct.dfcl = dfcl;
fluct.fnkperpspec = fnkperpspec;
fluct.mffcl = mffcl;
fluct.fbkperpspec = fbkperpspec;
%
fluct.prho = equil.ptx(:,1)/equil.ptx(end,1);
%
fluct.pfn = fnmax*exp(-(fluct.prho.^2 - 1.0).^2/dln/dln);% Electron desnity fluctuation profile
fluct.pfb = fbmax*exp(-(fluct.prho.^2 - 1.0).^2/dlb/dlb);% Electron desnity fluctuation profile
%
save_str = ['FLUCT_',id_equil,'_',id_fluct,'.mat'];
eval(['save ',save_str,' fluct']);
%
info_dke_yp(2,'Density and magnetic field fluctuations saved');
