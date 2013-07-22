function [x,y,Bx,By,BP,dBdtheta] = equilval_B_dB_en(equil_fit,rho,theta,mode)
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
%       
%       - x,dxdtheta,d2xdtheta2,dxdrho,d2xdthetadrho: horizontal coordinate and it's derivatives [1,1]
%       - y,dydtheta,d2ydtheta2,dydrho,d2ydthetadrho: vertical coordinate and it's derivatives [1,1]
%       - r,drdtheta,drdrho: minor radius and it's derivatives [1,1]
%       - Bx,dBxdtheta,d2Bxdtheta2,dBxdrho,d2Bxdthetadrho: horizontal B-field and it's derivatives
%       - By,dBydtheta,d2Bydtheta2,dBydrho,d2Bydthetadrho: vertical B-field
%       and it's derivatives [1,1]
%       - BP,dBPdtheta,dBPdrho,B,dBdtheta,dBdrho: poloidal B-field [1,1]
%
% by Y. Peysson DRFC-CEA <yves.peysson@cea.fr> and J. Decker DRFC-CEA <joan.decker@cea.fr> 
%
if nargin < 4
    mode = 1;
end
%
% Rp = equil_fit.Rp;
% Zp = equil_fit.Zp;
%
% psin = ppval(equil_fit.psin_fit.pp_f,rho);
% dpsindrho = ppval(equil_fit.psin_fit.pp_dfdrho,rho);
% dxstardpsin = ppval(equil_fit.dxstardpsin_fit.pp_f,rho);
% ddxstardpsindrho = ppval(equil_fit.dxstardpsin_fit.pp_dfdrho,rho);
%
x_a0 = ppval(equil_fit.x_fit.pp_a0,rho);
x_an = ppval(equil_fit.x_fit.pp_an,rho);
x_bn = ppval(equil_fit.x_fit.pp_bn,rho);
x_da0drho = ppval(equil_fit.x_fit.pp_da0drho,rho);
x_dandrho = ppval(equil_fit.x_fit.pp_dandrho,rho);
x_dbndrho = ppval(equil_fit.x_fit.pp_dbndrho,rho);
%
[x,dxdtheta,d2xdtheta2,dxdrho,d2xdthetadrho] = calcval_yp_vec(equil_fit,theta,x_a0,x_an,x_bn,x_da0drho,x_dandrho,x_dbndrho);
%
y_a0 = ppval(equil_fit.y_fit.pp_a0,rho);
y_an = ppval(equil_fit.y_fit.pp_an,rho);
y_bn = ppval(equil_fit.y_fit.pp_bn,rho);
y_da0drho = ppval(equil_fit.y_fit.pp_da0drho,rho);
y_dandrho = ppval(equil_fit.y_fit.pp_dandrho,rho);
y_dbndrho = ppval(equil_fit.y_fit.pp_dbndrho,rho);
%
[y,dydtheta,d2ydtheta2,dydrho,d2ydthetadrho] = calcval_yp_vec(equil_fit,theta,y_a0,y_an,y_bn,y_da0drho,y_dandrho,y_dbndrho);
%
%r = sqrt(x.^2 + y.^2);
%
Bx_a0 = ppval(equil_fit.Bx_fit.pp_a0,rho);
Bx_an = ppval(equil_fit.Bx_fit.pp_an,rho);
Bx_bn = ppval(equil_fit.Bx_fit.pp_bn,rho);
Bx_da0drho = ppval(equil_fit.Bx_fit.pp_da0drho,rho);
Bx_dandrho = ppval(equil_fit.Bx_fit.pp_dandrho,rho);
Bx_dbndrho = ppval(equil_fit.Bx_fit.pp_dbndrho,rho);
Bx_dbndrho = ppval(equil_fit.Bx_fit.pp_dbndrho,rho);
%
[Bx,dBxdtheta,d2Bxdtheta2,dBxdrho,d2Bxdthetadrho] = calcval_yp_vec(equil_fit,theta,Bx_a0,Bx_an,Bx_bn,Bx_da0drho,Bx_dandrho,Bx_dbndrho);
%
By_a0 = ppval(equil_fit.By_fit.pp_a0,rho);
By_an = ppval(equil_fit.By_fit.pp_an,rho);
By_bn = ppval(equil_fit.By_fit.pp_bn,rho);
By_da0drho = ppval(equil_fit.By_fit.pp_da0drho,rho);
By_dandrho = ppval(equil_fit.By_fit.pp_dandrho,rho);
By_dbndrho = ppval(equil_fit.By_fit.pp_dbndrho,rho);
%
[By,dBydtheta,d2Bydtheta2,dBydrho,d2Bydthetadrho] = calcval_yp_vec(equil_fit,theta,By_a0,By_an,By_bn,By_da0drho,By_dandrho,By_dbndrho);
%
Bz_a0 = ppval(equil_fit.Bz_fit.pp_a0,rho);
Bz_an = ppval(equil_fit.Bz_fit.pp_an,rho);
Bz_bn = ppval(equil_fit.Bz_fit.pp_bn,rho);
Bz_da0drho = ppval(equil_fit.Bz_fit.pp_da0drho,rho);
Bz_dandrho = ppval(equil_fit.Bz_fit.pp_dandrho,rho);
Bz_dbndrho = ppval(equil_fit.Bz_fit.pp_dbndrho,rho);
%
[Bz,dBzdtheta,d2Bzdtheta2,dBzdrho,d2Bzdthetadrho] = calcval_yp_vec(equil_fit,theta,Bz_a0,Bz_an,Bz_bn,Bz_da0drho,Bz_dandrho,Bz_dbndrho);
%
BP = sqrt(Bx.^2 + By.^2);
% dBPdtheta = (Bx*dBxdtheta + By*dBydtheta)/BP;
% dBPdrho = (Bx*dBxdrho + By*dBydrho)/BP;
%
B = sqrt(Bx.^2 + By.^2 + Bz.^2);
dBdtheta = (Bx.*dBxdtheta + By.*dBydtheta + Bz.*dBzdtheta)./B;
%