function [xrho_out_SX,xMNperp_SX,xM3eps_pmz_SX,...
        xrho_out_EBB,xMNperp_EBB,xM3eps_pmz_EBB,...
        xrho_out_EBW_ft,xMNperp_EBW_ft,xM3eps_pmz_EBW_ft,...
        xrho_out_EBW_ht,xMNperp_EBW_ht,xM3eps_pmz_EBW_ht,xMPflow_EBW_ht,xMPabs_EBW_at] = ...
    disp_ebw_jd(tokamak,xrho,xtheta,xNpar,omega);
%
n_MCR = 2000; %resolution in the MCR
%
nr = length(xrho);
%
qe = 1.60217733e-19;%Electron charge (C)
me = 9.1093897e-31;%Electron rest mass (Kg)
mp = 1.6726e-27;%Proton rest mass (Kg)
e0 = 8.8542e-12;%Free space permeability (F/m)
%
%
% Approximate Localization of Cut-Offs
%
loadstr = ['PARAM_',tokamak];
eval(['load ',loadstr,' ap Rp Bt pne Zi mi fi pzTi pzni prho pq']);
%
iaa = ap/Rp;
xne = interp1(prho,pne,xrho,'spline');
zxni = interp1(prho,pzni',xrho,'spline')';
xq = interp1(prho,pq,xrho,'spline');
xq(xq == 0) = eps;
%
xia = xrho*iaa;
xBt = Bt./(1+xia.*cos(xtheta));
xBp = xrho*ap/Rp.*xBt./xq;
xB = sqrt(xBt.^2 + xBp.^2);
xwce0 = qe*xB/me;
%
xns = [xne;zxni];
%
qs = qe*[-1;Zi'];
ms = [me;mp*mi'];
xqs = repmat(qs,[1,nr]);
xms = repmat(ms,[1,nr]);
%
Ni = length(Zi);
%
xBs = repmat(xB,[Ni+1,1]);
%
xwps = sqrt(xns.*xqs.^2/e0./xms);
xwcs = xqs.*xBs./xms;
%
xwR = sqrt((-xwcs(1,:) + xwcs(2,:)).^2/4 + sum(xwps.^2)./(1-xNpar.^2)) + (-xwcs(1,:) - xwcs(2,:))/2; 
xwL = sqrt((-xwcs(1,:) + xwcs(2,:)).^2/4 + sum(xwps.^2)./(1-xNpar.^2)) - (-xwcs(1,:) - xwcs(2,:))/2; 
%
iRco_app = max(find(omega < xwR));
iLco_app = max(find(omega < xwL));
iOco_app = max(find(omega < sqrt(sum(xwps.^2))));
iCmin_app = min([iRco_app,iLco_app,iOco_app]);
fr = 0.1;
xrho_MCR = linspace(xrho(iCmin_app)*(1 + fr)-fr,1,n_MCR);
xtheta_MCR = interp1(xrho,xtheta,xrho_MCR);
xNpar_MCR = interp1(xrho,xNpar,xrho_MCR);
%
%
% Cold plasma calculations
%
[NperpX_cold,NperpO_cold,xKxyz,x3eX_xyz_cold,x3eO_xyz_cold,x3eX_pmz_cold,x3eO_pmz_cold,x3eX_ppk_cold,x3eO_ppk_cold] = ...
    colddisp_OX_jd(tokamak,xrho_MCR.*cos(xtheta_MCR),xrho_MCR.*sin(xtheta_MCR),omega,xNpar_MCR);
%
aX = (pi/2 - angle(x3eX_pmz_cold(:,1)))*ones(1,3);
aO = (- angle(x3eO_pmz_cold(:,3)))*ones(1,3);
x3eX_xyz_cold = x3eX_xyz_cold.*exp(i*aX);
x3eX_pmz_cold = x3eX_pmz_cold.*exp(i*aX);
x3eX_ppk_cold = x3eX_ppk_cold.*exp(i*aX);
x3eO_xyz_cold = x3eO_xyz_cold.*exp(i*aO);
x3eO_pmz_cold = x3eO_pmz_cold.*exp(i*aO);
x3eO_ppk_cold = x3eO_ppk_cold.*exp(i*aO);
%
% cut-offs
%
xKpar = squeeze(xKxyz(3,3,:))';
xKperp = squeeze(xKxyz(1,1,:))';
xKxy = squeeze(i*xKxyz(1,2,:))';
%
xOco = xKpar; % O-mode cut-off
%
xKR = xKperp + xKxy;
xKL = xKperp - xKxy;
%
xRco = xKR-xNpar_MCR.^2; % R cut-off
xLco = xKL-xNpar_MCR.^2; % L cut-off
%
% wave resonances
%
xHres = xKperp; % UH or LH resonance
%
iLco = find((sign(xLco(2:n_MCR-1).*xLco(3:n_MCR)) <= 0) & (sign(diff(xLco(1:n_MCR-1)).*diff(xLco(2:n_MCR))) >= 0)) + 1;
iRco = find((sign(xRco(2:n_MCR-1).*xRco(3:n_MCR)) <= 0) & (sign(diff(xRco(1:n_MCR-1)).*diff(xRco(2:n_MCR))) >= 0)) + 1;
iOco = find((sign(xOco(2:n_MCR-1).*xOco(3:n_MCR)) <= 0) & (sign(diff(xOco(1:n_MCR-1)).*diff(xOco(2:n_MCR))) >= 0)) + 1;
iHres = find((sign(xHres(2:n_MCR-1).*xHres(3:n_MCR)) <= 0) & (sign(diff(xHres(1:n_MCR-1)).*diff(xHres(2:n_MCR))) >= 0)) + 1;
%
xia_MCR = xrho_MCR*iaa;
xq_MCR = interp1(prho,pq,xrho_MCR);
xq(xq == 0) = eps;
%
xBt_MCR = Bt./(1 + xia_MCR.*cos(xtheta_MCR));
xBp_MCR = xia_MCR.*xBt_MCR./xq_MCR;
xB_MCR = sqrt(xBt_MCR.^2 + xBp_MCR.^2);
xwce0_MCR = qe*xB_MCR/me;
%
if omega > 2*xwce0_MCR(iHres) %%%% mode conversion beyond UH res.
    scen = 1;
else                     %%%% mode conversion before UH res.
    scen = 0;
end
%
% Determines slow X-Mode branch
%
npar_OL = sqrt(1-1/(1+xwce0_MCR(iOco)/omega));
if abs(xNpar_MCR(iOco)) < npar_OL
    rho_0_SX = xrho_MCR(iLco + round(n_MCR/20));
else
    rho_0_SX = xrho_MCR(iOco + round(n_MCR/20));
end
mask_in_SX = (xrho_MCR >= rho_0_SX);
xrho_in_SX = xrho_MCR(mask_in_SX);
nr_in_SX = length(xrho_in_SX);
xtheta_in_SX = xtheta_MCR(mask_in_SX);
xNpar_in_SX = xNpar_MCR(mask_in_SX);
    
GNperpRe_SX = [1e-3];
GNperpIm_SX = [1e-3];
%GNperp_SX = GNperpRe_SX + i*GNperpIm_SX;
GNperp_SX = NperpX_cold(find(rho_0_SX == xrho_MCR));
knr_SX = 1;
nrt_nr_SX = 1;
nrt_fr_SX = 0;
kflag_SX = 1;
nn_nr_SX = 20;
%
[xrho_out_SX,xMNperp_SX,xM3eps_pmz_SX] = disp_jd(tokamak,xrho_in_SX,rho_0_SX,xtheta_in_SX,xNpar_in_SX,omega,knr_SX,nrt_nr_SX,nrt_fr_SX,kflag_SX,GNperp_SX,nn_nr_SX);
nr_out_SX = length(xrho_out_SX);
if nr_out_SX ~= nr_in_SX
    diff = num2str(100 - nr_out_SX*100/nr_in_SX);
    warning(['disp. calc. have been truncated by ',diff(1:2),' %'])
end
%
% Determines position of mode conversion to EBW
%
rho_0_MC = xrho_MCR(iHres);
%if scen == 1
%    mask_in_MC = (xrho_out_SX > rho_0_MC);
%else
%    mask_in_MC = (xrho_out_SX < rho_0_MC);
%end

%xrho_in_MC = xrho_out_SX(mask_in_MC);
xrho_in_MC = xrho_out_SX;
%xMNperp_MC = xMNperp_SX(mask_in_MC);
xMNperp_MC = xMNperp_SX;

%iMC = find(diff(real(xMNperp_MC)) == max(diff(real(xMNperp_MC)))) + 1;
iMCmax = min(find(abs(imag(xMNperp_MC)) > abs(real(xMNperp_MC))));
if isempty(iMCmax), 
    iMCmax = find(abs(imag(xMNperp_MC)) == max(abs(imag(xMNperp_MC))));
end
mask_MCmin = find(abs(imag(xMNperp_MC)) < 1e-6);
mask_MCmin = mask_MCmin(find(mask_MCmin < iMCmax));
iMCmin = max(mask_MCmin) - n_MCR/5;
%iMCmin = 1;
%
% Determines EBW branch
%
rho_0_EBB_max = xrho_in_MC(iMCmax);
rho_0_EBB_min = xrho_in_MC(iMCmin);
mask_in_EBB = (xrho_MCR <= rho_0_EBB_max) & (xrho_MCR >= rho_0_EBB_min);
%xrho_in_EBB = xrho_MCR(mask_in_EBB);
xrho_in_EBB = linspace(rho_0_EBB_min,rho_0_EBB_max,n_MCR);;
nr_in_EBB = length(xrho_in_EBB);
%xtheta_in_EBB = xtheta_MCR(mask_in_EBB);
%xNpar_in_EBB = xNpar_MCR(mask_in_EBB);
xtheta_in_EBB = interp1(xrho_MCR,xtheta_MCR,xrho_in_EBB);
xNpar_in_EBB = interp1(xrho_MCR,xNpar_MCR,xrho_in_EBB);
    
GNperpRe_EBB = real(xMNperp_MC(iMCmax));
GNperpIm_EBB = imag(xMNperp_MC(iMCmax));
GNperp_EBB = GNperpRe_EBB - i*abs(GNperpIm_EBB);
knr_EBB = 1;
nrt_nr_EBB = 1;
nrt_fr_EBB = 0;
kflag_EBB = 1;
nn_nr_EBB = 20;
%
[xrho_out_EBB,xMNperp_EBB,xM3eps_pmz_EBB] = disp_jd(tokamak,xrho_in_EBB,rho_0_EBB_max,xtheta_in_EBB,xNpar_in_EBB,omega,knr_EBB,nrt_nr_EBB,nrt_fr_EBB,kflag_EBB,GNperp_EBB,nn_nr_EBB);
nr_out_EBB = length(xrho_out_EBB);
if nr_out_EBB ~= nr_in_EBB
    diff = num2str(100 - nr_out_EBB*100/nr_in_EBB);
    warning(['disp. calc. have been truncated by ',diff(1:2),' %'])
end
%
%iEBW = find(xrho_out_EBB == min(xrho_out_EBB));
%
% Determines EBW root
%
irho_0_EBW = min(find(xrho >= min(xrho_out_EBB)));
rho_0_EBW = xrho(irho_0_EBW);
mask_in_EBW = (xrho <= rho_0_EBW);
xrho_in_EBW = xrho(mask_in_EBW);
nr_in_EBW = length(xrho_in_EBW);
xtheta_in_EBW = xtheta(mask_in_EBW);
xNpar_in_EBW = xNpar(mask_in_EBW);
    
GNperpRe_EBW = interp1(xrho_out_EBB,real(xMNperp_EBB),rho_0_EBW);
GNperpIm_EBW = interp1(xrho_out_EBB,imag(xMNperp_EBB),rho_0_EBW);
GNperp_EBW = GNperpRe_EBW + i*GNperpIm_EBW;
knr_EBW = 1;
nrt_nr_EBW = 1;
nrt_fr_EBW = 0;
kflag_EBW = 1;
nn_nr_EBW = 20;
%
[xrho_out_EBW_ft,xMNperp_EBW_ft,xM3eps_pmz_EBW_ft,xrho_out_EBW_ht,xMNperp_EBW_ht,xM3eps_pmz_EBW_ht,xMPflow_EBW_ht,xMPabs_EBW_at] = ...
    disp_jd(tokamak,xrho_in_EBW,rho_0_EBW,xtheta_in_EBW,xNpar_in_EBW,omega,knr_EBW,nrt_nr_EBW,nrt_fr_EBW,kflag_EBW,GNperp_EBW,nn_nr_EBW);
nr_out_EBW = length(xrho_out_EBW_ft);
if nr_out_EBW ~= nr_in_EBW
    diff = num2str(100 - nr_out_EBW*100/nr_in_EBW);
    warning(['disp. calc. have been truncated by ',diff(1:2),' %'])
end

