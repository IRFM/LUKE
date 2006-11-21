function xY = init_RT_jd(equil,equil_fit,xrho,xtheta,xphi,xomega,xNpar,xm,xmode,sigma,kmode);
%
% This function solves the dispersion relation from initial positions and 
% wave characteristics to initiate ray-tracing calculations.
%
%   INPUTS :
%
%       - equil: initial magnetic equilibrium
%       - equil_fit: fitted DKE equilibrium structure
%       - xrho: normalized minor radius positions [1,1]
%       - xtheta: poloidal positions (rad) [1,1]
%       - xphi: toroidal positions (rad) [1,1]
%       - xomega: wave frequencies (rad/s) [1,1]
%       - xNpar: parallel indices of refraction [1,1]
%       - xm: poloidal mode numbers [1,1]
%       - xmode: cold plasma mode [1,1] : (-1) m (1) p 
%           p is the slow mode when kperp > 0 (ex : LH slow wave)
%       - sigma: direction of the wave propagation (outward, or inward)
%       - kmode: kinetic (1) or cold (0) plasma model
%
%   OUTPUTS :
%
%       - xY: canonical coordinates vector [8,nx] decomposed into
%               - xpsin [1,1]
%               - xtheta (rad) [1,1]
%               - xphi (rad) [1,1]
%               - xkrhon  [1,1]
%               - xm [1,1]
%               - xn [1,1]
%               - xomega/clum (m^-1) [1,1]
%
%   By J. Decker DRFC-CEA <joan.decker@cea.fr> and Y. Peysson DRFC-CEA <yves.peysson@cea.fr>
%
if nargin < 10,
    kmode = 0;
end
if nargin < 9,
    error('Not enough input arguments')
end
if abs(sigma) ~= 1,error('Parameter ''sigma'' for the wave direction at launch must be +1 or +1');end
%
xpsin = rho2psi_jd(equil,xrho,'spline');
%
if length(xtheta) ~= 1 | length(xphi) ~= 1 | length(xomega) ~= 1 | length(xNpar) ~= 1 | length(xm) ~= 1,
    error('Input argument dimensions are not compatible');
end
%
xdxstardpsin = ppval(equil_fit.dxstardpsin_fit.pp_f,xrho);
%
zmi = equil_fit.zmi;
zZi = equil_fit.zZi;
if isfield(equil_fit,'Te_fit'),xTe = ppval(equil_fit.Te_fit.pp_f,xrho);else xTe = zeros(size(xrho));end
if isfield(equil_fit,'ne_fit'),xne = ppval(equil_fit.ne_fit.pp_f,xrho);else xne = zeros(size(xrho));end
if isfield(equil_fit,'zTi_fit'),zxTi = ppval(equil_fit.zTi_fit.pp_f,xrho);else zxTi = zeros(length(zZi),length(xrho));end
if isfield(equil_fit,'zni_fit'),zxni = ppval(equil_fit.zni_fit.pp_f,xrho);else zxni = zeros(length(zZi),length(xrho));end
%
x_a0_fit = ppval(equil_fit.x_fit.pp_a0,xrho);
x_an_fit = ppval(equil_fit.x_fit.pp_an,xrho);
x_bn_fit = ppval(equil_fit.x_fit.pp_bn,xrho);
%
y_a0_fit = ppval(equil_fit.y_fit.pp_a0,xrho);
y_an_fit = ppval(equil_fit.y_fit.pp_an,xrho);
y_bn_fit = ppval(equil_fit.y_fit.pp_bn,xrho);
%
Bx_a0_fit = ppval(equil_fit.Bx_fit.pp_a0,xrho);
Bx_an_fit = ppval(equil_fit.Bx_fit.pp_an,xrho);
Bx_bn_fit = ppval(equil_fit.Bx_fit.pp_bn,xrho);
%
By_a0_fit = ppval(equil_fit.By_fit.pp_a0,xrho);
By_an_fit = ppval(equil_fit.By_fit.pp_an,xrho);
By_bn_fit = ppval(equil_fit.By_fit.pp_bn,xrho);
%
BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,xrho);
BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,xrho);
BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,xrho);
%
% Build interpolated magnetic fields
%	
[xx,xdxdtheta,dummy,dummy,dummy] = calcval_yp(equil_fit,x_a0_fit,x_an_fit,x_bn_fit,[],[],[],xtheta);
[xy,xdydtheta,dummy,dummy,dummy] = calcval_yp(equil_fit,y_a0_fit,y_an_fit,y_bn_fit,[],[],[],xtheta);
[xBx,dummy,dummy,dummy,dummy] = calcval_yp(equil_fit,Bx_a0_fit,Bx_an_fit,Bx_bn_fit,[],[],[],xtheta);
[xBy,dummy,dummy,dummy,dummy] = calcval_yp(equil_fit,By_a0_fit,By_an_fit,By_bn_fit,[],[],[],xtheta);
[xBPHI,dummy,dummy,dummy,dummy] = calcval_yp(equil_fit,BPHI_a0_fit,BPHI_an_fit,BPHI_bn_fit,[],[],[],xtheta);
%
sigmaIp =  sign((-equil.ptBx(end,1).*sin(equil.theta(1)) + equil.ptBy(end,1).*cos(equil.theta(1))));%Sign of the plasma current
%
xR = xx + equil_fit.Rp;
xr = sqrt(xx.^2 + xy.^2);
xs = sigmaIp*(xx.*xdxdtheta + xy.*xdydtheta)./xr./sqrt(xdxdtheta.^2 + xdydtheta.^2);
xc = sigmaIp*sqrt(1.0 - xs.^2);
xBp = sqrt(xBx.^2 + xBy.^2); 
xBt = xBPHI; 
xB = sqrt(xBt.^2 + xBp.^2);
xBtheta = xBp./xB;
xBphi = xBt./xB;
xgradrho = xR.*xBp.*xdxstardpsin/equil_fit.psia/equil_fit.ap;
%
% Resolution of the dispersion relation
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
sm = [me;mp*zmi(:)];
sZ = qe*[-1;zZi(:)];
sxn = [xne;zxni(:)];
sxT = [xTe;zxTi(:)];
%
xNperp = zeros(1,1);
%
% Cold plasma calculations
%
[Nperpp,Nperpm] = colddisp_dke_jd(xNpar,xomega,xne,zxni,zZi,zmi,xB);
%
if xmode == -1,
    Nperpc = Nperpm;
elseif xmode == 1,
    Nperpc = Nperpp;
else
    error('Wrond input in xmode')
end
%
% Normalization
%
if kmode == 1,
    sa = sZ.^2.*sxn./sm/e0/xomega^2;
    sy = sZ*xB./sm/xomega;
    sbeta = sqrt(qe*sxT./sm/clum^2);
%
%   Kinetic plasma calculations
%
    xNperp = kineticdisp_jd(sa,sy,sbeta,xNpar,Nperpc,0);
else
    xNperp = Nperpc;
end
%
xn = xR.*(xNpar.*xomega/clum - xm.*xc.*xBtheta./xr)./xBphi;
%
xkrho = (xm.*xs./xr + sigma*sqrt(-(xm.*xc./xr).^2 - (xn./xR).^2 + (xNperp.^2 + xNpar.^2).*xomega.^2/clum^2))./xgradrho;
%
xY = [xrho;xtheta;xphi;xkrho;xm;xn;xomega];
%
% verification
%
if 1,
    xNpar2 = (xm.*xc.*xBtheta./xr + xn.*xBphi./xR)*clum./xomega;
    xNperp2 = sqrt((xkrho.^2.*xgradrho.^2 - 2*xkrho.*xgradrho.*xm.*xs./xr + xm.^2./xr.^2 + xn.^2/xR.^2)*clum^2./xomega^2 - xNpar.^2);
    [Nperpp2,Nperpm2,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk,Dp,Dm]...
        = colddisp_dke_jd(xNpar2,xomega,xne,zxni,zZi,zmi,xB,xNperp2);
%    disp(['xNpar,xNperp,xNpar2,xNperp2,Dp,Dm:',num2str(xNpar),',',num2str(xNperp),',',num2str(xNpar2),',',num2str(xNperp2),',',num2str(Dp),',',num2str(Dm)]);
end



