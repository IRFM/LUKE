function [ZP0,Zcurr,Znorm,ZXXS,XxRR_fsav,xMRR_flux,xMRR_tau,xRR_fsav,xne_norm_out,xTe_norm_out,xft_fsav,xfteff_fsav] = ...
    fmoments_dke_yp(path,dkeparam,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi,waveparam,radial_mode,Zdelta,XXsinksource,...
                    XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
                    ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyD0_rf,gridindex_rf,...
                    ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,XXILor)
%
%   Calculate moments of the electron distribution function.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC)   (joan.decker@cea.fr)
%
% Calculation of the various moments of the distribution function (density, current, power, bremsstrahlung)
%
time0 = clock;
dke_mode = dkeparam.dke_mode;
%
Xpnm = gridDKE.Xpnm;
Xpnp = gridDKE.Xpnp;
X1mmhu2 = gridDKE.X1mmhu2;
Xdpnm = gridDKE.Xdpnm;
Xdpn = gridDKE.Xdpn;
Xdmhu = gridDKE.Xdmhu;
%
XXdpnm = gridDKE.XXdpnm;
XXdpnp = gridDKE.XXdpnp;
XXdmhum = gridDKE.XXdmhum;
XXdmhup = gridDKE.XXdmhup;
%
Xgammam = Zmomcoef.Xgammam;
Xgammap = Zmomcoef.Xgammap;
%
XXlambda = Zbouncecoef.XXlambda;
xqtilde = Zbouncecoef.xqtilde;
xqhat =  Zbouncecoef.xqhat;
%
if nargout > 1,
    %
	xx0 = equilDKE.xx0;
	xBT0 = equilDKE.xBT0;
	xB0 = equilDKE.xB0;
	%
    dpnm = gridDKE.dpnm;
    dpn = gridDKE.dpn;
    dpnp = gridDKE.dpnp;
    dmhu = gridDKE.dmhu;
	dmhum = gridDKE.dmhum;
    %
    X1mmhu2m = gridDKE.X1mmhu2m;
    X1mmhu2p = gridDKE.X1mmhu2p;
    Xpn = gridDKE.Xpn;
    Xmhu = gridDKE.Xmhu;
    %
    XXpnm = gridDKE.XXpnm;
    XXpnp = gridDKE.XXpnp;
    XXpn = gridDKE.XXpn;
    XX1mmhu2 = gridDKE.XX1mmhu2;
    XX1mmhu2m = gridDKE.XX1mmhu2m;
    XX1mmhu2p = gridDKE.XX1mmhu2p;
    %
    XXgammam = Zmomcoef.XXgammam;
    XXgammap = Zmomcoef.XXgammap;
	v2 = Zmomcoef.v2;
    %
    XXRlambda_m = Zbouncecoef.XXRlambda_m;
    %
end    
%
XXdeltap_imj = Zdelta.XXdeltap_imj; 
XXdeltap_ipj = Zdelta.XXdeltap_ipj;
%
XXdeltam_ijm = Zdelta.XXdeltam_ijm; 
XXdeltam_ijp = Zdelta.XXdeltam_ijp;
%
npn = gridindex_rf.npn;
nmhu = gridindex_rf.nmhu;
nr = gridindex_rf.nr;
nr_dke = gridindex_rf.nr_dke;
nb = gridindex_rf.nb;
nn_rf = gridindex_rf.nn_rf;
rdke = gridDKE.rdke;
%
% Derivatives of the distibution function
%
indexi = cumsum(ones(npn,1));
indexj = cumsum(ones(nmhu,1));
%
indexim = indexi;
indexip = indexi;
%
indexjm = indexj;
indexjp = indexj;
%
indexim(2:npn) = indexi(1:npn-1);
%indexim(1) = indexi(1); since df/dp(p==0) = 0;
%
indexip(1:npn-1) = indexi(2:npn);
%indexip(npn) = indexi(npn); f(p>pmax) = 0 enforced later;
%
indexjm(2:nmhu) = indexj(1:nmhu-1);
%indexjm(1) = indexj(1); since df/dm(m==-1) = 0;
%
indexjp(1:nmhu-1) = indexj(2:nmhu);
%indexjp(nmhu) = indexj(nmhu); since df/dm(m==1) = 0;
%
XXf0_ij = XXf0;
%
XXf0_immj = XXf0_ij(indexim,:,:);
XXf0_ippj = XXf0_ij(indexip,:,:);XXf0_ippj(npn,:,:) = 0;
%
XXf0_imj = (1 - XXdeltap_imj).*XXf0_ij + XXdeltap_imj.*XXf0_immj;
XXf0_ipj = (1 - XXdeltap_ipj).*XXf0_ippj + XXdeltap_ipj.*XXf0_ij;
%
XXf0_imjmm = XXf0_imj(:,indexjm,:);
XXf0_imjpp = XXf0_imj(:,indexjp,:);
%
XXf0_ipjmm = XXf0_ipj(:,indexjm,:);
XXf0_ipjpp = XXf0_ipj(:,indexjp,:);
%
XXdf0dpn_imj = (XXf0_ij - XXf0_immj)./XXdpnm;
XXdf0dpn_ipj = (XXf0_ippj - XXf0_ij)./XXdpnp;
%
XXdf0dmhu_imj = (XXf0_imjpp - XXf0_imjmm)./(XXdmhum + XXdmhup);
XXdf0dmhu_ipj = (XXf0_ipjpp - XXf0_ipjmm)./(XXdmhum + XXdmhup);
%
if dke_mode == 1,
    %
    XXf0_tp_ij = XXf0_tp;
    %
    XXf0_tp_immj = XXf0_tp_ij(indexim,:,:);
    XXf0_tp_ippj = XXf0_tp_ij(indexip,:,:);XXf0_tp_ippj(npn,:,:) = 0;
    %
    XXf0_tp_imj = (1 - XXdeltap_imj).*XXf0_tp_ij + XXdeltap_imj.*XXf0_tp_immj;
    XXf0_tp_ipj = (1 - XXdeltap_ipj).*XXf0_tp_ippj + XXdeltap_ipj.*XXf0_tp_ij;
    %
    XXf0_tp_imjmm = XXf0_tp_imj(:,indexjm,:);
    XXf0_tp_imjpp = XXf0_tp_imj(:,indexjp,:);
    %
    XXf0_tp_ipjmm = XXf0_tp_ipj(:,indexjm,:);
    XXf0_tp_ipjpp = XXf0_tp_ipj(:,indexjp,:);
    %
    XXdf0dpn_tp_imj = (XXf0_tp_ij - XXf0_tp_immj)./XXdpnm;
    XXdf0dpn_tp_ipj = (XXf0_tp_ippj - XXf0_tp_ij)./XXdpnp;
    %
    XXdf0dmhu_tp_imj = (XXf0_tp_imjpp - XXf0_tp_imjmm)./(XXdmhum + XXdmhup);
    XXdf0dmhu_tp_ipj = (XXf0_tp_ipjpp - XXf0_tp_ipjmm)./(XXdmhum + XXdmhup);
    %
    %
    XXf0_g_ij = XXf0_g;
    %
    XXf0_g_immj = XXf0_g_ij(indexim,:,:);
    XXf0_g_ippj = XXf0_g_ij(indexip,:,:);XXf0_g_ippj(npn,:,:) = 0;
    %
    XXf0_g_imj = (1 - XXdeltap_imj).*XXf0_g_ij + XXdeltap_imj.*XXf0_g_immj;
    XXf0_g_ipj = (1 - XXdeltap_ipj).*XXf0_g_ippj + XXdeltap_ipj.*XXf0_g_ij;
    %
    XXf0_g_imjmm = XXf0_g_imj(:,indexjm,:);
    XXf0_g_imjpp = XXf0_g_imj(:,indexjp,:);
    %
    XXf0_g_ipjmm = XXf0_g_ipj(:,indexjm,:);
    XXf0_g_ipjpp = XXf0_g_ipj(:,indexjp,:);
    %
    XXdf0dpn_g_imj = (XXf0_g_ij - XXf0_g_immj)./XXdpnm;
    XXdf0dpn_g_ipj = (XXf0_g_ippj - XXf0_g_ij)./XXdpnp;
    %
    XXdf0dmhu_g_imj = (XXf0_g_imjpp - XXf0_g_imjmm)./(XXdmhum + XXdmhup);
    XXdf0dmhu_g_ipj = (XXf0_g_ipjpp - XXf0_g_ipjmm)./(XXdmhum + XXdmhup);
    %
end
%    
if nargout > 1,
    %
    XXf0_ijmm = XXf0_ij(:,indexjm,:);
    XXf0_ijpp = XXf0_ij(:,indexjp,:);
    %
    XXf0_ijm = (1 - XXdeltam_ijm).*XXf0_ij + XXdeltam_ijm.*XXf0_ijmm;
    XXf0_ijp = (1 - XXdeltam_ijp).*XXf0_ippj + XXdeltam_ijp.*XXf0_ij;
    %
    XXf0_immjm = XXf0_ijm(indexim,:,:);
    XXf0_ippjm = XXf0_ijm(indexip,:,:);XXf0_ippjm(npn,:,:) = 0;
    %
    XXf0_immjp = XXf0_ijp(indexim,:,:);
    XXf0_ippjp = XXf0_ijp(indexip,:,:);XXf0_ippjp(npn,:,:) = 0;
    %
    XXdf0dmhu_ijm = (XXf0_ij - XXf0_ijmm)./XXdmhum;
    XXdf0dmhu_ijp = (XXf0_ijpp - XXf0_ij)./XXdmhup;
    %
    XXdf0dpn_ijm = (XXf0_ippjm - XXf0_immjm)./(XXdpnm + XXdpnp);
    XXdf0dpn_ijp = (XXf0_ippjp - XXf0_immjp)./(XXdpnm + XXdpnp);
    %
    if dke_mode == 1,
        %
        XXf0_tp_ijmm = XXf0_tp_ij(:,indexjm,:);
        XXf0_tp_ijpp = XXf0_tp_ij(:,indexjp,:);
        %
        XXf0_tp_ijm = (1 - XXdeltam_ijm).*XXf0_tp_ij + XXdeltam_ijm.*XXf0_tp_ijmm;
        XXf0_tp_ijp = (1 - XXdeltam_ijp).*XXf0_tp_ippj + XXdeltam_ijp.*XXf0_tp_ij;
        %
        XXf0_tp_immjm = XXf0_tp_ijm(indexim,:,:);
        XXf0_tp_ippjm = XXf0_tp_ijm(indexip,:,:);XXf0_tp_ippjm(npn,:,:) = 0;
        %
        XXf0_tp_immjp = XXf0_tp_ijp(indexim,:,:);
        XXf0_tp_ippjp = XXf0_tp_ijp(indexip,:,:);XXf0_tp_ippjp(npn,:,:) = 0;
        %
        XXdf0dmhu_tp_ijm = (XXf0_tp_ij - XXf0_tp_ijmm)./XXdmhum;
        XXdf0dmhu_tp_ijp = (XXf0_tp_ijpp - XXf0_tp_ij)./XXdmhup;
        %
        XXdf0dpn_tp_ijm = (XXf0_tp_ippjm - XXf0_tp_immjm)./(XXdpnm + XXdpnp);
        XXdf0dpn_tp_ijp = (XXf0_tp_ippjp - XXf0_tp_immjp)./(XXdpnm + XXdpnp);
        %
        %
        XXf0_g_ijmm = XXf0_g_ij(:,indexjm,:);
        XXf0_g_ijpp = XXf0_g_ij(:,indexjp,:);
        %
        XXf0_g_ijm = (1 - XXdeltam_ijm).*XXf0_g_ij + XXdeltam_ijm.*XXf0_g_ijmm;
        XXf0_g_ijp = (1 - XXdeltam_ijp).*XXf0_g_ippj + XXdeltam_ijp.*XXf0_g_ij;
        %
        XXf0_g_immjm = XXf0_g_ijm(indexim,:,:);
        XXf0_g_ippjm = XXf0_g_ijm(indexip,:,:);XXf0_g_ippjm(npn,:,:) = 0;
        %
        XXf0_g_immjp = XXf0_g_ijp(indexim,:,:);
        XXf0_g_ippjp = XXf0_g_ijp(indexip,:,:);XXf0_g_ippjp(npn,:,:) = 0;
        %
        XXdf0dmhu_g_ijm = (XXf0_g_ij - XXf0_g_ijmm)./XXdmhum;
        XXdf0dmhu_g_ijp = (XXf0_g_ijpp - XXf0_g_ij)./XXdmhup;
        %
        XXdf0dpn_g_ijm = (XXf0_g_ippjm - XXf0_g_immjm)./(XXdpnm + XXdpnp);
        XXdf0dpn_g_ijp = (XXf0_g_ippjp - XXf0_g_immjp)./(XXdpnm + XXdpnp);
        %
    end
end
%
% -------------------------------------------------------------------------
% 
%                       RF Power and fluxes calculation
%
% -------------------------------------------------------------------------
% 
% Vector construction for RF fluxes
%
iX = (gridindex_rf.mask_m - 1)*npn + gridindex_rf.mask_p;
iXX = (gridindex_rf.mask_r - 1)*nmhu*npn + iX;
ixy = (gridindex_rf.mask_y - 1)*nr + gridindex_rf.mask_r;
ixyn = (gridindex_rf.mask_n - 1)*nb*nr + ixy;
iyn = (gridindex_rf.mask_n - 1)*nb + gridindex_rf.mask_y;
%
gridindex_rf = rmfield(gridindex_rf,['mask_r';'mask_m';'mask_p';'mask_n';'mask_y']);
%
XYD0_rf = xyD0_rf(ixy);
%
ZXYD_rf.pp_ipj = ZXYD_rf.pp_ipj.*XYD0_rf;
ZXYD_rf.pp_imj = ZXYD_rf.pp_imj.*XYD0_rf;
ZXYD_rf.pm_ipj = ZXYD_rf.pm_ipj.*XYD0_rf;
ZXYD_rf.pm_imj = ZXYD_rf.pm_imj.*XYD0_rf;
%
XYFp_rf_imj = 0;
XYFp_rf_ipj = 0;
%
XYf0_imj = single(XXf0_imj(iXX));
XYf0_ipj = single(XXf0_ipj(iXX));
%
XYdf0dpn_imj = single(XXdf0dpn_imj(iXX));
XYdf0dpn_ipj = single(XXdf0dpn_ipj(iXX));
%
XYdf0dmhu_imj = single(XXdf0dmhu_imj(iXX));
XYdf0dmhu_ipj = single(XXdf0dmhu_ipj(iXX));
%
XY1mmhu2 = single(X1mmhu2(iX));
XYpnm = single(Xpnm(iX));
XYpnp = single(Xpnp(iX));
%
if dke_mode == 1,
    %
    ZXYD_rf_tp.pp_ipj = ZXYD_rf_tp.pp_ipj.*XYD0_rf;
    ZXYD_rf_tp.pp_imj = ZXYD_rf_tp.pp_imj.*XYD0_rf;
    ZXYD_rf_tp.pm_ipj = ZXYD_rf_tp.pm_ipj.*XYD0_rf;
    ZXYD_rf_tp.pm_imj = ZXYD_rf_tp.pm_imj.*XYD0_rf;
    %
    ZXYF_rf_tp.p_ipj = ZXYF_rf_tp.p_ipj.*XYD0_rf;
    ZXYF_rf_tp.p_imj = ZXYF_rf_tp.p_imj.*XYD0_rf;
    %
    XYf0_tp_imj = single(XXf0_tp_imj(iXX));
    XYf0_tp_ipj = single(XXf0_tp_ipj(iXX));
    %
    XYdf0dpn_tp_imj = single(XXdf0dpn_tp_imj(iXX));
    XYdf0dpn_tp_ipj = single(XXdf0dpn_tp_ipj(iXX));
    %
    XYdf0dmhu_tp_imj = single(XXdf0dmhu_tp_imj(iXX));
    XYdf0dmhu_tp_ipj = single(XXdf0dmhu_tp_ipj(iXX));
    %
    XYf0_g_imj = single(XXf0_g_imj(iXX));
    XYf0_g_ipj = single(XXf0_g_ipj(iXX));
    %
    XYdf0dpn_g_imj = single(XXdf0dpn_g_imj(iXX));
    XYdf0dpn_g_ipj = single(XXdf0dpn_g_ipj(iXX));
    %
    XYdf0dmhu_g_imj = single(XXdf0dmhu_g_imj(iXX));
    XYdf0dmhu_g_ipj = single(XXdf0dmhu_g_ipj(iXX));
    %
end
%
if nargout == 1,
    %
    %f0 contribution
    %
    [XYSp0_rf_imj,XYSp0_rf_ipj] = ...
        fluxes_dke_jd(XYdf0dpn_imj,XYdf0dpn_ipj,XYdf0dmhu_imj,XYdf0dmhu_ipj,XYf0_imj,XYf0_ipj,...
                      ZXYD_rf.pp_imj,ZXYD_rf.pp_ipj,ZXYD_rf.pm_imj,ZXYD_rf.pm_ipj,XYFp_rf_imj,XYFp_rf_ipj,XY1mmhu2,XYpnm,XYpnp);
    %
    if dke_mode == 1,
        %
        [XYSp0_rf_tp_imj,XYSp0_rf_tp_ipj] = ...
            fluxes_dke_jd(XYdf0dpn_tp_imj,XYdf0dpn_tp_ipj,XYdf0dmhu_tp_imj,XYdf0dmhu_tp_ipj,XYf0_tp_imj,XYf0_tp_ipj,...
                      ZXYD_rf_tp.pp_imj,ZXYD_rf_tp.pp_ipj,ZXYD_rf_tp.pm_imj,ZXYD_rf_tp.pm_ipj,ZXYF_rf_tp.p_imj,ZXYF_rf_tp.p_ipj,XY1mmhu2,XYpnm,XYpnp);
        %
        [XYSp0_rf_g_imj,XYSp0_rf_g_ipj] = ...
            fluxes_dke_jd(XYdf0dpn_g_imj,XYdf0dpn_g_ipj,XYdf0dmhu_g_imj,XYdf0dmhu_g_ipj,XYf0_g_imj,XYf0_g_ipj,...
                      ZXYD_rf.pp_imj,ZXYD_rf.pp_ipj,ZXYD_rf.pm_imj,ZXYD_rf.pm_ipj,XYFp_rf_imj,XYFp_rf_ipj,XY1mmhu2,XYpnm,XYpnp);
        %
    end
else
    %
    ZXYD_rf.mm_ijm = ZXYD_rf.mm_ijm.*XYD0_rf;
    ZXYD_rf.mm_ijp = ZXYD_rf.mm_ijp.*XYD0_rf;
    ZXYD_rf.mp_ijm = ZXYD_rf.mp_ijm.*XYD0_rf;
    ZXYD_rf.mp_ijp = ZXYD_rf.mp_ijp.*XYD0_rf;
    %
    XYFm_rf_ijm = 0;
    XYFm_rf_ijp = 0;
    %
    XYf0_ijm = single(XXf0_ijm(iXX));
    XYf0_ijp = single(XXf0_ijp(iXX));
    %
    XYdf0dmhu_ijm = single(XXdf0dmhu_ijm(iXX));
    XYdf0dmhu_ijp = single(XXdf0dmhu_ijp(iXX));
    %
    XYdf0dpn_ijm = single(XXdf0dpn_ijm(iXX));
    XYdf0dpn_ijp = single(XXdf0dpn_ijp(iXX));
    %
    XY1mmhu2p = single(X1mmhu2p(iX));
    XY1mmhu2m = single(X1mmhu2m(iX));
    XYpn = single(Xpn(iX));
    %
    %f0 contribution
    %
    [XYSp0_rf_imj,XYSp0_rf_ipj,XYSm0_rf_ijm,XYSm0_rf_ijp] = ...
        fluxes_dke_jd(XYdf0dpn_imj,XYdf0dpn_ipj,XYdf0dmhu_imj,XYdf0dmhu_ipj,XYf0_imj,XYf0_ipj,...
                      ZXYD_rf.pp_imj,ZXYD_rf.pp_ipj,ZXYD_rf.pm_imj,ZXYD_rf.pm_ipj,XYFp_rf_imj,XYFp_rf_ipj,XY1mmhu2,XYpnm,XYpnp,...
                      XYdf0dmhu_ijm,XYdf0dmhu_ijp,XYdf0dpn_ijm,XYdf0dpn_ijp,XYf0_ijm,XYf0_ijp,...
                      ZXYD_rf.mm_ijm,ZXYD_rf.mm_ijp,ZXYD_rf.mp_ijm,ZXYD_rf.mp_ijp,XYFm_rf_ijm,XYFm_rf_ijp,XY1mmhu2m,XY1mmhu2p,XYpn);
    %
    if dke_mode == 1,
        %
        %f1 contribution
        %
        ZXYD_rf_tp.mm_ijm = ZXYD_rf_tp.mm_ijm.*XYD0_rf;
        ZXYD_rf_tp.mm_ijp = ZXYD_rf_tp.mm_ijp.*XYD0_rf;
        ZXYD_rf_tp.mp_ijm = ZXYD_rf_tp.mp_ijm.*XYD0_rf;
        ZXYD_rf_tp.mp_ijp = ZXYD_rf_tp.mp_ijp.*XYD0_rf;
        %
        ZXYF_rf_tp.m_ijm = ZXYF_rf_tp.m_ijm.*XYD0_rf;
        ZXYF_rf_tp.m_ijp = ZXYF_rf_tp.m_ijp.*XYD0_rf;
        %
        XYf0_tp_ijm = single(XXf0_tp_ijm(iXX));
        XYf0_tp_ijp = single(XXf0_tp_ijp(iXX));
        %
        XYdf0dmhu_tp_ijm = single(XXdf0dmhu_tp_ijm(iXX));
        XYdf0dmhu_tp_ijp = single(XXdf0dmhu_tp_ijp(iXX));
        %
        XYdf0dpn_tp_ijm = single(XXdf0dpn_tp_ijm(iXX));
        XYdf0dpn_tp_ijp = single(XXdf0dpn_tp_ijp(iXX));
        %
        XYf0_g_ijm = single(XXf0_g_ijm(iXX));
        XYf0_g_ijp = single(XXf0_g_ijp(iXX));
        %
        XYdf0dmhu_g_ijm = single(XXdf0dmhu_g_ijm(iXX));
        XYdf0dmhu_g_ijp = single(XXdf0dmhu_g_ijp(iXX));
        %
        XYdf0dpn_g_ijm = single(XXdf0dpn_g_ijm(iXX));
        XYdf0dpn_g_ijp = single(XXdf0dpn_g_ijp(iXX));
        %
        [XYSp0_rf_tp_imj,XYSp0_rf_tp_ipj,XYSm0_rf_tp_ijm,XYSm0_rf_tp_ijp] = ...
            fluxes_dke_jd(XYdf0dpn_tp_imj,XYdf0dpn_tp_ipj,XYdf0dmhu_tp_imj,XYdf0dmhu_tp_ipj,XYf0_tp_imj,XYf0_tp_ipj,...
                      ZXYD_rf_tp.pp_imj,ZXYD_rf_tp.pp_ipj,ZXYD_rf_tp.pm_imj,ZXYD_rf_tp.pm_ipj,ZXYF_rf_tp.p_imj,ZXYF_rf_tp.p_ipj,XY1mmhu2,XYpnm,XYpnp,...
                      XYdf0dmhu_tp_ijm,XYdf0dmhu_tp_ijp,XYdf0dpn_tp_ijm,XYdf0dpn_tp_ijp,XYf0_tp_ijm,XYf0_tp_ijp,...
                      ZXYD_rf_tp.mm_ijm,ZXYD_rf_tp.mm_ijp,ZXYD_rf_tp.mp_ijm,ZXYD_rf_tp.mp_ijp,ZXYF_rf_tp.m_ijm,ZXYF_rf_tp.m_ijp,XY1mmhu2m,XY1mmhu2p,XYpn);
        %
        [XYSp0_rf_g_imj,XYSp0_rf_g_ipj,XYSm0_rf_g_ijm,XYSm0_rf_g_ijp] = ...
            fluxes_dke_jd(XYdf0dpn_g_imj,XYdf0dpn_g_ipj,XYdf0dmhu_g_imj,XYdf0dmhu_g_ipj,XYf0_g_imj,XYf0_g_ipj,...
                      ZXYD_rf.pp_imj,ZXYD_rf.pp_ipj,ZXYD_rf.pm_imj,ZXYD_rf.pm_ipj,XYFp_rf_imj,XYFp_rf_ipj,XY1mmhu2,XYpnm,XYpnp,...
                      XYdf0dmhu_g_ijm,XYdf0dmhu_g_ijp,XYdf0dpn_g_ijm,XYdf0dpn_g_ijp,XYf0_g_ijm,XYf0_g_ijp,...
                      ZXYD_rf.mm_ijm,ZXYD_rf.mm_ijp,ZXYD_rf.mp_ijm,ZXYD_rf.mp_ijp,XYFm_rf_ijm,XYFm_rf_ijp,XY1mmhu2m,XY1mmhu2p,XYpn);
        %
        %  Wave-induced radial transport by adjoint technique (P. Helander model)
        %
        ZXYD_rf_tp.mm1_ijm = ZXYD_rf_tp.mm1_ijm.*XYD0_rf;
        ZXYD_rf_tp.mm1_ijp = ZXYD_rf_tp.mm1_ijp.*XYD0_rf;
        ZXYD_rf_tp.mp1_ijm = ZXYD_rf_tp.mp1_ijm.*XYD0_rf;
        ZXYD_rf_tp.mp1_ijp = ZXYD_rf_tp.mp1_ijp.*XYD0_rf;
        %
        %
        [XYSp0_rf_tp1_imj,XYSp0_rf_tp1_ipj,XYSm0_rf_tp1_ijm,XYSm0_rf_tp1_ijp] = ...
            fluxes_dke_jd(XYdf0dpn_imj,XYdf0dpn_ipj,XYdf0dmhu_imj,XYdf0dmhu_ipj,XYf0_imj,XYf0_ipj,...
                      ZXYD_rf_tp.pp_imj,ZXYD_rf_tp.pp_ipj,ZXYD_rf_tp.pm_imj,ZXYD_rf_tp.pm_ipj,XYFp_rf_imj,XYFp_rf_ipj,XY1mmhu2,XYpnm,XYpnp,...
                      XYdf0dmhu_ijm,XYdf0dmhu_ijp,XYdf0dpn_ijm,XYdf0dpn_ijp,XYf0_ijm,XYf0_ijp,...
                      ZXYD_rf_tp.mm1_ijm,ZXYD_rf_tp.mm1_ijp,ZXYD_rf_tp.mp1_ijm,ZXYD_rf_tp.mp1_ijp,XYFm_rf_ijm,XYFm_rf_ijp,XY1mmhu2m,XY1mmhu2p,XYpn);
    
        %
    end
    %
end
%
clear XYD0_rf ZXYD_rf ZXYD_rf_tp ZXYF_rf_tp 
%
clear XYf0_imj XYf0_ipj XYdf0dpn_imj XYdf0dpn_ipj XYdf0dmhu_imj XYdf0dmhu_ipj
clear XYf0_tp_imj XYf0_tp_ipj XYdf0dpn_tp_imj XYdf0dpn_tp_ipj XYdf0dmhu_tp_imj XYdf0dmhu_tp_ipj
clear XYf0_g_imj XYf0_g_ipj XYdf0dpn_g_imj XYdf0dpn_g_ipj XYdf0dmhu_g_imj XYdf0dmhu_g_ipj
%
clear XYf0_ijm XYf0_ijp XYdf0dmhu_ijm XYdf0dmhu_ijp XYdf0dpn_ijm XYdf0dpn_ijp
clear XYf0_tp_ijm XYf0_tp_ijp XYdf0dmhu_tp_ijm XYdf0dmhu_tp_ijp XYdf0dpn_tp_ijm XYdf0dpn_tp_ijp
clear XYf0_g_ijm XYf0_g_ijp XYdf0dmhu_g_ijm XYdf0dmhu_g_ijp XYdf0dpn_g_ijm XYdf0dpn_g_ijp
%
clear XY1mmhu2 XY1mmhu2p 
%
XYdmhu    = single(Xdmhu(iX));     
XYgammam  = single(Xgammam(iX));
XYgammap  = single(Xgammap(iX));
XYdpnm    = single(Xdpnm(iX));     
XYdpn     = single(Xdpn(iX));     
XYlambda  = single(XXlambda(iXX)); 
%
xqratio = xqtilde./xqhat;
xynqratio = repmat(xqratio.',[1,nb,nn_rf]);
%
XYIntegrandm = XYpnm.*XYpnm.*XYpnm.*XYlambda.*XYSp0_rf_imj./XYgammam;
XYIntegrandp = XYpnp.*XYpnp.*XYpnp.*XYlambda.*XYSp0_rf_ipj./XYgammap;
%
XYIntegrand = XYdmhu.*XYdpn.*(XYIntegrandm + XYIntegrandp)/2;
%
XYIntegrand = sparse(double(iX),double(ixyn),double(XYIntegrand),npn*nmhu,nr*nb*nn_rf);
%
ZP0.xyn_rf_fsav = 2*pi*xynqratio.*reshape(full(sum(XYIntegrand)),[nr,nb,nn_rf]);
%
ZP0.xy_rf_fsav = sum(ZP0.xyn_rf_fsav,3);%sum over harmonic numbers
ZP0.x_rf_fsav = sum(ZP0.xy_rf_fsav,2);%sum over rays
%
if dke_mode == 1,
    %
    XYIntegrandm = XYpnm.*XYpnm.*XYpnm.*XYlambda.*XYSp0_rf_tp_imj./XYgammam;
    XYIntegrandp = XYpnp.*XYpnp.*XYpnp.*XYlambda.*XYSp0_rf_tp_ipj./XYgammap;
    %
    XYIntegrand = XYdmhu.*XYdpn.*(XYIntegrandm + XYIntegrandp)/2;
    %
    XYIntegrand = sparse(double(iX),double(ixyn),double(XYIntegrand),npn*nmhu,nr*nb*nn_rf);
    %
    ZP0.xyn_rf_tp_fsav = 2*pi*xynqratio.*reshape(full(sum(XYIntegrand)),[nr,nb,nn_rf]);
    %
    XYIntegrandm = XYpnm.*XYpnm.*XYpnm.*XYlambda.*XYSp0_rf_g_imj./XYgammam;
    XYIntegrandp = XYpnp.*XYpnp.*XYpnp.*XYlambda.*XYSp0_rf_g_ipj./XYgammap;
    %
    XYIntegrand = XYdmhu.*XYdpn.*(XYIntegrandm + XYIntegrandp)/2;
    %
    XYIntegrand = sparse(double(iX),double(ixyn),double(XYIntegrand),npn*nmhu,nr*nb*nn_rf);
    %
    ZP0.xyn_rf_g_fsav = 2*pi*xynqratio.*reshape(full(sum(XYIntegrand)),[nr,nb,nn_rf]);
    %
    ZP0.xy_rf_tp_fsav = sum(ZP0.xyn_rf_tp_fsav,3);%sum over harmonic numbers
    ZP0.xy_rf_g_fsav = sum(ZP0.xyn_rf_g_fsav,3);%sum over harmonic numbers
    %
    ZP0.x_rf_tp_fsav = sum(ZP0.xy_rf_tp_fsav,2);%sum over rays
    ZP0.x_rf_g_fsav = sum(ZP0.xy_rf_g_fsav,2);%sum over rays
    %
    if dke_mode == 1 & nargout > 1,
        %
        %  Wave-induced radial transport by adjoint technique (P. Helander model)
        %
        XYmhu = single(Xmhu(iX));     
        XYRlambda_m = single(Xdpn(iXX));
        %
        XYIntegrand = XYdmhu.*XYdpnm.*XYpnm.*XYpnm.*XYmhu.*XYlambda.*XYSp0_rf_tp1_imj;
        XYIntegrand = sparse(double(iX),double(ixyn),double(XYIntegrand),npn*nmhu,nr*nb*nn_rf);
        xggradpsi21 = 2*pi*xqratio.*(xR0.*xBT0./xB0).*sum(sum(reshape(full(sum(XYIntegrand)),[nr,nb,nn_rf]),3),2).';
        %
        XYIntegrand = XYdmhu.*XYdpn.*XYpn.*XYpn.*XY1mmhu2m.*XYlambda.*XYRlambda_m.*XYSm0_rf_tp1_ijm;
        XYIntegrand = sparse(double(iX),double(ixyn),double(XYIntegrand),npn*nmhu,nr*nb*nn_rf);
        xggradpsi1 = 2*pi*xynqratio.*reshape(full(sum(XYIntegrand)),[nr,nb,nn_rf]);
    end
    %    
end
%
clear iX ixy ixyn
clear XYIntegrandm XYIntegrand XYIntegrandp
clear XYdmhu XYgamma XYgammap XYdpnm XYpnm XYpnp XYlambda XYpn XY1mmhu2m XYmhu XYdpn XYRlambda_m
%
if nargout == 1,
    %
    return
    %
end
%
% Sum over rays and harmonics for RF fluxes
%
ZXXS.p0_rf_imj = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSp0_rf_imj),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXS.p0_rf_ipj = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSp0_rf_ipj),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXS.m0_rf_ijm = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSm0_rf_ijm),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXS.m0_rf_ijp = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSm0_rf_ijp),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
%
if dke_mode == 1,
    %
    ZXXS.p0_rf_tp_imj = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSp0_rf_tp_imj),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
    ZXXS.p0_rf_tp_ipj = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSp0_rf_tp_ipj),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
    ZXXS.m0_rf_tp_ijm = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSm0_rf_tp_ijm),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
    ZXXS.m0_rf_tp_ijp = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSm0_rf_tp_ijp),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
    %
    ZXXS.p0_rf_g_imj = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSp0_rf_g_imj),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
    ZXXS.p0_rf_g_ipj = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSp0_rf_g_ipj),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
    ZXXS.m0_rf_g_ijm = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSm0_rf_g_ijm),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
    ZXXS.m0_rf_g_ijp = reshape(full(sum(sparse(double(iyn),double(iXX),double(XYSm0_rf_g_ijp),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
    %
end
%
clear iXX iyn
clear XYSp0_rf_imj XYSp0_rf_ipj XYSm0_rf_ijm XYSm0_rf_ijp
clear XYSp0_rf_tp_imj XYSp0_rf_tp_ipj XYSm0_rf_tp_ijm XYSm0_rf_tp_ijp
clear XYSp0_rf_tp1_imj XYSp0_rf_tp1_ipj XYSm0_rf_tp1_ijm XYSm0_rf_tp1_ijp
clear XYSp0_rf_g_imj XYSp0_rf_g_ipj XYSm0_rf_g_ijm XYSm0_rf_g_ijp
%
% -------------------------------------------------------------------------
% 
%                       Other Power and Fluxes Calculations
%
% -------------------------------------------------------------------------
%
%   Collisional fluxes and power
%
XXIntegrand_im = XXpnm(:,:,rdke).*XXpnm(:,:,rdke).*XXpnm(:,:,rdke).*XXlambda(:,:,rdke)./XXgammam(:,:,rdke);
XXIntegrand_ip = XXpnp(:,:,rdke).*XXpnp(:,:,rdke).*XXpnp(:,:,rdke).*XXlambda(:,:,rdke)./XXgammap(:,:,rdke);
%
% f0 contribution
%
[ZXXS.p0_c_imj,ZXXS.p0_c_ipj,ZXXS.m0_c_ijm,ZXXS.m0_c_ijp] = ...
    fluxes_dke_jd(XXdf0dpn_imj(:,:,rdke),XXdf0dpn_ipj(:,:,rdke),XXdf0dmhu_imj(:,:,rdke),XXdf0dmhu_ipj(:,:,rdke),XXf0_imj(:,:,rdke),XXf0_ipj(:,:,rdke),...
                  ZXXD_c.pp_imj(:,:,rdke),ZXXD_c.pp_ipj(:,:,rdke),ZXXD_c.pm_imj(:,:,rdke),ZXXD_c.pm_ipj(:,:,rdke),ZXXF_c.p_imj(:,:,rdke),ZXXF_c.p_ipj(:,:,rdke),XX1mmhu2(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),...
                  XXdf0dmhu_ijm(:,:,rdke),XXdf0dmhu_ijp(:,:,rdke),XXdf0dpn_ijm(:,:,rdke),XXdf0dpn_ijp(:,:,rdke),XXf0_ijm(:,:,rdke),XXf0_ijp(:,:,rdke),...
                  ZXXD_c.mm_ijm(:,:,rdke),ZXXD_c.mm_ijp(:,:,rdke),ZXXD_c.mp_ijm(:,:,rdke),ZXXD_c.mp_ijp(:,:,rdke),ZXXF_c.m_ijm(:,:,rdke),ZXXF_c.m_ijp(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),XXpn(:,:,rdke));
%
ZP0.x_c_fsav = 2*pi*xqratio(rdke).*integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXIntegrand_im.*ZXXS.p0_c_imj + XXIntegrand_ip.*ZXXS.p0_c_ipj)/2,1),1).';
%
if dke_mode >= 1
    %
    %f0_tp contribution
    %
    [ZXXS.p0_c_tp_imj,ZXXS.p0_c_tp_ipj,ZXXS.m0_c_tp_ijm,ZXXS.m0_c_tp_ijp] = ...
        fluxes_dke_jd(XXdf0dpn_tp_imj(:,:,rdke),XXdf0dpn_tp_ipj(:,:,rdke),XXdf0dmhu_tp_imj(:,:,rdke),XXdf0dmhu_tp_ipj(:,:,rdke),XXf0_tp_imj(:,:,rdke),XXf0_tp_ipj(:,:,rdke),...
                      ZXXD_c_tp.pp_imj(:,:,rdke),ZXXD_c_tp.pp_ipj(:,:,rdke),ZXXD_c_tp.pm_imj(:,:,rdke),ZXXD_c_tp.pm_ipj(:,:,rdke),ZXXF_c_tp.p_imj(:,:,rdke),ZXXF_c_tp.p_ipj(:,:,rdke),XX1mmhu2(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),...
                      XXdf0dmhu_tp_ijm(:,:,rdke),XXdf0dmhu_tp_ijp(:,:,rdke),XXdf0dpn_tp_ijm(:,:,rdke),XXdf0dpn_tp_ijp(:,:,rdke),XXf0_tp_ijm(:,:,rdke),XXf0_tp_ijp(:,:,rdke),...
                      ZXXD_c_tp.mm_ijm(:,:,rdke),ZXXD_c_tp.mm_ijp(:,:,rdke),ZXXD_c_tp.mp_ijm(:,:,rdke),ZXXD_c_tp.mp_ijp(:,:,rdke),ZXXF_c_tp.m_ijm(:,:,rdke),ZXXF_c_tp.m_ijp(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),XXpn(:,:,rdke));
    %
    ZP0.x_c_tp_fsav = 2*pi*xqratio(rdke).*integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXIntegrand_im.*ZXXS.p0_c_tp_imj + XXIntegrand_ip.*ZXXS.p0_c_tp_ipj)/2,1),1).';
    %
    %f0_g contribution
    %
    [ZXXS.p0_c_g_imj,ZXXS.p0_c_g_ipj,ZXXS.m0_c_g_ijm,ZXXS.m0_c_g_ijp] = ...
        fluxes_dke_jd(XXdf0dpn_g_imj(:,:,rdke),XXdf0dpn_g_ipj(:,:,rdke),XXdf0dmhu_g_imj(:,:,rdke),XXdf0dmhu_g_ipj(:,:,rdke),XXf0_g_imj(:,:,rdke),XXf0_g_ipj(:,:,rdke),...
                      ZXXD_c.pp_imj(:,:,rdke),ZXXD_c.pp_ipj(:,:,rdke),ZXXD_c.pm_imj(:,:,rdke),ZXXD_c.pm_ipj(:,:,rdke),ZXXF_c.p_imj(:,:,rdke),ZXXF_c.p_ipj(:,:,rdke),XX1mmhu2(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),...
                      XXdf0dmhu_g_ijm(:,:,rdke),XXdf0dmhu_g_ijp(:,:,rdke),XXdf0dpn_g_ijm(:,:,rdke),XXdf0dpn_g_ijp(:,:,rdke),XXf0_g_ijm(:,:,rdke),XXf0_g_ijp(:,:,rdke),...
                      ZXXD_c.mm_ijm(:,:,rdke),ZXXD_c.mm_ijp(:,:,rdke),ZXXD_c.mp_ijm(:,:,rdke),ZXXD_c.mp_ijp(:,:,rdke),ZXXF_c.m_ijm(:,:,rdke),ZXXF_c.m_ijp(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),XXpn(:,:,rdke));
    %
    ZP0.x_c_g_fsav = 2*pi*xqratio(rdke).*integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXIntegrand_im.*ZXXS.p0_c_g_imj + XXIntegrand_ip.*ZXXS.p0_c_g_ipj)/2,1),1).';
end
%
%   Ohmic fluxes and power
%
%
% f0 contribution
%
[ZXXS.p0_e_imj,ZXXS.p0_e_ipj,ZXXS.m0_e_ijm,ZXXS.m0_e_ijp] = ...
    fluxes_dke_jd(XXdf0dpn_imj(:,:,rdke),XXdf0dpn_ipj(:,:,rdke),XXdf0dmhu_imj(:,:,rdke),XXdf0dmhu_ipj(:,:,rdke),XXf0_imj(:,:,rdke),XXf0_ipj(:,:,rdke),...
                  ZXXD_e.pp_imj(:,:,rdke),ZXXD_e.pp_ipj(:,:,rdke),ZXXD_e.pm_imj(:,:,rdke),ZXXD_e.pm_ipj(:,:,rdke),ZXXF_e.p_imj(:,:,rdke),ZXXF_e.p_ipj(:,:,rdke),XX1mmhu2(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),...
                  XXdf0dmhu_ijm(:,:,rdke),XXdf0dmhu_ijp(:,:,rdke),XXdf0dpn_ijm(:,:,rdke),XXdf0dpn_ijp(:,:,rdke),XXf0_ijm(:,:,rdke),XXf0_ijp(:,:,rdke),...
                  ZXXD_e.mm_ijm(:,:,rdke),ZXXD_e.mm_ijp(:,:,rdke),ZXXD_e.mp_ijm(:,:,rdke),ZXXD_e.mp_ijp(:,:,rdke),ZXXF_e.m_ijm(:,:,rdke),ZXXF_e.m_ijp(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),XXpn(:,:,rdke));
%
ZP0.x_e_fsav = 2*pi*xqratio(rdke).*integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXIntegrand_im.*ZXXS.p0_e_imj + XXIntegrand_ip.*ZXXS.p0_e_ipj)/2,1),1).';
%
if dke_mode >= 1
    %
    %f0_tp contribution
    %
    [ZXXS.p0_e_tp_imj,ZXXS.p0_e_tp_ipj,ZXXS.m0_e_tp_ijm,ZXXS.m0_e_tp_ijp] = ...
        fluxes_dke_jd(XXdf0dpn_tp_imj(:,:,rdke),XXdf0dpn_tp_ipj(:,:,rdke),XXdf0dmhu_tp_imj(:,:,rdke),XXdf0dmhu_tp_ipj(:,:,rdke),XXf0_tp_imj(:,:,rdke),XXf0_tp_ipj(:,:,rdke),...
                      ZXXD_e_tp.pp_imj(:,:,rdke),ZXXD_e_tp.pp_ipj(:,:,rdke),ZXXD_e_tp.pm_imj(:,:,rdke),ZXXD_e_tp.pm_ipj(:,:,rdke),ZXXF_e_tp.p_imj(:,:,rdke),ZXXF_e_tp.p_ipj(:,:,rdke),XX1mmhu2(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),...
                      XXdf0dmhu_tp_ijm(:,:,rdke),XXdf0dmhu_tp_ijp(:,:,rdke),XXdf0dpn_tp_ijm(:,:,rdke),XXdf0dpn_tp_ijp(:,:,rdke),XXf0_tp_ijm(:,:,rdke),XXf0_tp_ijp(:,:,rdke),...
                      ZXXD_e_tp.mm_ijm(:,:,rdke),ZXXD_e_tp.mm_ijp(:,:,rdke),ZXXD_e_tp.mp_ijm(:,:,rdke),ZXXD_e_tp.mp_ijp(:,:,rdke),ZXXF_e_tp.m_ijm(:,:,rdke),ZXXF_e_tp.m_ijp(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),XXpn(:,:,rdke));
    %
    ZP0.x_e_tp_fsav = 2*pi*xqratio(rdke).*integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXIntegrand_im.*ZXXS.p0_e_tp_imj + XXIntegrand_ip.*ZXXS.p0_e_tp_ipj)/2,1),1).';
    %
    %f0_g contribution
    %
    [ZXXS.p0_e_g_imj,ZXXS.p0_e_g_ipj,ZXXS.m0_e_g_ijm,ZXXS.m0_e_g_ijp] = ...
        fluxes_dke_jd(XXdf0dpn_g_imj(:,:,rdke),XXdf0dpn_g_ipj(:,:,rdke),XXdf0dmhu_g_imj(:,:,rdke),XXdf0dmhu_g_ipj(:,:,rdke),XXf0_g_imj(:,:,rdke),XXf0_g_ipj(:,:,rdke),...
                      ZXXD_e.pp_imj(:,:,rdke),ZXXD_e.pp_ipj(:,:,rdke),ZXXD_e.pm_imj(:,:,rdke),ZXXD_e.pm_ipj(:,:,rdke),ZXXF_e.p_imj(:,:,rdke),ZXXF_e.p_ipj(:,:,rdke),XX1mmhu2(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),...
                      XXdf0dmhu_g_ijm(:,:,rdke),XXdf0dmhu_g_ijp(:,:,rdke),XXdf0dpn_g_ijm(:,:,rdke),XXdf0dpn_g_ijp(:,:,rdke),XXf0_g_ijm(:,:,rdke),XXf0_g_ijp(:,:,rdke),...
                      ZXXD_e.mm_ijm(:,:,rdke),ZXXD_e.mm_ijp(:,:,rdke),ZXXD_e.mp_ijm(:,:,rdke),ZXXD_e.mp_ijp(:,:,rdke),ZXXF_e.m_ijm(:,:,rdke),ZXXF_e.m_ijp(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),XXpn(:,:,rdke));
    %
    ZP0.x_e_g_fsav = 2*pi*xqratio(rdke).*integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXIntegrand_im.*ZXXS.p0_e_g_imj + XXIntegrand_ip.*ZXXS.p0_e_g_ipj)/2,1),1).';
end
%
XXSp0_imj = ZXXS.p0_c_imj + ZXXS.p0_e_imj + ZXXS.p0_rf_imj;
XXSm0_ijm = ZXXS.m0_c_ijm + ZXXS.m0_e_ijm + ZXXS.m0_rf_ijm;
XXSp0_ipj = ZXXS.p0_c_ipj + ZXXS.p0_e_ipj + ZXXS.p0_rf_ipj;
XXSm0_ijp = ZXXS.m0_c_ijp + ZXXS.m0_e_ijp + ZXXS.m0_rf_ijp;
%
% -------------------------------------------------------------------------
% 
%                       Other Moments Calculation
%
% -------------------------------------------------------------------------
%
bounce_mode = dkeparam.bounce_mode;
temppath = path.temppath;
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
Xdmhupp = gridDKE.Xdmhupp;
Xdpnmm = gridDKE.Xdpnmm;
Xdpn = gridDKE.Xdpn;
Xdpnpp = gridDKE.Xdpnpp;
Xmhumm = gridDKE.Xmhumm;
Xmhum = gridDKE.Xmhum;
Xmhu = gridDKE.Xmhu;
Xmhup = gridDKE.Xmhup;
Xmhupp = gridDKE.Xmhupp;
Xpnmm = gridDKE.Xpnmm;
Xpnpp = gridDKE.Xpnpp;
Xpn2m = gridDKE.Xpn2m;
Xpn2 = gridDKE.Xpn2;
Xpn2p = gridDKE.Xpn2p;
xpsin = gridDKE.xpsin;
XXmhu = gridDKE.XXmhu;
XXpn2 = gridDKE.XXpn2;
XXpn = gridDKE.XXpn;
XXpn2m = gridDKE.XXpn2m;
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
v = Zmomcoef.v;
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
XXlossripple = Zmripple.XXlossripple;
%
XXlambda_p2m2p2 = Zbouncecoef.XXlambda_p2m2p2;
XXlambda_b_p1m1 = Zbouncecoef.XXlambda_b_p1m1;
XXlambda_b_p2 = Zbouncecoef.XXlambda_b_p2;
XXheaviside = Zbouncecoef.XXheaviside;
Zmask_f0_t = Zbouncecoef.Zmask_f0_t;
ns_f = Zbouncecoef.ns_f; 
xq = Zbouncecoef.xq;
xqbar =  Zbouncecoef.xqbar;
Zmask_g = Zbouncecoef.Zmask_g;
ns_g = Zbouncecoef.ns_g;
xftp_norm = mksa.xftp_norm_ref;
%
xB0 = equilDKE.xB0;        
Rp = equilDKE.Rp;
xx0 = equilDKE.xx0;
xBT0 = equilDKE.xBT0;
xZeff = equilDKE.xZeff;
%
betath_ref = mksa.betath_ref;
%
[xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth] = normcoef_dke_yp(mksa,equilDKE,gridDKE);   
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
Zcurr.x_tp_fsav = 2*pi*(xqtilde(rdke)./xqbar(rdke))./(1 + xx0(rdke)/Rp).*(xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke).*XXlambda_p2m2p2(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
Zcurr.x_g_fsav = 2*pi*(xq(rdke)./xqbar(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_g(:,:,rdke).*XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
Zcurr.x_tot_fsav = Zcurr.x_0_fsav + Zcurr.x_tp_fsav + Zcurr.x_g_fsav;%Total current density
%
if dkeparam.coll_mode == 3,%Lorentz model (test mode only, see documentation)
    Zcurr.x_L_tp_fsav = 2*pi*(xqtilde(rdke)./xqbar(rdke))./(1 + xx0(rdke)/Rp).*(xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke).*XXlambda_p2m2p2(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
    Zcurr.x_L_g_fsav = 2*pi*(xq(rdke)./xqbar(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_g(:,:,rdke).*XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
    Zcurr.x_L_tot = Zcurr.x_0_fsav + Zcurr.x_L_tp_fsav + Zcurr.x_L_g_fsav;%Total current density
end
%
%  Wave-induced radial transport by adjoint technique (P. Helander model)
%
xX = ones(nr,1)*pn/sqrt(2);
xXG = (erf(xX) - 2*xX.*exp(-xX.^2)/sqrt(pi))./2./xX./xX;
XXnhuDei = permute(repmat(((xrnhuth.*xZeff)'*ones(1,npn)).*((erf(xX) - xXG)./xX./xX./xX),[1,1,nmhu]),[2,3,1]);
%  
if dke_mode == 1,
    xggradpsi22 = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*(xR0(rdke).*xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0(:,:,rdke).*XXnhuDei(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke).*XXlambda_b_p1m1(:,:,rdke),1),1)';
end
%
%   Wave-induced radial transport by adjoint technique (P. Helander model)
%
if dke_mode == 1,
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
%pnminRR = 2;%
%zminRR = betath_ref*pnminRR;
%zminRR2 = zminRR.*zminRR;
%gammaminRR = sqrt(1 + zminRR2);
%xRR_secondary_fsav = 1/(gammaminRR-1)*pi*xnloss(rdke).*xrnhuth(rdke)./xlnc_e(rdke);
%
xRR_fsav = xRR_primary_fsav;% + xRR_secondary_fsav;%Runaway rate profile (primary + secondary contribution)
%
Xxf0 = 0.5*integral_dke_jd(dmhu,XXf0(:,:,rdke),2);
XxfM = squeeze(XXfM(:,1,rdke));
Xxpn = repmat(pn',[1,nr_dke]);
Xxv = repmat(v',[1,nr_dke]);
%
xvth20 = 4*pi*integral_dke_jd(dpn,Xxpn.*Xxpn.*Xxv.*Xxv.*Xxf0,1)'/3;
xvth2M = 4*pi*integral_dke_jd(dpn,Xxpn.*Xxpn.*Xxv.*Xxv.*XxfM,1)'/3;
xTe_norm_out = (xvth20./xvth2M).*xTe_norm(rdke);%New bulk temperature (bulk heating)
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
if sum(sum(sum(XXlossripple))) ~= 0 & isempty(findstr(equilDKE.tokname,'TS')) == 0,
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
%
