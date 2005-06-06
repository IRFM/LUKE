function [nb,XXD_rf_ij,XXD_rf_tp_ij,XXF_rf_tp_ij,...
    XXDpp_rf_ippj,XXDpp_rf_ipj,XXDpp_rf_ij,XXDpp_rf_imj,XXDpp_rf_immj,...
	 XXDpm_rf_ipj,XXDpm_rf_ij,XXDpm_rf_imj,XXDmp_rf_ijp,XXDmp_rf_ij,XXDmp_rf_ijm,...
	 XXDmm_rf_ijp,XXDmm_rf_ijm,...
	 XXDpp_rf_tp_ippj,XXDpp_rf_tp_ipj,XXDpp_rf_tp_ij,XXDpp_rf_tp_imj,XXDpp_rf_tp_immj,...
	 XXDpm_rf_tp_ipj,XXDpm_rf_tp_ij,XXDpm_rf_tp_imj,XXDmp_rf_tp_ijp,XXDmp_rf_tp_ij,XXDmp_rf_tp_ijm,...
	 XXDmm_rf_tp_ijp,XXDmm_rf_tp_ijm,...
	 XXFp_rf_tp_ippj,XXFp_rf_tp_ipj,XXFp_rf_tp_ij,XXFp_rf_tp_imj,XXFp_rf_tp_immj,XXFm_rf_tp_ijp,XXFm_rf_tp_ijm,...
	 XXDmp1_rf_tp_ijp,XXDmp1_rf_tp_ij,XXDmp1_rf_tp_ijm,XXDmm1_rf_tp_ijp,XXDmm1_rf_tp_ijm] = rfdiff_dke_jd(it_rf,Dqlmax,waveparam,nmax_rf,...
    theta,XR,XZ,XBR,XBZ,XBphi,xB0,Rp,Zp,xqtilde,...
    XXheaviside,XXheaviside_p,XXheaviside_m,... 
    Xmhup,Xmhu,Xmhum,Xmhu2p,Xmhu2,Xmhu2m,X1mmhu2p,X1mmhu2,X1mmhu2m,...
	 Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
    pnpp,pnp,pn,pnm,pnmm,Xpnpp,Xpnp,Xpn,Xpnm,Xpnmm,...
	 Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
    Xgammapp,Xgammap,Xgamma,Xgammam,Xgammamm,...
    Xxlambdap,Xxlambda,Xxlambdam,...
    betath_ref,temppath,bounce_mode,dke_mode,display_mode)
%
% Calculates the RF quasilinear diffusion coefficient and the diffusion tensor elements 
% on a 4-D Grid: 2-D (p,mhu) in momentum; 1-D (rho) in space; 1-D for the series of RF rays.
%
% INPUTS:
%
%       - waveparam:        RF wave parameters (See detailed description below in code)
%                           waveparam may be build by the test function rfwave_dke_jd.m or by an independent ray-tracing code
%       - xrho...Xmhu...pn: grid variables
%       - Xgamma...:        relativistic factor
%       - Xxlambda...:      normalized bounce time
%       - xq:               safety factor
%       - betath_ref:       sqrt(Te_ref/mc2)
%       - Rp_norm:          Rp/ap
%       - bounce_mode:       bounce averaged calculation: (0) OFF, (1) ON
%
% OUTPUTS:
%   
%       - nb: number of effective rays
%       - QL diffusion tensor elements
%
% NOTE:
%
%   the first characters of a variable name are related to its structure:
%       - x_    1-D radial (rho)
%       - X_    2-D momentum (p,mhu) 
%       - Xx_   1-D momentum + 1-D radial (mhu,rho)
%       - xy_   1-D radial + 1-D ray number (rho,b)
%       - XX_   2-D momentum + 1-D radial (p,mhu,rho)
%       - YXX_  2-D momentum + 1-D radial + 1-D ray number (p,mhu,rho,b)
%
%   refer to documentation for detailed description    
%
% by J. Decker (MIT/RLE) <jodecker@mit.edu> and Y. Peysson CEA/DRFC <yves.peysson@cea.fr>
%
%
[qe,me] = pc_dke_yp;%Universal physics constant
%
[npn,nmhu] = size(Xpn);
nr = length(xB0);
nb = size(waveparam,2);
%
XXDpp_rf_ippj = zeros(npn,nmhu,nr);
XXDpp_rf_ipj = zeros(npn,nmhu,nr);
XXDpp_rf_ij = zeros(npn,nmhu,nr);
XXDpp_rf_imj = zeros(npn,nmhu,nr);
XXDpp_rf_immj = zeros(npn,nmhu,nr);
XXDpm_rf_ipj = zeros(npn,nmhu,nr);
XXDpm_rf_ij = zeros(npn,nmhu,nr);
XXDpm_rf_imj = zeros(npn,nmhu,nr);
XXDmp_rf_ijp = zeros(npn,nmhu,nr);
XXDmp_rf_ij = zeros(npn,nmhu,nr);
XXDmp_rf_ijm = zeros(npn,nmhu,nr);
XXDmm_rf_ijp = zeros(npn,nmhu,nr);
XXDmm_rf_ijm = zeros(npn,nmhu,nr);
XXD_rf_ij = zeros(npn,nmhu,nr);
if dke_mode == 1
	XXDpp_rf_tp_ippj = zeros(npn,nmhu,nr);
	XXDpp_rf_tp_ipj = zeros(npn,nmhu,nr);
	XXDpp_rf_tp_ij = zeros(npn,nmhu,nr);
	XXDpp_rf_tp_imj = zeros(npn,nmhu,nr);
	XXDpp_rf_tp_immj = zeros(npn,nmhu,nr);
	XXDpm_rf_tp_ipj = zeros(npn,nmhu,nr);
	XXDpm_rf_tp_ij = zeros(npn,nmhu,nr);
	XXDpm_rf_tp_imj = zeros(npn,nmhu,nr);
	XXDmp_rf_tp_ijp = zeros(npn,nmhu,nr);
	XXDmp_rf_tp_ij = zeros(npn,nmhu,nr);
	XXDmp_rf_tp_ijm = zeros(npn,nmhu,nr);
	XXDmm_rf_tp_ijp = zeros(npn,nmhu,nr);
	XXDmm_rf_tp_ijm = zeros(npn,nmhu,nr);
	XXD_rf_tp_ij = zeros(npn,nmhu,nr);
%
	XXFp_rf_tp_ippj = zeros(npn,nmhu,nr);
	XXFp_rf_tp_ipj = zeros(npn,nmhu,nr);
	XXFp_rf_tp_ij = zeros(npn,nmhu,nr);
	XXFp_rf_tp_imj = zeros(npn,nmhu,nr);
	XXFp_rf_tp_immj = zeros(npn,nmhu,nr);
	XXFm_rf_tp_ijp = zeros(npn,nmhu,nr);
	XXFm_rf_tp_ijm = zeros(npn,nmhu,nr);
	XXF_rf_tp_ij = zeros(npn,nmhu,nr);
%
% Wave-induced radial transport adjoint technique (P. Helander model)
%
   XXDmp1_rf_tp_ijp = zeros(npn,nmhu,nr);
   XXDmp1_rf_tp_ij = zeros(npn,nmhu,nr);
   XXDmp1_rf_tp_ijm = zeros(npn,nmhu,nr);
   XXDmm1_rf_tp_ijp = zeros(npn,nmhu,nr);
   XXDmm1_rf_tp_ijm = zeros(npn,nmhu,nr);
else
	XXDpp_rf_tp_ippj = NaN;
	XXDpp_rf_tp_ipj = NaN;
	XXDpp_rf_tp_ij = NaN;
	XXDpp_rf_tp_imj = NaN;
	XXDpp_rf_tp_immj = NaN;
	XXDpm_rf_tp_ipj = NaN;
	XXDpm_rf_tp_ij = NaN;
	XXDpm_rf_tp_imj = NaN;
	XXDmp_rf_tp_ijp = NaN;
	XXDmp_rf_tp_ij = NaN;
	XXDmp_rf_tp_ijm = NaN;
	XXDmm_rf_tp_ijp = NaN;
	XXDmm_rf_tp_ijm = NaN;
	XXD_rf_tp_ij = NaN;
%
	XXFp_rf_tp_ippj = NaN;
	XXFp_rf_tp_ipj = NaN;
	XXFp_rf_tp_ij = NaN;
	XXFp_rf_tp_imj = NaN;
	XXFp_rf_tp_immj = NaN;
	XXFm_rf_tp_ijp = NaN;
	XXFm_rf_tp_ijm = NaN;
	XXF_rf_tp_ij = NaN;
%
% Wave-induced radial transport adjoint technique (P. Helander model)
%
   XXDmp1_rf_tp_ijp = NaN;
   XXDmp1_rf_tp_ij = NaN;
   XXDmp1_rf_tp_ijm = NaN;
   XXDmm1_rf_tp_ijp = NaN;
   XXDmm1_rf_tp_ijm = NaN;
end
%
% Output files
%
if it_rf == 1,
%
%Linear interpolation coefficient in p and mhu for LH wave only (old technique Karney-Shoucri)
% 
   Xdeltap_ipj = Xdpnpp./(Xdpn + Xdpnpp);
   Xdeltap_imj = Xdpn./(Xdpn + Xdpnmm);
   Xdeltam_ijp = Xdmhupp./(Xdmhu + Xdmhupp);
   Xdeltam_ijm = Xdmhu./(Xdmhu + Xdmhumm);
%
% 3D duplications for each ray
%
   YXXmhup = repmat(Xmhup,[1,1,nr,1]);
   YXXmhu = repmat(Xmhu,[1,1,nr,1]);
   YXXmhum = repmat(Xmhum,[1,1,nr,1]);
%
   YXXmhu2p = repmat(Xmhu2p,[1,1,nr,1]);
   YXXmhu2 = repmat(Xmhu2,[1,1,nr,1]);
   YXXmhu2m = repmat(Xmhu2m,[1,1,nr,1]);
% 
   YXX1mmhu2p = repmat(X1mmhu2p,[1,1,nr,1]);
   YXX1mmhu2 = repmat(X1mmhu2,[1,1,nr,1]);
   YXX1mmhu2m = repmat(X1mmhu2m,[1,1,nr,1]);
%
   YXXpnpp = repmat(Xpnpp,[1,1,nr,1]);
   YXXpnp = repmat(Xpnp,[1,1,nr,1]);
   YXXpn = repmat(Xpn,[1,1,nr,1]);
   YXXpnm = repmat(Xpnm,[1,1,nr,1]);
   YXXpnmm = repmat(Xpnmm,[1,1,nr,1]);
%
   YXXgammapp = repmat(Xgammapp,[1,1,nr,1]);
   YXXgammap = repmat(Xgammap,[1,1,nr,1]);
   YXXgamma = repmat(Xgamma,[1,1,nr,1]);
   YXXgammam = repmat(Xgammam,[1,1,nr,1]);
   YXXgammamm = repmat(Xgammamm,[1,1,nr,1]);
%
   YXXdeltap_ipj = repmat(Xdeltap_ipj,[1,1,nr,1]);
   YXXdeltap_imj = repmat(Xdeltap_imj,[1,1,nr,1]);
   YXXdeltam_ijp = repmat(Xdeltam_ijp,[1,1,nr,1]);
   YXXdeltam_ijm = repmat(Xdeltam_ijm,[1,1,nr,1]);
%
   YXXqtilde = shiftdim(repmat(xqtilde',[1,1,npn,nmhu]),2);
   YXXB0 = shiftdim(repmat(xB0',[1,1,npn,nmhu]),2);
%      
   YXXsigmap = sign(YXXmhup);
   YXXsigma = sign(YXXmhu);
   YXXsigmam = sign(YXXmhum);
%          
% Bounce averaging factors
% 
   if bounce_mode > 0,          
   	YXXlambdap = shiftdim(repmat(Xxlambdap,[1,1,1,npn]),3); %Normalized bounce time
   	YXXlambda = shiftdim(repmat(Xxlambda,[1,1,1,npn]),3);
   	YXXlambdam = shiftdim(repmat(Xxlambdam,[1,1,1,npn]),3);
%  
   	YXXHPp = repmat(XXheaviside_p,[1,1,1,1]); %Mask for passing (1) or trapped (0) 
   	YXXHP = repmat(XXheaviside,[1,1,1,1]);
   	YXXHPm = repmat(XXheaviside_m,[1,1,1,1]);
% 
   	YXXBbp = YXXB0./YXX1mmhu2p;
   	YXXBb = YXXB0./YXX1mmhu2;
   	YXXBbm = YXXB0./YXX1mmhu2m;  
   else    
   	YXXlambdap = ones(npn,nmhu,nr,1);
   	YXXlambda = ones(npn,nmhu,nr,1);
   	YXXlambdam = ones(npn,nmhu,nr,1);    
%   
   	YXXHPp = ones(npn,nmhu,nr,1);
   	YXXHP = ones(npn,nmhu,nr,1);
   	YXXHPm = ones(npn,nmhu,nr,1);
   end
%
   time0 = clock;
%
   for iray = 1:nb;
   	for iD=1:19,
   		ZYXXD_rf{iD} = zeros(npn,nmhu,nr,1);
   		ZYXXD_rf_tp{iD} = zeros(npn,nmhu,nr,1);
   	end
   	for iF=1:8,
   		ZYXXF_rf_tp{iF} = zeros(npn,nmhu,nr,1);
   	end    
%
% RF wave parameters
%
   	xyomega_rf = waveparam(:,iray,1);% RF wave frequency 
   	xyopt = waveparam(:,iray,2);% options for Larmor radius effects and/or LH calc.
                     % 0:exact, 1:approx (kperp*rhoe<<1), 2: kperp*rhoe<<1 and old LH calc. (Karney, Shoucri)
   	xythetab_rf = waveparam(:,iray,3);% poloidal location of RF beam  (bounce_mode>0 only)
   	xyD0_rf = waveparam(:,iray,4);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
   	xynparmin_rf = waveparam(:,iray,5);% Square N// spectrum: Lower limit
   	xynparmax_rf = waveparam(:,iray,6);% Square N// spectrum: Upper limit
   	xynpar_rf = waveparam(:,iray,7);% Gaussian N// spectrum: peak n//
   	xydnpar_rf = waveparam(:,iray,8);% Gaussian N// spectrum: width in n//
   	xynperp_rf = waveparam(:,iray,9);% RF wave : n_perp
   	xyepolp_rf = waveparam(:,iray,10);% RF wave : polarization plus
   	xyepolm_rf = waveparam(:,iray,11);% RF wave : polarization minus
   	xyepolz_rf = waveparam(:,iray,12);% RF wave : polarization parallel
%
   	YXXomega_rf = shiftdim(repmat(xyomega_rf,[1,1,npn,nmhu]),2);
   	YXXopt = shiftdim(repmat(xyopt,[1,1,npn,nmhu]),2);
   	YXXD0_rf = shiftdim(repmat(xyD0_rf,[1,1,npn,nmhu]),2);
   	YXXnparmin_rf = shiftdim(repmat(xynparmin_rf,[1,1,npn,nmhu]),2);
   	YXXnparmax_rf = shiftdim(repmat(xynparmax_rf,[1,1,npn,nmhu]),2);
   	YXXnpar_rf = shiftdim(repmat(xynpar_rf,[1,1,npn,nmhu]),2);
   	YXXdnpar_rf = shiftdim(repmat(xydnpar_rf,[1,1,npn,nmhu]),2);
   	YXXnperp_rf = shiftdim(repmat(xynperp_rf,[1,1,npn,nmhu]),2);
   	YXXepolp_rf = shiftdim(repmat(xyepolp_rf,[1,1,npn,nmhu]),2);
   	YXXepolm_rf = shiftdim(repmat(xyepolm_rf,[1,1,npn,nmhu]),2);
   	YXXepolz_rf = shiftdim(repmat(xyepolz_rf,[1,1,npn,nmhu]),2);
%
% Magnetic geometry parameters at theta = thetab_rf
%
   	[xyBb_rf,xyBPb_rf,xyrb_rf] = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_rf);%
   	YXXBb_rf = shiftdim(repmat(xyBb_rf,[1,1,npn,nmhu]),2);
%    
% Bounce averaging factors
% 
   	if bounce_mode > 0,           
   		xyqtildeb_rf = xyBb_rf.*xyrb_rf./xyBPb_rf/Rp;
%   
   		YXXmaskb = (YXXBb_rf <= YXXBb) & (YXXBb_rf <= YXXBbp) & (YXXBb_rf <= YXXBbm); % condition thetab_rf < thetaT
%    
   		YXXpsib = YXXBb_rf./YXXB0; %Ratio of magnetic fields at theta = thetab_rf
%    
   		YXXmhubp = YXXmaskb.*YXXsigmap.*sqrt(1 - YXXpsib.*YXX1mmhu2p); %Pitch angle cosine at ray location
   		YXXmhub = YXXmaskb.*YXXsigma.*sqrt(1 - YXXpsib.*YXX1mmhu2);
   		YXXmhubm = YXXmaskb.*YXXsigmam.*sqrt(1 - YXXpsib.*YXX1mmhu2m);
%
   		YXXomegac = qe*YXXB0/me; % cyclotron frequency at B=Bmin 
%
   	else   
   		xyqtildeb_rf = ones(nr,1);% local bounce-averaging factor qtilde at theta = thetab_rf
%
   		YXXpsib = ones(npn,nmhu,nr,1);
   		YXXmaskb = ones(npn,nmhu,nr,1);
%
   		YXXmhubp = YXXmhup;
   		YXXmhub = YXXmhu;
   		YXXmhubm = YXXmhum;
%
%   when bounce_mode = 0, we need to take the cyclotron frequency at theta = thetab_rf 
%
   		YXXomegac = qe*YXXBb_rf/me;% cyclotron frequency at theta = thetab_rf
%    
   	end
%
%
   	YXXqtildeb_rf = shiftdim(repmat(xyqtildeb_rf,[1,1,npn,nmhu]),2); % local bounce-averaging factor qtilde at theta = thetab_rf
%
   	YXXmhub2p = YXXmhubp.*YXXmhubp;
   	YXXmhub2 = YXXmhub.*YXXmhub;
   	YXXmhub2m = YXXmhubm.*YXXmhubm;
%	    
   	YXXmhubp(YXXmhubp == 0) = eps;
   	YXXmhub(YXXmhub == 0) = eps;
   	YXXmhubm(YXXmhubm == 0) = eps;
%	    
   	YXXmhub2p(YXXmhub2p == 0) = eps;
   	YXXmhub2(YXXmhub2 == 0) = eps;
   	YXXmhub2m(YXXmhub2m == 0) = eps;
%
   	YXXlambdap(YXXlambdap == 0) = eps;
   	YXXlambda(YXXlambda == 0) = eps;
   	YXXlambdam(YXXlambdam == 0) = eps;
%
% FLR factor k_perp*rho_perp
% 
   	YXXZb_ippj = -YXXnperp_rf*betath_ref.*YXXpnpp.*sqrt(YXX1mmhu2).*YXXomega_rf./sqrt(YXXpsib)./YXXomegac;
   	YXXZb_ipj = -YXXnperp_rf*betath_ref.*YXXpnp.*sqrt(YXX1mmhu2).*YXXomega_rf./sqrt(YXXpsib)./YXXomegac;
   	YXXZb_ij = -YXXnperp_rf*betath_ref.*YXXpn.*sqrt(YXX1mmhu2).*YXXomega_rf./sqrt(YXXpsib)./YXXomegac;
   	YXXZb_imj = -YXXnperp_rf*betath_ref.*YXXpnm.*sqrt(YXX1mmhu2).*YXXomega_rf./sqrt(YXXpsib)./YXXomegac;
   	YXXZb_immj = -YXXnperp_rf*betath_ref.*YXXpnmm.*sqrt(YXX1mmhu2).*YXXomega_rf./sqrt(YXXpsib)./YXXomegac;
   	YXXZb_ijp = -YXXnperp_rf*betath_ref.*YXXpn.*sqrt(YXX1mmhu2p).*YXXomega_rf./sqrt(YXXpsib)./YXXomegac;
   	YXXZb_ijm = -YXXnperp_rf*betath_ref.*YXXpn.*sqrt(YXX1mmhu2m).*YXXomega_rf./sqrt(YXXpsib)./YXXomegac;
%
% Considers a square or a Gaussian shape for the spectrum, depending upon the condition isnan of YXXnparmin_rf and YXXnpar_rf
   	YXXmask_square = ~isnan(YXXnparmin_rf) & ~isnan(YXXnparmax_rf);%Square power spectrum in N//
   	YXXmask_gauss = ~isnan(YXXnpar_rf) & ~isnan(YXXdnpar_rf);%Gaussian power spectrum in N//  
%
   	YXXlre = (YXXopt == 0); %(0): exact calculation for the Bessel functions, otherwise, limit k_perp*rho_perp << 1
%
   	YXXold = (YXXopt == 2);
   	if max(YXXold(:)) > 0
   		info_dke_yp(1,'WARNING: Old technique for calculating the LH matrix coefficients, for comparaison with previous versions (Karney, Shoucri)');
   	end
%
% SUM OVER HARMONIC NUMBERS
%
   	for n_rf = 0:nmax_rf;
%
% Resonance Condition: resonant Npar
%
   		YXXnparres_ippj = (YXXgammapp - n_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpnpp./YXXmhub;
   		YXXnparres_ipj = (YXXgammap - n_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpnp./YXXmhub;
   		YXXnparres_ij = (YXXgamma - n_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpn./YXXmhub;
   		YXXnparres_imj = (YXXgammam - n_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpnm./YXXmhub;
   		YXXnparres_immj = (YXXgammamm - n_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpnmm./YXXmhub;
   		YXXnparres_ijp = (YXXgamma - n_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpn./YXXmhubp;
   		YXXnparres_ijm = (YXXgamma - n_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpn./YXXmhubm;
%
% Resonance Condition: delta function (normalized to: int(deltares d_npar) = 1)
%
   		YXXdeltares_ippj = zeros(npn,nmhu,nr,1);
   		YXXdeltares_ipj = zeros(npn,nmhu,nr,1);
   		YXXdeltares_ij = zeros(npn,nmhu,nr,1);
   		YXXdeltares_imj = zeros(npn,nmhu,nr,1);
   		YXXdeltares_immj = zeros(npn,nmhu,nr,1);
   		YXXdeltares_ijp = zeros(npn,nmhu,nr,1);
   		YXXdeltares_ijm = zeros(npn,nmhu,nr,1);
%
   		YXXdeltares_ippj(YXXmask_square) = (YXXnparres_ippj(YXXmask_square) > YXXnparmin_rf(YXXmask_square)).*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ippj(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
   		YXXdeltares_ippj(YXXmask_gauss) = exp(-(YXXnparres_ippj(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
%          
   		YXXdeltares_ipj(YXXmask_square) = (YXXnparres_ipj(YXXmask_square) > YXXnparmin_rf(YXXmask_square)).*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ipj(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
   		YXXdeltares_ipj(YXXmask_gauss) = exp(-(YXXnparres_ipj(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
%          
   		YXXdeltares_ij(YXXmask_square) = (YXXnparres_ij(YXXmask_square) > YXXnparmin_rf(YXXmask_square)).*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ij(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
   		YXXdeltares_ij(YXXmask_gauss) = exp(-(YXXnparres_ij(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
%           
   		YXXdeltares_imj(YXXmask_square) = (YXXnparres_imj(YXXmask_square) > YXXnparmin_rf(YXXmask_square)).*(YXXnparmax_rf(YXXmask_square) >YXXnparres_imj(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
   		YXXdeltares_imj(YXXmask_gauss) = exp(-(YXXnparres_imj(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
%           
   		YXXdeltares_immj(YXXmask_square) = (YXXnparres_immj(YXXmask_square) > YXXnparmin_rf(YXXmask_square)).*(YXXnparmax_rf(YXXmask_square) >YXXnparres_immj(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
   		YXXdeltares_immj(YXXmask_gauss) = exp(-(YXXnparres_immj(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
%           
   		YXXdeltares_ijp(YXXmask_square) = (YXXnparres_ijp(YXXmask_square) > YXXnparmin_rf(YXXmask_square)).*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ijp(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
   		YXXdeltares_ijp(YXXmask_gauss) = exp(-(YXXnparres_ijp(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
%           
   		YXXdeltares_ijm(YXXmask_square) = (YXXnparres_ijm(YXXmask_square) > YXXnparmin_rf(YXXmask_square)).*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ijm(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
   		YXXdeltares_ijm(YXXmask_gauss) = exp(-(YXXnparres_ijm(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
%
% Select only relevant harmonics
%
   		if max(max(max(max(YXXdeltares_ij)))) < 1e-10 %this harmonic is not a significant contribution 
   			continue;%valid only for MatLab v6.0+
   		end
%
%Old technique for calculating the LH matrix coefficients, for comparaison with previous versions (Karney, Shoucri)
%
   		YXXdeltares_old_ij = YXXdeltares_ij;
%
   		YXXdeltares_old_ippj = zeros(size(YXXdeltares_old_ij)); 
   		YXXdeltares_old_ipj = zeros(size(YXXdeltares_old_ij));
   		YXXdeltares_old_imj = zeros(size(YXXdeltares_old_ij)); 
   		YXXdeltares_old_immj = zeros(size(YXXdeltares_old_ij)); 
   		YXXdeltares_old_ijp = zeros(size(YXXdeltares_old_ij)); 
   		YXXdeltares_old_ijm = zeros(size(YXXdeltares_old_ij)); 
%
   		YXXdeltares_old_ippj(1:npn-1,:,:,:) = YXXdeltares_old_ij(2:npn,:,:,:);YXXdeltares_old_ippj(npn,:,:,:) = 0;
   		YXXdeltares_old_immj(2:npn,:,:,:) = YXXdeltares_old_ij(1:npn-1,:,:,:);YXXdeltares_old_immj(1,:,:,:) = 0;
   		YXXdeltares_old_ijpp(:,1:nmhu-1,:,:) = YXXdeltares_old_ij(:,2:nmhu,:,:);YXXdeltares_old_ijpp(:,nmhu,:,:,:) = 0;
   		YXXdeltares_old_ijmm(:,2:nmhu,:,:) = YXXdeltares_old_ij(:,1:nmhu-1,:,:);YXXdeltares_old_ijmm(:,1,:,:) = 0;
   		YXXdeltares_old_ipj = YXXdeltares_old_ippj.*(1-YXXdeltap_ipj) + YXXdeltares_old_ij.*YXXdeltap_ipj; 
   		YXXdeltares_old_imj = YXXdeltares_old_ij.*(1-YXXdeltap_imj) + YXXdeltares_old_immj.*YXXdeltap_imj;
   		YXXdeltares_old_ijp = YXXdeltares_old_ijpp.*(1-YXXdeltam_ijp) + YXXdeltares_old_ij.*YXXdeltam_ijp;
   		YXXdeltares_old_ijm = YXXdeltares_old_ij.*(1-YXXdeltam_ijm) + YXXdeltares_old_ijmm.*YXXdeltam_ijm;
%
%Old LH operator: 1/vpar dependence removed (Karney, Shoucri)
%
   		YXXdeltares_old_ippj = YXXdeltares_old_ippj.*YXXpnpp.*abs(YXXmhu)./YXXgammapp;
   		YXXdeltares_old_ipj = YXXdeltares_old_ipj.*YXXpnp.*abs(YXXmhu)./YXXgammap;
   		YXXdeltares_old_ij = YXXdeltares_old_ij.*YXXpn.*abs(YXXmhu)./YXXgamma;
   		YXXdeltares_old_imj = YXXdeltares_old_imj.*YXXpnm.*abs(YXXmhu)./YXXgammam;
   		YXXdeltares_old_immj = YXXdeltares_old_immj.*YXXpnmm.*abs(YXXmhu)./YXXgammamm;
   		YXXdeltares_old_ijp = YXXdeltares_old_ijp.*YXXpn.*abs(YXXmhup)./YXXgamma;
   		YXXdeltares_old_ijm = YXXdeltares_old_ijm.*YXXpn.*abs(YXXmhum)./YXXgamma;
%
   		YXXdeltares_ippj = YXXold.*YXXdeltares_old_ippj + ~YXXold.*YXXdeltares_ippj;
   		YXXdeltares_ipj = YXXold.*YXXdeltares_old_ipj + ~YXXold.*YXXdeltares_ipj;
   		YXXdeltares_ij = YXXold.*YXXdeltares_old_ij + ~YXXold.*YXXdeltares_ij;
   		YXXdeltares_imj = YXXold.*YXXdeltares_old_imj + ~YXXold.*YXXdeltares_imj;
   		YXXdeltares_immj = YXXold.*YXXdeltares_old_immj + ~YXXold.*YXXdeltares_immj;
   		YXXdeltares_ijp = YXXold.*YXXdeltares_old_ijp + ~YXXold.*YXXdeltares_ijp;
   		YXXdeltares_ijm = YXXold.*YXXdeltares_old_ijm + ~YXXold.*YXXdeltares_ijm;
%
% Polarization term 
%
% Polarization vector is normed to 1.  
%
         YXXpolb_ippj = YXXepolp_rf.*besselj_dke_jd(n_rf + 1,YXXZb_ippj,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(n_rf - 1,YXXZb_ippj,YXXlre)/sqrt(2)...
               - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(n_rf,YXXZb_ippj,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
         YXXpolb_ipj = YXXepolp_rf.*besselj_dke_jd(n_rf + 1,YXXZb_ipj,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(n_rf - 1,YXXZb_ipj,YXXlre)/sqrt(2)...
               - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(n_rf,YXXZb_ipj,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
         YXXpolb_ij = YXXepolp_rf.*besselj_dke_jd(n_rf + 1,YXXZb_ij,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(n_rf - 1,YXXZb_ij,YXXlre)/sqrt(2)...
               - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(n_rf,YXXZb_ij,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
         YXXpolb_imj = YXXepolp_rf.*besselj_dke_jd(n_rf + 1,YXXZb_imj,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(n_rf - 1,YXXZb_imj,YXXlre)/sqrt(2)...
               - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(n_rf,YXXZb_imj,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
         YXXpolb_immj = YXXepolp_rf.*besselj_dke_jd(n_rf + 1,YXXZb_immj,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(n_rf - 1,YXXZb_immj,YXXlre)/sqrt(2)...
               - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(n_rf,YXXZb_immj,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
         YXXpolb_ijp = YXXepolp_rf.*besselj_dke_jd(n_rf + 1,YXXZb_ijp,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(n_rf - 1,YXXZb_ijp,YXXlre)/sqrt(2)...
               - YXXmhubp.*YXXepolz_rf.*besselj_dke_jd(n_rf,YXXZb_ijp,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2p);
         YXXpolb_ijm = YXXepolp_rf.*besselj_dke_jd(n_rf + 1,YXXZb_ijm,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(n_rf - 1,YXXZb_ijm,YXXlre)/sqrt(2)...
               - YXXmhubm.*YXXepolz_rf.*besselj_dke_jd(n_rf,YXXZb_ijm,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2m);    
%
%Sum over sigma for trapped particles
%
% case FP
         YXXrespol_ippj = YXXHP.*(YXXdeltares_ippj.*abs(YXXpolb_ippj).^2) + ~YXXHP.*(YXXdeltares_ippj.*abs(YXXpolb_ippj).^2 + flipdim(YXXdeltares_ippj.*abs(YXXpolb_ippj).^2,2))/2;       
         YXXrespol_ipj = YXXHP.*(YXXdeltares_ipj.*abs(YXXpolb_ipj).^2) + ~YXXHP.*(YXXdeltares_ipj.*abs(YXXpolb_ipj).^2 + flipdim(YXXdeltares_ipj.*abs(YXXpolb_ipj).^2,2))/2;       
         YXXrespol_ij = YXXHP.*(YXXdeltares_ij.*abs(YXXpolb_ij).^2) + ~YXXHP.*(YXXdeltares_ij.*abs(YXXpolb_ij).^2 + flipdim(YXXdeltares_ij.*abs(YXXpolb_ij).^2,2))/2;       
         YXXrespol_imj = YXXHP.*(YXXdeltares_imj.*abs(YXXpolb_imj).^2) + ~YXXHP.*(YXXdeltares_imj.*abs(YXXpolb_imj).^2 + flipdim(YXXdeltares_imj.*abs(YXXpolb_imj).^2,2))/2;       
         YXXrespol_immj = YXXHP.*(YXXdeltares_immj.*abs(YXXpolb_immj).^2) + ~YXXHP.*(YXXdeltares_immj.*abs(YXXpolb_immj).^2 + flipdim(YXXdeltares_immj.*abs(YXXpolb_immj).^2,2))/2;      
         YXXrespol_ijp = YXXHPp.*(YXXdeltares_ijp.*abs(YXXpolb_ijp).^2) + ~YXXHPp.*(YXXdeltares_ijp.*abs(YXXpolb_ijp).^2 + flipdim(YXXdeltares_ijm.*abs(YXXpolb_ijm).^2,2))/2;% -mhup = fliplr(mhum)     
         YXXrespol_ijm = YXXHPm.*(YXXdeltares_ijm.*abs(YXXpolb_ijm).^2) + ~YXXHPm.*(YXXdeltares_ijm.*abs(YXXpolb_ijm).^2 + flipdim(YXXdeltares_ijp.*abs(YXXpolb_ijp).^2,2))/2;% -mhum = fliplr(mhup)        
% case DKE
         YXXrespol_tp_ippj = YXXHP.*(YXXdeltares_ippj.*abs(YXXpolb_ippj).^2) + ~YXXHP.*YXXsigma.*(YXXdeltares_ippj.*abs(YXXpolb_ippj).^2.*YXXsigma + flipdim(YXXdeltares_ippj.*abs(YXXpolb_ippj).^2.*YXXsigma,2))/2;       
         YXXrespol_tp_ipj = YXXHP.*(YXXdeltares_ipj.*abs(YXXpolb_ipj).^2) + ~YXXHP.*YXXsigma.*(YXXdeltares_ipj.*abs(YXXpolb_ipj).^2.*YXXsigma + flipdim(YXXdeltares_ipj.*abs(YXXpolb_ipj).^2.*YXXsigma,2))/2;       
         YXXrespol_tp_ij = YXXHP.*(YXXdeltares_ij.*abs(YXXpolb_ij).^2) + ~YXXHP.*YXXsigma.*(YXXdeltares_ij.*abs(YXXpolb_ij).^2.*YXXsigma + flipdim(YXXdeltares_ij.*abs(YXXpolb_ij).^2.*YXXsigma,2))/2;       
         YXXrespol_tp_imj = YXXHP.*(YXXdeltares_imj.*abs(YXXpolb_imj).^2) + ~YXXHP.*YXXsigma.*(YXXdeltares_imj.*abs(YXXpolb_imj).^2.*YXXsigma + flipdim(YXXdeltares_imj.*abs(YXXpolb_imj).^2.*YXXsigma,2))/2;       
         YXXrespol_tp_immj = YXXHP.*(YXXdeltares_immj.*abs(YXXpolb_immj).^2) + ~YXXHP.*YXXsigma.*(YXXdeltares_immj.*abs(YXXpolb_immj).^2.*YXXsigma + flipdim(YXXdeltares_immj.*abs(YXXpolb_immj).^2.*YXXsigma,2))/2;      
         YXXrespol_tp_ijp = YXXHPp.*(YXXdeltares_ijp.*abs(YXXpolb_ijp).^2) + ~YXXHPp.*YXXsigmap.*(YXXdeltares_ijp.*abs(YXXpolb_ijp).^2.*YXXsigmap + flipdim(YXXdeltares_ijm.*abs(YXXpolb_ijm).^2.*YXXsigmam,2))/2;% -mhup = fliplr(mhum)     
         YXXrespol_tp_ijm = YXXHPm.*(YXXdeltares_ijm.*abs(YXXpolb_ijm).^2) + ~YXXHPm.*YXXsigmam.*(YXXdeltares_ijm.*abs(YXXpolb_ijm).^2.*YXXsigmam + flipdim(YXXdeltares_ijp.*abs(YXXpolb_ijp).^2.*YXXsigmap,2))/2;% -mhum = fliplr(mhup)        
%
%QL diffusion coefficient normalized to YXXD0_rf
%    
         YXXDrf_ippj = YXXrespol_ippj.*YXXpsib.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgammapp./YXXpnpp./abs(YXXmhu)./YXXmhub2./YXXlambda./YXXqtilde;
         YXXDrf_ipj = YXXrespol_ipj.*YXXpsib.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgammap./YXXpnp./abs(YXXmhu)./YXXmhub2./YXXlambda./YXXqtilde;
         YXXDrf_ij = YXXrespol_ij.*YXXpsib.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhu)./YXXmhub2./YXXlambda./YXXqtilde;
         YXXDrf_imj = YXXrespol_imj.*YXXpsib.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgammam./YXXpnm./abs(YXXmhu)./YXXmhub2./YXXlambda./YXXqtilde;
         YXXDrf_immj = YXXrespol_immj.*YXXpsib.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgammamm./YXXpnmm./abs(YXXmhu)./YXXmhub2./YXXlambda./YXXqtilde;
         YXXDrf_ijp = YXXrespol_ijp.*YXXpsib.*YXXmhu2p.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhup)./YXXmhub2p./YXXlambdap./YXXqtilde;
         YXXDrf_ijm = YXXrespol_ijm.*YXXpsib.*YXXmhu2m.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhum)./YXXmhub2m./YXXlambdam./YXXqtilde;   
%
         if dke_mode == 1
         	YXXDrf_D_tp_ippj = YXXrespol_tp_ippj.*YXXmhu.*YXXqtildeb_rf.*YXXmaskb.*YXXgammapp./YXXpnpp./abs(YXXmhu)./YXXmhub./YXXlambda./YXXqtilde;
         	YXXDrf_D_tp_ipj = YXXrespol_tp_ipj.*YXXmhu.*YXXqtildeb_rf.*YXXmaskb.*YXXgammap./YXXpnp./abs(YXXmhu)./YXXmhub./YXXlambda./YXXqtilde;
         	YXXDrf_D_tp_ij = YXXrespol_tp_ij.*YXXmhu.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhu)./YXXmhub./YXXlambda./YXXqtilde;
         	YXXDrf_D_tp_imj = YXXrespol_tp_imj.*YXXmhu.*YXXqtildeb_rf.*YXXmaskb.*YXXgammam./YXXpnm./abs(YXXmhu)./YXXmhub./YXXlambda./YXXqtilde;
         	YXXDrf_D_tp_immj = YXXrespol_tp_immj.*YXXmhu.*YXXqtildeb_rf.*YXXmaskb.*YXXgammamm./YXXpnmm./abs(YXXmhu)./YXXmhub./YXXlambda./YXXqtilde;
         	YXXDrf_D_tp_ijp = YXXrespol_tp_ijp.*YXXmhup.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhup)./YXXmhubp./YXXlambdap./YXXqtilde;
         	YXXDrf_D_tp_ijm = YXXrespol_tp_ijm.*YXXmhum.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhum)./YXXmhubm./YXXlambdam./YXXqtilde;   
%    
         	YXXDrf_F_tp_ippj = YXXrespol_tp_ippj.*(1 - YXXpsib).*YXXmhu.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgammapp./YXXpnpp./abs(YXXmhu)./YXXmhub./YXXmhub2./YXXlambda./YXXqtilde;
         	YXXDrf_F_tp_ipj = YXXrespol_tp_ipj.*(1 - YXXpsib).*YXXmhu.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgammap./YXXpnp./abs(YXXmhu)./YXXmhub./YXXmhub2./YXXlambda./YXXqtilde;
         	YXXDrf_F_tp_ij = YXXrespol_tp_ij.*(1 - YXXpsib).*YXXmhu.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhu)./YXXmhub./YXXmhub2./YXXlambda./YXXqtilde;
         	YXXDrf_F_tp_imj = YXXrespol_tp_imj.*(1 - YXXpsib).*YXXmhu.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgammam./YXXpnm./abs(YXXmhu)./YXXmhub./YXXmhub2./YXXlambda./YXXqtilde;
         	YXXDrf_F_tp_immj = YXXrespol_tp_immj.*(1 - YXXpsib).*YXXmhu.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgammamm./YXXpnmm./abs(YXXmhu)./YXXmhub./YXXmhub2./YXXlambda./YXXqtilde;
         	YXXDrf_F_tp_ijp = YXXrespol_tp_ijp.*(1 - YXXpsib).*YXXmhup.*YXXmhu2p.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhup)./YXXmhubp./YXXmhub2p./YXXlambdap./YXXqtilde;
         	YXXDrf_F_tp_ijm = YXXrespol_tp_ijm.*(1 - YXXpsib).*YXXmhum.*YXXmhu2m.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhum)./YXXmhubm./YXXmhub2m./YXXlambdam./YXXqtilde;       
%
% ---------------- Terms for wave-induced radial transport by adjoint technique (P. Helander model) ----------------
%         	
         	YXXDrf_F1_tp_ijp = YXXrespol_tp_ijp.*YXXmhup.*YXXmhu2p.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhup)./YXXmhubp./YXXmhub2p./YXXlambdap./YXXqtilde;
            YXXDrf_F1_tp_ij = YXXrespol_tp_ij.*YXXmhu.*YXXmhu2.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhu)./YXXmhub./YXXmhub2./YXXlambda./YXXqtilde;
            YXXDrf_F1_tp_ijm = YXXrespol_tp_ijm.*YXXmhum.*YXXmhu2m.*YXXqtildeb_rf.*YXXmaskb.*YXXgamma./YXXpn./abs(YXXmhum)./YXXmhubm./YXXmhub2m./YXXlambdam./YXXqtilde;       
         end
%
%QL diffusion tensor elements normalized to YXXD0_rf
%
         ZYXXD_rf{1} = ZYXXD_rf{1} + YXX1mmhu2.*YXXDrf_ippj;%YXXDpp_rf_ippj
         ZYXXD_rf{2} = ZYXXD_rf{2} + YXX1mmhu2.*YXXDrf_ipj;%YXXDpp_rf_ipj
         ZYXXD_rf{3} = ZYXXD_rf{3} + YXX1mmhu2.*YXXDrf_ij;%YXXDpp_rf_ij
         ZYXXD_rf{4} = ZYXXD_rf{4} + YXX1mmhu2.*YXXDrf_imj;%YXXDpp_rf_imj
         ZYXXD_rf{5} = ZYXXD_rf{5} + YXX1mmhu2.*YXXDrf_immj;%YXXDpp_rf_immj
%
         ZYXXD_rf{6} = ZYXXD_rf{6} - sqrt(YXX1mmhu2).*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ipj./YXXmhu;%YXXDpm_rf_ipj
         ZYXXD_rf{7} = ZYXXD_rf{7} - sqrt(YXX1mmhu2).*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ij./YXXmhu;%YXXDpm_rf_ij
         ZYXXD_rf{8} = ZYXXD_rf{8} - sqrt(YXX1mmhu2).*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_imj./YXXmhu;%YXXDpm_rf_imj
%
         ZYXXD_rf{9} = ZYXXD_rf{9} - sqrt(YXX1mmhu2p).*(YXX1mmhu2p - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ijp./YXXmhup;%YXXDmp_rf_ijp
         ZYXXD_rf{10} = ZYXXD_rf{10} - sqrt(YXX1mmhu2).*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ij./YXXmhu;%YXXDmp_rf_ij
         ZYXXD_rf{11} = ZYXXD_rf{11} - sqrt(YXX1mmhu2m).*(YXX1mmhu2m - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ijm./YXXmhum;%YXXDmp_rf_ijm
%
         ZYXXD_rf{12} = ZYXXD_rf{12} + (YXX1mmhu2p - n_rf.*YXXomegac./YXXomega_rf).^2.*YXXDrf_ijp./YXXmhu2p;%YXXDmm_rf_ijp
         ZYXXD_rf{13} = ZYXXD_rf{13} + (YXX1mmhu2m - n_rf.*YXXomegac./YXXomega_rf).^2.*YXXDrf_ijm./YXXmhu2m;%YXXDmm_rf_ijm
%
         ZYXXD_rf{14} = ZYXXD_rf{14}  + YXXDrf_ij;
%
         if dke_mode == 1
         	ZYXXD_rf_tp{1} = ZYXXD_rf_tp{1} + YXX1mmhu2.*YXXDrf_D_tp_ippj;%YXXDpp_rf_ippj
         	ZYXXD_rf_tp{2} = ZYXXD_rf_tp{2} + YXX1mmhu2.*YXXDrf_D_tp_ipj;%YXXDpp_rf_ipj
         	ZYXXD_rf_tp{3} = ZYXXD_rf_tp{3} + YXX1mmhu2.*YXXDrf_D_tp_ij;%YXXDpp_rf_ij
         	ZYXXD_rf_tp{4} = ZYXXD_rf_tp{4} + YXX1mmhu2.*YXXDrf_D_tp_imj;%YXXDpp_rf_imj
         	ZYXXD_rf_tp{5} = ZYXXD_rf_tp{5} + YXX1mmhu2.*YXXDrf_D_tp_immj;%YXXDpp_rf_immj
%
         	ZYXXD_rf_tp{6} = ZYXXD_rf_tp{6} - sqrt(YXX1mmhu2).*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_D_tp_ipj./YXXmhu;%YXXDpm_rf_ipj
         	ZYXXD_rf_tp{7} = ZYXXD_rf_tp{7} - sqrt(YXX1mmhu2).*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_D_tp_ij./YXXmhu;%YXXDpm_rf_ij
         	ZYXXD_rf_tp{8} = ZYXXD_rf_tp{8} - sqrt(YXX1mmhu2).*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_D_tp_imj./YXXmhu;%YXXDpm_rf_imj
%
         	ZYXXD_rf_tp{9} = ZYXXD_rf_tp{9} - sqrt(YXX1mmhu2p).*(YXX1mmhu2p - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_D_tp_ijp./YXXmhup;%YXXDmp_rf_ijp
         	ZYXXD_rf_tp{10} = ZYXXD_rf_tp{10} - sqrt(YXX1mmhu2).*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_D_tp_ij./YXXmhu;%YXXDmp_rf_ij
         	ZYXXD_rf_tp{11} = ZYXXD_rf_tp{11} - sqrt(YXX1mmhu2m).*(YXX1mmhu2m - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_D_tp_ijm./YXXmhum;%YXXDmp_rf_ijm
%
         	ZYXXD_rf_tp{12} = ZYXXD_rf_tp{12} + (YXX1mmhu2p - n_rf.*YXXomegac./YXXomega_rf).^2.*YXXDrf_D_tp_ijp./YXXmhu2p;%YXXDmm_rf_ijp
         	ZYXXD_rf_tp{13} = ZYXXD_rf_tp{13} + (YXX1mmhu2m - n_rf.*YXXomegac./YXXomega_rf).^2.*YXXDrf_D_tp_ijm./YXXmhu2m;%YXXDmm_rf_ijm
%
         	ZYXXD_rf_tp{14} = ZYXXD_rf_tp{14} + YXXDrf_D_tp_ij;
%
% ---------------- Terms for wave-induced radial transport by adjoint technique (P. Helander model) ----------------
%
            ZYXXD_rf_tp{15} = ZYXXD_rf_tp{15} - sqrt(YXX1mmhu2p).*(YXX1mmhu2p - n_rf.*YXXomegac./YXXomega_rf).*(YXXDrf_D_tp_ijp + YXXDrf_F1_tp_ijp)./YXXmhup;%YXXDmp_rf_ijp
            ZYXXD_rf_tp{16} = ZYXXD_rf_tp{16} - sqrt(YXX1mmhu2).*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*(YXXDrf_D_tp_ij + YXXDrf_F1_tp_ij)./YXXmhu;%YXXDmp_rf_ij
            ZYXXD_rf_tp{17} = ZYXXD_rf_tp{17} - sqrt(YXX1mmhu2m).*(YXX1mmhu2m - n_rf.*YXXomegac./YXXomega_rf).*(YXXDrf_D_tp_ijm + YXXDrf_F1_tp_ijm)./YXXmhum;%YXXDmp_rf_ijm
%
            ZYXXD_rf_tp{18} = ZYXXD_rf_tp{18} + (YXX1mmhu2p - n_rf.*YXXomegac./YXXomega_rf).^2.*(YXXDrf_D_tp_ijp + YXXDrf_F1_tp_ijp)./YXXmhu2p;%YXXDmm_rf_ijp
            ZYXXD_rf_tp{19} = ZYXXD_rf_tp{19} + (YXX1mmhu2m - n_rf.*YXXomegac./YXXomega_rf).^2.*(YXXDrf_D_tp_ijm + YXXDrf_F1_tp_ijm)./YXXmhu2m;%YXXDmm_rf_ijm
%
% ------------------------------------------------------------------------------------------------------------------
%
         	ZYXXF_rf_tp{1} = ZYXXF_rf_tp{1} - YXX1mmhu2.*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_F_tp_ippj./YXXmhu2./YXXmhu2./YXXpnpp;%YXXFp_rf_tp_ippj 
         	ZYXXF_rf_tp{2} = ZYXXF_rf_tp{2} - YXX1mmhu2.*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_F_tp_ipj./YXXmhu2./YXXmhu2./YXXpnp;%YXXFp_rf_tp_ipj 
         	ZYXXF_rf_tp{3} = ZYXXF_rf_tp{3} - YXX1mmhu2.*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_F_tp_ij./YXXmhu2./YXXmhu2./YXXpn;%YXXFp_rf_tp_ij 
         	ZYXXF_rf_tp{4} = ZYXXF_rf_tp{4} - YXX1mmhu2.*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_F_tp_imj./YXXmhu2./YXXmhu2./YXXpnm;%YXXFp_rf_tp_imj 
         	ZYXXF_rf_tp{5} = ZYXXF_rf_tp{5} - YXX1mmhu2.*(YXX1mmhu2 - n_rf.*YXXomegac./YXXomega_rf).*YXXDrf_F_tp_immj./YXXmhu2./YXXmhu2./YXXpnmm;%YXXFp_rf_tp_immj 
%
         	ZYXXF_rf_tp{6} = ZYXXF_rf_tp{6} + sqrt(YXX1mmhu2p).*(YXX1mmhu2p - n_rf.*YXXomegac./YXXomega_rf).^2.*YXXDrf_F_tp_ijp./YXXmhu2p./YXXmhu2p./YXXmhup./YXXpn;%YXXFm_rf_ijp
         	ZYXXF_rf_tp{7} = ZYXXF_rf_tp{7} + sqrt(YXX1mmhu2m).*(YXX1mmhu2m - n_rf.*YXXomegac./YXXomega_rf).^2.*YXXDrf_F_tp_ijm./YXXmhu2m./YXXmhu2m./YXXmhum./YXXpn;%YXXFm_rf_ijm
%    
         	ZYXXF_rf_tp{8} = ZYXXF_rf_tp{8} + YXXDrf_F_tp_ij;
         else
         	ZYXXD_rf_tp{1} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{2} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{3} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{4} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{5} = zeros(npn,nmhu,nr,1);
%
         	ZYXXD_rf_tp{6} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{7} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{8} = zeros(npn,nmhu,nr,1);
%
         	ZYXXD_rf_tp{9} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{10} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{11} = zeros(npn,nmhu,nr,1);
%
         	ZYXXD_rf_tp{12} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{13} = zeros(npn,nmhu,nr,1);
%
         	ZYXXD_rf_tp{14} = zeros(npn,nmhu,nr,1);
%
         	ZYXXD_rf_tp{14} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{15} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{16} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{17} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{18} = zeros(npn,nmhu,nr,1);
         	ZYXXD_rf_tp{19} = zeros(npn,nmhu,nr,1);
%         	
         	ZYXXF_rf_tp{1} = zeros(npn,nmhu,nr,1);
         	ZYXXF_rf_tp{2} = zeros(npn,nmhu,nr,1);
         	ZYXXF_rf_tp{3} = zeros(npn,nmhu,nr,1);
         	ZYXXF_rf_tp{4} = zeros(npn,nmhu,nr,1);
         	ZYXXF_rf_tp{5} = zeros(npn,nmhu,nr,1);
%
         	ZYXXF_rf_tp{6} = zeros(npn,nmhu,nr,1);
         	ZYXXF_rf_tp{7} = zeros(npn,nmhu,nr,1);
%    
         	ZYXXF_rf_tp{8} = zeros(npn,nmhu,nr,1);       	
         end   
      end
%
% Save ray temporary files that can be very large for power calculations in dke_1_4yp.m
%
		save(fullfile(temppath,['temp_ray_#',int2str(iray)]),'ZYXXD_rf','ZYXXD_rf_tp','ZYXXF_rf_tp');
%
% Sum over all rays
%
      XXDpp_rf_ippj = XXDpp_rf_ippj + YXXD0_rf.*ZYXXD_rf{1};
      XXDpp_rf_ipj = XXDpp_rf_ipj + YXXD0_rf.*ZYXXD_rf{2};
      XXDpp_rf_ij = XXDpp_rf_ij + YXXD0_rf.*ZYXXD_rf{3};
      XXDpp_rf_imj = XXDpp_rf_imj + YXXD0_rf.*ZYXXD_rf{4};
      XXDpp_rf_immj = XXDpp_rf_immj + YXXD0_rf.*ZYXXD_rf{5};
      XXDpm_rf_ipj = XXDpm_rf_ipj + YXXD0_rf.*ZYXXD_rf{6};
      XXDpm_rf_ij = XXDpm_rf_ij + YXXD0_rf.*ZYXXD_rf{7};
      XXDpm_rf_imj = XXDpm_rf_imj + YXXD0_rf.*ZYXXD_rf{8};
      XXDmp_rf_ijp = XXDmp_rf_ijp + YXXD0_rf.*ZYXXD_rf{9};
      XXDmp_rf_ij = XXDmp_rf_ij + YXXD0_rf.*ZYXXD_rf{10};
      XXDmp_rf_ijm = XXDmp_rf_ijm + YXXD0_rf.*ZYXXD_rf{11};
      XXDmm_rf_ijp = XXDmm_rf_ijp + YXXD0_rf.*ZYXXD_rf{12};
      XXDmm_rf_ijm = XXDmm_rf_ijm + YXXD0_rf.*ZYXXD_rf{13}; 
      XXD_rf_ij = XXD_rf_ij + YXXD0_rf.*ZYXXD_rf{14}; 
%
      if dke_mode == 1
         XXDpp_rf_tp_ippj = XXDpp_rf_tp_ippj + YXXD0_rf.*ZYXXD_rf_tp{1};
         XXDpp_rf_tp_ipj = XXDpp_rf_tp_ipj + YXXD0_rf.*ZYXXD_rf_tp{2};
         XXDpp_rf_tp_ij = XXDpp_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{3};
         XXDpp_rf_tp_imj = XXDpp_rf_tp_imj + YXXD0_rf.*ZYXXD_rf_tp{4};
         XXDpp_rf_tp_immj = XXDpp_rf_tp_immj + YXXD0_rf.*ZYXXD_rf_tp{5};
         XXDpm_rf_tp_ipj = XXDpm_rf_tp_ipj + YXXD0_rf.*ZYXXD_rf_tp{6};
         XXDpm_rf_tp_ij = XXDpm_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{7};
         XXDpm_rf_tp_imj = XXDpm_rf_tp_imj + YXXD0_rf.*ZYXXD_rf_tp{8};
         XXDmp_rf_tp_ijp = XXDmp_rf_tp_ijp + YXXD0_rf.*ZYXXD_rf_tp{9};
         XXDmp_rf_tp_ij = XXDmp_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{10};
         XXDmp_rf_tp_ijm = XXDmp_rf_tp_ijm + YXXD0_rf.*ZYXXD_rf_tp{11};
         XXDmm_rf_tp_ijp = XXDmm_rf_tp_ijp + YXXD0_rf.*ZYXXD_rf_tp{12};
         XXDmm_rf_tp_ijm = XXDmm_rf_tp_ijm + YXXD0_rf.*ZYXXD_rf_tp{13}; 
         XXD_rf_tp_ij = XXD_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{14};				
%
         XXFp_rf_tp_ippj = XXFp_rf_tp_ippj + YXXD0_rf.*ZYXXF_rf_tp{1};
         XXFp_rf_tp_ipj = XXFp_rf_tp_ipj + YXXD0_rf.*ZYXXF_rf_tp{2};
         XXFp_rf_tp_ij = XXFp_rf_tp_ij + YXXD0_rf.*ZYXXF_rf_tp{3};
         XXFp_rf_tp_imj = XXFp_rf_tp_imj + YXXD0_rf.*ZYXXF_rf_tp{4};
         XXFp_rf_tp_immj = XXFp_rf_tp_immj + YXXD0_rf.*ZYXXF_rf_tp{5};
         XXFm_rf_tp_ijp = XXFm_rf_tp_ijp + YXXD0_rf.*ZYXXF_rf_tp{6};
         XXFm_rf_tp_ijm = XXFm_rf_tp_ijm + YXXD0_rf.*ZYXXF_rf_tp{7};
         XXF_rf_tp_ij = XXF_rf_tp_ij + YXXD0_rf.*ZYXXF_rf_tp{8};
%
% Wave-induced radial transport adjoint technique (P. Helander model)
%
   		XXDmp1_rf_tp_ijp = XXDmp1_rf_tp_ijp + YXXD0_rf.*ZYXXD_rf_tp{15};
   		XXDmp1_rf_tp_ij = XXDmp1_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{16};
   		XXDmp1_rf_tp_ijm = XXDmp1_rf_tp_ijm + YXXD0_rf.*ZYXXD_rf_tp{17};
   		XXDmm1_rf_tp_ijp = XXDmm1_rf_tp_ijp + YXXD0_rf.*ZYXXD_rf_tp{18};
   		XXDmm1_rf_tp_ijm = XXDmm1_rf_tp_ijm + YXXD0_rf.*ZYXXD_rf_tp{19};
      end
	   if display_mode >= 1,info_dke_yp(2,['Calculations of RF matrix coefficients for effective ray #',int2str(iray),'/',int2str(nb),' done. Elapsed time : ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end	
	end
else
   time0 = clock;
%
   for iray = 1:nb;
%
% RF wave Dql only
%
   	xyD0_rf = waveparam(:,iray,4);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
   	YXXD0_rf = shiftdim(repmat(xyD0_rf,[1,1,npn,nmhu]),2);
   	load(fullfile(temppath,['temp_ray_#',int2str(iray)]),'ZYXXD_rf','ZYXXD_rf_tp','ZYXXF_rf_tp');   
%
% Sum over all rays
%
   	XXDpp_rf_ippj = XXDpp_rf_ippj + YXXD0_rf.*ZYXXD_rf{1};
   	XXDpp_rf_ipj = XXDpp_rf_ipj + YXXD0_rf.*ZYXXD_rf{2};
   	XXDpp_rf_ij = XXDpp_rf_ij + YXXD0_rf.*ZYXXD_rf{3};
   	XXDpp_rf_imj = XXDpp_rf_imj + YXXD0_rf.*ZYXXD_rf{4};
   	XXDpp_rf_immj = XXDpp_rf_immj + YXXD0_rf.*ZYXXD_rf{5};
   	XXDpm_rf_ipj = XXDpm_rf_ipj + YXXD0_rf.*ZYXXD_rf{6};
   	XXDpm_rf_ij = XXDpm_rf_ij + YXXD0_rf.*ZYXXD_rf{7};
   	XXDpm_rf_imj = XXDpm_rf_imj + YXXD0_rf.*ZYXXD_rf{8};
   	XXDmp_rf_ijp = XXDmp_rf_ijp + YXXD0_rf.*ZYXXD_rf{9};
   	XXDmp_rf_ij = XXDmp_rf_ij + YXXD0_rf.*ZYXXD_rf{10};
   	XXDmp_rf_ijm = XXDmp_rf_ijm + YXXD0_rf.*ZYXXD_rf{11};
   	XXDmm_rf_ijp = XXDmm_rf_ijp + YXXD0_rf.*ZYXXD_rf{12};
   	XXDmm_rf_ijm = XXDmm_rf_ijm + YXXD0_rf.*ZYXXD_rf{13}; 
   	XXD_rf_ij = XXD_rf_ij + YXXD0_rf.*ZYXXD_rf{14}; 
%
   	if dke_mode == 1
   		XXDpp_rf_tp_ippj = XXDpp_rf_tp_ippj + YXXD0_rf.*ZYXXD_rf_tp{1};
   		XXDpp_rf_tp_ipj = XXDpp_rf_tp_ipj + YXXD0_rf.*ZYXXD_rf_tp{2};
   		XXDpp_rf_tp_ij = XXDpp_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{3};
   		XXDpp_rf_tp_imj = XXDpp_rf_tp_imj + YXXD0_rf.*ZYXXD_rf_tp{4};
   		XXDpp_rf_tp_immj = XXDpp_rf_tp_immj + YXXD0_rf.*ZYXXD_rf_tp{5};
   		XXDpm_rf_tp_ipj = XXDpm_rf_tp_ipj + YXXD0_rf.*ZYXXD_rf_tp{6};
   		XXDpm_rf_tp_ij = XXDpm_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{7};
   		XXDpm_rf_tp_imj = XXDpm_rf_tp_imj + YXXD0_rf.*ZYXXD_rf_tp{8};
   		XXDmp_rf_tp_ijp = XXDmp_rf_tp_ijp + YXXD0_rf.*ZYXXD_rf_tp{9};
   		XXDmp_rf_tp_ij = XXDmp_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{10};
   		XXDmp_rf_tp_ijm = XXDmp_rf_tp_ijm + YXXD0_rf.*ZYXXD_rf_tp{11};
   		XXDmm_rf_tp_ijp = XXDmm_rf_tp_ijp + YXXD0_rf.*ZYXXD_rf_tp{12};
   		XXDmm_rf_tp_ijm = XXDmm_rf_tp_ijm + YXXD0_rf.*ZYXXD_rf_tp{13}; 
   		XXD_rf_tp_ij = XXD_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{14};				
%
   		XXFp_rf_tp_ippj = XXFp_rf_tp_ippj + YXXD0_rf.*ZYXXF_rf_tp{1};
   		XXFp_rf_tp_ipj = XXFp_rf_tp_ipj + YXXD0_rf.*ZYXXF_rf_tp{2};
   		XXFp_rf_tp_ij = XXFp_rf_tp_ij + YXXD0_rf.*ZYXXF_rf_tp{3};
   		XXFp_rf_tp_imj = XXFp_rf_tp_imj + YXXD0_rf.*ZYXXF_rf_tp{4};
   		XXFp_rf_tp_immj = XXFp_rf_tp_immj + YXXD0_rf.*ZYXXF_rf_tp{5};
   		XXFm_rf_tp_ijp = XXFm_rf_tp_ijp + YXXD0_rf.*ZYXXF_rf_tp{6};
   		XXFm_rf_tp_ijm = XXFm_rf_tp_ijm + YXXD0_rf.*ZYXXF_rf_tp{7};
   		XXF_rf_tp_ij = XXF_rf_tp_ij + YXXD0_rf.*ZYXXF_rf_tp{8};
%
% Wave-induced radial transport adjoint technique (P. Helander model)
%
   		XXDmp1_rf_tp_ijp = XXDmp1_rf_tp_ijp + YXXD0_rf.*ZYXXD_rf_tp{15};
   		XXDmp1_rf_tp_ij = XXDmp1_rf_tp_ij + YXXD0_rf.*ZYXXD_rf_tp{16};
   		XXDmp1_rf_tp_ijm = XXDmp1_rf_tp_ijm + YXXD0_rf.*ZYXXD_rf_tp{17};
   		XXDmm1_rf_tp_ijp = XXDmm1_rf_tp_ijp + YXXD0_rf.*ZYXXD_rf_tp{18};
   		XXDmm1_rf_tp_ijm = XXDmm1_rf_tp_ijm + YXXD0_rf.*ZYXXD_rf_tp{19};
     	end
   	if display_mode >= 1,info_dke_yp(2,['Calculations of RF matrix coefficients for effective ray #',int2str(iray),'/',int2str(nb),' done. Elapsed time : ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end	
	end
end 
