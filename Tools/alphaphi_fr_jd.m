function xalphaphi = alphaphi_fr_jd(xa,xb,xbeta,xNpar,xNperp,xepol_pmz,n,rel_opt,ns,pperpmax);
%
%   ALPHAPHI_FR_JD 
%
%   This function calculates the fully relativistic electron absorption coefficient,
%   normalized to omega_rf/clum/phi, where omega_rf is the wave angular frequency
%   (in rad/s), clum is the speed of light (in m/s) and phi is the normalized
%   energy flow density. The result is an adimentional quantity.
%
%   INPUTS : 
%
%           - xa: omega_pe^2/omega_rf^2 [1,nx]
%           - xb: omega_ce/omega_rf [1,nx]
%           - xbeta: sqrt(kTe/mc2) [1,nx]
%           - xNpar: parallel index of refraction [1,nx]
%           - xNperp: perpendicular index of refraction [1,nx]
%           - xepol_pmz: polarization vector in rotating coordinates [3,nx]
%           - n: harmonic number [1,1] 
%           - rel_opt: option for non-relativistic (0) or relativistic (1) calculations (default: 0)
%           - ns: number of pperp integration steps [1,1] (default: 1000)
%           - pperpmax: maximum value for pperp integration [1,1] (default: 10)
%               Note: pperpmax valid only where xNpar >= 1; 
%                     elsewhere, pperpmax chosen by ellipse max position.
%
%   OUTPUTS :
%
%           - xalphaphi: alpha/(omega_rf/clum/phi) [1,nx]
%
%   by J. Decker 11/17/05
%
if nargin < 10,
    pperpmax = 10;
end
if nargin < 9,
    ns = 1000;
end
if nargin < 8,
    rel_opt = 0;
end
if nargin < 7,
    error('Not enough arguments')
end
%
xa = xa(:).';
xb = xb(:).';
xbeta = xbeta(:).';
xNpar = xNpar(:).';
xNperp = xNperp(:).';
%
xmask = ~isnan(xa) & ~isnan(xb) & ~isnan(xbeta) & ~isnan(xNpar) & ~isnan(xNperp) & ~isnan(sum(xepol_pmz));
%
nx = length(xa);
%
if size(xepol_pmz) == [nx,3],
    xepol_pmz = xepol_pmz.';
end
if length(xb) ~= nx | length(xbeta) ~= nx | length(xNpar) ~= nx | length(xNperp) ~= nx | size(xepol_pmz) ~= [3,nx] | length(n) ~= 1,
    error('Input dimensions mismatch')
end
%
xyn = xb*n;
xslperp = xNperp.*xbeta./xb;
%
Ntest = ceil(min(2*pi*ns/pperpmax./xslperp));
if Ntest < 50,
    warning(['Some positions have as little as ',num2str(Ntest),' integration steps per Bessel period'])
end
%
xmask_ellipse = xmask & (rel_opt == 1) & (xNpar.^2 < 1) & (n > 0) & (xyn > sqrt(1 - xNpar.^2));
xmask_parabola = xmask & (rel_opt == 1) & (xNpar.^2 == 1) & (n > 0);
xmask_hyperbola = xmask & (rel_opt == 1) & (xNpar.^2 > 1);
xmask_straight = xmask & (rel_opt == 0) & ((1 - xyn).^2 < xNpar.^2);
%
xpperpmax = pperpmax*ones(1,nx); % maximum pperp value in the integration
xpperpmax_ellipse = sqrt(xyn.^2./(1 - xNpar.^2) - 1)./xbeta; % maximum value of the ellipse
xpperpmax(xmask_ellipse) = xpperpmax_ellipse(xmask_ellipse);
xpperpmax(xpperpmax > pperpmax) = pperpmax; % pperp limited to pperp <= pperpmax
%
xInt = zeros(1,nx);
xInt(~xmask) = NaN;
%
if nx*ns <= 1e7,%no loop needed on the position
    %
    xInt(xmask_ellipse) = integral_fr_jd(xpperpmax(1,xmask_ellipse),xNpar(1,xmask_ellipse),xyn(1,xmask_ellipse),xbeta(1,xmask_ellipse),xepol_pmz(1,xmask_ellipse),xepol_pmz(2,xmask_ellipse),xepol_pmz(3,xmask_ellipse),xslperp(1,xmask_ellipse),n,ns,-1)...
                        + integral_fr_jd(xpperpmax(1,xmask_ellipse),xNpar(1,xmask_ellipse),xyn(1,xmask_ellipse),xbeta(1,xmask_ellipse),xepol_pmz(1,xmask_ellipse),xepol_pmz(2,xmask_ellipse),xepol_pmz(3,xmask_ellipse),xslperp(1,xmask_ellipse),n,ns,+1);
    %
    xInt(xmask_parabola) = integral_fr_jd(xpperpmax(1,xmask_parabola),xNpar(1,xmask_parabola),xyn(1,xmask_parabola),xbeta(1,xmask_parabola),xepol_pmz(1,xmask_parabola),xepol_pmz(2,xmask_parabola),xepol_pmz(3,xmask_parabola),xslperp(1,xmask_parabola),n,ns,0);
    %
    xInt(xmask_hyperbola) = integral_fr_jd(xpperpmax(1,xmask_hyperbola),xNpar(1,xmask_hyperbola),xyn(1,xmask_hyperbola),xbeta(1,xmask_hyperbola),xepol_pmz(1,xmask_hyperbola),xepol_pmz(2,xmask_hyperbola),xepol_pmz(3,xmask_hyperbola),xslperp(1,xmask_hyperbola),n,ns,-1);
    %
    xInt(xmask_straight) = integral_fr_jd(xpperpmax(1,xmask_straight),xNpar(1,xmask_straight),xyn(1,xmask_straight),xbeta(1,xmask_straight),xepol_pmz(1,xmask_straight),xepol_pmz(2,xmask_straight),xepol_pmz(3,xmask_straight),xslperp(1,xmask_straight),n,ns,NaN);
    %
else % loop needed on the position
    %
    %h = waitbar(0,'Calculation of the absorption coefficient');
    %
    for ix = 1:nx,
            %
        if xmask_ellipse(ix) == 1,
            %
            xInt(ix) = integral_fr_jd(xpperpmax(ix),xNpar(ix),xyn(ix),xbeta(ix),xepol_pmz(1,ix),xepol_pmz(2,ix),xepol_pmz(3,ix),xslperp(ix),n,ns,-1)...
                     + integral_fr_jd(xpperpmax(ix),xNpar(ix),xyn(ix),xbeta(ix),xepol_pmz(1,ix),xepol_pmz(2,ix),xepol_pmz(3,ix),xslperp(ix),n,ns,+1);
            %     
        elseif xmask_parabola(ix) == 1,
            %
            xInt(ix) = integral_fr_jd(xpperpmax(ix),xNpar(ix),xyn(ix),xbeta(ix),xepol_pmz(1,ix),xepol_pmz(2,ix),xepol_pmz(3,ix),xslperp(ix),n,ns,0);
            %
        elseif xmask_hyperbola(ix) == 1,
            %
            xInt(ix) = integral_fr_jd(xpperpmax(ix),xNpar(ix),xyn(ix),xbeta(ix),xepol_pmz(1,ix),xepol_pmz(2,ix),xepol_pmz(3,ix),xslperp(ix),n,ns,-1);
            %
        elseif xmask_straight(ix) == 1,
            %
            xInt(ix) = integral_fr_jd(xpperpmax(ix),xNpar(ix),xyn(ix),xbeta(ix),xepol_pmz(1,ix),xepol_pmz(2,ix),xepol_pmz(3,ix),xslperp(ix),n,ns,NaN);
            %           
        end  
        %
        %waitbar(ix/nx,h);
        %
    end
    %
    %close(h);
    %
end
%
if rel_opt == 1,
    xR = sqrt(pi/2)*xbeta./besselk(2,1./xbeta.^2,1);
else
    xR = 1;
end
%
xalphaphi = sqrt(pi/2)*xa.*xR.*xInt./xbeta;
%
%   Subfunction for the perpendicular momentum space integral
%
function xInt = integral_fr_jd(xpperpmax,xNpar,xyn,xbeta,xepol_p,xepol_m,xepol_z,xslperp,n,ns,res_opt);
    %
    sxpperp_S = linspace(0,1,ns+1).'*xpperpmax;   
    sxdpperp = diff(sxpperp_S);
    sxpperp = (sxpperp_S(1:ns,:) + sxpperp_S(2:ns+1,:))/2;
    %
    clear sxpperp_S
    %
    xsigma = sign(xNpar);
    %
    sxNpar = repmat(xNpar,[ns,1]);
    sxsigma = repmat(xsigma,[ns,1]);
    sxyn = repmat(xyn,[ns,1]);
    sxbeta = repmat(xbeta,[ns,1]);
    %
    if res_opt < 0,%branch m
        sxppar_res = (sxNpar.*sxyn - sxsigma.*sqrt(sxyn.^2 - (1 - sxNpar.^2).*(1 + sxbeta.^2.*sxpperp.^2)))./(sxbeta.*(1 - sxNpar.^2));
    elseif res_opt > 0,%branch p
        sxppar_res = (sxNpar.*sxyn + sxsigma.*sqrt(sxyn.^2 - (1 - sxNpar.^2).*(1 + sxbeta.^2.*sxpperp.^2)))./(sxbeta.*(1 - sxNpar.^2));
    elseif res_opt == 0,%branch 0
        sxppar_res = sxsigma.*(1 - sxyn.^2 + sxpperp.^2.*sxbeta.^2)./(2*sxbeta.*sxyn);
    else % non-relativistic calculation
        sxppar_res = (1 - sxyn)./sxbeta./sxNpar;
    end
    %
    clear sxsigma sxyn 
    %
    sxepol_p =  repmat(xepol_p,[ns,1]);
    sxepol_m =  repmat(xepol_m,[ns,1]);
    sxepol_z =  repmat(xepol_z,[ns,1]);
    %
    sxzeta = sxpperp.*repmat(xslperp,[ns,1]);
    %
    sxtheta = (sxepol_p.*besselj(n+1,sxzeta) + sxepol_m.*besselj(n-1,sxzeta))/sqrt(2) ...
        + sxepol_z.*besselj(n,sxzeta).*sxppar_res./sxpperp;
    %
    if ~isnan(res_opt),% relativistic case
        sxgamma = sqrt(1 + (sxppar_res.^2 + sxpperp.^2).*sxbeta.^2);
        %
        sxfint = sxpperp.^3.*abs(sxtheta).^2.*exp(-(sxgamma - 1)./sxbeta.^2)./abs(sxgamma.*sxNpar - sxppar_res.*sxbeta);
        %
    else
        %
        sxfint = sxpperp.^3.*abs(sxtheta).^2.*exp(-(sxppar_res.^2 + sxpperp.^2)/2)./abs(sxNpar);
        %
    end        
    %
    xInt = sum(sxfint.*sxdpperp);
%