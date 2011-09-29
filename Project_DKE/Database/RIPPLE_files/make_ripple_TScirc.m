%**************************************************************************************************************
%************************************** MAGNETIC RIPPLE PARAMETERS ********************************************
%**************************************************************************************************************
% Create the local file RIPPLE_id_equil.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
close all
%
id_equil = 'TScirc';
id_ripple = 'TSspecific';
%
ripple.id = id_ripple;
ripple.equil_id = id_equil;
%
%For the magnetic  ripple losses, the loss frequency must be very large compared to the reference frequency. Therefore it is always enforced in the code to 1000*nhu_ref
%Consequently, the ripple parameter is just a flag which indicates if magnetic ripple calculations are considered or not. Calculations are only valid for Tore Supra tokamak
%so the first two letters must be TS to be recognized in the calculations. See main_dke_yp.m
%
ripple.mode = 1;%No magnetic ripple if empty
%
ripple.N = 18;%Number of toroidal magnetic field coils
%
% For the Yushmanov model in Reviews of Plasma Physics, p.117-241, "Diffusive Transport Processes Caused by Ripple in Tokamaks" by P.N. Yushmanov, 1990.
%
ripple.B0 = 3.2;%Vacuum toroidal magnetic field on the toroidal axis, (signed value as BPHI) (T)
ripple.R0 = 2.4;%Toroidal major radius of the toroidal magnetic field windings(m)
ripple.rn = 1.0;%Inner radius of the toroidal magnetic field windings (m)
ripple.rx = 1.48;%Outer radius of the toroidal magnetic field windings (m)
%
%*************************************************************************************************************
%
eval(['save RIPPLE_',id_equil,'_',id_ripple,'.mat ripple']);
%
% DIsplay some results
%
load ../EQUIL_files/EQUIL_TScirc.mat
[equilDKE] = equilibrium_jd(equil,NaN,2i);%magnetic equilibrium for LUKE
ripple_model = 3;%Yushmanov model
%
[aBx,aBy,aBz,delta_rho,delta_theta,delta_phi] = bripfield_yp(ripple,equilDKE,ripple_model);
%
imidradius = find(equilDKE.xrho==0.5);%mid radius index
ipi = find(equilDKE.mtheta==pi);%indiex for theta = pi
%
figure('Name','Radial magnetic ripple perturbation')
graph1D_jd(equilDKE.mtheta(1:ipi),delta_rho(end,1:ipi),0,0,'\theta [rd]','\delta_{\rho}','Toroidal magnetic ripple (Tore Supra)',NaN,[0,pi],'','-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(equilDKE.mtheta(1:ipi),delta_rho(imidradius,1:ipi),0,0,'\theta [rd]','\delta_{\rho}','Toroidal magnetic ripple (Tore Supra)',NaN,[0,pi],'','--','none','b',2,20,gca,0.9,0.7,0.7);
legend('Plasma edge','Mid radius','Location','NorthEast');
print_jd(2,[id_equil,'_',id_ripple,'_delta_rho'],'Figures');
%
figure('Name','Poloidal magnetic ripple perturbation')
graph1D_jd(equilDKE.mtheta(1:ipi),delta_theta(end,1:ipi),0,0,'\theta [rd]','\delta_{\theta}','Toroidal magnetic ripple (Tore Supra)',NaN,[0,pi],'','-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(equilDKE.mtheta(1:ipi),delta_theta(imidradius,1:ipi),0,0,'\theta [rd]','\delta_{\theta}','Toroidal magnetic ripple (Tore Supra)',NaN,[0,pi],'','--','none','b',2,20,gca,0.9,0.7,0.7);
legend('Plasma edge','Mid radius','Location','NorthEast');
print_jd(2,[id_equil,'_',id_ripple,'_delta_theta'],'Figures');
%
figure('Name','Toroidal magnetic ripple perturbation')
graph1D_jd(equilDKE.mtheta(1:ipi),delta_phi(end,1:ipi),0,0,'\theta [rd]','\delta_{\phi}','Toroidal magnetic ripple (Tore Supra)',NaN,[0,pi],'','-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(equilDKE.mtheta(1:ipi),delta_phi(imidradius,1:ipi),0,0,'\theta [rd]','\delta_{\phi}','Toroidal magnetic ripple (Tore Supra)',NaN,[0,pi],'','--','none','b',2,20,gca,0.9,0.7,0.7);
legend('Plasma edge','Mid radius','Location','NorthEast');
print_jd(2,[id_equil,'_',id_ripple,'_delta_phi'],'Figures');
%
nphi = linspace(0,2*pi,ripple.N*100);
%
figure('Name','Toroidal magnetic ripple perturbation')
graph1D_jd(nphi,aBz(end,1)*cos(ripple.N*nphi)+ equilDKE.XBphi(end,1),0,0,'\phi [rd]','B_{\phi} [T]','Toroidal magnetic ripple (Tore Supra)',NaN,[0,2*pi],[min(equilDKE.XBphi(end,:))*0.5,max(equilDKE.XBphi(end,:))*1.5],'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(nphi,aBz(end,ipi)*cos(ripple.N*nphi)+ equilDKE.XBphi(end,ipi),0,0,'\phi [rd]','B_{\phi} [T]','Toroidal magnetic ripple (Tore Supra)',NaN,[0,2*pi],[min(equilDKE.XBphi(end,:))*0.5,max(equilDKE.XBphi(end,:))*1.5],'--','none','b',2,20,gca,0.9,0.7,0.7);
legend('Plasma edge (LFS)','Plasma edge (HFS)','Location','NorthEast');
print_jd(2,[id_equil,'_',id_ripple,'_B_phi'],'Figures');
%
%%%%%%%%%% Calcul des isoripple en courbes bleues et fines sur fond de courbes isoflux
%
figure(1),
%
xmin = min(min(equil.ptx));
xmax = max(max(equil.ptx));
ymin = min(min(equil.pty));
ymax = max(max(equil.pty));
%
hold on
graph2D_jd(equilDKE.Xx,equilDKE.Xy,log(delta_phi).','','','',[xmin,xmax],[ymin,ymax],0,NaN,NaN,0,'-','b',2,20);
hold off
print_jd(2,[id_equil,'_',id_ripple,'_isoripple'],'Figures');
