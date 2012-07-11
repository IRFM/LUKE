function [x,y] = testfitequil_yp(equil_in,equil_fit,rho,theta,ns)
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
x = [];
y = [];
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
Bx = equil_in.ptBx + eps;
By = equil_in.ptBy + eps;
Bz = equil_in.ptBPHI;
%
Rp = equil_in.Rp;
Zp = equil_in.Zp;
x = equil_in.ptx;
y = equil_in.pty;
%
BP = sqrt(Bx.^2 + By.^2);
B = sqrt(Bx.^2 + By.^2 + Bz.^2);
r = sqrt(x.^2 + y.^2)+eps;
%
[drdtheta,drdrho] = gradient(r);%r
drdtheta = drdtheta./(ones(length(dprho),1)*dtheta);
drdrho = drdrho./(dprho(:)*ones(1,length(dtheta)));
%
[dxdtheta,dxdrho] = gradient(x);%Xx
dxdtheta = dxdtheta./(ones(length(dprho),1)*dtheta);
dxdrho = dxdrho./(dprho(:)*ones(1,length(dtheta)));
%
[dydtheta,dydrho] = gradient(y);%Xy
dydtheta = dydtheta./(ones(length(dprho),1)*dtheta);
dydrho = dydrho./(dprho(:)*ones(1,length(dtheta)));
%
salpha = (x.*dxdtheta + y.*dydtheta)./r./sqrt(dxdtheta.^2 + dydtheta.^2 + eps);
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
[dBzdtheta,dBzdrho] = gradient(Bz);%Toroidal magnetic field
dBzdtheta = dBzdtheta./(ones(length(dprho),1)*dtheta);
dBzdrho = dBzdrho./(dprho(:)*ones(1,length(dtheta)));
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
%
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
dxstardpsin = gradient(x(:,1))./dpsin(:);
%
if isinf(Rp),
    Upsilon = 1;
else
    Upsilon = 1 + x/Rp;
end
%
gradrhon = Upsilon.*BP.*(dxstardpsin*ones(1,size(x,2)))/equil_fit.psia_apRp*equil_fit.ap;
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
   dxstardpsin_fit = ppval(equil_fit.dxstardpsin_fit.pp_f,rho_fit1);dxstardpsin_fit = dxstardpsin_fit(:);
   dxstardpsin_fit1 = ppval_yp(equil_fit.dxstardpsin_fit.pp_f,rho_fit1);dxstardpsin_fit1 = dxstardpsin_fit1(:); 
   ddxstardpsindrho_fit = ppval(equil_fit.dxstardpsin_fit.pp_dfdrho,rho_fit1);ddxstardpsindrho_fit = ddxstardpsindrho_fit(:);
   ddxstardpsindrho_fit1 = ppval_yp(equil_fit.dxstardpsin_fit.pp_dfdrho,rho_fit1);ddxstardpsindrho_fit1 = ddxstardpsindrho_fit1(:);
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
   Bz_a0_fit = ppval(equil_fit.Bz_fit.pp_a0,rho_fit1);
   Bz_an_fit = ppval(equil_fit.Bz_fit.pp_an,rho_fit1);
   Bz_bn_fit = ppval(equil_fit.Bz_fit.pp_bn,rho_fit1);
   Bz_da0drho_fit = ppval(equil_fit.Bz_fit.pp_da0drho,rho_fit1);
   Bz_dandrho_fit = ppval(equil_fit.Bz_fit.pp_dandrho,rho_fit1);
   Bz_dbndrho_fit = ppval(equil_fit.Bz_fit.pp_dbndrho,rho_fit1);
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
   Bz_a0_fit1 = ppval_yp(equil_fit.Bz_fit.pp_a0,rho_fit1);
   Bz_an_fit1 = ppval_yp(equil_fit.Bz_fit.pp_an,rho_fit1);
   Bz_bn_fit1 = ppval_yp(equil_fit.Bz_fit.pp_bn,rho_fit1);
   Bz_da0drho_fit1 = ppval_yp(equil_fit.Bz_fit.pp_da0drho,rho_fit1);
   Bz_dandrho_fit1 = ppval_yp(equil_fit.Bz_fit.pp_dandrho,rho_fit1);
   Bz_dbndrho_fit1 = ppval_yp(equil_fit.Bz_fit.pp_dbndrho,rho_fit1);
%
% Build interpolated quantities
%
   for ii = 1:ntheta_fit, 
      [x_fit(:,ii),dxdtheta_fit(:,ii),d2xdtheta2_fit(:,ii),dxdrho_fit(:,ii),d2xdthetadrho_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),x_a0_fit(:),x_an_fit,x_bn_fit,x_da0drho_fit(:),x_dandrho_fit,x_dbndrho_fit);
      [y_fit(:,ii),dydtheta_fit(:,ii),d2ydtheta2_fit(:,ii),dydrho_fit(:,ii),d2ydthetadrho_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),y_a0_fit(:),y_an_fit,y_bn_fit,y_da0drho_fit(:),y_dandrho_fit,y_dbndrho_fit);
%  
      r_fit(:,ii) = sqrt(x_fit(:,ii).^2 + y_fit(:,ii).^2);
      if (r_fit(1,ii) == 0), r_fit(1,ii) = prec; end
      drdtheta_fit(:,ii) = (dxdtheta_fit(:,ii).*x_fit(:,ii) + dydtheta_fit(:,ii).*y_fit(:,ii))./r_fit(:,ii);
      drdrho_fit(:,ii) = (dxdrho_fit(:,ii).*x_fit(:,ii) + dydrho_fit(:,ii).*y_fit(:,ii))./r_fit(:,ii);
%
      salpha_fit(:,ii) = (x_fit(:,ii).*dxdtheta_fit(:,ii) + y_fit(:,ii).*dydtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2);
      dsalphadtheta_fit(:,ii) = ...
         sqrt(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2)./r_fit(:,ii) ...
         +(x_fit(:,ii).*d2xdtheta2_fit(:,ii) + y_fit(:,ii).*d2ydtheta2_fit(:,ii))./r_fit(:,ii)./sqrt(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2) ...
         -drdtheta_fit(:,ii).*(x_fit(:,ii).*dxdtheta_fit(:,ii) + y_fit(:,ii).*dydtheta_fit(:,ii))./r_fit(:,ii).^2./sqrt(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2) ...
         -(dxdtheta_fit(:,ii).*d2xdtheta2_fit(:,ii) + dydtheta_fit(:,ii).*d2ydtheta2_fit(:,ii)).*(x_fit(:,ii).*dxdtheta_fit(:,ii) + y_fit(:,ii).*dydtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2)./(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2);     
      %
      dsalphadrho_fit(:,ii) = ...
        (dxdtheta_fit(:,ii).*dxdrho_fit(:,ii) + dydtheta_fit(:,ii).*dydrho_fit(:,ii))./r_fit(:,ii)./sqrt(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2)...
        +(x_fit(:,ii).*d2xdthetadrho_fit(:,ii) + y_fit(:,ii).*d2ydthetadrho_fit(:,ii))./r_fit(:,ii)./sqrt(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2) ...
        -drdrho_fit(:,ii).*(x_fit(:,ii).*dxdtheta_fit(:,ii) + y_fit(:,ii).*dydtheta_fit(:,ii))./r_fit(:,ii).^2./sqrt(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2) ...
        -(dxdtheta_fit(:,ii).*d2xdthetadrho_fit(:,ii) + dydtheta_fit(:,ii).*d2ydthetadrho_fit(:,ii)).*(x_fit(:,ii).*dxdtheta_fit(:,ii) + y_fit(:,ii).*dydtheta_fit(:,ii))./r_fit(:,ii)./sqrt(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2)./(dxdtheta_fit(:,ii).^2 + dydtheta_fit(:,ii).^2);
%
      calpha_fit(:,ii) = sqrt(1.0 - salpha_fit(:,ii).^2);
      if (calpha_fit(1,ii)== 0), calpha_fit(1,ii) = prec; end
      dcalphadtheta_fit(:,ii) = -salpha_fit(:,ii).*dsalphadtheta_fit(:,ii)./calpha_fit(:,ii);
      dcalphadrho_fit(:,ii) = -salpha_fit(:,ii).*dsalphadrho_fit(:,ii)./calpha_fit(:,ii);;
%
      [Bx_fit(:,ii),dBxdtheta_fit(:,ii),dummy,dBxdrho_fit(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),Bx_a0_fit(:),Bx_an_fit,Bx_bn_fit,Bx_da0drho_fit(:),Bx_dandrho_fit,Bx_dbndrho_fit);
      [By_fit(:,ii),dBydtheta_fit(:,ii),dummy,dBydrho_fit(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),By_a0_fit(:),By_an_fit,By_bn_fit,By_da0drho_fit(:),By_dandrho_fit,By_dbndrho_fit);
      [Bz_fit(:,ii),dBzdtheta_fit(:,ii),dummy,dBzdrho_fit(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),Bz_a0_fit(:),Bz_an_fit,Bz_bn_fit,Bz_da0drho_fit(:),Bz_dandrho_fit,Bz_dbndrho_fit);
%
      BP_fit(:,ii) = sqrt(Bx_fit(:,ii).^2 + By_fit(:,ii).^2);
      dBPdtheta_fit(:,ii) = (Bx_fit(:,ii).*dBxdtheta_fit(:,ii) + By_fit(:,ii).*dBydtheta_fit(:,ii))./BP_fit(:,ii);
      dBPdrho_fit(:,ii) = (Bx_fit(:,ii).*dBxdrho_fit(:,ii) + By_fit(:,ii).*dBydrho_fit(:,ii))./BP_fit(:,ii);
%
      B_fit(:,ii) = sqrt(Bx_fit(:,ii).^2 + By_fit(:,ii).^2 + Bz_fit(:,ii).^2);
      dBdtheta_fit(:,ii) = (Bx_fit(:,ii).*dBxdtheta_fit(:,ii) + By_fit(:,ii).*dBydtheta_fit(:,ii) + Bz_fit(:,ii).*dBzdtheta_fit(:,ii))./B_fit(:,ii);
      dBdrho_fit(:,ii) = (Bx_fit(:,ii).*dBxdrho_fit(:,ii) + By_fit(:,ii).*dBydrho_fit(:,ii) + Bz_fit(:,ii).*dBzdrho_fit(:,ii))./B_fit(:,ii);
%     
      if isinf(Rp),
         Upsilon_fit = ones(size(x_fit(:,ii)));
         dUpsilondrho_fit = zeros(size(x_fit(:,ii)));
         dUpsilondtheta_fit = zeros(size(x_fit(:,ii)));
      else
         Upsilon_fit = 1 + x_fit(:,ii)/Rp;
         dUpsilondrho_fit = dxdrho_fit(:,ii)/Rp;
         dUpsilondtheta_fit =  dxdtheta_fit(:,ii)/Rp;
      end
      %     
      gradrhon_fit(:,ii) = Upsilon_fit.*BP_fit(:,ii).*dxstardpsin_fit/equil_fit.psia_apRp*equil_fit.ap;
      dgradrhondrho_fit(:,ii) = dUpsilondrho_fit.*BP_fit(:,ii).*dxstardpsin_fit/equil_fit.psia_apRp*equil_fit.ap + Upsilon_fit.*dBPdrho_fit(:,ii).*dxstardpsin_fit/equil_fit.psia_apRp*equil_fit.ap + Upsilon_fit.*BP_fit(:,ii).*ddxstardpsindrho_fit/equil_fit.psia_apRp*equil_fit.ap;
      dgradrhondtheta_fit(:,ii) = dUpsilondtheta_fit.*BP_fit(:,ii).*dxstardpsin_fit/equil_fit.psia_apRp + Upsilon_fit.*dBPdtheta_fit(:,ii).*dxstardpsin_fit/equil_fit.psia_apRp*equil_fit.ap;     
%
      [x_fit1(:,ii),dxdtheta_fit1(:,ii),d2xdtheta2_fit1(:,ii),dxdrho_fit1(:,ii),d2xdthetadrho_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),x_a0_fit1,x_an_fit1,x_bn_fit,x_da0drho_fit1,x_dandrho_fit1,x_dbndrho_fit1);
      [y_fit1(:,ii),dydtheta_fit1(:,ii),d2ydtheta2_fit1(:,ii),dydrho_fit1(:,ii),d2ydthetadrho_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),y_a0_fit1,y_an_fit1,y_bn_fit,y_da0drho_fit1,y_dandrho_fit1,y_dbndrho_fit1);
%
      r_fit1(:,ii) = sqrt(x_fit1(:,ii).^2 + y_fit1(:,ii).^2);
      if (r_fit1(1,ii) == 0), r_fit1(1,ii) = prec; end
      drdtheta_fit1(:,ii) = (dxdtheta_fit1(:,ii).*x_fit1(:,ii) + dydtheta_fit1(:,ii).*y_fit1(:,ii))./r_fit1(:,ii);
      drdrho_fit1(:,ii) = (dxdrho_fit1(:,ii).*x_fit1(:,ii) + dydrho_fit1(:,ii).*y_fit1(:,ii))./r_fit1(:,ii);
%
      salpha_fit1(:,ii) = (x_fit1(:,ii).*dxdtheta_fit1(:,ii) + y_fit1(:,ii).*dydtheta_fit1(:,ii))./r_fit1(:,ii)./sqrt(dxdtheta_fit1(:,ii).^2 + dydtheta_fit1(:,ii).^2);
      dsalphadtheta_fit1(:,ii) = ...
      sqrt(dxdtheta_fit1(:,ii).^2 + dydtheta_fit1(:,ii).^2)./r_fit1(:,ii) ...
      + (x_fit1(:,ii).*d2xdtheta2_fit1(:,ii) + y_fit1(:,ii).*d2ydtheta2_fit1(:,ii))./r_fit1(:,ii)./sqrt(dxdtheta_fit1(:,ii).^2 + dydtheta_fit1(:,ii).^2) ...
      -drdtheta_fit1(:,ii).*(x_fit1(:,ii).*dxdtheta_fit1(:,ii) + y_fit1(:,ii).*dydtheta_fit1(:,ii))./r_fit1(:,ii).^2./sqrt(dxdtheta_fit1(:,ii).^2 + dydtheta_fit1(:,ii).^2) ...
      -(dxdtheta_fit1(:,ii).*d2xdtheta2_fit1(:,ii) + dydtheta_fit1(:,ii).*d2ydtheta2_fit1(:,ii)).*(x_fit1(:,ii).*dxdtheta_fit1(:,ii) + y_fit1(:,ii).*dydtheta_fit1(:,ii))./r_fit1(:,ii)./(dxdtheta_fit1(:,ii).^2 + dydtheta_fit1(:,ii).^2).^(3/2);
      dsalphadtheta_fit1(1,ii) = dsalphadtheta_fit1(2,ii);
      %
      dsalphadrho_fit1(:,ii) = ...
       (dxdtheta_fit1(:,ii).*dxdrho_fit1(:,ii) + dydtheta_fit1(:,ii).*dydrho_fit1(:,ii))./r_fit1(:,ii)./sqrt(dxdtheta_fit1(:,ii).^2 + dydtheta_fit1(:,ii).^2)...
      + (x_fit1(:,ii).*d2xdthetadrho_fit1(:,ii) + y_fit1(:,ii).*d2ydthetadrho_fit1(:,ii))./r_fit1(:,ii)./sqrt(dxdtheta_fit1(:,ii).^2 + dydtheta_fit1(:,ii).^2) ...
      -drdrho_fit1(:,ii).*(x_fit1(:,ii).*dxdtheta_fit1(:,ii) + y_fit1(:,ii).*dydtheta_fit1(:,ii))./r_fit1(:,ii).^2./sqrt(dxdtheta_fit1(:,ii).^2 + dydtheta_fit1(:,ii).^2) ...
      -(dxdtheta_fit1(:,ii).*d2xdthetadrho_fit1(:,ii) + dydtheta_fit1(:,ii).*d2ydthetadrho_fit1(:,ii)).*(x_fit1(:,ii).*dxdtheta_fit1(:,ii) + y_fit1(:,ii).*dydtheta_fit1(:,ii))./r_fit1(:,ii)./(dxdtheta_fit1(:,ii).^2 + dydtheta_fit1(:,ii).^2).^(3/2);
      dsalphadrho_fit1(1,ii) = dsalphadrho_fit1(2,ii);
%
      calpha_fit1(:,ii) = sqrt(1.0 - salpha_fit1(:,ii).^2);
      if (calpha_fit1(1,ii) == 0), calpha_fit1(1,ii) = prec; end
      dcalphadtheta_fit1(:,ii) = -salpha_fit1(:,ii).*dsalphadtheta_fit1(:,ii)./calpha_fit1(:,ii);
      dcalphadrho_fit1(:,ii) = -salpha_fit1(:,ii).*dsalphadrho_fit1(:,ii)./calpha_fit1(:,ii);;
%
      [Bx_fit1(:,ii),dBxdtheta_fit1(:,ii),dummy,dBxdrho_fit1(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),Bx_a0_fit1,Bx_an_fit1,Bx_bn_fit1,Bx_da0drho_fit1,Bx_dandrho_fit1,Bx_dbndrho_fit1);
      [By_fit1(:,ii),dBydtheta_fit1(:,ii),dummy,dBydrho_fit1(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),By_a0_fit1,By_an_fit1,By_bn_fit1,By_da0drho_fit1,By_dandrho_fit1,By_dbndrho_fit1);
      [Bz_fit1(:,ii),dBzdtheta_fit1(:,ii),dummy,dBzdrho_fit1(:,ii),dummy] = calcval_yp(equil_fit,theta_fit(ii),Bz_a0_fit1,Bz_an_fit1,Bz_bn_fit1,Bz_da0drho_fit1,Bz_dandrho_fit1,Bz_dbndrho_fit1);
%
      BP_fit1(:,ii) = sqrt(Bx_fit1(:,ii).^2 + By_fit1(:,ii).^2);
      dBPdtheta_fit1(:,ii) = (Bx_fit1(:,ii).*dBxdtheta_fit1(:,ii) + By_fit1(:,ii).*dBydtheta_fit1(:,ii))./BP_fit1(:,ii);
      dBPdrho_fit1(:,ii) = (Bx_fit1(:,ii).*dBxdrho_fit1(:,ii) + By_fit1(:,ii).*dBydrho_fit1(:,ii))./BP_fit1(:,ii);
%
      B_fit1(:,ii) = sqrt(Bx_fit1(:,ii).^2 + By_fit1(:,ii).^2 + Bz_fit1(:,ii).^2);
      dBdtheta_fit1(:,ii) = (Bx_fit1(:,ii).*dBxdtheta_fit1(:,ii) + By_fit1(:,ii).*dBydtheta_fit1(:,ii) + Bz_fit1(:,ii).*dBzdtheta_fit1(:,ii))./B_fit1(:,ii);
      dBdrho_fit1(:,ii) = (Bx_fit1(:,ii).*dBxdrho_fit1(:,ii) + By_fit1(:,ii).*dBydrho_fit1(:,ii) + Bz_fit1(:,ii).*dBzdrho_fit1(:,ii))./B_fit1(:,ii);
%
      if isinf(Rp),
         Upsilon_fit1 = ones(size(x_fit1(:,ii)));
         dUpsilondrho_fit1 = zeros(size(x_fit1(:,ii)));
         dUpsilondtheta_fit1 = zeros(size(x_fit1(:,ii)));
      else
         Upsilon_fit1 = 1 + x_fit1(:,ii)/Rp;
         dUpsilondrho_fit1 = dxdrho_fit1(:,ii)/Rp;
         dUpsilondtheta_fit1 =  dxdtheta_fit1(:,ii)/Rp;
      end
      %
      gradrhon_fit1(:,ii) = Upsilon_fit1.*BP_fit1(:,ii).*dxstardpsin_fit1/equil_fit.psia_apRp*equil_fit.ap;
      dgradrhondrho_fit1(:,ii) = dUpsilondrho_fit1.*BP_fit1(:,ii).*dxstardpsin_fit1/equil_fit.psia_apRp*equil_fit.ap + Upsilon_fit1.*dBPdrho_fit1(:,ii).*dxstardpsin_fit1/equil_fit.psia_apRp*equil_fit.ap + Upsilon_fit1.*BP_fit1(:,ii).*ddxstardpsindrho_fit1/equil_fit.psia_apRp*equil_fit.ap;
      dgradrhondtheta_fit1(:,ii) = dUpsilondtheta_fit1.*BP_fit1(:,ii).*dxstardpsin_fit1/equil_fit.psia_apRp*equil_fit.ap + Upsilon_fit1.*dBPdtheta_fit1(:,ii).*dxstardpsin_fit1/equil_fit.psia_apRp*equil_fit.ap;
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
   figure('Name','x (majord radius) coordinate'),
   [ax] = graph1D_jd(theta_fit,x_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,x_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),x(1:10:end,1:2:end),0,0,'\theta (rd)','x (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dx/dtheta'),
   [ax] = graph1D_jd(theta_fit,dxdtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dxdtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dxdtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dx/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dx/drho'),
   [ax] = graph1D_jd(theta_fit,dxdrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dxdrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dxdrho(1:10:end,1:2:end),0,0,'\theta','dx/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','y (vertical) coordinate'),
   [ax] = graph1D_jd(theta_fit,y_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,y_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),y(1:10:end,1:2:end),0,0,'\theta (rd)','y (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dy/dtheta'),
   [ax] = graph1D_jd(theta_fit,dydtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dydtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dydtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dy/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dy/drho'),
   [ax] = graph1D_jd(theta_fit,dydrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dydrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dydrho(1:10:end,1:2:end),0,0,'\rho','dy/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
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
   figure('Name','Toroidal (axial) magnetic field Bz'),
   [ax] = graph1D_jd(theta_fit,Bz_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,Bz_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),Bz(1:10:end,1:2:end),0,0,'\theta (rd)','B_{\phi} (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dBz/dtheta'),
   [ax] = graph1D_jd(theta_fit,dBzdtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBzdtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBzdtheta(1:10:end,1:2:end),0,0,'\theta (rd)','dBz/d\theta','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
%
   figure('Name','dBz/drho'),
   [ax] = graph1D_jd(theta_fit,dBzdrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBzdrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBzdrho(1:10:end,1:2:end),0,0,'\psi_{n}','dBz/d\rho','Blue: interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','non','r',1);
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
   xmin = min(min(x));
   xmax = max(max(x));
   ymin = min(min(y));
   ymax = max(max(y));
%
   figure('Name','Magnetic equilibrium flux surface contour')
% 
   [ax] = graph1D_jd(x(1:10:end,1:2:end),y(1:10:end,1:2:end),0,0,'','','',NaN,[xmin,xmax],[ymin,ymax],'-','none','r',2);drawnow
   [ax] = graph1D_jd(x(1:10:end,:)',y(1:10:end,:)',0,0,'x(m)','y(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[xmin,xmax],[ymin,ymax],'-','none','r',2);
%
   [ax] = graph1D_jd(x_fit(1:10:end,1:2:end),y_fit(1:10:end,1:2:end),0,0,'','','',NaN,[xmin,xmax],[ymin,ymax],'-','none','b',1);drawnow
   [ax] = graph1D_jd(x_fit(:,:)',y_fit(:,:)',0,0,'x(m)','y(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[xmin,xmax],[ymin,ymax],'-','none','b',1);
%
   [ax] = graph1D_jd(x_fit1(1:10:end,1:2:end),y_fit1(1:10:end,1:2:end),0,0,'','','',NaN,[xmin,xmax],[ymin,ymax],'--','none','c',1);drawnow
   [ax] = graph1D_jd(x_fit1(:,:)',y_fit1(:,:)',0,0,'x(m)','y(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[xmin,xmax],[ymin,ymax],'--','none','c',1);
   axis('equal');drawnow  
%
else
   [Te,dTedrho,d2Tedrho2,ne,dnedrho,d2nedrho2,zTi,dzTidrho,d2zTidrho2,zni,dznidrho,d2znidrho2,...
        x,dxdtheta,d2xdtheta2,dxdrho,d2xdthetadrho,y,dydtheta,d2ydtheta2,dydrho,d2ydthetadrho,...
        r,drdtheta,drdrho,salpha,dsalphadtheta,dsalphadrho,calpha,dcalphadtheta,dcalphadrho,...
        Bx,dBxdtheta,d2Bxdtheta2,dBxdrho,d2Bxdthetadrho,...
        By,dBydtheta,d2Bydtheta2,dBydrho,d2Bydthetadrho,...
        Bz,dBzdtheta,d2Bzdtheta2,dBzdrho,d2Bzdthetadrho,...
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
      disp(['equil_fit.Bz_fit.n = ',num2str(equil_fit.Bz_fit.n(end))]);
      disp(['equil_fit.Bz_fit.bn_f.coefs(1) = ',num2str(equil_fit.Bz_fit.pp_bn.coefs(1))]);
      disp(['equil_fit.Bz_fit.bn_f.coefs(1) = ',num2str(equil_fit.Bz_fit.pp_dbndrho.coefs(1))]);
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
      disp(['x(',num2str(rho),',',num2str(theta),'),dxdrho(',num2str(rho),',',num2str(theta),'),dxdtheta(',num2str(rho),',',num2str(theta),'),d2xdtheta2(',num2str(rho),',',num2str(theta),'),d2xdthetadrho(',num2str(rho),',',num2str(theta),') (m) = ',num2str(x),',',num2str(dxdrho),',',num2str(dxdtheta),',',num2str(d2xdtheta2),',',num2str(d2xdthetadrho)]);
      disp(['y(',num2str(rho),',',num2str(theta),'),dydrho(',num2str(rho),',',num2str(theta),'),dydtheta(',num2str(rho),',',num2str(theta),'),d2ydtheta2(',num2str(rho),',',num2str(theta),'),d2ydthetadrho(',num2str(rho),',',num2str(theta),') (m) = ',num2str(y),',',num2str(dydrho),',',num2str(dydtheta),',',num2str(d2ydtheta2),',',num2str(d2ydthetadrho)]);
      disp(['r(',num2str(rho),',',num2str(theta),'),drdrho(',num2str(rho),',',num2str(theta),'),drdtheta(',num2str(rho),',',num2str(theta),') (m) = ',num2str(r),',',num2str(drdrho),',',num2str(drdtheta)]);
      disp(['Bx(',num2str(rho),',',num2str(theta),'),dBxdrho(',num2str(rho),',',num2str(theta),'),dBxdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(Bx),',',num2str(dBxdrho),',',num2str(dBxdtheta)]);
      disp(['By(',num2str(rho),',',num2str(theta),'),dBydrho(',num2str(rho),',',num2str(theta),'),dBydtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(By),',',num2str(dBydrho),',',num2str(dBydtheta)]);
      disp(['Bz(',num2str(rho),',',num2str(theta),'),dBzdrho(',num2str(rho),',',num2str(theta),'),dBzdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(Bz),',',num2str(dBzdrho),',',num2str(dBzdtheta)]);
      disp(['BP(',num2str(rho),',',num2str(theta),'),dBPdrho(',num2str(rho),',',num2str(theta),'),dBPdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(BP),',',num2str(dBPdrho),',',num2str(dBPdtheta)]);
      disp(['B(',num2str(rho),',',num2str(theta),'),dBdrho(',num2str(rho),',',num2str(theta),'),dBdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(B),',',num2str(dBdrho),',',num2str(dBdtheta)]);
      disp(['calpha(',num2str(rho),',',num2str(theta),'),dcalphadrho(',num2str(rho),',',num2str(theta),'),dcalphadtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(calpha),',',num2str(dcalphadrho),',',num2str(dcalphadtheta)]);
      disp(['salpha(',num2str(rho),',',num2str(theta),'),dsalphadrho(',num2str(rho),',',num2str(theta),'),dsalphadtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(salpha),',',num2str(dsalphadrho),',',num2str(dsalphadtheta)]);
      disp(['gradrhon(',num2str(rho),',',num2str(theta),'),dgradrhondrho(',num2str(rho),',',num2str(theta),'),dgradrhondtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(gradrhon),',',num2str(dgradrhondrho),',',num2str(dgradrhondtheta)]);
   end
end

