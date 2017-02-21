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
close all
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
sigmaIp = sign(equil_in.psi_apRp(end));
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
calpha = (x.*By - y.*Bx)./BP./r;%cos(alpha)
calpha(1,:) = calpha(2,:);%cos(alpha)
salpha = sigmaIp*(x.*Bx + y.*By)./BP./r;%cos(alpha)
salpha(1,:) = salpha(2,:);%cos(alpha)
%
% Numerical calculation of derivatives 
%
[drdtheta,drdrho] = gradient(r);%r
drdtheta = drdtheta./(ones(length(dprho),1)*dtheta);%1st order derivative
drdrho = drdrho./(dprho(:)*ones(1,length(dtheta)));%1st order derivative
[d2rdtheta2,d2rdthetadrho] = gradient(drdtheta);
[d2rdrhodtheta,d2rdrho2] = gradient(drdrho);
d2rdtheta2 = d2rdtheta2./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2rdthetadrho = d2rdthetadrho./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
d2rdrhodtheta = d2rdrhodtheta./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2rdrho2 = d2rdrho2./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
%
[dxdtheta,dxdrho] = gradient(x);%Xx
dxdtheta = dxdtheta./(ones(length(dprho),1)*dtheta);
dxdrho = dxdrho./(dprho(:)*ones(1,length(dtheta)));
[d2xdtheta2,d2xdthetadrho] = gradient(dxdtheta);
[d2xdrhodtheta,d2xdrho2] = gradient(dxdrho);
d2xdtheta2 = d2xdtheta2./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2xdthetadrho = d2xdthetadrho./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
d2xdrhodtheta = d2xdrhodtheta./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2xdrho2 = d2xdrho2./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
%
[dydtheta,dydrho] = gradient(y);%Xy
dydtheta = dydtheta./(ones(length(dprho),1)*dtheta);
dydrho = dydrho./(dprho(:)*ones(1,length(dtheta)));
[d2ydtheta2,d2ydthetadrho] = gradient(dydtheta);
[d2ydrhodtheta,d2ydrho2] = gradient(dydrho);
d2ydtheta2 = d2ydtheta2./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2ydthetadrho = d2ydthetadrho./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
d2xdrhodtheta = d2ydrhodtheta./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2ydrho2 = d2ydrho2./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
%
[dcalphadtheta,dcalphadrho] = gradient(calpha);%
dcalphadtheta = dcalphadtheta./(ones(length(dprho),1)*dtheta);
dcalphadrho = dcalphadrho./(dprho(:)*ones(1,length(dtheta)));
[d2calphadtheta2,d2calphadthetadrho] = gradient(dcalphadtheta);
[d2calphadrhodtheta,d2calphadrho2] = gradient(dcalphadrho);
d2calphadtheta2 = d2calphadtheta2./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2calphadthetadrho = d2calphadthetadrho./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
d2calphadrhodtheta = d2calphadrhodtheta./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2calphadrho2 = d2calphadrho2./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
%
[dsalphadtheta,dsalphadrho] = gradient(salpha);%
dsalphadtheta = dsalphadtheta./(ones(length(dprho),1)*dtheta);
dsalphadrho = dsalphadrho./(dprho(:)*ones(1,length(dtheta)));
[d2salphadtheta2,d2salphadthetadrho] = gradient(dsalphadtheta);
[d2salphadrhodtheta,d2salphadrho2] = gradient(dsalphadrho);
d2salphadtheta2 = d2salphadtheta2./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2salphadthetadrho = d2salphadthetadrho./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
d2salphadrhodtheta = d2salphadrhodtheta./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2salphadrho2 = d2salphadrho2./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
%
[dBzdtheta,dBzdrho] = gradient(Bz);%Toroidal magnetic field
dBzdtheta = dBzdtheta./(ones(length(dprho),1)*dtheta);
dBzdrho = dBzdrho./(dprho(:)*ones(1,length(dtheta)));
[d2Bzdtheta2,d2Bzdthetadrho] = gradient(dBzdtheta);
[d2Bzdrhodtheta,d2Bzdrho2] = gradient(dBzdrho);
d2Bzdtheta2 = d2Bzdtheta2./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2Bzdthetadrho = d2Bzdthetadrho./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
d2Bzdrhodtheta = d2Bzdrhodtheta./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2Bzdrho2 = d2Bzdrho2./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
%
[dBPdtheta,dBPdrho] = gradient(BP);%Poloidal magnetic field
dBPdtheta = dBPdtheta./(ones(length(dprho),1)*dtheta);
dBPdrho = dBPdrho./(dprho(:)*ones(1,length(dtheta)));
[d2BPdtheta2,d2BPdthetadrho] = gradient(dBPdtheta);
[d2BPdrhodtheta,d2BPdrho2] = gradient(dBPdrho);
d2BPdtheta2 = d2BPdtheta2./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2BPdthetadrho = d2BPdthetadrho./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
d2BPdrhodtheta = d2BPdrhodtheta./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2BPdrho2 = d2BPdrho2./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
%
[dBdtheta,dBdrho] = gradient(B);%Total magnetic field
dBdtheta = dBdtheta./(ones(length(dprho),1)*dtheta);
dBdrho = dBdrho./(dprho(:)*ones(1,length(dtheta)));
[d2Bdtheta2,d2Bdthetadrho] = gradient(dBdtheta);
[d2Bdrhodtheta,d2Bdrho2] = gradient(dBdrho);
d2Bdtheta2 = d2Bdtheta2./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2Bdthetadrho = d2Bdthetadrho./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
d2Bdrhodtheta = d2Bdrhodtheta./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2Bdrho2 = d2Bdrho2./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
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
gradrho = Upsilon.*BP.*(dxstardpsin*ones(1,size(x,2)))/abs(equil_fit.psia_apRp);
%
[dgradrhodtheta,dgradrhodrho] = gradient(gradrho);%rho gradient
dgradrhodtheta = dgradrhodtheta./(ones(length(dprho),1)*dtheta);
dgradrhodrho = dgradrhodrho./(dprho(:)*ones(1,length(dtheta)));
[d2gradrhodtheta2,d2gradrhodthetadrho] = gradient(dgradrhodtheta);
[d2gradrhodrhodtheta,d2gradrhodrho2] = gradient(dgradrhodrho);
d2gradrhodtheta2 = d2gradrhodtheta2./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2gradrhodthetadrho = d2gradrhodthetadrho./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
d2gradrhodrhodtheta = d2gradrhodrhodtheta./(ones(length(dprho),1)*dtheta);%2nd order derivative
d2gradrhodrho2 = d2gradrhodrho2./(dprho(:)*ones(1,length(dtheta)));%2nd order derivative
%
% Calculation of derivatives with Matlab build-in interpolation using polynomials (spline...)
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
   nr = 5; 
   rho_fit1 = prho(1:nr:end);%New normalized radial grid for display 2-D magnetic field
   rho_fit1(1) = prec;
%
   dxstardpsin_fit = ppval(equil_fit.dxstardpsin_fit.pp_f,rho_fit1);dxstardpsin_fit = dxstardpsin_fit(:);
   dxstardpsin_fit1 = ppval_yp(equil_fit.dxstardpsin_fit.pp_f,rho_fit1);dxstardpsin_fit1 = dxstardpsin_fit1(:); 
   ddxstardpsindrho_fit = ppval(equil_fit.dxstardpsin_fit.pp_dfdrho,rho_fit1);ddxstardpsindrho_fit = ddxstardpsindrho_fit(:);
   ddxstardpsindrho_fit1 = ppval_yp(equil_fit.dxstardpsin_fit.pp_dfdrho,rho_fit1);ddxstardpsindrho_fit1 = ddxstardpsindrho_fit1(:);
   d2dxstardpsindrho2_fit = ppval(equil_fit.dxstardpsin_fit.pp_d2fdrho2,rho_fit1);d2dxstardpsindrho2_fit = d2dxstardpsindrho2_fit(:);
   d2dxstardpsindrho2_fit1 = ppval_yp(equil_fit.dxstardpsin_fit.pp_d2fdrho2,rho_fit1);d2dxstardpsindrho2_fit1 = d2dxstardpsindrho2_fit1(:);
%
   x_a0_fit = ppval(equil_fit.x_fit.pp_a0,rho_fit1);
   x_an_fit = ppval(equil_fit.x_fit.pp_an,rho_fit1);
   x_bn_fit = ppval(equil_fit.x_fit.pp_bn,rho_fit1);
   x_da0drho_fit = ppval(equil_fit.x_fit.pp_da0drho,rho_fit1);
   x_dandrho_fit = ppval(equil_fit.x_fit.pp_dandrho,rho_fit1);
   x_dbndrho_fit = ppval(equil_fit.x_fit.pp_dbndrho,rho_fit1);
   x_d2a0drho2_fit = ppval(equil_fit.x_fit.pp_d2a0drho2,rho_fit1);
   x_d2andrho2_fit = ppval(equil_fit.x_fit.pp_d2andrho2,rho_fit1);
   x_d2bndrho2_fit = ppval(equil_fit.x_fit.pp_d2bndrho2,rho_fit1);
%
   y_a0_fit = ppval(equil_fit.y_fit.pp_a0,rho_fit1);
   y_an_fit = ppval(equil_fit.y_fit.pp_an,rho_fit1);
   y_bn_fit = ppval(equil_fit.y_fit.pp_bn,rho_fit1);
   y_da0drho_fit = ppval(equil_fit.y_fit.pp_da0drho,rho_fit1);
   y_dandrho_fit = ppval(equil_fit.y_fit.pp_dandrho,rho_fit1);
   y_dbndrho_fit = ppval(equil_fit.y_fit.pp_dbndrho,rho_fit1);
   y_d2a0drho2_fit = ppval(equil_fit.y_fit.pp_d2a0drho2,rho_fit1);
   y_d2andrho2_fit = ppval(equil_fit.y_fit.pp_d2andrho2,rho_fit1);
   y_d2bndrho2_fit = ppval(equil_fit.y_fit.pp_d2bndrho2,rho_fit1);
%
   Bx_a0_fit = ppval(equil_fit.Bx_fit.pp_a0,rho_fit1);
   Bx_an_fit = ppval(equil_fit.Bx_fit.pp_an,rho_fit1);
   Bx_bn_fit = ppval(equil_fit.Bx_fit.pp_bn,rho_fit1);
   Bx_da0drho_fit = ppval(equil_fit.Bx_fit.pp_da0drho,rho_fit1);
   Bx_dandrho_fit = ppval(equil_fit.Bx_fit.pp_dandrho,rho_fit1);
   Bx_dbndrho_fit = ppval(equil_fit.Bx_fit.pp_dbndrho,rho_fit1);
   Bx_d2a0drho2_fit = ppval(equil_fit.Bx_fit.pp_d2a0drho2,rho_fit1);
   Bx_d2andrho2_fit = ppval(equil_fit.Bx_fit.pp_d2andrho2,rho_fit1);
   Bx_d2bndrho2_fit = ppval(equil_fit.Bx_fit.pp_d2bndrho2,rho_fit1);
%
   By_a0_fit = ppval(equil_fit.By_fit.pp_a0,rho_fit1);
   By_an_fit = ppval(equil_fit.By_fit.pp_an,rho_fit1);
   By_bn_fit = ppval(equil_fit.By_fit.pp_bn,rho_fit1);
   By_da0drho_fit = ppval(equil_fit.By_fit.pp_da0drho,rho_fit1);
   By_dandrho_fit = ppval(equil_fit.By_fit.pp_dandrho,rho_fit1);
   By_dbndrho_fit = ppval(equil_fit.By_fit.pp_dbndrho,rho_fit1);
   By_d2a0drho2_fit = ppval(equil_fit.By_fit.pp_d2a0drho2,rho_fit1);
   By_d2andrho2_fit = ppval(equil_fit.By_fit.pp_d2andrho2,rho_fit1);
   By_d2bndrho2_fit = ppval(equil_fit.By_fit.pp_d2bndrho2,rho_fit1);
%
   Bz_a0_fit = ppval(equil_fit.Bz_fit.pp_a0,rho_fit1);
   Bz_an_fit = ppval(equil_fit.Bz_fit.pp_an,rho_fit1);
   Bz_bn_fit = ppval(equil_fit.Bz_fit.pp_bn,rho_fit1);
   Bz_da0drho_fit = ppval(equil_fit.Bz_fit.pp_da0drho,rho_fit1);
   Bz_dandrho_fit = ppval(equil_fit.Bz_fit.pp_dandrho,rho_fit1);
   Bz_dbndrho_fit = ppval(equil_fit.Bz_fit.pp_dbndrho,rho_fit1);
   Bz_d2a0drho2_fit = ppval(equil_fit.Bz_fit.pp_d2a0drho2,rho_fit1);
   Bz_d2andrho2_fit = ppval(equil_fit.Bz_fit.pp_d2andrho2,rho_fit1);
   Bz_d2bndrho2_fit = ppval(equil_fit.Bz_fit.pp_d2bndrho2,rho_fit1);
%
   B_a0_fit = ppval(equil_fit.B_fit.pp_a0,rho_fit1);
   B_an_fit = ppval(equil_fit.B_fit.pp_an,rho_fit1);
   B_bn_fit = ppval(equil_fit.B_fit.pp_bn,rho_fit1);
   B_da0drho_fit = ppval(equil_fit.B_fit.pp_da0drho,rho_fit1);
   B_dandrho_fit = ppval(equil_fit.B_fit.pp_dandrho,rho_fit1);
   B_dbndrho_fit = ppval(equil_fit.B_fit.pp_dbndrho,rho_fit1);
   B_d2a0drho2_fit = ppval(equil_fit.B_fit.pp_d2a0drho2,rho_fit1);
   B_d2andrho2_fit = ppval(equil_fit.B_fit.pp_d2andrho2,rho_fit1);
   B_d2bndrho2_fit = ppval(equil_fit.B_fit.pp_d2bndrho2,rho_fit1);
%
   BP_a0_fit = ppval(equil_fit.BP_fit.pp_a0,rho_fit1);
   BP_an_fit = ppval(equil_fit.BP_fit.pp_an,rho_fit1);
   BP_bn_fit = ppval(equil_fit.BP_fit.pp_bn,rho_fit1);
   BP_da0drho_fit = ppval(equil_fit.BP_fit.pp_da0drho,rho_fit1);
   BP_dandrho_fit = ppval(equil_fit.BP_fit.pp_dandrho,rho_fit1);
   BP_dbndrho_fit = ppval(equil_fit.BP_fit.pp_dbndrho,rho_fit1);
   BP_d2a0drho2_fit = ppval(equil_fit.BP_fit.pp_d2a0drho2,rho_fit1);
   BP_d2andrho2_fit = ppval(equil_fit.BP_fit.pp_d2andrho2,rho_fit1);
   BP_d2bndrho2_fit = ppval(equil_fit.BP_fit.pp_d2bndrho2,rho_fit1);
%
   r_a0_fit = ppval(equil_fit.r_fit.pp_a0,rho_fit1);
   r_an_fit = ppval(equil_fit.r_fit.pp_an,rho_fit1);
   r_bn_fit = ppval(equil_fit.r_fit.pp_bn,rho_fit1);
   r_da0drho_fit = ppval(equil_fit.r_fit.pp_da0drho,rho_fit1);
   r_dandrho_fit = ppval(equil_fit.r_fit.pp_dandrho,rho_fit1);
   r_dbndrho_fit = ppval(equil_fit.r_fit.pp_dbndrho,rho_fit1); 
   r_d2a0drho2_fit = ppval(equil_fit.r_fit.pp_d2a0drho2,rho_fit1);
   r_d2andrho2_fit = ppval(equil_fit.r_fit.pp_d2andrho2,rho_fit1);
   r_d2bndrho2_fit = ppval(equil_fit.r_fit.pp_d2bndrho2,rho_fit1);   
%
   calpha_a0_fit = ppval(equil_fit.calpha_fit.pp_a0,rho_fit1);
   calpha_an_fit = ppval(equil_fit.calpha_fit.pp_an,rho_fit1);
   calpha_bn_fit = ppval(equil_fit.calpha_fit.pp_bn,rho_fit1);
   calpha_da0drho_fit = ppval(equil_fit.calpha_fit.pp_da0drho,rho_fit1);
   calpha_dandrho_fit = ppval(equil_fit.calpha_fit.pp_dandrho,rho_fit1);
   calpha_dbndrho_fit = ppval(equil_fit.calpha_fit.pp_dbndrho,rho_fit1);
   calpha_d2a0drho2_fit = ppval(equil_fit.calpha_fit.pp_d2a0drho2,rho_fit1);
   calpha_d2andrho2_fit = ppval(equil_fit.calpha_fit.pp_d2andrho2,rho_fit1);
   calpha_d2bndrho2_fit = ppval(equil_fit.calpha_fit.pp_d2bndrho2,rho_fit1);
%
   salpha_a0_fit = ppval(equil_fit.salpha_fit.pp_a0,rho_fit1);
   salpha_an_fit = ppval(equil_fit.salpha_fit.pp_an,rho_fit1);
   salpha_bn_fit = ppval(equil_fit.salpha_fit.pp_bn,rho_fit1);
   salpha_da0drho_fit = ppval(equil_fit.salpha_fit.pp_da0drho,rho_fit1);
   salpha_dandrho_fit = ppval(equil_fit.salpha_fit.pp_dandrho,rho_fit1);
   salpha_dbndrho_fit = ppval(equil_fit.salpha_fit.pp_dbndrho,rho_fit1);
   salpha_d2a0drho2_fit = ppval(equil_fit.salpha_fit.pp_d2a0drho2,rho_fit1);
   salpha_d2andrho2_fit = ppval(equil_fit.salpha_fit.pp_d2andrho2,rho_fit1);
   salpha_d2bndrho2_fit = ppval(equil_fit.salpha_fit.pp_d2bndrho2,rho_fit1);
%
   gradrho_a0_fit = ppval(equil_fit.gradrho_fit.pp_a0,rho_fit1);
   gradrho_an_fit = ppval(equil_fit.gradrho_fit.pp_an,rho_fit1);
   gradrho_bn_fit = ppval(equil_fit.gradrho_fit.pp_bn,rho_fit1);
   gradrho_da0drho_fit = ppval(equil_fit.gradrho_fit.pp_da0drho,rho_fit1);
   gradrho_dandrho_fit = ppval(equil_fit.gradrho_fit.pp_dandrho,rho_fit1);
   gradrho_dbndrho_fit = ppval(equil_fit.gradrho_fit.pp_dbndrho,rho_fit1);
   gradrho_d2a0drho2_fit = ppval(equil_fit.gradrho_fit.pp_d2a0drho2,rho_fit1);
   gradrho_d2andrho2_fit = ppval(equil_fit.gradrho_fit.pp_d2andrho2,rho_fit1);
   gradrho_d2bndrho2_fit = ppval(equil_fit.gradrho_fit.pp_d2bndrho2,rho_fit1);
%
% Calculation of derivatives with home made interpolation using polynomials (spline...) that has a C counterpart
%
   x_a0_fit1 = ppval_yp(equil_fit.x_fit.pp_a0,rho_fit1);
   x_an_fit1 = ppval_yp(equil_fit.x_fit.pp_an,rho_fit1);
   x_bn_fit1 = ppval_yp(equil_fit.x_fit.pp_bn,rho_fit1);
   x_da0drho_fit1 = ppval_yp(equil_fit.x_fit.pp_da0drho,rho_fit1);
   x_dandrho_fit1 = ppval_yp(equil_fit.x_fit.pp_dandrho,rho_fit1);
   x_dbndrho_fit1 = ppval_yp(equil_fit.x_fit.pp_dbndrho,rho_fit1);
   x_d2a0drho2_fit1 = ppval_yp(equil_fit.x_fit.pp_d2a0drho2,rho_fit1);
   x_d2andrho2_fit1 = ppval_yp(equil_fit.x_fit.pp_d2andrho2,rho_fit1);
   x_d2bndrho2_fit1 = ppval_yp(equil_fit.x_fit.pp_d2bndrho2,rho_fit1);
%
   y_a0_fit1 = ppval_yp(equil_fit.y_fit.pp_a0,rho_fit1);
   y_an_fit1 = ppval_yp(equil_fit.y_fit.pp_an,rho_fit1);
   y_bn_fit1 = ppval_yp(equil_fit.y_fit.pp_bn,rho_fit1);
   y_da0drho_fit1 = ppval_yp(equil_fit.y_fit.pp_da0drho,rho_fit1);
   y_dandrho_fit1 = ppval_yp(equil_fit.y_fit.pp_dandrho,rho_fit1);
   y_dbndrho_fit1 = ppval_yp(equil_fit.y_fit.pp_dbndrho,rho_fit1);
   y_d2a0drho2_fit1 = ppval_yp(equil_fit.y_fit.pp_d2a0drho2,rho_fit1);
   y_d2andrho2_fit1 = ppval_yp(equil_fit.y_fit.pp_d2andrho2,rho_fit1);
   y_d2bndrho2_fit1 = ppval_yp(equil_fit.y_fit.pp_d2bndrho2,rho_fit1);
%
   Bx_a0_fit1 = ppval_yp(equil_fit.Bx_fit.pp_a0,rho_fit1);
   Bx_an_fit1 = ppval_yp(equil_fit.Bx_fit.pp_an,rho_fit1);
   Bx_bn_fit1 = ppval_yp(equil_fit.Bx_fit.pp_bn,rho_fit1);
   Bx_da0drho_fit1 = ppval_yp(equil_fit.Bx_fit.pp_da0drho,rho_fit1);
   Bx_dandrho_fit1 = ppval_yp(equil_fit.Bx_fit.pp_dandrho,rho_fit1);
   Bx_dbndrho_fit1 = ppval_yp(equil_fit.Bx_fit.pp_dbndrho,rho_fit1);
   Bx_d2a0drho2_fit1 = ppval_yp(equil_fit.Bx_fit.pp_d2a0drho2,rho_fit1);
   Bx_d2andrho2_fit1 = ppval_yp(equil_fit.Bx_fit.pp_d2andrho2,rho_fit1);
   Bx_d2bndrho2_fit1 = ppval_yp(equil_fit.Bx_fit.pp_d2bndrho2,rho_fit1);
%
   By_a0_fit1 = ppval_yp(equil_fit.By_fit.pp_a0,rho_fit1);
   By_an_fit1 = ppval_yp(equil_fit.By_fit.pp_an,rho_fit1);
   By_bn_fit1 = ppval_yp(equil_fit.By_fit.pp_bn,rho_fit1);
   By_da0drho_fit1 = ppval_yp(equil_fit.By_fit.pp_da0drho,rho_fit1);
   By_dandrho_fit1 = ppval_yp(equil_fit.By_fit.pp_dandrho,rho_fit1);
   By_dbndrho_fit1 = ppval_yp(equil_fit.By_fit.pp_dbndrho,rho_fit1);
   By_d2a0drho2_fit1 = ppval_yp(equil_fit.By_fit.pp_d2a0drho2,rho_fit1);
   By_d2andrho2_fit1 = ppval_yp(equil_fit.By_fit.pp_d2andrho2,rho_fit1);
   By_d2bndrho2_fit1 = ppval_yp(equil_fit.By_fit.pp_d2bndrho2,rho_fit1);
%
   Bz_a0_fit1 = ppval_yp(equil_fit.Bz_fit.pp_a0,rho_fit1);
   Bz_an_fit1 = ppval_yp(equil_fit.Bz_fit.pp_an,rho_fit1);
   Bz_bn_fit1 = ppval_yp(equil_fit.Bz_fit.pp_bn,rho_fit1);
   Bz_da0drho_fit1 = ppval_yp(equil_fit.Bz_fit.pp_da0drho,rho_fit1);
   Bz_dandrho_fit1 = ppval_yp(equil_fit.Bz_fit.pp_dandrho,rho_fit1);
   Bz_dbndrho_fit1 = ppval_yp(equil_fit.Bz_fit.pp_dbndrho,rho_fit1);
   Bz_d2a0drho2_fit1 = ppval_yp(equil_fit.Bz_fit.pp_d2a0drho2,rho_fit1);
   Bz_d2andrho2_fit1 = ppval_yp(equil_fit.Bz_fit.pp_d2andrho2,rho_fit1);
   Bz_d2bndrho2_fit1 = ppval_yp(equil_fit.Bz_fit.pp_d2bndrho2,rho_fit1);
%
   B_a0_fit1 = ppval_yp(equil_fit.B_fit.pp_a0,rho_fit1);
   B_an_fit1 = ppval_yp(equil_fit.B_fit.pp_an,rho_fit1);
   B_bn_fit1 = ppval_yp(equil_fit.B_fit.pp_bn,rho_fit1);
   B_da0drho_fit1 = ppval_yp(equil_fit.B_fit.pp_da0drho,rho_fit1);
   B_dandrho_fit1 = ppval_yp(equil_fit.B_fit.pp_dandrho,rho_fit1);
   B_dbndrho_fit1 = ppval_yp(equil_fit.B_fit.pp_dbndrho,rho_fit1);
   B_d2a0drho2_fit1 = ppval_yp(equil_fit.B_fit.pp_d2a0drho2,rho_fit1);
   B_d2andrho2_fit1 = ppval_yp(equil_fit.B_fit.pp_d2andrho2,rho_fit1);
   B_d2bndrho2_fit1 = ppval_yp(equil_fit.B_fit.pp_d2bndrho2,rho_fit1);
%
   BP_a0_fit1 = ppval_yp(equil_fit.BP_fit.pp_a0,rho_fit1);
   BP_an_fit1 = ppval_yp(equil_fit.BP_fit.pp_an,rho_fit1);
   BP_bn_fit1 = ppval_yp(equil_fit.BP_fit.pp_bn,rho_fit1);
   BP_da0drho_fit1 = ppval_yp(equil_fit.BP_fit.pp_da0drho,rho_fit1);
   BP_dandrho_fit1 = ppval_yp(equil_fit.BP_fit.pp_dandrho,rho_fit1);
   BP_dbndrho_fit1 = ppval_yp(equil_fit.BP_fit.pp_dbndrho,rho_fit1);
   BP_d2a0drho2_fit1 = ppval_yp(equil_fit.BP_fit.pp_d2a0drho2,rho_fit1);
   BP_d2andrho2_fit1 = ppval_yp(equil_fit.BP_fit.pp_d2andrho2,rho_fit1);
   BP_d2bndrho2_fit1 = ppval_yp(equil_fit.BP_fit.pp_d2bndrho2,rho_fit1);
%
   r_a0_fit1 = ppval_yp(equil_fit.r_fit.pp_a0,rho_fit1);
   r_an_fit1 = ppval_yp(equil_fit.r_fit.pp_an,rho_fit1);
   r_bn_fit1 = ppval_yp(equil_fit.r_fit.pp_bn,rho_fit1);
   r_da0drho_fit1 = ppval_yp(equil_fit.r_fit.pp_da0drho,rho_fit1);
   r_dandrho_fit1 = ppval_yp(equil_fit.r_fit.pp_dandrho,rho_fit1);
   r_dbndrho_fit1 = ppval_yp(equil_fit.r_fit.pp_dbndrho,rho_fit1);
   r_d2a0drho2_fit1 = ppval_yp(equil_fit.r_fit.pp_d2a0drho2,rho_fit1);
   r_d2andrho2_fit1 = ppval_yp(equil_fit.r_fit.pp_d2andrho2,rho_fit1);
   r_d2bndrho2_fit1 = ppval_yp(equil_fit.r_fit.pp_d2bndrho2,rho_fit1);
%
   calpha_a0_fit1 = ppval_yp(equil_fit.calpha_fit.pp_a0,rho_fit1);
   calpha_an_fit1 = ppval_yp(equil_fit.calpha_fit.pp_an,rho_fit1);
   calpha_bn_fit1 = ppval_yp(equil_fit.calpha_fit.pp_bn,rho_fit1);
   calpha_da0drho_fit1 = ppval_yp(equil_fit.calpha_fit.pp_da0drho,rho_fit1);
   calpha_dandrho_fit1 = ppval_yp(equil_fit.calpha_fit.pp_dandrho,rho_fit1);
   calpha_dbndrho_fit1 = ppval_yp(equil_fit.calpha_fit.pp_dbndrho,rho_fit1);
   calpha_d2a0drho2_fit1 = ppval_yp(equil_fit.calpha_fit.pp_d2a0drho2,rho_fit1);
   calpha_d2andrho2_fit1 = ppval_yp(equil_fit.calpha_fit.pp_d2andrho2,rho_fit1);
   calpha_d2bndrho2_fit1 = ppval_yp(equil_fit.calpha_fit.pp_d2bndrho2,rho_fit1);
%
   salpha_a0_fit1 = ppval_yp(equil_fit.salpha_fit.pp_a0,rho_fit1);
   salpha_an_fit1 = ppval_yp(equil_fit.salpha_fit.pp_an,rho_fit1);
   salpha_bn_fit1 = ppval_yp(equil_fit.salpha_fit.pp_bn,rho_fit1);
   salpha_da0drho_fit1 = ppval_yp(equil_fit.salpha_fit.pp_da0drho,rho_fit1);
   salpha_dandrho_fit1 = ppval_yp(equil_fit.salpha_fit.pp_dandrho,rho_fit1);
   salpha_dbndrho_fit1 = ppval_yp(equil_fit.salpha_fit.pp_dbndrho,rho_fit1);
   salpha_d2a0drho2_fit1 = ppval_yp(equil_fit.salpha_fit.pp_d2a0drho2,rho_fit1);
   salpha_d2andrho2_fit1 = ppval_yp(equil_fit.salpha_fit.pp_d2andrho2,rho_fit1);
   salpha_d2bndrho2_fit1 = ppval_yp(equil_fit.salpha_fit.pp_d2bndrho2,rho_fit1);
%
   gradrho_a0_fit1 = ppval_yp(equil_fit.gradrho_fit.pp_a0,rho_fit1);
   gradrho_an_fit1 = ppval_yp(equil_fit.gradrho_fit.pp_an,rho_fit1);
   gradrho_bn_fit1 = ppval_yp(equil_fit.gradrho_fit.pp_bn,rho_fit1);
   gradrho_da0drho_fit1 = ppval_yp(equil_fit.gradrho_fit.pp_da0drho,rho_fit1);
   gradrho_dandrho_fit1 = ppval_yp(equil_fit.gradrho_fit.pp_dandrho,rho_fit1);
   gradrho_dbndrho_fit1 = ppval_yp(equil_fit.gradrho_fit.pp_dbndrho,rho_fit1);
   gradrho_d2a0drho2_fit1 = ppval_yp(equil_fit.gradrho_fit.pp_d2a0drho2,rho_fit1);
   gradrho_d2andrho2_fit1 = ppval_yp(equil_fit.gradrho_fit.pp_d2andrho2,rho_fit1);
   gradrho_d2bndrho2_fit1 = ppval_yp(equil_fit.gradrho_fit.pp_d2bndrho2,rho_fit1);
%
% Build interpolated quantities
%
   for ii = 1:ntheta_fit, 
      [x_fit(:,ii),dxdtheta_fit(:,ii),d2xdtheta2_fit(:,ii),dxdrho_fit(:,ii),d2xdthetadrho_fit(:,ii),d2xdrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),x_a0_fit(:),x_an_fit,x_bn_fit,x_da0drho_fit(:),x_dandrho_fit,x_dbndrho_fit,x_d2a0drho2_fit(:),x_d2andrho2_fit,x_d2bndrho2_fit);
      [y_fit(:,ii),dydtheta_fit(:,ii),d2ydtheta2_fit(:,ii),dydrho_fit(:,ii),d2ydthetadrho_fit(:,ii),d2ydrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),y_a0_fit(:),y_an_fit,y_bn_fit,y_da0drho_fit(:),y_dandrho_fit,y_dbndrho_fit,y_d2a0drho2_fit(:),y_d2andrho2_fit,y_d2bndrho2_fit);
      %
      [r_fit(:,ii),drdtheta_fit(:,ii),d2rdtheta2_fit(:,ii),drdrho_fit(:,ii),d2rdthetadrho_fit(:,ii),d2rdrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),r_a0_fit(:),r_an_fit,r_bn_fit,r_da0drho_fit(:),r_dandrho_fit,r_dbndrho_fit,r_d2a0drho2_fit(:),r_d2andrho2_fit,r_d2bndrho2_fit);
      %
      [Bx_fit(:,ii),dBxdtheta_fit(:,ii),d2Bxdtheta2_fit(:,ii),dBxdrho_fit(:,ii),d2Bxdthetadrho_fit(:,ii),d2Bxdrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),Bx_a0_fit(:),Bx_an_fit,Bx_bn_fit,Bx_da0drho_fit(:),Bx_dandrho_fit,Bx_dbndrho_fit,Bx_d2a0drho2_fit(:),Bx_d2andrho2_fit,Bx_d2bndrho2_fit);
      [By_fit(:,ii),dBydtheta_fit(:,ii),d2Bydtheta2_fit(:,ii),dBydrho_fit(:,ii),d2Bydthetadrho_fit(:,ii),d2Bydrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),By_a0_fit(:),By_an_fit,By_bn_fit,By_da0drho_fit(:),By_dandrho_fit,By_dbndrho_fit,By_d2a0drho2_fit(:),By_d2andrho2_fit,By_d2bndrho2_fit);
      [Bz_fit(:,ii),dBzdtheta_fit(:,ii),d2Bzdtheta2_fit(:,ii),dBzdrho_fit(:,ii),d2Bzdthetadrho_fit(:,ii),d2Bzdrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),Bz_a0_fit(:),Bz_an_fit,Bz_bn_fit,Bz_da0drho_fit(:),Bz_dandrho_fit,Bz_dbndrho_fit,Bz_d2a0drho2_fit(:),Bz_d2andrho2_fit,Bz_d2bndrho2_fit);
      %
      [B_fit(:,ii),dBdtheta_fit(:,ii),d2Bdtheta2_fit(:,ii),dBdrho_fit(:,ii),d2Bdthetadrho_fit(:,ii),d2Bdrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),B_a0_fit(:),B_an_fit,B_bn_fit,B_da0drho_fit(:),B_dandrho_fit,B_dbndrho_fit,B_d2a0drho2_fit(:),B_d2andrho2_fit,B_d2bndrho2_fit);
      [BP_fit(:,ii),dBPdtheta_fit(:,ii),d2BPdtheta2_fit(:,ii),dBPdrho_fit(:,ii),d2BPdthetadrho_fit(:,ii),d2BPdrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),BP_a0_fit(:),BP_an_fit,BP_bn_fit,BP_da0drho_fit(:),BP_dandrho_fit,BP_dbndrho_fit,BP_d2a0drho2_fit(:),BP_d2andrho2_fit,BP_d2bndrho2_fit);
      %
      [calpha_fit(:,ii),dcalphadtheta_fit(:,ii),d2calphadtheta2_fit(:,ii),dcalphadrho_fit(:,ii),d2calphadthetadrho_fit(:,ii),d2calphadrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),calpha_a0_fit(:),calpha_an_fit,calpha_bn_fit,calpha_da0drho_fit(:),calpha_dandrho_fit,calpha_dbndrho_fit,calpha_d2a0drho2_fit(:),calpha_d2andrho2_fit,calpha_d2bndrho2_fit);
      [salpha_fit(:,ii),dsalphadtheta_fit(:,ii),d2salphadtheta2_fit(:,ii),dsalphadrho_fit(:,ii),d2salphadthetadrho_fit(:,ii),d2salphadrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),salpha_a0_fit(:),salpha_an_fit,salpha_bn_fit,salpha_da0drho_fit(:),salpha_dandrho_fit,salpha_dbndrho_fit,salpha_d2a0drho2_fit(:),salpha_d2andrho2_fit,salpha_d2bndrho2_fit);     
      %
      [gradrho_fit(:,ii),dgradrhodtheta_fit(:,ii),d2gradrhodtheta2_fit(:,ii),dgradrhodrho_fit(:,ii),d2gradrhodthetadrho_fit(:,ii),d2gradrhodrho2_fit(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),gradrho_a0_fit(:),gradrho_an_fit,gradrho_bn_fit,gradrho_da0drho_fit(:),gradrho_dandrho_fit,gradrho_dbndrho_fit,gradrho_d2a0drho2_fit(:),gradrho_d2andrho2_fit,gradrho_d2bndrho2_fit);     
      %
      if isinf(Rp),
         Upsilon_fit = ones(size(x_fit(:,ii)));
         dUpsilondrho_fit = zeros(size(x_fit(:,ii)));
         dUpsilondtheta_fit = zeros(size(x_fit(:,ii)));
         d2Upsilondtheta2_fit = zeros(size(x_fit(:,ii)));
         d2Upsilondthetadrho_fit = zeros(size(x_fit(:,ii)));
         d2Upsilondrho2_fit = zeros(size(x_fit(:,ii)));
      else
         Upsilon_fit = 1 + x_fit(:,ii)/Rp;
         dUpsilondrho_fit = dxdrho_fit(:,ii)/Rp;
         dUpsilondtheta_fit =  dxdtheta_fit(:,ii)/Rp;
         d2Upsilondtheta2_fit = d2xdtheta2_fit(:,ii)/Rp;
         d2Upsilondthetadrho_fit = d2xdthetadrho_fit(:,ii)/Rp;
         d2Upsilondrho2_fit = d2xdrho2_fit(:,ii)/Rp;

      end
      %
      [x_fit1(:,ii),dxdtheta_fit1(:,ii),d2xdtheta2_fit1(:,ii),dxdrho_fit1(:,ii),d2xdthetadrho_fit1(:,ii),d2xdrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),x_a0_fit1,x_an_fit1,x_bn_fit,x_da0drho_fit1,x_dandrho_fit1,x_dbndrho_fit1,x_d2a0drho2_fit1,x_d2andrho2_fit1,x_d2bndrho2_fit1);
      [y_fit1(:,ii),dydtheta_fit1(:,ii),d2ydtheta2_fit1(:,ii),dydrho_fit1(:,ii),d2ydthetadrho_fit1(:,ii),d2ydrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),y_a0_fit1,y_an_fit1,y_bn_fit,y_da0drho_fit1,y_dandrho_fit1,y_dbndrho_fit1,y_d2a0drho2_fit1,y_d2andrho2_fit1,y_d2bndrho2_fit1);
      %
      [r_fit1(:,ii),drdtheta_fit1(:,ii),d2rdtheta2_fit1(:,ii),drdrho_fit1(:,ii),d2rdthetadrho_fit1(:,ii),d2rdrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),r_a0_fit1,r_an_fit1,r_bn_fit,r_da0drho_fit1,r_dandrho_fit1,r_dbndrho_fit1,r_d2a0drho2_fit1,r_d2andrho2_fit1,r_d2bndrho2_fit1);      
      %
      [Bx_fit1(:,ii),dBxdtheta_fit1(:,ii),d2Bxdtheta2_fit1(:,ii),dBxdrho_fit1(:,ii),d2Bxdthetadrho_fit1(:,ii),d2Bxdrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),Bx_a0_fit1,Bx_an_fit1,Bx_bn_fit1,Bx_da0drho_fit1,Bx_dandrho_fit1,Bx_dbndrho_fit1,Bx_d2a0drho2_fit1,Bx_d2andrho2_fit1,Bx_d2bndrho2_fit1);
      [By_fit1(:,ii),dBydtheta_fit1(:,ii),d2Bydtheta2_fit1(:,ii),dBydrho_fit1(:,ii),d2Bydthetadrho_fit1(:,ii),d2Bxydrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),By_a0_fit1,By_an_fit1,By_bn_fit1,By_da0drho_fit1,By_dandrho_fit1,By_dbndrho_fit1,By_d2a0drho2_fit1,By_d2andrho2_fit1,By_d2bndrho2_fit1);
      [Bz_fit1(:,ii),dBzdtheta_fit1(:,ii),d2Bzdtheta2_fit1(:,ii),dBzdrho_fit1(:,ii),d2Bzdthetadrho_fit1(:,ii),d2Bzdrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),Bz_a0_fit1,Bz_an_fit1,Bz_bn_fit1,Bz_da0drho_fit1,Bz_dandrho_fit1,Bz_dbndrho_fit1,Bz_d2a0drho2_fit1,Bz_d2andrho2_fit1,Bz_d2bndrho2_fit1);
      %
      [B_fit1(:,ii),dBdtheta_fit1(:,ii),d2Bdtheta2_fit1(:,ii),dBdrho_fit1(:,ii),d2Bdthetadrho_fit1(:,ii),d2Bdrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),B_a0_fit1,B_an_fit1,B_bn_fit1,B_da0drho_fit1,B_dandrho_fit1,B_dbndrho_fit1,B_d2a0drho2_fit1,B_d2andrho2_fit1,B_d2bndrho2_fit1);
      [BP_fit1(:,ii),dBPdtheta_fit1(:,ii),d2BPdtheta2_fit1(:,ii),dBPdrho_fit1(:,ii),d2BPdthetadrho_fit1(:,ii),d2BPdrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),BP_a0_fit1,BP_an_fit1,BP_bn_fit1,BP_da0drho_fit1,BP_dandrho_fit1,BP_dbndrho_fit1,BP_d2a0drho2_fit1,BP_d2andrho2_fit1,BP_d2bndrho2_fit1);
      %
      [calpha_fit1(:,ii),dcalphadtheta_fit1(:,ii),d2calphadtheta2_fit1(:,ii),dcalphadrho_fit1(:,ii),d2calphadthetadrho_fit1(:,ii),d2calphadrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),calpha_a0_fit1,calpha_an_fit1,calpha_bn_fit1,calpha_da0drho_fit1,calpha_dandrho_fit1,calpha_dbndrho_fit1,calpha_d2a0drho2_fit1,calpha_d2andrho2_fit1,calpha_d2bndrho2_fit1);
      [salpha_fit1(:,ii),dsalphadtheta_fit1(:,ii),d2salphadtheta2_fit1(:,ii),dsalphadrho_fit1(:,ii),d2salphadthetadrho_fit1(:,ii),d2salphadrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),salpha_a0_fit1,salpha_an_fit1,salpha_bn_fit1,salpha_da0drho_fit1,salpha_dandrho_fit1,salpha_dbndrho_fit1,salpha_d2a0drho2_fit1,salpha_d2andrho2_fit1,salpha_d2bndrho2_fit1);
      %
      [gradrho_fit1(:,ii),dgradrhodtheta_fit1(:,ii),d2gradrhodtheta2_fit1(:,ii),dgradrhodrho_fit1(:,ii),d2gradrhodthetadrho_fit1(:,ii),d2gradrhodrho2_fit1(:,ii)] = calcval_yp(equil_fit,theta_fit(ii),gradrho_a0_fit1(:),gradrho_an_fit1,gradrho_bn_fit1,gradrho_da0drho_fit1(:),gradrho_dandrho_fit1,gradrho_dbndrho_fit1,gradrho_d2a0drho2_fit1,gradrho_d2andrho2_fit1,gradrho_d2bndrho2_fit1);     
      %
      if isinf(Rp),
         Upsilon_fit1 = ones(size(x_fit1(:,ii)));
         dUpsilondrho_fit1 = zeros(size(x_fit1(:,ii)));
         dUpsilondtheta_fit1 = zeros(size(x_fit1(:,ii)));
         d2Upsilondtheta2_fit1 = zeros(size(x_fit1(:,ii)));
         d2Upsilondthetadrho_fit1 = zeros(size(x_fit1(:,ii)));
         d2Upsilondrho2_fit1 = zeros(size(x_fit1(:,ii)));
      else
         Upsilon_fit1 = 1 + x_fit1(:,ii)/Rp;
         dUpsilondrho_fit1 = dxdrho_fit1(:,ii)/Rp;
         dUpsilondtheta_fit1 =  dxdtheta_fit1(:,ii)/Rp;
         d2Upsilondtheta2_fit1 = d2xdtheta2_fit1(:,ii)/Rp;
         d2Upsilondthetadrho_fit1 = d2xdthetadrho_fit1(:,ii)/Rp;
         d2Upsilondrho2_fit1 = d2xdrho2_fit1(:,ii)/Rp;
      end
      %
   end
   %
   % Display results
   %
   scale_factor = 1.3;
   figure('Name','Magnetic equilibrium profile parameters'),clf
   set(gcf,'units','inches','position',[0.5,1,10*scale_factor,6*scale_factor]);
   set(gca,'position',[0,0,1,1]);
   %
   subplot('position',[1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,psin_fit,0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'-','none','b',2);%ppval matlab
   [ax] = graph1D_jd(rho_fit,psin_fit1,0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'-','none','c',1);%ppval_yp matlab
   [ax] = graph1D_jd(prho(1:nr:end),psin(1:nr:end),0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'--','non','r',1);%numerical interpolation
   if isfield(equil_fit,'Te_fit'),
      subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,Te_fit,0,0,'\psi','T_e (keV)',strrep(equil_in.id,'_','-'),NaN,[0,1],[-eps,max(equil_in.pTe)],'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,Te_fit1,0,0,'\psi','T_e (keV)',strrep(equil_in.id,'_','-'),NaN,[0,1],[-eps,max(equil_in.pTe)],'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),pTe(1:nr:end),0,0,'\rho','T_e (keV)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,[0,1],[-eps,max(equil_in.pTe)],'--','non','r',1);
   end
   if isfield(equil_fit,'ne_fit'),
      subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,ne_fit/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_in.pne/1e19)],'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,ne_fit1/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_in.pne/1e19)],'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),pne(1:nr:end)/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_in.pne/1e19)],'--','non','r',1);
   end
   if isfield(equil_fit,'zTi_fit'),
      subplot('position',[1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zTi_fit,0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_in.pzTi))],'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zTi_fit1,0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_in.pzTi))],'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),pzTi(1:nr:end,:),0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_in.pzTi))],'--','non','r',1);
   end
   if isfield(equil_fit,'zni_fit'),
      subplot('position',[1/3+1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zni_fit/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_in.pzni/1e19))],'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zni_fit1/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_in.pzni/1e19))],'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),pzni(1:nr:end,:)/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_in.pzni/1e19))],'--','non','r',1);
      subplot('position',[2/3+1/12,1/8,5/24,5/16])
   end
   %
   figure('Name','1st order derivatives of the magnetic equilibrium profile parameters'),clf
   set(gcf,'units','inches','position',[0.5,1,10*scale_factor,6*scale_factor]);
   set(gca,'position',[0,0,1,1]);
   %
   subplot('position',[1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,dpsindrho_fit,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,dpsindrho_fit1,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:nr:end),dpsindrho(1:nr:end),0,0,'\rho','d\psi_nd/\rho','',NaN,[0,1],[min(dpsindrho_fit1),max(dpsindrho_fit1)],'--','non','r',1);
   if isfield(equil_fit,'Te_fit'),
      subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,dTedrho_fit,0,0,'','',strrep(equil_in.id,'_','-'),NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,dTedrho_fit1,0,0,'','',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),dTedrho(1:nr:end),0,0,'\rho','dT_ed/\rho (keV)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'ne_fit'),
      subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,dnedrho_fit/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,dnedrho_fit1/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),dnedrho(1:nr:end)/1e19,0,0,'\rho','dn_e/d\rho (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'zTi_fit'),
      subplot('position',[1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zdTidrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zdTidrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),zdTidrho(1:nr:end,:),0,0,'\rho','dT_i/d\rho (keV)','',NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'zni_fit'),
      subplot('position',[1/3+1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zdnidrho_fit/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zdnidrho_fit1/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),zdnidrho(1:nr:end,:)/1e19,0,0,'\rho','dn_i/d\rho (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
      subplot('position',[2/3+1/12,1/8,5/24,5/16])
   end
   %
   figure('Name','2nd order derivatives of the magnetic equilibrium profile parameters'),clf
   set(gcf,'units','inches','position',[0.5,1,10*scale_factor,6*scale_factor]);
   set(gca,'position',[0,0,1,1]);
   %
   subplot('position',[1/12,0.5+1/16,5/24,5/16])
   [ax] = graph1D_jd(rho_fit,d2psindrho2_fit,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','b',2);
   [ax] = graph1D_jd(rho_fit,d2psindrho2_fit1,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','c',1);
   [ax] = graph1D_jd(prho(1:nr:end),d2psindrho2(1:nr:end),0,0,'\rho','d2\psi_nd/\rho2','',NaN,[0,1],[min(d2psindrho2_fit1),max(d2psindrho2_fit1)],'--','non','r',1);
   if isfield(equil_fit,'Te_fit'),
      subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,d2Tedrho2_fit,0,0,'','',strrep(equil_in.id,'_','-'),NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,d2Tedrho2_fit1,0,0,'','',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),d2Tedrho2(1:nr:end),0,0,'\rho','d2T_ed/\rho2 (keV)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'ne_fit'),
      subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,d2nedrho2_fit/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,d2nedrho2_fit1/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),d2nedrho2(1:nr:end)/1e19,0,0,'\rho','d2n_e/d\rho2 (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'zTi_fit'),
      subplot('position',[1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zd2Tidrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zd2Tidrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),zd2Tidrho2(1:nr:end,:),0,0,'\rho','d2T_i/d\rho2 (keV)','',NaN,NaN,NaN,'--','non','r',1);
   end
   if isfield(equil_fit,'zni_fit'),
      subplot('position',[1/3+1/12,1/8,5/24,5/16])
      [ax] = graph1D_jd(rho_fit,zd2nidrho2_fit/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
      [ax] = graph1D_jd(rho_fit,zd2nidrho2_fit1/1e19,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
      [ax] = graph1D_jd(prho(1:nr:end),zd2nidrho2(1:nr:end,:)/1e19,0,0,'','d2n_i/d\rho2 (10^{19} m^{-3})','',NaN,NaN,NaN,'--','non','r',1);
      subplot('position',[2/3+1/12,1/8,5/24,5/16])
   end
   %
   % Magnetic equilibrium coordinates
   %
   figure('Name','x (majord radius) coordinate'),
   [ax] = graph1D_jd(theta_fit,x_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,x_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),x(1:nr:end,1:2:end),0,0,'\theta (rd)','x (m)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dx/dtheta'),
   [ax] = graph1D_jd(theta_fit,dxdtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dxdtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dxdtheta(1:nr:end,1:2:end),0,0,'\theta (rd)','dx/d\theta',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dx/drho'),
   [ax] = graph1D_jd(theta_fit,dxdrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dxdrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dxdrho(1:nr:end,1:2:end),0,0,'\theta','dx/d\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2xdthetadrho'),
   [ax] = graph1D_jd(theta_fit,d2xdthetadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2xdthetadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2xdthetadrho(1:nr:end,1:2:end),0,0,'\theta','d2xdthetadrho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2x/drho2'),
   [ax] = graph1D_jd(theta_fit,d2xdrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2xdrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2xdrho2(1:nr:end,1:2:end),0,0,'\theta','d2x/d\rho2',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','y (vertical) coordinate'),
   [ax] = graph1D_jd(theta_fit,y_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,y_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),y(1:nr:end,1:2:end),0,0,'\theta (rd)','y (m)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dy/dtheta'),
   [ax] = graph1D_jd(theta_fit,dydtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dydtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dydtheta(1:nr:end,1:2:end),0,0,'\theta (rd)','dy/d\theta',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dy/drho'),
   [ax] = graph1D_jd(theta_fit,dydrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dydrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dydrho(1:nr:end,1:2:end),0,0,'\rho','dy/d\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','d2ydthetadrho'),
   [ax] = graph1D_jd(theta_fit,d2ydthetadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2ydthetadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2ydthetadrho(1:nr:end,1:2:end),0,0,'\theta','d2ydthetadrho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2y/drho2'),
   [ax] = graph1D_jd(theta_fit,d2ydrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2ydrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2ydrho2(1:nr:end,1:2:end),0,0,'\theta','d2y/d\rho2',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   % Magnetic equilibrium quantities 
   %
   figure('Name','r position'),
   [ax] = graph1D_jd(theta_fit,r_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,r_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),r(1:nr:end,1:2:end),0,0,'\theta (rd)','r (m)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dr/dtheta'),
   [ax] = graph1D_jd(theta_fit,drdtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,drdtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),drdtheta(1:nr:end,1:2:end),0,0,'\theta (rd)','dr/d\theta',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dr/drho'),
   [ax] = graph1D_jd(theta_fit,drdrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,drdrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),drdrho(1:nr:end,1:2:end),0,0,'\rho','dr/d\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','d2rdthetadrho'),
   [ax] = graph1D_jd(theta_fit,d2ydthetadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2ydthetadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2ydthetadrho(1:nr:end,1:2:end),0,0,'\theta','d2rdthetadrho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2r/drho2'),
   [ax] = graph1D_jd(theta_fit,d2rdrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2rdrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2rdrho2(1:nr:end,1:2:end),0,0,'\theta','d2r/d\rho2',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','cos(alpha)'),
   [ax] = graph1D_jd(theta_fit,calpha_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,calpha_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),calpha(1:nr:end,1:2:end),0,0,'\theta (rd)','cos(\alpha)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dcos(alpha)/dtheta'),
   [ax] = graph1D_jd(theta_fit,dcalphadtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dcalphadtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dcalphadtheta(1:nr:end,1:2:end),0,0,'\theta (rd)','dcos(\alpha)/d\theta',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dcos(alpha)/drho'),
   [ax] = graph1D_jd(theta_fit,dcalphadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dcalphadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dcalphadrho(1:nr:end,1:2:end),0,0,'\rho','dcos(\alpha)/d\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','none','r',1);
   %
   figure('Name','d2cos(alpha)/dtheta/drho'),
   [ax] = graph1D_jd(theta_fit,d2calphadthetadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2calphadthetadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2calphadthetadrho(1:nr:end,1:2:end),0,0,'\theta','d2cos(alpha)/d\theta/d\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2cos(alpha)/drho2'),
   [ax] = graph1D_jd(theta_fit,d2calphadrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2calphadrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2calphadrho2(1:nr:end,1:2:end),0,0,'\theta','d2cos(alpha)/d\rho2',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','sin(alpha)'),
   [ax] = graph1D_jd(theta_fit,salpha_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,salpha_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),salpha(1:nr:end,1:2:end),0,0,'\theta (rd)','sin(\alpha)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dsin(alpha)/dtheta'),
   [ax] = graph1D_jd(theta_fit,dsalphadtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dsalphadtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dsalphadtheta(1:nr:end,1:2:end),0,0,'\theta (rd)','dsin(\alpha)/d\theta',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dsin(alpha)/drho'),
   [ax] = graph1D_jd(theta_fit,dsalphadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dsalphadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dsalphadrho(1:nr:end,1:2:end),0,0,'\rho','dsin(\alpha)/d\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','d2sin(alpha)/dtheta/drho'),
   [ax] = graph1D_jd(theta_fit,d2salphadthetadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2salphadthetadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2salphadthetadrho(1:nr:end,1:2:end),0,0,'\theta','dsin(\alpha)/d\theta/d\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2sin(alpha)/drho2'),
   [ax] = graph1D_jd(theta_fit,d2salphadrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2salphadrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2salphadrho2(1:nr:end,1:2:end),0,0,'\theta','d2sin(\alpha)/d\rho2',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','cos^2(alpha)+sin^2(alpha)'),
   [ax] = graph1D_jd(theta_fit,salpha_fit.^2 + calpha_fit.^2,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),salpha(1:nr:end,1:2:end).^2 + calpha(1:nr:end,1:2:end).^2,0,0,'\theta (rd)','cos^2(\alpha)+sin^2(\alpha)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','\nabla*\rho'),
   [ax] = graph1D_jd(theta_fit,gradrho_fit(1:end,:),0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,gradrho_fit1(1:end,:),0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),gradrho(1:nr:end,1:2:end),0,0,'\theta (rd)','\nabla*\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','d\nabla*\rho/dtheta'),
   [ax] = graph1D_jd(theta_fit,dgradrhodtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dgradrhodtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dgradrhodtheta(1:nr:end,1:2:end),0,0,'\theta (rd)','d\nabla*\rho/d\theta',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','d\nabla*\rho/drho'),
   [ax] = graph1D_jd(theta_fit,dgradrhodrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dgradrhodrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dgradrhodrho(1:nr:end,1:2:end),0,0,'\rho','d\nabla*\rho/d\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','d2\nabla*\rho/dtheta/drho'),
   [ax] = graph1D_jd(theta_fit,d2gradrhodthetadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2gradrhodthetadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2gradrhodthetadrho(1:nr:end,1:2:end),0,0,'\theta','d2\nabla*\rhodthetadrho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2\nabla*\rho/drho2'),
   [ax] = graph1D_jd(theta_fit,d2ydrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2ydrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2ydrho2(1:nr:end,1:2:end),0,0,'\theta','d2\nabla*\rho/d\rho2',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   % Magnetic fields
   %
   figure('Name','Toroidal (axial) magnetic field Bz'),
   [ax] = graph1D_jd(theta_fit,Bz_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,Bz_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),Bz(1:nr:end,1:2:end),0,0,'\theta (rd)','B_{\phi} (T)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dBz/dtheta'),
   [ax] = graph1D_jd(theta_fit,dBzdtheta_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBzdtheta_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBzdtheta(1:nr:end,1:2:end),0,0,'\theta (rd)','dBz/d\theta',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dBz/drho'),
   [ax] = graph1D_jd(theta_fit,dBzdrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBzdrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBzdrho(1:nr:end,1:2:end),0,0,'\psi_{n}','dBz/d\rho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','d2Bz/dtheta/drho'),
   [ax] = graph1D_jd(theta_fit,d2Bzdthetadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2Bzdthetadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2Bzdthetadrho(1:nr:end,1:2:end),0,0,'\theta','d2Bzdthetadrho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2Bz/drho2'),
   [ax] = graph1D_jd(theta_fit,d2Bzdrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2Bzdrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2Bzdrho2(1:nr:end,1:2:end),0,0,'\theta','d2Bz/d\rho2',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','Poloidal magnetic field BP'),
   [ax] = graph1D_jd(theta_fit,BP_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,BP_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),BP(1:nr:end,1:2:end),0,0,'\theta (rd)','B_P (T)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dBP/dtheta'),
   [ax] = graph1D_jd(theta_fit,dBPdtheta_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBPdtheta_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBPdtheta(1:nr:end,1:2:end),0,0,'\theta (rd)','dB_P/d\theta (T)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dBP/drho'),
   [ax] = graph1D_jd(theta_fit,dBPdrho_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBPdrho_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBPdrho(1:nr:end,1:2:end),0,0,'\theta (rd)','dB_P/d\rho (T)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','d2BP/dtheta/drho'),
   [ax] = graph1D_jd(theta_fit,d2BPdthetadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2BPdthetadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2BPdthetadrho(1:nr:end,1:2:end),0,0,'\theta','d2BPdthetadrho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2BP/drho2'),
   [ax] = graph1D_jd(theta_fit,d2BPdrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2BPdrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2BPdrho2(1:nr:end,1:2:end),0,0,'\theta','d2BP/d\rho2',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','Total magnetic field'),
   [ax] = graph1D_jd(theta_fit,B_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,B_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),B(1:nr:end,1:2:end),0,0,'\theta (rd)','B (T)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dB/dtheta'),
   [ax] = graph1D_jd(theta_fit,dBdtheta_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBdtheta_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBdtheta(1:nr:end,1:2:end),0,0,'\theta (rd)','dB/d\theta (T)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','dB/drho'),
   [ax] = graph1D_jd(theta_fit,dBdrho_fit,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,dBdrho_fit1,0,0,'\rho','\rho','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),dBdrho(1:nr:end,1:2:end),0,0,'\theta (rd)','dB/d\rho (T)',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);
   %
   figure('Name','d2B/dtheta/drho'),
   [ax] = graph1D_jd(theta_fit,d2Bdthetadrho_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2Bdthetadrho_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2Bdthetadrho(1:nr:end,1:2:end),0,0,'\theta','d2Bdthetadrho',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   figure('Name','d2B/drho2'),
   [ax] = graph1D_jd(theta_fit,d2Bdrho2_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
   [ax] = graph1D_jd(theta_fit,d2Bdrho2_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
   [ax] = graph1D_jd(equil_in.theta(1:2:end),d2Bdrho2(1:nr:end,1:2:end),0,0,'\theta','d2B/d\rho2',[strrep(equil_in.id,'_','-'),', blue: ppval, cyan: ppval-yp, red: numerical'],NaN,NaN,NaN,'--','non','r',1);   
   %
   xmin = min(min(x));
   xmax = max(max(x));
   ymin = min(min(y));
   ymax = max(max(y));
   %
   figure('Name','Magnetic equilibrium flux surface contour')
   % 
   [ax] = graph1D_jd(x(1:nr:end,1:2:end),y(1:nr:end,1:2:end),0,0,'','','',NaN,[xmin,xmax],[ymin,ymax],'-','none','r',2);drawnow
   [ax] = graph1D_jd(x(1:nr:end,:)',y(1:nr:end,:)',0,0,'x(m)','y(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[xmin,xmax],[ymin,ymax],'-','none','r',2);
   %
   [ax] = graph1D_jd(x_fit(1:nr:end,1:2:end),y_fit(1:nr:end,1:2:end),0,0,'','','',NaN,[xmin,xmax],[ymin,ymax],'-','none','b',1);drawnow
   [ax] = graph1D_jd(x_fit(:,:)',y_fit(:,:)',0,0,'x(m)','y(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[xmin,xmax],[ymin,ymax],'-','none','b',1);
   %
   [ax] = graph1D_jd(x_fit1(1:nr:end,1:2:end),y_fit1(1:nr:end,1:2:end),0,0,'','','',NaN,[xmin,xmax],[ymin,ymax],'--','none','c',1);drawnow
   [ax] = graph1D_jd(x_fit1(:,:)',y_fit1(:,:)',0,0,'x(m)','y(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[xmin,xmax],[ymin,ymax],'--','none','c',1);
   axis('equal');drawnow  
   %
else
    equilval = equilval_yp(equil_fit,rho,theta);
    %
    Te = equilval.Te;
    dTedrho = equilval.dTedrho;
    d2Tedrho2 = equilval.d2Tedrho2;
    %
    ne = equilval.ne;
    dnedrho = equilval.dnedrho;
    d2nedrho2 = equilval.d2nedrho2;
    %
    zTi = equilval.zTi;
    dzTidrho = equilval.dzTidrho;
    d2zTidrho2 = equilval.d2zTidrho2;
    %
    zni = equilval.zni;
    dznidrho = equilval.dznidrho;
    d2znidrho2 = equilval.d2znidrho2;
    %
    x = equilval.x;
    dxdtheta = equilval.dxdtheta;
    d2xdtheta2 = equilval.d2xdtheta2;
    dxdrho = equilval.dxdrho;
    d2xdthetadrho = equilval.d2xdthetadrho;
    d2xdrho2 = equilval.d2xdrho2;
    %
    y = equilval.y;
    dydtheta = equilval.dydtheta;
    d2ydtheta2 = equilval.d2ydtheta2;
    dydrho = equilval.dydrho;
    d2ydthetadrho = equilval.d2ydthetadrho;
    d2ydrho2 = equilval.d2ydrho2;
    %
    r = equilval.r;
    drdtheta = equilval.drdtheta;
    d2rdtheta2 = equilval.d2rdtheta2;
    drdrho = equilval.drdrho;
    d2rdthetadrho = equilval.d2rdthetadrho;
    d2rdrho2 = equilval.d2rdrho2;
    %
    salpha = equilval.salpha;
    dsalphadtheta = equilval.dsalphadtheta;
    d2salphadtheta2 = equilval.d2salphadtheta2;
    dsalphadrho = equilval.dsalphadrho;
    d2salphadthetadrho = equilval.d2salphadthetadrho;
    d2salphadrho2 = equilval.d2salphadrho2;
    %
    calpha = equilval.calpha;
    dcalphadtheta = equilval.dcalphadtheta;
    d2calphadtheta2 = equilval.d2calphadtheta2;
    dcalphadrho = equilval.dcalphadrho;
    d2calphadthetadrho = equilval.d2calphadthetadrho;
    d2calphadrho2 = equilval.d2calphadrho2;
    %
    Bx = equilval.Bx;
    dBxdtheta = equilval.dBxdtheta;
    d2Bxdtheta2 = equilval.d2Bxdtheta2;
    dBxdrho = equilval.dBxdrho;
    d2Bxdthetadrho = equilval.d2Bxdthetadrho;
    d2Bxdrho2 = equilval.d2Bxdrho2;
    %
    By = equilval.By;
    dBydtheta = equilval.dBydtheta;
    d2Bydtheta2 = equilval.d2Bydtheta2;
    dBydrho = equilval.dBydrho;
    d2Bydthetadrho = equilval.d2Bydthetadrho;
    d2Bydrho2 = equilval.d2Bydrho2;
    %
    Bz = equilval.Bz;
    dBzdtheta = equilval.dBzdtheta;
    d2Bzdtheta2 = equilval.d2Bzdtheta2;
    dBzdrho = equilval.dBzdrho;
    d2Bzdthetadrho = equilval.d2Bzdthetadrho;
    d2Bzdrho2 = equilval.d2Bzdrho2;
    %
    BP = equilval.BP;
    dBPdtheta = equilval.dBPdtheta;
    d2BPdtheta2 = equilval.d2BPdtheta2;
    dBPdrho = equilval.dBPdrho;
    d2BPdthetadrho = equilval.d2BPdthetadrho;
    d2BPdrho2 = equilval.d2BPdrho2;
    %
    B = equilval.B;
    dBdtheta = equilval.dBdtheta;
    d2Bdtheta2 = equilval.d2Bdtheta2;
    dBdrho = equilval.dBdrho;
    d2Bdthetadrho = equilval.d2Bdthetadrho;
    d2Bdrho2 = equilval.d2Bdrho2;
    %
    gradrho = equilval.gradrho;
    dgradrhodtheta = equilval.dgradrhodtheta;
    d2gradrhodtheta2 = equilval.d2gradrhodtheta2;
    dgradrhodrho = equilval.dgradrhodrho;
    d2gradrhodthetadrho = equilval.d2gradrhodthetadrho;
    d2gradrhodrho2 = equilval.d2gradrhodrho2;
    %
    Upsilon = equilval.Upsilon;
    dUpsilondtheta = equilval.dUpsilondtheta;
    d2Upsilondtheta2 = equilval.d2Upsilondtheta2;
    dUpsilondrho = equilval.dUpsilondrho;
    d2Upsilondthetadrho = equilval.d2Upsilondthetadrho;
    d2Upsilondrho2 = equilval.d2Upsilondrho2;
    %
    %psin = equilval.psin;
    %dpsindrho = equilval.dpsindrho;
    %dxstardpsin = equilval.dxstardpsin;
    %ddxstardpsindrho = equilval.ddxstardpsindrho;    
    %
    if nargout ~= 2,
        disp('----------------------------');
        if isfield(equil_fit,'Te_fit'),
            disp(['equil_fit.Te_fit.pp_f.coefs(1) = ',num2str(equil_fit.Te_fit.pp_f.coefs(1))]);
            disp(['equil_fit.Te_fit.pp_dfdrho.coefs(1) = ',num2str(equil_fit.Te_fit.pp_dfdrho.coefs(1))]);
            disp(['equil_fit.Te_fit.pp_d2fdrho2.coefs(1) = ',num2str(equil_fit.Te_fit.pp_d2fdrho2.coefs(1))]);
        end
        disp(['equil_fit.Bz_fit.n = ',num2str(equil_fit.Bz_fit.n(end))]);
        disp(['equil_fit.Bz_fit.bn.coefs(1) = ',num2str(equil_fit.Bz_fit.pp_bn.coefs(1))]);
        disp(['equil_fit.Bz_fit.dbndrho.coefs(1) = ',num2str(equil_fit.Bz_fit.pp_dbndrho.coefs(1))]);
        disp(['equil_fit.Bz_fit.d2bndrho2.coefs(1) = ',num2str(equil_fit.Bz_fit.pp_d2bndrho2.coefs(1))]);
        disp('----------------------------');
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
        disp('----------------------------');
        disp(['x(',num2str(rho),',',num2str(theta),'),dxdrho(',num2str(rho),',',num2str(theta),'),dxdtheta(',num2str(rho),',',num2str(theta),') (m) = ',num2str(x),',',num2str(dxdrho),',',num2str(dxdtheta)]);
        disp(['d2xdtheta2(',num2str(rho),',',num2str(theta),'),d2xdthetadrho(',num2str(rho),',',num2str(theta),'),d2xdrho2(',num2str(rho),',',num2str(theta),') (m) = ',num2str(d2xdtheta2),',',num2str(d2xdthetadrho),',',num2str(d2xdrho2)]);
        disp('----------------------------');
        disp(['y(',num2str(rho),',',num2str(theta),'),dydrho(',num2str(rho),',',num2str(theta),'),dydtheta(',num2str(rho),',',num2str(theta),') (m) = ',num2str(y),',',num2str(dydrho),',',num2str(dydtheta)]);
        disp(['d2ydtheta2(',num2str(rho),',',num2str(theta),'),d2ydthetadrho(',num2str(rho),',',num2str(theta),'),d2ydrho2(',num2str(rho),',',num2str(theta),') (m) = ',num2str(d2ydtheta2),',',num2str(d2ydthetadrho),',',num2str(d2ydrho2)]);
        disp('----------------------------');
        disp(['r(',num2str(rho),',',num2str(theta),'),drdrho(',num2str(rho),',',num2str(theta),'),drdtheta(',num2str(rho),',',num2str(theta),') (m) = ',num2str(r),',',num2str(drdrho),',',num2str(drdtheta)]);
        disp(['d2rdtheta2(',num2str(rho),',',num2str(theta),'),d2rdthetadrho(',num2str(rho),',',num2str(theta),'),d2rdrho2(',num2str(rho),',',num2str(theta),') (m) = ',num2str(d2rdtheta2),',',num2str(d2rdthetadrho),',',num2str(d2rdrho2)]);
        disp('----------------------------');
        disp(['Bx(',num2str(rho),',',num2str(theta),'),dBxdrho(',num2str(rho),',',num2str(theta),'),dBxdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(Bx),',',num2str(dBxdrho),',',num2str(dBxdtheta)]);
        disp(['d2Bxdtheta2(',num2str(rho),',',num2str(theta),'),d2Bxdthetadrho(',num2str(rho),',',num2str(theta),'),d2Bxdrho2(',num2str(rho),',',num2str(theta),')  (T) = ',num2str(d2Bxdtheta2),',',num2str(d2Bxdthetadrho),',',num2str(d2Bxdrho2)]);
        disp('----------------------------');
        disp(['By(',num2str(rho),',',num2str(theta),'),dBydrho(',num2str(rho),',',num2str(theta),'),dBydtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(By),',',num2str(dBydrho),',',num2str(dBydtheta)]);
        disp(['d2Bydtheta2(',num2str(rho),',',num2str(theta),'),d2Bydthetadrho(',num2str(rho),',',num2str(theta),'),d2Bydrho2(',num2str(rho),',',num2str(theta),')  (T) = ',num2str(d2Bydtheta2),',',num2str(d2Bydthetadrho),',',num2str(d2Bydrho2)]);
        disp('----------------------------');
        disp(['Bz(',num2str(rho),',',num2str(theta),'),dBzdrho(',num2str(rho),',',num2str(theta),'),dBzdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(Bz),',',num2str(dBzdrho),',',num2str(dBzdtheta)]);
        disp(['d2Bzdtheta2(',num2str(rho),',',num2str(theta),'),d2Bzdthetadrho(',num2str(rho),',',num2str(theta),'),d2Bzdrho2(',num2str(rho),',',num2str(theta),')  (T) = ',num2str(d2Bzdtheta2),',',num2str(d2Bzdthetadrho),',',num2str(d2Bzdrho2)]);
        disp('----------------------------');
        disp(['BP(',num2str(rho),',',num2str(theta),'),dBPdrho(',num2str(rho),',',num2str(theta),'),dBPdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(BP),',',num2str(dBPdrho),',',num2str(dBPdtheta)]);
        disp(['d2BPdtheta2(',num2str(rho),',',num2str(theta),'),d2BPdthetadrho(',num2str(rho),',',num2str(theta),'),d2BPdrho2(',num2str(rho),',',num2str(theta),')  (T) = ',num2str(d2BPdtheta2),',',num2str(d2BPdthetadrho),',',num2str(d2BPdrho2)]);
        disp('----------------------------');
        disp(['B(',num2str(rho),',',num2str(theta),'),dBdrho(',num2str(rho),',',num2str(theta),'),dBdtheta(',num2str(rho),',',num2str(theta),') (T) = ',num2str(B),',',num2str(dBdrho),',',num2str(dBdtheta)]);
        disp(['d2Bdtheta2(',num2str(rho),',',num2str(theta),'),d2Bdthetadrho(',num2str(rho),',',num2str(theta),'),d2Bdrho2(',num2str(rho),',',num2str(theta),')  (T) = ',num2str(d2Bdtheta2),',',num2str(d2Bdthetadrho),',',num2str(d2Bdrho2)]);
        disp('----------------------------');
        disp(['calpha(',num2str(rho),',',num2str(theta),'),dcalphadrho(',num2str(rho),',',num2str(theta),'),dcalphadtheta(',num2str(rho),',',num2str(theta),') = ',num2str(calpha),',',num2str(dcalphadrho),',',num2str(dcalphadtheta)]);
        disp(['d2calphadtheta2(',num2str(rho),',',num2str(theta),'),d2calphadthetadrho(',num2str(rho),',',num2str(theta),'),d2calphadrho2(',num2str(rho),',',num2str(theta),') = ',num2str(d2calphadtheta2),',',num2str(d2calphadthetadrho),',',num2str(d2calphadrho2)]);
        disp(['salpha(',num2str(rho),',',num2str(theta),'),dsalphadrho(',num2str(rho),',',num2str(theta),'),dsalphadtheta(',num2str(rho),',',num2str(theta),') = ',num2str(salpha),',',num2str(dsalphadrho),',',num2str(dsalphadtheta)]);
        disp(['d2salphadtheta2(',num2str(rho),',',num2str(theta),'),d2salphadthetadrho(',num2str(rho),',',num2str(theta),'),d2salphadrho2(',num2str(rho),',',num2str(theta),') = ',num2str(d2salphadtheta2),',',num2str(d2salphadthetadrho),',',num2str(d2salphadrho2)]);
        disp('----------------------------');
        disp(['gradrho(',num2str(rho),',',num2str(theta),'),dgradrhodrho(',num2str(rho),',',num2str(theta),'),dgradrhodtheta(',num2str(rho),',',num2str(theta),') = ',num2str(gradrho),',',num2str(dgradrhodrho),',',num2str(dgradrhodtheta)]);
        disp(['d2gradrhodtheta2(',num2str(rho),',',num2str(theta),'),d2gradrhodthetadrho(',num2str(rho),',',num2str(theta),'),d2gradrhodrho2(',num2str(rho),',',num2str(theta),') = ',num2str(d2gradrhodtheta2),',',num2str(d2gradrhodthetadrho),',',num2str(d2gradrhodrho2)]);
        disp('----------------------------');
        disp(['Upsilon(',num2str(rho),',',num2str(theta),'),dUpsilondrho(',num2str(rho),',',num2str(theta),'),dUpsilondtheta(',num2str(rho),',',num2str(theta),') = ',num2str(Upsilon),',',num2str(dUpsilondrho),',',num2str(dUpsilondtheta)]);
        disp(['d2Upsilondtheta2(',num2str(rho),',',num2str(theta),'),d2Upsilondthetadrho(',num2str(rho),',',num2str(theta),'),d2Upsilondrho2(',num2str(rho),',',num2str(theta),') = ',num2str(d2Upsilondtheta2),',',num2str(d2Upsilondthetadrho),',',num2str(d2Upsilondrho2)]);
   end
end

