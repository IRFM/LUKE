function [equil_val] = equilval_yp(equil_fit,a,b)
%
% This function calculates all parameters of the axisymmetric magnetic equilibrium at any position in the plasma
%
%   INPUT :
%
%       - equil_fit: fitted axisymmetric magnetic equilibrium structure
%
%   - if equil_fit corresponds to (rho,theta) coordinates
%
%       - a: rho -> normalized minor radius (a.u.) [1,1]
%       - b: theta -> poloidal angle (rad) [1,1]
%
%   - if equil_fit corresponds to (x,y) coordinates
%
%       - a: x -> radial coordinate (R - Rp) [1,1]
%       - b: y -> vertical coordinate (Z - Zp) [1,1]
%
%   OUTPUT :
%
%   if input coordinates are (rho,theta,z):
%
%       - equil_val.Te,equil_val.dTedrho,equil_val.d2Tedrho2: electron temperature and its derivatives [1,1]
%       - equil_val.ne,equil_val.dnedrho,equil_val.d2nedrho2: electron desnity and its derivatives [1,1]
%       - equil_val.zTi,equil_val.dzTidrho,equil_val.d2zTidrho2: ion temperatures and their derivatives [1,1]
%       - equil_val.zni,equil_val.dznidrho,equil_val.d2znidrho2: ion densities and their derivatives [1,1]
%       - equil_val.x,equil_val.dxdtheta,equil_val.d2xdtheta2,equil_val.dxdrho,equil_val.d2xdthetadrho: horizontal coordinate and its derivatives [1,1]
%       - equil_val.y,equil_val.dydtheta,equil_val.d2ydtheta2,equil_val.dydrho,equil_val.d2ydthetadrho: vertical coordinate and its derivatives [1,1]
%       - equil_val.r,equil_val.drdtheta,equil_val.drdrho: minor radius and its derivatives [1,1]
%       - equil_val.salpha,equil_val.dsalphadtheta,equil_val.dsalphadrho: sin(alpha) and its derivatives [1,1]
%       - equil_val.calpha,equil_val.dcalphadtheta,equil_val.dcalphadrho: cos(alpha) and its derivatives [1,1]
%       - equil_val.Bx,equil_val.dBxdtheta,equil_val.d2Bxdtheta2,equil_val.dBxdrho,equil_val.d2Bxdthetadrho: horizontal B-field and its derivatives
%       - equil_val.By,equil_val.dBydtheta,equil_val.d2Bydtheta2,equil_val.dBydrho,equil_val.d2Bydthetadrho: vertical B-field and its derivatives [1,1]
%       - equil_val.Bz,equil_val.dBzdtheta,equil_val.d2Bzdtheta2,equil_val.dBzdrho,equil_val.d2Bzdthetadrho: toroidal or axial B-field and its derivatives (signed value) [1,1]
%       - equil_val.BP,equil_val.dBPdtheta,equil_val.dBPdrho,equil_val.B,equil_val.dBdtheta,equil_val.dBdrho: poloidal B-field and its derivatives [1,1]
%       - equil_val.gradrho,equil_val.dgradrhodtheta,equil_val.dgradrhodrho: normalized gradient of rho and its derivatives [1,1]
%       - equil_val.Upsilon,equil_val.dUpsilondrho,equil_val.dUpsilondtheta: toroidal form factor and its derivatives [1,1]
%
%   if input coordinates are (x,y,z):
%
%
% by Y. Peysson DRFC-CEA <yves.peysson@cea.fr> and J. Decker DRFC-CEA <joan.decker@cea.fr> 
%
if nargin < 4
    mode = 1;
end
%
equil_val.Rp = equil_fit.Rp;
equil_val.Zp = equil_fit.Zp;
%
if isfield(equil_fit.Bx_fit,'pp_a0'),% (rho,theta) coordinates
    %
    rho = a;
    theta = b;
    %
    equil_val.psin = ppval(equil_fit.psin_fit.pp_f,rho);
    equil_val.dpsindrho = ppval(equil_fit.psin_fit.pp_dfdrho,rho);
    equil_val.dxstardpsin = ppval(equil_fit.dxstardpsin_fit.pp_f,rho);
    equil_val.ddxstardpsindrho = ppval(equil_fit.dxstardpsin_fit.pp_dfdrho,rho);
    %
    if isfield(equil_fit,'Te_fit'),
      equil_val.Te = ppval_yp(equil_fit.Te_fit.pp_f,rho);
      equil_val.dTedrho = ppval_yp(equil_fit.Te_fit.pp_dfdrho,rho);
      equil_val.d2Tedrho2 = ppval_yp(equil_fit.Te_fit.pp_d2fdrho2,rho);
    else
      equil_val.Te = [];
      equil_val.dTedrho = [];
      equil_val.d2Tedrho2 = [];
    end
    %
    if isfield(equil_fit,'ne_fit'),
      equil_val.ne = ppval_yp(equil_fit.ne_fit.pp_f,rho);
      equil_val.dnedrho = ppval_yp(equil_fit.ne_fit.pp_dfdrho,rho);
      equil_val.d2nedrho2 = ppval_yp(equil_fit.ne_fit.pp_d2fdrho2,rho);
    else
      equil_val.ne = [];
      equil_val.dnedrho = [];
      equil_val.d2nedrho2 = [];  
    end
    %
    if isfield(equil_fit,'zTi_fit'),
      equil_val.zTi = ppval_yp(equil_fit.zTi_fit.pp_f,rho);
      equil_val.dzTidrho = ppval_yp(equil_fit.zTi_fit.pp_dfdrho,rho);
      equil_val.d2zTidrho2 = ppval_yp(equil_fit.zTi_fit.pp_d2fdrho2,rho);
    else
      equil_val.zTi = [];
      equil_val.dzTidrho = [];
      equil_val.d2zTidrho2 = [];
    end
    %
    if isfield(equil_fit,'zni_fit'),
      equil_val.zni = ppval_yp(equil_fit.zni_fit.pp_f,rho);
      equil_val.dznidrho = ppval_yp(equil_fit.zni_fit.pp_dfdrho,rho);
      equil_val.d2znidrho2 = ppval_yp(equil_fit.zni_fit.pp_d2fdrho2,rho);
    else
      equil_val.zni = [];
      equil_val.dznidrho = [];
      equil_val.d2znidrho2 = [];
    end
    %
    x_a0 = ppval(equil_fit.x_fit.pp_a0,rho);
    x_an = ppval(equil_fit.x_fit.pp_an,rho);
    x_bn = ppval(equil_fit.x_fit.pp_bn,rho);
    x_da0drho = ppval(equil_fit.x_fit.pp_da0drho,rho);
    x_dandrho = ppval(equil_fit.x_fit.pp_dandrho,rho);
    x_dbndrho = ppval(equil_fit.x_fit.pp_dbndrho,rho);
    %
    [equil_val.x,equil_val.dxdtheta,equil_val.d2xdtheta2,equil_val.dxdrho,equil_val.d2xdthetadrho] = calcval_yp(equil_fit,theta,x_a0,x_an,x_bn,x_da0drho,x_dandrho,x_dbndrho);
    %
    y_a0 = ppval(equil_fit.y_fit.pp_a0,rho);
    y_an = ppval(equil_fit.y_fit.pp_an,rho);
    y_bn = ppval(equil_fit.y_fit.pp_bn,rho);
    y_da0drho = ppval(equil_fit.y_fit.pp_da0drho,rho);
    y_dandrho = ppval(equil_fit.y_fit.pp_dandrho,rho);
    y_dbndrho = ppval(equil_fit.y_fit.pp_dbndrho,rho);
    %
    [equil_val.y,equil_val.dydtheta,equil_val.d2ydtheta2,equil_val.dydrho,equil_val.d2ydthetadrho] = calcval_yp(equil_fit,theta,y_a0,y_an,y_bn,y_da0drho,y_dandrho,y_dbndrho);
    %
    r_a0 = ppval(equil_fit.r_fit.pp_a0,rho);
    r_an = ppval(equil_fit.r_fit.pp_an,rho);
    r_bn = ppval(equil_fit.r_fit.pp_bn,rho);
    r_da0drho = ppval(equil_fit.r_fit.pp_da0drho,rho);
    r_dandrho = ppval(equil_fit.r_fit.pp_dandrho,rho);
    r_dbndrho = ppval(equil_fit.r_fit.pp_dbndrho,rho);
    %
    [equil_val.r,equil_val.drdtheta,equil_val.d2rdtheta2,equil_val.drdrho,equil_val.d2rdthetadrho] = calcval_yp(equil_fit,theta,r_a0,r_an,r_bn,r_da0drho,r_dandrho,r_dbndrho);
    %
    Bx_a0 = ppval(equil_fit.Bx_fit.pp_a0,rho);
    Bx_an = ppval(equil_fit.Bx_fit.pp_an,rho);
    Bx_bn = ppval(equil_fit.Bx_fit.pp_bn,rho);
    Bx_da0drho = ppval(equil_fit.Bx_fit.pp_da0drho,rho);
    Bx_dandrho = ppval(equil_fit.Bx_fit.pp_dandrho,rho);
    Bx_dbndrho = ppval(equil_fit.Bx_fit.pp_dbndrho,rho);
    Bx_dbndrho = ppval(equil_fit.Bx_fit.pp_dbndrho,rho);
    %
    [equil_val.Bx,equil_val.dBxdtheta,equil_val.d2Bxdtheta2,equil_val.dBxdrho,equil_val.d2Bxdthetadrho] = calcval_yp(equil_fit,theta,Bx_a0,Bx_an,Bx_bn,Bx_da0drho,Bx_dandrho,Bx_dbndrho);
    %
    By_a0 = ppval(equil_fit.By_fit.pp_a0,rho);
    By_an = ppval(equil_fit.By_fit.pp_an,rho);
    By_bn = ppval(equil_fit.By_fit.pp_bn,rho);
    By_da0drho = ppval(equil_fit.By_fit.pp_da0drho,rho);
    By_dandrho = ppval(equil_fit.By_fit.pp_dandrho,rho);
    By_dbndrho = ppval(equil_fit.By_fit.pp_dbndrho,rho);
    %
    [equil_val.By,equil_val.dBydtheta,equil_val.d2Bydtheta2,equil_val.dBydrho,equil_val.d2Bydthetadrho] = calcval_yp(equil_fit,theta,By_a0,By_an,By_bn,By_da0drho,By_dandrho,By_dbndrho);
    %
    Bz_a0 = ppval(equil_fit.Bz_fit.pp_a0,rho);
    Bz_an = ppval(equil_fit.Bz_fit.pp_an,rho);
    Bz_bn = ppval(equil_fit.Bz_fit.pp_bn,rho);
    Bz_da0drho = ppval(equil_fit.Bz_fit.pp_da0drho,rho);
    Bz_dandrho = ppval(equil_fit.Bz_fit.pp_dandrho,rho);
    Bz_dbndrho = ppval(equil_fit.Bz_fit.pp_dbndrho,rho);
    %
    [equil_val.Bz,equil_val.dBzdtheta,equil_val.d2Bzdtheta2,equil_val.dBzdrho,equil_val.d2Bzdthetadrho] = calcval_yp(equil_fit,theta,Bz_a0,Bz_an,Bz_bn,Bz_da0drho,Bz_dandrho,Bz_dbndrho);
    %
    BP_a0 = ppval(equil_fit.BP_fit.pp_a0,rho);
    BP_an = ppval(equil_fit.BP_fit.pp_an,rho);
    BP_bn = ppval(equil_fit.BP_fit.pp_bn,rho);
    BP_da0drho = ppval(equil_fit.BP_fit.pp_da0drho,rho);
    BP_dandrho = ppval(equil_fit.BP_fit.pp_dandrho,rho);
    BP_dbndrho = ppval(equil_fit.BP_fit.pp_dbndrho,rho);
    %
    [equil_val.BP,equil_val.dBPdtheta,equil_val.d2BPdtheta2,equil_val.dBPdrho,equil_val.d2BPdthetadrho] = calcval_yp(equil_fit,theta,BP_a0,BP_an,BP_bn,BP_da0drho,BP_dandrho,BP_dbndrho);
    %
    B_a0 = ppval(equil_fit.B_fit.pp_a0,rho);
    B_an = ppval(equil_fit.B_fit.pp_an,rho);
    B_bn = ppval(equil_fit.B_fit.pp_bn,rho);
    B_da0drho = ppval(equil_fit.B_fit.pp_da0drho,rho);
    B_dandrho = ppval(equil_fit.B_fit.pp_dandrho,rho);
    B_dbndrho = ppval(equil_fit.B_fit.pp_dbndrho,rho);
    %
    [equil_val.B,equil_val.dBdtheta,equil_val.d2Bdtheta2,equil_val.dBdrho,equil_val.d2Bdthetadrho] = calcval_yp(equil_fit,theta,B_a0,B_an,B_bn,B_da0drho,B_dandrho,B_dbndrho);
    %
    calpha_a0 = ppval(equil_fit.calpha_fit.pp_a0,rho);
    calpha_an = ppval(equil_fit.calpha_fit.pp_an,rho);
    calpha_bn = ppval(equil_fit.calpha_fit.pp_bn,rho);
    calpha_da0drho = ppval(equil_fit.calpha_fit.pp_da0drho,rho);
    calpha_dandrho = ppval(equil_fit.calpha_fit.pp_dandrho,rho);
    calpha_dbndrho = ppval(equil_fit.calpha_fit.pp_dbndrho,rho);
    %
    [equil_val.calpha,equil_val.dcalphadtheta,equil_val.d2calphadtheta2,equil_val.dcalphadrho,equil_val.d2calphadthetadrho] = calcval_yp(equil_fit,theta,calpha_a0,calpha_an,calpha_bn,calpha_da0drho,calpha_dandrho,calpha_dbndrho);
    %
    salpha_a0 = ppval(equil_fit.salpha_fit.pp_a0,rho);
    salpha_an = ppval(equil_fit.salpha_fit.pp_an,rho);
    salpha_bn = ppval(equil_fit.salpha_fit.pp_bn,rho);
    salpha_da0drho = ppval(equil_fit.salpha_fit.pp_da0drho,rho);
    salpha_dandrho = ppval(equil_fit.salpha_fit.pp_dandrho,rho);
    salpha_dbndrho = ppval(equil_fit.salpha_fit.pp_dbndrho,rho);
    %
    [equil_val.salpha,equil_val.dsalphadtheta,equil_val.d2salphadtheta2,equil_val.dsalphadrho,equil_val.d2salphadthetadrho] = calcval_yp(equil_fit,theta,salpha_a0,salpha_an,salpha_bn,salpha_da0drho,salpha_dandrho,salpha_dbndrho);
    %
    gradrho_a0 = ppval(equil_fit.gradrho_fit.pp_a0,rho);
    gradrho_an = ppval(equil_fit.gradrho_fit.pp_an,rho);
    gradrho_bn = ppval(equil_fit.gradrho_fit.pp_bn,rho);
    gradrho_da0drho = ppval(equil_fit.gradrho_fit.pp_da0drho,rho);
    gradrho_dandrho = ppval(equil_fit.gradrho_fit.pp_dandrho,rho);
    gradrho_dbndrho = ppval(equil_fit.gradrho_fit.pp_dbndrho,rho);
    %
    [equil_val.gradrho,equil_val.dgradrhodtheta,equil_val.d2gradrhodtheta2,equil_val.dgradrhodrho,equil_val.d2gradrhodthetadrho] = calcval_yp(equil_fit,theta,gradrho_a0,gradrho_an,gradrho_bn,gradrho_da0drho,gradrho_dandrho,gradrho_dbndrho);
    %
    if isinf(equil_val.Rp),
        equil_val.Upsilon = 1;
        equil_val.dUpsilondrho = 0;
        equil_val.dUpsilondtheta = 0;
    else
        equil_val.Upsilon = 1 + equil_val.x/equil_val.Rp;
        equil_val.dUpsilondrho =  equil_val.dxdrho/equil_val.Rp;
        equil_val.dUpsilondtheta =  equil_val.dxdtheta/equil_val.Rp;
    end
    %
elseif isfield(equil_fit.Bx_fit,'CC'),% (x,y,phi) coordinates
    %
    rho = a;
    theta = b;
    %
else
    error('ERROR: the format of the structure equil_fit is not recognized')
end