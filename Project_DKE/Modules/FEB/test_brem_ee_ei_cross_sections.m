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
%
% test e-e and e-i cross-sections and compare with publications (ref hau75)
%
close all
clear all
clear mex
%
clc
%
markersize = 12;
markertype(1) = 'o';
markertype(2) = 'o';
markertype(3) = 'o';
linewidth = 2;
fontsize = 14;
colorchoice(1) = 'r';
colorchoice(2) = 'b';
colorchoice(3) = 'g';
colorchoice(4) = 'c';
colorchoice(5) = 'm';
colorchoice(6) = 'k';
%
mb = 1e-31;%millibarns (10^-31 m2)
%
Ec = 300;%Incoming electron kinetic energy (keV)
k = 10;%Emitted photon energy (keV)
theta = linspace(0,pi,100);%angle between incoming electron and emitted photon (rad)
Znucleus = 1;%charge of the nucleus (H)
%
[seBHE,seBH,Elwert] = bhe_dke_yp(Ec,k,cos(theta),Znucleus);%Bethe-Heitler (1st Born approx.) + Elwert Coulomb correction (m2)
%
[seHC,seH,fee] = haug_dke_yp(Ec,k,cos(theta));
%
figure('Name','Ec = 300 keV, k = 10 keV, Z = 1 (H), no screening, angular scan')
%
plot(theta*180/pi,squeeze(seBHE)/mb/511,[colorchoice(1),'-'],'LineWidth',2);hold on
plot(theta*180/pi,squeeze(seHC)/mb/511,[colorchoice(4),'-.'],'LineWidth',2);hold on
legend('Bethe-Heitler+Elwert (e-i)','Haug (e-e)')
title('Ec = 300 keV, k = 10 keV, Z = 1 (H)')
xlabel('Photon emission angle \theta (deg.)')
ylabel('d\sigma/dk/d\Omega_k [mb/sterad]')
%
grid minor
drawnow
%
k = 200;%Emitted photon energy (keV)
%
[seBHE,seBH,Elwert] = bhe_dke_yp(Ec,k,cos(theta),Znucleus);%Bethe-Heitler (1st Born approx.) + Elwert Coulomb correction (m2)
%
[seHC,seH,fee] = haug_dke_yp(Ec,k,cos(theta));
%
figure('Name','Ec = 300 keV, k = 200 keV, Z = 1 (H), no screening, angular scan')
%
plot(theta*180/pi,squeeze(seBHE)/mb/511,[colorchoice(1),'-'],'LineWidth',2);hold on
plot(theta*180/pi,squeeze(seHC)/mb/511,[colorchoice(4),'-.'],'LineWidth',2);hold on
legend('Bethe-Heitler+Elwert (e-i)','Haug (e-e)')
title('Ec = 300 keV, k = 200 keV, Z = 1 (H)')
xlabel('Photon emission angle \theta (deg.)')
ylabel('d\sigma/dk/d\Omega_k [mb/sterad]')
%
grid minor
drawnow
%
Ec = 200000;%Incoming electron kinetic energy (keV)
k = 100000;%Emitted photon energy (keV)
theta = linspace(0,pi/10,100);%angle between incoming electron and emitted photon (rad)
%
[seBHE,seBH,Elwert] = bhe_dke_yp(Ec,k,cos(theta),Znucleus);%Bethe-Heitler (1st Born approx.) + Elwert Coulomb correction (m2)
%
[seHC,seH,fee] = haug_dke_yp(Ec,k,cos(theta));
%
figure('Name','Ec = 200 MeV, k = 100 MeV, Z = 1 (H), no screening, angular scan')
%
semilogy(theta*180/pi,squeeze(seBHE)/mb/511,[colorchoice(1),'-'],'LineWidth',2);hold on
semilogy(theta*180/pi,squeeze(seHC)/mb/511,[colorchoice(4),'-.'],'LineWidth',2);hold on
legend('Bethe-Heitler+Elwert (e-i)','Haug (e-e)')
title('Ec = 200 MeV, k = 100 MeV, Z = 1 (H)')
xlabel('Photon emission angle \theta (deg.)')
ylabel('(1/Z^2)*d\sigma/dk/d\Omega_k [mb/sterad]')
%
grid minor
drawnow


