function [vschord] = bremchord_dke_yp(HXR,display,n);
%
% This function calculates chord positions fro bremsstrahlung tomography in a torus along unit vector g. 
%
% INPUTS
%
%       - HXR: HXR tomographic system geometrical characteristics
%       - display: display chords [1,1]
%       - ns: number of points on the chords [1,1]
%
% OUTPUTS
%       
%       - vschord: chord parameter [11,n,nchords]
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 1,
    error('Not enough arguments in bremchord_dke_yp')
elseif nargin == 1,
   display = 1;
   ns = 1000;
elseif nargin == 2,
	ns = 1000;
end
%
ns = abs(ns);%Force ns to be always positive
%
% Conversion to proper plasma coordinates
%
nchords = length(HXR{1,1});%chord number
smax = HXR{1,4};%So that tangential chords may be also considered (maximum chord length = 2*R_hxr)
s = linspace(-smax,0,ns)'*ones(1,nchords);%for nchords
%
RR = HXR{1,4} + HXR{1,5}*cos(linspace(0,2*pi,1000));% Reference circle
ZZ = HXR{1,5}*sin(linspace(0,2*pi,1000));% Reference circle
HHR = linspace(HXR{1,4}-HXR{1,5},HXR{1,4}+HXR{1,5},1000);
HHZ = zeros(1,1000);
VVR = HXR{1,4}+zeros(1,1000);
VVZ = linspace(-HXR{1,5},+HXR{1,5},1000);
%
R_L = ones(ns,1)*(HXR{1,4} + HXR{1,5}*cos(HXR{1,2}*pi/180));
Z_L = ones(ns,1)*(HXR{1,5}*sin(HXR{1,2}*pi/180));
alpha_L = ones(ns,1)*(HXR{1,3}*pi/180);
beta_L = ones(ns,1)*(pi/2 - HXR{1,1}*pi/180);
%
if alpha_L <= -pi | alpha_L > pi
    error('need -pi < alpha_L <= pi')
end
if beta_L < 0 | beta_L > pi
    error('need 0 <= alpha_L <= pi')
end    
%
sZ = s.*cos(beta_L);
sh = s.*sin(beta_L);
%
R = sqrt(R_L.^2 + sh.^2 + 2*R_L.*sh.*cos(alpha_L));
Z = Z_L + sZ;
phi = acos((R.^2 + R_L.^2 - sh.^2)./(2*R.*R_L)).*sign(alpha_L);
%
gR = sin(beta_L).*cos(alpha_L - phi);
gZ = cos(beta_L);
gphi = sin(beta_L).*sin(alpha_L - phi);
%
alpha = alpha_L - phi;
beta = beta_L;
%
mask = ((R- HXR{1,4}).^2 + Z.^2) > HXR{1,5}^2;
R(mask)=NaN;
Z(mask)=NaN;
%
if display >= 1
   plot(R,Z,'b')
   xlabel('R (m)');ylabel('Z (m)');title('Bremsstrahlung tomography')
   hold on
   plot(RR,ZZ,'r')
   axis('equal');
   plot(HHR,HHZ,'r-.')
   plot(VVR,VVZ,'r-.')
   hold off
end
%
vschord = zeros(11,ns,nchords);
vschord(1,:,:) = s;
vschord(2,:,:) = R;
vschord(3,:,:) = Z;
vschord(4,:,:) = sh;
vschord(5,:,:) = sZ;
vschord(6,:,:) = phi;
vschord(7,:,:) = alpha;
vschord(8,:,:) = beta;
vschord(9,:,:) = gR;
vschord(10,:,:) = gZ;
vschord(11,:,:) = gphi;

