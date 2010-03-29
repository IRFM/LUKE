%script make_rayinit_ITER_Scen4_all
%
% runs all IAEA06 rayinit scripts
%
clear all
close all
warning off
%
dkepath = load_structures_yp('dkepath','','');%to set path to DCLUKE functions
%
mdce_mode = 2;
%
script_list = {...
'make_wave_ITER_Scen4_19Z',...
'make_wave_ITER_Scen4_20Z',...
'make_wave_ITER_Scen4_21Z'};
%
nruns = length(script_list);
%
dkecluster = clustermode_luke(mdce_mode,'',0,dkepath.remote);
dkecluster.size = nruns;
%
flag = mdce_luke(@feval,{''},1,script_list,dkecluster);
%
disp('******** Waves completed **********')