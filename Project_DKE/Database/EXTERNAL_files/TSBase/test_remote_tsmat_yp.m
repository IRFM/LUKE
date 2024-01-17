close all
clear all
clc
%
remote_enforce = 0;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
%
[liste_diag] = remote_tsmat(45525,'EXP=T=S;TORE_SUPRA;LISTDIAG');
[poshyb] = remote_tsmat(45525,'EXP=T=S;ANTENNES;POSHYB');
%[ITOR] = remote_tsmat(45525,'EXP=T=S;General;Itor',remote_enforce,remote_cluster);%shot number may be 0
%
disp('Remote data load using tsmat function') 
disp('-----------------------------------------------------------')
disp('List of available diagnostic for TORE SUPRA discharge #45525')
disp('-----------------------------------------------------------')
disp(liste_diag)
%
%
disp('---------------------------------------------------------------')
disp('Lower Hybrid antenna position for TORE SUPRA discharge #45525')
disp('---------------------------------------------------------------')
disp(poshyb)
%