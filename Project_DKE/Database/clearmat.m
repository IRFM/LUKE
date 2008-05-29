function [] = clearmat(dirname)
%LUKE - Remove binary files (*.mat) 
%
%This script removes *.mat file
%
% by  Yves Peysson <yves.peysson@cea.fr> (CEA/DSM/IRFM) and Joan Decker <joan.decker@cea.fr> (CEA/DSM/IRFM)
%
cd(dirname)
delete('*.mat')
pause(2)
info_dke_yp(2,['All *.mat files in ',dirname,' directory are removed.'])
cd ..
