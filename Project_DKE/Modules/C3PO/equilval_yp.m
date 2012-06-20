function [Te,dTedrho,d2Tedrho2,ne,dnedrho,d2nedrho2,zTi,dzTidrho,d2zTidrho2,zni,dznidrho,d2znidrho2,...
    R,dRdtheta,d2Rdtheta2,dRdrho,d2Rdthetadrho,Z,dZdtheta,d2Zdtheta2,dZdrho,d2Zdthetadrho,...
    r,drdtheta,drdrho,salpha,dsalphadtheta,dsalphadrho,calpha,dcalphadtheta,dcalphadrho,...
    BR,dBRdtheta,d2BRdtheta2,dBRdrho,d2BRdthetadrho,...
    BZ,dBZdtheta,d2BZdtheta2,dBZdrho,d2BZdthetadrho,...
    BPHI,dBPHIdtheta,d2BPHIdtheta2,dBPHIdrho,d2BPHIdthetadrho,...
    BP,dBPdtheta,dBPdrho,B,dBdtheta,dBdrho,...
    gradrhon,dgradrhondtheta,dgradrhondrho] = equilval_yp(equil_fit,rho,theta,mode)
%
% This function calculates all parameters of the axisymmetric magnetic equilibrium at any position in the plasma
%
%   INPUT :
%
%       - equil_fit: fitted axisymmetric magnetic equilibrium structure
%       - rho: normalized minor radius (a.u.) [1,1]
%       - theta: poloidal angle (rad) [1,1]
%       - mode: coordinate system for the magnetic equilibrium (1) -> (rho or psi,theta), (2) -> (x,y) [1,1]
%         (optional, default value : 1)
%
%   OUTPUT :
%
%       - Te,dTedrho,d2Tedrho2: electron temperature and it's derivatives [1,1]
%       - ne,dnedrho,d2nedrho2: electron desnity and it's derivatives [1,1]
%       - zTi,dzTidrho,d2zTidrho2: ion temperatures and their derivatives [1,1]
%       - zni,dznidrho,d2znidrho2: ion densities and their derivatives [1,1]
%       - R,dRdtheta,d2Rdtheta2,dRdrho,d2Rdthetadrho: horizontal coordinate and it's derivatives [1,1]
%       - Z,dZdtheta,d2Zdtheta2,dZdrho,d2Zdthetadrho: vertical coordinate and it's derivatives [1,1]
%       - r,drdtheta,drdrho: minor radius and it's derivatives [1,1]
%       - salpha,dsalphadtheta,dsalphadrho: sin(alpha) and it's derivatives [1,1]
%       - calpha,dcalphadtheta,dcalphadrho: cos(alpha) and it's derivatives [1,1]
%       - BR,dBRdtheta,d2BRdtheta2,dBRdrho,d2BRdthetadrho: horizontal B-field and it's derivatives
%       - BZ,dBZdtheta,d2BZdtheta2,dBZdrho,d2BZdthetadrho: vertical B-field and it's derivatives [1,1]
%       - BPHI,dBPHIdtheta,d2BPHIdtheta2,dBPHIdrho,d2BPHIdthetadrho: toroidal B-field and it's derivatives (signed value) [1,1]
%       - BP,dBPdtheta,dBPdrho,B,dBdtheta,dBdrho: poloidal B-field [1,1]
%       - gradrhon,dgradrhondtheta,dgradrhondrho: normalized gradient of rho and it'derivatives [1,1]
%
% by Y. Peysson DRFC-CEA <yves.peysson@cea.fr> and J. Decker DRFC-CEA <joan.decker@cea.fr> 
%
if nargin < 4
    mode = 1;
end
%
Rp = equil_fit.Rp;
Zp = equil_fit.Zp;
%
psin = ppval(equil_fit.psin_fit.pp_f,rho);
dpsindrho = ppval(equil_fit.psin_fit.pp_dfdrho,rho);
dRstardpsin = ppval(equil_fit.dxstardpsin_fit.pp_f,rho);
ddRstardpsindrho = ppval(equil_fit.dxstardpsin_fit.pp_dfdrho,rho);
if isfield(equil_fit,'Te_fit'),
  Te = ppval_yp(equil_fit.Te_fit.pp_f,rho);
  dTedrho = ppval_yp(equil_fit.Te_fit.pp_dfdrho,rho);
  d2Tedrho2 = ppval_yp(equil_fit.Te_fit.pp_d2fdrho2,rho);
end
if isfield(equil_fit,'ne_fit'),
  ne = ppval_yp(equil_fit.ne_fit.pp_f,rho);
  dnedrho = ppval_yp(equil_fit.ne_fit.pp_dfdrho,rho);
  d2nedrho2 = ppval_yp(equil_fit.ne_fit.pp_d2fdrho2,rho);
end
if isfield(equil_fit,'zTi_fit'),
  zTi = ppval_yp(equil_fit.zTi_fit.pp_f,rho);
  dzTidrho = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,rho);
  d2zTidrho2 = ppval_yp(equil_fit.zTi_fit.pp_d2fdrho2,rho);
end
if isfield(equil_fit,'zni_fit'),
  zni = ppval_yp(equil_fit.zni_fit.pp_f,rho);
  dznidrho = ppval_yp(equil_fit.zni_fit.pp_dfdrho,rho);
  d2znidrho2 = ppval_yp(equil_fit.zni_fit.pp_d2fdrho2,rho);
end
%
x_a0 = ppval(equil_fit.x_fit.pp_a0,rho);
x_an = ppval(equil_fit.x_fit.pp_an,rho);
x_bn = ppval(equil_fit.x_fit.pp_bn,rho);
x_da0drho = ppval(equil_fit.x_fit.pp_da0drho,rho);
x_dandrho = ppval(equil_fit.x_fit.pp_dandrho,rho);
x_dbndrho = ppval(equil_fit.x_fit.pp_dbndrho,rho);

[R,dRdtheta,d2Rdtheta2,dRdrho,d2Rdthetadrho] = calcval_yp(equil_fit,theta,x_a0,x_an,x_bn,x_da0drho,x_dandrho,x_dbndrho);
R = R + Rp;
%
y_a0 = ppval(equil_fit.y_fit.pp_a0,rho);
y_an = ppval(equil_fit.y_fit.pp_an,rho);
y_bn = ppval(equil_fit.y_fit.pp_bn,rho);
y_da0drho = ppval(equil_fit.y_fit.pp_da0drho,rho);
y_dandrho = ppval(equil_fit.y_fit.pp_dandrho,rho);
y_dbndrho = ppval(equil_fit.y_fit.pp_dbndrho,rho);
[Z,dZdtheta,d2Zdtheta2,dZdrho,d2Zdthetadrho] = calcval_yp(equil_fit,theta,y_a0,y_an,y_bn,y_da0drho,y_dandrho,y_dbndrho);
Z = Z + Zp;
%
r = sqrt((R - Rp).^2 + (Z - Zp).^2);
drdtheta = (dRdtheta.*(R - Rp) + dZdtheta.*(Z - Zp))./r;
drdrho = (dRdrho.*(R - Rp) + dZdrho.*(Z - Zp))./r;
%
salpha = ((R - Rp).*dRdtheta + (Z - Zp).*dZdtheta)./r./sqrt(dRdtheta.^2 + dZdtheta.^2);
dsalphadtheta = ...
  sqrt(dRdtheta.^2 + dZdtheta.^2)./r ...
  + ((R - Rp).*d2Rdtheta2 + (Z - Zp).*d2Zdtheta2)./r./sqrt(dRdtheta.^2 + dZdtheta.^2) ...
  -drdtheta.*((R - Rp).*dRdtheta + (Z - Zp).*dZdtheta)./r.^2./sqrt(dRdtheta.^2 + dZdtheta.^2) ...
  -(dRdtheta.*d2Rdtheta2 + dZdtheta.*d2Zdtheta2).*((R - Rp).*dRdtheta + (Z - Zp).*dZdtheta)./r./sqrt(dRdtheta.^2 + dZdtheta.^2)./(dRdtheta.^2 + dZdtheta.^2);
dsalphadrho = ...
  (dRdtheta.*dRdrho + dZdtheta.*dZdrho)./r./sqrt(dRdtheta.^2 + dZdtheta.^2)...
  + ((R - Rp).*d2Rdthetadrho + (Z - Zp).*d2Zdthetadrho)./r./sqrt(dRdtheta.^2 + dZdtheta.^2) ...
  -drdrho.*((R - Rp).*dRdtheta + (Z - Zp).*dZdtheta)./r.^2./sqrt(dRdtheta.^2 + dZdtheta.^2) ...
  -(dRdtheta.*d2Rdthetadrho + dZdtheta.*d2Zdthetadrho).*((R - Rp).*dRdtheta + (Z - Zp).*dZdtheta)./r./sqrt(dRdtheta.^2 + dZdtheta.^2)./(dRdtheta.^2 + dZdtheta.^2);
%
calpha = sqrt(1.0 - salpha.^2);
dcalphadtheta = -salpha.*dsalphadtheta./calpha;
dcalphadrho = -salpha.*dsalphadrho./calpha;
%
Bx_a0 = ppval(equil_fit.Bx_fit.pp_a0,rho);
Bx_an = ppval(equil_fit.Bx_fit.pp_an,rho);
Bx_bn = ppval(equil_fit.Bx_fit.pp_bn,rho);
Bx_da0drho = ppval(equil_fit.Bx_fit.pp_da0drho,rho);
Bx_dandrho = ppval(equil_fit.Bx_fit.pp_dandrho,rho);
Bx_dbndrho = ppval(equil_fit.Bx_fit.pp_dbndrho,rho);
Bx_dbndrho = ppval(equil_fit.Bx_fit.pp_dbndrho,rho);
[BR,dBRdtheta,d2BRdtheta2,dBRdrho,d2BRdthetadrho] = calcval_yp(equil_fit,theta,Bx_a0,Bx_an,Bx_bn,Bx_da0drho,Bx_dandrho,Bx_dbndrho);
%
By_a0 = ppval(equil_fit.By_fit.pp_a0,rho);
By_an = ppval(equil_fit.By_fit.pp_an,rho);
By_bn = ppval(equil_fit.By_fit.pp_bn,rho);
By_da0drho = ppval(equil_fit.By_fit.pp_da0drho,rho);
By_dandrho = ppval(equil_fit.By_fit.pp_dandrho,rho);
By_dbndrho = ppval(equil_fit.By_fit.pp_dbndrho,rho);
[BZ,dBZdtheta,d2BZdtheta2,dBZdrho,d2BZdthetadrho] = calcval_yp(equil_fit,theta,By_a0,By_an,By_bn,By_da0drho,By_dandrho,By_dbndrho);
%
BPHI_a0 = ppval(equil_fit.BPHI_fit.pp_a0,rho);
BPHI_an = ppval(equil_fit.BPHI_fit.pp_an,rho);
BPHI_bn = ppval(equil_fit.BPHI_fit.pp_bn,rho);
BPHI_da0drho = ppval(equil_fit.BPHI_fit.pp_da0drho,rho);
BPHI_dandrho = ppval(equil_fit.BPHI_fit.pp_dandrho,rho);
BPHI_dbndrho = ppval(equil_fit.BPHI_fit.pp_dbndrho,rho);
[BPHI,dBPHIdtheta,d2BPHIdtheta2,dBPHIdrho,d2BPHIdthetadrho] = calcval_yp(equil_fit,theta,BPHI_a0,BPHI_an,BPHI_bn,BPHI_da0drho,BPHI_dandrho,BPHI_dbndrho);
%
BP = sqrt(BR^2 + BZ^2);
dBPdtheta = (BR*dBRdtheta + BZ*dBZdtheta)/BP;
dBPdrho = (BR*dBRdrho + BZ*dBZdrho)/BP;
%
B = sqrt(BR^2 + BZ^2 + BPHI^2);
dBdtheta = (BR*dBRdtheta + BZ*dBZdtheta + BPHI*dBPHIdtheta)/B;
dBdrho = (BR*dBRdrho + BZ*dBZdrho + BPHI*dBPHIdrho)/B;
%
gradrhon = R.*BP.*dRstardpsin/equil_fit.psia;
dgradrhondrho = dRdrho.*BP.*dRstardpsin/equil_fit.psia + R.*dBPdrho.*dRstardpsin/equil_fit.psia + R.*BP.*ddRstardpsindrho/equil_fit.psia;
dgradrhondtheta = dRdtheta.*BP.*dRstardpsin/equil_fit.psia + R.*dBPdtheta.*dRstardpsin/equil_fit.psia;
