% script proc_wave_ITER_Scen4_IAEA06_C3PO
%
% displays wave properties
%
% by 	J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
% and   Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
clear all
close all
clc
%
% Equilibrium parameters
%
id_equil = 'ITER_Scen4_IAEA06';%For plasma equilibrium
path_equil = '../../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Wave properties - note that ids_wave,paths_wave,ids_rayinit and paths_rayinit must have the same
% number of elements
%
ids_wave = {'20Z_Alpha_3p7','20Z_Alpha_5p0'};
paths_wave = {'',''};
%
% Corresponding initial ray conditions - if not available, leave empty
%
ids_rayinit = ids_wave;%{'19Z'};
paths_rayinit = paths_wave;%{''};
%
n_rf_list = {0};%list of harmonics for absorption calculations
%
nr_dep = 20;
%
% Display parameters
%
opt.print = -1;
opt.TeNpar = 0;
opt.abs_max = 1;
%
rho_disp = [0:0.1:1];
ymask = {[2],[2]};%NaN;
yabs = {[873;1170],[795;939]};%range of power deposition. If NaN linear theory is used.
xvar = 's';
%
% -------------------------------------------------------------------------
%
% Load equilibrium
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	return
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
% load waves
%
ii=1;
for iw = 1:length(ids_wave),
	if exist([paths_wave{iw},'WAVE_',id_equil,'_',ids_wave{iw},'.mat']) == 0,%RF waves
		info_dke_yp(2,[paths_wave{iw},'WAVE_',id_equil,'_',ids_wave{iw},'.mat does not exist']);
        return
	else
		eval(['load ',paths_wave{iw},'WAVE_',id_equil,'_',ids_wave{iw},'.mat']);
		info_dke_yp(2,[paths_wave{iw},'WAVE_',id_equil,'_',ids_wave{iw},'.mat successfully loaded']);
		waves{ii} = wave;
		ii = ii + 1;
	end
end
%
% load initial ray conditions 
%
ii=1;
for iw = 1:length(ids_wave),
	if isempty(ids_rayinit{iw}),
        rayinits{iw} = '';
    elseif exist([paths_rayinit{iw},'RAYINIT_',id_equil,'_',ids_rayinit{iw},'.mat']) == 0,%Initial ray conditions
		info_dke_yp(2,[paths_rayinit{iw},'RAYINIT_',id_equil,'_',ids_rayinit{iw},'.mat does not exist']);
        return
	else
		eval(['load ',paths_rayinit{iw},'RAYINIT_',id_equil,'_',ids_rayinit{iw},'.mat']);
		info_dke_yp(2,[paths_rayinit{iw},'RAYINIT_',id_equil,'_',ids_rayinit{iw},'.mat successfully loaded']);
		rayinits{iw} = rayinit;
	end
end
%
% -------------------------------------------------------------------------
%
graph_wave_jd(equil,waves,rayinits,n_rf_list,nr_dep,opt,rho_disp,ymask,xvar,yabs);
%

