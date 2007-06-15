% script test_interp_theta_jd
%
% This script tests the function interp_theta_jd;
%
clear all
close all
%
% simple analytical case
%
Bzp = 1;
nt = 65;
pia = [0.1,0.2,0.3];
pBPp = 1*pia;
%
np = length(pia);
theta = linspace(0,2*pi,nt);
theta = linspace(pi/2,5*pi/2,nt);
XRratio = 1 + cos(theta.')*pia;
%
XBzp = Bzp*ones(nt,np);
XBxp = (-sin(theta.')*pBPp);
XByp = (cos(theta.')*pBPp);
%
XBz = XBzp./XRratio;
XBx = XBxp./XRratio;
XBy = XByp./XRratio;
%
btheta = [1,3,5,7]*pi/4;
nb = length(btheta);
%
pBp = sqrt(Bzp^2 + pBPp.^2);
bpB = (ones(nb,1)*pBp)./(1 + cos(btheta.')*pia);
%
[Ytheta1,Ytheta2] = interp_theta_jd(theta,XBx,XBy,XBz,bpB.');
%

