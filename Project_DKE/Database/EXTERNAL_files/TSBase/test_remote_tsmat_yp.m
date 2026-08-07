% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
close all
clear all
clc
%
remote_enforce = 0;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
%
tsclean(45525);
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