function [xInt] = qtilde_dke_jd(R0,Z0,XR,XZ,XBR,XBZ,XBphi);

XR = XR';
XZ = XZ';
XBR = XBR';
XBZ = XBZ';
XBphi = XBphi';

[nt,np] = size(XR);

theta = linspace(0,2*pi,nt); % Angular grid
Xtheta = repmat(theta',[1,np]);

XBT = abs(XBphi); % Toroidal B-field
XBP = sqrt(XBR.^2 + XBZ.^2); % Poloidal B-field
XB = sqrt(XBT.^2 + XBP.^2); % Total B-field

% Half grid in theta for integration

XMBR = (XBR(1:nt-1,:) + XBR(2:nt,:))/2;
clear XBR

XMBZ = (XBZ(1:nt-1,:) + XBZ(2:nt,:))/2;
clear XBZ

XMBphi = (XBphi(1:nt-1,:) + XBphi(2:nt,:))/2;
clear XBphi

XMR = (XR(1:nt-1,:) + XR(2:nt,:))/2;
clear XR

XMZ = (XZ(1:nt-1,:) + XZ(2:nt,:))/2;
clear XZ

nm = nt - 1;

XMB = sqrt(XMBR.^2 + XMBZ.^2 + XMBphi.^2); 

XMF = XMB.*((XMR - R0).^2 + (XMZ - Z0).^2)./abs(XMBR.*(XMZ - Z0) - XMBZ.*(XMR - R0))./R0;

clear XMB XMR XMZ XMBR XMBZ XMBphi

XMdt = diff(Xtheta);

xInt = squeeze(sum(XMF.*XMdt)/(2*pi));
	
