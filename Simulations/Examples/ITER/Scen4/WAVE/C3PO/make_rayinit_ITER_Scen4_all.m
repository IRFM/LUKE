%script make_rayinit_ITER_Scen4_all
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
'make_rayinit_ITER_Scen4_19Z',...
'make_rayinit_ITER_Scen4_20Z',...
'make_rayinit_ITER_Scen4_21Z'};
%
nruns = length(script_list);
%
dkecluster = clustermode_luke(mdce_mode,'',0);
dkecluster.size = nruns;
%
flag = mdce_luke(@loop_script_jd,{''},1,script_list,dkecluster);
%
rmdir(dkecluster.temppath,'s');
%
disp('******** Rayinits completed **********')
