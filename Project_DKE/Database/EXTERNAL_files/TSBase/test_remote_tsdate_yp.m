close all
clear all
clc
%
tsclean(45525,'tsdate');
[shotdate] = remote_tsdate(45525); 
%
disp(['Tore Supra discharge #45525 has been done the  : ',shotdate]);
