function [ZP0,Zcurr,Znorm,ZXXS,ZYXXD_rf,XxRR_fsav,xMRR_flux,xMRR_tau,xRR_fsav,xne_norm_out,xTe_norm_out,xft_fsav,xfteff_fsav] = fmoments_dke_yp(dkeparam,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,waveparam,radial_mode,Zdelta,XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,ZXXD_rf,ZXXD_rf_tp,ZXXF_rf_tp)
%
%   Calculate moments of the electron distribution function.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC)   (joan.decker@cea.fr)
%
% Calculation of the various moments of the distribution function (density, current, power, bremsstrahlung)
time0 = clock;
%
dke_mode = dkeparam.dke_mode;
bounce_mode = dkeparam.bounce_mode;
temppath = dkeparam.temppath;
%
display_mode = display.display_mode;
%
nr = gridDKE.nr;
npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
nr_dke = gridDKE.nr_dke;
rdke = gridDKE.rdke;
mhu = gridDKE.mhu;
Xdmhumm = gridDKE.Xdmhumm;
Xdmhum = gridDKE.Xdmhum;
Xdmhu = gridDKE.Xdmhu;
Xdmhup = gridDKE.Xdmhup;
Xdmhupp = gridDKE.Xdmhupp;
Xdpnmm = gridDKE.Xdpnmm;
Xdpnm = gridDKE.Xdpnm;
Xdpn = gridDKE.Xdpn;
Xdpnp = gridDKE.Xdpnp;
Xdpnpp = gridDKE.Xdpnpp;
Xmhumm = gridDKE.Xmhumm;
Xmhum = gridDKE.Xmhum;
Xmhu = gridDKE.Xmhu;
Xmhup = gridDKE.Xmhup;
Xmhupp = gridDKE.Xmhupp;
X1mmhu2m = gridDKE.X1mmhu2m;
X1mmhu2 = gridDKE.X1mmhu2;
X1mmhu2p = gridDKE.X1mmhu2p;
Xpnmm = gridDKE.Xpnmm;
Xpnm = gridDKE.Xpnm;
Xpn = gridDKE.Xpn;
Xpnp = gridDKE.Xpnp;
Xpnpp = gridDKE.Xpnpp;
Xpn2m = gridDKE.Xpn2m;
Xpn2 = gridDKE.Xpn2;
Xpn2p = gridDKE.Xpn2p;
xpsin = gridDKE.xpsin;
XXmhu = gridDKE.XXmhu;
XXpn2 = gridDKE.XXpn2;
XXpn = gridDKE.XXpn;
%
pn = gridDKE.pn;
pn2 = gridDKE.pn2;
pn3 = gridDKE.pn3;
xpn = gridDKE.xpn;
xpn2 = gridDKE.xpn2;
xpn3 = gridDKE.xpn3;dpn = gridDKE.dpn;
mhu = gridDKE.mhu;
dmhu = gridDKE.dmhu;
pn2 = gridDKE.pn2;
masku = gridDKE.masku;
maskl = gridDKE.maskl;
ir_display = gridDKE.ir_display_out;
%
xpsin = gridDKE.xpsin;
xrho = gridDKE.xrho;
%
z = Zmomcoef.z;
z2 = Zmomcoef.z2;
xz = Zmomcoef.xz;
xz2 = Zmomcoef.xz2;
gamma = Zmomcoef.gamma;
xgamma = Zmomcoef.xgamma;
sigma = Zmomcoef.sigma;
xsigma = Zmomcoef.xsigma;
J1 = Zmomcoef.J1;
J2 = Zmomcoef.J2;
J3 = Zmomcoef.J3;
J4 = Zmomcoef.J4;
xJ1 = Zmomcoef.xJ1;
xJ2 = Zmomcoef.xJ2;
xJ3 = Zmomcoef.xJ3;
xJ4 = Zmomcoef.xJ4;
XXgamma = Zmomcoef.XXgamma;
%
XXdeltap_imj = Zdelta.XXdeltap_imj; 
XXdeltap_ipj = Zdelta.XXdeltap_ipj;
XXdeltam_ijp = Zdelta.XXdeltam_ijp;
XXdeltam_ijm = Zdelta.XXdeltam_ijm;   
XXdeltap_imjmm = Zdelta.XXdeltap_imjmm;
XXdeltap_imjpp = Zdelta.XXdeltap_imjpp;
XXdeltap_ipjmm = Zdelta.XXdeltap_ipjmm;
XXdeltap_ipjpp = Zdelta.XXdeltap_ipjpp;
XXdeltam_immjm = Zdelta.XXdeltam_immjm;
XXdeltam_ippjm = Zdelta.XXdeltam_ippjm;
XXdeltam_immjp = Zdelta.XXdeltam_immjp;
XXdeltam_ippjp = Zdelta.XXdeltam_ippjp;
%
%
XXlambda_p2m2p2 = Zbouncecoef.XXlambda_p2m2p2;
XXlambda_b_p1m1 = Zbouncecoef.XXlambda_b_p1m1;
XXlambda_b_p2 = Zbouncecoef.XXlambda_b_p2;
XXlambda = Zbouncecoef.XXlambda;
XXheaviside = Zbouncecoef.XXheaviside;
Zmask_f0_t = Zbouncecoef.Zmask_f0_t;
ns_f = Zbouncecoef.ns_f; 
xq = Zbouncecoef.xq;
xqtilde = Zbouncecoef.xqtilde;
xqhat =  Zbouncecoef.xqhat;
xqbar =  Zbouncecoef.xqbar;
Zmask_g = Zbouncecoef.Zmask_g;
ns_g = Zbouncecoef.ns_g;
xftp_norm = mksa.xftp_norm_ref;
%
xB0 = equilDKE.xB0;        
Rp = equilDKE.Rp;
xR0 = equilDKE.xR0;
xBT0 = equilDKE.xBT0;
xZeff = equilDKE.xZeff;
%
betath_ref = mksa.betath_ref;
%
[xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth] = normcoef_dke_yp(mksa,equilDKE,gridDKE);   
%
if nargout == 1,%Only moments for quasilinear iteration are calculated.
%
%   RF fluxes and power
%     
   ZXXS.p0_rf_imj = zeros(npn,nmhu,nr_dke);
   ZXXS.p0_rf_ipj = zeros(npn,nmhu,nr_dke);
   ZXXS.m0_rf_ijm = zeros(npn,nmhu,nr_dke);
   ZXXS.m0_rf_ijp = zeros(npn,nmhu,nr_dke);
%
   ZP0.xy_rf_fsav = zeros(nr_dke,nb);
%
   if dke_mode >= 1
      ZXXS.p0_rf_tp_imj = zeros(npn,nmhu,nr_dke);
      ZXXS.p0_rf_tp_ipj = zeros(npn,nmhu,nr_dke);
      ZXXS.m0_rf_tp_ijm = zeros(npn,nmhu,nr_dke);
      ZXXS.m0_rf_tp_ijp = zeros(npn,nmhu,nr_dke);
%
      ZXXS.p0_rf_g_imj = zeros(npn,nmhu,nr_dke);
      ZXXS.p0_rf_g_ipj = zeros(npn,nmhu,nr_dke);
      ZXXS.m0_rf_g_ijm = zeros(npn,nmhu,nr_dke);
      ZXXS.m0_rf_g_ijp = zeros(npn,nmhu,nr_dke);
%    
      ZP0.xy_rf_tp_fsav = zeros(nr_dke,nb);
      ZP0.xy_rf_g_fsav = zeros(nr_dke,nb);
   end
%
   for iy = ylist_rf,
%
      xyD0_rf = waveparam(:,:,4);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
      XXD0_rf = shiftdim(repmat(xyD0_rf(:,iy),[1,npn,nmhu]),1);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
    %
      ynum = num2str(iy);
%      load([fullfile(temppath,'temp_DQL_'),save_id,'_',ynum,'.mat'],'ZXXD_rf','ZXXD_rf_tp','ZXXF_rf_tp');
%
	  XXDpp_rf_imj = ZXXD_rf.pp_imj.*XXD0_rf;
      XXDpp_rf_ipj = ZXXD_rf.pp_ipj.*XXD0_rf;
      XXDpm_rf_imj = ZXXD_rf.pm_imj.*XXD0_rf;
      XXDpm_rf_ipj = ZXXD_rf.pm_ipj.*XXD0_rf;
      XXFp_rf_imj = zeros(npn,nmhu,nr);
      XXFp_rf_ipj = zeros(npn,nmhu,nr);    
      XXDmm_rf_ijm = ZXXD_rf.mm_ijm.*XXD0_rf; 
      XXDmm_rf_ijp = ZXXD_rf.mm_ijp.*XXD0_rf;
      XXDmp_rf_ijm = ZXXD_rf.mp_ijm.*XXD0_rf;
      XXDmp_rf_ijp = ZXXD_rf.mp_ijp.*XXD0_rf;
      XXFm_rf_ijm = zeros(npn,nmhu,nr);
      XXFm_rf_ijp = zeros(npn,nmhu,nr);
%
%f0 contribution
%
      [XXSp0_rf_imj,XXSp0_rf_ipj,XXSm0_rf_ijm,XXSm0_rf_ijp] = ...
         fluxes_dke_jd(XXDpp_rf_imj(:,:,rdke),XXDpp_rf_ipj(:,:,rdke),XXDpm_rf_imj(:,:,rdke),XXDpm_rf_ipj(:,:,rdke),...
         XXFp_rf_imj(:,:,rdke),XXFp_rf_ipj(:,:,rdke),...
         XXDmm_rf_ijm(:,:,rdke),XXDmm_rf_ijp(:,:,rdke),XXDmp_rf_ijm(:,:,rdke),XXDmp_rf_ijp(:,:,rdke),...
         XXFm_rf_ijm(:,:,rdke),XXFm_rf_ijp(:,:,rdke),...
         XXf0(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
         XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
         XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%
      xP0m_rf_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke))'.*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).^3./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_imj,1),1);       
      xP0p_rf_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke))'.*integral_dke_jd(dmhu,integral_dke_jd(dpnp,XXpnp(:,:,rdke).^3./XXgammap(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_ipj,1),1);       
      ZP0.xy_rf_fsav(:,iy) = (xP0m_rf_fsav + xP0p_rf_fsav)/2;
%
      ZXXS.p0_rf_imj = ZXXS.p0_rf_imj + XXSp0_rf_imj;
      ZXXS.p0_rf_ipj = ZXXS.p0_rf_ipj + XXSp0_rf_ipj;
      ZXXS.m0_rf_ijm = ZXXS.m0_rf_ijm + XXSm0_rf_ijm;
      ZXXS.m0_rf_ijp = ZXXS.m0_rf_ijp + XXSm0_rf_ijp;
%        
      if dke_mode >= 1
         XXDpp_rf_tp_imj = ZXXD_rf_tp.pp_imj.*XXD0_rf(rdke);
         XXDpp_rf_tp_ipj = ZXXD_rf_tp.pp_ipj.*XXD0_rf(rdke);
         XXDpm_rf_tp_imj = ZXXD_rf_tp.pm_imj.*XXD0_rf(rdke);
         XXDpm_rf_tp_ipj = ZXXD_rf_tp.pm_ipj.*XXD0_rf(rdke);
         XXFp_rf_tp_imj = ZXXF_rf_tp.p_imj.*XXD0_rf(rdke);
         XXFp_rf_tp_ipj = ZXXF_rf_tp.p_ipj.*XXD0_rf(rdke);
         XXDmm_rf_tp_ijm = ZXXD_rf_tp.mm_ijm.*XXD0_rf(rdke); 
         XXDmm_rf_tp_ijp = ZXXD_rf_tp.mm_ijp.*XXD0_rf(rdke);
         XXDmp_rf_tp_ijm = ZXXD_rf_tp.mp_ijm.*XXD0_rf(rdke);
         XXDmp_rf_tp_ijp = ZXXD_rf_tp.mp_ijp.*XXD0_rf(rdke);
         XXFm_rf_tp_ijm = ZXXF_rf_tp.m_ijm.*XXD0_rf(rdke);
         XXFm_rf_tp_ijp = ZXXF_rf_tp.m_ijp.*XXD0_rf(rdke);
%
%f0_tp contribution
%
         [XXSp0_rf_tp_imj,XXSp0_rf_tp_ipj,XXSm0_rf_tp_ijm,XXSm0_rf_tp_ijp] = ...
            fluxes_dke_jd(XXDpp_rf_tp_imj,XXDpp_rf_tp_ipj,XXDpm_rf_tp_imj,XXDpm_rf_tp_ipj,...
            XXFp_rf_tp_imj,XXFp_rf_tp_ipj,...
            XXDmm_rf_tp_ijm,XXDmm_rf_tp_ijp,XXDmp_rf_tp_ijm,XXDmp_rf_tp_ijp,...
            XXFm_rf_tp_ijm,XXFm_rf_tp_ijp,...
            XXf0_tp(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
            XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
            XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%            
         ZP0.xy_rf_tp_fsav(:,iy) = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).^3./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_tp_imj,1),1);       
%
         ZXXS.p0_rf_tp_imj = ZXXS.p0_rf_tp_imj + XXSp0_rf_tp_imj;
         ZXXS.p0_rf_tp_ipj = ZXXS.p0_rf_tp_ipj + XXSp0_rf_tp_ipj;
         ZXXS.m0_rf_tp_ijm = ZXXS.m0_rf_tp_ijm + XXSm0_rf_tp_ijm;
         ZXXS.m0_rf_tp_ijp = ZXXS.m0_rf_tp_ijp + XXSm0_rf_tp_ijp;
%
%f0_g contribution
%
         [XXSp0_rf_g_imj,XXSp0_rf_g_ipj,XXSm0_rf_g_ijm,XXSm0_rf_g_ijp] = ...
            fluxes_dke_jd(XXDpp_rf_imj(:,:,rdke),XXDpp_rf_ipj(:,:,rdke),XXDpm_rf_imj(:,:,rdke),XXDpm_rf_ipj(:,:,rdke),...
            XXFp_rf_imj(:,:,rdke),XXFp_rf_ipj(:,:,rdke),...
            XXDmm_rf_ijm(:,:,rdke),XXDmm_rf_ijp(:,:,rdke),XXDmp_rf_ijm(:,:,rdke),XXDmp_rf_ijp(:,:,rdke),...
            XXFm_rf_ijm(:,:,rdke),XXFm_rf_ijp(:,:,rdke),...
            XXf0_g(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
            XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
            XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%    
         ZP0.xy_rf_g_fsav(:,iy) = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).^3./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_g_imj,1),1);       
%
         ZXXS.p0_rf_g_imj = ZXXS.p0_rf_g_imj + XXSp0_rf_g_imj;
         ZXXS.p0_rf_g_ipj = ZXXS.p0_rf_g_ipj + XXSp0_rf_g_ipj;
         ZXXS.m0_rf_g_ijm = ZXXS.m0_rf_g_ijm + XXSm0_rf_g_ijm;
         ZXXS.m0_rf_g_ijp = ZXXS.m0_rf_g_ijp + XXSm0_rf_g_ijp;
      end
   end
%
   ZP0.x_rf_fsav = sum(ZP0.xy_rf_fsav,2)';
   if dke_mode >= 1
      ZP0.x_rf_tp_fsav = sum(ZP0.xy_rf_tp_fsav,2)';
      ZP0.x_rf_g_fsav = sum(ZP0.xy_rf_g_fsav,2)';
   end    
else
%
%   Density
%
Znorm.x_0 = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
Znorm.x_tp = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_tp(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
Znorm.x_g = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_g(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
%
if dkeparam.coll_mode == 3,%Lorentz model (test mode only, see documentation)
    Znorm.x_L_tp = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_tp(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
    Znorm.x_L_g = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_g(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
end 
%
Znorm.x_0_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda(:,:,rdke).*XXf0(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
Znorm.x_tp_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda_b_p1m1(:,:,rdke).*XXf0_tp(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
Znorm.x_g_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda(:,:,rdke).*XXf0_g(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
%
if dkeparam.coll_mode == 3,%Lorentz model (test mode only, see documentation)
    Znorm.x_L_tp_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda_b_p1m1(:,:,rdke).*XXf0_L_tp(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
    Znorm.x_L_g_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda(:,:,rdke).*XXf0_L_g(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
end 
%
% When radial transport is turned off, the distribution function is renormalized before calculating all other
% moments. This makes physical sense since no electron is meant to be lost
% or gained (! still need to include run-away contribution - Yves?)
%
if radial_mode ~= 1,
    xnorm_0_fsav = 2*pi.*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*XXf0.*XXpn2,1),1)';%Same as Znorm.x_0_fsav but at all radius (just for vector calculations in dke_mode=1)
    XXf0 = XXf0.*shiftdim(repmat(xne_norm'./xnorm_0_fsav',[1,npn,nmhu]),1);
end
%
%
xc_g = -(Znorm.x_tp_fsav + Znorm.x_g_fsav)./xne_norm(rdke);%Flux surface averaged density conservation
XXxc_g = shiftdim(repmat(repmat(xc_g(:),[1,npn,1]),[1,1,nmhu]),1);
XXf0_g(:,:,rdke) = XXf0_g(:,:,rdke) + XXxc_g.*XXf0(:,:,rdke);%Normalisation in order to maintain the flux surface averaged density at the right level
%
%   Current
%
Zcurr.x_0 = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
Zcurr.x_tp = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
Zcurr.x_g = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_g(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
Zcurr.x_tot = Zcurr.x_0 + Zcurr.x_tp + Zcurr.x_g;%Total current density
%
if dkeparam.coll_mode == 3,%Lorentz model (test mode only, see documentation)
    Zcurr.x_L_tp = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
    Zcurr.x_L_g = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_g(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
    Zcurr.x_L_tot = Zcurr.x_0 + Zcurr.x_L_tp + Zcurr.x_L_g;%Total current density
end 
%
%   Flux surface averaged current
%
Zcurr.x_0_fsav = 2*pi*(xq(rdke)./xqbar(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0(:,:,rdke).*XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
Zcurr.x_tp_fsav = 2*pi*(xqtilde(rdke)./xqbar(rdke)).*(Rp./xR0(rdke)).*(xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke).*XXlambda_p2m2p2(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
Zcurr.x_g_fsav = 2*pi*(xq(rdke)./xqbar(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_g(:,:,rdke).*XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
Zcurr.x_tot_fsav = Zcurr.x_0_fsav + Zcurr.x_tp_fsav + Zcurr.x_g_fsav;%Total current density
%
if dkeparam.coll_mode == 3,%Lorentz model (test mode only, see documentation)
    Zcurr.x_L_tp_fsav = 2*pi*(xqtilde(rdke)./xqbar(rdke)).*(Rp./xR0(rdke)).*(xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke).*XXlambda_p2m2p2(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
    Zcurr.x_L_g_fsav = 2*pi*(xq(rdke)./xqbar(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_g(:,:,rdke).*XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
    Zcurr.x_L_tot = Zcurr.x_0_fsav + Zcurr.x_L_tp_fsav + Zcurr.x_L_g_fsav;%Total current density
end 
%   
%   Fluxes
%
%   Collisional fluxes and power
%
%f0 contribution
%
[ZXXS.p0_c_imj,ZXXS.p0_c_ipj,ZXXS.m0_c_ijm,ZXXS.m0_c_ijp] = ...
    fluxes_dke_jd(ZXXD_c.pp_imj(:,:,rdke),ZXXD_c.pp_ipj(:,:,rdke),ZXXD_c.pm_imj(:,:,rdke),ZXXD_c.pm_ipj(:,:,rdke),...
    ZXXF_c.p_imj(:,:,rdke),ZXXF_c.p_ipj(:,:,rdke),...
    ZXXD_c.mm_ijm(:,:,rdke),ZXXD_c.mm_ijp(:,:,rdke),ZXXD_c.mp_ijm(:,:,rdke),ZXXD_c.mp_ijp(:,:,rdke),...
    ZXXF_c.m_ijm(:,:,rdke),ZXXF_c.m_ijp(:,:,rdke),...
    XXf0(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
    XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
    XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%    
ZP0.x_c_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*ZXXS.p0_c_imj,1),1)';       
%
if dke_mode >= 1
%
%f0_tp contribution
%
    [ZXXS.p0_c_tp_imj,ZXXS.p0_c_tp_ipj,ZXXS.m0_c_tp_ijm,ZXXS.m0_c_tp_ijp] = ...
        fluxes_dke_jd(ZXXD_c_tp.pp_imj,ZXXD_c_tp.pp_ipj,ZXXD_c_tp.pm_imj,ZXXD_c_tp.pm_ipj,...
        ZXXF_c_tp.p_imj,ZXXF_c_tp.p_ipj,...
        ZXXD_c_tp.mm_ijm,ZXXD_c_tp.mm_ijp,ZXXD_c_tp.mp_ijm,ZXXD_c_tp.mp_ijp,...
        ZXXF_c_tp.m_ijm,ZXXF_c_tp.m_ijp,...
        XXf0_tp(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
        XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
        XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%    
    ZP0.x_c_tp_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*ZXXS.p0_c_tp_imj,1),1)';       
%
%f0_g contribution
%
    [ZXXS.p0_c_g_imj,ZXXS.p0_c_g_ipj,ZXXS.m0_c_g_ijm,ZXXS.m0_c_g_ijp] = ...
        fluxes_dke_jd(ZXXD_c.pp_imj(:,:,rdke),ZXXD_c.pp_ipj(:,:,rdke),ZXXD_c.pm_imj(:,:,rdke),ZXXD_c.pm_ipj(:,:,rdke),...
        ZXXF_c.p_imj(:,:,rdke),ZXXF_c.p_ipj(:,:,rdke),...
        ZXXD_c.mm_ijm(:,:,rdke),ZXXD_c.mm_ijp(:,:,rdke),ZXXD_c.mp_ijm(:,:,rdke),ZXXD_c.mp_ijp(:,:,rdke),...
        ZXXF_c.m_ijm(:,:,rdke),ZXXF_c.m_ijp(:,:,rdke),...
        XXf0_g(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
        XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
        XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%    
    ZP0.x_c_g_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*ZXXS.p0_c_g_imj,1),1)';       
end
%
%   Ohmic fluxes and power
%
%f0 contribution
%
[ZXXS.p0_e_imj,ZXXS.p0_e_ipj,ZXXS.m0_e_ijm,ZXXS.m0_e_ijp] = ...
    fluxes_dke_jd(ZXXD_e.pp_imj(:,:,rdke),ZXXD_e.pp_ipj(:,:,rdke),ZXXD_e.pm_imj(:,:,rdke),ZXXD_e.pm_ipj(:,:,rdke),...
    ZXXF_e.p_imj(:,:,rdke),ZXXF_e.p_ipj(:,:,rdke),...
    ZXXD_e.mm_ijm(:,:,rdke),ZXXD_e.mm_ijp(:,:,rdke),ZXXD_e.mp_ijm(:,:,rdke),ZXXD_e.mp_ijp(:,:,rdke),...
    ZXXF_e.m_ijm(:,:,rdke),ZXXF_e.m_ijp(:,:,rdke),...
    XXf0(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
    XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
    XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
% 
ZP0.x_e_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*ZXXS.p0_e_imj,1),1)';       
%
if dke_mode >= 1
%
%f0_tp contribution
%
    [ZXXS.p0_e_tp_imj,ZXXS.p0_e_tp_ipj,ZXXS.m0_e_tp_ijm,ZXXS.m0_e_tp_ijp] = ...
        fluxes_dke_jd(ZXXD_e_tp.pp_imj,ZXXD_e_tp.pp_ipj,ZXXD_e_tp.pm_imj,ZXXD_e_tp.pm_ipj,...
        ZXXF_e_tp.p_imj,ZXXF_e_tp.p_ipj,...
        ZXXD_e_tp.mm_ijm,ZXXD_e_tp.mm_ijp,ZXXD_e_tp.mp_ijm,ZXXD_e_tp.mp_ijp,...
        ZXXF_e_tp.m_ijm,ZXXF_e_tp.m_ijp,...
        XXf0_tp(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
        XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
        XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%
    ZP0.x_e_tp_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*ZXXS.p0_e_tp_imj,1),1)';       
%
%f0_g contribution
%
    [ZXXS.p0_e_g_imj,ZXXS.p0_e_g_ipj,ZXXS.m0_e_g_ijm,ZXXS.m0_e_g_ijp] = ...
        fluxes_dke_jd(ZXXD_e.pp_imj(:,:,rdke),ZXXD_e.pp_ipj(:,:,rdke),ZXXD_e.pm_imj(:,:,rdke),ZXXD_e.pm_ipj(:,:,rdke),...
        ZXXF_e.p_imj(:,:,rdke),ZXXF_e.p_ipj(:,:,rdke),...
        ZXXD_e.mm_ijm(:,:,rdke),ZXXD_e.mm_ijp(:,:,rdke),ZXXD_e.mp_ijm(:,:,rdke),ZXXD_e.mp_ijp(:,:,rdke),...
        ZXXF_e.m_ijm(:,:,rdke),ZXXF_e.m_ijp(:,:,rdke),...
        XXf0_g(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
        XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
        XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
% 
    ZP0.x_e_g_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*ZXXS.p0_e_g_imj,1),1)';       
end
%
%   RF fluxes and power
%     
ZXXS.p0_rf_imj = zeros(npn,nmhu,nr_dke);
ZXXS.p0_rf_ipj = zeros(npn,nmhu,nr_dke);
ZXXS.m0_rf_ijm = zeros(npn,nmhu,nr_dke);
ZXXS.m0_rf_ijp = zeros(npn,nmhu,nr_dke);
%
ZP0.xy_rf_fsav = zeros(nr_dke,nb);
%
if dke_mode >= 1
    ZXXS.p0_rf_tp_imj = zeros(npn,nmhu,nr_dke);
    ZXXS.p0_rf_tp_ipj = zeros(npn,nmhu,nr_dke);
    ZXXS.m0_rf_tp_ijm = zeros(npn,nmhu,nr_dke);
    ZXXS.m0_rf_tp_ijp = zeros(npn,nmhu,nr_dke);
%
    ZXXS.p0_rf_g_imj = zeros(npn,nmhu,nr_dke);
    ZXXS.p0_rf_g_ipj = zeros(npn,nmhu,nr_dke);
    ZXXS.m0_rf_g_ijm = zeros(npn,nmhu,nr_dke);
    ZXXS.m0_rf_g_ijp = zeros(npn,nmhu,nr_dke);
%    
    ZP0.xy_rf_tp_fsav = zeros(nr_dke,nb);
    ZP0.xy_rf_g_fsav = zeros(nr_dke,nb);
end
%
%  Wave-induced radial transport by adjoint technique (P. Helander model)
%
xX = ones(nr,1)*pn/sqrt(2);
xXG = (erf(xX) - 2*xX.*exp(-xX.^2)/sqrt(pi))./2./xX./xX;
XXnhuDei = permute(repmat(((xrnhuth.*xZeff)'*ones(1,npn)).*((erf(xX) - xXG)./xX./xX./xX),[1,1,nmhu]),[2,3,1]);
%  
xggradpsi22 = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*(xR0(rdke).*xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0(:,:,rdke).*XXnhuDei(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke).*XXlambda_b_p1m1(:,:,rdke),1),1)';
%
xggradpsi1 = 0;
xggradpsi21 = 0;
%
for iy = ylist_rf,
    %
    xyD0_rf = waveparam(:,:,4);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
    XXD0_rf = shiftdim(repmat(xyD0_rf(:,iy),[1,npn,nmhu]),1);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
    %
    ynum = num2str(iy);
    load([fullfile(temppath,'temp_DQL_'),save_id,'_',ynum,'.mat'],'ZXXD_rf','ZXXD_rf_tp','ZXXF_rf_tp');
%
	 XXDpp_rf_imj = ZXXD_rf.pp_imj.*XXD0_rf;
    XXDpp_rf_ipj = ZXXD_rf.pp_ipj.*XXD0_rf;
    XXDpm_rf_imj = ZXXD_rf.pm_imj.*XXD0_rf;
    XXDpm_rf_ipj = ZXXD_rf.pm_ipj.*XXD0_rf;
    XXFp_rf_imj = zeros(npn,nmhu,nr);
    XXFp_rf_ipj = zeros(npn,nmhu,nr);    
    XXDmm_rf_ijm = ZXXD_rf.mm_ijm.*XXD0_rf; 
    XXDmm_rf_ijp = ZXXD_rf.mm_ijp.*XXD0_rf;
    XXDmp_rf_ijm = ZXXD_rf.mp_ijm.*XXD0_rf;
    XXDmp_rf_ijp = ZXXD_rf.mp_ijp.*XXD0_rf;
    XXFm_rf_ijm = zeros(npn,nmhu,nr);
    XXFm_rf_ijp = zeros(npn,nmhu,nr);
%
%
%f0 contribution
%
    [XXSp0_rf_imj,XXSp0_rf_ipj,XXSm0_rf_ijm,XXSm0_rf_ijp] = ...
        fluxes_dke_jd(XXDpp_rf_imj(:,:,rdke),XXDpp_rf_ipj(:,:,rdke),XXDpm_rf_imj(:,:,rdke),XXDpm_rf_ipj(:,:,rdke),...
        XXFp_rf_imj(:,:,rdke),XXFp_rf_ipj(:,:,rdke),...
        XXDmm_rf_ijm(:,:,rdke),XXDmm_rf_ijp(:,:,rdke),XXDmp_rf_ijm(:,:,rdke),XXDmp_rf_ijp(:,:,rdke),...
        XXFm_rf_ijm(:,:,rdke),XXFm_rf_ijp(:,:,rdke),...
        XXf0(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
        XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
        XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%
    xP0m_rf_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke))'.*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).^3./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_imj,1),1);       
    xP0p_rf_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke))'.*integral_dke_jd(dmhu,integral_dke_jd(dpnp,XXpnp(:,:,rdke).^3./XXgammap(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_ipj,1),1);       
    ZP0.xy_rf_fsav(:,iy) = (xP0m_rf_fsav + xP0p_rf_fsav)/2;
%
    ZXXS.p0_rf_imj = ZXXS.p0_rf_imj + XXSp0_rf_imj;
    ZXXS.p0_rf_ipj = ZXXS.p0_rf_ipj + XXSp0_rf_ipj;
    ZXXS.m0_rf_ijm = ZXXS.m0_rf_ijm + XXSm0_rf_ijm;
    ZXXS.m0_rf_ijp = ZXXS.m0_rf_ijp + XXSm0_rf_ijp;
%        
    if dke_mode >= 1
        XXDpp_rf_tp_imj = ZXXD_rf_tp.pp_imj.*XXD0_rf(rdke);
        XXDpp_rf_tp_ipj = ZXXD_rf_tp.pp_ipj.*XXD0_rf(rdke);
        XXDpm_rf_tp_imj = ZXXD_rf_tp.pm_imj.*XXD0_rf(rdke);
        XXDpm_rf_tp_ipj = ZXXD_rf_tp.pm_ipj.*XXD0_rf(rdke);
        XXFp_rf_tp_imj = ZXXF_rf_tp.p_imj.*XXD0_rf(rdke);
        XXFp_rf_tp_ipj = ZXXF_rf_tp.p_ipj.*XXD0_rf(rdke);
        XXDmm_rf_tp_ijm = ZXXD_rf_tp.mm_ijm.*XXD0_rf(rdke); 
        XXDmm_rf_tp_ijp = ZXXD_rf_tp.mm_ijp.*XXD0_rf(rdke);
        XXDmp_rf_tp_ijm = ZXXD_rf_tp.mp_ijm.*XXD0_rf(rdke);
        XXDmp_rf_tp_ijp = ZXXD_rf_tp.mp_ijp.*XXD0_rf(rdke);
        XXFm_rf_tp_ijm = ZXXF_rf_tp.m_ijm.*XXD0_rf(rdke);
        XXFm_rf_tp_ijp = ZXXF_rf_tp.m_ijp.*XXD0_rf(rdke);
%
%  Wave-induced radial transport by adjoint technique (P. Helander model)
%
        XXDmp1_rf_tp_ijp = ZXXD_rf_tp.mp1_ijp.*XXD0_rf(rdke);
        XXDmp1_rf_tp_ij = ZXXD_rf_tp.mp1_ij.*XXD0_rf(rdke);
        XXDmp1_rf_tp_ijm = ZXXD_rf_tp.mp1_ijm.*XXD0_rf(rdke);
        XXDmm1_rf_tp_ijp = ZXXD_rf_tp.mm1_ijp.*XXD0_rf(rdke);
        XXDmm1_rf_tp_ijm = ZXXD_rf_tp.mm1_ijm.*XXD0_rf(rdke);    
%
%f0_tp contribution
%
        [XXSp0_rf_tp_imj,XXSp0_rf_tp_ipj,XXSm0_rf_tp_ijm,XXSm0_rf_tp_ijp] = ...
            fluxes_dke_jd(XXDpp_rf_tp_imj,XXDpp_rf_tp_ipj,XXDpm_rf_tp_imj,XXDpm_rf_tp_ipj,...
            XXFp_rf_tp_imj,XXFp_rf_tp_ipj,...
            XXDmm_rf_tp_ijm,XXDmm_rf_tp_ijp,XXDmp_rf_tp_ijm,XXDmp_rf_tp_ijp,...
            XXFm_rf_tp_ijm,XXFm_rf_tp_ijp,...
            XXf0_tp(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
            XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
            XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%            
        ZP0.xy_rf_tp_fsav(:,iy) = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).^3./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_tp_imj,1),1);       
%
        ZXXS.p0_rf_tp_imj = ZXXS.p0_rf_tp_imj + XXSp0_rf_tp_imj;
        ZXXS.p0_rf_tp_ipj = ZXXS.p0_rf_tp_ipj + XXSp0_rf_tp_ipj;
        ZXXS.m0_rf_tp_ijm = ZXXS.m0_rf_tp_ijm + XXSm0_rf_tp_ijm;
        ZXXS.m0_rf_tp_ijp = ZXXS.m0_rf_tp_ijp + XXSm0_rf_tp_ijp;
%
%f0_g contribution
%
        [XXSp0_rf_g_imj,XXSp0_rf_g_ipj,XXSm0_rf_g_ijm,XXSm0_rf_g_ijp] = ...
            fluxes_dke_jd(XXDpp_rf_imj(:,:,rdke),XXDpp_rf_ipj(:,:,rdke),XXDpm_rf_imj(:,:,rdke),XXDpm_rf_ipj(:,:,rdke),...
            XXFp_rf_imj(:,:,rdke),XXFp_rf_ipj(:,:,rdke),...
            XXDmm_rf_ijm(:,:,rdke),XXDmm_rf_ijp(:,:,rdke),XXDmp_rf_ijm(:,:,rdke),XXDmp_rf_ijp(:,:,rdke),...
            XXFm_rf_ijm(:,:,rdke),XXFm_rf_ijp(:,:,rdke),...
            XXf0_g(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
            XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
            XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%    
        ZP0.xy_rf_g_fsav(:,iy) = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).^3./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_g_imj,1),1);       
%
        ZXXS.p0_rf_g_imj = ZXXS.p0_rf_g_imj + XXSp0_rf_g_imj;
        ZXXS.p0_rf_g_ipj = ZXXS.p0_rf_g_ipj + XXSp0_rf_g_ipj;
        ZXXS.m0_rf_g_ijm = ZXXS.m0_rf_g_ijm + XXSm0_rf_g_ijm;
        ZXXS.m0_rf_g_ijp = ZXXS.m0_rf_g_ijp + XXSm0_rf_g_ijp;
%
%   Wave-induced radial transport by adjoint technique (P. Helander model)
%
        [XXp_rf_imj,XXp_rf_ipj,XXm_rf_ijm,XXm_rf_ijp] = ...
            fluxes_dke_jd(XXDpp_rf_tp_imj,XXDpp_rf_tp_ipj,XXDpm_rf_tp_imj,XXDpm_rf_tp_ipj,...
            0*XXFp_rf_tp_imj,0*XXFp_rf_tp_ipj,...
            XXDmm1_rf_tp_ijm,XXDmm1_rf_tp_ijp,XXDmp1_rf_tp_ijm,XXDmp1_rf_tp_ijp,...
            0*XXFm_rf_tp_ijm,0*XXFm_rf_tp_ijp,...
            XXf0(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke,:),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
            XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
            XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%
        xggradpsi21 = xggradpsi21(it,:) + 2*pi*(xqtilde(rdke)./xqhat(rdke)).*(xR0(rdke).*xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXp_rf_imj(:,:,rdke).*XXpn2m(:,:,rdke).*XXmhu(:,:,rdke).*XXlambda(:,:,rdke),1),1)';
        xggradpsi1 = xggradpsi1(it,:) + 2*pi*(xqtilde(rdke)./xqhat(rdke)).*(xR0(rdke).*xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhum,integral_dke_jd(dpn,XXm_rf_ijm(:,:,rdke).*XXpn2(:,:,rdke).*XX1mmhu2m(:,:,rdke).*XXlambda(:,:,rdke).*XXRlambda_m(:,:,rdke),1),1)';
    end
end
%
ZP0.x_rf_fsav = sum(ZP0.xy_rf_fsav,2)';
if dke_mode >= 1
    ZP0.x_rf_tp_fsav = sum(ZP0.xy_rf_tp_fsav,2)';
    ZP0.x_rf_g_fsav = sum(ZP0.xy_rf_g_fsav,2)';
end
%
XXSp0_imj = ZXXS.p0_c_imj + ZXXS.p0_e_imj + ZXXS.p0_rf_imj;
XXSm0_ijm = ZXXS.m0_c_ijm + ZXXS.m0_e_ijm + ZXXS.m0_rf_ijm;
XXSp0_ipj = ZXXS.p0_c_ipj + ZXXS.p0_e_ipj + ZXXS.p0_rf_ipj;
XXSm0_ijp = ZXXS.m0_c_ijp + ZXXS.m0_e_ijp + ZXXS.m0_rf_ijp;
%
%   Wave-induced radial transport by adjoint technique (P. Helander model)
%
if nb > 0,
	 xggradpsi = xggradpsi1 - xggradpsi21 - xggradpsi22;
     xVr = xggradpsi.*xR0(rdke).*xBp0(rdke)./xne_norm(rdke);
     ZWiTransp_fsav{1} = xggradpsi;%For all rays
	 ZWiTransp_fsav{2} = xggradpsi1;%For all rays
	 ZWiTransp_fsav{3} = xggradpsi21;%For all rays
	 ZWiTransp_fsav{4} = xggradpsi22;%For all rays
else
	 xggradpsi = zeros(length(rdke),1);
     xVr = zeros(length(rdke),1);
     ZWiTransp_fsav{1} = zeros(length(rdke),1);%For all rays
	 ZWiTransp_fsav{2} = zeros(length(rdke),1);%For all rays
	 ZWiTransp_fsav{3} = zeros(length(rdke),1);%For all rays
	 ZWiTransp_fsav{4} = zeros(length(rdke),1);%For all rays
end		
%
% Run-away loss rate (Primary and secondary (avalanche) generation)
%
xepsi_rdke = xepsi(rdke);
Xxqtilde = repmat(xqtilde,npn,1);
Xxqhat = repmat(xqtilde,npn,1);
XxRR_fsav = 2*pi*(Xxqtilde(:,rdke)./Xxqhat(:,rdke)).*integral_dke_jd(dmhu,XXSp0_imj.*XXpn2m(:,:,rdke).*XXlambda(:,:,rdke),2);%Primary generation run-away rate (Dreicer field effect)
xRR_primary_fsav = XxRR_fsav(end,:);%Radial profile of primary runaway electron generation rate
%
mask_xepsi = find(xepsi_rdke~=0);
if ~isempty(mask_xepsi)
    Zcurr.x_B_fsav = Zcurr.x_tot_fsav - 0.5*XxRR_fsav(npn-1,mask_xepsi)*max(v2)./xepsi_rdke(mask_xepsi);%Bulk current as defined by Karney (useful for non-zero large dc electric field only)
else
    Zcurr.x_B_fsav = Zcurr.x_tot_fsav;
end 
%
% Knock-on runaway generation
%
pnminRR = 2;%
zminRR = betath_ref*pnminRR;
zminRR2 = zminRR.*zminRR;
gammaminRR = sqrt(1 + zminRR2);
xRR_secondary_fsav = 1/(gammaminRR-1)*pi*xnloss(rdke).*xrnhuth(rdke)./xlnc_e(rdke);
%
xRR_fsav = xRR_primary_fsav + xRR_secondary_fsav;%Runaway rate profile (primary + secondary contribution)
%
Xxf0 = 0.5*integral_dke_jd(dmhu,XXf0(:,:,rdke),2);
XxfM = squeeze(XXfM(:,1,rdke));
Xxpn = repmat(pn',[1,nr_dke]);
Xxv = repmat(v',[1,nr_dke]);
%
xvth20 = 4*pi*integral_dke_jd(dpn,Xxpn.*Xxpn.*Xxv.*Xxv.*Xxf0,1)'/3;
xvth2M = 4*pi*integral_dke_jd(dpn,Xxpn.*Xxpn.*Xxv.*Xxv.*XxfM,1)'/3;
xTe_out_norm = (xvth20./xvth2M).*xTe_norm(rdke);%New bulk temperature (bulk heating)
%
%Exact trapped fraction (not the effective trapped fraction that rely on simplified plasma modeling with Maxwellian background)
%
if bounce_mode == 0,
    xft_fsav= zeros(1,nr_dke);%Fraction of trapped electrons
elseif bounce_mode == 1,
    xne_trap_fsav = integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXf0(:,:,rdke) + XXf0_g(:,:,rdke)).*~XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXlambda(:,:,rdke),1),1)';%trapped region only
    xne_tot_fsav = integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXf0(:,:,rdke) + XXf0_tp(:,:,rdke) + XXf0_g(:,:,rdke)).*XXpn2(:,:,rdke).*XXlambda(:,:,rdke),1),1)';%
    xft_fsav = xne_trap_fsav./xne_tot_fsav;
end
%
%Effective trapped fraction 
%
if bounce_mode == 0,
    xfteff_fsav= zeros(1,nr_dke);%Effective fraction of trapped electrons
elseif bounce_mode == 1,
    xfteff_fsav = 1.5*(xBT0(rdke)./xB0(rdke)).*((xqtilde(rdke)./xqbar(rdke)).*(xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,XXmhu(1,:,rdke).*XXmhu(1,:,rdke).*XXlambda_p2m2p2(1,:,rdke),2));    
    xfteff_fsav = xfteff_fsav - 1.5*(xBT0(rdke)./xB0(rdke)).*((xq(rdke)./xqbar(rdke)).*(xR0(rdke)/Rp).*integral_dke_jd(dmhu,abs(XXmhu(1,:,rdke)).*XXheaviside(1,:,rdke).*abs(XXILor(1,:,rdke)),2));
end
%
%   Magnetic ripple loss rate calculation (for Tore Supra tokamak only)
%   Volume or surface loss calculations must match if no additional source term 
%   is added (XXlossripple = XXsource). Otherwise, only the surface loss must be considered
%
if sum(sum(sum(XXlossripple))) ~= 0 & isempty(findstr(tokname,'TS')) == 0,
    xMRR_tau = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlossripple(:,:,rdke).*XXf0(:,:,rdke).*XXpn2(:,:,rdke).*XXlambda(:,:,rdke),1),1)';%Flux of electrons leaving the plasma through the loss cone
%
    XXmaskMRR_im = [zeros(1,nmhu,nr);abs(diff(XXlossripple~=0))];%Mask in p (only nhuloss ~=0 is considered)
    XXmaskMRR_jm = [zeros(npn,1,nr),abs(permute(diff(permute(XXlossripple~=0,[2,1,3])),[2,1,3]))];%Mask in mhu (mhu < 0 only because of symmetry) (only nhuloss ~=0 is considered)
    XXmaskMRR_jm(:,mhu>0,:)=0;%mhu < 0 only because of symmetry)
    XxMRR_flux_p = 2*pi*integral_dke_jd(dmhum,XXmaskMRR_im(:,:,rdke).*XXSp0_imj.*XXpn2m(:,:,rdke).*XXlambda(:,:,rdke).*XXRlambda_m(:,:,rdke),2);
    XxMRR_flux_mhu = 2*2*pi*integral_dke_jd(dpnm,XXmaskMRR_jm(:,:,rdke).*XXSm0_ijm.*XXpnm(:,:,rdke).*sqrt(XX1mmhu2m(:,:,rdke)).*XXlambda(:,:,rdke).*XXRlambda_m(:,:,rdke),1);
    xMRR_flux_p = XxMRR_flux_p(XxMRR_flux_p~=0)';
    xMRR_flux_mhu = XxMRR_flux_mhu(XxMRR_flux_mhu~=0)';
    xMRR_flux = xMRR_flux_p - xMRR_flux_mhu;%Reduce number of points since only nhuloss ~=0 is considered
    xMRR_flux =[xMRR_tau(find(xMRR_tau==0)),xMRR_flux];%Restore the points for nhuloss =0   
else
    xMRR_tau = NaN*ones(1,nr_dke);
    xMRR_flux = NaN*ones(1,nr_dke);
end
%
%Integral of the source term
%
xne_norm_out = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXsinksource(:,:,rdke).*XXpn2(:,:,rdke).*XXlambda(:,:,rdke),1),1)';%Flux of electrons leaving the plasma through the loss cone
%
if display_mode >= 1,info_dke_yp(2,['Moments of the distribution function calculated in ',num2str(etime(clock,time0)),' (s)']);end
end
%
