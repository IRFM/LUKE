function ZYXXD_rf = rfdiff_dke_jd(waveparam,xrho,...
    Xmhup,Xmhu,Xmhum,Xmhu2p,Xmhu2,Xmhu2m,X1mmhu2p,X1mmhu2,X1mmhu2m,...
    pnpp,pnp,pn,pnm,pnmm,Xpnpp,Xpnp,Xpn,Xpnm,Xpnmm,Xgammapp,Xgammap,Xgamma,Xgammam,Xgammamm,...
    Xxlambdap,Xxlambda,Xxlambdam,...
    xq,betath_ref,Rp_norm,bounce_mode)
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
%       - bounce_mode       bounce averaged calculation: (0) OFF, (1) ON
%
% OUTPUTS:
%   
%       - ZYXXD_rf{1:13}:   QL diffusion tensor elements
%       - ZYXXD_rf{14}:     QL diffusion coefficient
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
% Last update: 02/07/03
%
% by J. Decker (MIT/RLE, jodecker@mit.edu) 02/05/03 
%
[npn,nmhu] = size(Xpn);
nr = length(xrho);
nb = size(waveparam,2);
%
% Radial grid
%
xia = xrho/Rp_norm; % Local inverse aspect ratio
xmhubounce2 = 2*xia./(1 + xia); % Squared pitch-angle cosine at the trapped/passing boundary
%
% 4D duplications
%
YXXmhup = repmat(Xmhup,[1,1,nr,nb]);
YXXmhu = repmat(Xmhu,[1,1,nr,nb]);
YXXmhum = repmat(Xmhum,[1,1,nr,nb]);
%
YXXmhu2p = repmat(Xmhu2p,[1,1,nr,nb]);
YXXmhu2 = repmat(Xmhu2,[1,1,nr,nb]);
YXXmhu2m = repmat(Xmhu2m,[1,1,nr,nb]);
% 
YXX1mmhu2p = repmat(X1mmhu2p,[1,1,nr,nb]);
YXX1mmhu2 = repmat(X1mmhu2,[1,1,nr,nb]);
YXX1mmhu2m = repmat(X1mmhu2m,[1,1,nr,nb]);
%
YXXpnpp = repmat(Xpnpp,[1,1,nr,nb]);
YXXpnp = repmat(Xpnp,[1,1,nr,nb]);
YXXpn = repmat(Xpn,[1,1,nr,nb]);
YXXpnm = repmat(Xpnm,[1,1,nr,nb]);
YXXpnmm = repmat(Xpnmm,[1,1,nr,nb]);
%
YXXgammapp = repmat(Xgammapp,[1,1,nr,nb]);
YXXgammap = repmat(Xgammap,[1,1,nr,nb]);
YXXgamma = repmat(Xgamma,[1,1,nr,nb]);
YXXgammam = repmat(Xgammam,[1,1,nr,nb]);
YXXgammamm = repmat(Xgammamm,[1,1,nr,nb]);
%
YXXia = shiftdim(repmat(xia',[1,nb,npn,nmhu]),2);
YXXmhubounce2 = shiftdim(repmat(xmhubounce2',[1,nb,npn,nmhu]),2);
YXXq = shiftdim(repmat(xq',[1,nb,npn,nmhu]),2);
%
%
% RF wave parameters
%
xyn_rf = waveparam(:,:,1);% RF resonance harmonic
xyomega_rf = waveparam(:,:,2);% RF wave frequency 
xyomegac = waveparam(:,:,3);% midplane cyclotron frequency (r,theta=0) at the radial position considered 
                            % (!!) for bounce_mode = 0, enter cyclotron frequency at (r,theta)
xyopt = waveparam(:,:,4);% options for Larmor radius effects and/or LH calc.
                         % 0:exact, 1:approx (kperp*rhoe<<1), 2: kperp*rhoe<<1 and old LH calc. (Karney, Shoucri)
xythetab_rf = waveparam(:,:,5);% poloidal location of RF beam  (bounce_mode>0 only)
xyD0_rf = waveparam(:,:,6);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
xynparmin_rf = waveparam(:,:,7);% Square N// spectrum: Lower limit
xynparmax_rf = waveparam(:,:,8);% Square N// spectrum: Upper limit
xynpar_rf = waveparam(:,:,9);% Gaussian N// spectrum: peak n//
xydnpar_rf = waveparam(:,:,10);% Gaussian N// spectrum: width in n//
xynperp_rf = waveparam(:,:,11);% RF wave : n_perp
xyepolp_rf = waveparam(:,:,12);% RF wave : polarization plus
xyepolm_rf = waveparam(:,:,13);% RF wave : polarization minus
xyepolz_rf = waveparam(:,:,14);% RF wave : polarization parallel
%
YXXn_rf = shiftdim(repmat(xyn_rf,[1,1,npn,nmhu]),2);
YXXomega_rf = shiftdim(repmat(xyomega_rf,[1,1,npn,nmhu]),2);
YXXomegac = shiftdim(repmat(xyomegac,[1,1,npn,nmhu]),2);
YXXopt = shiftdim(repmat(xyopt,[1,1,npn,nmhu]),2);
YXXthetab_rf = shiftdim(repmat(xythetab_rf,[1,1,npn,nmhu]),2);%	
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
% Bounce averaging factors
% 
if bounce_mode > 0,          
    YXXlambdap = shiftdim(repmat(Xxlambdap,[1,1,nb,npn]),3); %Normalized bounce time
	 YXXlambda = shiftdim(repmat(Xxlambda,[1,1,nb,npn]),3);
	 YXXlambdam = shiftdim(repmat(Xxlambdam,[1,1,nb,npn]),3);
%  
	 YXXHPp = YXXmhu2p >= YXXmhubounce2; %Mask for passing (1) or trapped (0) 
	 YXXHP = YXXmhu2 >= YXXmhubounce2;
    YXXHPm = YXXmhu2m >= YXXmhubounce2;
% 
    YXXthetaCp = YXXHPp.*pi + ~YXXHPp.*acos(1 - 2*YXXmhu2p./YXXmhubounce2); %Poloidal angle at turning point (pi for passing el.)
    YXXthetaC = YXXHP.*pi + ~YXXHP.*acos(1 - 2*YXXmhu2./YXXmhubounce2);
    YXXthetaCm = YXXHPm.*pi + ~YXXHPm.*acos(1 - 2*YXXmhu2m./YXXmhubounce2);
%   
    YXXHZp = YXXthetaCp >= pi*YXXia./YXXq; %Mask for toroidal trapping effect
    YXXHZ = YXXthetaC >= pi*YXXia./YXXq;
    YXXHZm = YXXthetaCm >= pi*YXXia./YXXq;
%   
    YXXzetaCp = (YXXHPp + ~YXXHPp.*YXXHZp).*pi + ~YXXHPp.*~YXXHZp.*YXXthetaCp.*YXXq./YXXia; %Toroidal angle at turning point 
                                                            % (pi for passing el. or trapped el. covering more than 2*pi toroidally) 
    YXXzetaC = (YXXHP + ~YXXHP.*YXXHZ).*pi + ~YXXHP.*~YXXHZ.*YXXthetaC.*YXXq./YXXia;
    YXXzetaCm = (YXXHPm + ~YXXHPm.*YXXHZm).*pi + ~YXXHPm.*~YXXHZm.*YXXthetaCm.*YXXq./YXXia;
%    
    YXXHBp = YXXthetaCp >= abs(YXXthetab_rf); %Mask for particle reaching (1) or not (0) the poloidal location of the ray 
    YXXHB = YXXthetaC >= abs(YXXthetab_rf);
    YXXHBm = YXXthetaCm >= abs(YXXthetab_rf);
%
    YXXHTp = YXXzetaCp.*YXXHBp/pi; %Trapping factors put together
    YXXHT = YXXzetaC.*YXXHB/pi;
    YXXHTm = YXXzetaCm.*YXXHBm/pi;
%    
    YXXpsib = (1 + YXXia)./(1+YXXia.*cos(YXXthetab_rf)); %Ratio of magnetic fields
%    
    YXXmhubp = YXXHBp.*sign(YXXmhup).*sqrt(1 - YXXpsib.*YXX1mmhu2p); %Pitch angle cosine at ray location
    YXXmhub = YXXHB.*sign(YXXmhu).*sqrt(1 - YXXpsib.*YXX1mmhu2);
    YXXmhubm = YXXHBm.*sign(YXXmhum).*sqrt(1 - YXXpsib.*YXX1mmhu2m);
%
    clear YXXthetaCp YXXthetaC YXXthetaCm
    clear YXXzetaCp YXXzetaC YXXzetaCm
    clear YXXHZp YXXHZ YXXHZm
    clear YXXHBp YXXHB YXXHBm
    clear Xxlambdap Xxlambda Xxlambdam
else
    YXXHPp = ones(npn,nmhu,nr,nb);
    YXXHP = ones(npn,nmhu,nr,nb);
    YXXHPm = ones(npn,nmhu,nr,nb);
%    
    YXXHTp = ones(npn,nmhu,nr,nb);
    YXXHT = ones(npn,nmhu,nr,nb);
    YXXHTm = ones(npn,nmhu,nr,nb);
%
    YXXlambdap = ones(npn,nmhu,nr,nb);
    YXXlambda = ones(npn,nmhu,nr,nb);
    YXXlambdam = ones(npn,nmhu,nr,nb);    
%   
    YXXpsib = ones(npn,nmhu,nr,nb);
%
    YXXmhubp = YXXmhup;
	 YXXmhub = YXXmhu;
	 YXXmhubm = YXXmhum;
end
%
clear YXXmhubounce2 YXXia YXXthetab_rf YXXq
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
clear YXXnperp_rf
%
YXXlre = (YXXopt == 0); %(0): exact calculation for the bessel functions, otherwise, limit k_perp*rho_perp << 1
%
% Polarization term 
%
%   modified J.D. 07/02/03. Pol. vector is now norm. to 1.  
%
YXXpolb_ippj = YXXepolp_rf.*besselj_dke_jd(YXXn_rf + 1,YXXZb_ippj,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(YXXn_rf - 1,YXXZb_ippj,YXXlre)/sqrt(2)...
           - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(YXXn_rf,YXXZb_ippj,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
YXXpolb_ipj = YXXepolp_rf.*besselj_dke_jd(YXXn_rf + 1,YXXZb_ipj,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(YXXn_rf - 1,YXXZb_ipj,YXXlre)/sqrt(2)...
           - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(YXXn_rf,YXXZb_ipj,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
YXXpolb_ij = YXXepolp_rf.*besselj_dke_jd(YXXn_rf + 1,YXXZb_ij,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(YXXn_rf - 1,YXXZb_ij,YXXlre)/sqrt(2)...
           - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(YXXn_rf,YXXZb_ij,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
YXXpolb_imj = YXXepolp_rf.*besselj_dke_jd(YXXn_rf + 1,YXXZb_imj,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(YXXn_rf - 1,YXXZb_imj,YXXlre)/sqrt(2)...
           - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(YXXn_rf,YXXZb_imj,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
YXXpolb_immj = YXXepolp_rf.*besselj_dke_jd(YXXn_rf + 1,YXXZb_immj,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(YXXn_rf - 1,YXXZb_immj,YXXlre)/sqrt(2)...
           - YXXmhub.*YXXepolz_rf.*besselj_dke_jd(YXXn_rf,YXXZb_immj,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2);
YXXpolb_ijp = YXXepolp_rf.*besselj_dke_jd(YXXn_rf + 1,YXXZb_ijp,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(YXXn_rf - 1,YXXZb_ijp,YXXlre)/sqrt(2)...
           - YXXmhubp.*YXXepolz_rf.*besselj_dke_jd(YXXn_rf,YXXZb_ijp,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2p);
YXXpolb_ijm = YXXepolp_rf.*besselj_dke_jd(YXXn_rf + 1,YXXZb_ijm,YXXlre)/sqrt(2) + YXXepolm_rf.*besselj_dke_jd(YXXn_rf - 1,YXXZb_ijm,YXXlre)/sqrt(2)...
           - YXXmhubm.*YXXepolz_rf.*besselj_dke_jd(YXXn_rf,YXXZb_ijm,YXXlre)./sqrt(YXXpsib.*YXX1mmhu2m);    
%       
YXXpolb_ippj = YXXHP.*YXXpolb_ippj + ~YXXHP.*(YXXpolb_ippj + flipdim(YXXpolb_ippj,2))/2;       
YXXpolb_ipj = YXXHP.*YXXpolb_ipj + ~YXXHP.*(YXXpolb_ipj + flipdim(YXXpolb_ipj,2))/2;       
YXXpolb_ij = YXXHP.*YXXpolb_ij + ~YXXHP.*(YXXpolb_ij + flipdim(YXXpolb_ij,2))/2;       
YXXpolb_imj = YXXHP.*YXXpolb_imj + ~YXXHP.*(YXXpolb_imj + flipdim(YXXpolb_imj,2))/2;       
YXXpolb_immj = YXXHP.*YXXpolb_immj + ~YXXHP.*(YXXpolb_immj + flipdim(YXXpolb_immj,2))/2;       
YXXpolb_ijp = YXXHPp.*YXXpolb_ijp + ~YXXHPp.*(YXXpolb_ijp + flipdim(YXXpolb_ijp,2))/2;% -mhup = fliplr(mhum)       
YXXpolb_ijm = YXXHPm.*YXXpolb_ijm + ~YXXHPm.*(YXXpolb_ijm + flipdim(YXXpolb_ijm,2))/2;% -mhum = fliplr(mhup) 
%       
clear YXXlre 
clear YXXepolp_rf YXXepolm_rf YXXepolz_rf        
%
% Resonance Condition: resonant Npar
%
YXXnparres_ippj = (YXXgammapp - YXXn_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpnpp./YXXmhub;
YXXnparres_ipj = (YXXgammap - YXXn_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpnp./YXXmhub;
YXXnparres_ij = (YXXgamma - YXXn_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpn./YXXmhub;
YXXnparres_imj = (YXXgammam - YXXn_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpnm./YXXmhub;
YXXnparres_immj = (YXXgammamm - YXXn_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpnmm./YXXmhub;
YXXnparres_ijp = (YXXgamma - YXXn_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpn./YXXmhubp;
YXXnparres_ijm = (YXXgamma - YXXn_rf.*YXXomegac.*YXXpsib./YXXomega_rf)/betath_ref./YXXpn./YXXmhubm;
%
clear YXXmhubp YXXmhub YXXmhubm
%
YXXmask_square = ~isnan(YXXnparmin_rf) & ~isnan(YXXnparmax_rf);%Square power spectrum in N//
YXXmask_gauss = ~isnan(YXXnpar_rf) & ~isnan(YXXdnpar_rf);%Gaussian power spectrum in N//  
%
% Resonance Condition: delta function (normalized to: int(deltares d_npar) = 1)
% Considers a square or a Gaussian shape for the spectrum, depending upon the condition isnan of YXXnparmin_rf and YXXnpar_rf
%
YXXdeltares_ippj = zeros(npn,nmhu,nr,nb);
YXXdeltares_ipj = zeros(npn,nmhu,nr,nb);
YXXdeltares_ij = zeros(npn,nmhu,nr,nb);
YXXdeltares_imj = zeros(npn,nmhu,nr,nb);
YXXdeltares_immj = zeros(npn,nmhu,nr,nb);
YXXdeltares_ijp = zeros(npn,nmhu,nr,nb);
YXXdeltares_ijm = zeros(npn,nmhu,nr,nb);

YXXdeltares_ippj(YXXmask_square) = (YXXnparres_ippj(YXXmask_square) > YXXnparmin_rf(YXXmask_square))...
    .*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ippj(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
YXXdeltares_ippj(YXXmask_gauss) = exp(-(YXXnparres_ippj(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
           
YXXdeltares_ipj(YXXmask_square) = (YXXnparres_ipj(YXXmask_square) > YXXnparmin_rf(YXXmask_square))...
    .*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ipj(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
YXXdeltares_ipj(YXXmask_gauss) = exp(-(YXXnparres_ipj(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
           
YXXdeltares_ij(YXXmask_square) = (YXXnparres_ij(YXXmask_square) > YXXnparmin_rf(YXXmask_square))...
    .*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ij(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
YXXdeltares_ij(YXXmask_gauss) = exp(-(YXXnparres_ij(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
           
YXXdeltares_imj(YXXmask_square) = (YXXnparres_imj(YXXmask_square) > YXXnparmin_rf(YXXmask_square))...
    .*(YXXnparmax_rf(YXXmask_square) >YXXnparres_imj(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
YXXdeltares_imj(YXXmask_gauss) = exp(-(YXXnparres_imj(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
           
YXXdeltares_immj(YXXmask_square) = (YXXnparres_immj(YXXmask_square) > YXXnparmin_rf(YXXmask_square))...
    .*(YXXnparmax_rf(YXXmask_square) >YXXnparres_immj(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
YXXdeltares_immj(YXXmask_gauss) = exp(-(YXXnparres_immj(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
           
YXXdeltares_ijp(YXXmask_square) = (YXXnparres_ijp(YXXmask_square) > YXXnparmin_rf(YXXmask_square))...
    .*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ijp(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
YXXdeltares_ijp(YXXmask_gauss) = exp(-(YXXnparres_ijp(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
           
YXXdeltares_ijm(YXXmask_square) = (YXXnparres_ijm(YXXmask_square) > YXXnparmin_rf(YXXmask_square))...
    .*(YXXnparmax_rf(YXXmask_square) >YXXnparres_ijm(YXXmask_square))./(YXXnparmax_rf(YXXmask_square) - YXXnparmin_rf(YXXmask_square));
YXXdeltares_ijm(YXXmask_gauss) = exp(-(YXXnparres_ijm(YXXmask_gauss) - YXXnpar_rf(YXXmask_gauss)).^2./YXXdnpar_rf(YXXmask_gauss).^2)./YXXdnpar_rf(YXXmask_gauss)/sqrt(pi);
%
clear YXXmask_square YXXmask_gauss
clear YXXnparres_ippj YXXnparres_ipj YXXnparres_ij YXXnparres_imj YXXnparres_immj YXXnparres_ijp YXXnparres_ijm
clear YXXnparmin_rf YXXnparmax_rf YXXnpar_rf YXXdnpar_rf
%
%Sum over sigma for trapped particles
%
YXXres_ippj = YXXHP.*YXXdeltares_ippj + ~YXXHP.*(YXXdeltares_ippj + flipdim(YXXdeltares_ippj,2))/2;       
YXXres_ipj = YXXHP.*YXXdeltares_ipj + ~YXXHP.*(YXXdeltares_ipj + flipdim(YXXdeltares_ipj,2))/2;       
YXXres_ij = YXXHP.*YXXdeltares_ij + ~YXXHP.*(YXXdeltares_ij + flipdim(YXXdeltares_ij,2))/2;       
YXXres_imj = YXXHP.*YXXdeltares_imj + ~YXXHP.*(YXXdeltares_imj + flipdim(YXXdeltares_imj,2))/2;       
YXXres_immj = YXXHP.*YXXdeltares_immj + ~YXXHP.*(YXXdeltares_immj + flipdim(YXXdeltares_immj,2))/2;       
YXXres_ijp = YXXHPp.*YXXdeltares_ijp + ~YXXHPp.*(YXXdeltares_ijp + flipdim(YXXdeltares_ijm,2))/2;% -mhup = fliplr(mhum)       
YXXres_ijm = YXXHPm.*YXXdeltares_ijm + ~YXXHPm.*(YXXdeltares_ijm + flipdim(YXXdeltares_ijp,2))/2;% -mhum = fliplr(mhup) 
%
%YXXres_ippj(npn-2:npn,:) = 0;%Baranov
%YXXres_ipj(npn-2:npn,:) = 0;%Baranov
%YXXres_ij(npn-2:npn,:) = 0;%Baranov
%YXXres_imj(npn-2:npn,:) = 0;%Baranov
%YXXres_immj(npn-2:npn,:) = 0;%Baranov
%YXXres_ijp(npn-2:npn,:) = 0;%Baranov
%YXXres_ijm(npn-2:npn,:) = 0;%Baranov
%
clear YXXHPp YXXHP YXXHPm
clear YXXdeltares_ippj YXXdeltares_ipj YXXdeltares_ij YXXdeltares_imj YXXdeltares_immj YXXdeltares_ijp YXXdeltares_ijm
%
%Old technique for calculating the LH matrix coefficients, for comparaison with previous versions (Karney, Shoucri)
%
YXXold = (YXXopt == 2);
if max(YXXold(:)) > 0
	info_dke_yp(1,'WARNING: Old technique for calculating the LH matrix coefficients, for comparaison with previous versions (Karney, Shoucri)');
end
%
YXXres_old_ij = YXXres_ij;
YXXres_old_ij(npn-2:npn,:) = 0;%Baranov condition for avoiding particle leaks at the boundary when relativistic effects are karge at the high velocity limit
%
YXXres_old_ippj = zeros(size(YXXres_old_ij)); 
YXXres_old_ipj = zeros(size(YXXres_old_ij));
YXXres_old_imj = zeros(size(YXXres_old_ij)); 
YXXres_old_immj = zeros(size(YXXres_old_ij)); 
YXXres_old_ijp = zeros(size(YXXres_old_ij)); 
YXXres_old_ijm = zeros(size(YXXres_old_ij)); 
%
YXXres_old_ippj(1:npn-1,:,:,:) = YXXres_old_ij(2:npn,:,:,:); YXXres_old_ijipp(npn,:,:,:) = 0;
YXXres_old_ipj(1:npn-1,:,:,:) = (YXXres_old_ij(1:npn-1,:,:,:) + YXXres_old_ij(2:npn,:,:,:))/2; YXXres_old_ipj(npn,:,:,:) = YXXres_old_ij(npn,:,:,:)/2;
YXXres_old_imj(2:npn,:,:,:) = (YXXres_old_ij(1:npn-1,:,:,:) + YXXres_old_ij(2:npn,:,:,:))/2;YXXres_old_imj(1,:,:,:) = YXXres_old_ij(1,:,:,:)/2;
YXXres_old_immj(2:npn,:,:,:) = YXXres_old_ij(1:npn-1,:,:,:);YXXres_old_immj(1,:,:,:) = 0;
YXXres_old_ijp(:,1:nmhu-1,:,:) = (YXXres_old_ij(:,1:nmhu-1,:,:) + YXXres_old_ij(:,2:nmhu,:,:))/2;YXXres_old_ijp(:,nmhu,:,:) = YXXres_old_ij(:,nmhu,:,:)/2;   
YXXres_old_ijm(:,2:nmhu,:,:) = (YXXres_old_ij(:,1:nmhu-1,:,:) + YXXres_old_ij(:,2:nmhu,:,:))/2;YXXres_old_ijm(:,1,:,:) = YXXres_old_ij(:,1,:,:)/2;
%
%Old LH operator: 1/vpar dependence removed (Karney, Shoucri)
%
YXXres_old_ippj = YXXres_old_ippj.*YXXpnpp.*abs(YXXmhu)./YXXgammapp;
YXXres_old_ipj = YXXres_old_ipj.*YXXpnp.*abs(YXXmhu)./YXXgammap;
YXXres_old_ij = YXXres_old_ij.*YXXpn.*abs(YXXmhu)./YXXgamma;
YXXres_old_imj = YXXres_old_imj.*YXXpnm.*abs(YXXmhu)./YXXgammam;
YXXres_old_immj = YXXres_old_immj.*YXXpnmm.*abs(YXXmhu)./YXXgammamm;
YXXres_old_ijp = YXXres_old_ijp.*YXXpn.*abs(YXXmhup)./YXXgamma;
YXXres_old_ijm = YXXres_old_ijm.*YXXpn.*abs(YXXmhum)./YXXgamma;
%
YXXres_ippj = YXXold.*YXXres_old_ippj + ~YXXold.*YXXres_ippj;
YXXres_ipj = YXXold.*YXXres_old_ipj + ~YXXold.*YXXres_ipj;
YXXres_ij = YXXold.*YXXres_old_ij + ~YXXold.*YXXres_ij;
YXXres_imj = YXXold.*YXXres_old_imj + ~YXXold.*YXXres_imj;
YXXres_immj = YXXold.*YXXres_old_immj + ~YXXold.*YXXres_immj;
YXXres_ijp = YXXold.*YXXres_old_ijp + ~YXXold.*YXXres_ijp;
YXXres_ijm = YXXold.*YXXres_old_ijm + ~YXXold.*YXXres_ijm;
%
clear YXXold YXXopt
clear YXXres_old_ippj YXXres_old_ipj YXXres_old_ij YXXres_old_imj YXXres_old_immj YXXres_old_ijp YXXres_old_ijm 
%
%QL Diffusion Coefficient
%    
YXXDrf_ippj = YXXD0_rf.*abs(YXXpolb_ippj).^2.*YXXpsib.*YXXmhu2.*YXXHT.*YXXres_ippj.*YXXgammapp./YXXpnpp./abs(YXXmhu)./YXXmhub2./YXXlambda;
YXXDrf_ipj = YXXD0_rf.*abs(YXXpolb_ipj).^2.*YXXpsib.*YXXmhu2.*YXXHT.*YXXres_ipj.*YXXgammap./YXXpnp./abs(YXXmhu)./YXXmhub2./YXXlambda;
YXXDrf_ij = YXXD0_rf.*abs(YXXpolb_ij).^2.*YXXpsib.*YXXmhu2.*YXXHT.*YXXres_ij.*YXXgamma./YXXpn./abs(YXXmhu)./YXXmhub2./YXXlambda;
YXXDrf_imj = YXXD0_rf.*abs(YXXpolb_imj).^2.*YXXpsib.*YXXmhu2.*YXXHT.*YXXres_imj.*YXXgammam./YXXpnm./abs(YXXmhu)./YXXmhub2./YXXlambda;
YXXDrf_immj = YXXD0_rf.*abs(YXXpolb_immj).^2.*YXXpsib.*YXXmhu2.*YXXHT.*YXXres_immj.*YXXgammamm./YXXpnmm./abs(YXXmhu)./YXXmhub2./YXXlambda;
YXXDrf_ijp = YXXD0_rf.*abs(YXXpolb_ijp).^2.*YXXpsib.*YXXmhu2p.*YXXHTp.*YXXres_ijp.*YXXgamma./YXXpn./abs(YXXmhup)./YXXmhub2p./YXXlambdap;
YXXDrf_ijm = YXXD0_rf.*abs(YXXpolb_ijm).^2.*YXXpsib.*YXXmhu2m.*YXXHTm.*YXXres_ijm.*YXXgamma./YXXpn./abs(YXXmhum)./YXXmhub2m./YXXlambdam;   
%
clear YXXD0_rf YXXpsib YXXmhu2
clear YXXpolb_ippj YXXpolb_ipj YXXpolb_ij YXXpolb_imj YXXpolb_immj YXXpolb_ijp YXXpolb_ijm 
clear YXXres_ippj YXXres_ipj YXXres_ij YXXres_imj YXXres_immj YXXres_ijp YXXres_ijm 
clear YXXHTp YXXHT YXXHTm
clear YXXpnp YXXpn YXXpnm
clear YXXgammap YXXgamma YXXgammam
clear YXXlambdap YXXlambda YXXlambdam
%
%QL diffusion tensor elements
%
ZYXXD_rf{1} = YXX1mmhu2.*YXXDrf_ippj;%YXXDpp_rf_ippj
ZYXXD_rf{2} = YXX1mmhu2.*YXXDrf_ipj;%YXXDpp_rf_ipj
ZYXXD_rf{3} = YXX1mmhu2.*YXXDrf_ij;%YXXDpp_rf_ij
ZYXXD_rf{4} = YXX1mmhu2.*YXXDrf_imj;%YXXDpp_rf_imj
ZYXXD_rf{5} = YXX1mmhu2.*YXXDrf_immj;%YXXDpp_rf_immj
%
ZYXXD_rf{6} = -sqrt(YXX1mmhu2).*(YXX1mmhu2 - YXXn_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ipj./YXXmhu;%YXXDpm_rf_ipj
ZYXXD_rf{7} = -sqrt(YXX1mmhu2).*(YXX1mmhu2 - YXXn_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ij./YXXmhu;%YXXDpm_rf_ij
ZYXXD_rf{8} = -sqrt(YXX1mmhu2).*(YXX1mmhu2 - YXXn_rf.*YXXomegac./YXXomega_rf).*YXXDrf_imj./YXXmhu;%YXXDpm_rf_imj
%
ZYXXD_rf{9} = -sqrt(YXX1mmhu2p).*(YXX1mmhu2p - YXXn_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ijp./YXXmhup;%YXXDmp_rf_ijp
ZYXXD_rf{10} = -sqrt(YXX1mmhu2).*(YXX1mmhu2 - YXXn_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ij./YXXmhu;%YXXDmp_rf_ij
ZYXXD_rf{11} = -sqrt(YXX1mmhu2m).*(YXX1mmhu2m - YXXn_rf.*YXXomegac./YXXomega_rf).*YXXDrf_ijm./YXXmhum;%YXXDmp_rf_ijm
%
ZYXXD_rf{12} = (YXX1mmhu2p - YXXn_rf.*YXXomegac./YXXomega_rf).^2.*YXXDrf_ijp./YXXmhu2p;%YXXDmm_rf_ijp
ZYXXD_rf{13} = (YXX1mmhu2m - YXXn_rf.*YXXomegac./YXXomega_rf).^2.*YXXDrf_ijm./YXXmhu2m;%YXXDmm_rf_ijm
%
ZYXXD_rf{14} =  YXXDrf_ij;
