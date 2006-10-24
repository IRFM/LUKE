function xY = init_RT_jd(equil,equil_fit,xrho,xtheta,xphi,xomega,xNpar,xm,xmode,sigma,kmode);
%
% This function solves the dispersion relation from initial positions and 
% wave characteristics to initiate ray-tracing calculations.
%
%   INPUTS :
%
%       - equil: initial magnetic equilibrium
%       - equil_fit: fitted DKE equilibrium structure
%       - xrho: normalized minor radius positions [nx]
%       - xtheta: poloidal positions (rad) [nx]
%       - xphi: toroidal positions (rad) [nx]
%       - xomega: wave frequencies (rad/s) [nx]
%       - xNpar: parallel indices of refraction [nx]
%       - xm: poloidal mode numbers [nx]
%       - xmode: cold plasma mode [nx] : (-1) m (1) p 
%           p is the slow mode when kperp > 0 (ex : LH slow wave)
%       - sigma: direction of the wave propagation (outward, or inward)
%       - kmode: kinetic (1) or cold (0) plasma model
%
%   OUTPUTS :
%
%       - xY: canonical coordinates vector [8,nx] decomposed into
%               - xpsin [1,nx]
%               - xtheta (rad) [1,nx]
%               - xphi (rad) [1,nx]
%               - xkrhon  [1,nx]
%               - xm [1,nx]
%               - xn [1,nx]
%               - xomega/clum (m^-1) [1,nx]
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
xpsin = rho2psi_jd(equil,xrho(:).','spline');
xtheta = xtheta(:).';
xphi = xphi(:).';
xomega = xomega(:).';
xNpar = xNpar(:).';
xm = xm(:).';
%
nx = length(xpsin);
%
if length(xtheta) ~= nx | length(xphi) ~= nx | length(xomega) ~= nx | length(xNpar) ~= nx | length(xm) ~= nx,
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
x_an_fit = ppval(equil_fit.x_fit.pp_an,xrho).';
x_bn_fit = ppval(equil_fit.x_fit.pp_bn,xrho).';
%
y_a0_fit = ppval(equil_fit.y_fit.pp_a0,xrho);
y_an_fit = ppval(equil_fit.y_fit.pp_an,xrho).';
y_bn_fit = ppval(equil_fit.y_fit.pp_bn,xrho).';
%
Bx_a0_fit = ppval(equil_fit.Bx_fit.pp_a0,xrho);
Bx_an_fit = ppval(equil_fit.Bx_fit.pp_an,xrho).';
Bx_bn_fit = ppval(equil_fit.Bx_fit.pp_bn,xrho).';
%
By_a0_fit = ppval(equil_fit.By_fit.pp_a0,xrho);
By_an_fit = ppval(equil_fit.By_fit.pp_an,xrho).';
By_bn_fit = ppval(equil_fit.By_fit.pp_bn,xrho).';
%
BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,xrho);
BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,xrho).';
BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,xrho).';
%
% Build interpolated magnetic fields
%
xx = zeros(1,nx);
xy = zeros(1,nx);
xr = zeros(1,nx);
xc = zeros(1,nx);
xs = zeros(1,nx);
xBt = zeros(1,nx);
xBp = zeros(1,nx);
%
for ix = 1:nx,
    %
    xx(ix) = x_a0_fit(ix) + x_an_fit(ix,:)*cos(equil_fit.x_fit.n*xtheta(ix)) + x_bn_fit(ix,:)*sin(equil_fit.x_fit.n*xtheta(ix));
    xy(ix) = y_a0_fit(ix) + y_an_fit(ix,:)*cos(equil_fit.y_fit.n*xtheta(ix)) + y_bn_fit(ix,:)*sin(equil_fit.y_fit.n*xtheta(ix));
    xdxdtheta(ix) = -x_an_fit(ix,:)*(equil_fit.x_fit.n.*sin(equil_fit.x_fit.n*xtheta(ix))) + x_bn_fit(ix,:)*(equil_fit.x_fit.n.*cos(equil_fit.x_fit.n*xtheta(ix)));
    xdydtheta(ix) = -y_an_fit(ix,:)*(equil_fit.y_fit.n.*sin(equil_fit.y_fit.n*xtheta(ix))) + y_bn_fit(ix,:)*(equil_fit.y_fit.n.*cos(equil_fit.y_fit.n*xtheta(ix)));    
    xBx(ix) = Bx_a0_fit(ix) + Bx_an_fit(ix,:)*cos(equil_fit.Bx_fit.n*xtheta(ix)) + Bx_bn_fit(ix,:)*sin(equil_fit.Bx_fit.n*xtheta(ix));
    xBy(ix) = By_a0_fit(ix) + By_an_fit(ix,:)*cos(equil_fit.By_fit.n*xtheta(ix)) + By_bn_fit(ix,:)*sin(equil_fit.By_fit.n*xtheta(ix));
    xBPHI(ix) = BPHI_a0_fit(ix) + BPHI_an_fit(ix,:)*cos(equil_fit.BPHI_fit.n*xtheta(ix)) + BPHI_bn_fit(ix,:)*sin(equil_fit.BPHI_fit.n*xtheta(ix));
    %    
end
%
sigmaIp =  sign((-equil.ptBx(end,1).*sin(equil.theta(1)) + equil.ptBy(end,1).*cos(equil.theta(1))));%Sign of the plasma current
%
xR = xx + equil_fit.Rp;
xr = sqrt(xx.^2 + xy.^2);
xs = (xx.*xdxdtheta + xy.*xdydtheta)./xr./sqrt(xdxdtheta.^2 + xdydtheta.^2);
xc = sqrt(1.0 - xs.^2);
xBp = sqrt(xBx.^2 + xBy.^2); 
xBt = xBPHI; 
xB = sqrt(xBt.^2 + xBp.^2);
xBtheta = sigmaIp*xBp./xB;
xBphi = sign(xBPHI).*xBt./xB;
xgradrho = xR.*xBp.*xdxstardpsin/equil_fit.psia/equil_fit.ap;
%
% Resolution of the dispersion relation
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
sm = [me;mp*zmi.'];
sZ = qe*[-1;zZi.'];
sxn = [xne;zxni];
sxT = [xTe;zxTi];
%
xNperp = zeros(1,nx);
%
for ix = 1:nx,
    %
    % Cold plasma calculations
    %
    [Nperpp,Nperpm] = colddisp_dke_jd(xNpar(ix),xomega(ix),xne(ix),zxni(:,ix),zZi,zmi,xB(ix));
    %
    if xmode(ix) == -1,
        Nperpc = Nperpm;
    elseif xmode(ix) == 1,
        Nperpc = Nperpp;
    else
        error('Wrond input in xmode')
    end        
    %
    % Normalization
    %
    if kmode == 1,
        sa = sZ.^2.*sxn(:,ix)./sm/e0/xomega(ix)^2;
        sy = sZ*xB(ix)./sm/xomega(ix);
        sbeta = sqrt(qe*sxT(:,ix)./sm/clum^2);
        %
        %   Kinetic plasma calculations
        %
        xNperp(ix) = kineticdisp_jd(sa,sy,sbeta,xNpar(ix),Nperpc,0);
    else
        xNperp(ix) = Nperpc;
    end
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
        = colddisp_dke_jd(xNpar2,xomega(ix),xne(ix),zxni(:,ix),zZi,zmi,xB(ix),xNperp2);
%    disp(['xNpar,xNperp,xNpar2,xNperp2,Dp,Dm:',num2str(xNpar),',',num2str(xNperp),',',num2str(xNpar2),',',num2str(xNperp2),',',num2str(Dp),',',num2str(Dm)]);
end



