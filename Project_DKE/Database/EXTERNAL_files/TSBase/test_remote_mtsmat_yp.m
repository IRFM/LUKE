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
tsclean(45525);
%
[data] = remote_mtsmat(45525,{'EXP=T=S;TORE_SUPRA;LISTDIAG','EXP=T=S;General;Itor','EXP=T=S;ANTENNES;POSHYB'});
%
disp('Multiple remote data load using tsmat function') 
disp('---------------------------------------------------------------')
disp('List of available diagnostic for TORE SUPRA discharge #45525')
disp('---------------------------------------------------------------')
disp(data{1})
%
disp('---------------------------------------------------------------')
disp('Itor for TORE SUPRA discharge #45525')
disp('---------------------------------------------------------------')
disp(data{2})
%
disp('---------------------------------------------------------------')
disp('Lower Hybrid antenna position for TORE SUPRA discharge #45525')
disp('---------------------------------------------------------------')
disp(data{3})
%