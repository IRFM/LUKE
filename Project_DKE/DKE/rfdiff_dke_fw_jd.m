function [ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = rfdiff_dke_fw_jd(dkeparam,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,waves);%RF waves flux coefficients
%
% full wave diffusion tensor calculation
%
method = 'linear';
%
XXmhup = gridDKE.XXmhup;
XXmhu = gridDKE.XXmhu;
XXmhum = gridDKE.XXmhum;
%
XX1mmhu2p = gridDKE.XX1mmhu2p;
XX1mmhu2 = gridDKE.XX1mmhu2;
XX1mmhu2m = gridDKE.XX1mmhu2m;
%
XXpn2p = gridDKE.XXpn2p;
XXpn2 = gridDKE.XXpn2;
XXpn2m = gridDKE.XXpn2m;
%
XXgammap = Zmomcoef.XXgammap;
XXgamma = Zmomcoef.XXgamma;
XXgammam = Zmomcoef.XXgammam;
%
XXheavisidep = Zbouncecoef.XXheaviside_p;
XXheaviside = Zbouncecoef.XXheaviside;
XXheavisidem = Zbouncecoef.XXheaviside_m;
%
XXv2p = XXpn2p./XXgammap./XXgammap;
XXv2 = XXpn2./XXgamma./XXgamma;
XXv2m = XXpn2m./XXgammam./XXgammam;
%
% parallel velocity
%
XXvpar.ipj = XXmhu.*gridDKE.XXpnp./XXgammap;
XXvpar.ij = XXmhu.*gridDKE.XXpn./XXgamma;
XXvpar.imj = XXmhu.*gridDKE.XXpnm./XXgammam;
XXvpar.ijp = XXmhup.*gridDKE.XXpn./XXgamma;
XXvpar.ijm = XXmhum.*gridDKE.XXpn./XXgamma;
%
SXX = size(XXmhu);
%
npn = SXX(1);
nmhu = SXX(2);
nr = SXX(3);
%
XXyn = zeros(SXX);%Cerenkov resonance only
%
XXDld.ipj = zeros(SXX);
XXDld.ij = zeros(SXX);
XXDld.imj = zeros(SXX);
XXDld.ijp = zeros(SXX);
XXDld.ijm = zeros(SXX);
%
XXDmx.ipj = zeros(SXX);
XXDmx.ij = zeros(SXX);
XXDmx.imj = zeros(SXX);
XXDmx.ijp = zeros(SXX);
XXDmx.ijm = zeros(SXX);
%
XXDtt.ipj = zeros(SXX);
XXDtt.ij = zeros(SXX);
XXDtt.imj = zeros(SXX);
XXDtt.ijp = zeros(SXX);
XXDtt.ijm = zeros(SXX);
%
% calculation of the DQL components on the DKE grid
% each contribution on the wave.Xvpar grid is accounted for.
%
for iw = 1:length(waves);
    wave = waves{iw};
    %
    [nv,nr_fw] = size(wave.Xvpar);
    %
    for ir = 1:nr_fw,
        %
        xvpar = wave.Xvpar(:,ir);
        xDql_LD = wave.XDql_LD(:,ir);
        xDql_MX = wave.XDql_MX(:,ir);
        xDql_TT = wave.XDql_TT(:,ir);
        %
        % normalization
        %
        xvpar = xvpar/mksa.betath_ref;
        xDql_LD = xDql_LD/mksa.nhu_ref;
        xDql_MX = xDql_MX/mksa.nhu_ref*mksa.betath_ref^2;
        xDql_TT = xDql_TT/mksa.nhu_ref*mksa.betath_ref^4;
        %
        % smoothing of the diffusion coefficient
        % based on the vpar grid for mhu = 1
        %
        % smoothing scale: average DKE vpar grid step
        %
        dvpar = mean(diff(XXvpar.ij(:,nmhu,ir)));
        %
        xDql_LD_s = smooth_jd(xvpar,xDql_LD,dvpar);
        xDql_MX_s = smooth_jd(xvpar,xDql_MX,dvpar);
        xDql_TT_s = smooth_jd(xvpar,xDql_TT,dvpar);
        %
        % interpolation
        %
        XXDld.ipj(:,:,ir) = XXDld.ipj(:,:,ir) + interp1(xvpar,xDql_LD_s,XXvpar.ipj(:,:,ir),method,0);
        XXDmx.ipj(:,:,ir) = XXDmx.ipj(:,:,ir) + interp1(xvpar,xDql_MX_s,XXvpar.ipj(:,:,ir),method,0);
        XXDtt.ipj(:,:,ir) = XXDtt.ipj(:,:,ir) + interp1(xvpar,xDql_TT_s,XXvpar.ipj(:,:,ir),method,0);
        %
        XXDld.ij(:,:,ir) = XXDld.ij(:,:,ir) + interp1(xvpar,xDql_LD_s,XXvpar.ij(:,:,ir),method,0);
        XXDmx.ij(:,:,ir) = XXDmx.ij(:,:,ir) + interp1(xvpar,xDql_MX_s,XXvpar.ij(:,:,ir),method,0);
        XXDtt.ij(:,:,ir) = XXDtt.ij(:,:,ir) + interp1(xvpar,xDql_TT_s,XXvpar.ij(:,:,ir),method,0);
        %
        XXDld.imj(:,:,ir) = XXDld.imj(:,:,ir) + interp1(xvpar,xDql_LD_s,XXvpar.imj(:,:,ir),method,0);
        XXDmx.imj(:,:,ir) = XXDmx.imj(:,:,ir) + interp1(xvpar,xDql_MX_s,XXvpar.imj(:,:,ir),method,0);
        XXDtt.imj(:,:,ir) = XXDtt.imj(:,:,ir) + interp1(xvpar,xDql_TT_s,XXvpar.imj(:,:,ir),method,0);
        %
        XXDld.ijp(:,:,ir) = XXDld.ijp(:,:,ir) + interp1(xvpar,xDql_LD_s,XXvpar.ijp(:,:,ir),method,0);
        XXDmx.ijp(:,:,ir) = XXDmx.ijp(:,:,ir) + interp1(xvpar,xDql_MX_s,XXvpar.ijp(:,:,ir),method,0);
        XXDtt.ijp(:,:,ir) = XXDtt.ijp(:,:,ir) + interp1(xvpar,xDql_TT_s,XXvpar.ijp(:,:,ir),method,0);
        %
        XXDld.ijm(:,:,ir) = XXDld.ijm(:,:,ir) + interp1(xvpar,xDql_LD_s,XXvpar.ijm(:,:,ir),method,0);
        XXDmx.ijm(:,:,ir) = XXDmx.ijm(:,:,ir) + interp1(xvpar,xDql_MX_s,XXvpar.ijm(:,:,ir),method,0);
        XXDtt.ijm(:,:,ir) = XXDtt.ijm(:,:,ir) + interp1(xvpar,xDql_TT_s,XXvpar.ijm(:,:,ir),method,0);
    end
end
%
XXDrf.ipj = XXmhu.*XXmhu.*(XXDld.ipj + XXv2p.*XX1mmhu2.*XXDmx.ipj/2 + XXv2p.*XXv2p.*XX1mmhu2.*XX1mmhu2.*XXDtt.ipj/4)./XX1mmhu2;
XXDrf.ij = XXmhu.*XXmhu.*(XXDld.ij + XXv2.*XX1mmhu2.*XXDmx.ij/2 + XXv2.*XXv2.*XX1mmhu2.*XX1mmhu2.*XXDtt.ij/4)./XX1mmhu2;
XXDrf.imj = XXmhu.*XXmhu.*(XXDld.imj + XXv2m.*XX1mmhu2.*XXDmx.imj/2 + XXv2m.*XXv2m.*XX1mmhu2.*XX1mmhu2.*XXDtt.imj/4)./XX1mmhu2;
XXDrf.ijp = XXmhup.*XXmhup.*(XXDld.ijp + XXv2.*XX1mmhu2p.*XXDmx.ijp/2 + XXv2.*XXv2.*XX1mmhu2p.*XX1mmhu2p.*XXDtt.ijp/4)./XX1mmhu2p;
XXDrf.ijm = XXmhum.*XXmhum.*(XXDld.ijm + XXv2.*XX1mmhu2m.*XXDmx.ijm/2 + XXv2.*XXv2.*XX1mmhu2m.*XX1mmhu2m.*XXDtt.ijm/4)./XX1mmhu2m;
%
XXDrf_mhuflip.ipj = flipdim(XXDrf.ipj,2);
XXDrf_mhuflip.ij = flipdim(XXDrf.ij,2);
XXDrf_mhuflip.imj = flipdim(XXDrf.imj,2);
XXDrf_mhuflip.ijp = flipdim(XXDrf.ijm,2);
XXDrf_mhuflip.ijm = flipdim(XXDrf.ijp,2);
%
XXDrf.ipj(~XXheaviside) = (XXDrf.ipj(~XXheaviside) + XXDrf_mhuflip.ipj(~XXheaviside))/2;
XXDrf.ij(~XXheaviside) = (XXDrf.ij(~XXheaviside) + XXDrf_mhuflip.ij(~XXheaviside))/2;
XXDrf.imj(~XXheaviside) = (XXDrf.imj(~XXheaviside) + XXDrf_mhuflip.imj(~XXheaviside))/2;
XXDrf.ijp(~XXheavisidep) = (XXDrf.ijp(~XXheavisidep) + XXDrf_mhuflip.ijp(~XXheavisidep))/2;
XXDrf.ijm(~XXheavisidem) = (XXDrf.ijm(~XXheavisidem) + XXDrf_mhuflip.ijm(~XXheavisidem))/2;
%	    
% QL diffusion tensor elements
%
ZXXD_rf.pp_ipj = XX1mmhu2.*XXDrf.ipj;   
ZXXD_rf.pp_imj = XX1mmhu2.*XXDrf.imj;
ZXXD_rf.pm_ipj = - sqrt(XX1mmhu2).*(XX1mmhu2 - XXyn).*XXDrf.ipj./XXmhu;
ZXXD_rf.pm_imj = - sqrt(XX1mmhu2).*(XX1mmhu2 - XXyn).*XXDrf.imj./XXmhu;
ZXXD_rf.pr_ipj = zeros(size(XXmhu));
ZXXD_rf.pr_imj = zeros(size(XXmhu));
ZXXF_rf.p_ipj = zeros(size(XXmhu));
ZXXF_rf.p_imj = zeros(size(XXmhu));
%
ZXXD_rf.mm_ijp = (XX1mmhu2p - XXyn).^2.*XXDrf.ijp./XXmhup./XXmhup;
ZXXD_rf.mm_ijm = (XX1mmhu2m - XXyn).^2.*XXDrf.ijm./XXmhum./XXmhum;
ZXXD_rf.mp_ijp = - sqrt(XX1mmhu2p).*(XX1mmhu2p - XXyn).*XXDrf.ijp./XXmhup;
ZXXD_rf.mp_ijm = - sqrt(XX1mmhu2m).*(XX1mmhu2m - XXyn).*XXDrf.ijm./XXmhum;
ZXXD_rf.mr_ijp = zeros(size(XXmhu));
ZXXD_rf.mr_ijm = zeros(size(XXmhu));
ZXXF_rf.m_ijp = zeros(size(XXmhu));
ZXXF_rf.m_ijm = zeros(size(XXmhu));
%
ZXXD_rf.rr_lp = zeros(size(XXmhu));
ZXXD_rf.rr_lm = zeros(size(XXmhu));
ZXXD_rf.rp_lp = zeros(size(XXmhu));
ZXXD_rf.rp_lm = zeros(size(XXmhu));
ZXXD_rf.rm_lp = zeros(size(XXmhu));
ZXXD_rf.rm_lm = zeros(size(XXmhu));
ZXXF_rf.r_lp = zeros(size(XXmhu));
ZXXF_rf.r_lm = zeros(size(XXmhu));
%
ZXXD_rf.pp_ij = XX1mmhu2.*XXDrf.ij; 
ZXXD_rf.pm_ij = - sqrt(XX1mmhu2).*(XX1mmhu2 - XXyn).*XXDrf.ij./XXmhu;
ZXXD_rf.mp_ij = - sqrt(XX1mmhu2).*(XX1mmhu2 - XXyn).*XXDrf.ij./XXmhu;
%
ZXXD_rf.parpar_ij = XX1mmhu2.*(1 - XXyn).^2.*XXDrf.ij./XXmhu./XXmhu; 
%
ZXYD_rf.pp_ipj = ZXXD_rf.pp_ipj(:);
ZXYD_rf.pp_imj = ZXXD_rf.pp_imj(:);
ZXYD_rf.pm_ipj = ZXXD_rf.pm_ipj(:);
ZXYD_rf.pm_imj = ZXXD_rf.pm_imj(:);
ZXYF_rf.p_ipj = ZXXF_rf.p_ipj(:);
ZXYF_rf.p_imj = ZXXF_rf.p_imj(:);
%
ZXYD_rf.mm_ijp = ZXXD_rf.mm_ijp(:);
ZXYD_rf.mm_ijm = ZXXD_rf.mm_ijm(:);
ZXYD_rf.mp_ijp = ZXXD_rf.mp_ijp(:);
ZXYD_rf.mp_ijm = ZXXD_rf.mp_ijm(:);
ZXYF_rf.m_ijp = ZXXF_rf.m_ijp(:);
ZXYF_rf.m_ijm = ZXXF_rf.m_ijm(:);
%
%
ZXYD_rf.rr_lp = ZXXD_rf.rr_lp(:);
ZXYD_rf.rr_lm = ZXXD_rf.rr_lm(:);
ZXYD_rf.rp_lp = ZXXD_rf.rp_lp(:);
ZXYD_rf.rp_lm = ZXXD_rf.rp_lm(:);
ZXYD_rf.rm_lp = ZXXD_rf.rm_lp(:);
ZXYD_rf.rm_lm = ZXXD_rf.rm_lm(:);
ZXYF_rf.r_lp = ZXXF_rf.r_lp(:);
ZXYF_rf.r_lm = ZXXF_rf.r_lm(:);
%
ZXYD_rf.pp_ij = ZXXD_rf.pp_ij(:);
ZXYD_rf.pm_ij = ZXXD_rf.pm_ij(:);
ZXYD_rf.mp_ij = ZXXD_rf.mp_ij(:);
%
ZXYD_rf.parpar_ij = ZXXD_rf.parpar_ij(:);
%
ZXYD_rf_tp = NaN;
ZXYF_rf_tp = NaN;
%
XX_index = find(ones(SXX));
%
gridindex_rf.mask_r = ceil(XX_index/(npn*nmhu));
gridindex_rf.mask_m = ceil((XX_index - (gridindex_rf.mask_r - 1)*npn*nmhu)/npn);
gridindex_rf.mask_p = XX_index - ((gridindex_rf.mask_r - 1)*nmhu + (gridindex_rf.mask_m - 1))*npn;
gridindex_rf.mask_y = ones(prod(SXX),1);
gridindex_rf.mask_n = ones(prod(SXX),1);
%
gridindex_rf.npn = npn;
gridindex_rf.nmhu = nmhu;
gridindex_rf.nr = nr;
gridindex_rf.nr_dke = nr;
gridindex_rf.nb = 1;
gridindex_rf.nn_rf = 1;


