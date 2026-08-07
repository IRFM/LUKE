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
[phyb,tlh] = remote_tsbase(45525,'gphyb');
%
plot(tlh,phyb);title(['Tore Supra, shot #45525']),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');
