%script test_kineticdisp_jd
%
close all
clear all
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
nx = 101;
ixc = (nx + 1)/2;
%
guess_mode = 1;
opt_mode = 1;%(0) all (-1) m (1) p
%
omega_rf = [4.0]*2*pi*1e9;%wave frequency (rad/s)
Npar = 2;%parallel index of refraction
%
ne = 1e20;%electron density (m^-3)
Bfield = 5.0;%magnetic field (T)
Te = mc2*0.01;%electron temperature (keV)
%
zZi = [1,1,1];%ion charges
zmi = [1,2,3];%ion masses
zfi = [0,1,0];
%
ns = 1 + length(zZi);
%
ne_min = 0;ne_max = 0.02e20;xne = linspace(ne_min,ne_max,nx);xdisp = xne;xlab = 'n_e';xlim = [ne_min,ne_max];%xne = ne*ones(1,nx);%
xBfield = Bfield*ones(1,nx);%
xTe = Te*ones(1,nx);%Te_min = mc2*0.0001;Te_max = mc2*0.02;xTe = linspace(Te_min,Te_max,nx);xdisp = xTe;xlab = 'T_e';xlim = [Te_min,Te_max];%
%
xTi = xTe;%
%
xNpar = Npar*ones(1,nx);
%
zxni = zfi(:)*xne;
zxTi = ones(ns-1,1)*xTi;
%
sxn = [xne;zxni];
sxT = [xTe;zxTi];
%
sm = [me;mp*zmi(:)];
sq = qe*[-1;zZi(:)];
%
sxq = repmat(sq,[1,nx]);
sxm = repmat(sm,[1,nx]);
%
sxmc2 = mc2*sxm/me;
%
sxwp = sqrt(sxn.*sxq.^2/e0./sxm);
%
sxBfield = ones(ns,1)*xBfield;
sxwc = sxq.*sxBfield./sxm;
%
sxa = (sxwp/omega_rf).^2;
sxy = sxwc/omega_rf;
%
sxbeta = sqrt(sxT./sxmc2);
%
xNperpp_c = zeros(1,nx);
xNperpm_c = zeros(1,nx);
xep_c_xyz = zeros(3,nx);
xem_c_xyz = zeros(3,nx);
xep_c_pmz = zeros(3,nx);
xem_c_pmz = zeros(3,nx);
xep_c_pyk = zeros(3,nx);
xem_c_pyk = zeros(3,nx);
xphip_c_xyz = zeros(3,nx);
xphim_c_xyz = zeros(3,nx);
xphip_c_pmz = zeros(3,nx);
xphim_c_pmz = zeros(3,nx);
xphip_c_pyk = zeros(3,nx);
xphim_c_pyk = zeros(3,nx);
%
if opt_mode >= 0,
%
    xNperpp_k_ft = zeros(1,nx);
    xep_k_ft_xyz = zeros(3,nx);
    xep_k_ft_pmz = zeros(3,nx);
    xep_k_ft_pyk = zeros(3,nx);
    %
    xNperpp_k_ht = zeros(1,nx);
    xep_k_ht_xyz = zeros(3,nx);
    xep_k_ht_pmz = zeros(3,nx);
    xep_k_ht_pyk = zeros(3,nx);
    xalphaphi_lin_p_k = zeros(1,nx);
    xphiTp_k_xyz = zeros(3,nx);
    xphiPp_k_xyz = zeros(3,nx);
    xphiTp_k_pmz = zeros(3,nx);
    xphiPp_k_pmz = zeros(3,nx);
    xphiTp_k_pyk = zeros(3,nx);
    xphiPp_k_pyk = zeros(3,nx);
%
end
%
if opt_mode <= 0,
%
    xNperpm_k_ft = zeros(1,nx);
    xem_k_ft_xyz = zeros(3,nx);
    xem_k_ft_pmz = zeros(3,nx);
    xem_k_ft_pyk = zeros(3,nx);
    %
    xNperpm_k_ht = zeros(1,nx);
    xem_k_ht_xyz = zeros(3,nx);
    xem_k_ht_pmz = zeros(3,nx);
    xem_k_ht_pyk = zeros(3,nx);
    xalphaphi_lin_m_k = zeros(1,nx);
    xphiTm_k_xyz = zeros(3,nx);
    xphiPm_k_xyz = zeros(3,nx);
    xphiTm_k_pmz = zeros(3,nx);
    xphiPm_k_pmz = zeros(3,nx);
    xphiTm_k_pyk = zeros(3,nx);
    xphiPm_k_pyk = zeros(3,nx);
%
end
%
for ix = 1:nx,
    %
    [xNperpp_c(ix),xNperpm_c(ix),Kxyz,xep_c_xyz(:,ix),xem_c_xyz(:,ix),xep_c_pmz(:,ix),xem_c_pmz(:,ix),xep_c_pyk(:,ix),xem_c_pyk(:,ix),...
        xphip_c_xyz(:,ix),xphim_c_xyz(:,ix),xphip_c_pmz(:,ix),xphim_c_pmz(:,ix),xphip_c_pyk(:,ix),xphim_c_pyk(:,ix)]...
        = colddisp_dke_jd(xNpar(ix),omega_rf,xne(ix),zxni(:,ix),zZi,zmi,xBfield(ix));
    %
end
%
wb = waitbar(0,'dispersion calculations');
%
% first range
%
for ix = ixc:nx,
    %
    % for the p wave
    %
    %
    if opt_mode >= 0,
        %
        if guess_mode == 0 | ix == ixc | isnan(xNperpp_k_ft(ix-1)),
            xNperp_guess = xNperpp_c(ix);
        else
            xNperp_guess = xNperpp_k_ft(ix-1);
        end
        [xNperpp_k_ft(ix),xep_k_ft_xyz(:,ix),xep_k_ft_pmz(:,ix),xep_k_ft_pyk(:,ix)]...
            = kineticdisp_jd(sxa(:,ix),sxy(:,ix),sxbeta(:,ix),xNpar(ix),xNperp_guess,0);
        %
        if guess_mode == 0 | ix == ixc | isnan(xNperpp_k_ht(ix-1)),
            xNperp_guess = xNperpp_c(ix);
        else
            xNperp_guess = xNperpp_k_ht(ix-1);
        end
        [xNperpp_k_ht(ix),xep_k_ht_xyz(:,ix),xep_k_ht_pmz(:,ix),xep_k_ht_pyk(:,ix),D,X,X_s,X_sn,...
                  xalphaphi_lin_p_k(ix),xphiTp_k_xyz(:,ix),xphiPp_k_xyz(:,ix),xphiTp_k_pmz(:,ix),...
                  xphiPp_k_pmz(:,ix),xphiTp_k_pyk(:,ix),xphiPp_k_pyk(:,ix)]...
            = kineticdisp_jd(sxa(:,ix),sxy(:,ix),sxbeta(:,ix),xNpar(ix),xNperp_guess,1);
        %
    end
    %
    % for the m wave
    %
    if opt_mode <= 0,
        %
        if guess_mode == 0 | ix == ixc | isnan(xNperpm_k_ft(ix-1)),
            xNperp_guess = xNperpm_c(ix);
        else
            xNperp_guess = xNperpm_k_ft(ix-1);
        end
        [xNperpm_k_ft(ix),xem_k_ft_xyz(:,ix),xem_k_ft_pmz(:,ix),xem_k_ft_pyk(:,ix)]...
            = kineticdisp_jd(sxa(:,ix),sxy(:,ix),sxbeta(:,ix),xNpar(ix),xNperp_guess,0);
        %
        if guess_mode == 0 | ix == ixc | isnan(xNperpm_k_ht(ix-1)),
            xNperp_guess = xNperpm_c(ix);
        else
            xNperp_guess = xNperpm_k_ht(ix-1);
        end
        [xNperpm_k_ht(ix),xem_k_ht_xyz(:,ix),xem_k_ht_pmz(:,ix),xem_k_ht_pyk(:,ix),D,X,X_s,X_sn,...
                  xalphaphi_lin_m_k(ix),xphiTm_k_xyz(:,ix),xphiPm_k_xyz(:,ix),xphiTm_k_pmz(:,ix),...
                  xphiPm_k_pmz(:,ix),xphiTm_k_pyk(:,ix),xphiPm_k_pyk(:,ix)]...
            = kineticdisp_jd(sxa(:,ix),sxy(:,ix),sxbeta(:,ix),xNpar(ix),xNperp_guess,1);
    end
    %
    waitbar((ix-ixc)/nx,wb);
    %
end
%
% second range
%
for ix = ixc:-1:1,
    %
    % for the p wave
    %
    if opt_mode >= 0,
        %
        if guess_mode == 0 | ix == ixc | isnan(xNperpp_k_ft(ix+1)),
            xNperp_guess = xNperpp_c(ix);
        else
            xNperp_guess = xNperpp_k_ft(ix+1);
        end
        [xNperpp_k_ft(ix),xep_k_ft_xyz(:,ix),xep_k_ft_pmz(:,ix),xep_k_ft_pyk(:,ix)]...
            = kineticdisp_jd(sxa(:,ix),sxy(:,ix),sxbeta(:,ix),xNpar(ix),xNperp_guess,0);
        %
        if guess_mode == 0 | ix == ixc | isnan(xNperpp_k_ht(ix+1)),
            xNperp_guess = xNperpp_c(ix);
        else
            xNperp_guess = xNperpp_k_ht(ix+1);
        end
        [xNperpp_k_ht(ix),xep_k_ht_xyz(:,ix),xep_k_ht_pmz(:,ix),xep_k_ht_pyk(:,ix),D,X,X_s,X_sn,...
                  xalphaphi_lin_p_k(ix),xphiTp_k_xyz(:,ix),xphiPp_k_xyz(:,ix),xphiTp_k_pmz(:,ix),...
                  xphiPp_k_pmz(:,ix),xphiTp_k_pyk(:,ix),xphiPp_k_pyk(:,ix)]...
            = kineticdisp_jd(sxa(:,ix),sxy(:,ix),sxbeta(:,ix),xNpar(ix),xNperp_guess,1);
        %
    end
    %
    %
    % for the m wave
    %
    if opt_mode <= 0,
        %
        if guess_mode == 0 | ix == ixc | isnan(xNperpm_k_ft(ix+1)),
            xNperp_guess = xNperpm_c(ix);
        else
            xNperp_guess = xNperpm_k_ft(ix+1);
        end
        [xNperpm_k_ft(ix),xem_k_ft_xyz(:,ix),xem_k_ft_pmz(:,ix),xem_k_ft_pyk(:,ix)]...
            = kineticdisp_jd(sxa(:,ix),sxy(:,ix),sxbeta(:,ix),xNpar(ix),xNperp_guess,0);
        %
        if guess_mode == 0 | ix == ixc | isnan(xNperpm_k_ht(ix+1)),
            xNperp_guess = xNperpm_c(ix);
        else
            xNperp_guess = xNperpm_k_ht(ix+1);
        end
        [xNperpm_k_ht(ix),xem_k_ht_xyz(:,ix),xem_k_ht_pmz(:,ix),xem_k_ht_pyk(:,ix),D,X,X_s,X_sn,...
                  xalphaphi_lin_m_k(ix),xphiTm_k_xyz(:,ix),xphiPm_k_xyz(:,ix),xphiTm_k_pmz(:,ix),...
                  xphiPm_k_pmz(:,ix),xphiTm_k_pyk(:,ix),xphiPm_k_pyk(:,ix)]...
            = kineticdisp_jd(sxa(:,ix),sxy(:,ix),sxbeta(:,ix),xNpar(ix),xNperp_guess,1);
        %
    end
    %
    waitbar((nx - ix + 1)/nx,wb);
    %
end
%
%
close(wb)
clear Kxyz D X X_s X_sn xNperp_guess
%
% display results
%
style1 = '-';
style2 = '--';
marker1 = 'none';
marker2 = '.';
marker3 = 'o';
color0 = NaN;
color1 = 'r';
color2 = 'b';
color3 = 'm';
color4 = 'g';
color5 = 'k';
width1 = 2;
width2 = 0.5;
siz = 20;
red = 0.9;
lspace = 0.7;
bspace = 0.7;
%
if opt_mode >= 0,
    %
    xphip_k_xyz = xphiTp_k_xyz + xphiPp_k_xyz;
    xNperpp_k_ht_im = xalphaphi_lin_p_k./xphip_k_xyz(1,:)/2;
    %
    figure(1),clf
    %
    ylim = NaN;
    ylab = 'Re(N_{\perp})';
    %
    tit = 'p wave';
    leg = ['Cold      ';...
           'Kinetic FT';...
           'Kinetic HT'];
    %
    graph1D_jd(xdisp,[real(xNperpp_c);real(xNperpp_k_ft);real(xNperpp_k_ht)],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    ylim = get(gca,'ylim');
    ylim(1) = 0;
    set(gca,'ylim',ylim);
    %
    figure(2),clf
    %
    ylim = [-ylim(2),0];
    ylab = 'Im(N_{\perp})';
    %
    graph1D_jd(xdisp,[imag(xNperpp_c);imag(xNperpp_k_ft);real(xNperpp_k_ht_im)],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %
    figure(3),clf
    %
    ylim = [0,1];
    ylab = '|e_x|';
    %
    graph1D_jd(xdisp,[abs(xep_c_xyz(1,:));abs(xep_k_ft_xyz(1,:));abs(xep_k_ht_xyz(1,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %
    figure(4),clf
    %
    ylab = '|e_y|';
    %
    graph1D_jd(xdisp,[abs(xep_c_xyz(2,:));abs(xep_k_ft_xyz(2,:));abs(xep_k_ht_xyz(2,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %
    figure(5),clf
    %
    ylab = '|e_z|';
    %
    graph1D_jd(xdisp,[abs(xep_c_xyz(3,:));abs(xep_k_ft_xyz(3,:));abs(xep_k_ht_xyz(3,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %
    figure(6),clf
    %
    ylim = NaN;
    ylab = 'S_x';
    %
    leg = ['Cold     ';...
           'Kinetic P';...
           'Kinetic T'];
    %
    graph1D_jd(xdisp,[real(xphip_c_xyz(1,:));real(xphiPp_k_xyz(1,:));real(xphiTp_k_xyz(1,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    ylim = get(gca,'ylim');
    ylim(2) = 0;
    set(gca,'ylim',ylim);
    %
    figure(7),clf
    %
    ylim = NaN;
    ylab = 'S_y';
    %
    graph1D_jd(xdisp,[real(xphip_c_xyz(2,:));real(xphiPp_k_xyz(2,:));real(xphiTp_k_xyz(2,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %ylim = get(gca,'ylim');
    %ylim(1) = 0;
    %set(gca,'ylim',ylim);
    %
    figure(8),clf
    %
    ylim = NaN;
    ylab = 'S_z';
    %
    graph1D_jd(xdisp,[real(xphip_c_xyz(3,:));real(xphiPp_k_xyz(3,:));real(xphiTp_k_xyz(3,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    ylim = get(gca,'ylim');
    ylim(1) = 0;
    set(gca,'ylim',ylim);
    %
end
%
if opt_mode <= 0,
    %
    xphim_k_xyz = xphiTm_k_xyz + xphiPm_k_xyz;
    xNperpm_k_ht_im = xalphaphi_lin_m_k./xphim_k_xyz(1,:)/2;
    %
    figure(11),clf
    %
    ylim = NaN;
    ylab = 'Re(N_{\perp})';
    %
    tit = 'm wave';
    leg = ['Cold      ';...
           'Kinetic FT';...
           'Kinetic HT'];
    %
    graph1D_jd(xdisp,[real(xNperpm_c);real(xNperpm_k_ft);real(xNperpm_k_ht)],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    ylim = get(gca,'ylim');
    ylim(1) = 0;
    set(gca,'ylim',ylim);
    %
    figure(12),clf
    %
    ylab = 'Im(N_{\perp})';
    %
    graph1D_jd(xdisp,[imag(xNperpm_c);imag(xNperpm_k_ft);real(xNperpm_k_ht_im)],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %
    figure(13),clf
    %
    ylim = [0,1];
    ylab = '|e_x|';
    %
    graph1D_jd(xdisp,[abs(xem_c_xyz(1,:));abs(xem_k_ft_xyz(1,:));abs(xem_k_ht_xyz(1,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %
    figure(14),clf
    %
    ylab = '|e_y|';
    %
    graph1D_jd(xdisp,[abs(xem_c_xyz(2,:));abs(xem_k_ft_xyz(2,:));abs(xem_k_ht_xyz(2,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %
    figure(15),clf
    %
    ylab = '|e_z|';
    %
    graph1D_jd(xdisp,[abs(xem_c_xyz(3,:));abs(xem_k_ft_xyz(3,:));abs(xem_k_ht_xyz(3,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %
    figure(16),clf
    %
    ylim = NaN;
    ylab = 'S_x';
    %
    leg = ['Cold     ';...
           'Kinetic P';...
           'Kinetic T'];
    %
    graph1D_jd(xdisp,[real(xphim_c_xyz(1,:));real(xphiPm_k_xyz(1,:));real(xphiTm_k_xyz(1,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    ylim = get(gca,'ylim');
    ylim(1) = 0;
    set(gca,'ylim',ylim);
    %
    figure(17),clf
    %
    ylim = NaN;
    ylab = 'S_y';
    %
    graph1D_jd(xdisp,[real(xphim_c_xyz(2,:));real(xphiPm_k_xyz(2,:));real(xphiTm_k_xyz(2,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    %ylim = get(gca,'ylim');
    %ylim(1) = 0;
    %set(gca,'ylim',ylim);
    %
    figure(18),clf
    %
    ylim = NaN;
    ylab = 'S_z';
    %
    graph1D_jd(xdisp,[real(xphim_c_xyz(3,:));real(xphiPm_k_xyz(3,:));real(xphiTm_k_xyz(3,:))],0,0,xlab,ylab,tit,leg,xlim,ylim,style1,marker1,color0,width1,siz,gca,red,lspace,bspace);
    ylim = get(gca,'ylim');
    ylim(1) = 0;
    set(gca,'ylim',ylim);
    %
end    
        
        