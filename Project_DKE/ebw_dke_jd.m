function waveparam = ebw_dke_jd(tokamak,xyrho,xythetab,xyn,xyopt,xyNpar,xydNpar,xybwidth,xypol,xyomega_rf,xyPinc,xyfinc,Te_ref,ne_ref,xne_norm,zxni_norm,zZi,zmi,xyB0,Rp,ap,bounce_mode);
%
% Calculates the normalized diffusion coefficient, polarization elements, and Nperp for EBW 
%
% by J. Decker 09/23/03
%
% Updated 09/23/03
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
for ib = 1:nb
    somega = num2str(round(xyomega_rf(1,ib)/(2*pi*1e9)*10));
    if length(somega) == 2
        somega = ['0',somega];
    end
    sNpar = num2str(round(xyNpar(1,ib)*100));
    if length(sNpar) == 1
        sNpar = ['00',sNpar];
    elseif length(sNpar) == 2
        sNpar = ['0',sNpar];
    end
    loadstr = ['DISP_',tokamak,'_',somega,'_',sNpar,'.mat'];
    %
    if min(xyrho(:,ib) == repmat(xyrho(1,ib),[nr,1]))
        rho_0 = xyrho(1,ib);
    else
        rho_0 = NaN;
    end
    srho_0 = num2str(round(rho_0*1000));
    if length(srho_0) == 1
        srho_0 = ['00',srho_0];
    elseif length(srho_0) == 2
        srho_0 = ['0',srho_0];
    end
    loadseekstr = ['SEEK_',tokamak,'_',sNpar,'_',srho_0,'.mat'];
    loadintstr = ['INT_',tokamak,'_',sNpar,'.mat'];
    %
    if exist(loadintstr) == 2
        eval(['load ',loadintstr,' xrho_EBW xNperp_EBW x3eps_pmz_EBW xPflow_EBW xPabs_EBW']);
        xMNperp = interp1(xrho_EBW,xNperp_EBW,xyrho(:,ib));
        xM3eps_pmz = interp1(xrho_EBW,x3eps_pmz_EBW',xyrho(:,ib));
        xMPflow = interp1(xrho_EBW,xPflow_EBW,xyrho(:,ib));
        xMPabs = interp1(xrho_EBW,xPabs_EBW,xyrho(:,ib));       
    elseif exist(loadstr) == 2
        eval(['load ',loadstr,' xrho_EBW xNperp_EBW x3eps_pmz_EBW xPflow_EBW xPabs_EBW']);
        xMNperp = interp1(xrho_EBW,xNperp_EBW,xyrho(:,ib));
        xM3eps_pmz = interp1(xrho_EBW,x3eps_pmz_EBW',xyrho(:,ib));
        xMPflow = interp1(xrho_EBW,xPflow_EBW,xyrho(:,ib));
        xMPabs = interp1(xrho_EBW,xPabs_EBW,xyrho(:,ib));       
    elseif exist(loadseekstr) == 2
        eval(['load ',loadseekstr,' xrho_EBW xNperp_EBW x3eps_pmz_EBW xPflow_EBW xPabs_EBW omega']);
        xMNperp = interp1(xrho_EBW,xNperp_EBW,xyrho(:,ib));
        xM3eps_pmz = interp1(xrho_EBW,x3eps_pmz_EBW',xyrho(:,ib));
        xMPflow = interp1(xrho_EBW,xPflow_EBW,xyrho(:,ib));
        xMPabs = interp1(xrho_EBW,xPabs_EBW,xyrho(:,ib));       
    else
        prec = 5e-4;
        xrho = 0:prec:1;
        nr = length(xrho);
        if length(xyrho(:,ib)) > 1
            xtheta = interp1(xyrho(:,ib),xythetab(:,ib),xrho);
            xNpar = interp1(xyrho(:,ib),xyNpar(:,ib),xrho);
        else
            xtheta = repmat(xythetab(:,ib),[1,nr]);
            xNpar = repmat(xyNpar(:,ib),[1,nr]);
        end    
%
        [xrho_out_SX,xMNperp_SX,xM3eps_pmz_SX,...
                xrho_out_EBB,xMNperp_EBB,xM3eps_pmz_EBB,...
                xrho_out_EBW_ft,xMNperp_EBW_ft,xM3eps_pmz_EBW_ft,...
                xrho_out_EBW_ht,xMNperp_EBW_ht,xM3eps_pmz_EBW_ht,xMPflow_EBW_ht,xMPabs_EBW_at] = ...
            disp_ebw_jd(tokamak,xrho,xtheta,xNpar,xyomega_rf(1,ib));
        [xMNperp,xM3eps_pmz] = disp_ebw_jd(tokamak,xyrho(:,ib),xythetab(:,ib),xyNpar(:,ib),xyomega_rf(1,ib),prec);
        xMNperp = interp1(xrho_out_EBW_ht,xMNperp_EBW_ht,xyrho(:,ib));
        xM3eps_pmz = interp1(xrho_out_EBW_ht,xM3eps_pmz_EBW_ht,xyrho(:,ib));
        xMPflow =  interp1(xrho_out_EBW_ht,xMPflow_EBW_ht,xyrho(:,ib));
        xMPabs =  interp1(xrho_out_EBW_ht,xMPabs_EBW_at,xyrho(:,ib));
    end
    xyNperp(:,ib) = xMNperp;
    if length(xyrho(:,ib)) == 1
        xyepolp(:,ib) = xM3eps_pmz(:,1);  
        xyepolm(:,ib) = xM3eps_pmz(:,2);  
        xyepolz(:,ib) = xM3eps_pmz(:,3);  
    else        
        xyepolp(:,ib) = xM3eps_pmz(:,1,1);  
        xyepolm(:,ib) = xM3eps_pmz(:,1,2);  
        xyepolz(:,ib) = xM3eps_pmz(:,1,3); 
    end
    xyPflow(:,ib) = xMPflow;
    xyPabs(:,ib) = xMPabs;
end
%
%xyepolk = (real(xyNperp).*(xyepolp + xyepolm)/sqrt(2) + xyNpar.*xyepolz)./sqrt(real(xyNperp).^2 + xyNpar.^2);
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
%xyphibdn = -xyKperp.*xyNperpLH./(xyNpar_disp.^2 + xyNperpLH.^2)./xyfinc;
%xyphibdn = (1 - abs(xyepolk).^2).*xyNperp./xyfinc;
xyphibdn = 2*xyPflow/e0/clum./xyfinc;
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


