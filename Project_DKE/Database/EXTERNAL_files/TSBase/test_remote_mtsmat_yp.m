close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
remote_cluster = 'ALTAIR';%'SIRRAH','ANDROMEDE;
%
[data] = remote_mtsmat(45525,{'EXP=T=S;TORE_SUPRA;LISTDIAG','EXP=T=S;General;Itor','EXP=T=S;ANTENNES;POSHYB'},remote_enforce,remote_cluster);
%
disp('Multiple remote data load using tsmat function')
disp('---------------------------------------------------------------')
disp('List of available diagnostic for TORE SUPRA discharge #45525')
disp('---------------------------------------------------------------')
disp(data(1))
%
disp('---------------------------------------------------------------')
disp('Itor for TORE SUPRA discharge #45525')
disp('---------------------------------------------------------------')
disp(data(2))
%
disp('---------------------------------------------------------------')
disp('Lower Hybrid antenna position for TORE SUPRA discharge #45525')
disp('---------------------------------------------------------------')
disp(data(3))
%