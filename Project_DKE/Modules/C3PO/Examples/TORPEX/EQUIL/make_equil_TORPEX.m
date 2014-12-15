function [equil] = make_equil_TORPEX
%
%   This script generates the magnetic equilibrium-like data file of the TORPEX toric machine (CRPP, Switzerland)
%
%   By Y. Peysson <yves.peysson@cea.fr> and J. Decker <joan.decker@epfl.ch>
%
clear all
close all
clc
%
id = 'TORPEX';
%
B_torpex_data_x = load('Sources/B_V_x.txt','-ascii');% Radial magnetic field, TORPEX B_X [T]
B_torpex_data_y = load('Sources/B_Tbc_y.txt','-ascii');% Toroidal magnetic field, TORPEX B_Y [T]
B_torpex_data_z = load('Sources/B_V_z.txt','-ascii');% Vertical magnetic field, TORPEX B_Z [T]
%
ne_torpex_data = load('Sources/ne.txt','-ascii');% electron density [m-3]
%
if sum(sum(B_torpex_data_x(1:2,:) - B_torpex_data_y(1:2,:)) + sum(B_torpex_data_x(1:2,:) - B_torpex_data_z(1:2,:)) + sum(B_torpex_data_y(1:2,:) - B_torpex_data_z(1:2,:))) ~= 0,%grid consistency
    error('ERROR: inconsistent raw TORPEX B data');
end
%
if sum(sum(B_torpex_data_x(1:2,:) - ne_torpex_data(1:2,:))) ~= 0,%grid consistency
    error('ERROR: inconsistent raw TORPEX ne data');
end
%
Rp = (B_torpex_data_x(1,end) + B_torpex_data_x(1,1))/2;%Major radius (m) at phi = 0
Zp = (B_torpex_data_x(2,end) + B_torpex_data_x(2,1))/2;%Vertical position (m) at phi = 0
%
xyx = B_torpex_data_x(1,:) - Rp;
xyy = B_torpex_data_x(2,:) - Zp;
%
xyBx = B_torpex_data_x(3:end,:);
xyBy = B_torpex_data_z(3:end,:);
xyBz = B_torpex_data_y(3:end,:);%toroidal direction
%
xyne = ne_torpex_data(3:end,:);
xyTe = zeros(size(xyne));
%
zZi = [1,1,1,2];%Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
zmi = [1,2,3,4];%Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
zfi = [1,0,0];%Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
zeff = 1;%Effective charge 
%
xyzTi = repmat(zeros(size(xyne)),[length(zZi),1]);% Same temperature for all ion species
xyzni = species_dke_yp(xyne,zeff,zZi,zfi);
%
equil.id = id;
%
equil.Rp = Rp;
equil.Zp = Zp;
%
equil.xyx = xyx;
equil.xyy = xyy;
%
equil.xyBx = xyBx;
equil.xyBy = xyBy;
equil.xyBz = xyBz;%check sign for the reference frame
%
equil.xyTe = xyTe;
equil.xyne = xyne;
%
equil.zZi = zZi;
equil.zmi = zmi;
equil.zfi = zfi;
%
equil.xyzTi = xyzTi;
equil.xyzni = xyzni;
%
% Display TORPEX configuration
%
[xyR,xyZ] = meshgrid(xyx + Rp,xyy + Zp);
%
figure('Name','Radial magnetic field'),graph2D_jd(xyR,xyZ,xyBx.','R[m]','Z[m]','Radial magnetic field Bx [Tesla]',[],[],1);axis('equal'),colorbar;
figure('Name','Vertical magnetic field'),graph2D_jd(xyR,xyZ,xyBy.','R[m]','Z[m]','Vertical magnetic field By [Tesla]',[],[],1);axis('equal'),colorbar;
figure('Name','Toroidal magnetic field'),graph2D_jd(xyR,xyZ,xyBz.','R[m]','Z[m]','Toroidal magnetic field Bz [Tesla]',[],[],1);axis('equal'),colorbar;
figure('Name','Electron density'),graph2D_jd(xyR,xyZ,xyne.','R[m]','Z[m]','Interpolated electron density n_e[m^{-3}]',[],[],1);axis('equal'),colorbar;
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equil']);
%
[equil_fit] = fitequil_yp(equil,2,'spline');


