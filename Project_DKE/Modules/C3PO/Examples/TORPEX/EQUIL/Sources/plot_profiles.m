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
%cd('D:\Furno\Matlab\TORPEX\RFSCAT\Magnetic_field')
if 0
load Data4IvoRFSCAT
[X,Y]=meshgrid(linspace(-0.2,0.2,50),linspace(-0.2,0.2,50));
Ne=griddata(x/1000,y/1000,ne,X,Y);
figure(1)
contourf(X,Y,Ne)
colorbar
xlabel('X[m]')
ylabel('Z[m]')
title('electron density [m^{-3}]')

figure(2)
Te=griddata(x/1000,y/1000,te,X,Y);
contourf(X,Y,Te)
colorbar
xlabel('X[m]')
ylabel('Z[m]')
title('electron temperature [eV]')

end

% plot of the toroidal component of the magnetic field
load -ascii B_Tbc_y.txt
figure(3)
x=B_Tbc_y(1,:);
y=B_Tbc_y(2,:);
[X,Y]=meshgrid(x,y);
contourf(X,Y,B_Tbc_y(3:end,:))
colorbar
xlabel('X[m]')
ylabel('Z[m]')
title('Toroidal magnetic field, B_y[Tesla]')

% plot of the radial component of the magnetic field
load -ascii B_V_x.txt
figure(4)
x=B_V_x(1,:);
y=B_V_x(2,:);
[X,Y]=meshgrid(x,y);
contourf(X,Y,B_V_x(3:end,:))
colorbar
xlabel('X[m]')
ylabel('Z[m]')
title('Radial magnetic field, B_X[Tesla]')


% plot of the toroidal component of the magnetic field
load -ascii B_V_Z.txt
figure(5)
x=B_V_Z(1,:);
y=B_V_Z(2,:);
[X,Y]=meshgrid(x,y);
contourf(X,Y,B_V_Z(3:end,:))
colorbar
xlabel('X[m]')
ylabel('Z[m]')
title('Vertical magnetic field, B_Z[Tesla]')


load -ascii ne.txt
figure(6)
x=ne(1,:);
y=ne(2,:);
[X,Y]=meshgrid(x,y);
contourf(X,Y,ne(3:end,:))
colorbar
xlabel('X[m]')
ylabel('Z[m]')
title('Interpolated electron density, n_e[m^{-3}]')


