function [ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = rfdiff_dke_fw_jd(dkeparam,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,waves);%RF waves flux coefficients
%
% full wave diffusion tensor calculation
%
method = 'spline';
%
xrho = equilDKE.xrho;
xrho_S = radialDKE.xrho_S_dke;
%
% grids for interpolation
%
xrho_I = [0,xrho,1];
xrhoP_I = [0,equilDKE.xrhoP,1];
xrhoT_I = [0,equilDKE.xrhoT,1];
xrhoV_I = [0,equilDKE.xrhoV,1];
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
Xvpar = XXvpar.ij(:,:,1);
dvpar = mean([mean(diff(Xvpar)),mean(diff(Xvpar.'))]);
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
    %
    wave = waves{iw};
    %
    % normalization 
    %
    % The parallel quasilinear coefficient D// is considered here, with
    % D// = D_LD + vperp^2 D_MX +  vperp^4 D_TT.
    %
    % We assume the following normalization. 
    %
    % - xvpar and vperp are normalized to c
    % - xDql_LD, xDql_MX and xDql_TT are  normalized to (mc)^2
    %
    Xvpar = wave.Xvpar;
    %Xvpar_S = wave.Xvpar_S;
    XDql_LD = wave.XDql_LD;
    XDql_MX = wave.XDql_MX;
    XDql_TT = wave.XDql_TT;
    %rho = wave.rho;
    rho_S = wave.rho_S;
    rhotype = wave.rhotype;
    %
    [nv,nr_fw] = size(Xvpar);
    %
    % In LUKE, the velocities are normalized to vT = betath_ref*c
    % and the diffusion coefficients to (nhu_ref pT^2)
    %
    Xvpar = Xvpar/mksa.betath_ref;
    XDql_LD = XDql_LD/(mksa.nhu_ref*mksa.betath_ref^2);
    XDql_MX = XDql_MX/(mksa.nhu_ref*mksa.betath_ref^2)*mksa.betath_ref^2;
    XDql_TT = XDql_TT/(mksa.nhu_ref*mksa.betath_ref^2)*mksa.betath_ref^4;
    %
%     Xdvpar = [Xvpar(2,:) - Xvpar(1,:);...
%               (Xvpar(3:end,:) - Xvpar(1:end-2,:))/2;...
%               Xvpar(end,:) - Xvpar(end-1,:)];
    %
    if rhotype == 'g',
        %wrho = rho;
        wrho_S = rho_S;
    elseif rhotype == 'p',
        %wrho = interp1(xrhoP_I,xrho_I,rho,method);
        wrho_S = interp1(xrhoP_I,xrho_I,rho_S,method);
    elseif rhotype == 't',
        %wrho = interp1(xrhoT_I,xrho_I,rho,method);
        wrho_S = interp1(xrhoT_I,xrho_I,rho_S,method);
    elseif rhotype == 'v',
        %wrho = interp1(xrhoV_I,xrho_I,rho,method);
        wrho_S = interp1(xrhoV_I,xrho_I,rho_S,method);
    else
        error('rho type not recognized')
    end
    %
    wdrho = diff(wrho_S);
    %
    % There are several possible methods : 
    % - smooth XDql (in both (or either) v// and (or) rho)
    % - take every contribution from XDql and map it on (rho,p,mhu) space
    % - a combination of the two (smooth in v// for each rho contribution...)
    %
    for ir_fw = 1:nr_fw,
        % 
        disp(['Contruction of DQL from FW data : ir_rw = ',num2str(ir_fw),'/',num2str(nr_fw)]);
        %
        xmask = max([zeros(1,nr);(min([repmat(wrho_S(ir_fw + 1),[1,nr]);xrho_S(2:end)]) - max([repmat(wrho_S(ir_fw),[1,nr]);xrho_S(1:end-1)]))])/wdrho(ir_fw);
        XXmask = repmat(reshape(xmask,[1,1,nr]),[npn,nmhu,1]);
        %
        yvpar = Xvpar(:,ir_fw);
        yDql_LD = smooth_jd(yvpar,XDql_LD(:,ir_fw),dvpar);
        yDql_MX = smooth_jd(yvpar,XDql_MX(:,ir_fw),dvpar);
        yDql_TT = smooth_jd(yvpar,XDql_TT(:,ir_fw),dvpar);
        %
        XXDld.ipj = XXDld.ipj + XXmask.*interp1(yvpar,yDql_LD,XXvpar.ipj,'linear',0);
        XXDld.ij = XXDld.ipj + XXmask.*interp1(yvpar,yDql_LD,XXvpar.ij,'linear',0);
        XXDld.imj = XXDld.ipj + XXmask.*interp1(yvpar,yDql_LD,XXvpar.imj,'linear',0);
        XXDld.ijp = XXDld.ipj + XXmask.*interp1(yvpar,yDql_LD,XXvpar.ijp,'linear',0);
        XXDld.ijm = XXDld.ipj + XXmask.*interp1(yvpar,yDql_LD,XXvpar.ijm,'linear',0);
        %
        XXDmx.ipj = XXDld.ipj + XXmask.*interp1(yvpar,yDql_MX,XXvpar.ipj,'linear',0);
        XXDmx.ij = XXDld.ipj + XXmask.*interp1(yvpar,yDql_MX,XXvpar.ij,'linear',0);
        XXDmx.imj = XXDld.ipj + XXmask.*interp1(yvpar,yDql_MX,XXvpar.imj,'linear',0);
        XXDmx.ijp = XXDld.ipj + XXmask.*interp1(yvpar,yDql_MX,XXvpar.ijp,'linear',0);
        XXDmx.ijm = XXDld.ipj + XXmask.*interp1(yvpar,yDql_MX,XXvpar.ijm,'linear',0);
        %
        XXDtt.ipj = XXDld.ipj + XXmask.*interp1(yvpar,yDql_TT,XXvpar.ipj,'linear',0);
        XXDtt.ij = XXDld.ipj + XXmask.*interp1(yvpar,yDql_TT,XXvpar.ij,'linear',0);
        XXDtt.imj = XXDld.ipj + XXmask.*interp1(yvpar,yDql_TT,XXvpar.imj,'linear',0);
        XXDtt.ijp = XXDld.ipj + XXmask.*interp1(yvpar,yDql_TT,XXvpar.ijp,'linear',0);
        XXDtt.ijm = XXDld.ipj + XXmask.*interp1(yvpar,yDql_TT,XXvpar.ijm,'linear',0);
        %
    end
end
%
keyboard
%
XXDrf.ipj = XXmhu.*XXmhu.*(XXDld.ipj + XXv2p.*XX1mmhu2.*XXDmx.ipj + XXv2p.*XXv2p.*XX1mmhu2.*XX1mmhu2.*XXDtt.ipj)./XX1mmhu2;
XXDrf.ij = XXmhu.*XXmhu.*(XXDld.ij + XXv2.*XX1mmhu2.*XXDmx.ij + XXv2.*XXv2.*XX1mmhu2.*XX1mmhu2.*XXDtt.ij)./XX1mmhu2;
XXDrf.imj = XXmhu.*XXmhu.*(XXDld.imj + XXv2m.*XX1mmhu2.*XXDmx.imj + XXv2m.*XXv2m.*XX1mmhu2.*XX1mmhu2.*XXDtt.imj)./XX1mmhu2;
XXDrf.ijp = XXmhup.*XXmhup.*(XXDld.ijp + XXv2.*XX1mmhu2p.*XXDmx.ijp + XXv2.*XXv2.*XX1mmhu2p.*XX1mmhu2p.*XXDtt.ijp)./XX1mmhu2p;
XXDrf.ijm = XXmhum.*XXmhum.*(XXDld.ijm + XXv2.*XX1mmhu2m.*XXDmx.ijm + XXv2.*XXv2.*XX1mmhu2m.*XX1mmhu2m.*XXDtt.ijm)./XX1mmhu2m;
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


