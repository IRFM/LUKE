function equil_prof = equil_prof_ACCOME_yp(filename,type,prho,psin,display_mode,p_opt,dispname,savename,Zeff)
%
% This function reads the equilibrium profile data from ACCOME
%
%	INPUTS:
%
%		- filename: equilibrium data and save name
%		- type: profile data type:(0) for ascii; (1) for .mat
%		- display_mode: option for figure display
%		- p_opt: option for printing
%
% by Y.PEYSSON (CEA-DRFC, yves.peysson@cea.fr)
%
if nargin < 10,% & type == 3
    Zeff = NaN;
end
if nargin < 9,
    savename = filename;
end
if nargin < 8,
    dispname = filename;
end
%
if nargin < 7,
    p_opt = -1;
end
%
if nargin < 6,
    display_mode = 0;
end
%
method = 'spline';%'linear';
%
% Reads profile T and n data
%
profname = [filename,'.params'];
fid = fopen(profname);
%
npsi = fscanf(fid,'%d',1);
Zimp = fscanf(fid,'%f',1);
mimp = fscanf(fid,'%f',1);
%
fscanf(fid,'%s',11);
for ipsin=1:npsi,
    fscanf(fid,'%d',1);
    ypsin(ipsin) = fscanf(fid,'%f',1);
    yne(ipsin) = fscanf(fid,'%f',1);
    ynh(ipsin) = fscanf(fid,'%f',1);
    ynd(ipsin) = fscanf(fid,'%f',1);
    ynt(ipsin) = 0.0;
    ynimp(ipsin) = fscanf(fid,'%f',1);
    fscanf(fid,'%f',1);
    yTe(ipsin) = fscanf(fid,'%f',1);
    yTi(ipsin) = fscanf(fid,'%f',1);
    yZeff(ipsin) = fscanf(fid,'%f',1);
    ynisne(ipsin) = fscanf(fid,'%f',1);
end
%
fclose(fid);
%
zZi = [1,1,1,Zimp];
zmi = [1,2,3,mimp];
fi = [1,1,0];%Hydrogen + Deuterium plasma (no tritium)
yTe = yTe/1000;%keV
yTi = yTi/1000;%keV
yzTi = [1;1;0;1]*yTi;
yzni = [ynh;ynd;ynt;ynimp];
%
if ~isempty(prho),% profiles given on rho grid
    pTe = interp1(yrho,yTe,prho,method);
    pne = interp1(yrho,yne,prho,method);
    pzTi = interp1(yrho,yzTi.',prho,method).';
    pzni = interp1(yrho,yzni.',prho,method).';
    %
elseif ~isempty(psin),% profiles given on poloidal flux based grid
    pTe = interp1(ypsin,yTe,psin,method);
    pne = interp1(ypsin,yne,psin,method);
    pzTi = interp1(ypsin,yzTi.',psin,method).';
    pzni = interp1(ypsin,yzni.',psin,method).'; 
end
%
% equil structure
%
equil_prof.zZi = zZi;
equil_prof.zmi = zmi;
equil_prof.pTe = pTe;
equil_prof.pne = pne;
equil_prof.pzTi = pzTi;
equil_prof.pzni = pzni;
%