function waveparam = coldeccd_dke_jd(xyrho,xythetab,xyn,xyopt,xyNpar,xydNpar,xybwidth,xypol,xyomega_rf,xyPinc,xyfinc,Te_ref,ne_ref,xne_norm,zxni_norm,zZi,zmi,xyB0,Rp,ap,bounce_mode);
%
% Calculates the normalized diffusion coefficient, polarization elements, and Nperp for ECCD within the cold plasma model. 
%
% by J. Decker 05/02/03
%
% Updated 09/12/03
%
qe = 1.6022e-19;%Electron charge (C)
me = 9.1094e-31;%Electron rest mass (Kg)
mp = 1.6726e-27;%Proton rest mass (Kg)
e0 = 8.8542e-12;%Free space permeability (F/m)
clum = 299792458;%Speed of light (m/s)
%
xne = ne_ref*xne_norm;
zxni = ne_ref*zxni_norm;
xne = ne_ref*xne_norm;
%
[nr,nb] = size(xyrho);
%
xyia = xyrho*ap/Rp;
xyB = xyB0./(1 + xyia.*cos(xythetab));
xywce = qe*xyB/me;
%
for ir = 1:nr
    for ib = 1:nb
        Npar = xyNpar(ir,ib);
        omega_rf = xyomega_rf(ir,ib);
        ne = xne(ir);
        zni = zxni(:,ir);
        Bfield = xyB(ir,ib);
        %
        [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_ppk,em_ppk] = colddisp_dke_jd(Npar,omega_rf,ne,zni,zZi,zmi,Bfield);
        %
        mask = (xywce(ir,ib) < omega_rf);
        %
        NperpO = Nperpp.*mask + Nperpm.*~mask; 
        NperpX = Nperpp.*~mask + Nperpm.*mask; 
        %    
        xyNperpO(ir,ib) = NperpO;
        xyNperpX(ir,ib) = NperpX;
        %
        xyKxyz(1:3,1:3,ir,ib) = Kxyz;
        %
        eO_xyz = ep_xyz.*mask + em_xyz.*~mask; 
        eX_xyz = ep_xyz.*~mask + em_xyz.*mask; 
        eO_pmz = ep_pmz.*mask + em_pmz.*~mask; 
        eX_pmz = ep_pmz.*~mask + em_pmz.*mask; 
        eO_ppk = ep_ppk.*mask + em_ppk.*~mask; 
        eX_ppk = ep_ppk.*~mask + em_ppk.*mask; 
        %
        xy3eX_xyz(1:3,ir,ib) = eX_xyz;
        xy3eX_pmz(1:3,ir,ib) = eX_pmz;
        xy3eX_ppk(1:3,ir,ib) = eX_ppk;
        xy3eO_xyz(1:3,ir,ib) = eO_xyz;
        xy3eO_pmz(1:3,ir,ib) = eO_pmz;
        xy3eO_ppk(1:3,ir,ib) = eO_ppk;
    end
end
%
xyNperp = xyNperpX.*xypol + NperpO.*~xypol;
%
xy3pol = shiftdim(repmat(xypol,[1,1,3]),2);

xy3e_xyz = xy3eX_xyz.*xy3pol + xy3eO_xyz.*~xy3pol;
xy3e_pmz = xy3eX_pmz.*xy3pol + xy3eO_pmz.*~xy3pol;
xy3e_ppk = xy3eX_ppk.*xy3pol + xy3eO_ppk.*~xy3pol;
%
xyepolp = shiftdim(xy3e_pmz(1,:,:),1); 
xyepolm = shiftdim(xy3e_pmz(2,:,:),1); 
xyepolz = shiftdim(xy3e_pmz(3,:,:),1);
xyepolk = shiftdim(xy3e_ppk(3,:,:),1);
%
% electron frequencies
%
wpe_ref = sqrt(ne_ref*qe^2/e0/me);
xywce0 = qe*xyB0./(1 + xyia)/me;
%
lnc_ref = 15.2 - 0.5*log(ne_ref/1e20) + log(Te_ref);
%
xypsib = (1 + xyia)./(1 + xyia.*cos(xythetab));
xypsic = (1 + xyia);
%
if bounce_mode == 0 % 
    xywce_out = xywce0.*xypsib;
    xyrpsi = ones(nr,nb);
else
    xywce_out = xywce0;
    xyrpsi = xypsib./xypsic;
end
%
xyphibdn = (1 - abs(xyepolk).^2).*xyNperp./xyfinc;
%
xyD0 = xyPinc.*xyrpsi./(me*wpe_ref^2*lnc_ref*xyomega_rf.*abs(xyphibdn).*xyrho*ap*Rp);
%
xydNpar_bis = real(xyNperp./sqrt(xyNpar.^2 + xyNperp.^2)*clum./(xyomega_rf.*xybwidth));
mask = isnan(xydNpar);
xydNpar(mask) = xydNpar_bis(mask);
%    
% --------------------------- building waveparam-----------------------
%    
waveparam = zeros(nr,nb,14);
%
waveparam(:,:,1) = xyn;%RF resonance harmonic     
waveparam(:,:,2) = xyomega_rf;%RF wave frequency
waveparam(:,:,3) = xywce_out;%midplane cyclotron frequency (r,theta=0) at the radial position considered 
waveparam(:,:,4) = xyopt;%options for Larmor radius effects and/or LH calc. 
waveparam(:,:,5) = xythetab;%poloidal location of RF beam (relevant for bounce_mode>0 only)    
waveparam(:,:,6) = xyD0;%RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
waveparam(:,:,7) = NaN*ones(nr,nb);%Square N// spectrum: Lower limit
waveparam(:,:,8) = NaN*ones(nr,nb);%Square N// spectrum: Upper limit
waveparam(:,:,9) = xyNpar;%Gaussian N// spectrum: peak n//
waveparam(:,:,10) = xydNpar;%Gaussian N// spectrum: width in n//
waveparam(:,:,11) = xyNperp;%RF wave : n_perp
waveparam(:,:,12) = xyepolp;%RF wave : polarization plus
waveparam(:,:,13) = xyepolm;%RF wave : polarization minus
waveparam(:,:,14) = xyepolz;%RF wave : polarization parallel


