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
%       - equil_val.x,equil_val.dxdtheta,equil_val.d2xdtheta2,equil_val.dxdrho,equil_val.d2xdthetadrho,equil_val.d2xdrho2: horizontal coordinate and its derivatives [1,1]
%       - equil_val.y,equil_val.dydtheta,equil_val.d2ydtheta2,equil_val.dydrho,equil_val.d2ydthetadrho,equil_val.d2ydrho2: vertical coordinate and its derivatives [1,1]
%       - equil_val.r,equil_val.drdtheta,equil_val.d2rdtheta2,equil_val.drdrho,equil_val.d2rdthetadrho,equil_val.d2rdrho2: minor radius and its derivatives [1,1]
%       - equil_val.salpha,equil_val.dsalphadtheta,equil_val.d2salphadtheta2,equil_val.dsalphadrho,equil_val.d2salphadthetadrho,equil_val.d2salphadrho2: sin(alpha) and its derivatives [1,1]
%       - equil_val.calpha,equil_val.dcalphadtheta,equil_val.d2calphadtheta2,equil_val.dcalphadrho,equil_val.d2calphadthetadrho,equil_val.d2calphadrho2: cos(alpha) and its derivatives [1,1]
%       - equil_val.Bx,equil_val.dBxdtheta,equil_val.d2Bxdtheta2,equil_val.dBxdrho,equil_val.d2Bxdthetadrho,equil_val.d2Bxdrho2: horizontal B-field and its derivatives
%       - equil_val.By,equil_val.dBydtheta,equil_val.d2Bydtheta2,equil_val.dBydrho,equil_val.d2Bydthetadrho,equil_val.d2Bydrho2: vertical B-field and its derivatives [1,1]
%       - equil_val.Bz,equil_val.dBzdtheta,equil_val.d2Bzdtheta2,equil_val.dBzdrho,equil_val.d2Bzdthetadrho,equil_val.d2Bzdrho2: toroidal or axial B-field and its derivatives (signed value) [1,1]
%       - equil_val.BP,equil_val.dBPdtheta,equil_val.d2BPdtheta2,equil_val.dBPdrho,equil_val.d2BPdthetadrho,equil_val.d2BPdrho2: poloidal B-field and its derivatives [1,1]
%       - equil_val.B,equil_val.dBdtheta,equil_val.d2Bdtheta2,equil_val.dBdrho,equil_val.d2Bdthetadrho,equil_val.d2Bdrho2: B-field and its derivatives [1,1]
%       - equil_val.gradrho,equil_val.dgradrhodtheta,equil_val.d2gradrhodtheta2,equil_val.dgradrhodrho,equil_val.d2gradrhodthetadrho,equil_val.d2gradrhodrho2: normalized gradient of rho and its derivatives [1,1]
%       - equil_val.Upsilon,equil_val.dUpsilondtheta,equil_val.d2Upsilondtheta2,equil_val.dUpsilondrho,equil_val.d2Upsilondthetadrho,equil_val.d2Upsilondrho2: toroidal form factor and its derivatives [1,1]
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
    equil_val.psin = ppval_yp(equil_fit.psin_fit.pp_f,rho);
    equil_val.dpsindrho = ppval_yp(equil_fit.psin_fit.pp_dfdrho,rho);
    equil_val.dxstardpsin = ppval_yp(equil_fit.dxstardpsin_fit.pp_f,rho);
    equil_val.ddxstardpsindrho = ppval_yp(equil_fit.dxstardpsin_fit.pp_dfdrho,rho);
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
    x_a0 = ppval_yp(equil_fit.x_fit.pp_a0,rho);
    x_an = ppval_yp(equil_fit.x_fit.pp_an,rho);
    x_bn = ppval_yp(equil_fit.x_fit.pp_bn,rho);
    x_da0drho = ppval_yp(equil_fit.x_fit.pp_da0drho,rho);
    x_dandrho = ppval_yp(equil_fit.x_fit.pp_dandrho,rho);
    x_dbndrho = ppval_yp(equil_fit.x_fit.pp_dbndrho,rho);
    if isfield(equil_fit.x_fit,'pp_d2a0drho2'),
        x_d2a0drho2 = ppval_yp(equil_fit.x_fit.pp_d2a0drho2,rho);
        x_d2andrho2 = ppval_yp(equil_fit.x_fit.pp_d2andrho2,rho);
        x_d2bndrho2 = ppval_yp(equil_fit.x_fit.pp_d2bndrho2,rho);
    else
        x_d2a0drho2 = zeros(size(x_da0drho));
        x_d2andrho2 = zeros(size(x_dandrho));
        x_d2bndrho2 = zeros(size(x_dbndrho));
    end
    %
    [equil_val.x,equil_val.dxdtheta,equil_val.d2xdtheta2,equil_val.dxdrho,equil_val.d2xdthetadrho,equil_val.d2xdrho2] = calcval_yp(equil_fit,theta,x_a0,x_an,x_bn,x_da0drho,x_dandrho,x_dbndrho,x_d2a0drho2,x_d2andrho2,x_d2bndrho2);
    %
    y_a0 = ppval_yp(equil_fit.y_fit.pp_a0,rho);
    y_an = ppval_yp(equil_fit.y_fit.pp_an,rho);
    y_bn = ppval_yp(equil_fit.y_fit.pp_bn,rho);
    y_da0drho = ppval_yp(equil_fit.y_fit.pp_da0drho,rho);
    y_dandrho = ppval_yp(equil_fit.y_fit.pp_dandrho,rho);
    y_dbndrho = ppval_yp(equil_fit.y_fit.pp_dbndrho,rho);
    if isfield(equil_fit.y_fit,'pp_d2a0drho2');
        y_d2a0drho2 = ppval_yp(equil_fit.y_fit.pp_d2a0drho2,rho);
        y_d2andrho2 = ppval_yp(equil_fit.y_fit.pp_d2andrho2,rho);
        y_d2bndrho2 = ppval_yp(equil_fit.y_fit.pp_d2bndrho2,rho);
    else
        y_d2a0drho2 = zeros(size(y_da0drho));
        y_d2andrho2 = zeros(size(y_dandrho));
        y_d2bndrho2 =zeros(size(y_dbndrho));
    end
    %
    [equil_val.y,equil_val.dydtheta,equil_val.d2ydtheta2,equil_val.dydrho,equil_val.d2ydthetadrho,equil_val.d2ydrho2] = calcval_yp(equil_fit,theta,y_a0,y_an,y_bn,y_da0drho,y_dandrho,y_dbndrho,y_d2a0drho2,y_d2andrho2,y_d2bndrho2);
    %
    r_a0 = ppval_yp(equil_fit.r_fit.pp_a0,rho);
    r_an = ppval_yp(equil_fit.r_fit.pp_an,rho);
    r_bn = ppval_yp(equil_fit.r_fit.pp_bn,rho);
    r_da0drho = ppval_yp(equil_fit.r_fit.pp_da0drho,rho);
    r_dandrho = ppval_yp(equil_fit.r_fit.pp_dandrho,rho);
    r_dbndrho = ppval_yp(equil_fit.r_fit.pp_dbndrho,rho);
    if isfield(equil_fit.r_fit,'pp_d2a0drho2');
        r_d2a0drho2 = ppval_yp(equil_fit.r_fit.pp_d2a0drho2,rho);
        r_d2andrho2 = ppval_yp(equil_fit.r_fit.pp_d2andrho2,rho);
        r_d2bndrho2 = ppval_yp(equil_fit.r_fit.pp_d2bndrho2,rho);
    else
        r_d2a0drho2 = zeros(size(r_da0drho));
        r_d2andrho2 = zeros(size(r_dandrho));
        r_d2bndrho2 = zeros(size(r_dbndrho)); 
    end
    %
    [equil_val.r,equil_val.drdtheta,equil_val.d2rdtheta2,equil_val.drdrho,equil_val.d2rdthetadrho,equil_val.d2rdrho2] = calcval_yp(equil_fit,theta,r_a0,r_an,r_bn,r_da0drho,r_dandrho,r_dbndrho,r_d2a0drho2,r_d2andrho2,r_d2bndrho2);
    %
    Bx_a0 = ppval_yp(equil_fit.Bx_fit.pp_a0,rho);
    Bx_an = ppval_yp(equil_fit.Bx_fit.pp_an,rho);
    Bx_bn = ppval_yp(equil_fit.Bx_fit.pp_bn,rho);
    Bx_da0drho = ppval_yp(equil_fit.Bx_fit.pp_da0drho,rho);
    Bx_dandrho = ppval_yp(equil_fit.Bx_fit.pp_dandrho,rho);
    Bx_dbndrho = ppval_yp(equil_fit.Bx_fit.pp_dbndrho,rho);
    if isfield(equil_fit.Bx_fit,'pp_d2a0drho2');
        Bx_d2a0drho2 = ppval_yp(equil_fit.Bx_fit.pp_d2a0drho2,rho);
        Bx_d2andrho2 = ppval_yp(equil_fit.Bx_fit.pp_d2andrho2,rho);
        Bx_d2bndrho2 = ppval_yp(equil_fit.Bx_fit.pp_d2bndrho2,rho);
    else
        Bx_d2a0drho2 = zeros(size(Bx_da0drho));
        Bx_d2andrho2 = zeros(size(Bx_dandrho));
        Bx_d2bndrho2 = zeros(size(Bx_dbndrho)); 
    end
    %
    [equil_val.Bx,equil_val.dBxdtheta,equil_val.d2Bxdtheta2,equil_val.dBxdrho,equil_val.d2Bxdthetadrho,equil_val.d2Bxdrho2] = calcval_yp(equil_fit,theta,Bx_a0,Bx_an,Bx_bn,Bx_da0drho,Bx_dandrho,Bx_dbndrho,Bx_d2a0drho2,Bx_d2andrho2,Bx_d2bndrho2);
    %
    By_a0 = ppval_yp(equil_fit.By_fit.pp_a0,rho);
    By_an = ppval_yp(equil_fit.By_fit.pp_an,rho);
    By_bn = ppval_yp(equil_fit.By_fit.pp_bn,rho);
    By_da0drho = ppval_yp(equil_fit.By_fit.pp_da0drho,rho);
    By_dandrho = ppval_yp(equil_fit.By_fit.pp_dandrho,rho);
    By_dbndrho = ppval_yp(equil_fit.By_fit.pp_dbndrho,rho);
    if isfield(equil_fit.By_fit,'pp_d2a0drho2');
        By_d2a0drho2 = ppval_yp(equil_fit.By_fit.pp_d2a0drho2,rho);
        By_d2andrho2 = ppval_yp(equil_fit.By_fit.pp_d2andrho2,rho);
        By_d2bndrho2 = ppval_yp(equil_fit.By_fit.pp_d2bndrho2,rho);
    else
        By_d2a0drho2 = zeros(size(By_da0drho));
        By_d2andrho2 = zeros(size(By_dandrho));
        By_d2bndrho2 = zeros(size(By_dbndrho)); 
    end
    %
    [equil_val.By,equil_val.dBydtheta,equil_val.d2Bydtheta2,equil_val.dBydrho,equil_val.d2Bydthetadrho,equil_val.d2Bydrho2] = calcval_yp(equil_fit,theta,By_a0,By_an,By_bn,By_da0drho,By_dandrho,By_dbndrho,By_d2a0drho2,By_d2andrho2,By_d2bndrho2);
    %
    Bz_a0 = ppval_yp(equil_fit.Bz_fit.pp_a0,rho);
    Bz_an = ppval_yp(equil_fit.Bz_fit.pp_an,rho);
    Bz_bn = ppval_yp(equil_fit.Bz_fit.pp_bn,rho);
    Bz_da0drho = ppval_yp(equil_fit.Bz_fit.pp_da0drho,rho);
    Bz_dandrho = ppval_yp(equil_fit.Bz_fit.pp_dandrho,rho);
    Bz_dbndrho = ppval_yp(equil_fit.Bz_fit.pp_dbndrho,rho);
    if isfield(equil_fit.Bz_fit,'pp_d2a0drho2');
        Bz_d2a0drho2 = ppval_yp(equil_fit.Bz_fit.pp_d2a0drho2,rho);
        Bz_d2andrho2 = ppval_yp(equil_fit.Bz_fit.pp_d2andrho2,rho);
        Bz_d2bndrho2 = ppval_yp(equil_fit.Bz_fit.pp_d2bndrho2,rho);
    else
        Bz_d2a0drho2 = zeros(size(Bz_da0drho));
        Bz_d2andrho2 = zeros(size(Bz_dandrho));
        Bz_d2bndrho2 = zeros(size(Bz_dbndrho)); 
    end
    %
    [equil_val.Bz,equil_val.dBzdtheta,equil_val.d2Bzdtheta2,equil_val.dBzdrho,equil_val.d2Bzdthetadrho,equil_val.d2Bzdrho2] = calcval_yp(equil_fit,theta,Bz_a0,Bz_an,Bz_bn,Bz_da0drho,Bz_dandrho,Bz_dbndrho,Bz_d2a0drho2,Bz_d2andrho2,Bz_d2bndrho2);
    %
    BP_a0 = ppval_yp(equil_fit.BP_fit.pp_a0,rho);
    BP_an = ppval_yp(equil_fit.BP_fit.pp_an,rho);
    BP_bn = ppval_yp(equil_fit.BP_fit.pp_bn,rho);
    BP_da0drho = ppval_yp(equil_fit.BP_fit.pp_da0drho,rho);
    BP_dandrho = ppval_yp(equil_fit.BP_fit.pp_dandrho,rho);
    BP_dbndrho = ppval_yp(equil_fit.BP_fit.pp_dbndrho,rho);
    if isfield(equil_fit.BP_fit,'pp_d2a0drho2');
        BP_d2a0drho2 = ppval_yp(equil_fit.BP_fit.pp_d2a0drho2,rho);
        BP_d2andrho2 = ppval_yp(equil_fit.BP_fit.pp_d2andrho2,rho);
        BP_d2bndrho2 = ppval_yp(equil_fit.BP_fit.pp_d2bndrho2,rho);
    else
        BP_d2a0drho2 = zeros(size(BP_da0drho));
        BP_d2andrho2 = zeros(size(BP_dandrho));
        BP_d2bndrho2 = zeros(size(BP_dbndrho)); 
    end
    %
    [equil_val.BP,equil_val.dBPdtheta,equil_val.d2BPdtheta2,equil_val.dBPdrho,equil_val.d2BPdthetadrho,equil_val.d2BPdrho2] = calcval_yp(equil_fit,theta,BP_a0,BP_an,BP_bn,BP_da0drho,BP_dandrho,BP_dbndrho,BP_d2a0drho2,BP_d2andrho2,BP_d2bndrho2);
    %
    B_a0 = ppval_yp(equil_fit.B_fit.pp_a0,rho);
    B_an = ppval_yp(equil_fit.B_fit.pp_an,rho);
    B_bn = ppval_yp(equil_fit.B_fit.pp_bn,rho);
    B_da0drho = ppval_yp(equil_fit.B_fit.pp_da0drho,rho);
    B_dandrho = ppval_yp(equil_fit.B_fit.pp_dandrho,rho);
    B_dbndrho = ppval_yp(equil_fit.B_fit.pp_dbndrho,rho);
    if isfield(equil_fit.B_fit,'pp_d2a0drho2');
        B_d2a0drho2 = ppval_yp(equil_fit.B_fit.pp_d2a0drho2,rho);
        B_d2andrho2 = ppval_yp(equil_fit.B_fit.pp_d2andrho2,rho);
        B_d2bndrho2 = ppval_yp(equil_fit.B_fit.pp_d2bndrho2,rho);
    else
        B_d2a0drho2 = zeros(size(B_da0drho));
        B_d2andrho2 = zeros(size(B_dandrho));
        B_d2bndrho2 = zeros(size(B_dbndrho)); 
    end
    %
    [equil_val.B,equil_val.dBdtheta,equil_val.d2Bdtheta2,equil_val.dBdrho,equil_val.d2Bdthetadrho,equil_val.d2Bdrho2] = calcval_yp(equil_fit,theta,B_a0,B_an,B_bn,B_da0drho,B_dandrho,B_dbndrho,B_d2a0drho2,B_d2andrho2,B_d2bndrho2);
    %
    calpha_a0 = ppval_yp(equil_fit.calpha_fit.pp_a0,rho);
    calpha_an = ppval_yp(equil_fit.calpha_fit.pp_an,rho);
    calpha_bn = ppval_yp(equil_fit.calpha_fit.pp_bn,rho);
    calpha_da0drho = ppval_yp(equil_fit.calpha_fit.pp_da0drho,rho);
    calpha_dandrho = ppval_yp(equil_fit.calpha_fit.pp_dandrho,rho);
    calpha_dbndrho = ppval_yp(equil_fit.calpha_fit.pp_dbndrho,rho);
    if isfield(equil_fit.calpha_fit,'pp_d2a0drho2');
        calpha_d2a0drho2 = ppval_yp(equil_fit.calpha_fit.pp_d2a0drho2,rho);
        calpha_d2andrho2 = ppval_yp(equil_fit.calpha_fit.pp_d2andrho2,rho);
        calpha_d2bndrho2 = ppval_yp(equil_fit.calpha_fit.pp_d2bndrho2,rho);
    else
        calpha_d2a0drho2 = zeros(size(calpha_da0drho));
        calpha_d2andrho2 = zeros(size(calpha_dandrho));
        calpha_d2bndrho2 = zeros(size(calpha_dbndrho)); 
    end
    %
    [equil_val.calpha,equil_val.dcalphadtheta,equil_val.d2calphadtheta2,equil_val.dcalphadrho,equil_val.d2calphadthetadrho,equil_val.d2calphadrho2] = calcval_yp(equil_fit,theta,calpha_a0,calpha_an,calpha_bn,calpha_da0drho,calpha_dandrho,calpha_dbndrho,calpha_d2a0drho2,calpha_d2andrho2,calpha_d2bndrho2);
    %
    salpha_a0 = ppval_yp(equil_fit.salpha_fit.pp_a0,rho);
    salpha_an = ppval_yp(equil_fit.salpha_fit.pp_an,rho);
    salpha_bn = ppval_yp(equil_fit.salpha_fit.pp_bn,rho);
    salpha_da0drho = ppval_yp(equil_fit.salpha_fit.pp_da0drho,rho);
    salpha_dandrho = ppval_yp(equil_fit.salpha_fit.pp_dandrho,rho);
    salpha_dbndrho = ppval_yp(equil_fit.salpha_fit.pp_dbndrho,rho);
    if isfield(equil_fit.salpha_fit,'pp_d2a0drho2');
        salpha_d2a0drho2 = ppval_yp(equil_fit.salpha_fit.pp_d2a0drho2,rho);
        salpha_d2andrho2 = ppval_yp(equil_fit.salpha_fit.pp_d2andrho2,rho);
        salpha_d2bndrho2 = ppval_yp(equil_fit.salpha_fit.pp_d2bndrho2,rho);
    else
        salpha_d2a0drho2 = zeros(size(salpha_da0drho));
        salpha_d2andrho2 = zeros(size(salpha_dandrho));
        salpha_d2bndrho2 = zeros(size(salpha_dbndrho)); 
    end
    %
    [equil_val.salpha,equil_val.dsalphadtheta,equil_val.d2salphadtheta2,equil_val.dsalphadrho,equil_val.d2salphadthetadrho,equil_val.d2salphadrho2] = calcval_yp(equil_fit,theta,salpha_a0,salpha_an,salpha_bn,salpha_da0drho,salpha_dandrho,salpha_dbndrho,salpha_d2a0drho2,salpha_d2andrho2,salpha_d2bndrho2);
    %
    gradrho_a0 = ppval_yp(equil_fit.gradrho_fit.pp_a0,rho);
    gradrho_an = ppval_yp(equil_fit.gradrho_fit.pp_an,rho);
    gradrho_bn = ppval_yp(equil_fit.gradrho_fit.pp_bn,rho);
    gradrho_da0drho = ppval_yp(equil_fit.gradrho_fit.pp_da0drho,rho);
    gradrho_dandrho = ppval_yp(equil_fit.gradrho_fit.pp_dandrho,rho);
    gradrho_dbndrho = ppval_yp(equil_fit.gradrho_fit.pp_dbndrho,rho);
    if isfield(equil_fit.gradrho_fit,'pp_d2a0drho2');
        gradrho_d2a0drho2 = ppval_yp(equil_fit.gradrho_fit.pp_d2a0drho2,rho);
        gradrho_d2andrho2 = ppval_yp(equil_fit.gradrho_fit.pp_d2andrho2,rho);
        gradrho_d2bndrho2 = ppval_yp(equil_fit.gradrho_fit.pp_d2bndrho2,rho);
    else
        gradrho_d2a0drho2 = zeros(size(gradrho_da0drho));
        gradrho_d2andrho2 = zeros(size(gradrho_dandrho));
        gradrho_d2bndrho2 = zeros(size(gradrho_dbndrho)); 
    end
    %
    [equil_val.gradrho,equil_val.dgradrhodtheta,equil_val.d2gradrhodtheta2,equil_val.dgradrhodrho,equil_val.d2gradrhodthetadrho,equil_val.d2gradrhodrho2] = calcval_yp(equil_fit,theta,gradrho_a0,gradrho_an,gradrho_bn,gradrho_da0drho,gradrho_dandrho,gradrho_dbndrho,gradrho_d2a0drho2,gradrho_d2andrho2,gradrho_d2bndrho2);
    %
    if isinf(equil_val.Rp),
        equil_val.Upsilon = 1;
        equil_val.dUpsilondrho = 0;
        equil_val.dUpsilondtheta = 0;
        equil_val.d2Upsilondtheta2 = 0;
        equil_val.d2Upsilondthetadrho = 0;
        equil_val.d2Upsilondrho2 = 0;
    else

        equil_val.Upsilon = 1 + equil_val.x/equil_val.Rp;
        equil_val.dUpsilondrho = equil_val.dxdrho/equil_val.Rp;
        equil_val.dUpsilondtheta = equil_val.dxdtheta/equil_val.Rp;
        equil_val.d2Upsilondtheta2 = equil_val.d2xdtheta2/equil_val.Rp;
        equil_val.d2Upsilondthetadrho = equil_val.d2xdthetadrho/equil_val.Rp;
        equil_val.d2Upsilondrho2 = equil_val.d2xdrho2/equil_val.Rp;
    end
    %
elseif isfield(equil_fit.Bx_fit,'CC'),% (x,y,phi) coordinates
    %
    if size(a) == size(b),
        x = a(:).';
        y = b(:).';
    else
        error('ERROR: input coordinates must have the same number of dimensions');
    end
    %

    keyboard
    [k,l] = find((equil_fit.XX(:,1)*ones(1,length(x)) < ones(length(equil_fit.XX(:,1)),1)*x) & (ones(length(equil_fit.XX(:,1)),1)*x < equil_fit.XX(:,2)*ones(1,length(x))) & (equil_fit.YY(:,1)*ones(1,length(y)) < ones(length(equil_fit.YY(:,1)),1)*y) & (ones(length(equil_fit.YY(:,4)),1)*y < equil_fit.YY(:,4)*ones(1,length(y))));
    %
    t = ((x.' - equil_fit.XX(k,1))./(equil_fit.XX(k,2) - equil_fit.XX(k,1))).';
    u = ((y.' - equil_fit.YY(k,1))./(equil_fit.YY(k,4) - equil_fit.YY(k,1))).';
    %
    l = 1;
    for ii = 0:3,
        for jj = 0:3,
            ut(l,:) = t.^ii.*u.^jj;
            dutdt(l,:) = ii*t.^(ii-1).*u.^jj;
            dutdu(l,:) = jj*t.^ii.*u.^(jj-1);
            l = l+1;
        end
    end
    %
    equil_val.ne = equil_fit.ne_fit.CC(k,:)*ut(:);
    equil_val.dnedx = equil_fit.ne_fit.CC(k,:)*dutdt(:);
    equil_val.dnedy = equil_fit.ne_fit.CC(k,:)*dutdu(:);
    %

else
    error('ERROR: the format of the structure equil_fit is not recognized')
end