%
% test Moliere fit of dft calculation or any atomic electron density whatever the ionization state
%
close all
clear all
clc
%
%load('DFT/dft_2_He_helium.mat');
%load('DFT/dft_4_Be_beryllium.mat');
%load('DFT/dft_6_C_carbon.mat');
%load('DFT/dft_7_N_nitrogen.mat');
%load('DFT/dft_13_Al_aluminium.mat');
%load('DFT/dft_10_Ne_neon.mat');
load('DFT/dft_18_Ar_argon.mat')
%load('DFT/dft_74_W_tungsten.mat')
%
maxnum_exp = 3;%maximum number of exponentials may be automatically reduced if necessary)
print_opt = 2;%-1: no print, 2:save files (eps,png,fig)
%
[dft] = moliere(dft,maxnum_exp);%add Moliere calculation field in dft (ref Gaussian code)
%
[dft] = moliere(dft,maxnum_exp,1);%add Moliere calculation field in dft (ref Thomas-Fermi model)
%
linestyle(1) = {'-'};
linestyle(2) = {'--'};
linestyle(3) = {'-.'};
linestyle(4) = {':'};
linestyle(5) = {'-'};
linestyle(6) = {'--'};
%
linecolor(1) = {'r'};
linecolor(2) = {'b'};
linecolor(3) = {'g'};
linecolor(4) = {'m'};
linecolor(5) = {'c'};
linecolor(6) = {'k'};
%
marker(1) = {'o'};
marker(2) = {'x'};
marker(3) = {'+'};
marker(4) = {'*'};
marker(5) = {'s'};
marker(6) = {'d'};
%
siz = 20+14i;
%
xlab = 'Ion radius [a_0]';
ylab1 = '\rho [{a^{-3}_0}]';
ylab2 = '4\pir^2\rho [{a^{-1}_0}]';
leg = {'HFS (Gaussian code)','Moliere'};
%
i = 1;%neutral atom
%
tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moliere - HFS (Gaussian)'];
tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moliere - HFS (Gaussian)'];
%
figure('Name',tit1);
graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.r,dft.moliere.ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
print_jd(print_opt,['Density_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure('Name',tit2);
graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.r,4*pi*dft.moliere.r.*dft.moliere.r.*dft.moliere.ne(:,i),0,0,xlab,ylab2,tit2,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
print_jd(print_opt,['Lineicdensity_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moliere - Thomas-Fermi'];
tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moliere - Thomas-Fermi'];
leg1 = {'Thomas-Fermi','Moliere'};
%
figure('Name',tit1);
graph1D_jd(dft.ionradius{1}.rn{1},dft.ionradius{1}.dens{1},0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.tf.r,dft.moliere.tf.ne(:,i),0,1,xlab,ylab1,tit1,leg1,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
print_jd(print_opt,['TF_Density_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure('Name',tit2);
graph1D_jd(dft.ionradius{1}.rn{1},4*pi*dft.ionradius{1}.rn{1}.*dft.ionradius{1}.rn{1}.*dft.ionradius{1}.dens{1},0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.tf.r,4*pi*dft.moliere.tf.r.*dft.moliere.tf.r.*dft.moliere.tf.ne(:,i),0,0,xlab,ylab2,tit2,leg1,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
print_jd(print_opt,['TF_Lineicdensity_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
i = round(dft.Z/2)-1;%partially ionized atom 
%
tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moliere - HFS (Gaussian)'];
tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moliere - HFS (Gaussian)'];
%
figure('Name',tit1);
graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.r,dft.moliere.ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
print_jd(print_opt,['Density_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure('Name',tit2);
graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.r,4*pi*dft.moliere.r.*dft.moliere.r.*dft.moliere.ne(:,i),0,0,xlab,ylab2,tit2,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
print_jd(print_opt,['Lineicdensity_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
print_jd(print_opt,['MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
i = dft.Z;%partially ionized atom 
%
tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moliere - HFS (Gaussian)'];
tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moliere - HFS (Gaussian)'];
%
figure('Name',tit1);
graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.r,dft.moliere.ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
print_jd(print_opt,['Density_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure('Name',tit2);
graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.r,4*pi*dft.moliere.r.*dft.moliere.r.*dft.moliere.ne(:,i),0,0,xlab,ylab2,tit2,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
print_jd(print_opt,['Lineicdensity_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure,semilogy(dft.r,dft.ne(:,1:end),'r',dft.moliere.r,dft.moliere.ne(:,1:end),'b--')
xlabel(xlab);
ylabel(ylab1);
title(['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),'), Moliere - HFS (Gaussian)']);
axis([0,10,1e-11,1e5])
grid minor
%
if maxnum_exp == 1
    %
    [dft.Z-dft.moliere.Nfit',dft.moliere.checksum',dft.moliere.A,dft.moliere.alpha,(dft.moliere.alpha./dft.moliere.alpha(1,:)).^2]
    %
    figure('Name',['Moliere - HFS (Gaussian)']);
    %
    ns = dft.Z*(1/3-0.002*dft.Z);
    x = dft.Z0/dft.Z;
    y_kir = (1./(1 - x)).^(4/3);
    y_al = (1 - x.^(ns+1))./(1-x);
    y_al_mod = (1 - x.^(ns+1))./(1-x).^1.5;
    %
    xlab3 = 'Z_{0,s}/Z_s';
    ylab3 = '\lambda^2_{Z_{0,s}}/\lambda^2_{0,s}';
    tit3 = [[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),')'];
    leg3 = {'HFS-Moliere (Gaussian)','Kirillov et al. model (1975)','Avdonina - Pratt model (1989)','Avdonina - Pratt - Peysson model (2019)'};
    %
    graph1D_jd((dft.Z-dft.moliere.Nfit')/dft.Z,(dft.moliere.alpha./dft.moliere.alpha(1,:)).^2,0,1,xlab3,ylab3,tit3,'','','','none',marker{1},linecolor{1},2,siz,gca);hold on
    graph1D_jd(x,y_kir,0,1,xlab3,ylab3,tit3,'','','',linestyle{2},'none',linecolor{2},2,siz,gca);hold on
    graph1D_jd(x,y_al,0,1,xlab3,ylab3,tit3,'','','',linestyle{3},'none',linecolor{3},2,siz,gca);hold on
    graph1D_jd(x,y_al_mod,0,1,xlab3,ylab3,tit3,leg3,'','',linestyle{4},'none',linecolor{4},2,siz,gca);  
    %
    print_jd(2,['Moliere - models for ions ',[upper(dft.name(1)), lower(dft.name(2:end))]],'./Figs',get(gcf,'Number'))
    %
else
    %
    [dft.Z-dft.moliere.Nfit',dft.moliere.checksum',dft.moliere.A,dft.moliere.alpha]
    [dft.Z-dft.moliere.tf.Nfit',dft.moliere.tf.checksum',dft.moliere.tf.A,dft.moliere.tf.alpha]
    %
end
