function [vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr] = bremchord_dke_yp(tokamak,HXR,xpsin,xpsin_S,mfactor,method,display,ns);
%
% This function calculates chord positions fro bremsstrahlung tomography in a torus along unit vector g. 
%
% INPUTS
%
%       - HXR: geometrical characteristics of the HXR tomographic system 
%       - xpsin: poloidal flux surfaces for f used by DKE code [1,npsi]
%       - xpsin_S: poloidal flux surfaces used for S by DKE code [1,npsi+1]
%       - mfactor:
%         (default = 10)
%       - method: interpolation method
%         (default = 'spline')
%       - display: display chords [1,1]
%         (default = 2)
%       - ns: number of points on the chords [1,1]
%         (default = 2000)
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

%[vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr] = bremchord_dke_yp('TS',HXR,xpsin_dke,xpsin_S_dke,1,'spline',2);
if nargin < 4,
    error('Not enough arguments in bremchord_dke_yp')
elseif nargin == 4,
   	mfactor = 1;
		method = 'spline'; 	
      display = 2;
      ns = 2000;
elseif nargin == 5,
		method = 'spline'; 	
		display = 2;
		ns = 2000;
elseif nargin == 6,
		display = 2;
		ns = 2000;
elseif nargin == 7,
		ns = 2000;
end
%
ns = abs(ns);%Force ns to be always positive
nchords = length(HXR{1,1});%chord number
%
[theta,ppsin,psia,ptR,ptZ,ptBR,ptBZ,ptBphi,ptB0,ptR0,ptBT0,ptBp0,ptrho] = equilibrium_jd(tokamak,NaN*xpsin,xpsin_S,display,method,mfactor);%NaN
%
Rp = ptR(1,1);%Plasma major radius (m)
Zp = ptZ(1,1);%Plasma vertical position (m)
xq = qfactors_dke_yp(Rp,Zp,ptR,ptZ,ptBR,ptBZ,ptBphi);%Safety factor
r_lcs = sqrt((ptR(length(ppsin),:) - Rp).^2 + (ptZ(length(ppsin),:) - Zp).^2);%Minor radius of the last closed magnetic surface
ap = max([r_lcs(1),max(r_lcs)]);%Max of low field side  minor radius and maximum minor radius
%
smax = 2*(Rp + ap);%maximum chord length = R_hxr+a_hxr
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
ptBtheta = -ptBR.*sin(ones(size(ppsin))*theta) + ptBZ.*cos(ones(size(ppsin))*theta);
Ipdir = 2*isempty(find(ptBtheta < 0)) - 1;%If +1: Ip same direction to Bphi, if -1 Ip opposite direction to Bphi
%
BX_mfl_lcs = BR_mfl_lcs.*cos(phi_mfl) - Bphi_mfl_lcs.*sin(phi_mfl);
BY_mfl_lcs = BR_mfl_lcs.*sin(phi_mfl) + Bphi_mfl_lcs.*cos(phi_mfl);
%
X_mfl_lcs = (Rp + r_mfl_lcs.*cos(theta_mfl_lcs)).*cos(phi_mfl); 
Y_mfl_lcs = (Rp + r_mfl_lcs.*cos(theta_mfl_lcs)).*sin(phi_mfl); 
Z_mfl_lcs = Zp + r_mfl_lcs.*sin(theta_mfl_lcs);
%
alpha_hxr = ones(ns,1)*HXR{1,1};%Defined in the indirect frame only (see the documentation)
beta_hxr = ones(ns,1)*HXR{1,2};
R_hxr = ones(ns,1)*HXR{1,3};
Z_hxr = ones(ns,1)*HXR{1,4};
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
spsi = griddata(ptR,ptZ,ppsin*ones(1,length(theta)),sR,sZ);%Flux surface value
%
gX_hxr = sin(beta_hxr).*cos(alpha_hxr);%Chord vector
gY_hxr = sin(beta_hxr).*sin(alpha_hxr);%Chord vector
gZ_hxr = cos(beta_hxr);%Chord vector
%
sr = sqrt((sR - Rp).^2 + (sZ - Zp).^2);%Minor radius along the chords
st = atan((sZ - Zp)./(sR - Rp)) + pi - pi*(sR > Rp).*sign(sZ - Zp);%poloidal angle [0,2*pi]
%
sr_lcs = interp1(theta,r_lcs,st,method);
mask = sr < sr_lcs;
for ic = 1:nchords,
   imask = find(mask(1:end-1,ic)-mask(2:end,ic) == 1);
   if length(imask) == 2,%reject the case when chord go through the plasma twice
   	mask(1:imask(1),ic) = logical(0);
   end
end	
sR(~mask) = NaN;
sZ(~mask) = NaN; 
sphi(~mask) = NaN; 
sr(~mask) = NaN;
st(~mask) = NaN;
spsi(~mask) = NaN;
sBR=griddata(ptR,ptZ,ptBR,sR,sZ);
sBZ=griddata(ptR,ptZ,ptBZ,sR,sZ);
sBphi=griddata(ptR,ptZ,ptBphi,sR,sZ);
sB = sqrt(sBR.^2 + sBZ.^2 + sBphi.^2);
sksid = -Ipdir*((sBR.*cos(sphi) - sBphi.*sin(sphi)).*gX_hxr + (-sBR.*sin(sphi) + sBphi.*cos(sphi)).*gY_hxr + sBZ.*gZ_hxr)./sB;%cosine between magnetic field line and chord direction
%
if display >= 1
   figure(2878),
	[ax] = graph1D_jd(sR,sZ,0,0,'','','',NaN,'','','-','none','b',2);pause(0.5);%Poloidal plot
   xlabel('X=R (m)');ylabel('Z (m)');title('Bremsstrahlung tomography (Poloidal view)')
   hold on
   for ir = 1:length(xpsin_S),
        plot(RR_pol(ir,:),ZZ_pol(ir,:),'r')
   end
   axis('equal');
   plot(HHR_pol,HHZ_pol,'r-.')
   plot(VVR_pol,VVZ_pol,'r-.')
	plot(ptR,ptZ,'r-')
   hold off
%
	figure(2879),
	quiver(RR_pol,ZZ_pol,BR_pol,BZ_pol);
	axis('equal');
	xlabel('X=R (m)');ylabel('Z (m)');title('Poloidal field (T)')
	hold on
	plot(ptR,ptZ,'c-')
	plot(HHR_pol,HHZ_pol,'r-.')
	plot(VVR_pol,VVZ_pol,'r-.')
	hold off  
%
	figure(2880)
	plot(sR.*cos(sphi),sR.*sin(sphi),'b','LineWidth',2);%Toroidal plot
	xlabel('X (m)');ylabel('Y (m)');title('Bremsstrahlung tomography (Top toroidal view, Z = 0), Ip:green, B-field:black')
	hold on
	plot(XX_tor_min,YY_tor_min,'r',XX_tor,YY_tor,'r-.',XX_tor_max,YY_tor_max,'r','LineWidth',2)
	axis('equal');
	plot(VVX,VVY,'r-.')
	plot(HHX,HHY,'r-.')
	plot(X_mfl_lcs(1:3:end),Y_mfl_lcs(1:3:end),'k:');%Z < 0                                        
	plot(X_mfl_lcs(find(Z_mfl_lcs>=0)),Y_mfl_lcs(find(Z_mfl_lcs>=0)),'k-');%Z >= 0
	h = quiver(X_mfl_lcs(1:40:end),Y_mfl_lcs(1:40:end),BX_mfl_lcs(1:40:end),BY_mfl_lcs(1:40:end),0.5);%Magnetic field line direction
	set(h,'Color','k');
	h = quiver(X_mfl_lcs(20:40:end),Y_mfl_lcs(20:40:end),Ipdir*BX_mfl_lcs(20:40:end),Ipdir*BY_mfl_lcs(20:40:end),0.5);%Current direction on magnetic field line direction
	set(h,'Color','g');
	hold off
	set(gca,'YDir','rev');%Because the reference is indirect by definition
end
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
   	if isempty(find(it_st(:,1:59) == j & ir_spsi(:,1:59) == i)) ~= 1,
   		mask_hxr(i,j) = 1;
   	end
   end
end
%
theta_hxr = ones(length(xpsin),1)*(theta(1:end-1) + diff(theta)/2);
psin_hxr = xpsin'*ones(1,length(theta)-1);
B0_hxr = interp1(ppsin,ptB0,xpsin,method);%Bmin
PSI_hxr = griddata(ppsin*ones(1,length(theta)),ones(length(ppsin),1)*theta,sqrt(ptBR.^2 + ptBZ.^2 + ptBphi.^2),psin_hxr,theta_hxr)./(B0_hxr'*ones(1,length(theta)-1));%B/Bmin
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

