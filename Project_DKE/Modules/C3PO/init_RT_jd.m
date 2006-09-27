function xY = init_RT_jd(equil,equil_fit,xrho,xtheta,xphi,xomega,xNpar,xm,xmode,kmode);
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
if nargin < 9,
    kmode = 0;
end
if nargin < 8,
    error('Not enough input arguments')
end
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
sigma = + sign(equil_fit.psia);%for a wave propagating inward (-LH, + EC ** to be checked ?????)
%
xdRstardpsin = ppval(equil_fit.dRstardpsin_fit.pp_f,xrho);
xTe = ppval(equil_fit.Te_fit.pp_f,xrho);
xne = ppval(equil_fit.ne_fit.pp_f,xrho);
zxTi = ppval(equil_fit.zTi_fit.pp_f,xrho);
zxni = ppval(equil_fit.zni_fit.pp_f,xrho);
%
zmi = equil_fit.zmi;
zZi = equil_fit.zZi;
%
R_a0_fit = ppval(equil_fit.R_fit.pp_a0,xrho);
R_an_fit = ppval(equil_fit.R_fit.pp_an,xrho).';
R_bn_fit = ppval(equil_fit.R_fit.pp_bn,xrho).';
%
Z_a0_fit = ppval(equil_fit.Z_fit.pp_a0,xrho);
Z_an_fit = ppval(equil_fit.Z_fit.pp_an,xrho).';
Z_bn_fit = ppval(equil_fit.Z_fit.pp_bn,xrho).';
%
BR_a0_fit = ppval(equil_fit.BR_fit.pp_a0,xrho);
BR_an_fit = ppval(equil_fit.BR_fit.pp_an,xrho).';
BR_bn_fit = ppval(equil_fit.BR_fit.pp_bn,xrho).';
%
BZ_a0_fit = ppval(equil_fit.BZ_fit.pp_a0,xrho);
BZ_an_fit = ppval(equil_fit.BZ_fit.pp_an,xrho).';
BZ_bn_fit = ppval(equil_fit.BZ_fit.pp_bn,xrho).';
%
BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,xrho);
BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,xrho).';
BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,xrho).';
%
% Build interpolated magnetic fields
%
xR = zeros(1,nx);
xZ = zeros(1,nx);
xr = zeros(1,nx);
xc = zeros(1,nx);
xs = zeros(1,nx);
xBt = zeros(1,nx);
xBp = zeros(1,nx);
%
for ix = 1:nx,
    %
    xR(ix) = R_a0_fit(ix) + R_an_fit(ix,:)*cos(equil_fit.R_fit.n*xtheta(ix)) + R_bn_fit(ix,:)*sin(equil_fit.R_fit.n*xtheta(ix));
    xZ(ix) = Z_a0_fit(ix) + Z_an_fit(ix,:)*cos(equil_fit.Z_fit.n*xtheta(ix)) + Z_bn_fit(ix,:)*sin(equil_fit.Z_fit.n*xtheta(ix));
    xdRdtheta(ix) = -R_an_fit(ix,:)*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*xtheta(ix))) + R_bn_fit(ix,:)*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*xtheta(ix)));
    xdZdtheta(ix) = -Z_an_fit(ix,:)*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*xtheta(ix))) + Z_bn_fit(ix,:)*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*xtheta(ix)));    
    xBR(ix) = BR_a0_fit(ix) + BR_an_fit(ix,:)*cos(equil_fit.BR_fit.n*xtheta(ix)) + BR_bn_fit(ix,:)*sin(equil_fit.BR_fit.n*xtheta(ix));
    xBZ(ix) = BZ_a0_fit(ix) + BZ_an_fit(ix,:)*cos(equil_fit.BZ_fit.n*xtheta(ix)) + BZ_bn_fit(ix,:)*sin(equil_fit.BZ_fit.n*xtheta(ix));
    xBPHI(ix) = BPHI_a0_fit(ix) + BPHI_an_fit(ix,:)*cos(equil_fit.BPHI_fit.n*xtheta(ix)) + BPHI_bn_fit(ix,:)*sin(equil_fit.BPHI_fit.n*xtheta(ix));
    %    
end
%
xr = sqrt((xR - equil_fit.Rp).^2 + (xZ - equil_fit.Zp).^2);
xs = ((xR - equil_fit.Rp).*xdRdtheta + (xZ - equil_fit.Zp).*xdZdtheta)./xr./sqrt(xdRdtheta.^2 + xdZdtheta.^2);
xc = sqrt(1.0 - xs.^2);
xBp = sqrt(xBR.^2 + xBZ.^2); 
xBt = xBPHI; 
xB = sqrt(xBt.^2 + xBp.^2);
xp = xBp./xB;
xt = xBt./xB;
xgradrho = xR.*xBp.*xdRstardpsin/equil_fit.psia/equil_fit.ap;%normalized to ap so that krho is normalized
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
xn = xR.*(xNpar.*xomega/clum - xm.*xc.*xp./xr)./xt;
%
xkrho = (xm.*xs./xr + sigma*sqrt(xNperp.^2.*xomega.^2/clum^2 - (xm.*xc./xr - xNpar.*xp.*xomega/clum).^2./xt.^2))./xgradrho;
%
xY = [xrho;xtheta;xphi;xkrho;xm;xn;xomega];
%xY = [xrho;xtheta;xphi;xkrho;xm;xn;xomega/clum;zeros(1,nx)];
%
% verification
%
if 1,
    xNpar2 = (xm.*xc.*xp./xr + xn.*xt./xR)*clum./xomega;
    xNperp2 = sqrt((xkrho.^2.*xgradrho.^2 - 2*xkrho.*xgradrho.*xm.*xs./xr + xm.^2./xr.^2 + xn.^2/xR.^2)*clum^2./xomega^2 - xNpar.^2);
    [Nperpp2,Nperpm2,Kxyz,...
        ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,...
        phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk,...
        Dp,Dm]...
        = colddisp_dke_jd(xNpar2,xomega(ix),xne(ix),zxni(:,ix),zZi,zmi,xB(ix),xNperp2);
    disp(['xNpar,xNperp,xNpar2,xNperp2,Dp,Dm:',num2str(xNpar),',',num2str(xNperp),',',...
        num2str(xNpar2),',',num2str(xNperp2),',',num2str(Dp),',',num2str(Dm)]);
end



