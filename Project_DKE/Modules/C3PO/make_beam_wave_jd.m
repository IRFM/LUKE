function wave = make_beam_wave_jd(wave,equil,C3POdisplay,nd,nchi,w0,z0,nsm)
%
% This function generates a beam made of nd x nchi power tubes along a central ray
%
% Note : ray.swidth can be a scalar in which case the beam divergence is assumed to be zero.
%
if nargin < 8,
    nsm = 1;%smoothing parameter
end
%
if nargin < 7,
    z0 = NaN;
end
%
if nargin < 6,
    w0 = NaN;
end
%
if nargin < 5,
    nchi = 1;
end
%
if nargin < 4,
    nd = 1;
end
%
if length(wave.rays) ~= 1,
    if C3POdisplay.ray,disp('WARNING : This function only applies to the single ray representation.');end
    return
end
%
ray = wave.rays{1};
%
ss = ray.ss;
sphi_perp = abs(ray.sphi_xyz(1,:));
sphi_norm = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
omega_rf = wave.omega_rf;
%
ns = length(ss);
%
clum = 299792458;%Speed of light (m/s)
%
if ~isnan(w0),% beam width information given
    if ~isnan(z0)% gaussian beam representation
        zr = omega_rf.*w0^2/clum/2;
        swidthfac = sqrt(1 + (ss - z0).^2/zr^2);
    else
        swidthfac = ones(1,ns);
    end
    %
    swidth = w0*swidthfac/sqrt(2);
    %
    %ray.sdNpar = clum*sphi_perp./swidth./sphi_norm/omega_rf;
    %
else
    %warning('No beam width specified. Beam width determined from dNpar')
    swidth = clum*sphi_perp./ray.sdNpar./sphi_norm/omega_rf;
end
%
if nd == 1 || nchi == 1,
    wave.rays{1}.swidth = swidth;
    return
end
%
wave = rmfield(wave,'rays');
%
sx = ray.sx;
sy = ray.sy;
sphi = ray.sphi;
sNpar = ray.sNpar; 
sNperp = ray.sNperp;
%
if nsm > 1,
    sx = smooth(ss,sx,nsm).';
    sy = smooth(ss,sy,nsm).';
    sphi = smooth(ss,sphi,nsm).';
    %
    if length(sNpar) == ns,
        sNpar = smooth(ss,sNpar,nsm).';
    end
    if length(sNperp) == ns,
        sNperp = smooth(ss,sNperp,nsm).';
    end
end
%
sR = sx + equil.Rp;
%
sdx = zeros(1,ns);
sdy = zeros(1,ns);
sdphi = zeros(1,ns);
%
sdx(2:ns-1) = sx(3:ns) - sx(1:ns-2);
sdy(2:ns-1) = sy(3:ns) - sy(1:ns-2);
sdphi(2:ns-1) = sphi(3:ns) - sphi(1:ns-2);
%
sdx(1) = 2*(sx(2) - sx(1));
sdx(ns) = 2*(sx(ns) - sx(ns-1));
%
sdy(1) = 2*(sy(2) - sy(1));
sdy(ns) = 2*(sy(ns) - sy(ns-1));
%
sdphi(1) = 2*(sphi(2) - sphi(1));
sdphi(ns) = 2*(sphi(ns) - sphi(ns-1));
%
sv = sqrt(sdx.^2 + sR.^2.*sdphi.^2 + sdy.^2);
sz = sqrt(sdx.^2 + sR.^2.*sdphi.^2);
%
ir = 0;
%
for id = 1:nd,
    %
    sdi = swidth*sqrt(log(2*nd./(2*(nd - id) + 1)));
    %
    for jchi = 1:nchi,
        %
        ir = ir + 1;
        %
        schij = (2*jchi - 1)*pi/nchi;
        %
        sxR_ij = -sdi.*(cos(schij).*sdx.*sdy./sv - sin(schij).*sR.*sdphi)./sz;
        sxy_ij = sdi.*cos(schij).*(sdx.^2 + sR.^2.*sdphi.^2)./sz./sv;
        sxphi_ij = -sdi.*(cos(schij).*sR.*sdphi.*sdy./sv + sin(schij).*sdx)./sz;
        %
        sR_ij = sqrt((sR + sxR_ij).^2 + sxphi_ij.^2);
        sy_ij = sy + sxy_ij;
        sphi_ij = sphi + atan(sxphi_ij./(sR + sxR_ij));
        %
        sx_ij = sR_ij - equil.Rp;
        %
        wave.rays{ir}.P0_2piRp = ray.P0_2piRp/(nd*nchi);
        wave.rays{ir}.sx = sx_ij;
        wave.rays{ir}.sphi = sphi_ij;
        wave.rays{ir}.sy = sy_ij;
        %
        wave.rays{ir}.ss = [];
        wave.rays{ir}.spsin = [];
        wave.rays{ir}.stheta = [];
        %
        % The spectral properties must be the same as the central ray
        %        
        wave.rays{ir}.skx = ray.skx;
        wave.rays{ir}.sn = ray.sn;
        wave.rays{ir}.sky = ray.sky;
        wave.rays{ir}.sNpar = sNpar;
        wave.rays{ir}.sNperp= sNperp;
        wave.rays{ir}.sdNpar = ray.sdNpar;
        wave.rays{ir}.sepol_pmz = ray.sepol_pmz;
        wave.rays{ir}.sphi_xyz = ray.sphi_xyz;
        %
        wave.rays{ir}.swidth = swidth;
    end
end
%
if isfield(wave,'rayparam') && wave.rayparam.rel_opt == 0,
    wave.opt_disp = real(wave.opt_disp) - i;
else
    wave.opt_disp = real(wave.opt_disp) + i;
end    
%



