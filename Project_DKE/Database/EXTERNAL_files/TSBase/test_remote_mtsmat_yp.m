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