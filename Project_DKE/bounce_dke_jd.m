function [xq,xqtilde,xqbar,xqhat,xymaskT,...
    xylambda_p0p0,xylambda_p2m1,xylambda_p2m2p2,xylambda_b_p1p1,xylambda_b_p1m1p2,xylambda_b_p1m1,xylambda_b_p1m2,xylambda_b_p2m2p2,xylambda_b_p3m2,xylambda_b_p2,xylambda_b_p1m3p4]...
= bounce_dke_jd(ymhu0,XR,XZ,XBR,XBZ,XBphi,xB0,xR0,xBT0,Rp,Zp)
%
% calculates bounce averaging coefficients needed for solving the electron drift-kinetic-equation. 
%
%   INPUTS:
%
%       - ymhu0: pitch angle grid [1,nmhu]
%       - plasma magnetic equilibrium
%
%   OUTPUTS:
%   
%
% by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
if nargin < 3,
	error('Not enough arguments');
end
%
nmhu = length(ymhu0);
[nr,nt] = size(XR);
%
[xq,xqtilde,xqbar,xqhat] = qfactors_dke_yp(Rp,Zp,XR,XZ,XBR,XBZ,XBphi);%q factors calculations
xyqtilde = repmat(xqtilde',[1,nmhu]);
%
[YMdt,YMmask,YMF,YMPSIB,YMmhu0,YMmhu,YMR,xymaskT,nm2] = banana_dke_jd(ymhu0,Rp,Zp,XR,XZ,XBR,XBZ,XBphi);
%
YMR0 = repmat(xR0,[nm2,1,nmhu]);
%
Yweight_p0p0 = (YMmhu./YMmhu0).^(0).*YMPSIB.^(0);
xylambda_p0p0 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p0p0)/(2*pi),[nr,nmhu])./xyqtilde;
%
%For flux surface averaged Ohmic electric field
%
Yweight_p1m3p4 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-3).*(YMR0./YMR).^(4);
xylambda_p1m3p4 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m3p4)/(2*pi),[nr,nmhu])./xyqtilde;
xylambda_b_p1m3p4 = ~xymaskT.*xylambda_p1m3p4;
%
%Fokker-Planck weights
%
Yweight_p2m1 = (YMmhu./YMmhu0).^(2).*YMPSIB.^(-1);
xylambda_p2m1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2m1)/(2*pi),[nr,nmhu])./xyqtilde;
%
Yweight_p1p1 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(1);
xylambda_p1p1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1p1)/(2*pi),[nr,nmhu])./xyqtilde;
xylambda_b_p1p1 = ~xymaskT.*xylambda_p1p1;
%
Yweight_p1m1p2 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-1).*(YMR0./YMR).^(2);
xylambda_p1m1p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m1p2)/(2*pi),[nr,nmhu])./xyqtilde;
xylambda_b_p1m1p2 = ~xymaskT.*xylambda_p1m1p2;%Equivalent form: xq.*xRmin.*xB0./xqtilde/R0./xBTmin                                              
%
%Drift kinetic weights
%
Yweight_p1m1 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-1);
xylambda_p1m1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m1)/(2*pi),[nr,nmhu])./xyqtilde;
xylambda_b_p1m1 = ~xymaskT.*xylambda_p1m1;
%
Yweight_p1m2 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-2);
xylambda_p1m2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m2)/(2*pi),[nr,nmhu])./xyqtilde;
xylambda_b_p1m2 = ~xymaskT.*xylambda_p1m2;%In old notation: 1-delta/mhu0^2
%
Yweight_p2m2p2 = (YMmhu./YMmhu0).^(2).*YMPSIB.^(-2).*(YMR0./YMR).^(2);
xylambda_p2m2p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2m2p2)/(2*pi),[nr,nmhu])./xyqtilde;
xylambda_b_p2m2p2 = ~xymaskT.*xylambda_p2m2p2;
%
Yweight_p3m2 = (YMmhu./YMmhu0).^(3).*YMPSIB.^(-2);
xylambda_p3m2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p3m2)/(2*pi),[nr,nmhu])./xyqtilde;
xylambda_b_p3m2 = ~xymaskT.*xylambda_p3m2;
%
Yweight_p2 = (YMmhu./YMmhu0).^(2);
xylambda_p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2)/(2*pi),[nr,nmhu])./xyqtilde;%In old notation: s*_tilde
xylambda_b_p2 = ~xymaskT.*xylambda_p2;
%
ymask = find(ymhu0 == 0);
if ~isempty(ymask),
	xylambda_p0p0(:,ymask) = eps;
	xylambda_p2m1(:,ymask) = eps;
	xylambda_b_p1p1(:,ymask) = eps;
	xylambda_b_p1m1p2(:,ymask) = eps;
%
	xylambda_b_p1m1(:,ymask) = eps;
	xylambda_b_p1m2(:,ymask) = eps;
	xylambda_b_p2m2p2(:,ymask) = eps;
	xylambda_b_p3m2(:,ymask) = eps;
	xylambda_b_p2(:,ymask) = eps;
end
