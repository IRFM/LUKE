function waveparam = coldlhcd_dke_jd(xyrho,xythetab,xyn,xyopt,xyNparmin,xyNparmax,xyNpar,xydNpar,xyomega_rf,xyPinc,xyfinc,Te_ref,ne_ref,xne_norm,zxni_norm,zZi,zmi,Bt,Rp,ap,bounce_mode);

%

% Calculates the LH diffusion coefficient and built waveparam in an ideal

% LHCD case (Electrostatic Approximation)

%

% by J. Decker 08/21/03

%

% Last update: j.d. 09/12/03

%

qe = 1.6022e-19;%Electron charge (C)

me = 9.1094e-31;%Electron rest mass (Kg)

mp = 1.6726e-27;%Proton rest mass (Kg)

e0 = 8.8542e-12;%Free space permeability (F/m)

clum = 299792458;%Speed of light (m/s)

%

xne = ne_ref*xne_norm;

zxni = ne_ref*zxni_norm;

%

[nr,nb] = size(xyrho);

%

xyia = xyrho*ap/Rp;

xyB = Bt./(1 + xyia.*cos(xythetab));

xywce = qe*xyB/me;

%

xwpe = sqrt(xne*qe^2/e0/me);

zxZi = repmat(zZi,[1,nr]);

zxmi = repmat(zmi,[1,nr]);

zxwpi = sqrt(zxni.*zxZi.^2*qe^2/e0/mp./zxmi);

xywpe = repmat(xwpe,[1,nb]);

zxywpi = repmat(zxwpi,[1,1,nb]);

%

xymask_square = isnan(xyNpar);

xyNpar_disp_square = (xyNparmin + xyNparmax)/2;

xyNpar_disp_gauss = xyNpar;

%

xyNpar_disp = zeros(size(xyNpar));% value of Npar used for solving dispersion relation

xyNpar_disp(xymask_square) = xyNpar_disp_square(xymask_square);

xyNpar_disp(~xymask_square) = xyNpar_disp_gauss(~xymask_square);

%

%

% frequencies

%

wpe_ref = sqrt(ne_ref*qe^2/e0/me);

xywce0 = qe*Bt./(1 + xyia)/me;

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

xyKperp = 1 + xywpe.^2./xywce.^2 - squeeze(sum(zxywpi.^2))./xyomega_rf.^2;

xyKpar = - xywpe.^2./xyomega_rf.^2; 

xyNperpLH = sqrt(-xyKpar./xyKperp).*xyNpar_disp;

%

xyphibdn = -xyKperp.*xyNperpLH./(xyNpar_disp.^2 + xyNperpLH.^2)./xyfinc;

%

xyD0 = xyPinc.*xyrpsi./(me*wpe_ref^2*lnc_ref*xyomega_rf.*abs(xyphibdn).*xyrho*ap*Rp);

%

% ideal polarizations

%

xyepolLHp = ones(nr,nb)/sqrt(2);

xyepolLHm = ones(nr,nb)/sqrt(2);

xyepolLHz = xyNpar_disp./xyNperpLH;

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

waveparam(:,:,7) = xyNparmin;%Square N// spectrum: Lower limit

waveparam(:,:,8) = xyNparmax;%Square N// spectrum: Upper limit

waveparam(:,:,9) = xyNpar;%Gaussian N// spectrum: peak n//

waveparam(:,:,10) = xydNpar;%Gaussian N// spectrum: width in n//

waveparam(:,:,11) = xyNperpLH;%RF wave : n_perp

waveparam(:,:,12) = xyepolLHp;%RF wave : polarization plus

waveparam(:,:,13) = xyepolLHm;%RF wave : polarization minus

waveparam(:,:,14) = xyepolLHz;%RF wave : polarization parallel









