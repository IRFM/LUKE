%function [] = gaussian09_grasp2018_comparison(Z)
Z = 18;%Argon
%
% Comparison between GAUSSIAN and GRASP for different ionization of
% various elements. Cross-validation of the two methods for determining the ground-state 
% atomic density Tungsten
%
% by Yves Savoye-Peysson <yves.savoye-peysson@cea.fr> (IRFM/CEA)
%
%clear all
close all
clc
%
name = elements('atomic_number',Z,'name');
symbol = elements('atomic_number',Z,'symbol');
%
load(['DFT/dft_',int2str(Z),'_',symbol,'_',name,'.mat'])
load(['MCDHF/mcdhf_',int2str(Z),'_',symbol,'_',name,'.mat'])
%
tit1 = [[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z)];
h1 = figure('Name',[tit1,') DFT + MCDHF']);
semilogy(dft.dft_data(:,2),dft.dft_data(:,3:end),'r-','LineWidth',2), hold on
semilogy(mcdhf.ne(:,2),mcdhf.ne(:,3:end),'bo','MarkerSize',3)
axis([0,5,1e-4,1e4])
legend('DFT ({\itGAUSSIAN} code), Z_{0,s} = 0','MCDHF ({\itGRASP} code), Z_{0,s} = 0')
%
xlab = 'Ion radius [a_0]';
ylab = 'Density of bound electrons [{a^{-3}_0}]';
ylabel(ylab)
xlabel(xlab)
title([tit1,')'])
%
grid minor
%
drawnow
%

N_dft = 4*pi*trapz_dke_yp([dft.r,dft.ne(:,1).*dft.r.^2])
N_mcdhf = 4*pi*trapz_dke_yp([mcdhf.ne(:,2),mcdhf.ne(:,3).*mcdhf.ne(:,2).^2])

return











print_opt = 2;
%
load('DFT/dft_18_Ar_argon.mat')
load('MCDHF/Ar0_GRASP.mat')
W0 = aa;
load('MCDHF/W10_GRASP.mat')
W10 = cc;
load('MCDHF/W42_GRASP.mat')
W42 = bb;
load('MCDHF/W56_GRASP.mat')
W56 = dd;
%
tit1 = [[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z)];
h1 = figure('Name',[tit1,') DFT + MCDHF']);
semilogy(dft.r,dft.ne(:,1),'r-',dft.r,dft.ne(:,11),'r--',dft.r,dft.ne(:,43),'r-.',dft.r,dft.ne(:,57),'r:','LineWidth',2), hold on
semilogy(W0(1:3:end,1),W0(1:3:end,3),'bo',W10(1:3:end,1),W10(1:3:end,3),'b*',W42(1:3:end,1),W42(1:3:end,3),'b+',W56(1:3:end,1),W56(1:3:end,3),'bx','MarkerSize',12)
axis([0,5,1e-4,1e4])
legend('DFT ({\itGAUSSIAN} code), Z_{0,s} = 0','DFT ({\itGAUSSIAN} code), Z_{0,s} = 10','DFT ({\itGAUSSIAN} code), Z_{0,s} = 42','DFT ({\itGAUSSIAN} code), Z_{0,s} = 56','MCDHF ({\itGRASP} code), Z_{0,s} = 0','MCDHF ({\itGRASP} code), Z_{0,s} = 10','MCDHF ({\itGRASP} code), Z_{0,s} = 42','MCDHF ({\itGRASP} code), Z_{0,s} = 56')
%
xlab = 'Ion radius [a_0]';
ylab = 'Density of bound electrons [{a^{-3}_0}]';
ylabel(ylab)
xlabel(xlab)
title([tit1,')'])
%
grid minor
%
drawnow
%
print_jd(print_opt,['GaussianGrasp_comparison_',int2str(dft.Z)],'./Figs',get(h1,'Number'))
%
dft.Z - [trapz(dft.r,dft.ne(:,1)*4*pi.*dft.r.*dft.r),trapz(W0(:,1),W0(:,3)*4*pi.*W0(:,1).*W0(:,1)),trapz(W0(:,1),W0(:,2))]
dft.Z - [trapz(dft.r,dft.ne(:,11)*4*pi.*dft.r.*dft.r),trapz(W10(:,1),W10(:,3)*4*pi.*W10(:,1).*W10(:,1)),trapz(W10(:,1),W10(:,2))]
dft.Z - [trapz(dft.r,dft.ne(:,43)*4*pi.*dft.r.*dft.r),trapz(W42(:,1),W42(:,3)*4*pi.*W42(:,1).*W42(:,1)),trapz(W42(:,1),W42(:,2))]
dft.Z - [trapz(dft.r,dft.ne(:,57)*4*pi.*dft.r.*dft.r),trapz(W56(:,1),W56(:,3)*4*pi.*W56(:,1).*W56(:,1)),trapz(W56(:,1),W56(:,2))]
%
h2 = figure('Name',[tit1,',Z_{0,s} = 0) DFT + simple atomic models']);
semilogy(dft.r,dft.ne(:,1),'r-',dft.ionradius{1}.rn{1},dft.ionradius{1}.dens{1},'b--',...
dft.ionradius{4}.rn{1},dft.ionradius{4}.dens{1},'b-.',...
dft.ionradius{5}.rn{1},dft.ionradius{5}.dens{1},'b:','LineWidth',2), hold on
axis([0,5,1e-4,1e4])
legend('DFT ({\itGAUSSIAN} code)','Thomas-Fermi','Yukawa with \lambda^B_{0,s}','Yukawa with \lambda^{TF}_{0,s}')
%
xlab = 'Ion radius [a_0]';
ylab = 'Density of bound electrons [{a^{-3}_0}]';
ylabel(ylab)
xlabel(xlab)
title([tit1,', Z_{0,s} = 0)'])
%
grid minor
%
drawnow
%
print_jd(print_opt,['DFTsimplemodels_comparison_',int2str(dft.Z),'_Zs0=0'],'./Figs',get(h2,'Number'))
%
h3 = figure('Name',[tit1,',Z_{0,s} = 42) DFT + simple atomic models']);
semilogy(dft.r,dft.ne(:,43),'r-',dft.ionradius{1}.rn{42},dft.ionradius{1}.dens{42},'b--',...
dft.ionradius{4}.rn{42},dft.ionradius{4}.dens{42},'b-.',...
dft.ionradius{5}.rn{42},dft.ionradius{5}.dens{42},'b:','LineWidth',2), hold on
axis([0,2,1e-4,1e4])
legend('DFT ({\itGAUSSIAN} code)','Thomas-Fermi','Yukawa with \lambda^B_{0,s}','Yukawa with \lambda^{TF}_{0,s}')
%
xlab = 'Ion radius [a_0]';
ylab = 'Density of bound electrons [{a^{-3}_0}]';
ylabel(ylab)
xlabel(xlab)
title([tit1,', Z_{0,s} = 42)'])
%
grid minor
%
drawnow
%
print_jd(print_opt,['DFTsimplemodels_comparison_',int2str(dft.Z),'_Zs0=42'],'./Figs',get(h3,'Number'))
%