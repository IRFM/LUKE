function [Zbremchord,equilHXR] = bremchord_dke_yp(dkeparam,display,equil,radialDKE,Zcurr,hxr,hxrparam);
%
% This function calculates chord positions for bremsstrahlung tomography in a torus along unit vector g from DKE grid structure
%
% INPUTS
%
%       - dkeparam: DKE data structure
%       - equil: Magnetic equilibrium structure from numerical magnetic equilibrium code (no interpolation)
%       - radialDKE: Radial grid structure used by DKE
%       - dke_out: DKE data output
%       - hxr: Bremsstrahlung structure
%       - hxrparam : Bremsstrahlung calculation and display parameter structure
%
% OUTPUTS
%       
%       - Zbremchord: data structure for the bremsstrahlung diagnostic (for display principaly)
%          * Zbremchord.vschords: chords parameter [16,n,nchords]
%          * Zbremchord.psi_hxr: magnetic flux surface coordinate where the distribution function is calculated for the bremsstrahlung emission [npsi,ntheta]
%          * Zbremchord.theta_hxr: poloidal angle values where the distribution function is calculated for the bremsstrahlung emission [npsi,ntheta]
%          * Zbremchord.PSI_hxr: B/Bmin where the distribution function is calculated for the bremsstrahlung emission [npsi,ntheta]
%          * Zbremchord.mask_hxr: locations where the distribution function is calculated for the bremsstrahlung emission [npsi,ntheta]
%       - equilHXR: magnetic equilibrium structure optimized for HR
%       calculations
%
% by Y. Peysson (CEA-DRFC) <yves.peysson@cea.fr> and J. Decker (CEA-DRFC) <joan.decker@cea.fr> 
%
%WARNING: the definitions used in the DKE code, and here crucial for HXR calculations are the following
%         1) the toroidal frame (R,Z,phi) is direct (phi is positive clockwise when the tokamak is seen from the top)
%         2) the poloidal frame (r,theta,phi) is direct
%         3) (psi,s,phi) must be direct : if Ip.phi > 0, then B.theta > 0 and psi > 0, and s.theta > 0 (s as the same direction of theta)
%         4) the sign of psi is the sign of Ip.phi
% With the definitions above, if Ip is positive, psi is turned outward, Btheta is counterclockwise poloidally, and s too. The Ampere theorem is OK !
% The HXR diagnostic arrangement is taking this frame of reference.
%
if nargin < 5,
   error('Not enough arguments in bremchord_dke_yp')
end
%	
mfactor = hxrparam.mfactor;
method = hxrparam.method;
ns = hxrparam.ns;
%
xpsin = radialDKE.xpsin_f_dke;
xpsin_S = radialDKE.xpsin_S_dke;
%
[equilHXR] = equilibrium_jd(equil,radialDKE,display,'spline',mfactor);%Magnetic equilibrium for HXR at points of the distribution function
%
%   This function interpolates the equilibrium data on the radial grid.
%
Rp = equilHXR.Rp;%Plasma major radius (m)
Zp = equilHXR.Zp;%Plasma vertical position (m)
ap = equilHXR.ap;%Plasma minor radius (m)
theta = equilHXR.mtheta;
ppsin = equilHXR.xpsin;
ptR = equilHXR.Xx + Rp;
ptZ = equilHXR.Xy + Zp;
ptBR = equilHXR.XBx;
ptBZ = equilHXR.XBy;
ptBphi = equilHXR.XBphi;
ptBT = ptBphi;
ptBp = sqrt(ptBR.^2 + ptBZ.^2);
ptB = sqrt(ptBR.^2 + ptBZ.^2 + ptBphi.^2);
ptB0 = ptB(:,1);
ptR0 = equilHXR.Xx(:,1) + Rp;
ptBT0 = ptBT(:,1);
ptBp0 = ptBp(:,1);
ptrho = equilHXR.xrho;
%
if length(ppsin)==1,error('Bremsstrahlung calculations cannot be performed when DKE results are obtained for a single radial position !');end
%
ns = abs(ns);%Force ns to be always positive
nchords = length(hxr.alpha_hxr);%chord number
%
xq = ap*qfactors_dke_yp(dkeparam.equil_mode,Rp,ap,ptR-Rp,ptZ-Zp,ptBR,ptBZ,ptBphi,ptR0-Rp,ptB0,ptBT0,ptBp0)/Rp;%Safety factor
%
r_lcs = sqrt((ptR(length(ppsin),:) - Rp).^2 + (ptZ(length(ppsin),:) - Zp).^2);%Minor radius of the last closed magnetic surface
%
smax = 3*(Rp + ap);%maximum chord length = R_hxr+a_hxr
%s = linspace(-smax,+smax,ns)'*ones(1,nchords);%for nchords (s negative by definition)
s = linspace(-smax,0,ns)'*ones(1,nchords);%for nchords (s negative by definition)
% Poloidal plot
for ir = 1:length(xpsin_S)
    RR_pol(ir,:) = interp1(ppsin,ptR,xpsin_S(ir),method);
    ZZ_pol(ir,:) = interp1(ppsin,ptZ,xpsin_S(ir),method);
	BR_pol(ir,:) = interp1(ppsin,ptBR,xpsin_S(ir),method);
	BZ_pol(ir,:) = interp1(ppsin,ptBZ,xpsin_S(ir),method);
end
%
HHR_pol = linspace(Rp-1.1*r_lcs(round(length(theta)/2)),Rp+1.1*r_lcs(1),1000);
HHZ_pol = Zp + zeros(1,1000);
VVR_pol = Rp + zeros(1,1000);
VVZ_pol = linspace(-1.1*r_lcs(round(length(theta)/4)),1.1*r_lcs(round(3*length(theta)/4)),1000);
% Toroidal plot
XX_tor_min = (Rp-r_lcs(round(length(theta)/2)))*cos(linspace(0,2*pi,1000));
YY_tor_min = (Rp-r_lcs(round(length(theta)/2)))*sin(linspace(0,2*pi,1000));
XX_tor = Rp*cos(linspace(0,2*pi,1000));
YY_tor = Rp*sin(linspace(0,2*pi,1000));
XX_tor_max = (Rp+r_lcs(1))*cos(linspace(0,2*pi,1000));
YY_tor_max = (Rp+r_lcs(1))*sin(linspace(0,2*pi,1000));
VVX = zeros(1,1000);
VVY = linspace(1.1*min(YY_tor_max),1.1*max(YY_tor_max),1000);
HHX = linspace(1.1*min(XX_tor_max),1.1*max(XX_tor_max),1000);
HHY = zeros(1,1000);
%
phi_mfl = linspace(0,2*pi*xq(end),1000);
phi_mfl0 = 0;
theta_mfl_lcs = (phi_mfl - phi_mfl0)/xq(end);%Heliticity relation given by the safety factor
r_mfl_lcs = interp1(theta,r_lcs,theta_mfl_lcs,method);
%
BR_mfl_lcs = interp1(theta,ptBR(end,:),theta_mfl_lcs,method);
BZ_mfl_lcs = interp1(theta,ptBZ(end,:),theta_mfl_lcs,method);
Bphi_mfl_lcs = interp1(theta,ptBphi(end,:),theta_mfl_lcs,method);
%
ptBtheta = -ptBR.*sin(ones(size(ppsin(:)))*theta) + ptBZ.*cos(ones(size(ppsin(:)))*theta);
Ipdir = sign(ptBtheta);%Btheta < 0 (clockwise poloidal) then Ip is counterclockwise toroidally from the top view (positive trigonometric). May change as function of plasma minor radius (negative shear case)
Ipdir_mfl_lcs = sign(interp1(theta,Ipdir(end,:),theta_mfl_lcs,method));%Sign of Ip on the last closed magnetic surface
Ipdkedir_mfl_lcs = -sign(Zcurr.x_tot_fsav(end))*ones(size(Ipdir_mfl_lcs));%Sign of the current calculated by DKE (- because of the elctron charge). If Ipdkedir_mfl_lcs and Ipdir_mfl_lcs, have the same sign, it is cocurrent, otherwise it is countercurrent
Ipdir_psia = sign(equil.psi_apRp(end));
%
BX_mfl_lcs = BR_mfl_lcs.*cos(phi_mfl) - Bphi_mfl_lcs.*sin(phi_mfl);
BY_mfl_lcs = BR_mfl_lcs.*sin(phi_mfl) + Bphi_mfl_lcs.*cos(phi_mfl);
%
X_mfl_lcs = (Rp + r_mfl_lcs.*cos(theta_mfl_lcs)).*cos(phi_mfl); 
Y_mfl_lcs = (Rp + r_mfl_lcs.*cos(theta_mfl_lcs)).*sin(phi_mfl); 
Z_mfl_lcs = Zp + r_mfl_lcs.*sin(theta_mfl_lcs);
%
alpha_hxr = ones(ns,1)*hxr.alpha_hxr;%Defined in the indirect frame only (see the documentation)
beta_hxr = ones(ns,1)*hxr.beta_hxr;
R_hxr = ones(ns,1)*hxr.R_hxr;
Z_hxr = ones(ns,1)*hxr.Z_hxr;
%
if alpha_hxr <= -pi | alpha_hxr > pi
	 error('need -pi < alpha_hxr <= pi')
end
%
if beta_hxr < 0 | beta_hxr > pi
    error('need 0 <= beta_hxr <= pi')
end    
%
sZ = s.*cos(beta_hxr);
sh = s.*sin(beta_hxr);
%
sR = sqrt(R_hxr.^2 + sh.^2 + 2*R_hxr.*sh.*cos(alpha_hxr));
sR = sR + eps*(sR == Rp);%to avoid singularities
sZ = Z_hxr + sZ;
%
sZ = sZ + eps*(sZ == Zp);%to avoid singularities
sphi = rem(2*pi - acos((sR.^2 + R_hxr.^2 - sh.^2)./(2*sR.*R_hxr)).*sign(alpha_hxr),2*pi);%Toroidal angle
spsi = griddata(ptR,ptZ,ppsin(:)*ones(1,length(theta)),sR,sZ);%Flux surface value
%
gX_hxr = sin(beta_hxr).*cos(alpha_hxr);%Chord vector
gY_hxr = sin(beta_hxr).*sin(alpha_hxr);%Chord vector
gZ_hxr = cos(beta_hxr);%Chord vector
%
sr = sqrt((sR - Rp).^2 + (sZ - Zp).^2);%Minor radius along the chords
st = atan((sZ - Zp)./(sR - Rp)) + pi - pi*(sR > Rp).*sign(sZ - Zp);%poloidal angle [0,2*pi]
%
ir_spsi = spsi*0;
for i = length(xpsin_S)-1:-1:1,
	ir_spsi = ir_spsi + (spsi > xpsin_S(i));	
end
%
it_st = st*0;
for i = length(theta)-1:-1:1,
	it_st = it_st + (st > theta(i));	
end
%
mask_hxr = zeros(length(xpsin_S)-1,length(theta)-1);%Location where the distribution function is calculated
for i = 1:length(xpsin_S)-1,
	for j= 1:length(theta)-1,
		if isempty(find(it_st(:,1:nchords) == j & ir_spsi(:,1:nchords) == i)) ~= 1,
			mask_hxr(i,j) = 1;
		end
	end
end
%
theta_hxr = ones(length(xpsin),1)*(theta(1:end-1) + diff(theta)/2);
psin_hxr = xpsin'*ones(1,length(theta)-1);
B0_hxr = interp1(ppsin,ptB0,xpsin,method);%Bmin
PSI_hxr = griddata(ppsin(:)*ones(1,length(theta)),ones(length(ppsin),1)*theta,sqrt(ptBR.^2 + ptBZ.^2 + ptBphi.^2),psin_hxr,theta_hxr)./(B0_hxr'*ones(1,length(theta)-1));%B/Bmin
%
sr_lcs = interp1(theta,r_lcs,st,method);
mask = ~isnan(spsi);
for ic = 1:nchords,
   imask = find(mask(1:end-1,ic)-mask(2:end,ic) == 1);
   if length(imask) == 2,%reject the case when chord go through the plasma twice
   	mask(1:imask(1),ic) = logical(0);
   end
end	
%
s(~mask) = NaN;
sR(~mask) = NaN;
sZ(~mask) = NaN; 
sphi(~mask) = NaN; 
sr(~mask) = NaN;
st(~mask) = NaN;
spsi(~mask) = NaN;
ir_spsi(~mask) = NaN;
it_st(~mask) = NaN;
sksid(~mask) = NaN;
gX_hxr(~mask) = NaN;
gY_hxr(~mask) = NaN;
gZ_hxr(~mask) = NaN;
%
sBR = griddata(ptR,ptZ,ptBR,sR,sZ);
sBZ = griddata(ptR,ptZ,ptBZ,sR,sZ);
sBphi = griddata(ptR,ptZ,ptBphi,sR,sZ);
sB = sqrt(sBR.^2 + sBZ.^2 + sBphi.^2);
sksid = ((sBR.*cos(sphi) - sBphi.*sin(sphi)).*gX_hxr + (-sBR.*sin(sphi) + sBphi.*cos(sphi)).*gY_hxr + sBZ.*gZ_hxr)./sB;%cosine between magnetic field line and chord direction (towards the detector)
%
vschords = zeros(16,ns,nchords);
vschords(1,:,:) = s;
vschords(2,:,:) = sR;
vschords(3,:,:) = sZ;
vschords(4,:,:) = sphi;
vschords(5,:,:) = sr;
vschords(6,:,:) = st;
vschords(7,:,:) = spsi;
vschords(8,:,:) = ir_spsi;
vschords(9,:,:) = it_st;
vschords(10,:,:) = sksid;
vschords(11,:,:) = sBR;
vschords(12,:,:) = sBZ;
vschords(13,:,:) = sBphi;
vschords(14,:,:) = gX_hxr;
vschords(15,:,:) = gY_hxr;
vschords(16,:,:) = gZ_hxr;
%
% Structure for display
%	 
Zbremchord.ptrho = ptrho;
Zbremchord.xq = xq;
Zbremchord.sR = sR;
Zbremchord.sZ = sZ;
Zbremchord.RR_pol = RR_pol;
Zbremchord.ZZ_pol = ZZ_pol;
Zbremchord.HHR_pol = HHR_pol;
Zbremchord.HHZ_pol = HHZ_pol;
Zbremchord.VVR_pol = VVR_pol;
Zbremchord.VVZ_pol = VVZ_pol;
Zbremchord.ptR = ptR;
Zbremchord.ptZ = ptZ;
Zbremchord.BR_pol = BR_pol;
Zbremchord.BZ_pol = BZ_pol;
Zbremchord.X_mfl_lcs = X_mfl_lcs;
Zbremchord.Y_mfl_lcs = Y_mfl_lcs;
Zbremchord.Z_mfl_lcs = Z_mfl_lcs;
Zbremchord.BX_mfl_lcs = BX_mfl_lcs;
Zbremchord.BY_mfl_lcs = BY_mfl_lcs;
Zbremchord.Ipdir_mfl_lcs = Ipdir_mfl_lcs;
Zbremchord.Ipdkedir_mfl_lcs = Ipdkedir_mfl_lcs;
Zbremchord.sR = sR;
Zbremchord.sphi = sphi;
Zbremchord.XX_tor_min = XX_tor_min;
Zbremchord.YY_tor_min = YY_tor_min;
Zbremchord.XX_tor = XX_tor;
Zbremchord.YY_tor = YY_tor;
Zbremchord.XX_tor_max = XX_tor_max;
Zbremchord.YY_tor_max = YY_tor_max;
Zbremchord.VVX = VVX;
Zbremchord.VVY = VVY;
Zbremchord.HHX = HHX;
Zbremchord.HHY = HHY;
Zbremchord.xpsin_S = xpsin_S;
Zbremchord.vschords = vschords;
Zbremchord.psin_hxr = psin_hxr;
Zbremchord.theta_hxr = theta_hxr;
Zbremchord.PSI_hxr = PSI_hxr;
Zbremchord.mask_hxr = mask_hxr;
%
