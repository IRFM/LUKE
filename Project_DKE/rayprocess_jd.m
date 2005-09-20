function ray = rayprocess_jd(ray,equil,opt_disp,omega_rf,method);
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
[theta,ppsin,psia,ptR,ptZ,ptBR,ptBZ,ptBphi,pB0,pR0,pBT0,pBp0,prho,pTe,pne,pzTi,pzni,zZi,zmi,pZeff,Rp,Zp] = equilibrium_jd(equil);
%
ptr = sqrt((ptR - Rp).^2 + (ptZ - Zp).^2); %minor radius on the (psi,stheta) grid
ptBP = sqrt(ptBR.^2 + ptBZ.^2); %poloidal magnetic field on the (psi,stheta) grid
ptB = sqrt(ptBP.^2 + ptBphi.^2); %magnetic field on the (psi,stheta) grid
%
sR = ray.sR;% Ray location (major radius) along the propagation [1,ns]
sphi = ray.sphi;% Ray location (toroidal angle) along the propagation [1,ns]
sZ = ray.sZ;% Ray location (vertical) along the propagation [1,ns]
ss = ray.ss;% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
spsin = ray.spsin;% Ray location (normalized magnetic flux) along the propagation [1,ns]
stheta = ray.stheta;% Ray location (poloidal angle) along the propagation [1,ns]
%
skR = ray.skR;% Ray wave vector (major radius) along the propagation [1,ns]
sn = ray.sn;% Ray wave number (toroidal) along the propagation [1,ns]
skZ = ray.skZ;% Ray wave vector (vertical) along the propagation [1,ns]
%
sNpar = ray.sNpar;% Ray parallel wave number [1,ns]
sNperp = ray.sNperp;% Ray perpendicular wave number [1,ns]
sdNpar = ray.sdNpar;% Ray spectral width in Npar [1,ns] 
%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
%
sepol_pmz = ray.sepol_pmz;% polarization vector [3,ns] complex
sphi_pmz = ray.sphi_pmz;% normalized power flow [3,ns]
%
% Calculates ss (distance along the ray) if missing.
%
if isempty(ss),
    if isempty(sR) | isempty(sphi) | isempty(sZ)
        error('Ray-tracing data incomplete')
    end
    ns = length(sR);
    ss(1) = 0;
    if ns > 1,
        sRh = (sR(1:ns-1) + sR(2:ns))/2;
        ds = sqrt(diff(sR).^2 + (sRh.*diff(sphi)).^2 + diff(sZ).^2);
        ss(2:ns) = cumsum(ds);
    end
else 
    ns = length(ss);
end
%
% Calculates spsin and stheta (normalized flux and poloidal angle, location along the ray) and sR sZ sphi if missing.
%
if isempty(spsin) | isempty(stheta),
    if isempty(sR) | isempty(sZ)
        error('Ray-tracing data incomplete')
    end
    %
    % ray position in (r,theta) coordinates
    %
    sR = sR + eps*(sR == Rp); %to avoid singularities
    sZ = sZ + eps*(sZ == Zp); %to avoid singularities
    sr = sqrt((sR - Rp).^2 + (sZ - Zp).^2); %minor radius
    stheta = atan((sZ - Zp)./(sR - Rp)) + pi - pi*(sR > Rp).*sign(sZ - Zp); %poloidal angle [0,2*pi]
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
        spsin(is) = interp1(pstr(:,is),ppsin,sr(is),method2);%psi(s)
    end
    %
    % remove ray parts outlise the FS.
    %
    imask_1 = min(find(~isnan(spsin)));
    imask_2 = min([find(isnan(spsin(imask_1:ns))),ns - imask_1 + 2]);
    mask = [imask_1:imask_1 + imask_2 - 2];
    %
    % positive values only for spsin
    %
    if min(spsin) < -0
        error('The psin interpolation has produced negative values')
    end
    spsin(spsin <= 0) = eps;
else
    if isempty(sR) | isempty(sZ)
        sR = interp2(theta,ppsin,ptR,stheta,sypsin,method);
        sZ = interp2(theta,ppsin,ptZ,stheta,sypsin,method);
        if ~isempty(sNpar)
            ssigmah = sign((sNpar(1:ns-1,:) + sNpar(2:ns,:))/2);
        elseif ~isempty(sn)
            ssigmah = sign((sn(1:ns-1,:) + sn(2:ns,:))/2);
        else
            error('propagation data is imcomplete')
        end
        sphi(1,:) = 0;
        sRh = (sR(1:ns-1,:) + sR(2:ns,:))/2;
        dsphi = sqrt(diff(ss).^2 - diff(sRh).^2 - diff(sZ).^2)./sRh.*ssigmah;
        sphi(2:ns) = cumsum(dsphi);
    end
    sr = sqrt((sR - Rp).^2 + (sZ - Zp).^2); %minor radius
    %
    is0 = min(find(spsin < 1)); %position where the ray enters the plasma 
    ismax = min([find(spsin >= 1 & ss > ss(is0)) - 1,ns]); %position where the ray leaves the plasma (if applicable) 
    mask = is0:ismax;
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
sR = sR(mask);
sphi = sphi(mask);
sZ = sZ(mask);
%
ss = ss(mask);
ss = ss - ss(1);%reinitialize ss 
%
if ~isempty(skR) & ~isempty(sn) & ~isempty(skZ)
    skR = skR(mask);
    sn = sn(mask);
    skZ = skZ(mask);
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
if ~isempty(sepol_pmz)
    sepol_pmz = sepol_pmz(:,mask);
end
if ~isempty(sphi_pmz)
    sphi_pmz = sphi_pmz(:,mask);
end
if ~isempty(salphaphi_lin)
    salphaphi_lin = salphaphi_lin(:,mask);
end
%
% Calculates Equilibrium properties along the ray
%
sBR = interp2(theta,ppsin,ptBR,stheta,spsin,method);
sBphi = interp2(theta,ppsin,ptBphi,stheta,spsin,method);
sBZ = interp2(theta,ppsin,ptBZ,stheta,spsin,method);
sB = interp2(theta,ppsin,ptB,stheta,spsin,method);
sne = interp1(ppsin,pne,spsin,method);
szni = interp1(ppsin,pzni',spsin,method)';
sTe = interp1(ppsin,pTe,spsin,method);
szTi = interp1(ppsin,pzTi',spsin,method)';
%
% Calculates Npar and Nperp from kR,n and kZ if needed.
%
if isempty(sNpar),
    if isempty(skR) | isempty(sn) | isempty(skZ) 
        error('Ray-tracing data incomplete')
    end
    if isempty(sR)
        sR = interp2(theta,ppsin,ptR,st,spsin,method);
    end
    %
    skpar = (skR.*sBR + sn.*sBphi./sR + skZ.*sBZ)./sqrt(sBR.^2 + sBphi.^2 + sBZ.^2);
    sNpar = skpar*clum/omega_rf;
    %
    if isempty(sNperp), 
        skperp = sqrt(skR.^2 + (sn./sR).^2 + skZ.^2 - skpar.^2);
        sNperp = skperp*clum/omega_rf;
    end
end
%
% Calculates sdNpar if needed.
%
if isempty(sdNpar),
    sdNpar = 0.01*ones(1,ns);%assume a gaussian spectrum with this arbitrary width
end
%
if opt_disp == 0, %sepol_pmz, sNperp and phi_pmz given by ray-tracing
    if isempty(sepol_pmz) | isempty(sNperp) | isempty(sphi_pmz) 
        error('Ray-tracing data incomplete')
    end
else
%
% Solves the dispersion relation for sepol_pmz, sNperp and phi_pmz 
%
    if opt_disp == 1, % cold plasma dispersion tensor for sepol_pmz, sNperp and phi_pmz (colddisp_dke_jd)
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
            sphi_pmz = sphip_pmz.*(ones(3,1)*smaskp) + sphim_pmz.*(ones(3,1)*~smaskp);
        elseif length(sNperp) == 1
            %mask0 = (sNperp == 0)%O-mode;
            %%%%%%%%%% to be implemented %%%%%%%%%%
            error('model not yet implemented');
        else
            error('No information was given to choose between the two cold modes')
        end
    elseif opt_disp == 2, % warm plasma dispersion tensor for sepol_pmz, sNperp and phi_pmz (warmdisp_dke_jd)
        %%%%%%%%%% to be implemented %%%%%%%%%%
        error('model not yet implemented');
    elseif opt_disp == 3, % non-relativistic hot plasma dispersion tensor for sepol_pmz, sNperp and phi_pmz (R2D2) 
        [smask_ht,sNperp_ht,sepol_pmz_ht,sPflow_ht,sPabs_at] = ...
            disp_hot_jd(ss,sB,sne,sTe,sNpar,omega_rf,sNperp,0); 
%
        ns = length(smask_ht);
        %
        sNperp = sNperp_ht;
        sepol_pmz = sepol_pmz_ht;
        sphi_pmz(1,:) = abs(2*sPflow_ht(1,:)/e0/clum);
        sphi_pmz(2,:) = zeros(1,ns);
        sphi_pmz(3,:) = zeros(1,ns);       
        salphaphi_lin = 2*sPabs_at/e0/clum;
        %
        ss = ss(smask_ht);
        spsin = spsin(smask_ht);
        stheta = stheta(smask_ht);
        %
        sr = sr(smask_ht);
        sR = sR(smask_ht);
        sphi = sphi(smask_ht);
        sZ = sZ(smask_ht);
        %
        sNpar = sNpar(smask_ht);
        sdNpar = sdNpar(smask_ht);
        %
        if ~isempty(skR) & ~isempty(sn) & ~isempty(skZ)
            skR = skR(smask_ht);
            sn = sn(smask_ht);
            skZ = skZ(smask_ht);
        end        
        %
        sB = sB(smask_ht);
        sBR = sBR(smask_ht);
        sBphi = sBphi(smask_ht);
        sBZ = sBZ(smask_ht);
        %
        sne = sne(smask_ht);
        szni = szni(:,smask_ht);
        sTe = sTe(smask_ht);
        szTi = szTi(:,smask_ht);
        %
    elseif opt_disp == 4, % relativistic hot plasma dispersion tensor for sepol_pmz, sNperp and phi_pmz (R2D2)
        %%%%%%%%%% to be implemented %%%%%%%%%%
        error('model not yet implemented');
    else
        error('invalid disp option');
    end
end
%
ray.sR = sR;% Ray location (major radius) along the propagation [1,ns]
ray.sphi = sphi;% Ray location (toroidal angle) along the propagation [1,ns]
ray.sZ = sZ;% Ray location (vertical) along the propagation [1,ns]
ray.ss = ss;% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
ray.spsin = spsin;% Ray location (normalized magnetic flux) along the propagation [1,ns]
ray.stheta = stheta;% Ray location (poloidal angle) along the propagation [1,ns]
%
ray.skR = skR;% Ray wave vector (major radius) along the propagation [1,ns]
ray.sn = sn;% Ray wave number (toroidal) along the propagation [1,ns]
ray.skZ = skZ;% Ray wave vector (vertical) along the propagation [1,ns]
%
ray.sNpar = sNpar;% Ray parallel wave number [1,ns]
ray.sNperp = sNperp;% Ray perpendicular wave number [1,ns]
ray.sdNpar = sdNpar;% Ray spectral width in Npar [1,ns] 
%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
%
ray.sepol_pmz = sepol_pmz;% polarization vector [3,ns] complex
ray.sphi_pmz = sphi_pmz;% normalized power flow [3,ns]
%
% Additional ray parameters 
%
ray.sr = sr;
%
ray.sB = sB;
ray.sBR = sBR;
ray.sBphi = sBphi;
ray.sBZ = sBZ;
%
ray.sne = sne;
ray.szni = szni;
ray.sTe = sTe;
ray.szTi = szTi;
%
ray.salphaphi_lin = salphaphi_lin;
%
