function [vschords,gR,gZ,gphi] = bremchord_dke_yp(tokamak,HXR,xpsin_S,display,ns);
%
% This function calculates chord positions fro bremsstrahlung tomography in a torus along unit vector g. 
%
% INPUTS
%
%       - HXR: HXR tomographic system geometrical characteristics
%       - xpsin_S: flux surfaces used by DKE code
%       - display: display chords [1,1]
%       - ns: number of points on the chords [1,1]
%
% OUTPUTS
%       
%       - vschords: chords parameter [4,n,nchords]
%       - gR: component of g along R [1,n,nchords]
%       - gZ: component of g along Z [1,n,nchords]
%       - gphi: component of g along phi [1,n,nchords]
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 3,
    error('Not enough arguments in bremchord_dke_yp')
elseif nargin == 3,
   display = 1;
   ns = 2000;
elseif nargin == 4,
	ns = 2000;
end
%
ns = abs(ns);%Force ns to be always positive
nchords = length(HXR{1,1});%chord number
%
[theta,ppsin,psia,ptR,ptZ,ptBR,ptBZ] = equilibrium_jd(tokamak);	
%
Rp = ptR(1,1);%Plasma major radius (m)
Zp = ptZ(1,1);%Plasma vertical position (m)
%
r_lcs = sqrt((ptR(length(ppsin),:) - Rp).^2 + (ptZ(length(ppsin),:) - Zp).^2);%Minor radius of the last closed magnetic surface
ap = max([r_lcs(1),max(r_lcs)]);%Max of low field side  minor radius and maximum minor radius
smax = 2*(Rp + ap);%maximum chord length = R_hxr+a_hxr
s = linspace(-smax,0,ns)'*ones(1,nchords);%for nchords (s negative by definition)
% Poloidal plot
for ir = 1:length(xpsin_S)
   RR_pol(ir,:) = interp1(ppsin,ptR,xpsin_S(ir),'spline');
   ZZ_pol(ir,:) = interp1(ppsin,ptZ,xpsin_S(ir),'spline');
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
alpha_hxr = ones(ns,1)*HXR{1,1};
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
sZ = Z_hxr + sZ;
sphi = acos((sR.^2 + R_hxr.^2 - sh.^2)./(2*sR.*R_hxr)).*sign(alpha_hxr);
%
gR = sin(beta_hxr).*cos(alpha_hxr);
gZ = cos(beta_hxr);
gphi = sin(beta_hxr).*sin(alpha_hxr);
%
sr = sqrt((sR - Rp).^2 + (sZ - Zp).^2);%Minor radius along the chords
st = atan((sZ - Zp)./(sR - Rp)) + pi - pi*(sR > Rp).*sign(sZ - Zp);%poloidal angle [0,2*pi]
%
sr_lcs = interp1(theta,r_lcs,st,'spline');
mask = sr < sr_lcs;
for ic = 1:nchords,
   imask = find(mask(1:end-1,ic)-mask(2:end,ic) == 1);
   if length(imask) == 2,%reject the case when chord go through the plasma twice
   	mask(1:imask(1),ic) = logical(0);
   end
end	
sR(~mask)=NaN;
sZ(~mask)=NaN; 
%
if display >= 1
   figure(2878),plot(sR,sZ,'b');%Poloidal plot
   xlabel('X=R (m)');ylabel('Z (m)');title('Bremsstrahlung tomography (Poloidal view)')
   hold on
   for ir = 1:length(xpsin_S),
        plot(RR_pol(ir,:),ZZ_pol(ir,:),'r')
   end
   axis('equal');
   plot(HHR_pol,HHZ_pol,'r-.')
   plot(VVR_pol,VVZ_pol,'r-.')
   hold off
%
	figure(2879)
	plot(sR.*cos(sphi),sZ.*sin(sphi),'b');%Toroidal plot
	xlabel('X (m)');ylabel('Y (m)');title('Bremsstrahlung tomography (Toroidal view, Z = 0)')
	hold on
	plot(XX_tor_min,YY_tor_min,'r',XX_tor,YY_tor,'r-.',XX_tor_max,YY_tor_max,'r')
	axis('equal');
	plot(VVX,VVY,'r-.')
	plot(HHX,HHY,'r-.')
	hold off
end
%
vschords = zeros(4,ns,nchords);
vschords(1,:,:) = s;
vschords(2,:,:) = sR;
vschords(3,:,:) = sZ;
vschords(4,:,:) = sphi;
