function [vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr] = bremchord_dke_yp(equil,IPBT,hxr,xpsin,xpsin_S,mfactor,method,display,ns,mtheta);
%
% This function calculates chord positions fro bremsstrahlung tomography in a torus along unit vector g. 
%
% INPUTS
%
%       - equil: Magnetic equilibrium structure
%       - IPBT: Cosine between the plasma current and the toroidal B-field directions (+1: Ip same direction as BT, -1 opposite direction as BT) (see below definitions)
%       - hxr: Bremsstrahlung structure 
%       - xpsin: poloidal flux surfaces for f used by DKE code [1,npsi]
%       - xpsin_S: poloidal flux surfaces used for S by DKE code [1,npsi+1]
%       - mfactor: amplification number of poloidal angles compared to the value of the equilbrium code (>1) [1,1]
%         (default = 1)
%       - method: interpolation method
%         (default = 'spline')
%       - display: display chords [1,1]
%         (default = 2)
%       - ns: number of points on the chords [1,1]
%         (default = 3000)
%
% OUTPUTS
%       
%       - vschords: chords parameter [16,n,nchords]
%       - psi_hxr: magnetic flux surface coordinate where the distribution function is calculated for the bremsstrahlung emission [npsi,ntheta]
%       - theta_hxr: poloidal angle values where the distribution function is calculated for the bremsstrahlung emission [npsi,ntheta]
%       - PSI_hxr: B/Bmin where the distribution function is calculated for the bremsstrahlung emission [npsi,ntheta]
%       - mask_hxr: locations where the distribution function is calculated for the bremsstrahlung emission [npsi,ntheta]
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
%WARNING: the definitions used in the DKE code, and here crucial for HXR calculations are the following
%         1) the frame (psi,s,phi) is direct
%         2) BT.phi > 0 
%         3) Bp.s > 0
% The consequence is that when BT.Ip > 0, (Ip is the plsma current vector) psi increases from the plasma center to the edge (the vector psi goes out of the plasma)
% In most machines, BT is clockwise when the machine is viewed from the top (Z axis is positive towards the top) 
% With the definitions above, if Ip is positive, psi is turned outward, Bp is counterclockwise poloidally, and s too. The Ampère theorem is OK !
% The HXR diagnostic arrangement is taking this frame of reference. Check the figures. Take care if BT is counterclockwise...
%
if nargin < 5,
    error('Not enough arguments in bremchord_dke_yp')
elseif nargin == 5,
   	  mfactor = 1;
	  method = 'spline'; 	
      display = 2;
      ns = 3000;
elseif nargin == 6,
		method = 'spline'; 	
		display = 2;
		ns = 3000;
elseif nargin == 7,
		display = 2;
		ns = 3000;
elseif nargin == 8,
		ns = 3000;
end
%
ns = abs(ns);%Force ns to be always positive
nchords = length(hxr.alpha_hxr);%chord number
%
[theta,ppsin,psia,ptR,ptZ,ptBR,ptBZ,ptBphi,ptB0,ptR0,ptBT0,ptBp0,ptrho] = equilibrium_jd(equil,NaN,NaN,0,method,mfactor);
%
ptBR = -sign(IPBT)*ptBR;%Ip is positive, psi is turned outward, Bp is counterclockwise -> negative sign
ptBZ = -sign(IPBT)*ptBZ;%Ip is positive, psi is turned outward, Bp is counterclockwise -> negative sign
%
Rp = ptR(1,1);%Plasma major radius (m)
Zp = ptZ(1,1);%Plasma vertical position (m)
xq = qfactors_dke_yp(Rp,Zp,ptR,ptZ,ptBR,ptBZ,ptBphi);%Safety factor
r_lcs = sqrt((ptR(length(ppsin),:) - Rp).^2 + (ptZ(length(ppsin),:) - Zp).^2);%Minor radius of the last closed magnetic surface
ap = max([r_lcs(1),max(r_lcs)]);%Max of low field side  minor radius and maximum minor radius
%
smax = 3*(Rp + ap);%maximum chord length = R_hxr+a_hxr
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
Ipdir = sign(ptBtheta);%Btheta > 0 (clockwise) then Ip is counterclickwise from the top view (Bphi > 0, clockwise from top view). May change as function of plasma minor radius (negative shear case)
Ipdir_mfl_lcs = sign(interp1(theta,Ipdir(end,:),theta_mfl_lcs,method));%Sign of Ip on the last closed magnetic surface
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
sBR=griddata(ptR,ptZ,ptBR,sR,sZ);
sBZ=griddata(ptR,ptZ,ptBZ,sR,sZ);
sBphi=griddata(ptR,ptZ,ptBphi,sR,sZ);
sIpdir=sign(griddata(ptR,ptZ,Ipdir,sR,sZ));%sign function to enforce +/- 1. Only the sign is important here
sB = sqrt(sBR.^2 + sBZ.^2 + sBphi.^2);
sksid = -sIpdir.*((sBR.*cos(sphi) - sBphi.*sin(sphi)).*gX_hxr + (-sBR.*sin(sphi) + sBphi.*cos(sphi)).*gY_hxr + sBZ.*gZ_hxr)./sB;%cosine between magnetic field line and chord direction (towards the detector)
%
if display >= 1
    figure('Name','Safety factor'),
    [ax] = graph1D_jd(ptrho,xq,0,0,'Normalized radius {\rho}','q','Safety factor',NaN,'','','-','none','b',2);pause(0.5);%Safety factor profile
%
   figure('Name','Bremsstrahlung tomography (Poloidal view)'),
	[ax] = graph1D_jd(sR,sZ,0,0,'','','',NaN,'','','-','none','b',2);pause(0.5);%Poloidal plot
   hold on
   for ir = 1:length(xpsin_S),
			graph1D_jd(RR_pol(ir,:),ZZ_pol(ir,:),0,0,'','','',NaN,'','','-','non','r',1);
	     end
   axis('equal');
	graph1D_jd(HHR_pol,HHZ_pol,0,0,'','','',NaN,'','','-.','non','r',1);
	graph1D_jd(VVR_pol,VVZ_pol,0,0,'','','',NaN,'','','-.','non','r',1);
	graph1D_jd(ptR,ptZ,0,0,'X=R (m)','Z (m)','Bremsstrahlung tomography (Poloidal view)',NaN,'','','-','non','r',1);
   hold off
%
	figure('Name','Poloidal field'),
	quiver(RR_pol,ZZ_pol,BR_pol,BZ_pol);
	axis('equal');
	hold on
	graph1D_jd(ptR,ptZ,0,0,'','','',NaN,'','','-','non','c',1);
	graph1D_jd(HHR_pol,HHZ_pol,0,0,'','','',NaN,'','','-.','non','r',1);
	graph1D_jd(VVR_pol,VVZ_pol,0,0,'X=R (m)','Z (m)','Poloidal field (T)',NaN,'','','-.','non','r',1);
	hold off  	
%
	figure('Name','Bremsstrahlung tomography (Toroidal top view, Z = 0)')
	h = quiver(X_mfl_lcs(1:40:end),Y_mfl_lcs(1:40:end),BX_mfl_lcs(1:40:end),BY_mfl_lcs(1:40:end),0.5);%Magnetic field line direction
	set(h,'Color','k');
	hold on
	h = quiver(X_mfl_lcs(20:40:end),Y_mfl_lcs(20:40:end),Ipdir_mfl_lcs(20:40:end).*BX_mfl_lcs(20:40:end),Ipdir_mfl_lcs(20:40:end).*BY_mfl_lcs(20:40:end),0.5);%Current direction on magnetic field line direction
	set(h,'Color','g');
	axis('equal');	
	graph1D_jd(sR.*cos(sphi),sR.*sin(sphi),0,0,'','','',NaN,'','','-','non','b',2);
	graph1D_jd(XX_tor_min,YY_tor_min,0,0,'','','',NaN,'','','-','non','r',2);
	graph1D_jd(XX_tor,YY_tor,0,0,'','','',NaN,'','','-.','non','r',2);
	graph1D_jd(XX_tor_max,YY_tor_max,0,0,'','','',NaN,'','','-','non','r',2);
	graph1D_jd(VVX,VVY,0,0,'','','',NaN,'','','-.','non','r',1);
	graph1D_jd(HHX,HHY,0,0,'','','',NaN,'','','-.','non','r',1);
	graph1D_jd(X_mfl_lcs(1:3:end),Y_mfl_lcs(1:3:end),0,0,'','','',NaN,'','',':','non','k',1);%Z < 0 
	graph1D_jd(X_mfl_lcs(find(Z_mfl_lcs>=0)),Y_mfl_lcs(find(Z_mfl_lcs>=0)),0,0,'X (m)','Y (m)','Bremsstrahlung tomography (Toroidal top view, Z = 0)','B-field, (Ip: green)','','','-','non','k',1);%Z >= 0 
	hold off
	set(gca,'YDir','rev');%Because the reference is indirect by definition
end
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

