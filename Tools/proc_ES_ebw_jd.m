function [mask,xNperp,xepol_pmz,xphi_xyz,xalphaphi_lin_nr,...
        xalphaphi_lin_wr,xalphaphi_lin_fr,xepol_xyz,xepol_pyk,xphi_pmz,xphi_pyk] = ...
    proc_ES_ebw_jd(xa,xq,xbeta,xNpar,xNperp,opt_disp_in,nmax_in)
%
% Non-relativistic electrostatic dispersion processing for high-frequency waves
%
% Note: xalphaphi_lin is normalized to (omega/clum)
%
%   INPUTS:
%       
%       - xa: (wpe/w)^2 [1,nx]
%       - xq: w/wce [1,nx]
%       - xbeta: sqrt(Te/mc2) [1,nx]
%       - xNpar: parallel index of refraction [1,nx]
%       - xNperp_in: guess for root [1,nx] or [1,1] (with progressive guess)
%       - opt_disp: option for dispersion relation: 
%           - (0): exact ES NR 
%           - (1): Z function expansion large argument 2nd order 
%           - (2): Z function expansion large argument 1st order + Nperp >> Npar
%
%       - nmax: number of harmonic numbers to be considered
%
% J. Decker 14/12/05 (joan.decker@cea.fr)
%
if nargin < 7
    nmax_in = 50;
end
if nargin < 6
    opt_disp_in = 0;
end
if nargin < 5
    error('An initial guess must be provided')
end
%
opt_disp = opt_disp_in;
nmax = nmax_in;
%
nx = max([length(xa),length(xq),length(xbeta),length(xNpar),length(xNperp)]);
%
if length(xa) ~= nx,
    error('Argument dimension mismatch')
end
%
if length(xq) ~= nx,
    error('Argument dimension mismatch')
end
%
if length(xbeta) ~= nx,
    error('Argument dimension mismatch')
end
%
if length(xNpar) ~= nx,
    error('Argument dimension mismatch')
end
%
if length(xNperp) ~= nx,
    error('Argument dimension mismatch')
end
%
xa = xa(:).';
xq = xq(:).';
xbeta = xbeta(:).';
xNpar = xNpar(:).';
xNperp = xNperp(:).';
%
% --------------- Initialization -----------------
%
xalphaphi_lin_nr = NaN*ones(1,nx);
xalphaphi_lin_wr = NaN*ones(1,nx);
xalphaphi_lin_fr = NaN*ones(1,nx);
%
xepol_xyz = NaN*ones(3,nx);
xepol_pmz = NaN*ones(3,nx);
xepol_pyk = NaN*ones(3,nx);
%
xphi_xyz = NaN*ones(3,nx);
xphi_pmz = NaN*ones(3,nx);
xphi_pyk = NaN*ones(3,nx);
%
xlpar = (xNpar.*xbeta.*xq).^2;
%
xNperp(real(xNperp) < 1e-2) = NaN;
xlperp = (xNperp.*xbeta.*xq).^2;
%
mask = ~isnan(xNperp); 
nx = length(mask);
%
xa = xa(mask);
xq = xq(mask);
xbeta = xbeta(mask);
xNpar = xNpar(mask);
xNperp = xNperp(mask);
%
% ---------------- Polarization ------------------
%
xepol_pyk(1,mask) = 0;
xepol_pyk(2,mask) = 0;
xepol_pyk(3,mask) = 1;
%
xNtot = sqrt(xNperp.^2 + xNpar.^2);
%
xepol_xyz(1,mask) = xNperp./xNtot;
xepol_xyz(2,mask) = 0./xNtot;
xepol_xyz(3,mask) = xNpar./xNtot;
%
xepol_pmz(1,mask) = xNperp./xNtot/sqrt(2);
xepol_pmz(2,mask) = xNperp./xNtot/sqrt(2);
xepol_pmz(3,mask) = xNpar./xNtot;
%
% ------------- Energy flow density --------------
%
n = -(nmax+1):nmax+1;
nn = 2*nmax+1;
%
XBessel = besseli(n.',xlperp,1).'; % takes the Bessel function on lambda with orders 1:N
XGamma = XBessel(2:end-1,:);
XdGammadlperp = (XBessel(1:end-2,:) + XBessel(3:end,:))/2 - XGamma;
%
xdlperpdNperp = 2*xNperp.*(xbeta.*xq).^2;
xdlpardNpar = 2*xNpar.*(xbeta.*xq).^2;
%
Xn = repmat(n(2:end-1).',[1,nx]);
%
Xq = repmat(xq,[nn,1]);
Xlperp = repmat(xlperp,[nn,1]);
Xlpar = repmat(xlpar,[nn,1]);
%
if opt_disp == 0,
    %
    Xzeta = (Xq-Xn)./sqrt(2*Xlpar);
    %
    [XZ,XZp] = Zlasmadisp_jd(Xzeta);
    %
    xdYdNperp = xdlperpdNperp.*xa.*xq.^2./(xlperp + xlpar).*...
        sum((XdGammadlperp - XGamma./(Xlperp + Xlpar)).*(1 + Xn./Xq + Xq.*real(XZ)./sqrt(2*Xlpar)),1);
    xdYdNpar = - xdlpardNpar.*xa.*xq.^2./(xlperp + xlpar).*...
        sum(XGamma./(Xlperp + Xlpar).*(1 + Xn./Xq + Xq.*real(XZ)./sqrt(2*Xlpar)) + XGamma.*Xq.*(real(XZ) + Xzeta.*real(XZp))./(2*Xlpar).^(3/2),1);
elseif opt_disp == 1,
    %
    xdYdNperp = xdlperpdNperp.*xa./(xlperp + xlpar).*...
        sum((XGamma./(Xlperp + Xlpar) - XdGammadlperp).*(Xn.^2./(1 - Xn./Xq) + Xlpar./(1 - Xn./Xq).^3),1);
    %
    xdYdNpar = xdlpardNpar.*xa./(xlperp + xlpar).*...
        sum(XGamma./(Xlperp + Xlpar).*(Xn.^2./(1 - Xn./Xq) + Xlpar./(1 - Xn./Xq).^3) - XGamma./(1 - Xn./Xq).^3,1);
    %
elseif opt_disp == 2,
    %
    xdYdNperp = xdlperpdNperp.*xa./xlperp.*...
        sum((XGamma./Xlperp - XdGammadlperp).*Xn.^2./(1 - Xn./Xq),1);
    %
    xdYdNpar = zeros(1,nx);
    %
end
%
xphi_xyz(1,mask) = - xdYdNperp/2;
xphi_xyz(2,mask) = 0;
xphi_xyz(3,mask) = - xdYdNpar/2;
%
% ----------- Absorption Coefficient -------------
%
if nargout > 4,
	%
	[xalphaphi_lin_nr(mask),xalphaphi_lin_wr(mask),xalphaphi_lin_fr(mask)] = alphaphi_ebw_jd(xa,xq,xbeta,xNpar,xNperp,opt_disp,nmax);
	%
end

