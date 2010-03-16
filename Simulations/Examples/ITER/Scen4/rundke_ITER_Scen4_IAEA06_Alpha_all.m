%script rundke_ITER_Scen4_Alpha_all
%
% runs all IAEA06 Alpha scripts
%
clear all
close all
warning off
%
mdce_mode = 2;
%
script_list = {...
'rundke_ITER_Scen4_IAEA06_19Z_Alpha_3p7',...
'rundke_ITER_Scen4_IAEA06_19Z_Alpha_5p0',...
'rundke_ITER_Scen4_IAEA06_20Z_Alpha_3p7',...
'rundke_ITER_Scen4_IAEA06_20Z_Alpha_5p0',...
'rundke_ITER_Scen4_IAEA06_21Z_Alpha_3p7',...
'rundke_ITER_Scen4_IAEA06_21Z_Alpha_5p0'};
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
disp('******** Simulation completed **********')