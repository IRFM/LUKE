function waveparam = coldlhcd_dke_jd(xyrho,xythetab,xyn,xyopt,xyNparmin,xyNparmax,xyNpar,xydNpar,xyomega_rf,xyPinc,xyfinc,Te_ref,ne_ref,xne_norm,zxni_norm,zZi,zmi,Bt,Rp,ap,bounce_mode);

% 

% Solves the LH Dispersion Relation within the cold plasma model and gives Nperp and the polarization vector

% Also calculates the LH diffusion coefficient and built waveparam

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

xymask_square = isnan(xyNpar);

xyNpar_disp_square = (xyNparmin + xyNparmax)/2;

xyNpar_disp_gauss = xyNpar;

%

xyNpar_disp = zeros(size(xyNpar));% value of Npar used for solving dispersion relation

xyNpar_disp(xymask_square) = xyNpar_disp_square(xymask_square);

xyNpar_disp(~xymask_square) = xyNpar_disp_gauss(~xymask_square);

%

for ir = 1:nr

    for ib = 1:nb

        Npar = xyNpar_disp(ir,ib);

        omega_rf = xyomega_rf(ir,ib);

        ne = xne(ir);

        zni = zxni(:,ir);

        Bfield = xyB(ir,ib);

        %

        [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_ppk,em_ppk] = colddisp_dke_jd(Npar,omega_rf,ne,zni,zZi,zmi,Bfield);

        %

        NperpFW = Nperpm; 

        NperpSW = Nperpp; 

        %    

        xyNperpFW(ir,ib) = NperpFW;

        xyNperpSW(ir,ib) = NperpSW;

        %

        xyKxyz(1:3,1:3,ir,ib) = Kxyz;

        %

        eFW_xyz = em_xyz; 

        eSW_xyz = ep_xyz; 

        eFW_pmz = em_pmz; 

        eSW_pmz = ep_pmz; 

        eFW_ppk = em_ppk; 

        eSW_ppk = ep_ppk; 

        %

        xy3eFW_xyz(1:3,ir,ib) = eFW_xyz;

        xy3eFW_pmz(1:3,ir,ib) = eFW_pmz;

        xy3eFW_ppk(1:3,ir,ib) = eFW_ppk;

        xy3eSW_xyz(1:3,ir,ib) = eSW_xyz;

        xy3eSW_pmz(1:3,ir,ib) = eSW_pmz;

        xy3eSW_ppk(1:3,ir,ib) = eSW_ppk;

    end

end

%

xyNperpLH = xyNperpSW;

%

xy3eLH_xyz = xy3eSW_xyz;

xy3eLH_pmz = xy3eSW_pmz;

xy3eLH_ppk = xy3eSW_ppk;

%

xyepolLHp = shiftdim(xy3eLH_pmz(1,:,:),1); 

xyepolLHm = shiftdim(xy3eLH_pmz(2,:,:),1); 

xyepolLHz = shiftdim(xy3eLH_pmz(3,:,:),1);

xyepolLHk = shiftdim(xy3eLH_ppk(3,:,:),1);

%

xyKperp = squeeze(xyKxyz(1,1,:,:));

%

% electron frequencies

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

xyphibdn = -xyKperp.*xyNperpLH./(xyNpar_disp.^2 + xyNperpLH.^2)./xyfinc;

%

xyD0 = xyPinc.*xyrpsi./(me*wpe_ref^2*lnc_ref*xyomega_rf.*abs(xyphibdn).*xyrho*ap*Rp);

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









