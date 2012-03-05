%Script for running the DKE solver (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
clear mex
clear functions
close all
warning off
global nfig
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'Ohm_epsi';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.5];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {''};%For RF waves contribution (put all the type of waves needed)
paths_wave = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = '';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = '';%For fast electron magnetic ripple losses
path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%2;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 0;%1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
betath = 0.1;%validated for NR limit
%
epsi_list = logspace(-2,-1,21);%logspace(-5,-1.4,19);
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
for iepsi = 1:length(epsi_list),
    %
    epsi = epsi_list(iepsi);
    %
    ohm = ohm_flat(equil,epsi);
    %
    dkeparam.coll_mode = 0;% Relativistic Maxwellian background
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if dke_out.residu_f{1}(max([1,find(~isnan(dke_out.residu_f{1}))])) < dkeparam.prec0_f,
        sigma_0(iepsi) = Zcurr.x_0/epsi;
        sigma_0_noconv(iepsi) = NaN;
    else
        sigma_0(iepsi) = NaN;
        sigma_0_noconv(iepsi) = Zcurr.x_0/epsi;
    end        
    pn3 = momentumDKE.pn.^3;
    Xmhu = repmat(momentumDKE.mhu,[length(pn3),1]);
    dZcurrdpn = 2*pi*pn3.*integral_dke_jd(momentumDKE.dmhu,dke_out.XXf0(:,:,1).*Xmhu,2).'./Zmomcoef.gamma;
    ipnmax = find(dZcurrdpn == max(dZcurrdpn));
    if ipnmax < length(pn3),
        Ecmax_0(iepsi) = integral_dke_jd(momentumDKE.dpn,dZcurrdpn.*Zmomcoef.Ec_ref,2)./integral_dke_jd(momentumDKE.dpn,dZcurrdpn,2);
    else
        Ecmax_0(iepsi) = NaN;
    end
    %Ecmax_0(iepsi) = Zmomcoef.Ec_ref(ipnmax);
    %
    dkeparam.coll_mode = 1;% High-velocity limit
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if dke_out.residu_f{1}(max([1,find(~isnan(dke_out.residu_f{1}))])) < dkeparam.prec0_f,
        sigma_1(iepsi) = Zcurr.x_0/epsi;
        sigma_1_noconv(iepsi) = NaN;
    else
        sigma_1(iepsi) = NaN;
        sigma_1_noconv(iepsi) = Zcurr.x_0/epsi;
    end        
    pn3 = momentumDKE.pn.^3;
    Xmhu = repmat(momentumDKE.mhu,[length(pn3),1]);
    dZcurrdpn = 2*pi*pn3.*integral_dke_jd(momentumDKE.dmhu,dke_out.XXf0(:,:,1).*Xmhu,2).'./Zmomcoef.gamma;
    ipnmax = find(dZcurrdpn == max(dZcurrdpn));
    if ipnmax < length(pn3),
        Ecmax_1(iepsi) = integral_dke_jd(momentumDKE.dpn,dZcurrdpn.*Zmomcoef.Ec_ref,2)./integral_dke_jd(momentumDKE.dpn,dZcurrdpn,2);
    else
        Ecmax_1(iepsi) = NaN;
    end
    %Ecmax_1(iepsi) = Zmomcoef.Ec_ref(ipnmax);
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if dke_out.residu_f{1}(max([1,find(~isnan(dke_out.residu_f{1}))])) < dkeparam.prec0_f,
        sigma_2(iepsi) = Zcurr.x_0/epsi;
        sigma_2_noconv(iepsi) = NaN;
    else
        sigma_2(iepsi) = NaN;
        sigma_2_noconv(iepsi) = Zcurr.x_0/epsi;
    end        
    pn3 = momentumDKE.pn.^3;
    Xmhu = repmat(momentumDKE.mhu,[length(pn3),1]);
    dZcurrdpn = 2*pi*pn3.*integral_dke_jd(momentumDKE.dmhu,dke_out.XXf0(:,:,1).*Xmhu,2).'./Zmomcoef.gamma;
    ipnmax = find(dZcurrdpn == max(dZcurrdpn));
    if ipnmax < length(pn3),
        Ecmax_2(iepsi) = integral_dke_jd(momentumDKE.dpn,dZcurrdpn.*Zmomcoef.Ec_ref,2)./integral_dke_jd(momentumDKE.dpn,dZcurrdpn,2);
    else
        Ecmax_2(iepsi) = NaN;
    end
    %Ecmax_2(iepsi) = Zmomcoef.Ec_ref(ipnmax);
    %
end
%
sigma_0_noconv(max(find(~isnan(sigma_0)))) = sigma_0(max(find(~isnan(sigma_0))));
sigma_1_noconv(max(find(~isnan(sigma_1)))) = sigma_1(max(find(~isnan(sigma_1))));
sigma_2_noconv(max(find(~isnan(sigma_2)))) = sigma_2(max(find(~isnan(sigma_2))));
%
sigma_Z1s = 1/100*sqrt(me*qe/10)/(1.65*mu0*e0^2);%Spitzer conductivity (from 'Tokamaks' by J. Wesson, Oxford Science Publication, 3rd Eds., 2004)
%
sigma_Karney_nr_0 = [3.773];
sigma_Karney_nr_1 = [2.837];
sigma_Karney_nr_2 = [7.429];
%
Ecmax_norm_0 = Ecmax_0;%/(mc2*betath.^2);
Ecmax_norm_1 = Ecmax_1;%/(mc2*betath.^2);
Ecmax_norm_2 = Ecmax_2;%/(mc2*betath.^2);
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'Linearized','High v limit','Maxwellian'};
xlim = 10.^[-2,-1];%10.^[-5,0];%
ylim = [0,10];
xlab = 'E/E_D';
ylab = '\sigma';
tit = '';
graph1D_jd(epsi_list,sigma_2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(epsi_list,sigma_1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(epsi_list,sigma_0,1,0,'','','',leg,xlim,ylim,'-','none','g',2,20,gca);
graph1D_jd(epsi_list,sigma_2_noconv,1,0,'','','',NaN,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(epsi_list,sigma_1_noconv,1,0,'','','',NaN,xlim,ylim,'--','none','b',2,20,gca);
graph1D_jd(epsi_list,sigma_0_noconv,1,0,'','','',NaN,xlim,ylim,'--','none','g',2,20,gca);
graph1D_jd(xlim,[sigma_Z1s,sigma_Z1s],1,0,'','','',NaN,xlim,ylim,'-','none','k',0.5,20,gca);
graph1D_jd(xlim,[sigma_Karney_nr_2,sigma_Karney_nr_2],0,0,'','','',NaN,xlim,ylim,'--','none','r',0.5,20,gca);
graph1D_jd(xlim,[sigma_Karney_nr_1,sigma_Karney_nr_1],0,0,'','','',NaN,xlim,ylim,'--','none','b',0.5,20,gca);
graph1D_jd(xlim,[sigma_Karney_nr_0,sigma_Karney_nr_0],0,0,'','','',NaN,xlim,ylim,'--','none','g',0.5,20,gca);
graph1D_jd([1,1]/dkeparam.pnmax_S^2,ylim,0,0,'','','',NaN,xlim,ylim,'--','none','k',2,20,gca);
set(gca,'ytick',[0:2:10])
set(gca,'xtick',[1e-06 1e-5 0.0001 0.001 0.01 0.1 1])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(2,'fig_sigma_epsi','./figures',1)
%
figure(2),clf
%
leg = {'Linearized','High v limit','Maxwellian'};
ylim = [0,200];
xlab = 'E/E_D';
ylab = '<E> (keV)';%'E_{Jmax}/T';
tit = '';
graph1D_jd(epsi_list,Ecmax_norm_2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
%graph1D_jd(epsi_list,Ecmax_norm_1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
%graph1D_jd(epsi_list,Ecmax_norm_0,1,0,'','','',leg,xlim,ylim,'-','none','g',2,20,gca);
set(gca,'ytick',[0:40:200])
set(gca,'xtick',[0.01:0.01:0.1])%set(gca,'xtick',[1e-06 1e-5 0.0001 0.001 0.01 0.1 1])
set(gca,'XTickLabel',['0.01',cell(1,8),'0.1'])%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(2,'fig_Ecmax_epsi','./figures',2)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
