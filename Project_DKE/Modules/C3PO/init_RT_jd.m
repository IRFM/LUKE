function xY = init_RT_jd(equil_fit,xpsi,xtheta,xphi,xomega,xNpar,xm,xmode,kmode);
%
% This function solves the dispersion relation from initial positions and 
% wave characteristics to initiate ray-tracing calculations.
%
%   INPUTS :
%
%       - equil_fit: fitted DKE equilibrium structure
%       - xpsi: magnetic flux coordinate positions (Wb) [nx]
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
%               - xpsi (Wb) [1,nx]
%               - xtheta (rad) [1,nx]
%               - xphi (rad) [1,nx]
%               - xkpsi (Wb^-1) [1,nx]
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
xpsi = xpsi(:).';
xtheta = xtheta(:).';
xphi = xphi(:).';
xomega = xomega(:).';
xNpar = xNpar(:).';
xm = xm(:).';
%
nx = length(xpsi);
%
if length(xtheta) ~= nx | length(xphi) ~= nx | length(xomega) ~= nx | length(xNpar) ~= nx | length(xm) ~= nx,
    error('Input argument dimensions are not compatible');
end
%
sigma = - sign(equil_fit.psia);%for a wave propagating inward.
%
xTe = ppval(equil_fit.Te_fit.pp_f,xpsi);
xne = ppval(equil_fit.ne_fit.pp_f,xpsi);
zxTi = ppval(equil_fit.zTi_fit.pp_f,xpsi);
zxni = ppval(equil_fit.zni_fit.pp_f,xpsi);
%
zmi = equil_fit.zmi;
zZi = equil_fit.zZi;
%
BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,xpsi);
BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,xpsi).';
BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,xpsi).';
%
BP_a0_fit = ppval(equil_fit.BP_fit.pp_a0,xpsi);
BP_an_fit = ppval(equil_fit.BP_fit.pp_an,xpsi).';
BP_bn_fit = ppval(equil_fit.BP_fit.pp_bn,xpsi).';
%
R_a0_fit = ppval(equil_fit.R_fit.pp_a0,xpsi);
R_an_fit = ppval(equil_fit.R_fit.pp_an,xpsi).';
R_bn_fit = ppval(equil_fit.R_fit.pp_bn,xpsi).';
%
Z_a0_fit = ppval(equil_fit.Z_fit.pp_a0,xpsi);
Z_an_fit = ppval(equil_fit.Z_fit.pp_an,xpsi).';
Z_bn_fit = ppval(equil_fit.Z_fit.pp_bn,xpsi).';
%
r_a0_fit = ppval(equil_fit.r_fit.pp_a0,xpsi);
r_an_fit = ppval(equil_fit.r_fit.pp_an,xpsi).';
r_bn_fit = ppval(equil_fit.r_fit.pp_bn,xpsi).';
%
calpha_a0_fit = ppval(equil_fit.calpha_fit.pp_a0,xpsi);
calpha_an_fit = ppval(equil_fit.calpha_fit.pp_an,xpsi).';
calpha_bn_fit = ppval(equil_fit.calpha_fit.pp_bn,xpsi).';
%
salpha_a0_fit = ppval(equil_fit.salpha_fit.pp_a0,xpsi);
salpha_an_fit = ppval(equil_fit.salpha_fit.pp_an,xpsi).';
salpha_bn_fit = ppval(equil_fit.salpha_fit.pp_bn,xpsi).';
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
    xr(ix) = r_a0_fit(ix) + r_an_fit(ix,:)*cos(equil_fit.r_fit.n*xtheta(ix)) + r_bn_fit(ix,:)*sin(equil_fit.r_fit.n*xtheta(ix));
    xc(ix) = calpha_a0_fit(ix) + calpha_an_fit(ix,:)*cos(equil_fit.calpha_fit.n*xtheta(ix)) + calpha_bn_fit(ix,:)*sin(equil_fit.calpha_fit.n*xtheta(ix));
    xs(ix) = salpha_a0_fit(ix) + salpha_an_fit(ix,:)*cos(equil_fit.salpha_fit.n*xtheta(ix)) + salpha_bn_fit(ix,:)*sin(equil_fit.salpha_fit.n*xtheta(ix));
    xBt(ix) = BPHI_a0_fit(ix) + BPHI_an_fit(ix,:)*cos(equil_fit.BPHI_fit.n*xtheta(ix)) + BPHI_bn_fit(ix,:)*sin(equil_fit.BPHI_fit.n*xtheta(ix));
    xBp(ix) = BP_a0_fit(ix) + BP_an_fit(ix,:)*cos(equil_fit.BP_fit.n*xtheta(ix)) + BP_bn_fit(ix,:)*sin(equil_fit.BP_fit.n*xtheta(ix));
    %    
end
%
xB = sqrt(xBt.^2 + xBp.^2);
xp = xBp./xB;
xt = xBt./xB;
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
xkpsi = (xm.*xs./xr + sigma*sqrt(xNperp.^2.*xomega.^2/clum^2 - (xm.*xc./xr - xNpar.*xp.*xomega/clum).^2./xt.^2))./xR./xBp;
%
xY = [xpsi;xtheta;xphi;xkpsi;xm;xn;xomega/clum];
%xY = [xpsi;xtheta;xphi;xkpsi;xm;xn;xomega/clum;zeros(1,nx)];
