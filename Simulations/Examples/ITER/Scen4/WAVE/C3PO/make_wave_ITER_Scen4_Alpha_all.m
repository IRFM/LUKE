%script make_rayinit_ITER_Scen4_Alpha_all
%
% runs all IAEA06 rayinit scripts
%
clear all
close all
warning off
%
mdce_mode = 2;
%
script_list = {...
'make_wave_ITER_Scen4_19Z_Alpha_3p7',...
'make_wave_ITER_Scen4_19Z_Alpha_5p0',...
'make_wave_ITER_Scen4_20Z_Alpha_3p7',...
'make_wave_ITER_Scen4_20Z_Alpha_5p0',...
'make_wave_ITER_Scen4_21Z_Alpha_3p7',...
'make_wave_ITER_Scen4_21Z_Alpha_5p0'};
%
nruns = length(script_list);
%
dkecluster = clustermode_luke(mdce_mode,'',0);
dkecluster.size = nruns;
%
flag = mdce_luke(@feval,{''},1,script_list,dkecluster);
%
rmdir(dkecluster.temppath,'s');
%
disp('******** Waves completed **********')