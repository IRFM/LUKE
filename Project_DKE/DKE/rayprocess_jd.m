function ray = rayprocess_jd(ray,equilDKE_Fourier,opt_disp,omega_rf,n_rf_list,method);
%
% This function calculates missing ray info if needed. 
% Also calculates the correct Nperp, polarization and power flow if required 
%
% created 03/01/05
% by J. Decker and Y. Peysson 
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
%
% equilibrium data with Fourier-enhanced poloidal precision and original radial grid
%
%
theta = equilDKE_Fourier.mtheta;
ppsin = equilDKE_Fourier.xpsin;
ptx = equilDKE_Fourier.Xx;
pty = equilDKE_Fourier.Xy;
ptBx = equilDKE_Fourier.XBx;
ptBy = equilDKE_Fourier.XBy;
ptBphi = equilDKE_Fourier.XBphi;
pB0 = equilDKE_Fourier.xB0;
px0 = equilDKE_Fourier.xx0;
pBT0 = equilDKE_Fourier.xBT0;
pBp0 = equilDKE_Fourier.xBp0;
prho = equilDKE_Fourier.xrho;
pTe = equilDKE_Fourier.xTe;
pne = equilDKE_Fourier.xne;
pzTi = equilDKE_Fourier.xzTi;
pzni = equilDKE_Fourier.xzni;
zZi = equilDKE_Fourier.zZi;
zmi = equilDKE_Fourier.zmi;
pZeff = equilDKE_Fourier.xZeff;
Rp = equilDKE_Fourier.Rp;
Zp = equilDKE_Fourier.Zp;
%
ptr = sqrt(ptx.^2 + pty.^2); %minor radius on the (psi,stheta) grid
ptBP = sqrt(ptBx.^2 + ptBy.^2); %poloidal magnetic field on the (psi,stheta) grid
ptB = sqrt(ptBP.^2 + ptBphi.^2); %magnetic field on the (psi,stheta) grid
%
if ~isinf(Rp), %toroidal FP calculations
    if ~isfield(ray,'sphi') | ~isfield(ray,'sn'),% check for toroidal ray tracing
        error('cylindrical ray tracing and toroidal FP codes are incompatible');
    else
        sphi = ray.sphi;% Ray location (toroidal angle) along the propagation [1,ns]
        sn = ray.sn;% Ray wave number (toroidal) along the propagation [1,ns]
    end
    tor_mode = 1;
else
    if ~isfield(ray,'sz') | ~isfield(ray,'skz'),% check for cylindrical ray tracing
        error('toroidal ray tracing and cylindrical FP codes are incompatible');
    else
        sz = ray.sz;% Ray longitudinal position
        skz = ray.skz;% Ray wave vector along the axis [1,ns]
    end
    tor_mode = 0;
end
%
sx = ray.sx;% Ray location (major radius) along the propagation [1,ns]
sy = ray.sy;% Ray location (vertical) along the propagation [1,ns]
ss = ray.ss;% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
spsin = ray.spsin;% Ray location (normalized magnetic flux) along the propagation [1,ns]
stheta = ray.stheta;% Ray location (poloidal angle) along the propagation [1,ns]
%
skx = ray.skx;% Ray wave vector (major radius) along the propagation [1,ns]
sky = ray.sky;% Ray wave vector (vertical) along the propagation [1,ns]
%
sNpar = ray.sNpar;% Ray parallel wave number [1,ns]
sNperp = ray.sNperp;% Ray perpendicular wave number [1,ns]
sdNpar = ray.sdNpar;% Ray spectral width in Npar [1,ns] 
%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
%
if isfield(ray,'swidth'),
    swidth = ray.swidth;
else
    swidth = [];
end
%
sepol_pmz = ray.sepol_pmz;% polarization vector [3,ns] complex
sphi_xyz = ray.sphi_xyz;% normalized power flow [3,ns]
%
% Calculates ss (distance along the ray) if missing.
%
if isempty(ss),
    if tor_mode == 1,
        if isempty(sx) | isempty(sphi) | isempty(sy)
            error('Ray-tracing data incomplete')
        end
        ns = length(sx);
        ss(1) = 0;
        if ns > 1,
            sR = Rp + sx;
            sRh = (sR(1:ns-1) + sR(2:ns))/2;
            ds = sqrt(diff(sx).^2 + (sRh.*diff(sphi)).^2 + diff(sy).^2);
            ss(2:ns) = cumsum(ds);
        end
    else
        if isempty(sx) | isempty(sy) | isempty(sz)
            error('Ray-tracing data incomplete')
        end
        ns = length(sx);
        ss(1) = 0;
        if ns > 1,
            ds = sqrt(diff(sx).^2 + diff(sy).^2 + diff(sz).^2);
            ss(2:ns) = cumsum(ds);
        end
    end
else 
    ns = length(ss);
end
%
mask = [1,find(diff(ss) > 0) + 1];
%
% Calculates spsin and stheta (normalized flux and poloidal angle, location along the ray) and sR sZ sphi if missing.
%
if isempty(spsin) | isempty(stheta),
    if isempty(sx) | isempty(sy)
        error('Ray-tracing data incomplete')
    end
    %
    % ray position in (r,theta) coordinates
    %
    sx(sx == 0) = eps; %to avoid singularities
    %sy(sy == 0) = eps; %to avoid singularities
    sr = sqrt(sx.^2 + sy.^2); %minor radius
    ssy = sign(sy);
    ssy(ssy == 0) = 1;
    stheta = atan(sy./sx) + pi - pi*(sx > 0).*ssy; %poloidal angle [0,2*pi]
    %
    if ns > 1,
        %
        % interpolation for r at ray poloidal locations    
        %
        pstr = interp1(theta,ptr',stheta,method)';%r(psi,st)
        %
        % interpolation for psi at ray position (along cst theta lines)
        %
        %spsin = interp1(pstr,ppsin,sr,method);%psi(s)
        method2 = 'linear';
        for is = 1:ns 
            spsin(is) = interp1(pstr(:,is),ppsin,sr(is),method2,1);%psi(s)
        end
        %
        % remove ray parts outlise the FS.
        %
        %imask_1 = min(find(~isnan(spsin)));
        %imask_2 = min([find(isnan(spsin(imask_1:ns))),ns - imask_1 + 2]);
        %mask = [imask_1:imask_1 + imask_2 - 2];
        %
        % positive values only for spsin
        %
    else
        spsin = ppsin;
    end
    %
    if min(spsin) < -0
        error('The psin interpolation has produced negative values')
    end
    spsin(spsin <= 0) = eps;
else
    if isempty(sx) | isempty(sy),
        sx = interp2(theta,ppsin,ptx,stheta,sypsin,method);
        sy = interp2(theta,ppsin,pty,stheta,sypsin,method);
        if tor_mode == 1,
            if ~isempty(sNpar)
                ssigmah = sign((sNpar(1:ns-1,:) + sNpar(2:ns,:))/2);
            elseif ~isempty(sn)
                ssigmah = sign((sn(1:ns-1,:) + sn(2:ns,:))/2);
            else
                error('propagation data is imcomplete')
            end
            sphi(1,:) = 0;
            sR = Rp + sx;
            sRh = (sR(1:ns-1,:) + sR(2:ns,:))/2;
            dsphi = sqrt(diff(ss).^2 - diff(sx).^2 - diff(sy).^2).*ssigmah./sRh;
            sphi(2:ns) = cumsum(dsphi);
        else
            if ~isempty(sNpar)
                ssigmah = sign((sNpar(1:ns-1,:) + sNpar(2:ns,:))/2);
            elseif ~isempty(skz)
                ssigmah = sign((skz(1:ns-1,:) + skz(2:ns,:))/2);
            else
                error('propagation data is imcomplete')
            end
            sz = sqrt(diff(ss).^2 - diff(sx).^2 - diff(sy).^2).*ssigmah;
        end            
    end
    sr = sqrt(sx.^2 + sy.^2); %minor radius
    %
%    is0 = min(find(spsin < 1)); %position where the ray enters the plasma 
%    ismax = min([find(spsin >= 1 & ss > ss(is0)) - 1,ns]); %position where the ray leaves the plasma (if applicable) 
%    mask = is0:ismax;
end    
%
try
    salphaphi_lin = ray.salphaphi_lin;
catch
    salphaphi_lin = NaN*ones(1,ns);
end
%
% remove unwanted ray parts
%
ns = length(mask);
%
spsin = spsin(mask);%part of ray outside the last flux-surface
stheta = stheta(mask);
%
sr = sr(mask);
%
sx = sx(mask);
sy = sy(mask);
%
if tor_mode == 1,
    sphi = sphi(mask);
    if ~isempty(sn),
        sn = sn(mask);
    end
else
    sz = sz(mask);
    if ~isempty(skz),
        skz = skz(mask);
    end
end
%
ss = ss(mask);
ss = ss - ss(1);%reinitialize ss 
%
if ~isempty(skx) & ~isempty(skZ)
    skx = skx(mask);
    sky = sky(mask);
end
if ~isempty(sNpar)
    sNpar = sNpar(mask);
end
if ~isempty(sNperp)
    sNperp = sNperp(mask);
end
if ~isempty(sdNpar)
    sdNpar = sdNpar(mask);
end
if ~isempty(swidth)
    swidth = swidth(mask);
end
if ~isempty(sepol_pmz)
    sepol_pmz = sepol_pmz(:,mask);
end
if ~isempty(sphi_xyz)
    sphi_xyz = sphi_xyz(:,mask);
end
if ~isempty(salphaphi_lin)
    salphaphi_lin = salphaphi_lin(:,mask);
end
%
% Calculates Equilibrium properties along the ray
%
if ns > 1,
    sBx = interp2(theta,ppsin,ptBx,stheta,spsin,method);
    sBphi = interp2(theta,ppsin,ptBphi,stheta,spsin,method);
    sBy = interp2(theta,ppsin,ptBy,stheta,spsin,method);
    sB = interp2(theta,ppsin,ptB,stheta,spsin,method);
    sne = interp1(ppsin,pne,spsin,method);
    szni = interp1(ppsin,pzni',spsin,method)';
    sTe = interp1(ppsin,pTe,spsin,method);
    szTi = interp1(ppsin,pzTi',spsin,method)';
else
    sBx = ptBx;
    sBphi = ptBphi;
    sBy = ptBy;
    sB = ptB;
    sne = pne;
    szni = pzni;
    sTe = pTe;
    szTi = pzTi;
end    
%
% Calculates Npar and Nperp from kx,n and kZ if needed.
%
if isempty(sNpar),
    if tor_mode == 1,
        if isempty(skx) | isempty(sn) | isempty(skZ) 
            error('Ray-tracing data incomplete')
        end
    %    if isempty(sR)
    %        sR = interp2(theta,ppsin,ptR,st,spsin,method);
    %    end
        %
        sR = Rp + sx;
        skpar = (skR.*sBR + sn.*sBphi./sR + skZ.*sBZ)./sqrt(sBR.^2 + sBphi.^2 + sBZ.^2);
        sNpar = skpar*clum/omega_rf;
        %
        if isempty(sNperp), 
            skperp = sqrt(skR.^2 + (sn./sR).^2 + skZ.^2 - skpar.^2);
            sNperp = skperp*clum/omega_rf;
        end
    else
        if isempty(skx) | isempty(sky) | isempty(skz) 
            error('Ray-tracing data incomplete')
        end
        skpar = (skx.*sBx + sky.*sBy + skz.*sBz)./sqrt(sBx.^2 + sBy.^2 + sBz.^2);
        sNpar = skpar*clum/omega_rf;
        %
        if isempty(sNperp), 
            skperp = sqrt(skx.^2 + sky.^2 + skz.^2 - skpar.^2);
            sNperp = skperp*clum/omega_rf;
        end        
    end
end
%
if real(opt_disp) == 0, %sepol_pmz, sNperp and phi_xyz given by ray-tracing
    if isempty(sepol_pmz) | isempty(sNperp) | isempty(sphi_xyz) 
        error('Ray-tracing data incomplete')
    end
else
%
% Solves the dispersion relation for sepol_pmz, sNperp and phi_xyz 
%
    if real(opt_disp) == 1, % cold plasma dispersion tensor for sepol_pmz, sNperp and phi_xyz (colddisp_dke_jd)
        for is = 1:ns
            [sNperpp(is),sNperpm(is),sKxyz(1:3,1:3,is),...
                sep_xyz(1:3,is),sem_xyz(1:3,is),sep_pmz(1:3,is),sem_pmz(1:3,is),sep_pyk(1:3,is),sem_pyk(1:3,is),...
                sphip_xyz(1:3,is),sphim_xyz(1:3,is),sphip_pmz(1:3,is),sphim_pmz(1:3,is),sphip_pyk(1:3,is),sphim_pyk(1:3,is)]...
            = colddisp_dke_jd(sNpar(is),omega_rf,sne(is),szni(:,is),zZi,zmi,sB(is));
        end
        if length(sNperp) == ns,
            smaskp = (abs(sNperpp - sNperp) <= abs(sNperpm - sNperp));
            sNperp = sNperpp.*smaskp + sNperpm.*~smaskp;
            sepol_pmz = sep_pmz.*(ones(3,1)*smaskp) + sem_pmz.*(ones(3,1)*~smaskp);
            sphi_xyz = sphip_xyz.*(ones(3,1)*smaskp) + sphim_xyz.*(ones(3,1)*~smaskp);
        elseif length(sNperp) == 1
            %mask0 = (sNperp == 0)%O-mode;
            %%%%%%%%%% to be implemented %%%%%%%%%%
            error('model not yet implemented');
        else
            error('No information was given to choose between the two cold modes')
        end
    elseif real(opt_disp) == 2, % non-relativistic hot plasma dispersion tensor for sepol_pmz, sNperp and phi_xyz (hotdisp_dke_jd)
        for is=1:ns,
            [sNperp(is),e_xyz,sepol_pmz(:,is),e_pyk,D,X,X_s,X_sn,salphaphi_lin(is),sphiT_xyz(:,is),sphiP_xyz(:,is)]...
                = hotdisp_dke_jd(sNpar(is),omega_rf,sTe(is),sne(is),szTi(:,is),szni(:,is),zZi,zmi,sB(is),sNperp(is),1);
        end
        sphi_xyz = real(sphiP_xyz + sphiT_xyz);
        salphaphi_lin = real(salphaphi_lin);
    elseif real(opt_disp) == 3, % non-relativistic hot plasma dispersion tensor for sepol_pmz, sNperp and phi_xyz (R2D2) 
        [smask_ht,sNperp_ht,sepol_pmz_ht,sPflow_ht,sPabs_at] = ...
            disp_hot_jd(ss,sB,sne,sTe,sNpar,omega_rf,sNperp,0); 
%
        ns = length(smask_ht);
        %
        sNperp = sNperp_ht(smask_ht);
        sepol_pmz = sepol_pmz_ht(:,smask_ht);
        sphi_xyz(1,:) = abs(2*sPflow_ht(1,smask_ht)/e0/clum);
        sphi_xyz(2,:) = zeros(1,ns);
        sphi_xyz(3,:) = zeros(1,ns);       
        salphaphi_lin = 2*sPabs_at(smask_ht)/e0/clum;
        %
        ss = ss(smask_ht);
        spsin = spsin(smask_ht);
        stheta = stheta(smask_ht);
        %
        sr = sr(smask_ht);
        sx = sx(smask_ht);
        sy = sy(smask_ht);
        %
        if tor_mode == 1,
            sphi = sphi(smask_ht);
            if ~isempty(sn)
                sn = sn(smask_ht);
            end               
        else
            sz = sz(smask_ht);
            if ~isempty(skz)
                skz = skz(smask_ht);
            end               
        end
        %
        sNpar = sNpar(smask_ht);
        sdNpar = sdNpar(smask_ht);
        %
        if ~isempty(skx) & ~isempty(sky)
            skx = skx(smask_ht);
            sky = sky(smask_ht);
        end        
        %
        sB = sB(smask_ht);
        sBx = sBx(smask_ht);
        sBy = sBy(smask_ht);
        sBphi = sBphi(smask_ht);
        %
        sne = sne(smask_ht);
        szni = szni(:,smask_ht);
        sTe = sTe(smask_ht);
        szTi = szTi(:,smask_ht);
        %
    elseif real(opt_disp) == 4, % relativistic hot plasma dispersion tensor for sepol_pmz, sNperp and phi_xyz (R2D2)
        %%%%%%%%%% to be implemented %%%%%%%%%%
        error('model not yet implemented');
    else
        error('invalid disp option');
    end
end
%
% Calculates sdNpar if needed.
%
if isempty(sdNpar),
    if ~isempty(swidth),
        sphi_norm = sqrt(abs(sphi_xyz(1,:).^2 + sphi_xyz(2,:).^2 + sphi_xyz(3,:).^2));
        sdNpar = clum.*abs(sphi_xyz(1,:))./sphi_norm/omega_rf./swidth;
    else
        sdNpar = 0.01*ones(1,ns);%assume a gaussian spectrum with this arbitrary width
    end
end
%
if imag(opt_disp) >= 1,%calculation of the absorption coefficient
    %
    rel_opt = (imag(opt_disp) == 1);
    %
    sa = sne*qe^2/e0/me/omega_rf^2;
    sb = sB*qe/me/omega_rf;
	sbeta = sqrt(sTe/mc2);
    salphaphi_lin = zeros(1,ns);
    for n = n_rf_list,
        salphaphi_lin = salphaphi_lin + omega_rf/clum*alphaphi_fr_jd(sa,sb,sbeta,sNpar,real(sNperp),sepol_pmz,n,rel_opt);
    end
end
%
ray.sx = sx;% Ray location (major radius) along the propagation [1,ns]
ray.sy = sy;% Ray location (vertical) along the propagation [1,ns]
ray.ss = ss;% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
ray.spsin = spsin;% Ray location (normalized magnetic flux) along the propagation [1,ns]
ray.stheta = stheta;% Ray location (poloidal angle) along the propagation [1,ns]
%
if tor_mode == 1,
    ray.sphi = sphi;% Ray location (toroidal angle) along the propagation [1,ns]
    if ~isempty(sn)
        ray.sn = sn;% Ray wave number (toroidal) along the propagation [1,ns]
    end               
else
    ray.sz = sz;% Ray location (toroidal angle) along the propagation [1,ns]
    if ~isempty(skz)
        ray.skz = skz;
    end               
end
%
ray.skx = skx;% Ray wave vector (major radius) along the propagation [1,ns]
ray.sky = sky;% Ray wave vector (vertical) along the propagation [1,ns]
%
ray.sNpar = sNpar;% Ray parallel wave number [1,ns]
ray.sNperp = real(sNperp);% Ray perpendicular wave number [1,ns]
ray.sdNpar = sdNpar;% Ray spectral width in Npar [1,ns] 
%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
%
ray.sepol_pmz = sepol_pmz;% polarization vector [3,ns] complex
ray.sphi_xyz = sphi_xyz;% normalized power flow [3,ns]
%
% Additional ray parameters 
%
ray.sr = sr;
%
ray.sB = sB;
ray.sBx = sBx;
ray.sBy = sBy;
ray.sBphi = sBphi;
%
ray.sne = sne;
ray.szni = szni;
ray.sTe = sTe;
ray.szTi = szTi;
%
ray.salphaphi_lin = salphaphi_lin;
%
