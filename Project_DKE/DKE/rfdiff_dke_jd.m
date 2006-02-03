function [ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp,ylist_rf] = rfdiff_dke_jd(waveparam,nmax_rf,save_id,temppath,...
    theta,XR,XZ,XBR,XBZ,XBphi,xB0,Rp,Zp,xqtilde,...
    XXheaviside,XXheaviside_p,XXheaviside_m,... 
    Xmhup,Xmhu,Xmhum,Xmhu2p,Xmhu2,Xmhu2m,X1mmhu2p,X1mmhu2,X1mmhu2m,Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
    Xpnpp,Xpnp,Xpn,Xpnm,Xpnmm,Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
    Xgammapp,Xgammap,Xgamma,Xgammam,Xgammamm,...
    Xxlambdap,Xxlambda,Xxlambdam,...
    betath_ref,bounce_mode,dke_mode,rdke,display_mode)
%
% Calculates the RF quasilinear diffusion coefficient and the diffusion
% tensor elements on a 3-D Grid: 2-D (p,mhu) in momentum; 1-D (rho) in space. 
% The coefficients associated with each ray are saved in the file
% temp_DQL.mat while the resulting coefficients are returned in the
% variables ZYXXD_rf,ZYXXD_rf_tp and ZYXXF_rf_tp.
% Note that since the coefficients are saved, only the missing elements are
% calculated in rfdiff_dke_jd while others are retrived. The coefficients
% are finally weighted by the magnitude of the diffusion coefficient.
%
% INPUTS:
%
%       - waveparam:        RF wave parameters (See detailed description below in code)
%                           waveparam is build by the function rfwave_dke_jd.m
%       - nmax_rf:          maximum harmonic number to be included
%       - save_id:          identification string, based on running date and time
%       - temppath:         path to temporary folder
%       - theta...xqtilde:  equilibrium properties
%       - Xmhup...Xdmhupp:  pitch angle grid 
%       - Xpnpp...Xdpnpp:   momentum grid 
%       - Xgamma...:        relativistic factor
%       - Xxlambda...:      normalized bounce time
%       - betath_ref:       sqrt(Te_ref/mc2)
%       - bounce_mode       bounce averaged calculation: (0) OFF, (1) ON
%       - dke_mode          equation solved: (0) FPE, (1) DKE
%       - rdke              list of points for DKE calculations
%       - display_mode      display mode parameter (full: 2, partial: 1, no: = 0)
%
% OUTPUTS:
%   
%       - ZYXXD_rf:         QL diffusion tensor elements for f0 
%       - ZYXXD_rf_tp:      QL diffusion tensor elements for ftilde 
%       - ZYXXF_rf_tp:      QL convection vector elements for ftilde 
%       - ylist_rf:         list of rays to be accounted for 
%
% NOTE:
%
%   the first characters of a variable name are related to its structure:
%       - x_    1-D radial (rho)
%       - X_    2-D momentum (p,mhu) 
%       - Xx_   1-D momentum + 1-D radial (mhu,rho)
%       - xy_   1-D radial + 1-D ray number (rho,b)
%       - XX_   2-D momentum + 1-D radial (p,mhu,rho)
%
%   refer to documentation for detailed description    
%
% by J. Decker (MIT/RLE) <jodecker@mit.edu> and Y. Peysson CEA/DRFC <yves.peysson@cea.fr>
%
[qe,me] = pc_dke_yp;%Universal physics constant
%
[npn,nmhu] = size(Xpn);
nr = length(xB0);
nr_dke = length(rdke);
nb = size(waveparam,2);
%
% Output files initialization
%
ZYXXD_rf.pp_ippj = zeros(npn,nmhu,nr);
ZYXXD_rf.pp_ipj = zeros(npn,nmhu,nr);
ZYXXD_rf.pp_ij = zeros(npn,nmhu,nr);
ZYXXD_rf.pp_imj = zeros(npn,nmhu,nr);
ZYXXD_rf.pp_immj = zeros(npn,nmhu,nr);
ZYXXD_rf.pm_ipj = zeros(npn,nmhu,nr);
ZYXXD_rf.pm_ij = zeros(npn,nmhu,nr);
ZYXXD_rf.parpar_ij = zeros(npn,nmhu,nr);
ZYXXD_rf.pm_imj = zeros(npn,nmhu,nr);
ZYXXD_rf.mp_ijp = zeros(npn,nmhu,nr);
ZYXXD_rf.mp_ij = zeros(npn,nmhu,nr);
ZYXXD_rf.mp_ijm = zeros(npn,nmhu,nr);
ZYXXD_rf.mm_ijp = zeros(npn,nmhu,nr);
ZYXXD_rf.mm_ijm = zeros(npn,nmhu,nr);
%
ZYXXF_rf.p_ippj = zeros(npn,nmhu,nr);
ZYXXF_rf.p_ipj = zeros(npn,nmhu,nr);
ZYXXF_rf.p_ij = zeros(npn,nmhu,nr);
ZYXXF_rf.p_imj = zeros(npn,nmhu,nr);
ZYXXF_rf.p_immj = zeros(npn,nmhu,nr);
ZYXXF_rf.m_ijp = zeros(npn,nmhu,nr);
ZYXXF_rf.m_ijm = zeros(npn,nmhu,nr);
%
if dke_mode == 1
%
    ZYXXD_rf_tp.pp_ippj = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.pp_ipj = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.pp_ij = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.pp_imj = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.pp_immj = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.pm_ipj = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.pm_ij = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.pm_imj = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.mp_ijp = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.mp_ij = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.mp_ijm = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.mm_ijp = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.mm_ijm = zeros(npn,nmhu,nr_dke);
%
	ZYXXF_rf_tp.p_ippj = zeros(npn,nmhu,nr_dke);
	ZYXXF_rf_tp.p_ipj = zeros(npn,nmhu,nr_dke);
	ZYXXF_rf_tp.p_ij = zeros(npn,nmhu,nr_dke);
	ZYXXF_rf_tp.p_imj = zeros(npn,nmhu,nr_dke);
	ZYXXF_rf_tp.p_immj = zeros(npn,nmhu,nr_dke);
	ZYXXF_rf_tp.m_ijp = zeros(npn,nmhu,nr_dke);
	ZYXXF_rf_tp.m_ijm = zeros(npn,nmhu,nr_dke);
%
% Wave-induced radial transport adjoint technique (P. Helander model)
%
    ZYXXD_rf_tp.mp1_ijp = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.mp1_ij = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.mp1_ijm = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.mm1_ijp = zeros(npn,nmhu,nr_dke);
    ZYXXD_rf_tp.mm1_ijm = zeros(npn,nmhu,nr_dke);
%    
else
%    
	ZYXXD_rf_tp = NaN;
	ZYXXF_rf_tp = NaN;
%
end
%
% Case where no RF wave is to be accounted for
%
if nb == 0,
    ylist_rf = [];
    return
end
%
%Linear interpolation coefficient in p and mhu for LH wave only (old technique Karney-Shoucri)
% 
Xdeltap_ipj = Xdpnpp./(Xdpn + Xdpnpp);
Xdeltap_imj = Xdpn./(Xdpn + Xdpnmm);
Xdeltam_ijp = Xdmhupp./(Xdmhu + Xdmhupp);
Xdeltam_ijm = Xdmhu./(Xdmhu + Xdmhumm);
%
% 3D duplications
%
XXmhup = repmat(Xmhup,[1,1,nr]);
XXmhu = repmat(Xmhu,[1,1,nr]);
XXmhum = repmat(Xmhum,[1,1,nr]);
%
XXmhu2p = repmat(Xmhu2p,[1,1,nr]);
XXmhu2 = repmat(Xmhu2,[1,1,nr]);
XXmhu2m = repmat(Xmhu2m,[1,1,nr]);
% 
XX1mmhu2p = repmat(X1mmhu2p,[1,1,nr]);
XX1mmhu2 = repmat(X1mmhu2,[1,1,nr]);
XX1mmhu2m = repmat(X1mmhu2m,[1,1,nr]);
%
XXpnpp = repmat(Xpnpp,[1,1,nr]);
XXpnp = repmat(Xpnp,[1,1,nr]);
XXpn = repmat(Xpn,[1,1,nr]);
XXpnm = repmat(Xpnm,[1,1,nr]);
XXpnmm = repmat(Xpnmm,[1,1,nr]);
%
XXgammapp = repmat(Xgammapp,[1,1,nr]);
XXgammap = repmat(Xgammap,[1,1,nr]);
XXgamma = repmat(Xgamma,[1,1,nr]);
XXgammam = repmat(Xgammam,[1,1,nr]);
XXgammamm = repmat(Xgammamm,[1,1,nr]);
%
XXdeltap_ipj = repmat(Xdeltap_ipj,[1,1,nr]);
XXdeltap_imj = repmat(Xdeltap_imj,[1,1,nr]);
XXdeltam_ijp = repmat(Xdeltam_ijp,[1,1,nr]);
XXdeltam_ijm = repmat(Xdeltam_ijm,[1,1,nr]);
%
XXqtilde = shiftdim(repmat(xqtilde,[nmhu,1,npn]),2);
XXB0 = shiftdim(repmat(xB0,[nmhu,1,npn]),2);
%
XXBbp = XXB0./XX1mmhu2p;
XXBb = XXB0./XX1mmhu2;
XXBbm = XXB0./XX1mmhu2m;
%
XXsigmap = sign(XXmhup);
XXsigma = sign(XXmhu);
XXsigmam = sign(XXmhum);
%
% RF wave parameters
%
xyomega_rf = waveparam(:,:,1);% RF wave frequency 
xyopt = waveparam(:,:,2);% options for Larmor radius effects and/or LH calc.
                         % 0:exact, 1:approx (kperp*rhoe<<1), 2: kperp*rhoe<<1 and old LH calc. (Karney, Shoucri)
xythetab_rf = waveparam(:,:,3);% poloidal location of RF beam  (bounce_mode>0 only)
xyD0_rf = waveparam(:,:,4);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
xynparmin_rf = waveparam(:,:,5);% Square N// spectrum: Lower limit
xynparmax_rf = waveparam(:,:,6);% Square N// spectrum: Upper limit
xynpar_rf = waveparam(:,:,7);% Gaussian N// spectrum: peak n//
xydnpar_rf = waveparam(:,:,8);% Gaussian N// spectrum: width in n//
xynperp_rf = waveparam(:,:,9);% RF wave : n_perp
xyepolp_rf = waveparam(:,:,10);% RF wave : polarization plus
xyepolm_rf = waveparam(:,:,11);% RF wave : polarization minus
xyepolz_rf = waveparam(:,:,12);% RF wave : polarization parallel
%
% Magnetic geometry parameters at theta = thetab_rf
%
[xyBb_rf,xyBPb_rf,xyrb_rf] = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_rf);%
%    
% Bounce averaging factors
% 
if bounce_mode > 0,          
    XXlambdap = shiftdim(repmat(Xxlambdap,[1,1,npn]),2); %Normalized bounce time
    XXlambda = shiftdim(repmat(Xxlambda,[1,1,npn]),2);
    XXlambdam = shiftdim(repmat(Xxlambdam,[1,1,npn]),2);
%
    XXlambdap(XXlambdap == 0) = eps;
    XXlambda(XXlambda == 0) = eps;
    XXlambdam(XXlambdam == 0) = eps;
% 
    xyqtildeb_rf = xyBb_rf.*xyrb_rf./xyBPb_rf/Rp;
%    
else
    XXheaviside_p = ones(npn,nmhu,nr);
    XXheaviside = ones(npn,nmhu,nr);
    XXheaviside_m = ones(npn,nmhu,nr);
%    
    XXlambdap = ones(npn,nmhu,nr);
    XXlambda = ones(npn,nmhu,nr);
    XXlambdam = ones(npn,nmhu,nr);       
%
    xyqtildeb_rf = ones(nr,nb);% local bounce-averaging factor qtilde at theta = thetab_rf
end
%
% The rays to be accounted for in the calculation of the RF coefficients
% are those for which one xyD0_rf at least is nonzero.
%
ylist_rf = find(max(xyD0_rf,[],1) > 0);%rays to be accounted for
%
for iy = ylist_rf,
    %
    XXD0_rf = shiftdim(repmat(xyD0_rf(:,iy),[1,npn,nmhu]),1);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
    %
    ynum = num2str(iy);
    if exist([fullfile(temppath,'temp_DQL_'),save_id,'_',ynum,'.mat']) == 2,
        if dke_mode == 0,
            load([fullfile(temppath,'temp_DQL_'),save_id,'_',ynum,'.mat'],'ZXXD_rf');
        else
            load([fullfile(temppath,'temp_DQL_'),save_id,'_',ynum,'.mat'],'ZXXD_rf','ZXXD_rf_tp','ZXXF_rf_tp');
        end            
    %
        if display_mode >= 1,info_dke_yp(2,['RF matrix coefficients for effective ray #',ynum,' retrieved.']);end	
    %
    else %The coefficients associated with this ray must be calculated.
    %
    % Initialization for coefficients associated with the current ray
    %
        ZXXD_rf.pp_ippj = zeros(npn,nmhu,nr);
        ZXXD_rf.pp_ipj = zeros(npn,nmhu,nr);
        ZXXD_rf.pp_ij = zeros(npn,nmhu,nr);
        ZXXD_rf.pp_imj = zeros(npn,nmhu,nr);
        ZXXD_rf.pp_immj = zeros(npn,nmhu,nr);
        ZXXD_rf.pm_ipj = zeros(npn,nmhu,nr);
        ZXXD_rf.pm_ij = zeros(npn,nmhu,nr);
        ZXXD_rf.parpar_ij = zeros(npn,nmhu,nr);
        ZXXD_rf.pm_imj = zeros(npn,nmhu,nr);
        ZXXD_rf.mp_ijp = zeros(npn,nmhu,nr);
        ZXXD_rf.mp_ij = zeros(npn,nmhu,nr);
        ZXXD_rf.mp_ijm = zeros(npn,nmhu,nr);
        ZXXD_rf.mm_ijp = zeros(npn,nmhu,nr);
        ZXXD_rf.mm_ijm = zeros(npn,nmhu,nr);
        %
        if dke_mode == 1
        %
            ZXXD_rf_tp.pp_ippj = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.pp_ipj = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.pp_ij = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.pp_imj = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.pp_immj = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.pm_ipj = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.pm_ij = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.pm_imj = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.mp_ijp = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.mp_ij = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.mp_ijm = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.mm_ijp = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.mm_ijm = zeros(npn,nmhu,nr_dke);
        %
        	ZXXF_rf_tp.p_ippj = zeros(npn,nmhu,nr_dke);
        	ZXXF_rf_tp.p_ipj = zeros(npn,nmhu,nr_dke);
        	ZXXF_rf_tp.p_ij = zeros(npn,nmhu,nr_dke);
        	ZXXF_rf_tp.p_imj = zeros(npn,nmhu,nr_dke);
        	ZXXF_rf_tp.p_immj = zeros(npn,nmhu,nr_dke);
        	ZXXF_rf_tp.m_ijp = zeros(npn,nmhu,nr_dke);
        	ZXXF_rf_tp.m_ijm = zeros(npn,nmhu,nr_dke);
        %
        % Wave-induced radial transport adjoint technique (P. Helander model)
        %
            ZXXD_rf_tp.mp1_ijp = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.mp1_ij = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.mp1_ijm = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.mm1_ijp = zeros(npn,nmhu,nr_dke);
            ZXXD_rf_tp.mm1_ijm = zeros(npn,nmhu,nr_dke);
        %    
        end
    %
        XXomega_rf = shiftdim(repmat(xyomega_rf(:,iy),[1,npn,nmhu]),1);
        XXopt = shiftdim(repmat(xyopt(:,iy),[1,npn,nmhu]),1);
        XXnparmin_rf = shiftdim(repmat(xynparmin_rf(:,iy),[1,npn,nmhu]),1);
        XXnparmax_rf = shiftdim(repmat(xynparmax_rf(:,iy),[1,npn,nmhu]),1);
        XXnpar_rf = shiftdim(repmat(xynpar_rf(:,iy),[1,npn,nmhu]),1);
        XXdnpar_rf = shiftdim(repmat(xydnpar_rf(:,iy),[1,npn,nmhu]),1);
        XXnperp_rf = shiftdim(repmat(xynperp_rf(:,iy),[1,npn,nmhu]),1);
        XXepolp_rf = shiftdim(repmat(xyepolp_rf(:,iy),[1,npn,nmhu]),1);
        XXepolm_rf = shiftdim(repmat(xyepolm_rf(:,iy),[1,npn,nmhu]),1);
        XXepolz_rf = shiftdim(repmat(xyepolz_rf(:,iy),[1,npn,nmhu]),1);
    %    
        XXBb_rf = shiftdim(repmat(xyBb_rf(:,iy),[1,npn,nmhu]),1);
    %
        XXqtildeb_rf = shiftdim(repmat(xyqtildeb_rf(:,iy),[1,npn,nmhu]),1); % local bounce-averaging factor qtilde at theta = thetab_rf
    %
        if bounce_mode > 0,          
        %   
            XXmaskb = (XXBb_rf <= XXBb) & (XXBb_rf <= XXBbp) & (XXBb_rf <= XXBbm); % condition thetab_rf < thetaT
        %    
            XXpsib = XXBb_rf./XXB0; %Ratio of magnetic fields at theta = thetab_rf
        %    
            XXmhubp = XXmaskb.*XXsigmap.*sqrt(1 - XXpsib.*XX1mmhu2p); %Pitch angle cosine at ray location
            XXmhub = XXmaskb.*XXsigma.*sqrt(1 - XXpsib.*XX1mmhu2);
            XXmhubm = XXmaskb.*XXsigmam.*sqrt(1 - XXpsib.*XX1mmhu2m);
        %
            XXomegac = qe*XXB0/me; % cyclotron frequency at B=Bmin 
        %
        else
        %
            XXmaskb = ones(npn,nmhu,nr);
        %   
            XXpsib = ones(npn,nmhu,nr);
        %
            XXmhubp = XXmhup;
            XXmhub = XXmhu;
            XXmhubm = XXmhum;
        %
        %   when bounce_mode = 0, we need to take the cyclotron frequency at theta = thetab_rf 
        %
            XXomegac = qe*XXBb_rf/me;% cyclotron frequency at theta = thetab_rf
        %    
        end
        %
        XXmhub2p = XXmhubp.*XXmhubp;
        XXmhub2 = XXmhub.*XXmhub;
        XXmhub2m = XXmhubm.*XXmhubm;
        %	    
        XXmhubp(XXmhubp == 0) = eps;
        XXmhub(XXmhub == 0) = eps;
        XXmhubm(XXmhubm == 0) = eps;
        %	    
        XXmhub2p(XXmhub2p == 0) = eps;
        XXmhub2(XXmhub2 == 0) = eps;
        XXmhub2m(XXmhub2m == 0) = eps;
        %
        % FLR factor k_perp*rho_perp
        % 
        XXZb_ippj = -XXnperp_rf*betath_ref.*XXpnpp.*sqrt(XX1mmhu2).*XXomega_rf./sqrt(XXpsib)./XXomegac;
        XXZb_ipj = -XXnperp_rf*betath_ref.*XXpnp.*sqrt(XX1mmhu2).*XXomega_rf./sqrt(XXpsib)./XXomegac;
        XXZb_ij = -XXnperp_rf*betath_ref.*XXpn.*sqrt(XX1mmhu2).*XXomega_rf./sqrt(XXpsib)./XXomegac;
        XXZb_imj = -XXnperp_rf*betath_ref.*XXpnm.*sqrt(XX1mmhu2).*XXomega_rf./sqrt(XXpsib)./XXomegac;
        XXZb_immj = -XXnperp_rf*betath_ref.*XXpnmm.*sqrt(XX1mmhu2).*XXomega_rf./sqrt(XXpsib)./XXomegac;
        XXZb_ijp = -XXnperp_rf*betath_ref.*XXpn.*sqrt(XX1mmhu2p).*XXomega_rf./sqrt(XXpsib)./XXomegac;
        XXZb_ijm = -XXnperp_rf*betath_ref.*XXpn.*sqrt(XX1mmhu2m).*XXomega_rf./sqrt(XXpsib)./XXomegac;
        %
        % Considers a square or a Gaussian shape for the spectrum,
        % depending upon the condition isnan of XXnparmin_rf and XXnpar_rf
        %
        XXmask_square = ~isnan(XXnparmin_rf) & ~isnan(XXnparmax_rf);%Square power spectrum in N//
        XXmask_gauss = ~isnan(XXnpar_rf) & ~isnan(XXdnpar_rf);%Gaussian power spectrum in N//  
        %
        XXlre = (XXopt == 0); %(0): exact calculation for the Bessel functions, otherwise, limit k_perp*rho_perp << 1
        %
        XXold = (XXopt == 2);
        if max(XXold(:)) > 0
            if display_mode >= 1,info_dke_yp(1,'WARNING: Old technique for calculating the LH matrix coefficients, for comparaison with previous versions (Karney, Shoucri)');end
        end
        %
        % SUM OVER HARMONIC NUMBERS
        %
        for n_rf = 0:nmax_rf;
            %
            % Resonance Condition: resonant Npar
            %
            XXnparres_ippj = (XXgammapp - n_rf.*XXomegac.*XXpsib./XXomega_rf)/betath_ref./XXpnpp./XXmhub;
            XXnparres_ipj = (XXgammap - n_rf.*XXomegac.*XXpsib./XXomega_rf)/betath_ref./XXpnp./XXmhub;
            XXnparres_ij = (XXgamma - n_rf.*XXomegac.*XXpsib./XXomega_rf)/betath_ref./XXpn./XXmhub;
            XXnparres_imj = (XXgammam - n_rf.*XXomegac.*XXpsib./XXomega_rf)/betath_ref./XXpnm./XXmhub;
            XXnparres_immj = (XXgammamm - n_rf.*XXomegac.*XXpsib./XXomega_rf)/betath_ref./XXpnmm./XXmhub;
            XXnparres_ijp = (XXgamma - n_rf.*XXomegac.*XXpsib./XXomega_rf)/betath_ref./XXpn./XXmhubp;
            XXnparres_ijm = (XXgamma - n_rf.*XXomegac.*XXpsib./XXomega_rf)/betath_ref./XXpn./XXmhubm;
            %
            % Resonance Condition: delta function (normalized to: int(deltares d_npar) = 1)
            %
            XXdeltares_ippj = zeros(npn,nmhu,nr);
            XXdeltares_ipj = zeros(npn,nmhu,nr);
            XXdeltares_ij = zeros(npn,nmhu,nr);
            XXdeltares_imj = zeros(npn,nmhu,nr);
            XXdeltares_immj = zeros(npn,nmhu,nr);
            XXdeltares_ijp = zeros(npn,nmhu,nr);
            XXdeltares_ijm = zeros(npn,nmhu,nr);
        
            XXdeltares_ippj(XXmask_square) = (XXnparres_ippj(XXmask_square) > XXnparmin_rf(XXmask_square)).*(XXnparmax_rf(XXmask_square) >XXnparres_ippj(XXmask_square))./(XXnparmax_rf(XXmask_square) - XXnparmin_rf(XXmask_square));
            XXdeltares_ippj(XXmask_gauss) = exp(-(XXnparres_ippj(XXmask_gauss) - XXnpar_rf(XXmask_gauss)).^2./XXdnpar_rf(XXmask_gauss).^2)./XXdnpar_rf(XXmask_gauss)/sqrt(pi);
                   
            XXdeltares_ipj(XXmask_square) = (XXnparres_ipj(XXmask_square) > XXnparmin_rf(XXmask_square)).*(XXnparmax_rf(XXmask_square) >XXnparres_ipj(XXmask_square))./(XXnparmax_rf(XXmask_square) - XXnparmin_rf(XXmask_square));
            XXdeltares_ipj(XXmask_gauss) = exp(-(XXnparres_ipj(XXmask_gauss) - XXnpar_rf(XXmask_gauss)).^2./XXdnpar_rf(XXmask_gauss).^2)./XXdnpar_rf(XXmask_gauss)/sqrt(pi);
                   
            XXdeltares_ij(XXmask_square) = (XXnparres_ij(XXmask_square) > XXnparmin_rf(XXmask_square)).*(XXnparmax_rf(XXmask_square) >XXnparres_ij(XXmask_square))./(XXnparmax_rf(XXmask_square) - XXnparmin_rf(XXmask_square));
            XXdeltares_ij(XXmask_gauss) = exp(-(XXnparres_ij(XXmask_gauss) - XXnpar_rf(XXmask_gauss)).^2./XXdnpar_rf(XXmask_gauss).^2)./XXdnpar_rf(XXmask_gauss)/sqrt(pi);
                   
            XXdeltares_imj(XXmask_square) = (XXnparres_imj(XXmask_square) > XXnparmin_rf(XXmask_square)).*(XXnparmax_rf(XXmask_square) >XXnparres_imj(XXmask_square))./(XXnparmax_rf(XXmask_square) - XXnparmin_rf(XXmask_square));
            XXdeltares_imj(XXmask_gauss) = exp(-(XXnparres_imj(XXmask_gauss) - XXnpar_rf(XXmask_gauss)).^2./XXdnpar_rf(XXmask_gauss).^2)./XXdnpar_rf(XXmask_gauss)/sqrt(pi);
                   
            XXdeltares_immj(XXmask_square) = (XXnparres_immj(XXmask_square) > XXnparmin_rf(XXmask_square)).*(XXnparmax_rf(XXmask_square) >XXnparres_immj(XXmask_square))./(XXnparmax_rf(XXmask_square) - XXnparmin_rf(XXmask_square));
            XXdeltares_immj(XXmask_gauss) = exp(-(XXnparres_immj(XXmask_gauss) - XXnpar_rf(XXmask_gauss)).^2./XXdnpar_rf(XXmask_gauss).^2)./XXdnpar_rf(XXmask_gauss)/sqrt(pi);
                   
            XXdeltares_ijp(XXmask_square) = (XXnparres_ijp(XXmask_square) > XXnparmin_rf(XXmask_square)).*(XXnparmax_rf(XXmask_square) >XXnparres_ijp(XXmask_square))./(XXnparmax_rf(XXmask_square) - XXnparmin_rf(XXmask_square));
            XXdeltares_ijp(XXmask_gauss) = exp(-(XXnparres_ijp(XXmask_gauss) - XXnpar_rf(XXmask_gauss)).^2./XXdnpar_rf(XXmask_gauss).^2)./XXdnpar_rf(XXmask_gauss)/sqrt(pi);
                   
            XXdeltares_ijm(XXmask_square) = (XXnparres_ijm(XXmask_square) > XXnparmin_rf(XXmask_square)).*(XXnparmax_rf(XXmask_square) >XXnparres_ijm(XXmask_square))./(XXnparmax_rf(XXmask_square) - XXnparmin_rf(XXmask_square));
            XXdeltares_ijm(XXmask_gauss) = exp(-(XXnparres_ijm(XXmask_gauss) - XXnpar_rf(XXmask_gauss)).^2./XXdnpar_rf(XXmask_gauss).^2)./XXdnpar_rf(XXmask_gauss)/sqrt(pi);
            %            
            % Select only relevant harmonics
            %
            if max(max(max(max(XXdeltares_ij)))) < 1e-10 %this harmonic is not a significant contribution 
                continue
            end
            %
            %Old technique for calculating the LH matrix coefficients, for comparaison with previous versions (Karney, Shoucri)
            %
            XXdeltares_old_ij = XXdeltares_ij;
            %
            XXdeltares_old_ippj = zeros(size(XXdeltares_old_ij)); 
            XXdeltares_old_ipj = zeros(size(XXdeltares_old_ij));
            XXdeltares_old_imj = zeros(size(XXdeltares_old_ij)); 
            XXdeltares_old_immj = zeros(size(XXdeltares_old_ij)); 
            XXdeltares_old_ijp = zeros(size(XXdeltares_old_ij)); 
            XXdeltares_old_ijm = zeros(size(XXdeltares_old_ij)); 
            %
            XXdeltares_old_ippj(1:npn-1,:,:,:) = XXdeltares_old_ij(2:npn,:,:,:);XXdeltares_old_ippj(npn,:,:,:) = 0;
            XXdeltares_old_immj(2:npn,:,:,:) = XXdeltares_old_ij(1:npn-1,:,:,:);XXdeltares_old_immj(1,:,:,:) = 0;
            XXdeltares_old_ijpp(:,1:nmhu-1,:,:) = XXdeltares_old_ij(:,2:nmhu,:,:);XXdeltares_old_ijpp(:,nmhu,:,:,:) = 0;
            XXdeltares_old_ijmm(:,2:nmhu,:,:) = XXdeltares_old_ij(:,1:nmhu-1,:,:);XXdeltares_old_ijmm(:,1,:,:) = 0;
            XXdeltares_old_ipj = XXdeltares_old_ippj.*(1-XXdeltap_ipj) + XXdeltares_old_ij.*XXdeltap_ipj; 
            XXdeltares_old_imj = XXdeltares_old_ij.*(1-XXdeltap_imj) + XXdeltares_old_immj.*XXdeltap_imj;
            XXdeltares_old_ijp = XXdeltares_old_ijpp.*(1-XXdeltam_ijp) + XXdeltares_old_ij.*XXdeltam_ijp;
            XXdeltares_old_ijm = XXdeltares_old_ij.*(1-XXdeltam_ijm) + XXdeltares_old_ijmm.*XXdeltam_ijm;
            %
            %Old LH operator: 1/vpar dependence removed (Karney, Shoucri)
            %
            XXdeltares_old_ippj = XXdeltares_old_ippj.*XXpnpp.*abs(XXmhu)./XXgammapp;
            XXdeltares_old_ipj = XXdeltares_old_ipj.*XXpnp.*abs(XXmhu)./XXgammap;
            XXdeltares_old_ij = XXdeltares_old_ij.*XXpn.*abs(XXmhu)./XXgamma;
            XXdeltares_old_imj = XXdeltares_old_imj.*XXpnm.*abs(XXmhu)./XXgammam;
            XXdeltares_old_immj = XXdeltares_old_immj.*XXpnmm.*abs(XXmhu)./XXgammamm;
            XXdeltares_old_ijp = XXdeltares_old_ijp.*XXpn.*abs(XXmhup)./XXgamma;
            XXdeltares_old_ijm = XXdeltares_old_ijm.*XXpn.*abs(XXmhum)./XXgamma;
            %
            XXdeltares_ippj = XXold.*XXdeltares_old_ippj + ~XXold.*XXdeltares_ippj;
            XXdeltares_ipj = XXold.*XXdeltares_old_ipj + ~XXold.*XXdeltares_ipj;
            XXdeltares_ij = XXold.*XXdeltares_old_ij + ~XXold.*XXdeltares_ij;
            XXdeltares_imj = XXold.*XXdeltares_old_imj + ~XXold.*XXdeltares_imj;
            XXdeltares_immj = XXold.*XXdeltares_old_immj + ~XXold.*XXdeltares_immj;
            XXdeltares_ijp = XXold.*XXdeltares_old_ijp + ~XXold.*XXdeltares_ijp;
            XXdeltares_ijm = XXold.*XXdeltares_old_ijm + ~XXold.*XXdeltares_ijm;
            %
            % Polarization term 
            %
            % Polarization vector is normalized to 1.  
            %
            XXpolb_ippj = XXepolp_rf.*besselj_dke_jd(n_rf + 1,XXZb_ippj,XXlre)/sqrt(2) + XXepolm_rf.*besselj_dke_jd(n_rf - 1,XXZb_ippj,XXlre)/sqrt(2)...
               - XXmhub.*XXepolz_rf.*besselj_dke_jd(n_rf,XXZb_ippj,XXlre)./sqrt(XXpsib.*XX1mmhu2);
            XXpolb_ipj = XXepolp_rf.*besselj_dke_jd(n_rf + 1,XXZb_ipj,XXlre)/sqrt(2) + XXepolm_rf.*besselj_dke_jd(n_rf - 1,XXZb_ipj,XXlre)/sqrt(2)...
               - XXmhub.*XXepolz_rf.*besselj_dke_jd(n_rf,XXZb_ipj,XXlre)./sqrt(XXpsib.*XX1mmhu2);
            XXpolb_ij = XXepolp_rf.*besselj_dke_jd(n_rf + 1,XXZb_ij,XXlre)/sqrt(2) + XXepolm_rf.*besselj_dke_jd(n_rf - 1,XXZb_ij,XXlre)/sqrt(2)...
               - XXmhub.*XXepolz_rf.*besselj_dke_jd(n_rf,XXZb_ij,XXlre)./sqrt(XXpsib.*XX1mmhu2);
            XXpolb_imj = XXepolp_rf.*besselj_dke_jd(n_rf + 1,XXZb_imj,XXlre)/sqrt(2) + XXepolm_rf.*besselj_dke_jd(n_rf - 1,XXZb_imj,XXlre)/sqrt(2)...
               - XXmhub.*XXepolz_rf.*besselj_dke_jd(n_rf,XXZb_imj,XXlre)./sqrt(XXpsib.*XX1mmhu2);
            XXpolb_immj = XXepolp_rf.*besselj_dke_jd(n_rf + 1,XXZb_immj,XXlre)/sqrt(2) + XXepolm_rf.*besselj_dke_jd(n_rf - 1,XXZb_immj,XXlre)/sqrt(2)...
               - XXmhub.*XXepolz_rf.*besselj_dke_jd(n_rf,XXZb_immj,XXlre)./sqrt(XXpsib.*XX1mmhu2);
            XXpolb_ijp = XXepolp_rf.*besselj_dke_jd(n_rf + 1,XXZb_ijp,XXlre)/sqrt(2) + XXepolm_rf.*besselj_dke_jd(n_rf - 1,XXZb_ijp,XXlre)/sqrt(2)...
               - XXmhubp.*XXepolz_rf.*besselj_dke_jd(n_rf,XXZb_ijp,XXlre)./sqrt(XXpsib.*XX1mmhu2p);
            XXpolb_ijm = XXepolp_rf.*besselj_dke_jd(n_rf + 1,XXZb_ijm,XXlre)/sqrt(2) + XXepolm_rf.*besselj_dke_jd(n_rf - 1,XXZb_ijm,XXlre)/sqrt(2)...
               - XXmhubm.*XXepolz_rf.*besselj_dke_jd(n_rf,XXZb_ijm,XXlre)./sqrt(XXpsib.*XX1mmhu2m);    
            %
            %Sum over sigma for trapped particles - case FP
            %
            XXrespol_ippj = XXheaviside.*(XXdeltares_ippj.*abs(XXpolb_ippj).^2) + ~XXheaviside.*(XXdeltares_ippj.*abs(XXpolb_ippj).^2 + flipdim(XXdeltares_ippj.*abs(XXpolb_ippj).^2,2))/2;       
            XXrespol_ipj = XXheaviside.*(XXdeltares_ipj.*abs(XXpolb_ipj).^2) + ~XXheaviside.*(XXdeltares_ipj.*abs(XXpolb_ipj).^2 + flipdim(XXdeltares_ipj.*abs(XXpolb_ipj).^2,2))/2;       
            XXrespol_ij = XXheaviside.*(XXdeltares_ij.*abs(XXpolb_ij).^2) + ~XXheaviside.*(XXdeltares_ij.*abs(XXpolb_ij).^2 + flipdim(XXdeltares_ij.*abs(XXpolb_ij).^2,2))/2;       
            XXrespol_imj = XXheaviside.*(XXdeltares_imj.*abs(XXpolb_imj).^2) + ~XXheaviside.*(XXdeltares_imj.*abs(XXpolb_imj).^2 + flipdim(XXdeltares_imj.*abs(XXpolb_imj).^2,2))/2;       
            XXrespol_immj = XXheaviside.*(XXdeltares_immj.*abs(XXpolb_immj).^2) + ~XXheaviside.*(XXdeltares_immj.*abs(XXpolb_immj).^2 + flipdim(XXdeltares_immj.*abs(XXpolb_immj).^2,2))/2;      
            XXrespol_ijp = XXheaviside_p.*(XXdeltares_ijp.*abs(XXpolb_ijp).^2) + ~XXheaviside_p.*(XXdeltares_ijp.*abs(XXpolb_ijp).^2 + flipdim(XXdeltares_ijm.*abs(XXpolb_ijm).^2,2))/2;% -mhup = fliplr(mhum)     
            XXrespol_ijm = XXheaviside_m.*(XXdeltares_ijm.*abs(XXpolb_ijm).^2) + ~XXheaviside_m.*(XXdeltares_ijm.*abs(XXpolb_ijm).^2 + flipdim(XXdeltares_ijp.*abs(XXpolb_ijp).^2,2))/2;% -mhum = fliplr(mhup)        
            %
            %QL Diffusion Coefficient
            %    
            XXDrf_ippj = XXrespol_ippj.*XXpsib.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgammapp./XXpnpp./abs(XXmhu)./XXmhub2./XXlambda./XXqtilde;
            XXDrf_ipj = XXrespol_ipj.*XXpsib.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgammap./XXpnp./abs(XXmhu)./XXmhub2./XXlambda./XXqtilde;
            XXDrf_ij = XXrespol_ij.*XXpsib.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhu)./XXmhub2./XXlambda./XXqtilde;
            XXDrf_imj = XXrespol_imj.*XXpsib.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgammam./XXpnm./abs(XXmhu)./XXmhub2./XXlambda./XXqtilde;
            XXDrf_immj = XXrespol_immj.*XXpsib.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgammamm./XXpnmm./abs(XXmhu)./XXmhub2./XXlambda./XXqtilde;
            XXDrf_ijp = XXrespol_ijp.*XXpsib.*XXmhu2p.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhup)./XXmhub2p./XXlambdap./XXqtilde;
            XXDrf_ijm = XXrespol_ijm.*XXpsib.*XXmhu2m.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhum)./XXmhub2m./XXlambdam./XXqtilde;   
            % 
            %QL diffusion tensor elements
            %
            ZXXD_rf.pp_ippj = ZXXD_rf.pp_ippj + XX1mmhu2.*XXDrf_ippj;
            ZXXD_rf.pp_ipj = ZXXD_rf.pp_ipj + XX1mmhu2.*XXDrf_ipj;
            ZXXD_rf.pp_ij = ZXXD_rf.pp_ij + XX1mmhu2.*XXDrf_ij;
            ZXXD_rf.parpar_ij = ZXXD_rf.parpar_ij + XX1mmhu2.*(1 - n_rf.*XXomegac./XXomega_rf).^2.*XXDrf_ij./XXmhu2;
            ZXXD_rf.pp_imj = ZXXD_rf.pp_imj + XX1mmhu2.*XXDrf_imj;
            ZXXD_rf.pp_immj = ZXXD_rf.pp_immj + XX1mmhu2.*XXDrf_immj;
            %
            ZXXD_rf.pm_ipj = ZXXD_rf.pm_ipj - sqrt(XX1mmhu2).*(XX1mmhu2 - n_rf.*XXomegac./XXomega_rf).*XXDrf_ipj./XXmhu;
            ZXXD_rf.pm_ij = ZXXD_rf.pm_ij - sqrt(XX1mmhu2).*(XX1mmhu2 - n_rf.*XXomegac./XXomega_rf).*XXDrf_ij./XXmhu;
            ZXXD_rf.pm_imj = ZXXD_rf.pm_imj - sqrt(XX1mmhu2).*(XX1mmhu2 - n_rf.*XXomegac./XXomega_rf).*XXDrf_imj./XXmhu;
            %
            ZXXD_rf.mp_ijp = ZXXD_rf.mp_ijp - sqrt(XX1mmhu2p).*(XX1mmhu2p - n_rf.*XXomegac./XXomega_rf).*XXDrf_ijp./XXmhup;
            ZXXD_rf.mp_ij = ZXXD_rf.mp_ij - sqrt(XX1mmhu2).*(XX1mmhu2 - n_rf.*XXomegac./XXomega_rf).*XXDrf_ij./XXmhu;
            ZXXD_rf.mp_ijm = ZXXD_rf.mp_ijm - sqrt(XX1mmhu2m).*(XX1mmhu2m - n_rf.*XXomegac./XXomega_rf).*XXDrf_ijm./XXmhum;
            %
            ZXXD_rf.mm_ijp = ZXXD_rf.mm_ijp + (XX1mmhu2p - n_rf.*XXomegac./XXomega_rf).^2.*XXDrf_ijp./XXmhu2p;
            ZXXD_rf.mm_ijm = ZXXD_rf.mm_ijm + (XX1mmhu2m - n_rf.*XXomegac./XXomega_rf).^2.*XXDrf_ijm./XXmhu2m;
            %
            if dke_mode == 1
                %
                %Sum over sigma for trapped particles - case DKE
                %
                XXrespol_tp_ippj = XXheaviside.*(XXdeltares_ippj.*abs(XXpolb_ippj).^2) + ~XXheaviside.*XXsigma.*(XXdeltares_ippj.*abs(XXpolb_ippj).^2.*XXsigma + flipdim(XXdeltares_ippj.*abs(XXpolb_ippj).^2.*XXsigma,2))/2;       
                XXrespol_tp_ipj = XXheaviside.*(XXdeltares_ipj.*abs(XXpolb_ipj).^2) + ~XXheaviside.*XXsigma.*(XXdeltares_ipj.*abs(XXpolb_ipj).^2.*XXsigma + flipdim(XXdeltares_ipj.*abs(XXpolb_ipj).^2.*XXsigma,2))/2;       
                XXrespol_tp_ij = XXheaviside.*(XXdeltares_ij.*abs(XXpolb_ij).^2) + ~XXheaviside.*XXsigma.*(XXdeltares_ij.*abs(XXpolb_ij).^2.*XXsigma + flipdim(XXdeltares_ij.*abs(XXpolb_ij).^2.*XXsigma,2))/2;       
                XXrespol_tp_imj = XXheaviside.*(XXdeltares_imj.*abs(XXpolb_imj).^2) + ~XXheaviside.*XXsigma.*(XXdeltares_imj.*abs(XXpolb_imj).^2.*XXsigma + flipdim(XXdeltares_imj.*abs(XXpolb_imj).^2.*XXsigma,2))/2;       
                XXrespol_tp_immj = XXheaviside.*(XXdeltares_immj.*abs(XXpolb_immj).^2) + ~XXheaviside.*XXsigma.*(XXdeltares_immj.*abs(XXpolb_immj).^2.*XXsigma + flipdim(XXdeltares_immj.*abs(XXpolb_immj).^2.*XXsigma,2))/2;      
                XXrespol_tp_ijp = XXheaviside_p.*(XXdeltares_ijp.*abs(XXpolb_ijp).^2) + ~XXheaviside_p.*XXsigmap.*(XXdeltares_ijp.*abs(XXpolb_ijp).^2.*XXsigmap + flipdim(XXdeltares_ijm.*abs(XXpolb_ijm).^2.*XXsigmam,2))/2;% -mhup = fliplr(mhum)     
                XXrespol_tp_ijm = XXheaviside_m.*(XXdeltares_ijm.*abs(XXpolb_ijm).^2) + ~XXheaviside_m.*XXsigmam.*(XXdeltares_ijm.*abs(XXpolb_ijm).^2.*XXsigmam + flipdim(XXdeltares_ijp.*abs(XXpolb_ijp).^2.*XXsigmap,2))/2;% -mhum = fliplr(mhup)        
                %
                %QL Diffusion Coefficient
                %    
                XXDrf_D_tp_ippj = XXrespol_tp_ippj.*XXmhu.*XXqtildeb_rf.*XXmaskb.*XXgammapp./XXpnpp./abs(XXmhu)./XXmhub./XXlambda./XXqtilde;
                XXDrf_D_tp_ipj = XXrespol_tp_ipj.*XXmhu.*XXqtildeb_rf.*XXmaskb.*XXgammap./XXpnp./abs(XXmhu)./XXmhub./XXlambda./XXqtilde;
                XXDrf_D_tp_ij = XXrespol_tp_ij.*XXmhu.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhu)./XXmhub./XXlambda./XXqtilde;
                XXDrf_D_tp_imj = XXrespol_tp_imj.*XXmhu.*XXqtildeb_rf.*XXmaskb.*XXgammam./XXpnm./abs(XXmhu)./XXmhub./XXlambda./XXqtilde;
                XXDrf_D_tp_immj = XXrespol_tp_immj.*XXmhu.*XXqtildeb_rf.*XXmaskb.*XXgammamm./XXpnmm./abs(XXmhu)./XXmhub./XXlambda./XXqtilde;
                XXDrf_D_tp_ijp = XXrespol_tp_ijp.*XXmhup.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhup)./XXmhubp./XXlambdap./XXqtilde;
                XXDrf_D_tp_ijm = XXrespol_tp_ijm.*XXmhum.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhum)./XXmhubm./XXlambdam./XXqtilde;   
                %    
                XXDrf_F_tp_ippj = XXrespol_tp_ippj.*(1 - XXpsib).*XXmhu.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgammapp./XXpnpp./abs(XXmhu)./XXmhub./XXmhub2./XXlambda./XXqtilde;
                XXDrf_F_tp_ipj = XXrespol_tp_ipj.*(1 - XXpsib).*XXmhu.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgammap./XXpnp./abs(XXmhu)./XXmhub./XXmhub2./XXlambda./XXqtilde;
                XXDrf_F_tp_ij = XXrespol_tp_ij.*(1 - XXpsib).*XXmhu.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhu)./XXmhub./XXmhub2./XXlambda./XXqtilde;
                XXDrf_F_tp_imj = XXrespol_tp_imj.*(1 - XXpsib).*XXmhu.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgammam./XXpnm./abs(XXmhu)./XXmhub./XXmhub2./XXlambda./XXqtilde;
                XXDrf_F_tp_immj = XXrespol_tp_immj.*(1 - XXpsib).*XXmhu.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgammamm./XXpnmm./abs(XXmhu)./XXmhub./XXmhub2./XXlambda./XXqtilde;
                XXDrf_F_tp_ijp = XXrespol_tp_ijp.*(1 - XXpsib).*XXmhup.*XXmhu2p.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhup)./XXmhubp./XXmhub2p./XXlambdap./XXqtilde;
                XXDrf_F_tp_ijm = XXrespol_tp_ijm.*(1 - XXpsib).*XXmhum.*XXmhu2m.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhum)./XXmhubm./XXmhub2m./XXlambdam./XXqtilde;       
                %
                % ---------------- Terms for wave-induced radial transport by adjoint technique (P. Helander model) ----------------
                %         	
         	    XXDrf_F1_tp_ijp = XXrespol_tp_ijp.*XXmhup.*XXmhu2p.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhup)./XXmhubp./XXmhub2p./XXlambdap./XXqtilde;
                XXDrf_F1_tp_ij = XXrespol_tp_ij.*XXmhu.*XXmhu2.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhu)./XXmhub./XXmhub2./XXlambda./XXqtilde;
                XXDrf_F1_tp_ijm = XXrespol_tp_ijm.*XXmhum.*XXmhu2m.*XXqtildeb_rf.*XXmaskb.*XXgamma./XXpn./abs(XXmhum)./XXmhubm./XXmhub2m./XXlambdam./XXqtilde;       
                % 
                %QL diffusion tensor elements
                %
                ZXXD_rf_tp.pp_ippj = ZXXD_rf_tp.pp_ippj + XX1mmhu2(:,:,rdke).*XXDrf_D_tp_ippj(:,:,rdke);
                ZXXD_rf_tp.pp_ipj = ZXXD_rf_tp.pp_ipj + XX1mmhu2(:,:,rdke).*XXDrf_D_tp_ipj(:,:,rdke);
                ZXXD_rf_tp.pp_ij = ZXXD_rf_tp.pp_ij + XX1mmhu2(:,:,rdke).*XXDrf_D_tp_ij(:,:,rdke);
                ZXXD_rf_tp.pp_imj = ZXXD_rf_tp.pp_imj + XX1mmhu2(:,:,rdke).*XXDrf_D_tp_imj(:,:,rdke);
                ZXXD_rf_tp.pp_immj = ZXXD_rf_tp.pp_immj + XX1mmhu2(:,:,rdke).*XXDrf_D_tp_immj(:,:,rdke);
            %
                ZXXD_rf_tp.pm_ipj = ZXXD_rf_tp.pm_ipj - sqrt(XX1mmhu2(:,:,rdke)).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_D_tp_ipj(:,:,rdke)./XXmhu(:,:,rdke);
                ZXXD_rf_tp.pm_ij = ZXXD_rf_tp.pm_ij - sqrt(XX1mmhu2(:,:,rdke)).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_D_tp_ij(:,:,rdke)./XXmhu(:,:,rdke);
                ZXXD_rf_tp.pm_imj = ZXXD_rf_tp.pm_imj - sqrt(XX1mmhu2(:,:,rdke)).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_D_tp_imj(:,:,rdke)./XXmhu(:,:,rdke);
            %
                ZXXD_rf_tp.mp_ijp = ZXXD_rf_tp.mp_ijp - sqrt(XX1mmhu2p(:,:,rdke)).*(XX1mmhu2p(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_D_tp_ijp(:,:,rdke)./XXmhup(:,:,rdke);
                ZXXD_rf_tp.mp_ij = ZXXD_rf_tp.mp_ij - sqrt(XX1mmhu2(:,:,rdke)).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_D_tp_ij(:,:,rdke)./XXmhu(:,:,rdke);
                ZXXD_rf_tp.mp_ijm = ZXXD_rf_tp.mp_ijm - sqrt(XX1mmhu2m(:,:,rdke)).*(XX1mmhu2m (:,:,rdke)- n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_D_tp_ijm(:,:,rdke)./XXmhum(:,:,rdke);
            %
                ZXXD_rf_tp.mm_ijp = ZXXD_rf_tp.mm_ijp + (XX1mmhu2p(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).^2.*XXDrf_D_tp_ijp(:,:,rdke)./XXmhu2p(:,:,rdke);
                ZXXD_rf_tp.mm_ijm = ZXXD_rf_tp.mm_ijm + (XX1mmhu2m(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).^2.*XXDrf_D_tp_ijm(:,:,rdke)./XXmhu2m(:,:,rdke);
            %
            % ---------------- Terms for wave-induced radial transport by adjoint technique (P. Helander model) ----------------
            %
                ZXXD_rf_tp.mp1_ijp = ZXXD_rf_tp.mp1_ijp - sqrt(XX1mmhu2p(:,:,rdke)).*(XX1mmhu2p(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*(XXDrf_D_tp_ijp(:,:,rdke) + XXDrf_F1_tp_ijp(:,:,rdke))./XXmhup(:,:,rdke);%XXDmp_rf_ijp
                ZXXD_rf_tp.mp1_ij = ZXXD_rf_tp.mp1_ij - sqrt(XX1mmhu2(:,:,rdke)).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*(XXDrf_D_tp_ij(:,:,rdke) + XXDrf_F1_tp_ij(:,:,rdke))./XXmhu(:,:,rdke);%XXDmp_rf_ij
                ZXXD_rf_tp.mp1_ijm = ZXXD_rf_tp.mp1_ijm - sqrt(XX1mmhu2m(:,:,rdke)).*(XX1mmhu2m (:,:,rdke)- n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*(XXDrf_D_tp_ijm(:,:,rdke) + XXDrf_F1_tp_ijm(:,:,rdke))./XXmhum(:,:,rdke);%XXDmp_rf_ijm
            %
                ZXXD_rf_tp.mm1_ijp = ZXXD_rf_tp.mm1_ijp + (XX1mmhu2p(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).^2.*(XXDrf_D_tp_ijp(:,:,rdke)+ XXDrf_F1_tp_ijp(:,:,rdke))./XXmhu2p(:,:,rdke);%XXDmm_rf_ijp
                ZXXD_rf_tp.mm1_ijm = ZXXD_rf_tp.mm1_ijm + (XX1mmhu2m(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).^2.*(XXDrf_D_tp_ijm(:,:,rdke) + XXDrf_F1_tp_ijm(:,:,rdke))./XXmhu2m(:,:,rdke);%XXDmm_rf_ijm
            %
            % ------------------------------------------------------------------------------------------------------------------
            %
            %
                ZXXF_rf_tp.p_ippj = ZXXF_rf_tp.p_ippj - XX1mmhu2(:,:,rdke).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_F_tp_ippj(:,:,rdke)./XXmhu2(:,:,rdke)./XXmhu2(:,:,rdke)./XXpnpp(:,:,rdke); 
                ZXXF_rf_tp.p_ipj = ZXXF_rf_tp.p_ipj - XX1mmhu2(:,:,rdke).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_F_tp_ipj(:,:,rdke)./XXmhu2(:,:,rdke)./XXmhu2(:,:,rdke)./XXpnp(:,:,rdke);
                ZXXF_rf_tp.p_ij = ZXXF_rf_tp.p_ij - XX1mmhu2(:,:,rdke).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_F_tp_ij(:,:,rdke)./XXmhu2(:,:,rdke)./XXmhu2(:,:,rdke)./XXpn(:,:,rdke); 
                ZXXF_rf_tp.p_imj = ZXXF_rf_tp.p_imj - XX1mmhu2(:,:,rdke).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_F_tp_imj(:,:,rdke)./XXmhu2(:,:,rdke)./XXmhu2(:,:,rdke)./XXpnm(:,:,rdke);
                ZXXF_rf_tp.p_immj = ZXXF_rf_tp.p_immj - XX1mmhu2(:,:,rdke).*(XX1mmhu2(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).*XXDrf_F_tp_immj(:,:,rdke)./XXmhu2(:,:,rdke)./XXmhu2(:,:,rdke)./XXpnmm(:,:,rdke);
            %
                ZXXF_rf_tp.m_ijp = ZXXF_rf_tp.m_ijp + sqrt(XX1mmhu2p(:,:,rdke)).*(XX1mmhu2p(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).^2.*XXDrf_F_tp_ijp(:,:,rdke)./XXmhu2p(:,:,rdke)./XXmhu2p(:,:,rdke)./XXmhup(:,:,rdke)./XXpn(:,:,rdke);
                ZXXF_rf_tp.m_ijm = ZXXF_rf_tp.m_ijm + sqrt(XX1mmhu2m(:,:,rdke)).*(XX1mmhu2m(:,:,rdke) - n_rf.*XXomegac(:,:,rdke)./XXomega_rf(:,:,rdke)).^2.*XXDrf_F_tp_ijm(:,:,rdke)./XXmhu2m(:,:,rdke)./XXmhu2m(:,:,rdke)./XXmhum(:,:,rdke)./XXpn(:,:,rdke);
            else
                ZXXD_rf_tp = NaN;
                ZXXF_rf_tp = NaN;
            end            
            %
        end
        %
        if dke_mode == 0,
            save([fullfile(temppath,'temp_DQL_'),save_id,'_',ynum,'.mat'],'ZXXD_rf');
        else
            save([fullfile(temppath,'temp_DQL_'),save_id,'_',ynum,'.mat'],'ZXXD_rf','ZXXD_rf_tp','ZXXF_rf_tp');
        end            
        %
        if display_mode >= 1,info_dke_yp(2,['RF matrix coefficients for effective ray #',ynum,' calculated and saved.']);end	
        %
    end
    %
    ZYXXD_rf.pp_ippj = ZYXXD_rf.pp_ippj + ZXXD_rf.pp_ippj.*XXD0_rf;
    ZYXXD_rf.pp_ipj = ZYXXD_rf.pp_ipj + ZXXD_rf.pp_ipj.*XXD0_rf;
    ZYXXD_rf.pp_ij = ZYXXD_rf.pp_ij + ZXXD_rf.pp_ij.*XXD0_rf;
    ZYXXD_rf.pp_imj = ZYXXD_rf.pp_imj + ZXXD_rf.pp_imj.*XXD0_rf;
    ZYXXD_rf.pp_immj = ZYXXD_rf.pp_immj + ZXXD_rf.pp_immj.*XXD0_rf;
    ZYXXD_rf.pm_ipj = ZYXXD_rf.pm_ipj + ZXXD_rf.pm_ipj .*XXD0_rf;
    ZYXXD_rf.pm_ij = ZYXXD_rf.pm_ij + ZXXD_rf.pm_ij.*XXD0_rf;
    ZYXXD_rf.parpar_ij = ZYXXD_rf.parpar_ij + ZXXD_rf.parpar_ij.*XXD0_rf;
    ZYXXD_rf.pm_imj = ZYXXD_rf.pm_imj + ZXXD_rf.pm_imj.*XXD0_rf;
    ZYXXD_rf.mp_ijp = ZYXXD_rf.mp_ijp + ZXXD_rf.mp_ijp.*XXD0_rf;
    ZYXXD_rf.mp_ij = ZYXXD_rf.mp_ij + ZXXD_rf.mp_ij.*XXD0_rf;
    ZYXXD_rf.mp_ijm = ZYXXD_rf.mp_ijm + ZXXD_rf.mp_ijm.*XXD0_rf;
    ZYXXD_rf.mm_ijp = ZYXXD_rf.mm_ijp + ZXXD_rf.mm_ijp.*XXD0_rf;
    ZYXXD_rf.mm_ijm = ZYXXD_rf.mm_ijm + ZXXD_rf.mm_ijm.*XXD0_rf;
    %
    if dke_mode == 1
    %
        ZYXXD_rf_tp.pp_ippj = ZYXXD_rf_tp.pp_ippj + ZXXD_rf_tp.pp_ippj.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.pp_ipj = ZYXXD_rf_tp.pp_ipj + ZXXD_rf_tp.pp_ipj.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.pp_ij = ZYXXD_rf_tp.pp_ij + ZXXD_rf_tp.pp_ij.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.pp_imj = ZYXXD_rf_tp.pp_imj + ZXXD_rf_tp.pp_imj.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.pp_immj = ZYXXD_rf_tp.pp_immj + ZXXD_rf_tp.pp_immj.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.pm_ipj = ZYXXD_rf_tp.pm_ipj + ZXXD_rf_tp.pm_ipj.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.pm_ij = ZYXXD_rf_tp.pm_ij + ZXXD_rf_tp.pm_ij.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.pm_imj = ZYXXD_rf_tp.pm_imj + ZXXD_rf_tp.pm_imj.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.mp_ijp = ZYXXD_rf_tp.mp_ijp + ZXXD_rf_tp.mp_ijp.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.mp_ij = ZYXXD_rf_tp.mp_ij + ZXXD_rf_tp.mp_ij.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.mp_ijm = ZYXXD_rf_tp.mp_ijm + ZXXD_rf_tp.mp_ijm.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.mm_ijp = ZYXXD_rf_tp.mm_ijp + ZXXD_rf_tp.mm_ijp.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.mm_ijm = ZYXXD_rf_tp.mm_ijm + ZXXD_rf_tp.mm_ijm.*XXD0_rf(:,:,rdke);
    %
    	ZYXXF_rf_tp.p_ippj = ZYXXF_rf_tp.p_ippj + ZXXF_rf_tp.p_ippj.*XXD0_rf(:,:,rdke);
    	ZYXXF_rf_tp.p_ipj = ZYXXF_rf_tp.p_ipj + ZXXF_rf_tp.p_ipj.*XXD0_rf(:,:,rdke);
    	ZYXXF_rf_tp.p_ij = ZYXXF_rf_tp.p_ij + ZXXF_rf_tp.p_ij.*XXD0_rf(:,:,rdke);
    	ZYXXF_rf_tp.p_imj = ZYXXF_rf_tp.p_imj + ZXXF_rf_tp.p_imj.*XXD0_rf(:,:,rdke);
    	ZYXXF_rf_tp.p_immj = ZYXXF_rf_tp.p_immj + ZXXF_rf_tp.p_immj.*XXD0_rf(:,:,rdke);
    	ZYXXF_rf_tp.m_ijp = ZYXXF_rf_tp.m_ijp + ZXXF_rf_tp.m_ijp.*XXD0_rf(:,:,rdke);
    	ZYXXF_rf_tp.m_ijm = ZYXXF_rf_tp.m_ijm + ZXXF_rf_tp.m_ijm.*XXD0_rf(:,:,rdke);
    %
    % Wave-induced radial transport adjoint technique (P. Helander model)
    %
        ZYXXD_rf_tp.mp1_ijp = ZYXXD_rf_tp.mp1_ijp + ZXXD_rf_tp.mp1_ijp.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.mp1_ij = ZYXXD_rf_tp.mp1_ij + ZXXD_rf_tp.mp1_ij.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.mp1_ijm = ZYXXD_rf_tp.mp1_ijm + ZXXD_rf_tp.mp1_ijm.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.mm1_ijp = ZYXXD_rf_tp.mm1_ijp + ZXXD_rf_tp.mm1_ijp.*XXD0_rf(:,:,rdke);
        ZYXXD_rf_tp.mm1_ijm = ZYXXD_rf_tp.mm1_ijm + ZXXD_rf_tp.mm1_ijm.*XXD0_rf(:,:,rdke);
    %
    end
end