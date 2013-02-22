%
% Parameters for testing the effect of fluctuations on ray trajectories
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
clear all
close all
clc
%
id_fluct = 'pureripple';%Plasma fluctuations identifier
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
% Non axisymmetric perturbation of the toroidal MHD equilibrium for any rf waves : toroidal magnetic field ripple
%
id_ripple = 'rippletest';%Name of the machine
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
save_str = ['FLUCT_',id_equil,'_',id_fluct,'.mat'];
eval(['save ',save_str,' fluct']);
%
info_dke_yp(2,'Fluctuations structure saved');
%
% load('../EQUIL/EQUILV_JETliketest.mat');
%
% [fluct] = fluctphase_yp(fluct);
% [fluct_fit] = fitfluct_yp(fluct);
% testfitfluct_yp(equil_fit,fluct,fluct_fit,0.8);

