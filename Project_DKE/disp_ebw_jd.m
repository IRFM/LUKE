function [xpsin_out_EBW_ht,xtheta_EBW_ht,xMNperp_EBW_ht,xM3eps_pmz_EBW_ht,xMPflow_EBW_ht,xMPabs_EBW_at,...
        xpsin_out_EBW_ft,xMNperp_EBW_ft,xM3eps_pmz_EBW_ft] = ...
    disp_ebw_jd(tokamak,xpsin,xtheta,xNpar,omega);
%
nr = length(xpsin);
%
[qe,me,mp,mn,e0] = pc_dke_yp;
%
[mtheta,xpsin,psia,xtR,xtZ,xtBR,xtBZ,xtBphi,xB0,xR0,xBT0,xBp0,xrho,xTe,xne,xzTi,xzni,zZi,zmi,xZeff,Rp,Zp,ap] = equilibrium_jd(tokamak,xpsin);
%
xB = mg_interp_jd(mtheta,xtR,xtZ,xtBR,xtBZ,xtBphi,Rp,Zp,xtheta')';
%
% Cut-Offs location in cold plasma
%
xns = [xne;xzni];
%
qs = qe*[-1;zZi'];
ms = [me;mp*zmi'];
xqs = repmat(qs,[1,nr]);
xms = repmat(ms,[1,nr]);
%
Ni = length(zZi);
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
%
Npar_lim = 1/sqrt(1+abs(xwps(1,iOco_app))/xwps(1,iOco_app));
%
if xNpar(iOco_app) > Npar_lim,
    ir0 = iOco_app;
else
    ir0 = iCmin_app;
end
%
% ES approximation
%
[Nperp_ES] = disp_ebwES_jd(xB(ir0),xTe(ir0),xne(ir0),omega);
%
% Determines EBW root
%
mask_in_EBW = ir0:-1:1;
nr_in_EBW = length(mask_in_EBW);
xpsin_in_EBW = xpsin(mask_in_EBW);
xNpar_in_EBW = xNpar(mask_in_EBW);
xB_in_EBW = xB(mask_in_EBW);
xTe_in_EBW = xTe(mask_in_EBW);
xne_in_EBW = xne(mask_in_EBW);
%    
GNperp_EBW = Nperp_ES;
knr_EBW = 1;
nrt_nr_EBW = 1;
nrt_fr_EBW = 0;
kflag_EBW = 1;
nn_nr_EBW = 50;
%
[xpsin_out_EBW_ft,xMNperp_EBW_ft,xM3eps_pmz_EBW_ft,xpsin_out_EBW_ht,xMNperp_EBW_ht,xM3eps_pmz_EBW_ht,xMPflow_EBW_ht,xMPabs_EBW_at] = ...
    disp_jd(xpsin_in_EBW,xB_in_EBW,xTe_in_EBW,xne_in_EBW,xNpar_in_EBW,omega,knr_EBW,nrt_nr_EBW,nrt_fr_EBW,kflag_EBW,GNperp_EBW,nn_nr_EBW);
nr_out_EBW_ft = length(xpsin_out_EBW_ft);
nr_out_EBW_ht = length(xpsin_out_EBW_ht);
if nr_out_EBW_ht ~= nr_in_EBW
    diff = num2str(100 - nr_out_EBW_ht*100/nr_in_EBW);
    disp(['Warning: disp. calc. have been truncated by ',diff(1:2),' %'])
end
%
xM3eps_pmz_EBW_ft = squeeze(xM3eps_pmz_EBW_ft);%since nrt=1
xM3eps_pmz_EBW_ht = squeeze(xM3eps_pmz_EBW_ht);
%
mask_out_EBW_ht = ir0:-1:ir0-nr_out_EBW_ht+1;
xtheta_EBW_ht = xtheta(mask_out_EBW_ht);
%
