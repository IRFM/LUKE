function [] = testfitequil_yp(equil_in,equil_fit,rho,theta)
%
% Test the interpolated magnetic equilibrium
%
% INPUT
%    - equil_in: numerical magnetic equilibrium structure
%    - equil_fit: interpolated magnetic equilibrium structure
%    - rho: normalized minor radius [1,1]
%      (default = 0.25)
%    - theta: poloidal angle (rad) [1,1]
%      (default = 0.2)
%
% OUTPUT: none
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin <3,% Output for comparison with C raytracing_yp.c
   rho = 0.25;
   theta = 0.2;
end
%
prec = 1e-3;
%
[prho] = psi2rho_jd(equil_in,equil_in.ppsi/equil_in.ppsi(end),'spline');
ppsin = equil_in.ppsi(:)/equil_in.ppsi(end);
dppsin = gradient(ppsin);
dprho = gradient(prho);
dtheta = gradient(equil_in.theta);
%
pTe = equil_in.pTe(:);
pne = equil_in.pne(:);
pzTi = equil_in.pzTi';
pzni = equil_in.pzni';
%
BR = equil_in.BR + eps;
BZ = equil_in.BZ + eps;
%
BP = sqrt(BR.^2 + BZ.^2);
B = sqrt(BR.^2 + BZ.^2 + equil_in.BPHI.^2);
r = sqrt((equil_in.R - equil_in.R(1,1)).^2 + (equil_in.Z - equil_in.Z(1,1)).^2)+eps;
%
salpha = (BZ.*(equil_in.Z - equil_in.Z(1,1)) + BR.*(equil_in.R - equil_in.R(1,1)))./r./BP;
calpha =  (-BR.*(equil_in.Z - equil_in.Z(1,1)) + BZ.*(equil_in.R - equil_in.R(1,1)))./r./BP;
salpha(1,:) = salpha(2,:);
calpha(1,:) = calpha(2,:);
%
[dcalphadtheta,dcalphadrho] = gradient(calpha);%
dcalphadtheta = dcalphadtheta./(ones(length(dprho),1)*dtheta);
dcalphadrho = dcalphadrho./(dprho(:)*ones(1,length(dtheta)));
%
[dsalphadtheta,dsalphadrho] = gradient(salpha);%
dsalphadtheta = dsalphadtheta./(ones(length(dprho),1)*dtheta);
dsalphadrho = dsalphadrho./(dprho(:)*ones(1,length(dtheta)));
%
[drdtheta,drdrho] = gradient(r);%r
drdtheta = drdtheta./(ones(length(dprho),1)*dtheta);
drdrho = drdrho./(dprho(:)*ones(1,length(dtheta)));
%
[dRdtheta,dRdrho] = gradient(equil_in.R);%XR
dRdtheta = dRdtheta./(ones(length(dprho),1)*dtheta);
dRdrho = dRdrho./(dprho(:)*ones(1,length(dtheta)));
%
[dZdtheta,dZdrho] = gradient(equil_in.Z);%XZ
dZdtheta = dZdtheta./(ones(length(dprho),1)*dtheta);
dZdrho = dZdrho./(dprho(:)*ones(1,length(dtheta)));
%
[dBPHIdtheta,dBPHIdrho] = gradient(equil_in.BPHI);%Toroidal magnetic field
dBPHIdtheta = dBPHIdtheta./(ones(length(dprho),1)*dtheta);
dBPHIdrho = dBPHIdrho./(dprho(:)*ones(1,length(dtheta)));
%
[dBPdtheta,dBPdrho] = gradient(BP);%Poloidal magnetic field
dBPdtheta = dBPdtheta./(ones(length(dprho),1)*dtheta);
dBPdrho = dBPdrho./(dprho(:)*ones(1,length(dtheta)));
%
[dBdtheta,dBdrho] = gradient(B);%Total magnetic field
dBdtheta = dBdtheta./(ones(length(dprho),1)*dtheta);
dBdrho = dBdrho./(dprho(:)*ones(1,length(dtheta)));
%
dpsindrho = gradient(ppsin)./dprho(:);
dTedrho = gradient(pTe)./dprho(:);
dnedrho = gradient(pne)./dprho(:);
for i = 1:length(equil_fit.zZi)
   zdTidrho(:,i) = gradient(pzTi(:,i))./dprho(:);
   zdnidrho(:,i) = gradient(pzni(:,i))./dprho(:);
end
%
dRstardpsin = gradient(equil_in.R(:,1))./dppsin(:);
gradrho = equil_in.R.*BP.*(dRstardpsin*ones(1,size(equil_in.R,2)))/equil_fit.ap/equil_fit.psia;
[dgradrhodtheta,dgradrhodrho] = gradient(gradrho);%rho gradient
dgradrhodtheta = dgradrhodtheta./(ones(length(dprho),1)*dtheta);
dgradrhodrho = dgradrhodrho./(dprho(:)*ones(1,length(dtheta)));
%
if nargin < 3, 
   close all;
%
   nrho_fit = 500;
   ntheta_fit= length(equil_in.theta);
%
   rho_fit = linspace(prho(1),prho(end),nrho_fit)';
   rho_fit(1) = prec;
   theta_fit = equil_in.theta';
%
   psin_fit = ppval(equil_fit.psin_fit.pp_f,rho_fit);psin_fit = psin_fit(:);
   psin_fit1 = ppval_yp(equil_fit.psin_fit.pp_f,rho_fit);psin_fit1 = psin_fit1(:);
%
   Te_fit = ppval(equil_fit.Te_fit.pp_f,rho_fit);Te_fit = Te_fit(:);
   Te_fit1 = ppval_yp(equil_fit.Te_fit.pp_f,rho_fit);Te_fit1 = Te_fit1(:);
%
   ne_fit = ppval(equil_fit.ne_fit.pp_f,rho_fit);ne_fit = ne_fit(:);
   ne_fit1 = ppval_yp(equil_fit.ne_fit.pp_f,rho_fit);ne_fit1 = ne_fit1(:);
%
   zTi_fit = ppval(equil_fit.zTi_fit.pp_f,rho_fit);
   zTi_fit1 = ppval_yp(equil_fit.zTi_fit.pp_f,rho_fit);
%
   zni_fit = ppval(equil_fit.zni_fit.pp_f,rho_fit);
   zni_fit1 = ppval_yp(equil_fit.zni_fit.pp_f,rho_fit);
%
   dpsindrho_fit = ppval(equil_fit.psin_fit.pp_dfdrho,rho_fit);
   dpsindrho_fit1 = ppval_yp(equil_fit.psin_fit.pp_dfdrho,rho_fit);
%
   dTedrho_fit = ppval(equil_fit.Te_fit.pp_dfdrho,rho_fit);
   dTedrho_fit1 = ppval_yp(equil_fit.Te_fit.pp_dfdrho,rho_fit);
%
   dnedrho_fit = ppval(equil_fit.ne_fit.pp_dfdrho,rho_fit);
   dnedrho_fit1 = ppval_yp(equil_fit.ne_fit.pp_dfdrho,rho_fit);
%
   zdTidrho_fit = ppval(equil_fit.zTi_fit.pp_dfdrho,rho_fit);
   zdTidrho_fit1 = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,rho_fit);
%
   zdnidrho_fit = ppval(equil_fit.zni_fit.pp_dfdrho,rho_fit);
   zdnidrho_fit1 = ppval_yp(equil_fit.zni_fit.pp_dfdrho,rho_fit);
%
% Calculation of the coordinates and magnetic equilibrium quantity
%
   rho_fit1 = prho(1:10:end);%New normalized radial grid for display 2-D magnetic field
   rho_fit1(1) = prec;
%
   dRstardpsin_fit = ppval(equil_fit.dRstardpsin_fit.pp_f,rho_fit1);dRstardpsin_fit = dRstardpsin_fit(:);
   dRstardpsin_fit1 = ppval_yp(equil_fit.dRstardpsin_fit.pp_f,rho_fit1);dRstardpsin_fit1 = dRstardpsin_fit1(:); 
   ddRstardpsindrho_fit = ppval(equil_fit.dRstardpsin_fit.pp_dfdrho,rho_fit1);ddRstardpsindrho_fit = ddRstardpsindrho_fit(:);
   ddRstardpsindrho_fit1 = ppval_yp(equil_fit.dRstardpsin_fit.pp_dfdrho,rho_fit1);ddRstardpsindrho_fit1 = ddRstardpsindrho_fit1(:);
%
   R_a0_fit = ppval(equil_fit.R_fit.pp_a0,rho_fit1);R_a0_fit = R_a0_fit(:);
   R_an_fit = ppval(equil_fit.R_fit.pp_an,rho_fit1);
   R_bn_fit = ppval(equil_fit.R_fit.pp_bn,rho_fit1);
   R_da0drho_fit = ppval(equil_fit.R_fit.pp_da0drho,rho_fit1);R_da0drho_fit = R_da0drho_fit(:);
   R_dandrho_fit = ppval(equil_fit.R_fit.pp_dandrho,rho_fit1);
   R_dbndrho_fit = ppval(equil_fit.R_fit.pp_dbndrho,rho_fit1);
%
   Z_a0_fit = ppval(equil_fit.Z_fit.pp_a0,rho_fit1);Z_a0_fit = Z_a0_fit(:);
   Z_an_fit = ppval(equil_fit.Z_fit.pp_an,rho_fit1);
   Z_bn_fit = ppval(equil_fit.Z_fit.pp_bn,rho_fit1);
   Z_da0drho_fit = ppval(equil_fit.Z_fit.pp_da0drho,rho_fit1);Z_da0drho_fit = Z_da0drho_fit(:);
   Z_dandrho_fit = ppval(equil_fit.Z_fit.pp_dandrho,rho_fit1);
   Z_dbndrho_fit = ppval(equil_fit.Z_fit.pp_dbndrho,rho_fit1);
%
   BR_a0_fit = ppval(equil_fit.BR_fit.pp_a0,rho_fit1);BR_a0_fit = BR_a0_fit(:);
   BR_an_fit = ppval(equil_fit.BR_fit.pp_an,rho_fit1);
   BR_bn_fit = ppval(equil_fit.BR_fit.pp_bn,rho_fit1);
   BR_da0drho_fit = ppval(equil_fit.BR_fit.pp_da0drho,rho_fit1);BR_da0drho_fit = BR_da0drho_fit(:);
   BR_dandrho_fit = ppval(equil_fit.BR_fit.pp_dandrho,rho_fit1);
   BR_dbndrho_fit = ppval(equil_fit.BR_fit.pp_dbndrho,rho_fit1);
%
   BZ_a0_fit = ppval(equil_fit.BZ_fit.pp_a0,rho_fit1);BZ_a0_fit = BZ_a0_fit(:);
   BZ_an_fit = ppval(equil_fit.BZ_fit.pp_an,rho_fit1);
   BZ_bn_fit = ppval(equil_fit.BZ_fit.pp_bn,rho_fit1);
   BZ_da0drho_fit = ppval(equil_fit.BZ_fit.pp_da0drho,rho_fit1);BZ_da0drho_fit = BZ_da0drho_fit(:);
   BZ_dandrho_fit = ppval(equil_fit.BZ_fit.pp_dandrho,rho_fit1);
   BZ_dbndrho_fit = ppval(equil_fit.BZ_fit.pp_dbndrho,rho_fit1);
%
   BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,rho_fit1);BPHI_a0_fit = BPHI_a0_fit(:);
   BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,rho_fit1);
   BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,rho_fit1);
   BPHI_da0drho_fit = ppval(equil_fit.BPHI_fit.pp_da0drho,rho_fit1);BPHI_da0drho_fit = BPHI_da0drho_fit(:);
   BPHI_dandrho_fit = ppval(equil_fit.BPHI_fit.pp_dandrho,rho_fit1);
   BPHI_dbndrho_fit = ppval(equil_fit.BPHI_fit.pp_dbndrho,rho_fit1);
%
   R_a0_fit1 = ppval_yp(equil_fit.R_fit.pp_a0,rho_fit1);
   R_an_fit1 = ppval_yp(equil_fit.R_fit.pp_an,rho_fit1);
   R_bn_fit1 = ppval_yp(equil_fit.R_fit.pp_bn,rho_fit1);
   R_da0drho_fit1 = ppval_yp(equil_fit.R_fit.pp_da0drho,rho_fit1);
   R_dandrho_fit1 = ppval_yp(equil_fit.R_fit.pp_dandrho,rho_fit1);
   R_dbndrho_fit1 = ppval_yp(equil_fit.R_fit.pp_dbndrho,rho_fit1);
%
   Z_a0_fit1 = ppval_yp(equil_fit.Z_fit.pp_a0,rho_fit1);
   Z_an_fit1 = ppval_yp(equil_fit.Z_fit.pp_an,rho_fit1);
   Z_bn_fit1 = ppval_yp(equil_fit.Z_fit.pp_bn,rho_fit1);
   Z_da0drho_fit1 = ppval_yp(equil_fit.Z_fit.pp_da0drho,rho_fit1);
   Z_dandrho_fit1 = ppval_yp(equil_fit.Z_fit.pp_dandrho,rho_fit1);
   Z_dbndrho_fit1 = ppval_yp(equil_fit.Z_fit.pp_dbndrho,rho_fit1);
%
   BR_a0_fit1 = ppval_yp(equil_fit.BR_fit.pp_a0,rho_fit1);
   BR_an_fit1 = ppval_yp(equil_fit.BR_fit.pp_an,rho_fit1);
   BR_bn_fit1 = ppval_yp(equil_fit.BR_fit.pp_bn,rho_fit1);
   BR_da0drho_fit1 = ppval_yp(equil_fit.BR_fit.pp_da0drho,rho_fit1);
   BR_dandrho_fit1 = ppval_yp(equil_fit.BR_fit.pp_dandrho,rho_fit1);
   BR_dbndrho_fit1 = ppval_yp(equil_fit.BR_fit.pp_dbndrho,rho_fit1);
%
   BZ_a0_fit1 = ppval_yp(equil_fit.BZ_fit.pp_a0,rho_fit1);
   BZ_an_fit1 = ppval_yp(equil_fit.BZ_fit.pp_an,rho_fit1);
   BZ_bn_fit1 = ppval_yp(equil_fit.BZ_fit.pp_bn,rho_fit1);
   BZ_da0drho_fit1 = ppval_yp(equil_fit.BZ_fit.pp_da0drho,rho_fit1);
   BZ_dandrho_fit1 = ppval_yp(equil_fit.BZ_fit.pp_dandrho,rho_fit1);
   BZ_dbndrho_fit1 = ppval_yp(equil_fit.BZ_fit.pp_dbndrho,rho_fit1);
%
   BPHI_a0_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_a0,rho_fit1);
   BPHI_an_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_an,rho_fit1);
   BPHI_bn_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_bn,rho_fit1);
   BPHI_da0drho_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_da0drho,rho_fit1);
   BPHI_dandrho_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_dandrho,rho_fit1);
   BPHI_dbndrho_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_dbndrho,rho_fit1);
%
% Build interpolated quantities
%
   for ii = 1:ntheta_fit,
      R_fit(:,ii) = R_a0_fit + R_an_fit*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_bn_fit*sin(equil_fit.R_fit.n*theta_fit(ii));
      dRdtheta_fit(:,ii) = -R_an_fit*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta_fit(ii))) + R_bn_fit*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta_fit(ii)));
      d2Rdtheta2_fit(:,ii) = -R_an_fit*(equil_fit.R_fit.n.^2.*cos(equil_fit.R_fit.n*theta_fit(ii))) - R_bn_fit*(equil_fit.R_fit.n.^2.*sin(equil_fit.R_fit.n*theta_fit(ii)));
      dRdrho_fit(:,ii) = R_da0drho_fit + R_dandrho_fit*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_dbndrho_fit*sin(equil_fit.R_fit.n*theta_fit(ii));
      d2Rdthetadrho_fit(:,ii) = -R_dandrho_fit*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta_fit(ii))) + R_dbndrho_fit*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta_fit(ii)));
%
      Z_fit(:,ii) = Z_a0_fit + Z_an_fit*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_bn_fit*sin(equil_fit.Z_fit.n*theta_fit(ii));
      dZdtheta_fit(:,ii) = -Z_an_fit*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta_fit(ii))) + Z_bn_fit*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta_fit(ii)));
      d2Zdtheta2_fit(:,ii) = -Z_an_fit*(equil_fit.Z_fit.n.^2.*cos(equil_fit.Z_fit.n*theta_fit(ii))) - Z_bn_fit*(equil_fit.Z_fit.n.^2.*sin(equil_fit.Z_fit.n*theta_fit(ii)));
      dZdrho_fit(:,ii) = Z_da0drho_fit + Z_dandrho_fit*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_dbndrho_fit*sin(equil_fit.Z_fit.n*theta_fit(ii));
      d2Zdthetadrho_fit(:,ii) = -Z_dandrho_fit*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta_fit(ii))) + Z_dbndrho_fit*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta_fit(ii)));
%  
      r_fit(:,ii) = sqrt((R_fit(:,ii) - equil_fit.Rp).^2 + (Z_fit(:,ii) - equil_fit.Zp).^2);
      if (r_fit(1,ii) == 0), r_fit(1,ii) = prec; end
      drdtheta_fit(:,ii) = (dRdtheta_fit(:,ii).*(R_fit(:,ii) - equil_fit.Rp) + dZdtheta_fit(:,ii).*(Z_fit(:,ii) - equil_fit.Zp))./r_fit(:,ii);
      drdrho_fit(:,ii) = (dRdrho_fit(:,ii).*(R_fit(:,ii) - equil_fit.Rp) + dZdrho_fit(:,ii).*(Z_fit(:,ii) - equil_fit.Zp))./r_fit(:,ii);
%
      salpha_fit(:,ii) = ((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2);
      dsalphadtheta_fit(:,ii) = ...
         sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)./r_fit(:,ii) ...
         +((R_fit(:,ii) - equil_fit.Rp).*d2Rdtheta2_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*d2Zdtheta2_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
         -drdtheta_fit(:,ii).*((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii).^2./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
         -(dRdtheta_fit(:,ii).*d2Rdtheta2_fit(:,ii) + dZdtheta_fit(:,ii).*d2Zdtheta2_fit(:,ii)).*((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)./(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2);     
      dsalphadrho_fit(:,ii) = ...
        (dRdtheta_fit(:,ii).*dRdrho_fit(:,ii) + dZdtheta_fit(:,ii).*dZdrho_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)...
        +((R_fit(:,ii) - equil_fit.Rp).*d2Rdthetadrho_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*d2Zdthetadrho_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
        -drdrho_fit(:,ii).*((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii).^2./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
        -(dRdtheta_fit(:,ii).*d2Rdthetadrho_fit(:,ii) + dZdtheta_fit(:,ii).*d2Zdthetadrho_fit(:,ii)).*((R_fit(:,ii) - equil_fit.Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - equil_fit.Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)./(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2);
%
      calpha_fit(:,ii) = sqrt(1.0 - salpha_fit(:,ii).^2);
      if (calpha_fit(1,ii)== 0), calpha_fit(1,ii) = prec; end
      dcalphadtheta_fit(:,ii) = -salpha_fit(:,ii).*dsalphadtheta_fit(:,ii)./calpha_fit(:,ii);
      dcalphadrho_fit(:,ii) = -salpha_fit(:,ii).*dsalphadrho_fit(:,ii)./calpha_fit(:,ii);;
%
      BR_fit(:,ii) = BR_a0_fit + BR_an_fit*cos(equil_fit.BR_fit.n*theta_fit(ii)) + BR_bn_fit*sin(equil_fit.BR_fit.n*theta_fit(ii));
      dBRdtheta_fit(:,ii) = -BR_an_fit*(equil_fit.BR_fit.n.*sin(equil_fit.BR_fit.n*theta_fit(ii))) + BR_bn_fit*(equil_fit.BR_fit.n.*cos(equil_fit.BR_fit.n*theta_fit(ii)));
      dBRdrho_fit(:,ii) = BR_da0drho_fit + BR_dandrho_fit*cos(equil_fit.BR_fit.n*theta_fit(ii)) + BR_dbndrho_fit*sin(equil_fit.BR_fit.n*theta_fit(ii));
%
      BZ_fit(:,ii) = BZ_a0_fit + BZ_an_fit*cos(equil_fit.BZ_fit.n*theta_fit(ii)) + BZ_bn_fit*sin(equil_fit.BZ_fit.n*theta_fit(ii));
      dBZdtheta_fit(:,ii) = -BZ_an_fit*(equil_fit.BZ_fit.n.*sin(equil_fit.BZ_fit.n*theta_fit(ii))) + BZ_bn_fit*(equil_fit.BZ_fit.n.*cos(equil_fit.BZ_fit.n*theta_fit(ii)));
      dBZdrho_fit(:,ii) = BZ_da0drho_fit + BZ_dandrho_fit*cos(equil_fit.BZ_fit.n*theta_fit(ii)) + BZ_dbndrho_fit*sin(equil_fit.BZ_fit.n*theta_fit(ii));
%
      BPHI_fit(:,ii) = BPHI_a0_fit + BPHI_an_fit*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_bn_fit*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
      dBPHIdtheta_fit(:,ii) = -BPHI_an_fit*(equil_fit.BPHI_fit.n.*sin(equil_fit.BPHI_fit.n*theta_fit(ii))) + BPHI_bn_fit*(equil_fit.BPHI_fit.n.*cos(equil_fit.BPHI_fit.n*theta_fit(ii)));
      dBPHIdrho_fit(:,ii) = BPHI_da0drho_fit + BPHI_dandrho_fit*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_dbndrho_fit*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
%
      BP_fit(:,ii) = sqrt(BR_fit(:,ii).^2 + BZ_fit(:,ii).^2);
      dBPdtheta_fit(:,ii) = (BR_fit(:,ii).*dBRdtheta_fit(:,ii) + BZ_fit(:,ii).*dBZdtheta_fit(:,ii))./BP_fit(:,ii);
      dBPdrho_fit(:,ii) = (BR_fit(:,ii).*dBRdrho_fit(:,ii) + BZ_fit(:,ii).*dBZdrho_fit(:,ii))./BP_fit(:,ii);
%
      B_fit(:,ii) = sqrt(BR_fit(:,ii).^2 + BZ_fit(:,ii).^2 + BPHI_fit(:,ii).^2);
      dBdtheta_fit(:,ii) = (BR_fit(:,ii).*dBRdtheta_fit(:,ii) + BZ_fit(:,ii).*dBZdtheta_fit(:,ii) + BPHI_fit(:,ii).*dBPHIdtheta_fit(:,ii))./B_fit(:,ii);
      dBdrho_fit(:,ii) = (BR_fit(:,ii).*dBRdrho_fit(:,ii) + BZ_fit(:,ii).*dBZdrho_fit(:,ii) + BPHI_fit(:,ii).*dBPHIdrho_fit(:,ii))./B_fit(:,ii);
%      
      gradrho_fit(:,ii) = R_fit(:,ii).*BP_fit(:,ii).*dRstardpsin_fit/equil_fit.ap/equil_fit.psia;
      dgradrhodrho_fit(:,ii) = dRdrho_fit(:,ii).*BP_fit(:,ii).*dRstardpsin_fit/equil_fit.ap + R_fit(:,ii).*dBPdrho_fit(:,ii).*dRstardpsin_fit/equil_fit.ap + R_fit(:,ii).*BP_fit(:,ii).*ddRstardpsindrho_fit/equil_fit.ap/equil_fit.psia;
      dgradrhodtheta_fit(:,ii) = dRdtheta_fit(:,ii).*BP_fit(:,ii).*dRstardpsin_fit/equil_fit.ap + R_fit(:,ii).*dBPdtheta_fit(:,ii).*dRstardpsin_fit/equil_fit.ap/equil_fit.psia;     
%
      R_fit1(:,ii) = R_a0_fit1 + R_an_fit1*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_bn_fit1*sin(equil_fit.R_fit.n*theta_fit(ii));
      dRdtheta_fit1(:,ii) = -R_an_fit1*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta_fit(ii))) + R_bn_fit1*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta_fit(ii)));
      d2Rdtheta2_fit1(:,ii) = -R_an_fit1*(equil_fit.R_fit.n.^2.*cos(equil_fit.R_fit.n*theta_fit(ii))) - R_bn_fit1*(equil_fit.R_fit.n.^2.*sin(equil_fit.R_fit.n*theta_fit(ii)));
      dRdrho_fit1(:,ii) = R_da0drho_fit1 + R_dandrho_fit1*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_dbndrho_fit1*sin(equil_fit.R_fit.n*theta_fit(ii));
      d2Rdthetadrho_fit1(:,ii) = -R_dandrho_fit1*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta_fit(ii))) + R_dbndrho_fit1*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta_fit(ii)));
%
      Z_fit1(:,ii) = Z_a0_fit1 + Z_an_fit1*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_bn_fit1*sin(equil_fit.Z_fit.n*theta_fit(ii));
      dZdtheta_fit1(:,ii) = -Z_an_fit1*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta_fit(ii))) + Z_bn_fit1*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta_fit(ii)));
      d2Zdtheta2_fit1(:,ii) = -Z_an_fit1*(equil_fit.Z_fit.n.^2.*cos(equil_fit.Z_fit.n*theta_fit(ii))) - Z_bn_fit1*(equil_fit.Z_fit.n.^2.*sin(equil_fit.Z_fit.n*theta_fit(ii)));
      dZdrho_fit1(:,ii) = Z_da0drho_fit1 + Z_dandrho_fit1*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_dbndrho_fit1*sin(equil_fit.Z_fit.n*theta_fit(ii));
      d2Zdthetadrho_fit1(:,ii) = -Z_dandrho_fit1*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta_fit(ii))) + Z_dbndrho_fit1*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta_fit(ii)));
%
      r_fit1(:,ii) = sqrt((R_fit1(:,ii) - equil_fit.Rp).^2 + (Z_fit1(:,ii) - equil_fit.Zp).^2);
      if (r_fit1(1,ii) == 0), r_fit1(1,ii) = prec; end
      drdtheta_fit1(:,ii) = (dRdtheta_fit1(:,ii).*(R_fit1(:,ii) - equil_fit.Rp) + dZdtheta_fit1(:,ii).*(Z_fit(:,ii) - equil_fit.Zp))./r_fit1(:,ii);
      drdrho_fit1(:,ii) = (dRdrho_fit1(:,ii).*(R_fit1(:,ii) - equil_fit.Rp) + dZdrho_fit1(:,ii).*(Z_fit(:,ii) - equil_fit.Zp))./r_fit1(:,ii);
%
      salpha_fit1(:,ii) = ((R_fit1(:,ii) - equil_fit.Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - equil_fit.Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii)./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2);
      dsalphadtheta_fit1(:,ii) = ...
      sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2)./r_fit1(:,ii) ...
      + ((R_fit1(:,ii) - equil_fit.Rp).*d2Rdtheta2_fit1(:,ii) + (Z_fit1(:,ii) - equil_fit.Zp).*d2Zdtheta2_fit1(:,ii))./r_fit1(:,ii)./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2) ...
      -drdtheta_fit1(:,ii).*((R_fit1(:,ii) - equil_fit.Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - equil_fit.Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii).^2./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2) ...
      -(dRdtheta_fit1(:,ii).*d2Rdtheta2_fit1(:,ii) + dZdtheta_fit1(:,ii).*d2Zdtheta2_fit1(:,ii)).*((R_fit1(:,ii) - equil_fit.Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - equil_fit.Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii)./(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2).^(3/2);
      dsalphadtheta_fit1(1,ii) = dsalphadtheta_fit1(2,ii);
      dsalphadrho_fit1(:,ii) = ...
       (dRdtheta_fit1(:,ii).*dRdrho_fit1(:,ii) + dZdtheta_fit1(:,ii).*dZdrho_fit1(:,ii))./r_fit1(:,ii)./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2)...
      + ((R_fit1(:,ii) - equil_fit.Rp).*d2Rdthetadrho_fit1(:,ii) + (Z_fit1(:,ii) - equil_fit.Zp).*d2Zdthetadrho_fit1(:,ii))./r_fit1(:,ii)./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2) ...
      -drdrho_fit1(:,ii).*((R_fit1(:,ii) - equil_fit.Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - equil_fit.Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii).^2./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2) ...
      -(dRdtheta_fit1(:,ii).*d2Rdthetadrho_fit1(:,ii) + dZdtheta_fit1(:,ii).*d2Zdthetadrho_fit1(:,ii)).*((R_fit1(:,ii) - equil_fit.Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - equil_fit.Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii)./(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2).^(3/2);
      dsalphadrho_fit1(1,ii) = dsalphadrho_fit1(2,ii);
%
      calpha_fit1(:,ii) = sqrt(1.0 - salpha_fit1(:,ii).^2);
      if (calpha_fit1(1,ii) == 0), calpha_fit1(1,ii) = prec; end
      dcalphadtheta_fit1(:,ii) = -salpha_fit1(:,ii).*dsalphadtheta_fit1(:,ii)./calpha_fit1(:,ii);
      dcalphadrho_fit1(:,ii) = -salpha_fit1(:,ii).*dsalphadrho_fit1(:,ii)./calpha_fit1(:,ii);;
%
      BR_fit1(:,ii) = BR_a0_fit1 + BR_an_fit1*cos(equil_fit.BR_fit.n*theta_fit(ii)) + BR_bn_fit1*sin(equil_fit.BR_fit.n*theta_fit(ii));
      dBRdtheta_fit1(:,ii) = -BR_an_fit1*(equil_fit.BR_fit.n.*sin(equil_fit.BR_fit.n*theta_fit(ii))) + BR_bn_fit1*(equil_fit.BR_fit.n.*cos(equil_fit.BR_fit.n*theta_fit(ii)));
      dBRdrho_fit1(:,ii) = BR_da0drho_fit1 + BR_dandrho_fit1*cos(equil_fit.BR_fit.n*theta_fit(ii)) + BR_dbndrho_fit1*sin(equil_fit.BR_fit.n*theta_fit(ii));
%
      BZ_fit1(:,ii) = BZ_a0_fit1 + BZ_an_fit1*cos(equil_fit.BZ_fit.n*theta_fit(ii)) + BZ_bn_fit1*sin(equil_fit.BZ_fit.n*theta_fit(ii));
      dBZdtheta_fit1(:,ii) = -BZ_an_fit1*(equil_fit.BZ_fit.n.*sin(equil_fit.BZ_fit.n*theta_fit(ii))) + BZ_bn_fit1*(equil_fit.BZ_fit.n.*cos(equil_fit.BZ_fit.n*theta_fit(ii)));
      dBZdrho_fit1(:,ii) = BZ_da0drho_fit1 + BZ_dandrho_fit1*cos(equil_fit.BZ_fit.n*theta_fit(ii)) + BZ_dbndrho_fit1*sin(equil_fit.BZ_fit.n*theta_fit(ii));
%
      BPHI_fit1(:,ii) = BPHI_a0_fit1 + BPHI_an_fit1*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_bn_fit1*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
      dBPHIdtheta_fit1(:,ii) = -BPHI_an_fit1*(equil_fit.BPHI_fit.n.*sin(equil_fit.BPHI_fit.n*theta_fit(ii))) + BPHI_bn_fit1*(equil_fit.BPHI_fit.n.*cos(equil_fit.BPHI_fit.n*theta_fit(ii)));
      dBPHIdrho_fit1(:,ii) = BPHI_da0drho_fit1 + BPHI_dandrho_fit1*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_dbndrho_fit1*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
%
      BP_fit1(:,ii) = sqrt(BR_fit1(:,ii).^2 + BZ_fit1(:,ii).^2);
      dBPdtheta_fit1(:,ii) = (BR_fit1(:,ii).*dBRdtheta_fit1(:,ii) + BZ_fit1(:,ii).*dBZdtheta_fit1(:,ii))./BP_fit1(:,ii);
      dBPdrho_fit1(:,ii) = (BR_fit1(:,ii).*dBRdrho_fit1(:,ii) + BZ_fit1(:,ii).*dBZdrho_fit1(:,ii))./BP_fit1(:,ii);
%
      B_fit1(:,ii) = sqrt(BR_fit1(:,ii).^2 + BZ_fit1(:,ii).^2 + BPHI_fit1(:,ii).^2);
      dBdtheta_fit1(:,ii) = (BR_fit1(:,ii).*dBRdtheta_fit1(:,ii) + BZ_fit1(:,ii).*dBZdtheta_fit1(:,ii) + BPHI_fit1(:,ii).*dBPHIdtheta_fit1(:,ii))./B_fit1(:,ii);
      dBdrho_fit1(:,ii) = (BR_fit1(:,ii).*dBRdrho_fit1(:,ii) + BZ_fit1(:,ii).*dBZdrho_fit1(:,ii) + BPHI_fit1(:,ii).*dBPHIdrho_fit1(:,ii))./B_fit1(:,ii);
%
      gradrho_fit1(:,ii) = R_fit1(:,ii).*BP_fit1(:,ii).*dRstardpsin_fit1/equil_fit.ap/equil_fit.psia;
      dgradrhodrho_fit1(:,ii) = dRdrho_fit1(:,ii).*BP_fit1(:,ii).*dRstardpsin_fit1/equil_fit.ap + R_fit1(:,ii).*dBPdrho_fit1(:,ii).*dRstardpsin_fit1/equil_fit.ap + R_fit1(:,ii).*BP_fit1(:,ii).*ddRstardpsindrho_fit1/equil_fit.ap/equil_fit.psia;
      dgradrhodtheta_fit1(:,ii) = dRdtheta_fit1(:,ii).*BP_fit1(:,ii).*dRstardpsin_fit1/equil_fit.ap + R_fit1(:,ii).*dBPdtheta_fit1(:,ii).*dRstardpsin_fit1/equil_fit.ap/equil_fit.psia;
   end
%
% Display results
%
   figure('Name','Magnetic equilibrium profile parameters'),clf
   set(gcf,'units','inches','position',[0.5,1,10,6]);
   set(gca,'position',[0,0,1,1]);
%
   subplot('position',[1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,psin_fit,0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,psin_fit1,0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),ppsin(1:10:end),0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'--','non','r',1);
   subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,Te_fit,0,0,'\psi','T_e (keV)',equil_in.id,NaN,[0,1],[-eps,max(equil_in.pTe)],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,Te_fit1,0,0,'\psi','T_e (keV)',equil_in.id,NaN,[0,1],[-eps,max(equil_in.pTe)],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),pTe(1:10:end),0,0,'\rho','T_e (keV)',equil_in.id,NaN,[0,1],[-eps,max(equil_in.pTe)],'--','non','r',1);
   subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,ne_fit/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_in.pne/1e19)],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,ne_fit1/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_in.pne/1e19)],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),pne(1:10:end)/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_in.pne/1e19)],'--','non','r',1);
   subplot('position',[1/12,1/8,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,zTi_fit,0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_in.pzTi))],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,zTi_fit1,0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_in.pzTi))],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),pzTi(1:10:end,:),0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_in.pzTi))],'--','non','r',1);
   subplot('position',[1/3+1/12,1/8,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,zni_fit/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_in.pzni/1e19))],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,zni_fit1/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_in.pzni/1e19))],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),pzni(1:10:end,:)/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_in.pzni/1e19))],'--','non','r',1);
   subplot('position',[2/3+1/12,1/8,5/24,5/16])
%
   figure('Name','Derivatives of magnetic equilibrium profile parameters'),clf
   set(gcf,'units','inches','position',[0.5,1,10,6]);
   set(gca,'position',[0,0,1,1]);
%
   subplot('position',[1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,dpsindrho_fit,0,0,'\rho','d\psi_nd/\rho','',NaN,[0,1],[-eps,1],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,dpsindrho_fit1,0,0,'\rho','d\psi_nd/\rho','',NaN,[0,1],[-eps,1],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),dpsindrho(1:10:end),0,0,'\rho','d\psi_nd/\rho','',NaN,[0,1],[-eps,1],'--','non','r',1);
   subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,dTedrho_fit,0,0,'\rho','T_e (keV)',equil_in.id,NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,dTedrho_fit1,0,0,'\rho','T_e (keV)',equil_in.id,NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),dTedrho(1:10:end),0,0,'\rho','dT_ed/\rho (keV)',equil_in.id,NaN,NaN,NaN,'--','non','r',1);
   subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,dnedrho_fit/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,dnedrho_fit1/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),dnedrho(1:10:end)/1e19,0,0,'\rho','dn_e/d\rho (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
   subplot('position',[1/12,1/8,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,zdTidrho_fit,0,0,'\rho','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,zdTidrho_fit1,0,0,'\rho','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),zdTidrho(1:10:end,:),0,0,'\rho','dT_i/d\rho (keV)','',NaN,NaN,NaN,'--','non','r',1);
   subplot('position',[1/3+1/12,1/8,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,zdnidrho_fit/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,zdnidrho_fit1/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),zdnidrho(1:10:end,:)/1e19,0,0,'\rho','dn_i/d\rho (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
   subplot('position',[2/3+1/12,1/8,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,zdnidrho_fit/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','b',2); 
%
% Magnetic equilibrium coordinates
%
   figure('Name','R coordinate'),
   [ax] = graph1D_jd(theta_fit,R_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,R_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),equil_in.R(1:10:end,1:2:end),0,0,'\theta (rd)','R (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dR/dtheta'),
   [ax] = graph1D_jd(theta_fit,dRdtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dRdtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dRdtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dR/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dR/drho'),
   [ax] = graph1D_jd(theta_fit,dRdrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dRdrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dRdrho(1:10:end,1:2:end),0,0,'\theta','dR/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','Z coordinate'),
   [ax] = graph1D_jd(theta_fit,Z_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,Z_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),equil_in.Z(1:10:end,1:2:end),0,0,'\theta (rd)','Z (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dZ/dtheta'),
   [ax] = graph1D_jd(theta_fit,dZdtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dZdtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dZdtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dZ/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dZ/drho'),
   [ax] = graph1D_jd(theta_fit,dZdrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dZdrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dZdrho(1:10:end,1:2:end),0,0,'\rho','dZ/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
% Magnetic equilibrium quantities 
%
   figure('Name','r position'),
   [ax] = graph1D_jd(theta_fit,r_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,r_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),r(1:10:end,1:2:end),0,0,'\theta (rd)','r (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dr/dtheta'),
   [ax] = graph1D_jd(theta_fit,drdtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,drdtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),drdtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dr/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dr/drho'),
   [ax] = graph1D_jd(theta_fit,drdrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,drdrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),drdrho(1:10:end,1:2:end),0,0,'\rho','dr/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','cos(alpha)'),
   [ax] = graph1D_jd(theta_fit,calpha_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,calpha_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),calpha(1:10:end,1:2:end),0,0,'\theta (rd)','cos(\alpha)','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dcos(alpha)/dtheta'),
   [ax] = graph1D_jd(theta_fit,dcalphadtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dcalphadtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dcalphadtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dcos(\alpha)/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dcos(alpha)/drho'),
   [ax] = graph1D_jd(theta_fit,dcalphadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dcalphadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dcalphadrho(1:10:end,1:2:end),0,0,'\rho','dcos(\alpha)/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
   figure('Name','sin(alpha)'),
   [ax] = graph1D_jd(theta_fit,salpha_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,salpha_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),salpha(1:10:end,1:2:end),0,0,'\theta (rd)','sin(\alpha)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dsin(alpha)/dtheta'),
   [ax] = graph1D_jd(theta_fit,dsalphadtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dsalphadtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dsalphadtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dsin(\alpha)/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dsin(alpha)/drho'),
   [ax] = graph1D_jd(theta_fit,dsalphadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dsalphadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dsalphadrho(1:10:end,1:2:end),0,0,'\rho','dsin(\alpha)/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','cos^2(alpha)+sin^2(alpha)'),
   [ax] = graph1D_jd(theta_fit,salpha_fit.^2 + calpha_fit.^2,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),salpha(1:10:end,1:2:end).^2 + calpha(1:10:end,1:2:end).^2,0,0,'\theta (rd)','cos^2(\alpha)+sin^2(\alpha)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','gradrho'),
   [ax] = graph1D_jd(theta_fit,gradrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,gradrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),gradrho(1:10:end,1:2:end),0,0,'\theta (rd)','gradrho','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dgradrho/dtheta'),
   [ax] = graph1D_jd(theta_fit,dgradrhodtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dgradrhodtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dgradrhodtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dgradrho/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dgradrho/drho'),
   [ax] = graph1D_jd(theta_fit,dgradrhodrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dgradrhodrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dgradrhodrho(1:10:end,1:2:end),0,0,'\rho','dgradrho/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
%Magnetic fields
%
   figure('Name','Toroidal magnetic field BPHI'),
   [ax] = graph1D_jd(theta_fit,BPHI_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,BPHI_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),equil_in.BPHI(1:10:end,1:2:end),0,0,'\theta (rd)','B_{\phi} (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dBPHI/dtheta'),
   [ax] = graph1D_jd(theta_fit,dBPHIdtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBPHIdtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBPHIdtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dBPHI/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dBPHI/drho'),
   [ax] = graph1D_jd(theta_fit,dBPHIdrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBPHIdrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBPHIdrho(1:10:end,1:2:end),0,0,'\psi_{n}','dBPHI/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','Poloidal magnetic field BP'),
   [ax] = graph1D_jd(theta_fit,BP_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,BP_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),BP(1:10:end,1:2:end),0,0,'\theta (rd)','B_P (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dBP/dtheta'),
   [ax] = graph1D_jd(theta_fit,dBPdtheta_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBPdtheta_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBPdtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dB_P/d\theta (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dBP/drho'),
   [ax] = graph1D_jd(theta_fit,dBPdrho_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBPdrho_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBPdrho(1:10:end,1:2:end),0,0,'\theta (rd)','dB_P/d\rho (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','Total magnetic field'),
   [ax] = graph1D_jd(theta_fit,B_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,B_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),B(1:10:end,1:2:end),0,0,'\theta (rd)','B (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dB/dtheta'),
   [ax] = graph1D_jd(theta_fit,dBdtheta_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBdtheta_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBdtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dB/d\theta (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dB/drho'),
   [ax] = graph1D_jd(theta_fit,dBdrho_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBdrho_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBdrho(1:10:end,1:2:end),0,0,'\theta (rd)','dB/d\rho (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   Rmin = min(min(equil_in.R));
   Rmax = max(max(equil_in.R));
   Zmin = min(min(equil_in.Z));
   Zmax = max(max(equil_in.Z));
%
   figure('Name','Magnetic equilibrium flux surface contour')
% 
   [ax] = graph1D_jd(equil_in.R(1:10:end,1:2:end),equil_in.Z(1:10:end,1:2:end),0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);drawnow
   [ax] = graph1D_jd(equil_in.R(1:10:end,:)',equil_in.Z(1:10:end,:)',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);
%
   [ax] = graph1D_jd(R_fit(1:10:end,1:2:end),Z_fit(1:10:end,1:2:end),0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
   [ax] = graph1D_jd(R_fit(:,:)',Z_fit(:,:)',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);
%
   [ax] = graph1D_jd(R_fit1(1:10:end,1:2:end),Z_fit1(1:10:end,1:2:end),0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','c',1);drawnow
   [ax] = graph1D_jd(R_fit1(:,:)',Z_fit1(:,:)',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','c',1);
   axis('equal');drawnow  
%
end
%
psin = ppval(equil_fit.psin_fit.pp_f,rho);
dpsindrho = ppval(equil_fit.psin_fit.pp_dfdrho,rho);
dRstardpsin = ppval(equil_fit.dRstardpsin_fit.pp_f,rho);
ddRstardpsindrho = ppval(equil_fit.dRstardpsin_fit.pp_dfdrho,rho);
Te = ppval(equil_fit.Te_fit.pp_f,rho);
dTedrho = ppval_yp(equil_fit.Te_fit.pp_dfdrho,rho);
ne = ppval(equil_fit.ne_fit.pp_f,rho);
dnedrho = ppval_yp(equil_fit.ne_fit.pp_dfdrho,rho);
zTi = ppval(equil_fit.zTi_fit.pp_f,rho);
dzTidrho = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,rho);
zni = ppval(equil_fit.zni_fit.pp_f,rho);
dznidrho = ppval_yp(equil_fit.zni_fit.pp_dfdrho,rho);
%
R_a0 = ppval(equil_fit.R_fit.pp_a0,rho);
R_an = ppval(equil_fit.R_fit.pp_an,rho);
R_bn = ppval(equil_fit.R_fit.pp_bn,rho);
R_da0drho = ppval(equil_fit.R_fit.pp_da0drho,rho);
R_dandrho = ppval(equil_fit.R_fit.pp_dandrho,rho);
R_dbndrho = ppval(equil_fit.R_fit.pp_dbndrho,rho);
R = R_a0 + R_an'*cos(equil_fit.R_fit.n*theta) + R_bn'*sin(equil_fit.R_fit.n*theta);
dRdtheta = -R_an'*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta)) + R_bn'*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta));
d2Rdtheta2 = -R_an'*(equil_fit.R_fit.n.^2.*cos(equil_fit.R_fit.n*theta)) - R_bn'*(equil_fit.R_fit.n.^2.*sin(equil_fit.R_fit.n*theta));
dRdrho = R_da0drho + R_dandrho'*cos(equil_fit.R_fit.n*theta) + R_dbndrho'*sin(equil_fit.R_fit.n*theta);
d2Rdthetadrho = -R_dandrho'*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta)) + R_dbndrho'*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta));
%
Z_a0 = ppval(equil_fit.Z_fit.pp_a0,rho);
Z_an = ppval(equil_fit.Z_fit.pp_an,rho);
Z_bn = ppval(equil_fit.Z_fit.pp_bn,rho);
Z_da0drho = ppval(equil_fit.Z_fit.pp_da0drho,rho);
Z_dandrho = ppval(equil_fit.Z_fit.pp_dandrho,rho);
Z_dbndrho = ppval(equil_fit.Z_fit.pp_dbndrho,rho);
Z = Z_a0 + Z_an'*cos(equil_fit.Z_fit.n*theta) + Z_bn'*sin(equil_fit.Z_fit.n*theta);
dZdtheta = -Z_an'*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta)) + Z_bn'*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta));
d2Zdtheta2 = -Z_an'*(equil_fit.Z_fit.n.^2.*cos(equil_fit.Z_fit.n*theta)) - Z_bn'*(equil_fit.Z_fit.n.^2.*sin(equil_fit.Z_fit.n*theta));
dZdrho = Z_da0drho + Z_dandrho'*cos(equil_fit.Z_fit.n*theta) + Z_dbndrho'*sin(equil_fit.Z_fit.n*theta);
d2Zdthetadrho = -Z_dandrho'*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta)) + Z_dbndrho'*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta));
%
r = sqrt((R - equil_fit.Rp).^2 + (Z - equil_fit.Zp).^2);
drdtheta = (dRdtheta.*(R - equil_fit.Rp) + dZdtheta.*(Z - equil_fit.Zp))./r;
drdrho = (dRdrho.*(R - equil_fit.Rp) + dZdrho.*(Z - equil_fit.Zp))./r;
%
salpha = ((R - equil_fit.Rp).*dRdtheta + (Z - equil_fit.Zp).*dZdtheta)./r./sqrt(dRdtheta.^2 + dZdtheta.^2);
dsalphadtheta = ...
   sqrt(dRdtheta.^2 + dZdtheta.^2)./r ...
   + ((R - equil_fit.Rp).*d2Rdtheta2 + (Z - equil_fit.Zp).*d2Zdtheta2)./r./sqrt(dRdtheta.^2 + dZdtheta.^2) ...
   -drdtheta.*((R - equil_fit.Rp).*dRdtheta + (Z - equil_fit.Zp).*dZdtheta)./r.^2./sqrt(dRdtheta.^2 + dZdtheta.^2) ...
   -(dRdtheta.*d2Rdtheta2 + dZdtheta.*d2Zdtheta2).*((R - equil_fit.Rp).*dRdtheta + (Z - equil_fit.Zp).*dZdtheta)./r./sqrt(dRdtheta.^2 + dZdtheta.^2)./(dRdtheta.^2 + dZdtheta.^2);
dsalphadrho = ...
   (dRdtheta.*dRdrho + dZdtheta.*dZdrho)./r./sqrt(dRdtheta.^2 + dZdtheta.^2)...
   + ((R - equil_fit.Rp).*d2Rdthetadrho + (Z - equil_fit.Zp).*d2Zdthetadrho)./r./sqrt(dRdtheta.^2 + dZdtheta.^2) ...
   -drdrho.*((R - equil_fit.Rp).*dRdtheta + (Z - equil_fit.Zp).*dZdtheta)./r.^2./sqrt(dRdtheta.^2 + dZdtheta.^2) ...
   -(dRdtheta.*d2Rdthetadrho + dZdtheta.*d2Zdthetadrho).*((R - equil_fit.Rp).*dRdtheta + (Z - equil_fit.Zp).*dZdtheta)./r./sqrt(dRdtheta.^2 + dZdtheta.^2)./(dRdtheta.^2 + dZdtheta.^2);
%
calpha = sqrt(1.0 - salpha.^2);
dcalphadtheta = -salpha.*dsalphadtheta./calpha;
dcalphadrho = -salpha.*dsalphadrho./calpha;
%
BR_a0 = ppval(equil_fit.BR_fit.pp_a0,rho);
BR_an = ppval(equil_fit.BR_fit.pp_an,rho);
BR_bn = ppval(equil_fit.BR_fit.pp_bn,rho);
BR_da0drho = ppval(equil_fit.BR_fit.pp_da0drho,rho);
BR_dandrho = ppval(equil_fit.BR_fit.pp_dandrho,rho);
BR_dbndrho = ppval(equil_fit.BR_fit.pp_dbndrho,rho);
BR = BR_a0 + BR_an'*cos(equil_fit.BR_fit.n*theta) + BR_bn'*sin(equil_fit.BR_fit.n*theta);
dBRdtheta = -BR_an'*(equil_fit.BR_fit.n.*sin(equil_fit.BR_fit.n*theta)) + BR_bn'*(equil_fit.BR_fit.n.*cos(equil_fit.BR_fit.n*theta));
dBRdrho = BR_da0drho + BR_dandrho'*cos(equil_fit.BR_fit.n*theta) + BR_dbndrho'*sin(equil_fit.BR_fit.n*theta);
%
BZ_a0 = ppval(equil_fit.BZ_fit.pp_a0,rho);
BZ_an = ppval(equil_fit.BZ_fit.pp_an,rho);
BZ_bn = ppval(equil_fit.BZ_fit.pp_bn,rho);
BZ_da0drho = ppval(equil_fit.BZ_fit.pp_da0drho,rho);
BZ_dandrho = ppval(equil_fit.BZ_fit.pp_dandrho,rho);
BZ_dbndrho = ppval(equil_fit.BZ_fit.pp_dbndrho,rho);
BZ = BZ_a0 + BZ_an'*cos(equil_fit.BZ_fit.n*theta) + BZ_bn'*sin(equil_fit.BZ_fit.n*theta);
dBZdtheta = -BZ_an'*(equil_fit.BZ_fit.n.*sin(equil_fit.BZ_fit.n*theta)) + BZ_bn'*(equil_fit.BZ_fit.n.*cos(equil_fit.BZ_fit.n*theta));
dBZdrho = BZ_da0drho + BZ_dandrho'*cos(equil_fit.BZ_fit.n*theta) + BZ_dbndrho'*sin(equil_fit.BZ_fit.n*theta);
%
BPHI_a0 = ppval(equil_fit.BPHI_fit.pp_a0,rho);
BPHI_an = ppval(equil_fit.BPHI_fit.pp_an,rho);
BPHI_bn = ppval(equil_fit.BPHI_fit.pp_bn,rho);
BPHI_da0drho = ppval(equil_fit.BPHI_fit.pp_da0drho,rho);
BPHI_dandrho = ppval(equil_fit.BPHI_fit.pp_dandrho,rho);
BPHI_dbndrho = ppval(equil_fit.BPHI_fit.pp_dbndrho,rho);
BPHI = BPHI_a0 + BPHI_an'*cos(equil_fit.BPHI_fit.n*theta) + BPHI_bn'*sin(equil_fit.BPHI_fit.n*theta);
dBPHIdtheta = -BPHI_an'*(equil_fit.BPHI_fit.n.*sin(equil_fit.BPHI_fit.n*theta)) + BPHI_bn'*(equil_fit.BPHI_fit.n.*cos(equil_fit.BPHI_fit.n*theta));
dBPHIdrho = BPHI_da0drho + BPHI_dandrho'*cos(equil_fit.BPHI_fit.n*theta) + BPHI_dbndrho'*sin(equil_fit.BPHI_fit.n*theta);
%
BP = sqrt(BR^2 + BZ^2);
dBPdtheta = (BR*dBRdtheta + BZ*dBZdtheta)/BP;
dBPdrho = (BR*dBRdrho + BZ*dBZdrho)/BP;
%
B = sqrt(BR^2 + BZ^2 + BPHI^2);
dBdtheta = (BR*dBRdtheta + BZ*dBZdtheta + BPHI*dBPHIdtheta)/B;
dBdrho = (BR*dBRdrho + BZ*dBZdrho + BPHI*dBPHIdrho)/B;
%
gradrho = R.*BP.*dRstardpsin/equil_fit.ap/equil_fit.psia;
dgradrhodrho = dRdrho.*BP.*dRstardpsin/equil_fit.psia/equil_fit.ap + R.*dBPdrho.*dRstardpsin/equil_fit.psia/equil_fit.ap + R.*BP.*ddRstardpsindrho/equil_fit.psia/equil_fit.ap;
dgradrhodtheta = dRdtheta.*BP.*dRstardpsin/equil_fit.psia/equil_fit.ap + R.*dBPdtheta.*dRstardpsin/equil_fit.psia/equil_fit.ap;
%
disp(['equil_fit.zZi(4) = ',num2str(equil_fit.zZi(4))]);
disp('--------------');
disp(['equil_fit.Te_fit.pp_f.coefs(1) = ',num2str(equil_fit.Te_fit.pp_f.coefs(1))]);
disp(['equil_fit.Te_fit.pp_dfdrho.coefs(1) = ',num2str(equil_fit.Te_fit.pp_dfdrho.coefs(1))]);
disp(['equil_fit.BPHI_fit.n = ',num2str(equil_fit.BPHI_fit.n(1))]);
disp(['equil_fit.BPHI_fit.bn_f.coefs(1) = ',num2str(equil_fit.BPHI_fit.pp_bn.coefs(1))]);
disp(['equil_fit.BPHI_fit.bn_f.coefs(1) = ',num2str(equil_fit.BPHI_fit.pp_dbndrho.coefs(1))]);
disp('--------------');
disp(['Te(',num2str(rho),'),dTedrho(',num2str(rho),') (keV) = ',num2str(Te),',',num2str(dTedrho)]);
disp(['ne(',num2str(rho),'),dnedrho(',num2str(rho),') (10+19 m-3) = ',num2str(ne/1e19),',',num2str(dnedrho/1e19)]);
disp(['zTi(2,',num2str(rho),'),dzTidrho(2,',num2str(rho),') (keV) = ',num2str(zTi(2)),',',num2str(dzTidrho(2))]);
disp(['zni(2,',num2str(rho),'),dznidrho(2,',num2str(rho),') (10+19 m-3) = ',num2str(zni(2)/1e19),',',num2str(dznidrho(2)/1e19)]);
disp(['R(',num2str(rho),',',num2str(theta),'),dRdrho(',num2str(rho),',',num2str(theta),'),dRdtheta(',num2str(rho),',',num2str(theta),'),d2Rdtheta2(',num2str(rho),',',num2str(theta),'),d2Rdthetadrho(',num2str(rho),',',num2str(theta),') (m) = ',num2str(R),',',num2str(dRdrho),',',num2str(dRdtheta),',',num2str(d2Rdtheta2),',',num2str(d2Rdthetadrho)]);
disp(['Z(',num2str(rho),',',num2str(theta),'),dZdrho(',num2str(rho),',',num2str(theta),'),dZdtheta(',num2str(rho),',',num2str(theta),'),d2Zdtheta2(',num2str(rho),',',num2str(theta),'),d2Zdthetadrho(',num2str(rho),',',num2str(theta),') (m) = ',num2str(Z),',',num2str(dZdrho),',',num2str(dZdtheta),',',num2str(d2Zdtheta2),',',num2str(d2Zdthetadrho)]);
disp(['r(',num2str(rho),',',num2str(theta),'),drdrho(',num2str(rho),',',num2str(theta),'),drdtheta(',num2str(rho),',',num2str(theta),') (m) = ',num2str(r),',',num2str(drdrho),',',num2str(drdtheta)]);
disp(['BR(',num2str(rho),',',num2str(theta),'),dBRdrho(',num2str(rho),',',num2str(theta),'),dBRdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(BR),',',num2str(dBRdrho),',',num2str(dBRdtheta)]);
disp(['BZ(',num2str(rho),',',num2str(theta),'),dBZdrho(',num2str(rho),',',num2str(theta),'),dBZdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(BZ),',',num2str(dBZdrho),',',num2str(dBZdtheta)]);
disp(['BPHI(',num2str(rho),',',num2str(theta),'),dBPHIdrho(',num2str(rho),',',num2str(theta),'),dBPHIdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(BPHI),',',num2str(dBPHIdrho),',',num2str(dBPHIdtheta)]);
disp(['BP(',num2str(rho),',',num2str(theta),'),dBPdrho(',num2str(rho),',',num2str(theta),'),dBPdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(BP),',',num2str(dBPdrho),',',num2str(dBPdtheta)]);
disp(['B(',num2str(rho),',',num2str(theta),'),dBdrho(',num2str(rho),',',num2str(theta),'),dBdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(B),',',num2str(dBdrho),',',num2str(dBdtheta)]);
disp(['calpha(',num2str(rho),',',num2str(theta),'),dcalphadrho(',num2str(rho),',',num2str(theta),'),dcalphadtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(calpha),',',num2str(dcalphadrho),',',num2str(dcalphadtheta)]);
disp(['salpha(',num2str(rho),',',num2str(theta),'),dsalphadrho(',num2str(rho),',',num2str(theta),'),dsalphadtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(salpha),',',num2str(dsalphadrho),',',num2str(dsalphadtheta)]);
disp(['gradrho(',num2str(rho),',',num2str(theta),'),dgradrhodrho(',num2str(rho),',',num2str(theta),'),dgradrhodtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(gradrho),',',num2str(dgradrhodrho),',',num2str(dgradrhodtheta)]);


