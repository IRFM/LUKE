close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
remote_cluster = 'ALTAIR';%'SIRRAH','ANDROMEDE;
%
[liste_diag] = remote_tsmat(0,'EXP=T=S;TORE_SUPRA;LISTDIAG',remote_enforce,remote_cluster);
%[ITOR] = remote_tsmat(0,'EXP=T=S;General;Itor',remote_enforce,remote_cluster);
%[poshyb] = remote_tsmat(45525,'EXP=T=S;ANTENNES;POSHYB',remote_enforce,remote_cluster);
%
disp('List of avaiable diagnostic for TORE SUPRA discharge #45525')
disp('-----------------------------------------------------------')
disp(liste_diag)
%