function waveparam = warmeccd_dke_jd(tokamak,xyrho,xythetab,xyn,xyopt,xyNpar,xydNpar,xybwidth,xypol,xyomega_rf,xyPinc,xyfinc,Te_ref,ne_ref,xne_norm,zxni_norm,zZi,zmi,xyB0,Rp,ap,bounce_mode);
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
nroots = 2;
kflag = 1;
nn_nr = 20;
knr = 1;
nrt_nr = 2;
nrt_fr = 1;
%
for ib = 1:nb
    i_0 = find(xyrho(:,ib) == max(xyrho(:,ib)));
    rho_0 = xyrho(i_0,ib);
    thetab_0 = xythetab(i_0,ib);
    xyNpar_0 = xyNpar(i_0,ib);
    [NperpX_cold,NperpO_cold] = ...
        colddisp_OX_jd(tokamak,rho_0*cos(thetab_0),rho_0*sin(thetab_0),xyomega_rf(1,ib),xyNpar_0);
    GNperp = [NperpX_cold,NperpO_cold];
    [xrho_out,xMNperp,xM3eps_pmz] = ...
        disp_jd(tokamak,xyrho(:,ib),rho_0,xythetab(:,ib),xyNpar(:,ib),xyomega_rf(1,ib),knr,nrt_nr,nrt_fr,kflag,GNperp,nn_nr);
    aX = - angle(xM3eps_pmz(nr,2,2));
    aO = - angle(xM3eps_pmz(nr,1,3));
    aM = repmat([aO,aX],[nr,1,3]);
    xM3eps_pmz = xM3eps_pmz.*exp(i*aM);
    xyNperp(:,ib) = xMNperp(:,1).*~xypol(:,ib) + xMNperp(:,2).*xypol(:,ib);  
    xyepolp(:,ib) = xM3eps_pmz(:,1,1).*~xypol(:,ib) + xM3eps_pmz(:,2,1).*xypol(:,ib);  
    xyepolm(:,ib) = xM3eps_pmz(:,1,2).*~xypol(:,ib) + xM3eps_pmz(:,2,2).*xypol(:,ib);  
    xyepolz(:,ib) = xM3eps_pmz(:,1,3).*~xypol(:,ib) + xM3eps_pmz(:,2,3).*xypol(:,ib);  
end
%
xyepolk = (real(xyNperp).*(xyepolp + xyepolm)/sqrt(2) + xyNpar.*xyepolz)./sqrt(real(xyNperp).^2 + xyNpar.^2);
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
xydNpar_bis = real(xyNperp)./sqrt(xyNpar.^2 + real(xyNperp).^2)*clum./(xyomega_rf.*xybwidth);
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


