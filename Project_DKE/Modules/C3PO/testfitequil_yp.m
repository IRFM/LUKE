function [R,Z] = testfitequil_yp(equil_in,equil_fit,rho,theta,ns)
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
%    - ns: number of species [1,1]
%      (default = 2)
%
% OUTPUT: (size(rho)=size(theta)=(1,1) only)
%    - R: Major axis position [1,1]
%    - Z: Vertical axis position [1,1]
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 3,% Output for comparison with C raytracing_yp.c
   rho = 0.25;
   theta = 0.2;
   ns = 2;
end
if nargin < 4,% Output for comparison with C raytracing_yp.c
   theta = 0.2;
   ns = 2;
end
if nargin < 5,
   ns = 2;
end
%
R = [];
Z = [];
%
prec = 1e-3;
%
psin = equil_in.psi_apRp/equil_in.psi_apRp(end);
[prho] = psi2rho_jd(equil_in,psin,'spline');
dpsin = gradient(psin(:));
d2psin = gradient(dpsin(:));
dprho = gradient(prho(:));
dtheta = gradient(equil_in.theta);
%
pTe = equil_in.pTe(:);
pne = equil_in.pne(:);
pzTi = equil_in.pzTi';
pzni = equil_in.pzni';
%
BR = equil_in.ptBx + eps;
BZ = equil_in.ptBy + eps;
BPHI = equil_in.ptBPHI;
%
Rp = equil_in.Rp;
Zp = equil_in.Zp;
R = equil_in.ptx + Rp;
Z = equil_in.pty + Zp;
%
BP = sqrt(BR.^2 + BZ.^2);
B = sqrt(BR.^2 + BZ.^2 + BPHI.^2);
r = sqrt((R - Rp).^2 + (Z - Zp).^2)+eps;
%
[drdtheta,drdrho] = gradient(r);%r
drdtheta = drdtheta./(ones(length(dprho),1)*dtheta);
drdrho = drdrho./(dprho(:)*ones(1,length(dtheta)));
%
[dRdtheta,dRdrho] = gradient(R);%XR
dRdtheta = dRdtheta./(ones(length(dprho),1)*dtheta);
dRdrho = dRdrho./(dprho(:)*ones(1,length(dtheta)));
%
[dZdtheta,dZdrho] = gradient(Z);%XZ
dZdtheta = dZdtheta./(ones(length(dprho),1)*dtheta);
dZdrho = dZdrho./(dprho(:)*ones(1,length(dtheta)));
%
salpha = ((R - Rp).*dRdtheta + (Z - Zp).*dZdtheta)./r./sqrt(dRdtheta.^2 + dZdtheta.^2 + eps);
salpha(:,1) = salpha(:,2);
salpha(:,end) = salpha(:,end-1);
calpha = sqrt(1.0 - salpha.^2);
%
[dcalphadtheta,dcalphadrho] = gradient(calpha);%
dcalphadtheta = dcalphadtheta./(ones(length(dprho),1)*dtheta);
dcalphadrho = dcalphadrho./(dprho(:)*ones(1,length(dtheta)));
%
[dsalphadtheta,dsalphadrho] = gradient(salpha);%
dsalphadtheta = dsalphadtheta./(ones(length(dprho),1)*dtheta);
dsalphadrho = dsalphadrho./(dprho(:)*ones(1,length(dtheta)));
%
[dBPHIdtheta,dBPHIdrho] = gradient(BPHI);%Toroidal magnetic field
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
dpsindrho = dpsin./dprho;
d2psindrho2 = d2psin./dprho./dprho;
if ~isempty(pTe),
    pdTe = gradient(pTe);
    pd2Te = gradient(pdTe);
    dTedrho = pdTe./dprho(:);
    d2Tedrho2 = pd2Te./dprho(:)./dprho(:);
end
if ~isempty(pne),
    pdne = gradient(pne);
    pd2ne = gradient(pdne);
    dnedrho = pdne./dprho(:);
    d2nedrho2 = pd2ne./dprho(:)./dprho(:);
end
if ~isempty(equil_in.zZi),
   for i = 1:length(equil_in.zZi)
      pdzTi = gradient(pzTi(:,i));
      pd2zTi = gradient(pdzTi);       
      pdzni = gradient(pzni(:,i));
      pd2zni = gradient(pdzni);       
      %
      zdTidrho(:,i) = pdzTi./dprho(:);
      zdnidrho(:,i) = pdzni./dprho(:);
      %
      zd2Tidrho2(:,i) = pd2zTi./dprho(:)./dprho(:);
      zd2nidrho2(:,i) = pd2zni./dprho(:)./dprho(:);
   end
end
%
dRstardpsin = gradient(R(:,1))./dpsin(:);
gradrhon = R.*BP.*(dRstardpsin*ones(1,size(R,2)))/equil_fit.psia;
[dgradrhondtheta,dgradrhondrho] = gradient(gradrhon);%rho gradient
dgradrhondtheta = dgradrhondtheta./(ones(length(dprho),1)*dtheta);
dgradrhondrho = dgradrhondrho./(dprho(:)*ones(1,length(dtheta)));
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
   dpsindrho_fit = ppval(equil_fit.psin_fit.pp_dfdrho,rho_fit);
   dpsindrho_fit1 = ppval_yp(equil_fit.psin_fit.pp_dfdrho,rho_fit);
   d2psindrho2_fit = ppval(equil_fit.psin_fit.pp_d2fdrho2,rho_fit);
   d2psindrho2_fit1 = ppval_yp(equil_fit.psin_fit.pp_d2fdrho2,rho_fit);
%
   if isfield(equil_fit,'Te_fit'),
      Te_fit = ppval(equil_fit.Te_fit.pp_f,rho_fit);Te_fit = Te_fit(:);
      Te_fit1 = ppval_yp(equil_fit.Te_fit.pp_f,rho_fit);Te_fit1 = Te_fit1(:);
      dTedrho_fit = ppval(equil_fit.Te_fit.pp_dfdrho,rho_fit);
      dTedrho_fit1 = ppval_yp(equil_fit.Te_fit.pp_dfdrho,rho_fit);
      d2Tedrho2_fit = ppval(equil_fit.Te_fit.pp_d2fdrho2,rho_fit);
      d2Tedrho2_fit1 = ppval_yp(equil_fit.Te_fit.pp_d2fdrho2,rho_fit);
   end
%
   if isfield(equil_fit,'ne_fit'),
      ne_fit = ppval(equil_fit.ne_fit.pp_f,rho_fit);ne_fit = ne_fit(:);
      ne_fit1 = ppval_yp(equil_fit.ne_fit.pp_f,rho_fit);ne_fit1 = ne_fit1(:);
      dnedrho_fit = ppval(equil_fit.ne_fit.pp_dfdrho,rho_fit);
      dnedrho_fit1 = ppval_yp(equil_fit.ne_fit.pp_dfdrho,rho_fit);
      d2nedrho2_fit = ppval(equil_fit.ne_fit.pp_d2fdrho2,rho_fit);
      d2nedrho2_fit1 = ppval_yp(equil_fit.ne_fit.pp_d2fdrho2,rho_fit);
   end
%
   if isfield(equil_fit,'zTi_fit'),
      zTi_fit = ppval(equil_fit.zTi_fit.pp_f,rho_fit);
      zTi_fit1 = ppval_yp(equil_fit.zTi_fit.pp_f,rho_fit);
      zdTidrho_fit = ppval(equil_fit.zTi_fit.pp_dfdrho,rho_fit);
      zdTidrho_fit1 = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,rho_fit);
      zd2Tidrho2_fit = ppval(equil_fit.zTi_fit.pp_d2fdrho2,rho_fit);
      zd2Tidrho2_fit1 = ppval_yp(equil_fit.zTi_fit.pp_d2fdrho2,rho_fit);
   end
%
   if isfield(equil_fit,'zni_fit'),
      zni_fit = ppval(equil_fit.zni_fit.pp_f,rho_fit);
      zni_fit1 = ppval_yp(equil_fit.zni_fit.pp_f,rho_fit);
      zdnidrho_fit = ppval(equil_fit.zni_fit.pp_dfdrho,rho_fit);
      zdnidrho_fit1 = ppval_yp(equil_fit.zni_fit.pp_dfdrho,rho_fit);
      zd2nidrho2_fit = ppval(equil_fit.zni_fit.pp_d2fdrho2,rho_fit);
      zd2nidrho2_fit1 = ppval_yp(equil_fit.zni_fit.pp_d2fdrho2,rho_fit);
   end
%
% Calculation of the coordinates and magnetic equilibrium quantity
%
   rho_fit1 = prho(1:10:end);%New normalized radial grid for display 2-D magnetic field
   rho_fit1(1) = prec;
%
   dRstardpsin_fit = ppval(equil_fit.dxstardpsin_fit.pp_f,rho_fit1);dRstardpsin_fit = dRstardpsin_fit(:);
   dRstardpsin_fit1 = ppval_yp(equil_fit.dxstardpsin_fit.pp_f,rho_fit1);dRstardpsin_fit1 = dRstardpsin_fit1(:); 
   ddRstardpsindrho_fit = ppval(equil_fit.dxstardpsin_fit.pp_dfdrho,rho_fit1);ddRstardpsindrho_fit = ddRstardpsindrho_fit(:);
   ddRstardpsindrho_fit1 = ppval_yp(equil_fit.dxstardpsin_fit.pp_dfdrho,rho_fit1);ddRstardpsindrho_fit1 = ddRstardpsindrho_fit1(:);
%
   x_a0_fit = ppval(equil_fit.x_fit.pp_a0,rho_fit1);
   x_an_fit = ppval(equil_fit.x_fit.pp_an,rho_fit1);
   x_bn_fit = ppval(equil_fit.x_fit.pp_bn,rho_fit1);
   x_da0drho_fit = ppval(equil_fit.x_fit.pp_da0drho,rho_fit1);
   x_dandrho_fit = ppval(equil_fit.x_fit.pp_dandrho,rho_fit1);
   x_dbndrho_fit = ppval(equil_fit.x_fit.pp_dbndrho,rho_fit1);
%
   y_a0_fit = ppval(equil_fit.y_fit.pp_a0,rho_fit1);
   y_an_fit = ppval(equil_fit.y_fit.pp_an,rho_fit1);
   y_bn_fit = ppval(equil_fit.y_fit.pp_bn,rho_fit1);
   y_da0drho_fit = ppval(equil_fit.y_fit.pp_da0drho,rho_fit1);
   y_dandrho_fit = ppval(equil_fit.y_fit.pp_dandrho,rho_fit1);
   y_dbndrho_fit = ppval(equil_fit.y_fit.pp_dbndrho,rho_fit1);
%
   Bx_a0_fit = ppval(equil_fit.Bx_fit.pp_a0,rho_fit1);
   Bx_an_fit = ppval(equil_fit.Bx_fit.pp_an,rho_fit1);
   Bx_bn_fit = ppval(equil_fit.Bx_fit.pp_bn,rho_fit1);
   Bx_da0drho_fit = ppval(equil_fit.Bx_fit.pp_da0drho,rho_fit1);
   Bx_dandrho_fit = ppval(equil_fit.Bx_fit.pp_dandrho,rho_fit1);
   Bx_dbndrho_fit = ppval(equil_fit.Bx_fit.pp_dbndrho,rho_fit1);
%
   By_a0_fit = ppval(equil_fit.By_fit.pp_a0,rho_fit1);
   By_an_fit = ppval(equil_fit.By_fit.pp_an,rho_fit1);
   By_bn_fit = ppval(equil_fit.By_fit.pp_bn,rho_fit1);
   By_da0drho_fit = ppval(equil_fit.By_fit.pp_da0drho,rho_fit1);
   By_dandrho_fit = ppval(equil_fit.By_fit.pp_dandrho,rho_fit1);
   By_dbndrho_fit = ppval(equil_fit.By_fit.pp_dbndrho,rho_fit1);
%
   BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,rho_fit1);
   BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,rho_fit1);
   BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,rho_fit1);
   BPHI_da0drho_fit = ppval(equil_fit.BPHI_fit.pp_da0drho,rho_fit1);
   BPHI_dandrho_fit = ppval(equil_fit.BPHI_fit.pp_dandrho,rho_fit1);
   BPHI_dbndrho_fit = ppval(equil_fit.BPHI_fit.pp_dbndrho,rho_fit1);
%
   x_a0_fit1 = ppval_yp(equil_fit.x_fit.pp_a0,rho_fit1);
   x_an_fit1 = ppval_yp(equil_fit.x_fit.pp_an,rho_fit1);
   x_bn_fit1 = ppval_yp(equil_fit.x_fit.pp_bn,rho_fit1);
   x_da0drho_fit1 = ppval_yp(equil_fit.x_fit.pp_da0drho,rho_fit1);
   x_dandrho_fit1 = ppval_yp(equil_fit.x_fit.pp_dandrho,rho_fit1);
   x_dbndrho_fit1 = ppval_yp(equil_fit.x_fit.pp_dbndrho,rho_fit1);
%
   y_a0_fit1 = ppval_yp(equil_fit.y_fit.pp_a0,rho_fit1);
   y_an_fit1 = ppval_yp(equil_fit.y_fit.pp_an,rho_fit1);
   y_bn_fit1 = ppval_yp(equil_fit.y_fit.pp_bn,rho_fit1);
   y_da0drho_fit1 = ppval_yp(equil_fit.y_fit.pp_da0drho,rho_fit1);
   y_dandrho_fit1 = ppval_yp(equil_fit.y_fit.pp_dandrho,rho_fit1);
   y_dbndrho_fit1 = ppval_yp(equil_fit.y_fit.pp_dbndrho,rho_fit1);
%
   Bx_a0_fit1 = ppval_yp(equil_fit.Bx_fit.pp_a0,rho_fit1);
   Bx_an_fit1 = ppval_yp(equil_fit.Bx_fit.pp_an,rho_fit1);
   Bx_bn_fit1 = ppval_yp(equil_fit.Bx_fit.pp_bn,rho_fit1);
   Bx_da0drho_fit1 = ppval_yp(equil_fit.Bx_fit.pp_da0drho,rho_fit1);
   Bx_dandrho_fit1 = ppval_yp(equil_fit.Bx_fit.pp_dandrho,rho_fit1);
   Bx_dbndrho_fit1 = ppval_yp(equil_fit.Bx_fit.pp_dbndrho,rho_fit1);
%
   By_a0_fit1 = ppval_yp(equil_fit.By_fit.pp_a0,rho_fit1);
   By_an_fit1 = ppval_yp(equil_fit.By_fit.pp_an,rho_fit1);
   By_bn_fit1 = ppval_yp(equil_fit.By_fit.pp_bn,rho_fit1);
   By_da0drho_fit1 = ppval_yp(equil_fit.By_fit.pp_da0drho,rho_fit1);
   By_dandrho_fit1 = ppval_yp(equil_fit.By_fit.pp_dandrho,rho_fit1);
   By_dbndrho_fit1 = ppval_yp(equil_fit.By_fit.pp_dbndrho,rho_fit1);
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
      [R_fit(:,ii),dRdtheta_fit(:,ii),d2Rdtheta2_fit(:,ii),dRdrho_fit(:,ii),d2Rdthetadrho_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),x_a0_fit(:),x_an_fit,x_bn_fit,x_da0drho_fit(:),x_dandrho_fit,x_dbndrho_fit);
      R_fit(:,ii) = R_fit(:,ii) + Rp;
      [Z_fit(:,ii),dZdtheta_fit(:,ii),d2Zdtheta2_fit(:,ii),dZdrho_fit(:,ii),d2Zdthetadrho_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),y_a0_fit(:),y_an_fit,y_bn_fit,y_da0drho_fit(:),y_dandrho_fit,y_dbndrho_fit);
      Z_fit(:,ii) = Z_fit(:,ii) + Zp;
%  
      r_fit(:,ii) = sqrt((R_fit(:,ii) - Rp).^2 + (Z_fit(:,ii) - Zp).^2);
      if (r_fit(1,ii) == 0), r_fit(1,ii) = prec; end
      drdtheta_fit(:,ii) = (dRdtheta_fit(:,ii).*(R_fit(:,ii) - Rp) + dZdtheta_fit(:,ii).*(Z_fit(:,ii) - Zp))./r_fit(:,ii);
      drdrho_fit(:,ii) = (dRdrho_fit(:,ii).*(R_fit(:,ii) - Rp) + dZdrho_fit(:,ii).*(Z_fit(:,ii) - Zp))./r_fit(:,ii);
%
      salpha_fit(:,ii) = ((R_fit(:,ii) - Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2);
      dsalphadtheta_fit(:,ii) = ...
         sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)./r_fit(:,ii) ...
         +((R_fit(:,ii) - Rp).*d2Rdtheta2_fit(:,ii) + (Z_fit(:,ii) - Zp).*d2Zdtheta2_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
         -drdtheta_fit(:,ii).*((R_fit(:,ii) - Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii).^2./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
         -(dRdtheta_fit(:,ii).*d2Rdtheta2_fit(:,ii) + dZdtheta_fit(:,ii).*d2Zdtheta2_fit(:,ii)).*((R_fit(:,ii) - Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)./(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2);     
      dsalphadrho_fit(:,ii) = ...
        (dRdtheta_fit(:,ii).*dRdrho_fit(:,ii) + dZdtheta_fit(:,ii).*dZdrho_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)...
        +((R_fit(:,ii) - Rp).*d2Rdthetadrho_fit(:,ii) + (Z_fit(:,ii) - Zp).*d2Zdthetadrho_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
        -drdrho_fit(:,ii).*((R_fit(:,ii) - Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii).^2./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2) ...
        -(dRdtheta_fit(:,ii).*d2Rdthetadrho_fit(:,ii) + dZdtheta_fit(:,ii).*d2Zdthetadrho_fit(:,ii)).*((R_fit(:,ii) - Rp).*dRdtheta_fit(:,ii) + (Z_fit(:,ii) - Zp).*dZdtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2)./(dRdtheta_fit(:,ii).^2 + dZdtheta_fit(:,ii).^2);
%
      calpha_fit(:,ii) = sqrt(1.0 - salpha_fit(:,ii).^2);
      if (calpha_fit(1,ii)== 0), calpha_fit(1,ii) = prec; end
      dcalphadtheta_fit(:,ii) = -salpha_fit(:,ii).*dsalphadtheta_fit(:,ii)./calpha_fit(:,ii);
      dcalphadrho_fit(:,ii) = -salpha_fit(:,ii).*dsalphadrho_fit(:,ii)./calpha_fit(:,ii);;
%
      [BR_fit(:,ii),dBRdtheta_fit(:,ii),dummy,dBRdrho_fit(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),Bx_a0_fit(:),Bx_an_fit,Bx_bn_fit,Bx_da0drho_fit(:),Bx_dandrho_fit,Bx_dbndrho_fit);
      [BZ_fit(:,ii),dBZdtheta_fit(:,ii),dummy,dBZdrho_fit(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),By_a0_fit(:),By_an_fit,By_bn_fit,By_da0drho_fit(:),By_dandrho_fit,By_dbndrho_fit);
      [BPHI_fit(:,ii),dBPHIdtheta_fit(:,ii),dummy,dBPHIdrho_fit(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),BPHI_a0_fit(:),BPHI_an_fit,BPHI_bn_fit,BPHI_da0drho_fit(:),BPHI_dandrho_fit,BPHI_dbndrho_fit);
%
      BP_fit(:,ii) = sqrt(BR_fit(:,ii).^2 + BZ_fit(:,ii).^2);
      dBPdtheta_fit(:,ii) = (BR_fit(:,ii).*dBRdtheta_fit(:,ii) + BZ_fit(:,ii).*dBZdtheta_fit(:,ii))./BP_fit(:,ii);
      dBPdrho_fit(:,ii) = (BR_fit(:,ii).*dBRdrho_fit(:,ii) + BZ_fit(:,ii).*dBZdrho_fit(:,ii))./BP_fit(:,ii);
%
      B_fit(:,ii) = sqrt(BR_fit(:,ii).^2 + BZ_fit(:,ii).^2 + BPHI_fit(:,ii).^2);
      dBdtheta_fit(:,ii) = (BR_fit(:,ii).*dBRdtheta_fit(:,ii) + BZ_fit(:,ii).*dBZdtheta_fit(:,ii) + BPHI_fit(:,ii).*dBPHIdtheta_fit(:,ii))./B_fit(:,ii);
      dBdrho_fit(:,ii) = (BR_fit(:,ii).*dBRdrho_fit(:,ii) + BZ_fit(:,ii).*dBZdrho_fit(:,ii) + BPHI_fit(:,ii).*dBPHIdrho_fit(:,ii))./B_fit(:,ii);
%      
      gradrhon_fit(:,ii) = R_fit(:,ii).*BP_fit(:,ii).*dRstardpsin_fit/equil_fit.psia;
      dgradrhondrho_fit(:,ii) = dRdrho_fit(:,ii).*BP_fit(:,ii).*dRstardpsin_fit/equil_fit.psia + R_fit(:,ii).*dBPdrho_fit(:,ii).*dRstardpsin_fit/equil_fit.ap/equil_fit.psia + R_fit(:,ii).*BP_fit(:,ii).*ddRstardpsindrho_fit/equil_fit.ap/equil_fit.psia;
      dgradrhondtheta_fit(:,ii) = dRdtheta_fit(:,ii).*BP_fit(:,ii).*dRstardpsin_fit/equil_fit.psia + R_fit(:,ii).*dBPdtheta_fit(:,ii).*dRstardpsin_fit/equil_fit.ap/equil_fit.psia;     
%
      [R_fit1(:,ii),dRdtheta_fit1(:,ii),d2Rdtheta2_fit1(:,ii),dRdrho_fit1(:,ii),d2Rdthetadrho_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),x_a0_fit1,x_an_fit1,x_bn_fit,x_da0drho_fit1,x_dandrho_fit1,x_dbndrho_fit1);
      R_fit1(:,ii) = R_fit1(:,ii) + Rp;
      [Z_fit1(:,ii),dZdtheta_fit1(:,ii),d2Zdtheta2_fit1(:,ii),dZdrho_fit1(:,ii),d2Zdthetadrho_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),y_a0_fit1,y_an_fit1,y_bn_fit,y_da0drho_fit1,y_dandrho_fit1,y_dbndrho_fit1);
      Z_fit1(:,ii) = Z_fit1(:,ii) + Zp;
%
      r_fit1(:,ii) = sqrt((R_fit1(:,ii) - Rp).^2 + (Z_fit1(:,ii) - Zp).^2);
      if (r_fit1(1,ii) == 0), r_fit1(1,ii) = prec; end
      drdtheta_fit1(:,ii) = (dRdtheta_fit1(:,ii).*(R_fit1(:,ii) - Rp) + dZdtheta_fit1(:,ii).*(Z_fit(:,ii) - Zp))./r_fit1(:,ii);
      drdrho_fit1(:,ii) = (dRdrho_fit1(:,ii).*(R_fit1(:,ii) - Rp) + dZdrho_fit1(:,ii).*(Z_fit(:,ii) - Zp))./r_fit1(:,ii);
%
      salpha_fit1(:,ii) = ((R_fit1(:,ii) - Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii)./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2);
      dsalphadtheta_fit1(:,ii) = ...
      sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2)./r_fit1(:,ii) ...
      + ((R_fit1(:,ii) - Rp).*d2Rdtheta2_fit1(:,ii) + (Z_fit1(:,ii) - Zp).*d2Zdtheta2_fit1(:,ii))./r_fit1(:,ii)./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2) ...
      -drdtheta_fit1(:,ii).*((R_fit1(:,ii) - Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii).^2./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2) ...
      -(dRdtheta_fit1(:,ii).*d2Rdtheta2_fit1(:,ii) + dZdtheta_fit1(:,ii).*d2Zdtheta2_fit1(:,ii)).*((R_fit1(:,ii) - Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii)./(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2).^(3/2);
      dsalphadtheta_fit1(1,ii) = dsalphadtheta_fit1(2,ii);
      dsalphadrho_fit1(:,ii) = ...
       (dRdtheta_fit1(:,ii).*dRdrho_fit1(:,ii) + dZdtheta_fit1(:,ii).*dZdrho_fit1(:,ii))./r_fit1(:,ii)./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2)...
      + ((R_fit1(:,ii) - Rp).*d2Rdthetadrho_fit1(:,ii) + (Z_fit1(:,ii) - Zp).*d2Zdthetadrho_fit1(:,ii))./r_fit1(:,ii)./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2) ...
      -drdrho_fit1(:,ii).*((R_fit1(:,ii) - Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii).^2./sqrt(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2) ...
      -(dRdtheta_fit1(:,ii).*d2Rdthetadrho_fit1(:,ii) + dZdtheta_fit1(:,ii).*d2Zdthetadrho_fit1(:,ii)).*((R_fit1(:,ii) - Rp).*dRdtheta_fit1(:,ii) + (Z_fit1(:,ii) - Zp).*dZdtheta_fit1(:,ii))./r_fit1(:,ii)./(dRdtheta_fit1(:,ii).^2 + dZdtheta_fit1(:,ii).^2).^(3/2);
      dsalphadrho_fit1(1,ii) = dsalphadrho_fit1(2,ii);
%
      calpha_fit1(:,ii) = sqrt(1.0 - salpha_fit1(:,ii).^2);
      if (calpha_fit1(1,ii) == 0), calpha_fit1(1,ii) = prec; end
      dcalphadtheta_fit1(:,ii) = -salpha_fit1(:,ii).*dsalphadtheta_fit1(:,ii)./calpha_fit1(:,ii);
      dcalphadrho_fit1(:,ii) = -salpha_fit1(:,ii).*dsalphadrho_fit1(:,ii)./calpha_fit1(:,ii);;
%
      [BR_fit1(:,ii),dBRdtheta_fit1(:,ii),dummy,dBRdrho_fit1(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),Bx_a0_fit1,Bx_an_fit1,Bx_bn_fit1,Bx_da0drho_fit1,Bx_dandrho_fit1,Bx_dbndrho_fit1);
      [BZ_fit1(:,ii),dBZdtheta_fit1(:,ii),dummy,dBZdrho_fit1(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),By_a0_fit1,By_an_fit1,By_bn_fit1,By_da0drho_fit1,By_dandrho_fit1,By_dbndrho_fit1);
      [BPHI_fit1(:,ii),dBPHIdtheta_fit1(:,ii),dummy,dBPHIdrho_fit1(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),BPHI_a0_fit1,BPHI_an_fit1,BPHI_bn_fit1,BPHI_da0drho_fit1,BPHI_dandrho_fit1,BPHI_dbndrho_fit1);
%
      BP_fit1(:,ii) = sqrt(BR_fit1(:,ii).^2 + BZ_fit1(:,ii).^2);
      dBPdtheta_fit1(:,ii) = (BR_fit1(:,ii).*dBRdtheta_fit1(:,ii) + BZ_fit1(:,ii).*dBZdtheta_fit1(:,ii))./BP_fit1(:,ii);
      dBPdrho_fit1(:,ii) = (BR_fit1(:,ii).*dBRdrho_fit1(:,ii) + BZ_fit1(:,ii).*dBZdrho_fit1(:,ii))./BP_fit1(:,ii);
%
      B_fit1(:,ii) = sqrt(BR_fit1(:,ii).^2 + BZ_fit1(:,ii).^2 + BPHI_fit1(:,ii).^2);
      dBdtheta_fit1(:,ii) = (BR_fit1(:,ii).*dBRdtheta_fit1(:,ii) + BZ_fit1(:,ii).*dBZdtheta_fit1(:,ii) + BPHI_fit1(:,ii).*dBPHIdtheta_fit1(:,ii))./B_fit1(:,ii);
      dBdrho_fit1(:,ii) = (BR_fit1(:,ii).*dBRdrho_fit1(:,ii) + BZ_fit1(:,ii).*dBZdrho_fit1(:,ii) + BPHI_fit1(:,ii).*dBPHIdrho_fit1(:,ii))./B_fit1(:,ii);
%
      gradrhon_fit1(:,ii) = R_fit1(:,ii).*BP_fit1(:,ii).*dRstardpsin_fit1/equil_fit.psia;
      dgradrhondrho_fit1(:,ii) = dRdrho_fit1(:,ii).*BP_fit1(:,ii).*dRstardpsin_fit1/equil_fit.psia + R_fit1(:,ii).*dBPdrho_fit1(:,ii).*dRstardpsin_fit1/equil_fit.ap + R_fit1(:,ii).*BP_fit1(:,ii).*ddRstardpsindrho_fit1/equil_fit.ap/equil_fit.psia;
      dgradrhondtheta_fit1(:,ii) = dRdtheta_fit1(:,ii).*BP_fit1(:,ii).*dRstardpsin_fit1/equil_fit.psia + R_fit1(:,ii).*dBPdtheta_fit1(:,ii).*dRstardpsin_fit1/equil_fit.ap/equil_fit.psia;
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
   [ax] = graph1D_jd(prho(1:10:end),psin(1:10:end),0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'--','non','r',1);
   if isfield(equil_fit,'Te_fit'),
      subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,Te_fit,0,0,'\psi','T_e (keV)',equil_in.id,NaN,[0,1],[-eps,max(equil_in.pTe)],'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,Te_fit1,0,0,'\psi','T_e (keV)',equil_in.id,NaN,[0,1],[-eps,max(equil_in.pTe)],'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),pTe(1:10:end),0,0,'\rho','T_e (keV)',equil_in.id,NaN,[0,1],[-eps,max(equil_in.pTe)],'--','non','r',1);
   end
   if isfield(equil_fit,'ne_fit'),
      subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,ne_fit/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_in.pne/1e19)],'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,ne_fit1/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_in.pne/1e19)],'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),pne(1:10:end)/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_in.pne/1e19)],'--','non','r',1);
   end
   if isfield(equil_fit,'zTi_fit'),
      subplot('position',[1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zTi_fit,0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_in.pzTi))],'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zTi_fit1,0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_in.pzTi))],'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),pzTi(1:10:end,:),0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_in.pzTi))],'--','non','r',1);
   end
   if isfield(equil_fit,'zni_fit'),
      subplot('position',[1/3+1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zni_fit/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_in.pzni/1e19))],'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zni_fit1/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_in.pzni/1e19))],'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),pzni(1:10:end,:)/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_in.pzni/1e19))],'--','non','r',1);
      subplot('position',[2/3+1/12,1/8,5/24,5/16])
   end
%
   figure('Name','1st order derivatives of the magnetic equilibrium profile parameters'),clf
   set(gcf,'units','inches','position',[0.5,1,10,6]);
   set(gca,'position',[0,0,1,1]);
%
   subplot('position',[1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,dpsindrho_fit,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,dpsindrho_fit1,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),dpsindrho(1:10:end),0,0,'\rho','d\psi_nd/\rho','',NaN,[0,1],[min(dpsindrho_fit1),max(dpsindrho_fit1)],'--','non','r',1);
   if isfield(equil_fit,'Te_fit'),
      subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,dTedrho_fit,0,0,'','',equil_in.id,NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,dTedrho_fit1,0,0,'','',equil_in.id,NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),dTedrho(1:10:end),0,0,'\rho','dT_ed/\rho (keV)',equil_in.id,NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'ne_fit'),
      subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,dnedrho_fit/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,dnedrho_fit1/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),dnedrho(1:10:end)/1e19,0,0,'\rho','dn_e/d\rho (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'zTi_fit'),
      subplot('position',[1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zdTidrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zdTidrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),zdTidrho(1:10:end,:),0,0,'\rho','dT_i/d\rho (keV)','',NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'zni_fit'),
      subplot('position',[1/3+1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zdnidrho_fit/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zdnidrho_fit1/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),zdnidrho(1:10:end,:)/1e19,0,0,'\rho','dn_i/d\rho (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
      subplot('position',[2/3+1/12,1/8,5/24,5/16])
   end
%
   figure('Name','2nd order derivatives of the magnetic equilibrium profile parameters'),clf
   set(gcf,'units','inches','position',[0.5,1,10,6]);
   set(gca,'position',[0,0,1,1]);
%
   subplot('position',[1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,d2psindrho2_fit,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,d2psindrho2_fit1,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:10:end),d2psindrho2(1:10:end),0,0,'\rho','d2\psi_nd/\rho2','',NaN,[0,1],[min(d2psindrho2_fit1),max(d2psindrho2_fit1)],'--','non','r',1);
   if isfield(equil_fit,'Te_fit'),
      subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,d2Tedrho2_fit,0,0,'','',equil_in.id,NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,d2Tedrho2_fit1,0,0,'','',equil_in.id,NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),d2Tedrho2(1:10:end),0,0,'\rho','d2T_ed/\rho2 (keV)',equil_in.id,NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'ne_fit'),
      subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,d2nedrho2_fit/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,d2nedrho2_fit1/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),d2nedrho2(1:10:end)/1e19,0,0,'\rho','d2n_e/d\rho2 (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'zTi_fit'),
      subplot('position',[1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zd2Tidrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zd2Tidrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),zd2Tidrho2(1:10:end,:),0,0,'\rho','d2T_i/d\rho2 (keV)','',NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'zni_fit'),
      subplot('position',[1/3+1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zd2nidrho2_fit/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zd2nidrho2_fit1/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:10:end),zd2nidrho2(1:10:end,:)/1e19,0,0,'','d2n_i/d\rho2 (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
      subplot('position',[2/3+1/12,1/8,5/24,5/16])
   end
%
% Magnetic equilibrium coordinates
%
   figure('Name','Z coordinate'),
   [ax] = graph1D_jd(theta_fit,R_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,R_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),R(1:10:end,1:2:end),0,0,'\theta (rd)','R (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
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
   [ax] = graph1D_jd(equil_in.theta(1:2:end),Z(1:10:end,1:2:end),0,0,'\theta (rd)','Z (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
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
   figure('Name','gradrhon'),
   [ax] = graph1D_jd(theta_fit,gradrhon_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,gradrhon_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),gradrhon(1:10:end,1:2:end),0,0,'\theta (rd)','grad\rhon','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dgradrhon/dtheta'),
   [ax] = graph1D_jd(theta_fit,dgradrhondtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dgradrhondtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dgradrhondtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dgrad\rhon/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dgradrhon/drho'),
   [ax] = graph1D_jd(theta_fit,dgradrhondrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dgradrhondrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dgradrhondrho(1:10:end,1:2:end),0,0,'\rho','dgrad\rhon/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
%Magnetic fields
%
   figure('Name','Toroidal magnetic field BPHI'),
   [ax] = graph1D_jd(theta_fit,BPHI_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,BPHI_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),BPHI(1:10:end,1:2:end),0,0,'\theta (rd)','B_{\phi} (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
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
   Rmin = min(min(R));
   Rmax = max(max(R));
   Zmin = min(min(Z));
   Zmax = max(max(Z));
%
   figure('Name','Magnetic equilibrium flux surface contour')
% 
   [ax] = graph1D_jd(R(1:10:end,1:2:end),Z(1:10:end,1:2:end),0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);drawnow
   [ax] = graph1D_jd(R(1:10:end,:)',Z(1:10:end,:)',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);
%
   [ax] = graph1D_jd(R_fit(1:10:end,1:2:end),Z_fit(1:10:end,1:2:end),0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
   [ax] = graph1D_jd(R_fit(:,:)',Z_fit(:,:)',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);
%
   [ax] = graph1D_jd(R_fit1(1:10:end,1:2:end),Z_fit1(1:10:end,1:2:end),0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','c',1);drawnow
   [ax] = graph1D_jd(R_fit1(:,:)',Z_fit1(:,:)',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','c',1);
   axis('equal');drawnow  
%
else
   [Te,dTedrho,d2Tedrho2,ne,dnedrho,d2nedrho2,zTi,dzTidrho,d2zTidrho2,zni,dznidrho,d2znidrho2,...
        R,dRdtheta,d2Rdtheta2,dRdrho,d2Rdthetadrho,Z,dZdtheta,d2Zdtheta2,dZdrho,d2Zdthetadrho,...
        r,drdtheta,drdrho,salpha,dsalphadtheta,dsalphadrho,calpha,dcalphadtheta,dcalphadrho,...
        BR,dBRdtheta,d2BRdtheta2,dBRdrho,d2BRdthetadrho,...
        BZ,dBZdtheta,d2BZdtheta2,dBZdrho,d2BZdthetadrho,...
        BPHI,dBPHIdtheta,d2BPHIdtheta2,dBPHIdrho,d2BPHIdthetadrho,...
        BP,dBPdtheta,dBPdrho,B,dBdtheta,dBdrho,...
        gradrhon,dgradrhondtheta,dgradrhondrho] = equilval_yp(equil_fit,rho,theta,1);
%
   if nargout ~= 2,
      disp('--------------');
      if isfield(equil_fit,'Te_fit'),
         disp(['equil_fit.Te_fit.pp_f.coefs(1) = ',num2str(equil_fit.Te_fit.pp_f.coefs(1))]);
         disp(['equil_fit.Te_fit.pp_dfdrho.coefs(1) = ',num2str(equil_fit.Te_fit.pp_dfdrho.coefs(1))]);
         disp(['equil_fit.Te_fit.pp_d2fdrho2.coefs(1) = ',num2str(equil_fit.Te_fit.pp_d2fdrho2.coefs(1))]);
      end
      disp(['equil_fit.BPHI_fit.n = ',num2str(equil_fit.BPHI_fit.n(end))]);
      disp(['equil_fit.BPHI_fit.bn_f.coefs(1) = ',num2str(equil_fit.BPHI_fit.pp_bn.coefs(1))]);
      disp(['equil_fit.BPHI_fit.bn_f.coefs(1) = ',num2str(equil_fit.BPHI_fit.pp_dbndrho.coefs(1))]);
      disp('--------------');
      if isfield(equil_fit,'Te_fit'),
         disp(['Te(',num2str(rho),'),dTedrho(',num2str(rho),'),d2Tedrho2(',num2str(rho),') (keV) = ',num2str(Te),',',num2str(dTedrho),',',num2str(d2Tedrho2)]);
      end
      if isfield(equil_fit,'ne_fit'),
         disp(['ne(',num2str(rho),'),dnedrho(',num2str(rho),'),d2nedrho2(',num2str(rho),') (10+19 m-3) = ',num2str(ne/1e19),',',num2str(dnedrho/1e19),',',num2str(d2nedrho2/1e19)]);
      end
      if isfield(equil_fit,'zTi_fit'),
         disp(['zTi(',int2str(ns),',',num2str(rho),'),dzTidrho(',int2str(ns),',',num2str(rho),'),d2zTidrho2(',int2str(ns),' ,',num2str(rho),') (keV) = ',num2str(zTi(ns)),',',num2str(dzTidrho(ns)),',',num2str(d2zTidrho2(ns))]);
      end
      if isfield(equil_fit,'zni_fit'),
         disp(['zni(',int2str(ns),',',num2str(rho),'),dznidrho(',int2str(ns),',',num2str(rho),'),d2znidrho2(',int2str(ns),' ,',num2str(rho),') (10+19 m-3) = ',num2str(zni(ns)/1e19),',',num2str(dznidrho(ns)/1e19),',',num2str(d2znidrho2(ns)/1e19)]);
      end
%
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
      disp(['gradrhon(',num2str(rho),',',num2str(theta),'),dgradrhondrho(',num2str(rho),',',num2str(theta),'),dgradrhondtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(gradrhon),',',num2str(dgradrhondrho),',',num2str(dgradrhondtheta)]);
   end
end

