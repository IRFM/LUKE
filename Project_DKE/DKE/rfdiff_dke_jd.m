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
[qe,me,mp,mn,e0] = pc_dke_yp;%Universal physics constant
%
rf_tol = eps('single');% threshold for calculation mask on deltares
%
n_rf_list = single(dkeparam.n_rf_list);
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
ap = equilDKE.ap;
xdV_2piRp_dke = equilDKE.xdV_2piRp_dke;
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
xqtilde = Zbouncecoef.xqtilde;
xqhat = Zbouncecoef.xqhat;
Xxlambdap = Zbouncecoef.Xxlambda_p;
Xxlambda = Zbouncecoef.Xxlambda;
Xxlambdam = Zbouncecoef.Xxlambda_m;
XXheavisidep = Zbouncecoef.XXheaviside_p;
XXheaviside = Zbouncecoef.XXheaviside;
XXheavisidem = Zbouncecoef.XXheaviside_m;
%
betath_ref = mksa.betath_ref;
ne_ref = mksa.ne_ref;
lnc_e_ref = mksa.lnc_e_ref;
%
rdke = radialDKE.r_dke;
%
Xsigmap = sign(Xmhup);
Xsigma = sign(Xmhu);
Xsigmam = sign(Xmhum);
%
pnmax = max(Xpn(:,1));
%
% RF wave parameters
%
biy_rf = uint32(waveparam.biy_rf);% subray the fragment belongs to
bir_rf = uint32(waveparam.bir_rf);% FS the fragment belongs to
bds_rf = single(waveparam.bds_rf);% ray fragement path length
bomega_rf = single(waveparam.bomega_rf);% RF wave frequency 
bopt_rf = uint32(waveparam.bopt_rf);% options for Larmor radius effects and/or LH calc.  
%                               - 0:exact, 
%                               - 1:approx (kperp*rhoe<<1)
%                               - 2: kperp*rhoe<<1 and old LH calc. (Karney, Shoucri)
bthetab_rf = single(waveparam.bthetab_rf);% poloidal location along the ray (bounce_mode>0 only)
bB_rf = single(waveparam.bB_rf);% B field along the ray
bnpar_rf = single(waveparam.bNpar_rf);% n_par along the ray
bdnpar_rf = single(waveparam.bdNpar_rf);% dn_par along the ray
bnperp_rf = single(waveparam.bNperp_rf);%  n_perp along the ray
bepolp_rf = single(waveparam.bepolp_rf);%  polarization plus along the ray
bepolm_rf = single(waveparam.bepolm_rf);%  polarization minus along the ray
bepolz_rf = single(waveparam.bepolz_rf);%  polarization parallel along the ray
bphinorm_rf = single(waveparam.bphinorm_rf);%  normalized energy flow density along the ray
%
clear dkeparam display equilDKE gridDKE Zmomcoef Zbouncecoef mksa radialDKE waveparam
%
[npn,nmhu] = size(Xpn);
nr = length(xB0);
nr_dke = length(rdke);
nb = length(biy_rf);
ny = double(max([biy_rf,0]));
nn_rf = length(n_rf_list);
%
gridindex_rf.npn = npn;
gridindex_rf.nmhu = nmhu;
gridindex_rf.nr = nr;
gridindex_rf.nr_dke = nr_dke;
gridindex_rf.ny = ny;
gridindex_rf.nn_rf = nn_rf;
%
% Case where no RF wave is to be accounted for
%
if nb == 0,
    ZXYD_rf = [];
    ZXYD_rf_tp = [];
    ZXYF_rf_tp = [];
    %
    gridindex_rf.mask_p = zeros(0,0,'uint32');%mask of indices in the momentum grid
    gridindex_rf.mask_m = zeros(0,0,'uint32');%mask of indices in the pitch angle grid
    gridindex_rf.mask_r = zeros(0,0,'uint32');%mask of indices in the radial grid
    gridindex_rf.mask_y = zeros(0,0,'uint32');%mask of indices in the ray fragments list
    gridindex_rf.mask_n = zeros(0,0,'uint32');%mask of indices in the harmonic number list
    gridindex_rf.mask_dke = zeros(0,0,'uint32');%mask of indices in the DKE grid list
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
%
%
[biy_rf_sort,ib_sort] = sort(biy_rf);
bomega_rf_sort = bomega_rf(ib_sort);
iy_sort = 1+[0,find(diff(biy_rf_sort) ~= 0)];
if iy_sort ~= (1:ny),
    error('subray list is inconsistent')
end
%
yomega_rf = bomega_rf_sort(iy_sort);
%
if length(theta) > 1,
    xbxb_rf = interp1(theta,Xx.',bthetab_rf);
    xbyb_rf = interp1(theta,Xy.',bthetab_rf);
    xbBxb_rf = interp1(theta,XBx.',bthetab_rf);
    xbByb_rf = interp1(theta,XBy.',bthetab_rf);
    xbBphib_rf = interp1(theta,XBphi.',bthetab_rf);
else
    xbxb_rf = Xx;
    xbyb_rf = Xy;
    xbBxb_rf = XBx;
    xbByb_rf = XBy;
    xbBphib_rf = XBphi;
end    
%
if nr > 1,
    xbxb_rf = xbxb_rf.';
    xbyb_rf = xbyb_rf.';
    xbBxb_rf = xbBxb_rf.';
    xbByb_rf = xbByb_rf.';
    xbBphib_rf = xbBphib_rf.';    
end
%
xbrb_rf = sqrt(xbxb_rf.^2 + xbyb_rf.^2);% minor radius at theta = thetab_rf at the center of any FS
xbBPb_rf = sqrt(xbBxb_rf.^2 + xbByb_rf.^2);% poloidal magnetic field at theta = thetab_rf at the center of any FS
xbBb_rf = sqrt(xbBPb_rf.^2 + xbBphib_rf.^2);% magnetic field at theta = thetab_rf at the center of any FS
xbcosb_rf = abs(xbBxb_rf.*xbyb_rf - xbByb_rf.*xbxb_rf)./xbrb_rf./xbBPb_rf;
%
xbmask_rf = uint32((0:nb-1)*nr) + bir_rf;
bxb_rf = xbxb_rf(xbmask_rf);% horizontal poloidal position at theta = thetab_rf at the center of the FS
bBPb_rf = xbBPb_rf(xbmask_rf);% poloidal magnetic field at theta = thetab_rf at the center of the FS
bBb_rf = xbBb_rf(xbmask_rf);% magnetic field at theta = thetab_rf at the center of the FS
brb_rf = xbrb_rf(xbmask_rf);% minor radius at theta = thetab_rf at the center of the FS
bcosb_rf = xbcosb_rf(xbmask_rf);% cos alpha at theta = thetab_rf at the center of the FS
%
%if bounce_mode > 0,
    bB0 = single(xB0(bir_rf));
    %
    bpsib = bBb_rf./bB0; %Ratio of magnetic fields at theta = thetab_rf at the center of the FS
%else
%    bpsib = ones(1,nb); %Ratio of magnetic fields at theta = thetab_rf at the center of the FS
%end
%
bomegaratio = qe*bB_rf./bomega_rf/me; % cyclotron frequency along the ray path
%
bkperprho = bnperp_rf*betath_ref./bomegaratio;
bZbfac = bkperprho.*sqrt(bpsib);% momentum-independent factor in XBZb
%
% Spectral properties
%
bnpar_acc = imag(bnpar_rf);%accessibility condition
bnpar_acc(bnpar_acc == 0) = Inf;
bnpar_rf = real(bnpar_rf);%actual npar value
%
bnparmin_rf = NaN*ones(1,nb,'single');
bnparmax_rf = NaN*ones(1,nb,'single');
%
bmask_gauss = (imag(bdnpar_rf) == 0);
%
bnparmin_rf(~bmask_gauss) = bnpar_rf(~bmask_gauss) - imag(bdnpar_rf(~bmask_gauss))/2;
bnparmax_rf(~bmask_gauss) = bnpar_rf(~bmask_gauss) + imag(bdnpar_rf(~bmask_gauss))/2;
%
bnparmin_rf(bmask_gauss) = bnpar_rf(bmask_gauss) - bdnpar_rf(bmask_gauss).*sqrt(-log(rf_tol*sqrt(pi)*bdnpar_rf(bmask_gauss)));
bnparmax_rf(bmask_gauss) = bnpar_rf(bmask_gauss) + bdnpar_rf(bmask_gauss).*sqrt(-log(rf_tol*sqrt(pi)*bdnpar_rf(bmask_gauss)));
%
bdnpar_rf = abs(bdnpar_rf);
%
% Diffusion coefficient (normalized to the incident power per unit length along the major radius in W/m)
%
wpe_ref = sqrt(ne_ref*qe^2/e0/me);
%
bphinorm_rf(bphinorm_rf == 0) = eps('single');%avoid singularities
%
bqtilde = single(xqtilde(bir_rf));
bdV_2piRp_dke = single(xdV_2piRp_dke(bir_rf));
%
bFtilde = brb_rf.*bBb_rf./(ap*bBPb_rf.*bqtilde.*bcosb_rf);
%
if ~isempty(bds_rf),
    bD0_rf = 4*pi^2*bds_rf.*bFtilde./(me*lnc_e_ref*wpe_ref^2.*bomega_rf.*bphinorm_rf.*bdV_2piRp_dke);
else
    %
    % note that in this case bphinorm_rf should be replaced by bphi_perp_rf
    %
    bqhat = single(xqhat(bir_rf));
    bFhat = brb_rf.*bB0./(ap*bBPb_rf.*bqhat.*bcosb_rf*(1 + bxb_rf/Rp));    
    bD0_rf = 4*pi^2.*bFhat.*bFtilde./(me*lnc_e_ref*wpe_ref^2.*bomega_rf.*bphinorm_rf*2*pi.*brb_rf);
end
%
% Determination of (np*nmhu*nb*nr*n_rf)-space points to be accounted for
%
%
% sum over harmonic numbers and rays
%
if display_mode > 1, h = waitbar(0);end
%
% mask calculation of point that must be calculated
%    
Nmat = npn*nmhu*min([nb,100]);
%
mask_p = zeros(Nmat,1,'uint32');%mask of indices in the momentum grid
mask_m = zeros(Nmat,1,'uint32');%mask of indices in the pitch angle grid
mask_b = zeros(Nmat,1,'uint32');%mask of indices in the ray fragments
mask_n = zeros(Nmat,1,'uint32');%mask of indices in the harmonic number list
%
iX = 1;
iMat = 1;
%
for in = 1:nn_rf,
    %
    n_rf = n_rf_list(in);
    %
    % Preselection based on the momentum space localization of the resonance curves
    %
    % See J. Decker PoP 13, 112503 (2006) Eq. 32
    %
    byn_rf = n_rf*bomegaratio;
    %
    bmask_n1 = (bnpar_rf == 1);
    bmask_yn = (abs(bnpar_rf) > 1 | byn_rf > sqrt(1 - bnpar_rf.^2));
    bpn_res = abs((abs(bnpar_rf).*byn_rf - sqrt(byn_rf.^2 + bnpar_rf.^2 - 1))./(1 - bnpar_rf.^2))/betath_ref;
    bpn_res_n1 = abs(1 - byn_rf.^2)./(2*byn_rf*betath_ref);
    bpn_res(bmask_n1) = bpn_res_n1(bmask_n1);
    %
    bmask_n1_min = (bnparmin_rf == 1);
    bmask_yn_min = (abs(bnparmin_rf) > 1 | byn_rf > sqrt(1 - bnparmin_rf.^2));
    bpn_res_min = abs((abs(bnparmin_rf).*byn_rf - sqrt(byn_rf.^2 + bnparmin_rf.^2 - 1))./(1 - bnparmin_rf.^2))/betath_ref;
    bpn_res_n1_min = abs(1 - byn_rf.^2)./(2*byn_rf*betath_ref);
    bpn_res_min(bmask_n1_min) = bpn_res_n1_min(bmask_n1_min);
    %
    bmask_n1_max = (bnparmax_rf == 1);
    bmask_yn_max = (abs(bnparmax_rf) > 1 | byn_rf > sqrt(1 - bnparmax_rf.^2));
    bpn_res_max = abs((abs(bnparmax_rf).*byn_rf - sqrt(byn_rf.^2 + bnparmax_rf.^2 - 1))./(1 - bnparmax_rf.^2))/betath_ref;
    bpn_res_n1_max = abs(1 - byn_rf.^2)./(2*byn_rf*betath_ref);
    bpn_res_max(bmask_n1_max) = bpn_res_n1_max(bmask_n1_max);
    %
    bmask = find((bmask_yn & bpn_res < pnmax) | (bmask_yn_min & bpn_res_min < pnmax) | (bmask_yn_max & bpn_res_max < pnmax));
    %
    for ib = bmask,   
        %
        Xmaskb = (bpsib(ib).*X1mmhu2 <= 1); % condition thetab_rf < thetaT
        %	    
        Xmhub = Xmaskb.*Xsigma.*sqrt(1 - bpsib(ib).*X1mmhu2);%mhu at theta = thetab_rf at the center of the FS
        Xmhub(Xmhub == 0) = eps('single');
        %
        % Resonance Condition: resonant Npar
        %
        Xnparres_ij = (Xgamma - n_rf.*bomegaratio(ib))./Xpn./Xmhub/betath_ref;
        %
        % Resonance Condition: delta function (normalized to: int(deltares d_npar) = 1)
        %
        if bmask_gauss(ib),
            Xdeltares_ij = exp(-(Xnparres_ij - bnpar_rf(ib)).^2./bdnpar_rf(ib).^2)./bdnpar_rf(ib)/sqrt(pi);
        else
            Xdeltares_ij = (Xnparres_ij > bnparmin_rf(ib)).*(bnparmax_rf(ib) > Xnparres_ij)./bdnpar_rf(ib);
        end
		%
		Xdeltares_ij(abs(Xnparres_ij) > bnpar_acc(ib)) = 0;%accessibility condition
        %
        X_index_ij = (Xdeltares_ij >= rf_tol) | (~XXheaviside(:,:,bir_rf(ib)) & fliplr(Xdeltares_ij) >= rf_tol);
        %
        % neighboring points are also accounted for
        %
        X_index_immj = X_index_ij;X_index_immj(2:npn,:) = X_index_ij(1:npn-1,:);
        X_index_ippj = X_index_ij;X_index_ippj(1:npn-1,:) = X_index_ij(2:npn,:);
        X_index_ijmm = X_index_ij;X_index_ijmm(:,2:nmhu) = X_index_ij(:,1:nmhu-1);
        X_index_ijpp = X_index_ij;X_index_ijpp(:,1:nmhu-1) = X_index_ij(:,2:nmhu);      
        %
        X_index = find(X_index_ij | X_index_immj | X_index_ippj | X_index_ijmm | X_index_ijpp);
        %
        m_index = ceil(X_index/npn);
        p_index = X_index - (m_index - 1)*npn;
        b_index = ib*ones(size(X_index));
        n_index = in*ones(size(X_index));
        %
        N_index = length(m_index);
        %
        mask_index = iX:iX + N_index - 1;
		%
		while iX + N_index - 1 > iMat*Nmat,
			%
			iMat = iMat + 1; 
			%
			mask_p = [mask_p;zeros(Nmat,1,'uint32')];%mask of indices in the momentum grid
			mask_m = [mask_m;zeros(Nmat,1,'uint32')];%mask of indices in the pitch angle grid
			mask_b = [mask_b;zeros(Nmat,1,'uint32')];%mask of indices in the ray fragments
			mask_n = [mask_n;zeros(Nmat,1,'uint32')];%mask of indices in the harmonic number list
			%
		end
        %
        mask_p(mask_index) = p_index;
        mask_m(mask_index) = m_index;
        mask_b(mask_index) = b_index;
        mask_n(mask_index) = n_index;
        %
        iX = iX + N_index;
	%
        if display_mode > 1, waitbar((ib + nb*(in - 1))/(nb*nn_rf),h);end
        %
    end
    %
end
%
if display_mode >1, close(h); end
%
mask_0 = 1:iX - 1;
%
mask_p = mask_p(mask_0);%mask of indices in the momentum grid
mask_m = mask_m(mask_0);%mask of indices in the pitch angle grid
mask_b = mask_b(mask_0);%mask of indices in the ray fragments
mask_n = mask_n(mask_0);%mask of indices in the harmonic number list
%
clear XXsigma XX1mmhu2 XXpn XXgamma XXpsib XXomegac XXmaskb XXmhub 
clear XXomega_rf XXnparmin_rf XXnparmax_rf XXnpar_rf XXdnpar_rf
clear XXmask_square  XXmask_gauss XXnparres_ij XXdeltares_ij 
clear XX_index XX_index_ij XX_index_immj XX_index_ippj XX_index_ijmm XX_index_ijpp
clear p_index m_index r_index b_index n_index
clear mask_index mask_0 N_index N iX imat
%
Nmax = 2000000;
%
SXB = size(mask_p);
nXB = length(mask_p);
%
XBDrf.ippj = zeros(SXB,'single');
XBDrf.ipj = zeros(SXB,'single');
XBDrf.ij = zeros(SXB,'single');
XBDrf.imj = zeros(SXB,'single');
XBDrf.immj = zeros(SXB,'single');
XBDrf.ijp = zeros(SXB,'single');
XBDrf.ijm = zeros(SXB,'single');
%
for ibloc = 1:ceil(nXB/Nmax),
%
bloc_mask = (ibloc - 1)*Nmax + 1:min([ibloc*Nmax,nXB]);
%
mask_p_bloc = mask_p(bloc_mask);
mask_m_bloc = mask_m(bloc_mask);
mask_b_bloc = mask_b(bloc_mask);
mask_n_bloc = mask_n(bloc_mask);
%
SXB_bloc = size(mask_p_bloc);
%
Xmask = (mask_m_bloc - 1)*npn + mask_p_bloc;%mask in momentum 2-D matrices
%
% Vector construction
%
XBn_rf = n_rf_list(mask_n_bloc);
if nn_rf > 1,
    XBn_rf = XBn_rf.';
end
%
if nb > 1, 
    XByn = XBn_rf.*bomegaratio(mask_b_bloc).';
    XBpsib = bpsib(mask_b_bloc).';   
else
    XByn = XBn_rf.*bomegaratio(mask_b_bloc);
    XBpsib = bpsib(mask_b_bloc);   
end
%
XBpnpp = single(Xpnpp(Xmask));
XBpnp = single(Xpnp(Xmask));
XBpn = single(Xpn(Xmask));
XBpnm = single(Xpnm(Xmask));
XBpnmm = single(Xpnmm(Xmask));
%
XBgammapp = single(Xgammapp(Xmask));
XBgammap = single(Xgammap(Xmask));
XBgamma = single(Xgamma(Xmask));
XBgammam = single(Xgammam(Xmask));
XBgammamm = single(Xgammamm(Xmask));
%
XBsigmap = single(Xsigmap(Xmask));
XBsigma = single(Xsigma(Xmask));
XBsigmam = single(Xsigmam(Xmask));
%
XB1mmhu2p = single(X1mmhu2p(Xmask));
XB1mmhu2 = single(X1mmhu2(Xmask));
XB1mmhu2m = single(X1mmhu2m(Xmask));
%
XB1mmhu2p(XB1mmhu2p == 0) = eps('single');
XB1mmhu2(XB1mmhu2 == 0) =  eps('single');
XB1mmhu2m(XB1mmhu2m == 0) =  eps('single');
%
XBmaskb = (XBpsib.*XB1mmhu2p <= 1) & (XBpsib.*XB1mmhu2 <= 1) & (XBpsib.*XB1mmhu2m <= 1);
%
XBmhubp = XBmaskb.*XBsigmap.*sqrt(1 - XBpsib.*XB1mmhu2p);
XBmhub = XBmaskb.*XBsigma.*sqrt(1 - XBpsib.*XB1mmhu2);
XBmhubm = XBmaskb.*XBsigmam.*sqrt(1 - XBpsib.*XB1mmhu2m);
%
clear XBmaskb
%
if dke_mode == 0,
    %
    clear XBsigmap XBsigma XBsigmam
    %            
end     
%
XBmhubp(XBmhubp == 0) = eps('single');
XBmhub(XBmhub == 0) =  eps('single');
XBmhubm(XBmhubm == 0) =  eps('single');
%
% Resonant Npar
%
XBnparres.ippj = (XBgammapp - XByn)./XBpnpp./XBmhub/betath_ref;
XBnparres.ipj = (XBgammap - XByn)./XBpnp./XBmhub/betath_ref;
XBnparres.ij = (XBgamma - XByn)./XBpn./XBmhub/betath_ref;
XBnparres.imj = (XBgammam - XByn)./XBpnm./XBmhub/betath_ref;
XBnparres.immj = (XBgammamm - XByn)./XBpnmm./XBmhub/betath_ref;
XBnparres.ijp = (XBgamma - XByn)./XBpn./XBmhubp/betath_ref;
XBnparres.ijm = (XBgamma - XByn)./XBpn./XBmhubm/betath_ref;
%
clear XByn
%
% Resonance Condition: delta function (normalized to: int(deltares d_npar) = 1)
%
if nb > 1,
    XBmask_gauss = bmask_gauss(mask_b_bloc).';
    XBmask_square = ~bmask_gauss(mask_b_bloc).';
    %
    XBnparmin_rf = bnparmin_rf(mask_b_bloc).';
    XBnparmax_rf = bnparmax_rf(mask_b_bloc).';
    XBnpar_rf = bnpar_rf(mask_b_bloc).';
    XBdnpar_rf = bdnpar_rf(mask_b_bloc).';
	XBnpar_acc = bnpar_acc(mask_b_bloc).';
    %
    XBZbfac = bZbfac(mask_b_bloc).';
else
    XBmask_gauss = bmask_gauss(mask_b_bloc);
    XBmask_square = ~bmask_gauss(mask_b_bloc);
    %
    XBnparmin_rf = bnparmin_rf(mask_b_bloc);
    XBnparmax_rf = bnparmax_rf(mask_b_bloc);
    XBnpar_rf = bnpar_rf(mask_b_bloc);
    XBdnpar_rf = bdnpar_rf(mask_b_bloc);
	XBnpar_acc = bnpar_acc(mask_b_bloc);
    %
    XBZbfac = bZbfac(mask_b_bloc);
end    
%
XBdeltares.ippj = zeros(SXB_bloc,'single');
XBdeltares.ipj = zeros(SXB_bloc,'single');
XBdeltares.ij = zeros(SXB_bloc,'single');
XBdeltares.imj = zeros(SXB_bloc,'single');
XBdeltares.immj = zeros(SXB_bloc,'single');
XBdeltares.ijp = zeros(SXB_bloc,'single');
XBdeltares.ijm = zeros(SXB_bloc,'single');
%
XBdeltares.ippj(XBmask_square) = (XBnparres.ippj(XBmask_square) > XBnparmin_rf(XBmask_square)).*(XBnparmax_rf(XBmask_square) > XBnparres.ippj(XBmask_square))./XBdnpar_rf(XBmask_square);
XBdeltares.ippj(XBmask_gauss) = exp(-(XBnparres.ippj(XBmask_gauss) - XBnpar_rf(XBmask_gauss)).^2./XBdnpar_rf(XBmask_gauss).^2)./XBdnpar_rf(XBmask_gauss)/sqrt(pi);
XBdeltares.ippj(abs(XBnparres.ippj) > XBnpar_acc) = 0;
%
XBdeltares.ipj(XBmask_square) = (XBnparres.ipj(XBmask_square) > XBnparmin_rf(XBmask_square)).*(XBnparmax_rf(XBmask_square) > XBnparres.ipj(XBmask_square))./XBdnpar_rf(XBmask_square);
XBdeltares.ipj(XBmask_gauss) = exp(-(XBnparres.ipj(XBmask_gauss) - XBnpar_rf(XBmask_gauss)).^2./XBdnpar_rf(XBmask_gauss).^2)./XBdnpar_rf(XBmask_gauss)/sqrt(pi);
XBdeltares.ipj(abs(XBnparres.ipj) > XBnpar_acc) = 0;
%
XBdeltares.ij(XBmask_square) = (XBnparres.ij(XBmask_square) > XBnparmin_rf(XBmask_square)).*(XBnparmax_rf(XBmask_square) > XBnparres.ij(XBmask_square))./XBdnpar_rf(XBmask_square);
XBdeltares.ij(XBmask_gauss) = exp(-(XBnparres.ij(XBmask_gauss) - XBnpar_rf(XBmask_gauss)).^2./XBdnpar_rf(XBmask_gauss).^2)./XBdnpar_rf(XBmask_gauss)/sqrt(pi);
XBdeltares.ij(abs(XBnparres.ij) > XBnpar_acc) = 0;
%
XBdeltares.imj(XBmask_square) = (XBnparres.imj(XBmask_square) > XBnparmin_rf(XBmask_square)).*(XBnparmax_rf(XBmask_square) > XBnparres.imj(XBmask_square))./XBdnpar_rf(XBmask_square);
XBdeltares.imj(XBmask_gauss) = exp(-(XBnparres.imj(XBmask_gauss) - XBnpar_rf(XBmask_gauss)).^2./XBdnpar_rf(XBmask_gauss).^2)./XBdnpar_rf(XBmask_gauss)/sqrt(pi);
XBdeltares.imj(abs(XBnparres.imj) > XBnpar_acc) = 0;
%
XBdeltares.immj(XBmask_square) = (XBnparres.immj(XBmask_square) > XBnparmin_rf(XBmask_square)).*(XBnparmax_rf(XBmask_square) > XBnparres.immj(XBmask_square))./XBdnpar_rf(XBmask_square);
XBdeltares.immj(XBmask_gauss) = exp(-(XBnparres.immj(XBmask_gauss) - XBnpar_rf(XBmask_gauss)).^2./XBdnpar_rf(XBmask_gauss).^2)./XBdnpar_rf(XBmask_gauss)/sqrt(pi);
XBdeltares.immj(abs(XBnparres.immj) > XBnpar_acc) = 0;
%
XBdeltares.ijp(XBmask_square) = (XBnparres.ijp(XBmask_square) > XBnparmin_rf(XBmask_square)).*(XBnparmax_rf(XBmask_square) > XBnparres.ijp(XBmask_square))./XBdnpar_rf(XBmask_square);
XBdeltares.ijp(XBmask_gauss) = exp(-(XBnparres.ijp(XBmask_gauss) - XBnpar_rf(XBmask_gauss)).^2./XBdnpar_rf(XBmask_gauss).^2)./XBdnpar_rf(XBmask_gauss)/sqrt(pi);
XBdeltares.ijp(abs(XBnparres.ijp) > XBnpar_acc) = 0;
%
XBdeltares.ijm(XBmask_square) = (XBnparres.ijm(XBmask_square) > XBnparmin_rf(XBmask_square)).*(XBnparmax_rf(XBmask_square) > XBnparres.ijm(XBmask_square))./XBdnpar_rf(XBmask_square);
XBdeltares.ijm(XBmask_gauss) = exp(-(XBnparres.ijm(XBmask_gauss) - XBnpar_rf(XBmask_gauss)).^2./XBdnpar_rf(XBmask_gauss).^2)./XBdnpar_rf(XBmask_gauss)/sqrt(pi);
XBdeltares.ijm(abs(XBnparres.ijm) > XBnpar_acc) = 0;
%
clear XBnparres XBmask_square XBmask_gauss XBnparmin_rf XBnparmax_rf XBnpar_rf XBdnpar_rf XBnpar_acc
%
% FLR factor k_perp*rho_perp
% 
XBZb.ippj = -XBZbfac.*XBpnpp.*sqrt(XB1mmhu2);
XBZb.ipj = -XBZbfac.*XBpnp.*sqrt(XB1mmhu2);
XBZb.ij = -XBZbfac.*XBpn.*sqrt(XB1mmhu2);
XBZb.imj = -XBZbfac.*XBpnm.*sqrt(XB1mmhu2);
XBZb.immj = -XBZbfac.*XBpnmm.*sqrt(XB1mmhu2);
XBZb.ijp = -XBZbfac.*XBpn.*sqrt(XB1mmhu2p);
XBZb.ijm = -XBZbfac.*XBpn.*sqrt(XB1mmhu2m);
%
clear XBZbfac
%
% Polarization term 
%
% Polarization vector is normalized to 1.  
%
if nb > 1,
    XBepolp_rf = bepolp_rf(mask_b_bloc).'; 
    XBepolm_rf = bepolm_rf(mask_b_bloc).'; 
    XBepolz_rf = bepolz_rf(mask_b_bloc).'; 
    %
    XBlre = (bopt_rf(mask_b_bloc).' == 0); %(0): exact calculation for the Bessel functions, otherwise, limit k_perp*rho_perp << 1
else
    XBepolp_rf = bepolp_rf(mask_b_bloc); 
    XBepolm_rf = bepolm_rf(mask_b_bloc); 
    XBepolz_rf = bepolz_rf(mask_b_bloc); 
    %
    XBlre = (bopt_rf(mask_b_bloc) == 0); %(0): exact calculation for the Bessel functions, otherwise, limit k_perp*rho_perp << 1
end
%
XBmhuratiop = XBmhubp./sqrt(XBpsib.*XB1mmhu2p);
XBmhuratio = XBmhub./sqrt(XBpsib.*XB1mmhu2);
XBmhuratiom = XBmhubm./sqrt(XBpsib.*XB1mmhu2m);
%
clear XB1mmhu2p XB1mmhu2 XB1mmhu2m
%
XBpolb.ippj = XBepolp_rf.*besselj_dke_jd(XBn_rf + 1,XBZb.ippj,XBlre)/sqrt(2) + XBepolm_rf.*besselj_dke_jd(XBn_rf - 1,XBZb.ippj,XBlre)/sqrt(2)...
   - XBmhuratio.*XBepolz_rf.*besselj_dke_jd(XBn_rf,XBZb.ippj,XBlre);
XBpolb.ipj = XBepolp_rf.*besselj_dke_jd(XBn_rf + 1,XBZb.ipj,XBlre)/sqrt(2) + XBepolm_rf.*besselj_dke_jd(XBn_rf - 1,XBZb.ipj,XBlre)/sqrt(2)...
   - XBmhuratio.*XBepolz_rf.*besselj_dke_jd(XBn_rf,XBZb.ipj,XBlre);
XBpolb.ij = XBepolp_rf.*besselj_dke_jd(XBn_rf + 1,XBZb.ij,XBlre)/sqrt(2) + XBepolm_rf.*besselj_dke_jd(XBn_rf - 1,XBZb.ij,XBlre)/sqrt(2)...
   - XBmhuratio.*XBepolz_rf.*besselj_dke_jd(XBn_rf,XBZb.ij,XBlre);
XBpolb.imj = XBepolp_rf.*besselj_dke_jd(XBn_rf + 1,XBZb.imj,XBlre)/sqrt(2) + XBepolm_rf.*besselj_dke_jd(XBn_rf - 1,XBZb.imj,XBlre)/sqrt(2)...
   - XBmhuratio.*XBepolz_rf.*besselj_dke_jd(XBn_rf,XBZb.imj,XBlre);
XBpolb.immj = XBepolp_rf.*besselj_dke_jd(XBn_rf + 1,XBZb.immj,XBlre)/sqrt(2) + XBepolm_rf.*besselj_dke_jd(XBn_rf - 1,XBZb.immj,XBlre)/sqrt(2)...
   - XBmhuratio.*XBepolz_rf.*besselj_dke_jd(XBn_rf,XBZb.immj,XBlre);
XBpolb.ijp = XBepolp_rf.*besselj_dke_jd(XBn_rf + 1,XBZb.ijp,XBlre)/sqrt(2) + XBepolm_rf.*besselj_dke_jd(XBn_rf - 1,XBZb.ijp,XBlre)/sqrt(2)...
   - XBmhuratiop.*XBepolz_rf.*besselj_dke_jd(XBn_rf,XBZb.ijp,XBlre);
XBpolb.ijm = XBepolp_rf.*besselj_dke_jd(XBn_rf + 1,XBZb.ijm,XBlre)/sqrt(2) + XBepolm_rf.*besselj_dke_jd(XBn_rf - 1,XBZb.ijm,XBlre)/sqrt(2)...
   - XBmhuratiom.*XBepolz_rf.*besselj_dke_jd(XBn_rf,XBZb.ijm,XBlre);    
%
clear XBZb XBn_rf XBepolp_rf XBepolm_rf XBepolz_rf XBlre XBmhuratiop XBmhuratio XBmhuratiom 
%
XBrespol.ippj = XBdeltares.ippj.*abs(XBpolb.ippj).^2;
XBrespol.ipj = XBdeltares.ipj.*abs(XBpolb.ipj).^2;
XBrespol.ij = XBdeltares.ij.*abs(XBpolb.ij).^2;
XBrespol.imj = XBdeltares.imj.*abs(XBpolb.imj).^2;
XBrespol.immj = XBdeltares.immj.*abs(XBpolb.immj).^2;
XBrespol.ijp = XBdeltares.ijp.*abs(XBpolb.ijp).^2;
XBrespol.ijm = XBdeltares.ijm.*abs(XBpolb.ijm).^2;
%
clear XBdeltares XBpolb
%
%Sum over sigma for trapped particles - case FP
%
if dke_mode == 1,
    %
    XBrespol_tp = XBrespol;
    %
end
%
Yxmask = ((mask_n_bloc - 1)*nb + (mask_b_bloc - 1))*npn + mask_p_bloc;%mask in pnp-y-rho-n 4-D matrices
%
XBrespol_mhuflip.ippj = flipud(sparse(double(mask_m_bloc),double(Yxmask),double(XBrespol.ippj),nmhu,npn*nb*nn_rf));
XBrespol_mhuflip.ipj = flipud(sparse(double(mask_m_bloc),double(Yxmask),double(XBrespol.ipj),nmhu,npn*nb*nn_rf));
XBrespol_mhuflip.ij = flipud(sparse(double(mask_m_bloc),double(Yxmask),double(XBrespol.ij),nmhu,npn*nb*nn_rf));
XBrespol_mhuflip.imj = flipud(sparse(double(mask_m_bloc),double(Yxmask),double(XBrespol.imj),nmhu,npn*nb*nn_rf));
XBrespol_mhuflip.immj = flipud(sparse(double(mask_m_bloc),double(Yxmask),double(XBrespol.immj),nmhu,npn*nb*nn_rf));
XBrespol_mhuflip.ijp = flipud(sparse(double(mask_m_bloc),double(Yxmask),double(XBrespol.ijm),nmhu,npn*nb*nn_rf));
XBrespol_mhuflip.ijm = flipud(sparse(double(mask_m_bloc),double(Yxmask),double(XBrespol.ijp),nmhu,npn*nb*nn_rf));
%
XBmask = (Yxmask - 1)*nmhu + mask_m_bloc;
%
XBrespol_mhuflip.ippj = single(full(XBrespol_mhuflip.ippj(XBmask)));
XBrespol_mhuflip.ipj = single(full(XBrespol_mhuflip.ipj(XBmask)));
XBrespol_mhuflip.ij = single(full(XBrespol_mhuflip.ij(XBmask)));
XBrespol_mhuflip.imj = single(full(XBrespol_mhuflip.imj(XBmask)));
XBrespol_mhuflip.immj = single(full(XBrespol_mhuflip.immj(XBmask)));
XBrespol_mhuflip.ijp = single(full(XBrespol_mhuflip.ijp(XBmask)));
XBrespol_mhuflip.ijm = single(full(XBrespol_mhuflip.ijm(XBmask))); 
%
if dke_mode == 0,
    %
    clear Yxmask XBmask
    %
end
%
if nb > 1,
    mask_r_bloc = bir_rf(mask_b_bloc).';
else
    mask_r_bloc = bir_rf(mask_b_bloc);
end    
%
XXmask = ((mask_r_bloc - 1)*nmhu + (mask_m_bloc - 1))*npn + mask_p_bloc;%mask in rho-momentum 3-D matrices
%
XBtrapped_p = ~XXheavisidep(XXmask);
XBtrapped = ~XXheaviside(XXmask);
XBtrapped_m = ~XXheavisidem(XXmask);     
%
clear XXmask
%
XBrespol.ippj(XBtrapped) = (XBrespol.ippj(XBtrapped) + XBrespol_mhuflip.ippj(XBtrapped))/2;
XBrespol.ipj(XBtrapped) = (XBrespol.ipj(XBtrapped) + XBrespol_mhuflip.ipj(XBtrapped))/2;
XBrespol.ij(XBtrapped) = (XBrespol.ij(XBtrapped) + XBrespol_mhuflip.ij(XBtrapped))/2;
XBrespol.imj(XBtrapped) = (XBrespol.imj(XBtrapped) + XBrespol_mhuflip.imj(XBtrapped))/2;
XBrespol.immj(XBtrapped) = (XBrespol.immj(XBtrapped) + XBrespol_mhuflip.immj(XBtrapped))/2;
XBrespol.ijp(XBtrapped_p) = (XBrespol.ijp(XBtrapped_p) + XBrespol_mhuflip.ijp(XBtrapped_p))/2;
XBrespol.ijm(XBtrapped_m) = (XBrespol.ijm(XBtrapped_m) + XBrespol_mhuflip.ijm(XBtrapped_m))/2;
%
clear XBrespol_mhuflip
%
if dke_mode == 0,
    %
    clear XBtrapped_p XBtrapped XBtrapped_m
    %            
end
%
Xxmask = (mask_r_bloc - 1)*nmhu + mask_m_bloc;%mask in mhu-rho 2-D matrices
%
XBlambdap = Xxlambdap(Xxmask);
XBlambda = Xxlambda(Xxmask);        
XBlambdam = Xxlambdam(Xxmask);        
%
clear Xxmask 
%
XBlambdap(XBlambdap == 0) = eps('single');
XBlambda(XBlambda == 0) =  eps('single');
XBlambdam(XBlambdam == 0) =  eps('single');
%
XBmhup = single(Xmhup(Xmask));
XBmhu = single(Xmhu(Xmask));
XBmhum = single(Xmhum(Xmask));
%
clear Xmask 
%
if nb > 1,
    XBD0_rf = bD0_rf(mask_b_bloc).';
else
    XBD0_rf = bD0_rf(mask_b_bloc);
end
%
XBDfacp = XBD0_rf.*XBmhup.*XBmhup.*XBpsib./XBlambdap./XBmhubp./XBmhubp;
XBDfac = XBD0_rf.*XBmhu.*XBmhu.*XBpsib./XBlambda./XBmhub./XBmhub;
XBDfacm = XBD0_rf.*XBmhum.*XBmhum.*XBpsib./XBlambdam./XBmhubm./XBmhubm;
%
clear XBD0_rf
%
if dke_mode == 0,
    %
    clear XBpsib XBmhubp XBmhub XBmhubm XBlambdap XBlambda XBlambdam XBqratio
    %            
end     
%
%QL Diffusion Coefficient
%    
if nb > 1,
    XBold = (bopt_rf(mask_b_bloc).' == 2); %(2): no 1/vpar dependence (old method, benchmark Karney Shoucri) 
else
    XBold = (bopt_rf(mask_b_bloc) == 2); %(2): no 1/vpar dependence (old method, benchmark Karney Shoucri) 
end
%
if max(XBold(:)) > 0
    if display_mode >= 1,info_dke_yp(1,'WARNING: Old technique for calculating the LH matrix coefficients, for comparaison with previous versions (Karney, Shoucri)');end
end
%
XBDrf_bloc.ippj = zeros(SXB_bloc,'single');
XBDrf_bloc.ipj = zeros(SXB_bloc,'single');
XBDrf_bloc.ij = zeros(SXB_bloc,'single');
XBDrf_bloc.imj = zeros(SXB_bloc,'single');
XBDrf_bloc.immj = zeros(SXB_bloc,'single');
XBDrf_bloc.ijp = zeros(SXB_bloc,'single');
XBDrf_bloc.ijm = zeros(SXB_bloc,'single');
%
XBDrf_bloc.ippj(XBold) = XBrespol.ippj(XBold).*XBDfac(XBold);
XBDrf_bloc.ipj(XBold) = XBrespol.ipj(XBold).*XBDfac(XBold);
XBDrf_bloc.ij(XBold) = XBrespol.ij(XBold).*XBDfac(XBold);
XBDrf_bloc.imj(XBold) = XBrespol.imj(XBold).*XBDfac(XBold);
XBDrf_bloc.immj(XBold) = XBrespol.immj(XBold).*XBDfac(XBold);
XBDrf_bloc.ijp(XBold) = XBrespol.ijp(XBold).*XBDfacp(XBold);
XBDrf_bloc.ijm(XBold) = XBrespol.ijm(XBold).*XBDfacm(XBold);
%
XBDrf_bloc.ippj(~XBold) = XBrespol.ippj(~XBold).*XBDfac(~XBold).*XBgammapp(~XBold)./XBpnpp(~XBold)./abs(XBmhu(~XBold));
XBDrf_bloc.ipj(~XBold) = XBrespol.ipj(~XBold).*XBDfac(~XBold).*XBgammap(~XBold)./XBpnp(~XBold)./abs(XBmhu(~XBold));
XBDrf_bloc.ij(~XBold) = XBrespol.ij(~XBold).*XBDfac(~XBold).*XBgamma(~XBold)./XBpn(~XBold)./abs(XBmhu(~XBold));
XBDrf_bloc.imj(~XBold) = XBrespol.imj(~XBold).*XBDfac(~XBold).*XBgammam(~XBold)./XBpnm(~XBold)./abs(XBmhu(~XBold));
XBDrf_bloc.immj(~XBold) = XBrespol.immj(~XBold).*XBDfac(~XBold).*XBgammamm(~XBold)./XBpnmm(~XBold)./abs(XBmhu(~XBold));
XBDrf_bloc.ijp(~XBold) = XBrespol.ijp(~XBold).*XBDfacp(~XBold).*XBgamma(~XBold)./XBpn(~XBold)./abs(XBmhup(~XBold));
XBDrf_bloc.ijm(~XBold) = XBrespol.ijm(~XBold).*XBDfacm(~XBold).*XBgamma(~XBold)./XBpn(~XBold)./abs(XBmhum(~XBold));
%
clear XBrespol XBDfacp XBDfac XBDfacm 
clear XBgammapp XBgammap XBgamma XBgammam XBgammamm   
clear XBmhup XBmhu XBmhum
%
if dke_mode == 0,
    %
    clear XBpnpp XBpnp XBpn XBpnm XBpnmm XBold
    %
end
%
XBDrf.ippj(bloc_mask) = XBDrf_bloc.ippj;
XBDrf.ipj(bloc_mask) = XBDrf_bloc.ipj;
XBDrf.ij(bloc_mask) = XBDrf_bloc.ij;
XBDrf.imj(bloc_mask) = XBDrf_bloc.imj;
XBDrf.immj(bloc_mask) = XBDrf_bloc.immj;
XBDrf.ijp(bloc_mask) = XBDrf_bloc.ijp;
XBDrf.ijm(bloc_mask) = XBDrf_bloc.ijm;
%
end
%
clear XBDrf_bloc  XXheavisidep XXheaviside XXheavisidem
%
% Sum over all fragments within a flux surface
%
%
if nb > 1,
    mask_r = bir_rf(mask_b).';
    mask_y = biy_rf(mask_b).';
else
    mask_r = bir_rf(mask_b);
    mask_y = biy_rf(mask_b);
    %
end
%
clear mask_b
%
xymask = double((mask_y - 1)*nr + mask_r);
Xnmask = double(((mask_n - 1)*nmhu + mask_m - 1)*npn + mask_p);%mask in pnp-y-rho-n 4-D matrices
%
XYDrf.ippj = sparse(xymask,Xnmask,double(XBDrf.ippj),nr*ny,npn*nmhu*nn_rf);
XYDrf.ipj = sparse(xymask,Xnmask,double(XBDrf.ipj),nr*ny,npn*nmhu*nn_rf);
XYDrf.ij = sparse(xymask,Xnmask,double(XBDrf.ij),nr*ny,npn*nmhu*nn_rf);
XYDrf.imj = sparse(xymask,Xnmask,double(XBDrf.imj),nr*ny,npn*nmhu*nn_rf);
XYDrf.immj = sparse(xymask,Xnmask,double(XBDrf.immj),nr*ny,npn*nmhu*nn_rf);
XYDrf.ijp = sparse(xymask,Xnmask,double(XBDrf.ijp),nr*ny,npn*nmhu*nn_rf);
XYDrf.ijm = sparse(xymask,Xnmask,double(XBDrf.ijm),nr*ny,npn*nmhu*nn_rf);
%
clear Xnmask xymask XBDrf
%
XYmask = find(XYDrf.ippj | XYDrf.ipj | XYDrf.ij | XYDrf.imj...
    | XYDrf.immj | XYDrf.ijp | XYDrf.ijm);
%
if nr*ny == 1,
    XYmask = XYmask.';
end
%
mask_n = ceil(XYmask/(nmhu*npn*ny*nr));
mask_m = ceil((XYmask - (mask_n - 1)*nmhu*npn*ny*nr)/(npn*ny*nr));
mask_p = ceil((XYmask - ((mask_n - 1)*nmhu + mask_m - 1)*npn*ny*nr)/(ny*nr));
mask_y = ceil((XYmask - (((mask_n - 1)*nmhu + mask_m - 1)*npn + mask_p - 1)*ny*nr)/nr);
mask_r = XYmask - ((((mask_n - 1)*nmhu + mask_m - 1)*npn + mask_p - 1)*ny + mask_y - 1)*nr;
%
XYmask = uint32(XYmask);
mask_n = uint32(mask_n);
mask_m = uint32(mask_m);
mask_p = uint32(mask_p);
mask_y = uint32(mask_y);
mask_r = uint32(mask_r);
%
XYDrf.ippj = single(full(XYDrf.ippj(XYmask)));
XYDrf.ipj = single(full(XYDrf.ipj(XYmask)));
XYDrf.ij = single(full(XYDrf.ij(XYmask)));
XYDrf.imj = single(full(XYDrf.imj(XYmask)));
XYDrf.immj = single(full(XYDrf.immj(XYmask)));
XYDrf.ijp = single(full(XYDrf.ijp(XYmask)));
XYDrf.ijm = single(full(XYDrf.ijm(XYmask))); 
%
if nr*ny == 1,
    XYDrf.ippj = XYDrf.ippj.';
    XYDrf.ipj = XYDrf.ipj.';
    XYDrf.ij = XYDrf.ij.';
    XYDrf.imj = XYDrf.imj.';
    XYDrf.immj = XYDrf.immj.';
    XYDrf.ijp = XYDrf.ijp.';
    XYDrf.ijm = XYDrf.ijm.';
end
%
clear XYmask
%
% QL diffusion tensor elements
%
Xmask = (mask_m - 1)*npn + mask_p;
%
XY1mmhu2p = single(X1mmhu2p(Xmask));
XY1mmhu2 = single(X1mmhu2(Xmask));
XY1mmhu2m = single(X1mmhu2m(Xmask));
%
XY1mmhu2p(XY1mmhu2p == 0) = eps('single');
XY1mmhu2(XY1mmhu2 == 0) =  eps('single');
XY1mmhu2m(XY1mmhu2m == 0) =  eps('single');
%
XYgammap = single(Xgammap(Xmask));
XYgamma = single(Xgamma(Xmask));
XYgammam = single(Xgammam(Xmask));
%
XYmhup = single(Xmhup(Xmask));
XYmhu = single(Xmhu(Xmask));
XYmhum = single(Xmhum(Xmask));
%
XYomega_rf = yomega_rf(mask_y);
if ny > 1,
    XYomega_rf = XYomega_rf.';
end    
XYB0 = single(xB0(mask_r));
if nr > 1,
    XYB0 = XYB0.';
end    
XYomegaratio0 = qe*XYB0./XYomega_rf/me; % cyclotron frequency along the ray path
%
XYn = n_rf_list(mask_n);
if nn_rf > 1,
    XYn = XYn.';
end
%
XYyn0 = XYomegaratio0.*XYn;
%
clear XYomega_rf XYB0 XYomegaratio0
%
ZXYD_rf.pp_ippj = XY1mmhu2.*XYDrf.ippj;
ZXYD_rf.pp_ipj = XY1mmhu2.*XYDrf.ipj;                                     
ZXYD_rf.pp_ij = XY1mmhu2.*XYDrf.ij;                                      
ZXYD_rf.parpar_ij = XY1mmhu2.*(1 - XYyn0./XYgamma).^2.*XYDrf.ij./XYmhu./XYmhu; 
ZXYD_rf.pp_imj = XY1mmhu2.*XYDrf.imj;
ZXYD_rf.pp_immj = XY1mmhu2.*XYDrf.immj;
%
ZXYD_rf.pm_ipj = - sqrt(XY1mmhu2).*(XY1mmhu2 - XYyn0./XYgammap).*XYDrf.ipj./XYmhu;
ZXYD_rf.pm_ij = - sqrt(XY1mmhu2).*(XY1mmhu2 - XYyn0./XYgamma).*XYDrf.ij./XYmhu;
ZXYD_rf.pm_imj = - sqrt(XY1mmhu2).*(XY1mmhu2 - XYyn0./XYgammam).*XYDrf.imj./XYmhu;
%
ZXYD_rf.mp_ijp = - sqrt(XY1mmhu2p).*(XY1mmhu2p - XYyn0./XYgamma).*XYDrf.ijp./XYmhup;
ZXYD_rf.mp_ij = - sqrt(XY1mmhu2).*(XY1mmhu2 - XYyn0./XYgamma).*XYDrf.ij./XYmhu;
ZXYD_rf.mp_ijm = - sqrt(XY1mmhu2m).*(XY1mmhu2m - XYyn0./XYgamma).*XYDrf.ijm./XYmhum;
%
ZXYD_rf.mm_ijp = (XY1mmhu2p - XYyn0./XYgamma).^2.*XYDrf.ijp./XYmhup./XYmhup;
ZXYD_rf.mm_ijm = (XY1mmhu2m - XYyn0./XYgamma).^2.*XYDrf.ijm./XYmhum./XYmhum;
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
clear XYgammap XYgamma XYgammam
clear XYmhup XYmhu XYmhum XY1mmhu2p XY1mmhu2 XY1mmhu2m XYyn0 XYold
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
