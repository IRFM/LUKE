%
% Parameters for testing the effect fluctuations on ray trajectories
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
clear all
close all
clc
%
id_fluct = 'npar0_lh';%Fluctuations identifier
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
% Perturbation of the launched npar for the LH wave only (simulate possible diffraction of the LH wave in the SOL by edge density fluctuations)
%
fluctuations.npar0_lh.fluct.dtn = 1;%Gaussian time correlation model, edge_dtn = 2.14*t_correlation (if edge_dtn is Inf, no fluctuations)
fluctuations.npar0_lh.fluct.hwhm_npar = 0.1;%Gaussian distribution (if hwhm is NaN or empty, no fluctuations)%
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
