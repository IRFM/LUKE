function [prho,pcurr_hir_ref_fsav,pcurr_sau_ref_fsav,pcurr_hin_ref_fsav,pcurr_i_ref_fsav,L31] = ...
    hsneomodels_dke_jd(equil)
% 
% Calculates the bootstrap current from neoclassical models by Hinton & Hazeltine, Hirshman and Sauter 
% in the limit of large aspect ratio ia << 1.  
% Note: The calculation is based on the model of circular concentric
% flux-surface, with parameters derived from the magnetic geometry.
%
%   INPUTS: 
%
%       - tokname: Name of the tokamak
%
%   OUTPUTS:
%
%       - prho: radial grid [1,np]
%       - pcurr_hir_ref_fsav: Electron bootstrap current from Hirshman model, low collisionality limit (MA/m2) [1,np]
%       - pcurr_sau_ref_fsav: Electron bootstrap current from Sauter model (MA/m2) [1,np]
%       - pcurr_hin_ref_fsav: Electron bootstrap current from Hinton & Hazeltine model (MA/m2) [1,np]
%       - pcurr_i_ref_fsav: Ion contribution to total bootstrap current for Hirschman, Sauter and Hinton & Hazeltine models (MA/m2) [1,np]
%       - pcurr_tag_e_ref_fsav: Electron bootstrap current from Taguchi model (anistropic electron distribution) (MA/m2) [1,np] 
%       - pcurr_tag_i_ref_fsav: Ion bootstrap current from Taguchi model (anistropic electron distribution) (MA/m2) [1,np] 
%
%by Joan Decker <jodecker@mit.edu> and Y. Peysson CEA-DRFC <yves.peysson@cea.fr>
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
%
zZi = equil.zZi;
zmi = equil.zmi;
theta = equil.theta;
pTe = equil.pTe;
pne = equil.pne;
pzTi = equil.pzTi;
pzni = equil.pzni;
R = equil.R;
Z = equil.Z;
ppsi = equil.ppsi;
BR = equil.BR;
BZ = equil.BZ;
BPHI = equil.BPHI;
%
Bt = BPHI(1,1);
%
[npsi,ntheta] = size(R);
np = length(ppsi);
%
% FFT interpolation on R,Z, BR, BZ, BPHI as a function of theta (very precise, works for uniform theta grids only)
%
mfactor = 10;
mtheta = 0:2*pi/((ntheta-1)*mfactor):2*pi*((ntheta-1)*mfactor-1)/((ntheta-1)*mfactor); %super theta grid
%
mR = interpft(R(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mZ = interpft(Z(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mBR = interpft(BR(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mBZ = interpft(BZ(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mBPHI = interpft(BPHI(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
%
mtheta = [mtheta,2*pi]; %2*pi point retrieved (for future interpolation)
mR = [mR,mR(:,1)]; %2*pi point retrieved
mZ = [mZ,mZ(:,1)]; %2*pi point retrieved
mBR = [mBR,mBR(:,1)]; %2*pi point retrieved
mBZ = [mBZ,mBZ(:,1)]; %2*pi point retrieved
mBPHI = [mBPHI,mBPHI(:,1)]; %2*pi point retrieved
%
nmtheta = length(mtheta);
%
Rp = mR(1,1);%Major radius of magnetic Axis
Zp = mZ(1,1);%Elevation of magnetic Axis
%
Rmax = mR(npsi,1);%Major radius where the last close flux-surface crosses the LFS midplane
ap =  Rmax - Rp;%Plasma minor radius on the LFS midplane 
prho = (R(:,1) - Rp)'/ap;
%
psia = ppsi(npsi);%Poloidal flux at the edge
ppsin = ppsi/psia;%Normalized poloidal flux
%
pR = mR;
pZ = mZ;
pBR = mBR;
pBZ = mBZ;
pBphi = mBPHI;
pBT = abs(pBphi);%Toroidal B-field
pBp = sqrt(pBR.^2 + pBZ.^2);%Poloidal B-field
pB = sqrt(pBphi.^2 + pBR.^2 + pBZ.^2);%Total B-field
%
%index 0 refers to the minimum of the magnetic field
%
[pB0,piB0] = min(pB'); %Minimum of B on flux surface
pBmax = max(pB'); %Maximum of B on flux surface
%
pmhu0T2 = 1 - pB0./pBmax; %Pitch-angle (squared) at the trapped-passing boundary
%
piB0 = (piB0 - 1)*npsi + (1:npsi);%Indices in (psi,theta) grid corresponding of B=Bmin
pBT0 = pBT(piB0);%Toroidal field at B=Bmin
pBp0 = pBp(piB0);%Poroidal field at B=Bmin
pR0 = pR(piB0);%Major radius at B=Bmin
%
% note: model with one ion species only. to be completed
%
pTi = pzTi(1,:);
Zi = zZi(1);
%
drho = diff(prho);
%
dTedr = diff(pTe)./drho/ap;
dTedr = [dTedr(1),(dTedr(1:np-2) + dTedr(2:np-1))/2,dTedr(np-1)]; 
dnedr = diff(pne)./drho/ap;
dnedr = [dnedr(1),(dnedr(1:np-2) + dnedr(2:np-1))/2,dnedr(np-1)]; 
dTidr = diff(pTi)./drho/ap;
dTidr = [dTidr(1),(dTidr(1:np-2) + dTidr(2:np-1))/2,dTidr(np-1)]; 
%
dlnTedr = 1./(pTe+eps).*dTedr;
dlnnedr = 1./(pne+eps).*dnedr;
dlnTidr = 1./(pTi+eps).*dTidr;
dlnnidr = dlnnedr;
%
ppe = pne.*pTe;
dlnpedr = dlnTedr + dlnnedr;
dlnpidr = dlnTidr + dlnnidr;
%
pia = prho*ap/Rp;
%
px = (1.46*pia.^(0.5) + 2.40*pia)./(1 - pia).^(1.5);%Small inverse aspect ratio expansion
%[pft,pftu,pftl] = ft_llm_dke_yp(pia,1000);
%px = pft./(1-pft);
%
Dx = 1.414*Zi + Zi^2 + px*(0.754 + 2.657*Zi + 2*Zi^2) + px.^2*(0.348 + 1.243*Zi + Zi^2);
%
L31 = px.*(0.754 + 2.21*Zi + Zi^2 + px*(0.348 + 1.243*Zi + Zi^2))./Dx;
L32 = -px*(0.884 + 2.074*Zi)./Dx;
L34 = L31;
alpha = -1.172./(1 + 0.462*Zi);
%
%From Sauter paper
%
%pft
%pnhu_e_s
%X = pft./(1 + (1-0.1*pft).*sqrt(pnhu_e_s) + 0.5*(1-pft).*pnhu_e_s/Zi);
%L31_s = (1 + 1.4/(Zi+1))*X - 1.9/(Zi+1)*X.^2 + 0.3/(Zi+1)*X.^3 + 0.2/(Zi+1)*X.^4;
%X = pft./(1 + 0.26*(1-pft).*sqrt(pnhu_e_s) + 0.18*(1-0.37*pft).*pnhu_e_s/sqrt(Zi));
%F32_ee_s = (X-X.^4)*(0.05+0.62*Zi)/(Zi+0.44*Zi^2) + (X.^2-X.^4 - 1.2*(X.^3-X.^4))/(0.22*Zi+1) + 1.2/(0.5*Zi+1)*X.^4;
%Y = pft./(1 + (1+0.6*pft).*sqrt(pnhu_e_s) + 0.85*(1-0.37*pft).*pnhu_e_s/(1+Zi));
%F32_ei_s = -(Y-Y.^4)*(0.56+1.93*Zi)/(Zi+0.44*Zi^2) + 4.95*(Y.^2-Y.^4 - 0.55*(Y.^3-Y.^4))/(2.48*Zi+1) - 1.2/(0.5*Zi+1)*Y.^4;
%L32_s = F32_ee_s + F32_ei_s;
%X = pft./(1 + (1-0.1*pft).*sqrt(pnhu_e_s) + 0.5*(1-0.5*pft).*pnhu_e_s/Zi);
%L34_s = (1 + 1.4/(Zi+1))*X - 1.9/(Zi+1)*X.^2 + 0.3/(Zi+1)*X.^3 + 0.2/(Zi+1)*X.^4;
%
% Sauter Correction for L32 in case of large aspect ratio limit (S.Schultz thesis p 92)
%
px_s = 1 - (1 - pia).^2./sqrt(1-pia.^2)./(1 + 1.46*sqrt(pia));
L32_s = -(0.51 + 1.31*Zi)/Zi/(1 + 0.44*Zi)*(px_s - px_s.^4)...
        +(5.95 + 3.57*Zi)/(1 + 2.70*Zi + 0.546*Zi^2)*(px_s.^2 - px_s.^4)...
        -(3.92 + 3.57*Zi)/(1 + 2.70*Zi + 0.546*Zi^2)*(px_s.^3 - px_s.^4);
%
A1 = dlnpedr + pTi./(Zi*pTe).*dlnpidr;
A2 = dlnTedr;
A4 = alpha.*pTi./(Zi*pTe).*dlnTidr;
%
Jbavnorm = -ppe.*pBT0./pBp0.*(L31.*A1 + L32.*A2 + L34.*A4);%WARNING: pBT0./pBp0 not equal to pq./pia when pia becomes large (i.e. > 0.2)
Jbavnorm_s = -ppe.*pBT0./pBp0.*(L31.*A1 + L32_s.*A2 + L34.*A4); 
Jbavnorm_hh = -ppe.*pBT0./pBp0.*(0.69*dlnTedr + 2.44*dlnnedr); 
%
pcurr_hir_ref_fsav = Jbavnorm/Bt*qe*1e-6*1e3; 
pcurr_sau_ref_fsav = Jbavnorm_s/Bt*qe*1e-6*1e3;
pcurr_hin_ref_fsav_e = Jbavnorm_hh/Bt*qe*1e-6*1e3;
%
% Ion Flux to be added in the fluid limit: Hinton & Hazeltine, Hirshman and Sauter relations use the same term
%
A1_i = pTi./(Zi*pTe).*dlnpidr;
Jbavnorm_i = -ppe.*pBT0./pBp0.*(L31.*A1_i + L34.*A4);
pcurr_i_ref_fsav = Jbavnorm_i/Bt*qe*1e-6*1e3; 
%
pcurr_hin_ref_fsav = pcurr_hin_ref_fsav_e + pcurr_i_ref_fsav;
%
%Taguchi's model for anisotropic electron distribution function (Ref: J. Physical Soc. Japan, 65,11 (1996) 3530)
%
pcurr_tag_e_ref_fsav = NaN;
pcurr_tag_i_ref_fsav = NaN;
