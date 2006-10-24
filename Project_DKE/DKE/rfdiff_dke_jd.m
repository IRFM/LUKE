function [ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = rfdiff_dke_jd(dkeparam,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,waveparam);
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
%       - gridindex_rf:     List of grid indices in resonant point vectors
%
% NOTE:
%
%   the first characters of a variable name are related to its structure:
%       - x_    1-D radial (rho)
%       - X_    2-D momentum (p,mhu) 
%       - Xx_   1-D momentum + 1-D radial (mhu,rho)
%       - xy_   1-D radial + 1-D ray number (rho,b)
%       - XX_   1-D radial + 2-D momentum (rho,p,mhu)
%
%   refer to documentation for detailed description    
%
% by J. Decker (MIT/RLE) <jodecker@mit.edu> and Y. Peysson CEA/DRFC <yves.peysson@cea.fr>
%
etime_rf = 0;
time0 = clock;
%
[qe,me] = pc_dke_yp;%Universal physics constant
%
rf_tol = eps('single');% threshold for calculation mask on deltares
%
n_rf_list = dkeparam.n_rf_list;
bounce_mode = dkeparam.bounce_mode;
dke_mode = dkeparam.dke_mode;
%
display_mode = display.display_mode;
%
theta = equilDKE.mtheta;
Xx = equilDKE.Xx;
Xy = equilDKE.Xy;
XBx = equilDKE.XBx;
XBy = equilDKE.XBy;
XBphi = equilDKE.XBphi;
xB0 = equilDKE.xB0;
Rp = equilDKE.Rp;
Zp = equilDKE.Zp;
%
Xmhup = gridDKE.Xmhup;
Xmhu = gridDKE.Xmhu;
Xmhum = gridDKE.Xmhum;
X1mmhu2p = gridDKE.X1mmhu2p;
X1mmhu2 = gridDKE.X1mmhu2;
X1mmhu2m = gridDKE.X1mmhu2m;
Xpnpp = gridDKE.Xpnpp;
Xpnp = gridDKE.Xpnp;
Xpn = gridDKE.Xpn;
Xpnm = gridDKE.Xpnm;
Xpnmm = gridDKE.Xpnmm;
%
Xgammapp = Zmomcoef.Xgammapp;
Xgammap = Zmomcoef.Xgammap;
Xgamma = Zmomcoef.Xgamma;
Xgammam = Zmomcoef.Xgammam;
Xgammamm = Zmomcoef.Xgammamm;
%
Xxlambdap = Zbouncecoef.Xxlambda_p;
Xxlambda = Zbouncecoef.Xxlambda;
Xxlambdam = Zbouncecoef.Xxlambda_m;
XXheavisidep = Zbouncecoef.XXheaviside_p;
XXheaviside = Zbouncecoef.XXheaviside;
XXheavisidem = Zbouncecoef.XXheaviside_m;
%
betath_ref = mksa.betath_ref;
%
rdke = radialDKE.r_dke;
%
% RF wave parameters
%
xyomega_rf =    single(waveparam(:,:,1));% RF wave frequency 
xyopt =         single(waveparam(:,:,2));% options for Larmor radius effects and/or LH calc.  0:exact, 1:approx (kperp*rhoe<<1), 2: kperp*rhoe<<1 and old LH calc. (Karney, Shoucri)                                        
xythetab_rf =   single(waveparam(:,:,3));% poloidal location of RF beam  (bounce_mode>0 only)
xyD0_rf =       single(waveparam(:,:,4));% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
xynparmin_rf =  single(waveparam(:,:,5));% Square N// spectrum: Lower limit
xynparmax_rf =  single(waveparam(:,:,6));% Square N// spectrum: Upper limit
xynpar_rf =     single(waveparam(:,:,7));% Gaussian N// spectrum: peak n//
xydnpar_rf =    single(waveparam(:,:,8));% Gaussian N// spectrum: width in n//
xynperp_rf =    single(waveparam(:,:,9));% RF wave : n_perp
xyepolp_rf =    single(waveparam(:,:,10));% RF wave : polarization plus
xyepolm_rf =    single(waveparam(:,:,11));% RF wave : polarization minus
xyepolz_rf =    single(waveparam(:,:,12));% RF wave : polarization parallel
%
clear dkeparam display equilDKE gridDKE Zmomcoef Zbouncecoef mksa radialDKE waveparam
%
[npn,nmhu] = size(Xpn);
nr = length(xB0);
nr_dke = length(rdke);
nb = size(xyomega_rf,2);
nn_rf = length(n_rf_list);
%
gridindex_rf.npn = npn;
gridindex_rf.nmhu = nmhu;
gridindex_rf.nr = nr;
gridindex_rf.nr_dke = nr_dke;
gridindex_rf.nb = nb;
gridindex_rf.nn_rf = nn_rf;
%
% mask calculation of point that must be calculated
%    
mask_p = zeros(0,0,'uint32');%mask of indices in the momentum grid        
mask_m = zeros(0,0,'uint32');%mask of indices in the pitch angle grid
mask_y = zeros(0,0,'uint32');%mask of indices in the ray list
mask_r = zeros(0,0,'uint32');%mask of indices in the radial grid
mask_n = zeros(0,0,'uint32');%mask of indices in the harmonic number list
mask_dke = zeros(0,0,'uint32');%mask of indices in the harmonic number list
%
% Case where no RF wave is to be accounted for
%
if nb == 0,
    ZXYD_rf = [];
    ZXYD_rf_tp = [];
    ZXYF_rf_tp = [];
    %
    gridindex_rf.mask_p = mask_p;
    gridindex_rf.mask_m = mask_m;
    gridindex_rf.mask_y = mask_y;
    gridindex_rf.mask_r = mask_r;
    gridindex_rf.mask_n = mask_n;
	gridindex_rf.mask_dke = mask_dke;
    %
    ZXYD_rf.pp_ippj = [];
    ZXYD_rf.pp_ipj = [];
    ZXYD_rf.pp_ij = [];
    ZXYD_rf.parpar_ij = [];
    ZXYD_rf.pp_imj = [];
    ZXYD_rf.pp_immj = [];
    ZXYD_rf.pm_ipj = [];
    ZXYD_rf.pm_ij = [];
    ZXYD_rf.pm_imj = [];
    ZXYD_rf.mp_ijp = [];
    ZXYD_rf.mp_ij = [];
    ZXYD_rf.mp_ijm = [];
    ZXYD_rf.mm_ijp = [];
    ZXYD_rf.mm_ijm = [];
%
    ZXYF_rf.p_ippj = []; 
    ZXYF_rf.p_ipj = [];    
    ZXYF_rf.p_ij = [];    
    ZXYF_rf.p_imj = [];    
    ZXYF_rf.p_immj = [];  
    ZXYF_rf.m_ijp = [];   
    ZXYF_rf.m_ijm = [];   
    %
    if dke_mode == 1,
        %
        ZXYD_rf_tp.pp_ippj = [];
        ZXYD_rf_tp.pp_ipj =  [];
        ZXYD_rf_tp.pp_ij =   [];
        ZXYD_rf_tp.pp_imj =  [];
        ZXYD_rf_tp.pp_immj = [];
        ZXYD_rf_tp.pm_ipj =  [];
        ZXYD_rf_tp.pm_ij =   [];
        ZXYD_rf_tp.pm_imj =  [];
        ZXYD_rf_tp.mp_ijp =  [];
        ZXYD_rf_tp.mp_ij =   [];
        ZXYD_rf_tp.mp_ijm =  [];
        ZXYD_rf_tp.mm_ijp =  [];
        ZXYD_rf_tp.mm_ijm =  [];
        %
        % ---------------- Terms for wave-induced radial transport by adjoint technique (P. Helander model) ----------------
        %
        ZXYD_rf_tp.mp1_ijp = [];
        ZXYD_rf_tp.mp1_ij =  [];
        ZXYD_rf_tp.mp1_ijm = [];
        ZXYD_rf_tp.mm1_ijp = [];
        ZXYD_rf_tp.mm1_ijm = [];
        %
        ZXYF_rf_tp.p_ippj =  [];
        ZXYF_rf_tp.p_ipj =   [];
        ZXYF_rf_tp.p_ij =    [];
        ZXYF_rf_tp.p_imj =   [];
        ZXYF_rf_tp.p_immj =  [];
        ZXYF_rf_tp.m_ijp =   [];
        ZXYF_rf_tp.m_ijm =   [];
    else
        ZXYD_rf_tp = NaN;
        ZXYF_rf_tp = NaN;
    end            
    %    
    return
end
%
% Magnetic geometry parameters at theta = thetab_rf
%
[xyBb_rf] = mg_interp_jd(theta,Xx,Xy,XBx,XBy,XBphi,xythetab_rf);
%
xyB0 = repmat(single(xB0).',[1,nb]);
%
if bounce_mode > 0,          
    %   
    xypsib = xyBb_rf./xyB0; %Ratio of magnetic fields at theta = thetab_rf
    xyomegac = qe*xyB0/me; % cyclotron frequency at B=Bmin 
    %
else
    %
    %   when bounce_mode = 0, we need to take the cyclotron frequency at theta = thetab_rf 
    %
    xypsib = ones(nr,nb,'single'); %Ratio of magnetic fields at theta = thetab_rf
    xyomegac = qe*xyBb_rf/me; % cyclotron frequency at B=Bmin 
    %
end
%
xyomegaratio = xyomega_rf./xyomegac;
%
xykperprho = xynperp_rf.*xyomegaratio*betath_ref;
xyZbfac = xykperprho./sqrt(xypsib);% momentum-independent factor in XYZb
%
% Considers a square or a Gaussian shape for the spectrum,
% depending upon the condition isnan of xynparmin_rf and xynpar_rf
%
xymask_square = ~isnan(xynparmin_rf) & ~isnan(xynparmax_rf);%Square power spectrum in N//
xymask_gauss = ~isnan(xynpar_rf) & ~isnan(xydnpar_rf);%Gaussian power spectrum in N//  
%
Xsigmap = sign(Xmhup);
Xsigma = sign(Xmhu);
Xsigmam = sign(Xmhum);
%
XXsigma =  permute(repmat(single(Xsigma),[1,1,nr]),[3,1,2]);
XX1mmhu2 = permute(repmat(single(X1mmhu2),[1,1,nr]),[3,1,2]);
%
XXpn = permute(repmat(single(Xpn),[1,1,nr]),[3,1,2]);
XXgamma = permute(repmat(single(Xgamma),[1,1,nr]),[3,1,2]);
%
XXheavisidep = permute(XXheavisidep,[3,1,2]);
XXheaviside = permute(XXheaviside,[3,1,2]);
XXheavisidem = permute(XXheavisidem,[3,1,2]);
%
% Determination of (np*nmhu*nb*nr*n_rf)-space points to be accounted for
%
%
% sum over harmonic numbers and rays
%
if display_mode > 1, h = waitbar(0);end
%
for in = 1:nn_rf,
    %
    for iy = 1:nb,
        %
        % sparse matrices mask calculation
        %    
        XXpsib = repmat(xypsib(:,iy),[1,npn,nmhu]);%Ratio of magnetic fields at theta = thetab_rf  
        XXomegac = repmat(xyomegac(:,iy),[1,npn,nmhu]);% cyclotron frequency at B=Bmin 
        %
        if bounce_mode > 0,          
            %   
            XXmaskb = (XXpsib.*XX1mmhu2 <= 1); % condition thetab_rf < thetaT
            %    
            XXmhub = XXmaskb.*XXsigma.*sqrt(1 - XXpsib.*XX1mmhu2);%mhu at theta = thetab_rf
            %
        else
            %
            XXmaskb = ones(nr,npn,nmhu,'single');
            %
            XXmhub = permute(repmat(single(Xmhu),[1,1,nr]),[3,1,2]);
            %    
        end
        %	    
        XXmhub(XXmhub == 0) = eps('single');
        %
        XXomega_rf = repmat(xyomega_rf(:,iy),[1,npn,nmhu]);
        XXnparmin_rf = repmat(xynparmin_rf(:,iy),[1,npn,nmhu]);
        XXnparmax_rf = repmat(xynparmax_rf(:,iy),[1,npn,nmhu]);
        XXnpar_rf = repmat(xynpar_rf(:,iy),[1,npn,nmhu]);
        XXdnpar_rf = repmat(xydnpar_rf(:,iy),[1,npn,nmhu]);
        %
        XXmask_square = repmat(xymask_square(:,iy),[1,npn,nmhu]);
        XXmask_gauss = repmat(xymask_gauss(:,iy),[1,npn,nmhu]);            
        %
        % Resonance Condition: resonant Npar
        %
        XXnparres_ij = (XXgamma - n_rf_list(in).*XXomegac.*XXpsib./XXomega_rf)/betath_ref./XXpn./XXmhub;
        %
        % Resonance Condition: delta function (normalized to: int(deltares d_npar) = 1)
        %
        XXdeltares_ij = zeros(nr,npn,nmhu);
        %
        XXdeltares_ij(XXmask_square) = (XXnparres_ij(XXmask_square) > XXnparmin_rf(XXmask_square)).*(XXnparmax_rf(XXmask_square) > XXnparres_ij(XXmask_square))./(XXnparmax_rf(XXmask_square) - XXnparmin_rf(XXmask_square));
        XXdeltares_ij(XXmask_gauss) = exp(-(XXnparres_ij(XXmask_gauss) - XXnpar_rf(XXmask_gauss)).^2./XXdnpar_rf(XXmask_gauss).^2)./XXdnpar_rf(XXmask_gauss)/sqrt(pi);
        %
        XX_index_ij = (XXdeltares_ij >= rf_tol) | (~XXheaviside & flipdim(XXdeltares_ij,2) >= rf_tol);
        %
        % neighboring points are also accounted for
        %
        XX_index_immj = XX_index_ij;XX_index_immj(:,2:npn,:) = XX_index_ij(:,1:npn-1,:);
        XX_index_ippj = XX_index_ij;XX_index_ippj(:,1:npn-1,:) = XX_index_ij(:,2:npn,:);
        XX_index_ijmm = XX_index_ij;XX_index_ijmm(:,:,2:nmhu) = XX_index_ij(:,:,1:nmhu-1);
        XX_index_ijpp = XX_index_ij;XX_index_ijpp(:,:,1:nmhu-1) = XX_index_ij(:,:,2:nmhu);      
        %
        XX_index = find(XX_index_ij | XX_index_immj | XX_index_ippj | XX_index_ijmm | XX_index_ijpp);
        %
        m_index = ceil(XX_index/(nr*npn));
        p_index = ceil((XX_index - (m_index - 1)*nr*npn)/nr);
        r_index = XX_index - ((m_index - 1)*npn + (p_index - 1))*nr;
        y_index = iy*ones(size(XX_index));
        n_index = in*ones(size(XX_index));
        %
        mask_p = [mask_p;p_index];
        mask_m = [mask_m;m_index];
        mask_r = [mask_r;r_index];
        mask_y = [mask_y;y_index];
        mask_n = [mask_n;n_index];
        %
        if display_mode > 1, waitbar((iy + nb*(in - 1))/(nb*nn_rf),h);end
        %
    end
    %
end
%
if display_mode >1, close(h); end
%
clear XXsigma XX1mmhu2 XXpn XXgamma XXpsib XXomegac XXmaskb XXmhub 
clear XXomega_rf XXnparmin_rf XXnparmax_rf XXnpar_rf XXdnpar_rf
clear XXmask_square  XXmask_gauss XXnparres_ij XXdeltares_ij 
clear XX_index XX_index_ij XX_index_immj XX_index_ippj XX_index_ijmm XX_index_ijpp
clear p_index m_index r_index y_index n_index
%
Xmask = (mask_m - 1)*npn + mask_p;%mask in momentum 2-D matrices
xymask = (mask_y - 1)*nr + mask_r;%mask in y-rho 2-D matrices
%
SXY = size(Xmask);
%
% Vector construction
%
XYn_rf = reshape(n_rf_list(mask_n),[length(mask_n),1]);
XYyn = XYn_rf./reshape(xyomegaratio(xymask),[length(mask_n),1]);%to prevent matlab bug w
XYpsib = xypsib(xymask);   
XYynb = XYyn.*XYpsib;
%
XYpnpp = single(Xpnpp(Xmask));
XYpnp = single(Xpnp(Xmask));
XYpn = single(Xpn(Xmask));
XYpnm = single(Xpnm(Xmask));
XYpnmm = single(Xpnmm(Xmask));
%
XYgammapp = single(Xgammapp(Xmask));
XYgammap = single(Xgammap(Xmask));
XYgamma = single(Xgamma(Xmask));
XYgammam = single(Xgammam(Xmask));
XYgammamm = single(Xgammamm(Xmask));
%
XYsigmap = single(Xsigmap(Xmask));
XYsigma = single(Xsigma(Xmask));
XYsigmam = single(Xsigmam(Xmask));
%
XY1mmhu2p = single(X1mmhu2p(Xmask));
XY1mmhu2 = single(X1mmhu2(Xmask));
XY1mmhu2m = single(X1mmhu2m(Xmask));
%
XY1mmhu2p(XY1mmhu2p == 0) = eps('single');
XY1mmhu2(XY1mmhu2 == 0) =  eps('single');
XY1mmhu2m(XY1mmhu2m == 0) =  eps('single');
%
XYmaskb = (XYpsib.*XY1mmhu2p <= 1) & (XYpsib.*XY1mmhu2 <= 1) & (XYpsib.*XY1mmhu2m <= 1);
%
XYmhubp = XYmaskb.*XYsigmap.*sqrt(1 - XYpsib.*XY1mmhu2p);
XYmhub = XYmaskb.*XYsigma.*sqrt(1 - XYpsib.*XY1mmhu2);
XYmhubm = XYmaskb.*XYsigmam.*sqrt(1 - XYpsib.*XY1mmhu2m);
%
clear XYmaskb
%
if dke_mode == 0,
    %
    clear XYsigmap XYsigma XYsigmam
    %            
end     
%
XYmhubp(XYmhubp == 0) = eps('single');
XYmhub(XYmhub == 0) =  eps('single');
XYmhubm(XYmhubm == 0) =  eps('single');
%
% Resonant Npar
%
XYnparres.ippj = (XYgammapp - XYynb)./XYpnpp./XYmhub/betath_ref;
XYnparres.ipj = (XYgammap - XYynb)./XYpnp./XYmhub/betath_ref;
XYnparres.ij = (XYgamma - XYynb)./XYpn./XYmhub/betath_ref;
XYnparres.imj = (XYgammam - XYynb)./XYpnm./XYmhub/betath_ref;
XYnparres.immj = (XYgammamm - XYynb)./XYpnmm./XYmhub/betath_ref;
XYnparres.ijp = (XYgamma - XYynb)./XYpn./XYmhubp/betath_ref;
XYnparres.ijm = (XYgamma - XYynb)./XYpn./XYmhubm/betath_ref;
%
clear XYynb 
%
% Resonance Condition: delta function (normalized to: int(deltares d_npar) = 1)
%
XYmask_square = xymask_square(xymask);
XYmask_gauss = xymask_gauss(xymask);
%
XYnparmin_rf = xynparmin_rf(xymask);
XYnparmax_rf = xynparmax_rf(xymask);
XYnpar_rf = xynpar_rf(xymask);
XYdnpar_rf_gauss = xydnpar_rf(xymask);
XYdnpar_rf_square = xynparmax_rf(xymask) - xynparmin_rf(xymask);       
%
XYdeltares.ippj = zeros(SXY,'single');
XYdeltares.ipj = zeros(SXY,'single');
XYdeltares.ij = zeros(SXY,'single');
XYdeltares.imj = zeros(SXY,'single');
XYdeltares.immj = zeros(SXY,'single');
XYdeltares.ijp = zeros(SXY,'single');
XYdeltares.ijm = zeros(SXY,'single');
%
XYdeltares.ippj(XYmask_square) = (XYnparres.ippj(XYmask_square) > XYnparmin_rf(XYmask_square)).*(XYnparmax_rf(XYmask_square) > XYnparres.ippj(XYmask_square))./XYdnpar_rf_square(XYmask_square);
XYdeltares.ippj(XYmask_gauss) = exp(-(XYnparres.ippj(XYmask_gauss) - XYnpar_rf(XYmask_gauss)).^2./XYdnpar_rf_gauss(XYmask_gauss).^2)./XYdnpar_rf_gauss(XYmask_gauss)/sqrt(pi);
%
XYdeltares.ipj(XYmask_square) = (XYnparres.ipj(XYmask_square) > XYnparmin_rf(XYmask_square)).*(XYnparmax_rf(XYmask_square) > XYnparres.ipj(XYmask_square))./XYdnpar_rf_square(XYmask_square);
XYdeltares.ipj(XYmask_gauss) = exp(-(XYnparres.ipj(XYmask_gauss) - XYnpar_rf(XYmask_gauss)).^2./XYdnpar_rf_gauss(XYmask_gauss).^2)./XYdnpar_rf_gauss(XYmask_gauss)/sqrt(pi);
%
XYdeltares.ij(XYmask_square) = (XYnparres.ij(XYmask_square) > XYnparmin_rf(XYmask_square)).*(XYnparmax_rf(XYmask_square) > XYnparres.ij(XYmask_square))./XYdnpar_rf_square(XYmask_square);
XYdeltares.ij(XYmask_gauss) = exp(-(XYnparres.ij(XYmask_gauss) - XYnpar_rf(XYmask_gauss)).^2./XYdnpar_rf_gauss(XYmask_gauss).^2)./XYdnpar_rf_gauss(XYmask_gauss)/sqrt(pi);
%
XYdeltares.imj(XYmask_square) = (XYnparres.imj(XYmask_square) > XYnparmin_rf(XYmask_square)).*(XYnparmax_rf(XYmask_square) > XYnparres.imj(XYmask_square))./XYdnpar_rf_square(XYmask_square);
XYdeltares.imj(XYmask_gauss) = exp(-(XYnparres.imj(XYmask_gauss) - XYnpar_rf(XYmask_gauss)).^2./XYdnpar_rf_gauss(XYmask_gauss).^2)./XYdnpar_rf_gauss(XYmask_gauss)/sqrt(pi);
%
XYdeltares.immj(XYmask_square) = (XYnparres.immj(XYmask_square) > XYnparmin_rf(XYmask_square)).*(XYnparmax_rf(XYmask_square) > XYnparres.immj(XYmask_square))./XYdnpar_rf_square(XYmask_square);
XYdeltares.immj(XYmask_gauss) = exp(-(XYnparres.immj(XYmask_gauss) - XYnpar_rf(XYmask_gauss)).^2./XYdnpar_rf_gauss(XYmask_gauss).^2)./XYdnpar_rf_gauss(XYmask_gauss)/sqrt(pi);
%
XYdeltares.ijp(XYmask_square) = (XYnparres.ijp(XYmask_square) > XYnparmin_rf(XYmask_square)).*(XYnparmax_rf(XYmask_square) > XYnparres.ijp(XYmask_square))./XYdnpar_rf_square(XYmask_square);
XYdeltares.ijp(XYmask_gauss) = exp(-(XYnparres.ijp(XYmask_gauss) - XYnpar_rf(XYmask_gauss)).^2./XYdnpar_rf_gauss(XYmask_gauss).^2)./XYdnpar_rf_gauss(XYmask_gauss)/sqrt(pi);
%
XYdeltares.ijm(XYmask_square) = (XYnparres.ijm(XYmask_square) > XYnparmin_rf(XYmask_square)).*(XYnparmax_rf(XYmask_square) > XYnparres.ijm(XYmask_square))./XYdnpar_rf_square(XYmask_square);
XYdeltares.ijm(XYmask_gauss) = exp(-(XYnparres.ijm(XYmask_gauss) - XYnpar_rf(XYmask_gauss)).^2./XYdnpar_rf_gauss(XYmask_gauss).^2)./XYdnpar_rf_gauss(XYmask_gauss)/sqrt(pi);
%
clear XYnparres XYmask_square XYmask_gauss XYnparmin_rf XYnparmax_rf XYnpar_rf XYdnpar_rf_gauss XYdnpar_rf_square
%
% FLR factor k_perp*rho_perp
% 
XYZbfac = xyZbfac(xymask);
%
XYZb.ippj = -XYZbfac.*XYpnpp.*sqrt(XY1mmhu2);
XYZb.ipj = -XYZbfac.*XYpnp.*sqrt(XY1mmhu2);
XYZb.ij = -XYZbfac.*XYpn.*sqrt(XY1mmhu2);
XYZb.imj = -XYZbfac.*XYpnm.*sqrt(XY1mmhu2);
XYZb.immj = -XYZbfac.*XYpnmm.*sqrt(XY1mmhu2);
XYZb.ijp = -XYZbfac.*XYpn.*sqrt(XY1mmhu2p);
XYZb.ijm = -XYZbfac.*XYpn.*sqrt(XY1mmhu2m);
%
clear XYZbfac
%
% Polarization term 
%
% Polarization vector is normalized to 1.  
%
XYepolp_rf = xyepolp_rf(xymask); 
XYepolm_rf = xyepolm_rf(xymask); 
XYepolz_rf = xyepolz_rf(xymask); 
%
XYlre = xyopt(xymask) == 0; %(0): exact calculation for the Bessel functions, otherwise, limit k_perp*rho_perp << 1
%
XYmhuratiop = XYmhubp./sqrt(XYpsib.*XY1mmhu2p);
XYmhuratio = XYmhub./sqrt(XYpsib.*XY1mmhu2);
XYmhuratiom = XYmhubm./sqrt(XYpsib.*XY1mmhu2m);
%
XYpolb.ippj = XYepolp_rf.*besselj_dke_jd(XYn_rf + 1,XYZb.ippj,XYlre)/sqrt(2) + XYepolm_rf.*besselj_dke_jd(XYn_rf - 1,XYZb.ippj,XYlre)/sqrt(2)...
   - XYmhuratio.*XYepolz_rf.*besselj_dke_jd(XYn_rf,XYZb.ippj,XYlre);
XYpolb.ipj = XYepolp_rf.*besselj_dke_jd(XYn_rf + 1,XYZb.ipj,XYlre)/sqrt(2) + XYepolm_rf.*besselj_dke_jd(XYn_rf - 1,XYZb.ipj,XYlre)/sqrt(2)...
   - XYmhuratio.*XYepolz_rf.*besselj_dke_jd(XYn_rf,XYZb.ipj,XYlre);
XYpolb.ij = XYepolp_rf.*besselj_dke_jd(XYn_rf + 1,XYZb.ij,XYlre)/sqrt(2) + XYepolm_rf.*besselj_dke_jd(XYn_rf - 1,XYZb.ij,XYlre)/sqrt(2)...
   - XYmhuratio.*XYepolz_rf.*besselj_dke_jd(XYn_rf,XYZb.ij,XYlre);
XYpolb.imj = XYepolp_rf.*besselj_dke_jd(XYn_rf + 1,XYZb.imj,XYlre)/sqrt(2) + XYepolm_rf.*besselj_dke_jd(XYn_rf - 1,XYZb.imj,XYlre)/sqrt(2)...
   - XYmhuratio.*XYepolz_rf.*besselj_dke_jd(XYn_rf,XYZb.imj,XYlre);
XYpolb.immj = XYepolp_rf.*besselj_dke_jd(XYn_rf + 1,XYZb.immj,XYlre)/sqrt(2) + XYepolm_rf.*besselj_dke_jd(XYn_rf - 1,XYZb.immj,XYlre)/sqrt(2)...
   - XYmhuratio.*XYepolz_rf.*besselj_dke_jd(XYn_rf,XYZb.immj,XYlre);
XYpolb.ijp = XYepolp_rf.*besselj_dke_jd(XYn_rf + 1,XYZb.ijp,XYlre)/sqrt(2) + XYepolm_rf.*besselj_dke_jd(XYn_rf - 1,XYZb.ijp,XYlre)/sqrt(2)...
   - XYmhuratiop.*XYepolz_rf.*besselj_dke_jd(XYn_rf,XYZb.ijp,XYlre);
XYpolb.ijm = XYepolp_rf.*besselj_dke_jd(XYn_rf + 1,XYZb.ijm,XYlre)/sqrt(2) + XYepolm_rf.*besselj_dke_jd(XYn_rf - 1,XYZb.ijm,XYlre)/sqrt(2)...
   - XYmhuratiom.*XYepolz_rf.*besselj_dke_jd(XYn_rf,XYZb.ijm,XYlre);    
%
clear XYZb XYn_rf XYepolp_rf XYepolm_rf XYepolz_rf XYlre XYmhuratiop XYmhuratio XYmhuratiom 
%
XYrespol.ippj = XYdeltares.ippj.*abs(XYpolb.ippj).^2;
XYrespol.ipj = XYdeltares.ipj.*abs(XYpolb.ipj).^2;
XYrespol.ij = XYdeltares.ij.*abs(XYpolb.ij).^2;
XYrespol.imj = XYdeltares.imj.*abs(XYpolb.imj).^2;
XYrespol.immj = XYdeltares.immj.*abs(XYpolb.immj).^2;
XYrespol.ijp = XYdeltares.ijp.*abs(XYpolb.ijp).^2;
XYrespol.ijm = XYdeltares.ijm.*abs(XYpolb.ijm).^2;
%
clear XYdeltares XYpolb
%
%Sum over sigma for trapped particles - case FP
%
if dke_mode == 1,
    %
    XYrespol_tp = XYrespol;
    %
end
%
Yxmask = (((mask_n - 1)*nr + (mask_r - 1))*nb + (mask_y - 1))*npn + mask_p;%mask in pnp-y-rho-n 4-D matrices
%
XYrespol_mhuflip.ippj = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol.ippj),nmhu,npn*nb*nr*nn_rf));
XYrespol_mhuflip.ipj = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol.ipj),nmhu,npn*nb*nr*nn_rf));
XYrespol_mhuflip.ij = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol.ij),nmhu,npn*nb*nr*nn_rf));
XYrespol_mhuflip.imj = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol.imj),nmhu,npn*nb*nr*nn_rf));
XYrespol_mhuflip.immj = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol.immj),nmhu,npn*nb*nr*nn_rf));
XYrespol_mhuflip.ijp = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol.ijm),nmhu,npn*nb*nr*nn_rf));
XYrespol_mhuflip.ijm = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol.ijp),nmhu,npn*nb*nr*nn_rf));
%
XYmask = (Yxmask - 1)*nmhu + mask_m;
%
XYrespol_mhuflip.ippj = single(full(XYrespol_mhuflip.ippj(XYmask)));
XYrespol_mhuflip.ipj = single(full(XYrespol_mhuflip.ipj(XYmask)));
XYrespol_mhuflip.ij = single(full(XYrespol_mhuflip.ij(XYmask)));
XYrespol_mhuflip.imj = single(full(XYrespol_mhuflip.imj(XYmask)));
XYrespol_mhuflip.immj = single(full(XYrespol_mhuflip.immj(XYmask)));
XYrespol_mhuflip.ijp = single(full(XYrespol_mhuflip.ijp(XYmask)));
XYrespol_mhuflip.ijm = single(full(XYrespol_mhuflip.ijm(XYmask))); 
%
if dke_mode == 0,
    %
    clear Yxmask XYmask
    %
end
%
XXmask = ((mask_m - 1)*npn + (mask_p - 1))*nr + mask_r;%mask in rho-momentum 3-D matrices
%
XYtrapped_p = ~XXheavisidep(XXmask);
XYtrapped = ~XXheaviside(XXmask);
XYtrapped_m = ~XXheavisidem(XXmask);     
%
clear XXmask XXheavisidep XXheaviside XXheavisidem
%
XYrespol.ippj(XYtrapped) = (XYrespol.ippj(XYtrapped) + XYrespol_mhuflip.ippj(XYtrapped))/2;
XYrespol.ipj(XYtrapped) = (XYrespol.ipj(XYtrapped) + XYrespol_mhuflip.ipj(XYtrapped))/2;
XYrespol.ij(XYtrapped) = (XYrespol.ij(XYtrapped) + XYrespol_mhuflip.ij(XYtrapped))/2;
XYrespol.imj(XYtrapped) = (XYrespol.imj(XYtrapped) + XYrespol_mhuflip.imj(XYtrapped))/2;
XYrespol.immj(XYtrapped) = (XYrespol.immj(XYtrapped) + XYrespol_mhuflip.immj(XYtrapped))/2;
XYrespol.ijp(XYtrapped_p) = (XYrespol.ijp(XYtrapped_p) + XYrespol_mhuflip.ijp(XYtrapped_p))/2;
XYrespol.ijm(XYtrapped_m) = (XYrespol.ijm(XYtrapped_m) + XYrespol_mhuflip.ijm(XYtrapped_m))/2;
%
clear XYrespol_mhuflip
%
if dke_mode == 0,
    %
    clear XYtrapped_p XYtrapped XYtrapped_m
    %            
end
%
Xxmask = (mask_r - 1)*nmhu + mask_m;%mask in mhu-rho 2-D matrices
%
XYlambdap = Xxlambdap(Xxmask);
XYlambda = Xxlambda(Xxmask);        
XYlambdam = Xxlambdam(Xxmask);        
%
clear Xxmask 
%
XYlambdap(XYlambdap == 0) = eps('single');
XYlambda(XYlambda == 0) =  eps('single');
XYlambdam(XYlambdam == 0) =  eps('single');
%
XYmhup = single(Xmhup(Xmask));
XYmhu = single(Xmhu(Xmask));
XYmhum = single(Xmhum(Xmask));
%
clear Xmask 
%
XYDfacp = XYmhup.*XYmhup.*XYpsib./XYlambdap./XYmhubp./XYmhubp;
XYDfac = XYmhu.*XYmhu.*XYpsib./XYlambda./XYmhub./XYmhub;
XYDfacm = XYmhum.*XYmhum.*XYpsib./XYlambdam./XYmhubm./XYmhubm;
%
if dke_mode == 0,
    %
    clear XYpsib XYmhubp XYmhub XYmhubm XYlambdap XYlambda XYlambdam XYqratio
    %            
end     
%
%QL Diffusion Coefficient
%    
XYold = xyopt(xymask) == 2; %(2): no 1/vpar dependence (old method, benchmark Karney Shoucri) 
if max(XYold(:)) > 0
    if display_mode >= 1,info_dke_yp(1,'WARNING: Old technique for calculating the LH matrix coefficients, for comparaison with previous versions (Karney, Shoucri)');end
end
%
clear xymask
%
XYDrf.ippj = zeros(SXY,'single');
XYDrf.ipj = zeros(SXY,'single');
XYDrf.ij = zeros(SXY,'single');
XYDrf.imj = zeros(SXY,'single');
XYDrf.immj = zeros(SXY,'single');
XYDrf.ijp = zeros(SXY,'single');
XYDrf.ijm = zeros(SXY,'single');
%
XYDrf.ippj(XYold) = XYrespol.ippj(XYold).*XYDfac(XYold);
XYDrf.ipj(XYold) = XYrespol.ipj(XYold).*XYDfac(XYold);
XYDrf.ij(XYold) = XYrespol.ij(XYold).*XYDfac(XYold);
XYDrf.imj(XYold) = XYrespol.imj(XYold).*XYDfac(XYold);
XYDrf.immj(XYold) = XYrespol.immj(XYold).*XYDfac(XYold);
XYDrf.ijp(XYold) = XYrespol.ijp(XYold).*XYDfacp(XYold);
XYDrf.ijm(XYold) = XYrespol.ijm(XYold).*XYDfacm(XYold);
%
XYDrf.ippj(~XYold) = XYrespol.ippj(~XYold).*XYDfac(~XYold).*XYgammapp(~XYold)./XYpnpp(~XYold)./abs(XYmhu(~XYold));
XYDrf.ipj(~XYold) = XYrespol.ipj(~XYold).*XYDfac(~XYold).*XYgammap(~XYold)./XYpnp(~XYold)./abs(XYmhu(~XYold));
XYDrf.ij(~XYold) = XYrespol.ij(~XYold).*XYDfac(~XYold).*XYgamma(~XYold)./XYpn(~XYold)./abs(XYmhu(~XYold));
XYDrf.imj(~XYold) = XYrespol.imj(~XYold).*XYDfac(~XYold).*XYgammam(~XYold)./XYpnm(~XYold)./abs(XYmhu(~XYold));
XYDrf.immj(~XYold) = XYrespol.immj(~XYold).*XYDfac(~XYold).*XYgammamm(~XYold)./XYpnmm(~XYold)./abs(XYmhu(~XYold));
XYDrf.ijp(~XYold) = XYrespol.ijp(~XYold).*XYDfacp(~XYold).*XYgamma(~XYold)./XYpn(~XYold)./abs(XYmhup(~XYold));
XYDrf.ijm(~XYold) = XYrespol.ijm(~XYold).*XYDfacm(~XYold).*XYgamma(~XYold)./XYpn(~XYold)./abs(XYmhum(~XYold));
%
clear XYrespol XYDfacp XYDfac XYDfacm  
%
if dke_mode == 0,
    %
    clear XYgammapp XYgammap XYgamma XYgammam XYgammamm
    clear XYpnpp XYpnp XYpn XYpnm XYpnmm
    %
end
%	    
% QL diffusion tensor elements
%
ZXYD_rf.pp_ippj = XY1mmhu2.*XYDrf.ippj;
ZXYD_rf.pp_ipj = XY1mmhu2.*XYDrf.ipj;                                     
ZXYD_rf.pp_ij = XY1mmhu2.*XYDrf.ij;                                      
ZXYD_rf.parpar_ij = XY1mmhu2.*(1 - XYyn).^2.*XYDrf.ij./XYmhu./XYmhu; 
ZXYD_rf.pp_imj = XY1mmhu2.*XYDrf.imj;
ZXYD_rf.pp_immj = XY1mmhu2.*XYDrf.immj;
%
ZXYD_rf.pm_ipj = - sqrt(XY1mmhu2).*(XY1mmhu2 - XYyn).*XYDrf.ipj./XYmhu;
ZXYD_rf.pm_ij = - sqrt(XY1mmhu2).*(XY1mmhu2 - XYyn).*XYDrf.ij./XYmhu;
ZXYD_rf.pm_imj = - sqrt(XY1mmhu2).*(XY1mmhu2 - XYyn).*XYDrf.imj./XYmhu;
%
ZXYD_rf.mp_ijp = - sqrt(XY1mmhu2p).*(XY1mmhu2p - XYyn).*XYDrf.ijp./XYmhup;
ZXYD_rf.mp_ij = - sqrt(XY1mmhu2).*(XY1mmhu2 - XYyn).*XYDrf.ij./XYmhu;
ZXYD_rf.mp_ijm = - sqrt(XY1mmhu2m).*(XY1mmhu2m - XYyn).*XYDrf.ijm./XYmhum;
%
ZXYD_rf.mm_ijp = (XY1mmhu2p - XYyn).^2.*XYDrf.ijp./XYmhup./XYmhup;
ZXYD_rf.mm_ijm = (XY1mmhu2m - XYyn).^2.*XYDrf.ijm./XYmhum./XYmhum;
%
clear XYDrf 
%
if dke_mode == 1,
    %
    % Sum over sigma for trapped particles - case DKE
    %
    XYrespol_tp_mhuflip.ippj = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol_tp.ippj.*XYsigma),nmhu,npn*nb*nr));
    XYrespol_tp_mhuflip.ipj = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol_tp.ipj.*XYsigma),nmhu,npn*nb*nr));
    XYrespol_tp_mhuflip.ij = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol_tp.ij.*XYsigma),nmhu,npn*nb*nr));
    XYrespol_tp_mhuflip.imj = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol_tp.imj.*XYsigma),nmhu,npn*nb*nr));
    XYrespol_tp_mhuflip.immj = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol_tp.immj.*XYsigma),nmhu,npn*nb*nr));
    XYrespol_tp_mhuflip.ijp = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol_tp.ijp.*XYsigmap),nmhu,npn*nb*nr));
    XYrespol_tp_mhuflip.ijm = flipud(sparse(double(mask_m),double(Yxmask),double(XYrespol_tp.ijm.*XYsigmam),nmhu,npn*nb*nr));
    %
    XYrespol_tp_mhuflip.ippj = XYsigma.*single(full(XYrespol_tp_mhuflip.ippj(XYmask)));
    XYrespol_tp_mhuflip.ipj = XYsigma.*single(full(XYrespol_tp_mhuflip.ipj(XYmask)));
    XYrespol_tp_mhuflip.ij = XYsigma.*single(full(XYrespol_tp_mhuflip.ij(XYmask)));
    XYrespol_tp_mhuflip.imj = XYsigma.*single(full(XYrespol_tp_mhuflip.imj(XYmask)));
    XYrespol_tp_mhuflip.immj = XYsigma.*single(full(XYrespol_tp_mhuflip.immj(XYmask)));
    XYrespol_tp_mhuflip.ijp = XYsigmap.*single(full(XYrespol_tp_mhuflip.ijp(XYmask)));
    XYrespol_tp_mhuflip.ijm = XYsigmam.*single(full(XYrespol_tp_mhuflip.ijm(XYmask))); 
    %
    clear Yxmask XYmask
    %
    XYrespol_tp.ippj(XYtrapped) = (XYrespol_tp.ippj(XYtrapped) + XYrespol_tp_mhuflip.ippj(XYtrapped))/2;
    XYrespol_tp.ipj(XYtrapped) = (XYrespol_tp.ipj(XYtrapped) + XYrespol_tp_mhuflip.ipj(XYtrapped))/2;
    XYrespol_tp.ij(XYtrapped) = (XYrespol_tp.ij(XYtrapped) + XYrespol_tp_mhuflip.ij(XYtrapped))/2;
    XYrespol_tp.imj(XYtrapped) = (XYrespol_tp.imj(XYtrapped) + XYrespol_tp_mhuflip.imj(XYtrapped))/2;
    XYrespol_tp.immj(XYtrapped) = (XYrespol_tp.immj(XYtrapped) + XYrespol_tp_mhuflip.immj(XYtrapped))/2;
    XYrespol_tp.ijp(XYtrapped_p) = (XYrespol_tp.ijp(XYtrapped_p) + XYrespol_tp_mhuflip.ijp(XYtrapped_p))/2;
    XYrespol_tp.ijm(XYtrapped_m) = (XYrespol_tp.ijm(XYtrapped_m) + XYrespol_tp_mhuflip.ijm(XYtrapped_m))/2;
    %
    clear XYtrapped_p XYtrapped XYtrapped_m XYrespol_tp_mhuflip
    %
    XYDfacp_D_tp = XYsigmap.*abs(XYmhup)./XYlambdap./XYmhubp;
    XYDfac_D_tp = XYsigma.*abs(XYmhu)./XYlambda./XYmhub;
    XYDfacm_D_tp = XYsigmam.*abs(XYmhum)./XYlambdam./XYmhubm;
    %
    XYDfacp_F_tp = (1 - XYpsib).*XYmhup.*XYmhup.*XYmhup./XYlambdap./XYmhubp./XYmhubp./XYmhubp;
    XYDfac_F_tp = (1 - XYpsib).*XYmhu.*XYmhu.*XYmhu./XYlambda./XYmhub./XYmhub./XYmhub;
    XYDfacm_F_tp = (1 - XYpsib).*XYmhum.*XYmhum.*XYmhum./XYlambdam./XYmhubm./XYmhubm./XYmhubm;
    %
    clear XYpsib XYsigmap XYsigma XYsigmam XYlambdap XYlambda XYlambdam XYqratio XYmhubp XYmhub XYmhubm 
    %
    %QL Diffusion Coefficient
    %    
    XYDrf_D_tp.ippj = zeros(SXY,'single');
    XYDrf_D_tp.ipj = zeros(SXY,'single');
    XYDrf_D_tp.ij = zeros(SXY,'single');
    XYDrf_D_tp.imj = zeros(SXY,'single');
    XYDrf_D_tp.immj = zeros(SXY,'single');
    XYDrf_D_tp.ijp = zeros(SXY,'single');
    XYDrf_D_tp.ijm = zeros(SXY,'single');
    %    
    XYDrf_D_tp.ippj(XYold) = XYrespol_tp.ippj(XYold).*XYDfac_D_tp(XYold);
    XYDrf_D_tp.ipj(XYold) = XYrespol_tp.ipj(XYold).*XYDfac_D_tp(XYold);
    XYDrf_D_tp.ij(XYold) = XYrespol_tp.ij(XYold).*XYDfac_D_tp(XYold);
    XYDrf_D_tp.imj(XYold) = XYrespol_tp.imj(XYold).*XYDfac_D_tp(XYold);
    XYDrf_D_tp.immj(XYold) = XYrespol_tp.immj(XYold).*XYDfac_D_tp(XYold);
    XYDrf_D_tp.ijp(XYold) = XYrespol_tp.ijp(XYold).*XYDfacp_D_tp(XYold);
    XYDrf_D_tp.ijm(XYold) = XYrespol_tp.ijm(XYold).*XYDfacm_D_tp(XYold);   
    %    
    XYDrf_D_tp.ippj(~XYold) = XYrespol_tp.ippj(~XYold).*XYDfac_D_tp(~XYold).*XYgammapp(~XYold)./XYpnpp(~XYold)./abs(XYmhu(~XYold));
    XYDrf_D_tp.ipj(~XYold) = XYrespol_tp.ipj(~XYold).*XYDfac_D_tp(~XYold).*XYgammap(~XYold)./XYpnp(~XYold)./abs(XYmhu(~XYold));
    XYDrf_D_tp.ij(~XYold) = XYrespol_tp.ij(~XYold).*XYDfac_D_tp(~XYold).*XYgamma(~XYold)./XYpn(~XYold)./abs(XYmhu(~XYold));
    XYDrf_D_tp.imj(~XYold) = XYrespol_tp.imj(~XYold).*XYDfac_D_tp(~XYold).*XYgammam(~XYold)./XYpnm(~XYold)./abs(XYmhu(~XYold));
    XYDrf_D_tp.immj(~XYold) = XYrespol_tp.immj(~XYold).*XYDfac_D_tp(~XYold).*XYgammamm(~XYold)./XYpnmm(~XYold)./abs(XYmhu(~XYold));
    XYDrf_D_tp.ijp(~XYold) = XYrespol_tp.ijp(~XYold).*XYDfacp_D_tp(~XYold).*XYgamma(~XYold)./XYpn(~XYold)./abs(XYmhup(~XYold));
    XYDrf_D_tp.ijm(~XYold) = XYrespol_tp.ijm(~XYold).*XYDfacm_D_tp(~XYold).*XYgamma(~XYold)./XYpn(~XYold)./abs(XYmhum(~XYold));   
    %    
    clear XYDfacp_D_tp XYDfac_D_tp XYDfacm_D_tp
    %    
    XYDrf_F_tp.ippj = zeros(SXY,'single');
    XYDrf_F_tp.ipj = zeros(SXY,'single');
    XYDrf_F_tp.ij = zeros(SXY,'single');
    XYDrf_F_tp.imj = zeros(SXY,'single');
    XYDrf_F_tp.immj = zeros(SXY,'single');
    XYDrf_F_tp.ijp = zeros(SXY,'single');
    XYDrf_F_tp.ijm = zeros(SXY,'single');
    %
    XYDrf_F_tp.ippj(XYold) = XYrespol_tp.ippj(XYold).*XYDfac_F_tp(XYold);
    XYDrf_F_tp.ipj(XYold) = XYrespol_tp.ipj(XYold).*XYDfac_F_tp(XYold);
    XYDrf_F_tp.ij(XYold) = XYrespol_tp.ij(XYold).*XYDfac_F_tp(XYold);
    XYDrf_F_tp.imj(XYold) = XYrespol_tp.imj(XYold).*XYDfac_F_tp(XYold);
    XYDrf_F_tp.immj(XYold) = XYrespol_tp.immj(XYold).*XYDfac_F_tp(XYold);
    XYDrf_F_tp.ijp(XYold) = XYrespol_tp.ijp(XYold).*XYDfacp_F_tp(XYold);
    XYDrf_F_tp.ijm(XYold) = XYrespol_tp.ijm(XYold).*XYDfacm_F_tp(XYold);       
    %
    XYDrf_F_tp.ippj(~XYold) = XYrespol_tp.ippj(~XYold).*XYDfac_F_tp(~XYold).*XYgammapp(~XYold)./XYpnpp(~XYold)./abs(XYmhu(~XYold));
    XYDrf_F_tp.ipj(~XYold) = XYrespol_tp.ipj(~XYold).*XYDfac_F_tp(~XYold).*XYgammap(~XYold)./XYpnp(~XYold)./abs(XYmhu(~XYold));
    XYDrf_F_tp.ij(~XYold) = XYrespol_tp.ij(~XYold).*XYDfac_F_tp(~XYold).*XYgamma(~XYold)./XYpn(~XYold)./abs(XYmhu(~XYold));
    XYDrf_F_tp.imj(~XYold) = XYrespol_tp.imj(~XYold).*XYDfac_F_tp(~XYold).*XYgammam(~XYold)./XYpnm(~XYold)./abs(XYmhu(~XYold));
    XYDrf_F_tp.immj(~XYold) = XYrespol_tp.immj(~XYold).*XYDfac_F_tp(~XYold).*XYgammamm(~XYold)./XYpnmm(~XYold)./abs(XYmhu(~XYold));
    XYDrf_F_tp.ijp(~XYold) = XYrespol_tp.ijp(~XYold).*XYDfacp_F_tp(~XYold).*XYgamma(~XYold)./XYpn(~XYold)./abs(XYmhup(~XYold));
    XYDrf_F_tp.ijm(~XYold) = XYrespol_tp.ijm(~XYold).*XYDfacm_F_tp(~XYold).*XYgamma(~XYold)./XYpn(~XYold)./abs(XYmhum(~XYold));       
    %
    % ---------------- Terms for wave-induced radial transport by adjoint technique (P. Helander model) ----------------
    %         	
    XYDrf_F1_tp.ijp = XYrespol_tp.ijp.*XYDfacp_F_tp.*XYgamma./XYpn;
    XYDrf_F1_tp.ij = XYrespol_tp.ij.*XYDfac_F_tp.*XYgamma./XYpn;
    XYDrf_F1_tp.ijm = XYrespol_tp.ijm.*XYDfacm_F_tp.*XYgamma./XYpn;       
    %
    clear XYrespol_tp XYDfacp_F_tp XYDfac_F_tp XYDfacm_F_tp
    clear XYgammapp XYgammap XYgamma XYgammam XYgammamm
    clear XYpnpp XYpnp XYpn XYpnm XYpnmm
    %
    % Mask for DKE points
    %
    mask_dke = any((1./rdke.')*(mask_r.') == 1).';%selects DKE points
    % 
    %QL diffusion tensor elements
    %
    ZXYD_rf_tp.pp_ippj = XY1mmhu2(mask_dke).*XYDrf_D_tp.ippj(mask_dke);
    ZXYD_rf_tp.pp_ipj = XY1mmhu2(mask_dke).*XYDrf_D_tp.ipj(mask_dke);
    ZXYD_rf_tp.pp_ij = XY1mmhu2(mask_dke).*XYDrf_D_tp.ij(mask_dke);
    ZXYD_rf_tp.pp_imj = XY1mmhu2(mask_dke).*XYDrf_D_tp.imj(mask_dke);
    ZXYD_rf_tp.pp_immj = XY1mmhu2(mask_dke).*XYDrf_D_tp.immj(mask_dke);
    %
    ZXYD_rf_tp.pm_ipj = - sqrt(XY1mmhu2(mask_dke)).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*XYDrf_D_tp.ipj(mask_dke)./XYmhu(mask_dke);
    ZXYD_rf_tp.pm_ij = - sqrt(XY1mmhu2(mask_dke)).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*XYDrf_D_tp.ij(mask_dke)./XYmhu(mask_dke);
    ZXYD_rf_tp.pm_imj = - sqrt(XY1mmhu2(mask_dke)).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*XYDrf_D_tp.imj(mask_dke)./XYmhu(mask_dke);
    %
    ZXYD_rf_tp.mp_ijp = - sqrt(XY1mmhu2p(mask_dke)).*(XY1mmhu2p(mask_dke) - XYyn(mask_dke)).*XYDrf_D_tp.ijp(mask_dke)./XYmhup(mask_dke);
    ZXYD_rf_tp.mp_ij = - sqrt(XY1mmhu2(mask_dke)).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*XYDrf_D_tp.ij(mask_dke)./XYmhu(mask_dke);
    ZXYD_rf_tp.mp_ijm = - sqrt(XY1mmhu2m(mask_dke)).*(XY1mmhu2m (mask_dke)- XYyn(mask_dke)).*XYDrf_D_tp.ijm(mask_dke)./XYmhum(mask_dke);
    %
    ZXYD_rf_tp.mm_ijp = (XY1mmhu2p(mask_dke) - XYyn(mask_dke)).^2.*XYDrf_D_tp.ijp(mask_dke)./XYmhu2p(mask_dke);
    ZXYD_rf_tp.mm_ijm = (XY1mmhu2m(mask_dke) - XYyn(mask_dke)).^2.*XYDrf_D_tp.ijm(mask_dke)./XYmhu2m(mask_dke);
    %
    % ---------------- Terms for wave-induced radial transport by adjoint technique (P. Helander model) ----------------
    %
    ZXYD_rf_tp.mp1_ijp = - sqrt(XY1mmhu2p(mask_dke)).*(XY1mmhu2p(mask_dke) - XYyn(mask_dke)).*(XYDrf_D_tp.ijp(mask_dke) + XYDrf_F1_tp.ijp(mask_dke))./XYmhup(mask_dke);%XYDmp_rf_ijp
    ZXYD_rf_tp.mp1_ij = - sqrt(XY1mmhu2(mask_dke)).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*(XYDrf_D_tp.ij(mask_dke) + XYDrf_F1_tp.ij(mask_dke))./XYmhu(mask_dke);%XYDmp_rf_ij
    ZXYD_rf_tp.mp1_ijm = - sqrt(XY1mmhu2m(mask_dke)).*(XY1mmhu2m (mask_dke)- XYyn(mask_dke)).*(XYDrf_D_tp.ijm(mask_dke) + XYDrf_F1_tp.ijm(mask_dke))./XYmhum(mask_dke);%XYDmp_rf_ijm
    %
    ZXYD_rf_tp.mm1_ijp = (XY1mmhu2p(mask_dke) - XYyn(mask_dke)).^2.*(XYDrf_D_tp.ijp(mask_dke) + XYDrf_F1_tp.ijp(mask_dke))./XYmhu2p(mask_dke);%XYDmm_rf_ijp
    ZXYD_rf_tp.mm1_ijm = (XY1mmhu2m(mask_dke) - XYyn(mask_dke)).^2.*(XYDrf_D_tp.ijm(mask_dke) + XYDrf_F1_tp.ijm(mask_dke))./XYmhu2m(mask_dke);%XYDmm_rf_ijm
    %
    clear XYDrf_F1_tp XYDrf_D_tp
    %
    % ------------------------------------------------------------------------------------------------------------------
    %
    XYmhu5p = XYmhu2p./XYmhu2p./XYmhup;
    XYmhu4 = XYmhu2./XYmhu2;
    XYmhu5m = XYmhu2m./XYmhu2m./XYmhum;
    %
    ZXYF_rf_tp.p_ippj = - XY1mmhu2(mask_dke).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*XYDrf_F_tp.ippj(mask_dke)./XYmhu4(mask_dke)./XYpnpp(mask_dke); 
    ZXYF_rf_tp.p_ipj = - XY1mmhu2(mask_dke).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*XYDrf_F_tp.ipj(mask_dke)./XYmhu4(mask_dke)./XYpnp(mask_dke);
    ZXYF_rf_tp.p_ij = - XY1mmhu2(mask_dke).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*XYDrf_F_tp.ij(mask_dke)./XYmhu4(mask_dke)./XYpn(mask_dke); 
    ZXYF_rf_tp.p_imj = - XY1mmhu2(mask_dke).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*XYDrf_F_tp.imj(mask_dke)./XYmhu4(mask_dke)./XYpnm(mask_dke);
    ZXYF_rf_tp.p_immj = - XY1mmhu2(mask_dke).*(XY1mmhu2(mask_dke) - XYyn(mask_dke)).*XYDrf_F_tp.immj(mask_dke)./XYmhu4(mask_dke)./XYpnmm(mask_dke);
    %
    ZXYF_rf_tp.m_ijp = sqrt(XY1mmhu2p(mask_dke)).*(XY1mmhu2p(mask_dke) - XYyn(mask_dke)).^2.*XYDrf_F_tp.ijp(mask_dke)./XYmhu5p(mask_dke)./XYpn(mask_dke);
    ZXYF_rf_tp.m_ijm = sqrt(XY1mmhu2m(mask_dke)).*(XY1mmhu2m(mask_dke) - XYyn(mask_dke)).^2.*XYDrf_F_tp.ijm(mask_dke)./XYmhu5m(mask_dke)./XYpn(mask_dke);
    %
    clear XYDrf_F_tp XYmhu5p XYmhu4 XYmhu5m 
    %
    gridindex_rf.mask_dke = mask_dke;
    %
    clear mask_dke
    %
    %iXX = double(((mask_r(mask_dke) - 1)*nmhu + (mask_m(mask_dke) - 1))*npn + mask_p(mask_dke));
    %iyn = double((mask_n(mask_dke) - 1)*nb + mask_y(mask_dke));
    %
    %ZXXD_rf_tp.pp_ippj =   sparse(iyn,iXX,double(ZXYD_rf_tp.pp_ippj),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.pp_ipj =    sparse(iyn,iXX,double(ZXYD_rf_tp.pp_ipj ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.pp_ij =     sparse(iyn,iXX,double(ZXYD_rf_tp.pp_ij  ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.pp_imj =    sparse(iyn,iXX,double(ZXYD_rf_tp.pp_imj ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.pp_immj =   sparse(iyn,iXX,double(ZXYD_rf_tp.pp_immj),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.pm_ipj =    sparse(iyn,iXX,double(ZXYD_rf_tp.pm_ipj ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.pm_ij =     sparse(iyn,iXX,double(ZXYD_rf_tp.pm_ij  ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.pm_imj =    sparse(iyn,iXX,double(ZXYD_rf_tp.pm_imj ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.mp_ijp =    sparse(iyn,iXX,double(ZXYD_rf_tp.mp_ijp ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.mp_ij =     sparse(iyn,iXX,double(ZXYD_rf_tp.mp_ij  ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.mp_ijm =    sparse(iyn,iXX,double(ZXYD_rf_tp.mp_ijm ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.mm_ijp =    sparse(iyn,iXX,double(ZXYD_rf_tp.mm_ijp ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.mm_ijm =    sparse(iyn,iXX,double(ZXYD_rf_tp.mm_ijm ),nb*nn_rf,npn*nmhu*nr_dke);
    %
    %ZXXD_rf_tp.mp1_ijp =   sparse(iyn,iXX,double(ZXYD_rf_tp.mp1_ijp),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.mp1_ij =    sparse(iyn,iXX,double(ZXYD_rf_tp.mp1_ij ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.mp1_ijm =   sparse(iyn,iXX,double(ZXYD_rf_tp.mp1_ijm),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.mm1_ijp =   sparse(iyn,iXX,double(ZXYD_rf_tp.mm1_ijp),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXD_rf_tp.mm1_ijm =   sparse(iyn,iXX,double(ZXYD_rf_tp.mm1_ijm),nb*nn_rf,npn*nmhu*nr_dke);
    %
    %ZXXF_rf_tp.p_ippj =    sparse(iyn,iXX,double(ZXYF_rf_tp.p_ippj ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXF_rf_tp.p_ipj =     sparse(iyn,iXX,double(ZXYF_rf_tp.p_ipj  ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXF_rf_tp.p_ij =      sparse(iyn,iXX,double(ZXYF_rf_tp.p_ij   ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXF_rf_tp.p_imj =     sparse(iyn,iXX,double(ZXYF_rf_tp.p_imj  ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXF_rf_tp.p_immj =    sparse(iyn,iXX,double(ZXYF_rf_tp.p_immj ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXF_rf_tp.m_ijp =     sparse(iyn,iXX,double(ZXYF_rf_tp.m_ijp  ),nb*nn_rf,npn*nmhu*nr_dke);
    %ZXXF_rf_tp.m_ijm =     sparse(iyn,iXX,double(ZXYD_rf_tp.m_ijm  ),nb*nn_rf,npn*nmhu*nr_dke);
    %
else
    ZXYD_rf_tp = NaN;
    ZXYF_rf_tp = NaN;
end            
%
clear XYmhup XYmhu XYmhum XY1mmhu2p XY1mmhu2 XY1mmhu2m XYyn XYold
%
gridindex_rf.mask_p = mask_p;
gridindex_rf.mask_m = mask_m;
gridindex_rf.mask_y = mask_y;
gridindex_rf.mask_r = mask_r;
gridindex_rf.mask_n = mask_n;
%
%iXX = double(((mask_r - 1)*nmhu + (mask_m - 1))*npn + mask_p);
%iyn = double((mask_n - 1)*nb + mask_y);
%
%clear mask_r mask_m mask_p mask_n mask_y 
%
%ZXXD_rf.pp_ippj =  sparse(iyn,iXX,double(ZXYD_rf.pp_ippj   ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.pp_ipj =   sparse(iyn,iXX,double(ZXYD_rf.pp_ipj    ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.pp_ij =    sparse(iyn,iXX,double(ZXYD_rf.pp_ij     ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.pp_imj =   sparse(iyn,iXX,double(ZXYD_rf.pp_imj    ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.pp_immj =  sparse(iyn,iXX,double(ZXYD_rf.pp_immj   ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.pm_ipj =   sparse(iyn,iXX,double(ZXYD_rf.pm_ipj    ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.pm_ij =    sparse(iyn,iXX,double(ZXYD_rf.pm_ij     ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.pm_imj =   sparse(iyn,iXX,double(ZXYD_rf.pm_imj    ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.mp_ijp =   sparse(iyn,iXX,double(ZXYD_rf.mp_ijp    ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.mp_ij =    sparse(iyn,iXX,double(ZXYD_rf.mp_ij     ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.mp_ijm =   sparse(iyn,iXX,double(ZXYD_rf.mp_ijm    ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.mm_ijp =   sparse(iyn,iXX,double(ZXYD_rf.mm_ijp    ),nb*nn_rf,npn*nmhu*nr);
%ZXXD_rf.mm_ijm =   sparse(iyn,iXX,double(ZXYD_rf.mm_ijm    ),nb*nn_rf,npn*nmhu*nr);
%
%
etime_rf = etime_rf + etime(clock,time0);
if display_mode >= 1,info_dke_yp(2,['RF flux coefficients calculations done in ',num2str(etime_rf),' (s)']);end	
