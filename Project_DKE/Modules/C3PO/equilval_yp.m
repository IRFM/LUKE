function [Te,dTedrho,d2Tedrho2,ne,dnedrho,d2nedrho2,zTi,dzTidrho,d2zTidrho2,zni,dznidrho,d2znidrho2,...
    x,dxdtheta,d2xdtheta2,dxdrho,d2xdthetadrho,y,dydtheta,d2ydtheta2,dydrho,d2ydthetadrho,...
    r,drdtheta,drdrho,salpha,dsalphadtheta,dsalphadrho,calpha,dcalphadtheta,dcalphadrho,...
    Bx,dBxdtheta,d2Bxdtheta2,dBxdrho,d2Bxdthetadrho,...
    By,dBydtheta,d2Bydtheta2,dBydrho,d2Bydthetadrho,...
    Bz,dBzdtheta,d2Bzdtheta2,dBzdrho,d2Bzdthetadrho,...
    BP,dBPdtheta,dBPdrho,B,dBdtheta,dBdrho,...
    gradrho,dgradrhodtheta,dgradrhodrho,...
    Upsilon,dUpsilondrho,dUpsilondtheta] = equilval_yp(equil_fit,rho,theta,mode)
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
%       - Te,dTedrho,d2Tedrho2: electron temperature and its derivatives [1,1]
%       - ne,dnedrho,d2nedrho2: electron desnity and its derivatives [1,1]
%       - zTi,dzTidrho,d2zTidrho2: ion temperatures and their derivatives [1,1]
%       - zni,dznidrho,d2znidrho2: ion densities and their derivatives [1,1]
%       - x,dxdtheta,d2xdtheta2,dxdrho,d2xdthetadrho: horizontal coordinate and its derivatives [1,1]
%       - y,dydtheta,d2ydtheta2,dydrho,d2ydthetadrho: vertical coordinate and its derivatives [1,1]
%       - r,drdtheta,drdrho: minor radius and its derivatives [1,1]
%       - salpha,dsalphadtheta,dsalphadrho: sin(alpha) and its derivatives [1,1]
%       - calpha,dcalphadtheta,dcalphadrho: cos(alpha) and its derivatives [1,1]
%       - Bx,dBxdtheta,d2Bxdtheta2,dBxdrho,d2Bxdthetadrho: horizontal B-field and its derivatives
%       - By,dBydtheta,d2Bydtheta2,dBydrho,d2Bydthetadrho: vertical B-field and its derivatives [1,1]
%       - Bz,dBzdtheta,d2Bzdtheta2,dBzdrho,d2Bzdthetadrho: toroidal or axial B-field and its derivatives (signed value) [1,1]
%       - BP,dBPdtheta,dBPdrho,B,dBdtheta,dBdrho: poloidal B-field and its derivatives [1,1]
%       - gradrho,dgradrhodtheta,dgradrhodrho: normalized gradient of rho and its derivatives [1,1]
%       - Upsilon,dUpsilondrho,dUpsilondtheta: toroidal form factor and its derivatives [1,1]
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
dxstardpsin = ppval(equil_fit.dxstardpsin_fit.pp_f,rho);
ddxstardpsindrho = ppval(equil_fit.dxstardpsin_fit.pp_dfdrho,rho);
%
if isfield(equil_fit,'Te_fit'),
  Te = ppval_yp(equil_fit.Te_fit.pp_f,rho);
  dTedrho = ppval_yp(equil_fit.Te_fit.pp_dfdrho,rho);
  d2Tedrho2 = ppval_yp(equil_fit.Te_fit.pp_d2fdrho2,rho);
end
%
if isfield(equil_fit,'ne_fit'),
  ne = ppval_yp(equil_fit.ne_fit.pp_f,rho);
  dnedrho = ppval_yp(equil_fit.ne_fit.pp_dfdrho,rho);
  d2nedrho2 = ppval_yp(equil_fit.ne_fit.pp_d2fdrho2,rho);
end
%
if isfield(equil_fit,'zTi_fit'),
  zTi = ppval_yp(equil_fit.zTi_fit.pp_f,rho);
  dzTidrho = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,rho);
  d2zTidrho2 = ppval_yp(equil_fit.zTi_fit.pp_d2fdrho2,rho);
end
%
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
%
[x,dxdtheta,d2xdtheta2,dxdrho,d2xdthetadrho] = calcval_yp(equil_fit,theta,x_a0,x_an,x_bn,x_da0drho,x_dandrho,x_dbndrho);
%
y_a0 = ppval(equil_fit.y_fit.pp_a0,rho);
y_an = ppval(equil_fit.y_fit.pp_an,rho);
y_bn = ppval(equil_fit.y_fit.pp_bn,rho);
y_da0drho = ppval(equil_fit.y_fit.pp_da0drho,rho);
y_dandrho = ppval(equil_fit.y_fit.pp_dandrho,rho);
y_dbndrho = ppval(equil_fit.y_fit.pp_dbndrho,rho);
%
[y,dydtheta,d2ydtheta2,dydrho,d2ydthetadrho] = calcval_yp(equil_fit,theta,y_a0,y_an,y_bn,y_da0drho,y_dandrho,y_dbndrho);
%
r_a0 = ppval(equil_fit.r_fit.pp_a0,rho);
r_an = ppval(equil_fit.r_fit.pp_an,rho);
r_bn = ppval(equil_fit.r_fit.pp_bn,rho);
r_da0drho = ppval(equil_fit.r_fit.pp_da0drho,rho);
r_dandrho = ppval(equil_fit.r_fit.pp_dandrho,rho);
r_dbndrho = ppval(equil_fit.r_fit.pp_dbndrho,rho);
%
[r,drdtheta,d2rdtheta2,drdrho,d2rdthetadrho] = calcval_yp(equil_fit,theta,r_a0,r_an,r_bn,r_da0drho,r_dandrho,r_dbndrho);
%
Bx_a0 = ppval(equil_fit.Bx_fit.pp_a0,rho);
Bx_an = ppval(equil_fit.Bx_fit.pp_an,rho);
Bx_bn = ppval(equil_fit.Bx_fit.pp_bn,rho);
Bx_da0drho = ppval(equil_fit.Bx_fit.pp_da0drho,rho);
Bx_dandrho = ppval(equil_fit.Bx_fit.pp_dandrho,rho);
Bx_dbndrho = ppval(equil_fit.Bx_fit.pp_dbndrho,rho);
Bx_dbndrho = ppval(equil_fit.Bx_fit.pp_dbndrho,rho);
%
[Bx,dBxdtheta,d2Bxdtheta2,dBxdrho,d2Bxdthetadrho] = calcval_yp(equil_fit,theta,Bx_a0,Bx_an,Bx_bn,Bx_da0drho,Bx_dandrho,Bx_dbndrho);
%
By_a0 = ppval(equil_fit.By_fit.pp_a0,rho);
By_an = ppval(equil_fit.By_fit.pp_an,rho);
By_bn = ppval(equil_fit.By_fit.pp_bn,rho);
By_da0drho = ppval(equil_fit.By_fit.pp_da0drho,rho);
By_dandrho = ppval(equil_fit.By_fit.pp_dandrho,rho);
By_dbndrho = ppval(equil_fit.By_fit.pp_dbndrho,rho);
%
[By,dBydtheta,d2Bydtheta2,dBydrho,d2Bydthetadrho] = calcval_yp(equil_fit,theta,By_a0,By_an,By_bn,By_da0drho,By_dandrho,By_dbndrho);
%
Bz_a0 = ppval(equil_fit.Bz_fit.pp_a0,rho);
Bz_an = ppval(equil_fit.Bz_fit.pp_an,rho);
Bz_bn = ppval(equil_fit.Bz_fit.pp_bn,rho);
Bz_da0drho = ppval(equil_fit.Bz_fit.pp_da0drho,rho);
Bz_dandrho = ppval(equil_fit.Bz_fit.pp_dandrho,rho);
Bz_dbndrho = ppval(equil_fit.Bz_fit.pp_dbndrho,rho);
%
[Bz,dBzdtheta,d2Bzdtheta2,dBzdrho,d2Bzdthetadrho] = calcval_yp(equil_fit,theta,Bz_a0,Bz_an,Bz_bn,Bz_da0drho,Bz_dandrho,Bz_dbndrho);
%
BP_a0 = ppval(equil_fit.BP_fit.pp_a0,rho);
BP_an = ppval(equil_fit.BP_fit.pp_an,rho);
BP_bn = ppval(equil_fit.BP_fit.pp_bn,rho);
BP_da0drho = ppval(equil_fit.BP_fit.pp_da0drho,rho);
BP_dandrho = ppval(equil_fit.BP_fit.pp_dandrho,rho);
BP_dbndrho = ppval(equil_fit.BP_fit.pp_dbndrho,rho);
%
[BP,dBPdtheta,d2BPdtheta2,dBPdrho,d2BPdthetadrho] = calcval_yp(equil_fit,theta,BP_a0,BP_an,BP_bn,BP_da0drho,BP_dandrho,BP_dbndrho);
%
B_a0 = ppval(equil_fit.B_fit.pp_a0,rho);
B_an = ppval(equil_fit.B_fit.pp_an,rho);
B_bn = ppval(equil_fit.B_fit.pp_bn,rho);
B_da0drho = ppval(equil_fit.B_fit.pp_da0drho,rho);
B_dandrho = ppval(equil_fit.B_fit.pp_dandrho,rho);
B_dbndrho = ppval(equil_fit.B_fit.pp_dbndrho,rho);
%
[B,dBdtheta,d2Bdtheta2,dBdrho,d2Bdthetadrho] = calcval_yp(equil_fit,theta,B_a0,B_an,B_bn,B_da0drho,B_dandrho,B_dbndrho);
%
calpha_a0 = ppval(equil_fit.calpha_fit.pp_a0,rho);
calpha_an = ppval(equil_fit.calpha_fit.pp_an,rho);
calpha_bn = ppval(equil_fit.calpha_fit.pp_bn,rho);
calpha_da0drho = ppval(equil_fit.calpha_fit.pp_da0drho,rho);
calpha_dandrho = ppval(equil_fit.calpha_fit.pp_dandrho,rho);
calpha_dbndrho = ppval(equil_fit.calpha_fit.pp_dbndrho,rho);
%
[calpha,dcalphadtheta,d2calphadtheta2,dcalphadrho,d2calphadthetadrho] = calcval_yp(equil_fit,theta,calpha_a0,calpha_an,calpha_bn,calpha_da0drho,calpha_dandrho,calpha_dbndrho);
%
salpha_a0 = ppval(equil_fit.salpha_fit.pp_a0,rho);
salpha_an = ppval(equil_fit.salpha_fit.pp_an,rho);
salpha_bn = ppval(equil_fit.salpha_fit.pp_bn,rho);
salpha_da0drho = ppval(equil_fit.salpha_fit.pp_da0drho,rho);
salpha_dandrho = ppval(equil_fit.salpha_fit.pp_dandrho,rho);
salpha_dbndrho = ppval(equil_fit.salpha_fit.pp_dbndrho,rho);
%
[salpha,dsalphadtheta,d2salphadtheta2,dsalphadrho,d2salphadthetadrho] = calcval_yp(equil_fit,theta,salpha_a0,salpha_an,salpha_bn,salpha_da0drho,salpha_dandrho,salpha_dbndrho);
%
if isinf(Rp),
    Upsilon = 1;
    dUpsilondrho = 0;
    dUpsilondtheta = 0;
else
    Upsilon = 1 + x/Rp;
    dUpsilondrho = dxdrho/Rp;
    dUpsilondtheta = dxdtheta/Rp;
end
%
gradrho = Upsilon.*BP.*dxstardpsin/equil_fit.psia_apRp;
dgradrhodrho = (dUpsilondrho.*BP.*dxstardpsin + Upsilon.*dBPdrho.*dxstardpsin + Upsilon.*BP.*ddxstardpsindrho)/equil_fit.psia_apRp;
dgradrhodtheta = (dUpsilondtheta.*BP.*dxstardpsin + Upsilon.*dBPdtheta.*dxstardpsin)/equil_fit.psia_apRp;
