function [R0,xBmin,xRBmin,xBTBmin,xq,xqtilde,xqbar,xqhat,...
xylambda_p0p0,xylambda_p2m1,xylambda_b_p1p1,xylambda_b_p1m1p2,xylambda_b_p1m1,xylambda_b_p1m2,xylambda_b_p2m2p2,xylambda_b_p3m2,xylambda_b_p2,xymaskT,xmhu0T2] = bounce_dke_jd(tokamak,xia,ymhu0)
%
% calculates bounce averaging coefficients needed for solving the electron drift-kinetic-equation. 
%
%   INPUTS:
%
%       - tokamak: equilibrium data file name 
%       - xia: radial grid [1,nr]
%       - ymhu0: pitch angle grid [1,nmhu]
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
method = 'linear';%Interpolation method (linear,cubic,spline,...)
%
filename = ['EQUIL_',tokamak];
%filename = 'equihelena';
eval(['load ',filename,'.mat R Z BR BZ BPHI'])
%
nmhu = length(ymhu0);
%
R0 = R(1,1);%R of Magnetic Axis
Z0 = Z(1,1);%Z of Magnetic Axis
%
ia = (R(:,1) - R0)'/R0;
%Interpolation for better numerical accuracy
XR = interp1(ia,R,xia);
XZ = interp1(ia,Z,xia);
XBR = interp1(ia,BR,xia);
XBZ = interp1(ia,BZ,xia);
XBphi = interp1(ia,BPHI,xia);
%
[np,nt] = size(XR);
%
[xq,xqtilde,xqbar,xqhat] = qfactors_dke_yp(R0,Z0,XR,XZ,XBR,XBZ,XBphi);%q factors calculations
xyqtilde = repmat(xqtilde',[1,nmhu]);
%
XBT = abs(XBphi);%Toroidal B-field
XB = sqrt(XBphi.^2 + XBR.^2 + XBZ.^2); % Total B-field
%
xBmin = min(XB'); % Minimum of B on flux surface
xBmax = max(XB'); % Maximum of B on flux surface
%
xmhu0T2 = 1 - xBmin./xBmax; % Pitch-angle (squared) at the trapped-passing boundary
%
XBmin = repmat(xBmin',[1,nt-1]);
iBmin = find(XBmin == XB(:,1:nt-1));
xBTmin = XBT(iBmin)';
xRmin = XR(iBmin)';
%
[R0,xBmin,xRBmin,xBTBmin,YMdt,YMmask,YMF,YMPSIB,YMmhu0,YMmhu,YMR,YMRBmin,xymaskT] = banana_dke_jd(ymhu0,R0,Z0,XR,XZ,XBR,XBZ,XBphi);
%
Yweight_p0p0 = (YMmhu./YMmhu0).^(0).*YMPSIB.^(0);
xylambda_p0p0 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p0p0)/(2*pi),[np,nmhu])./xyqtilde;
%
%Fokker-Planck weights
%
Yweight_p2m1 = (YMmhu./YMmhu0).^(2).*YMPSIB.^(-1);
xylambda_p2m1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2m1)/(2*pi),[np,nmhu])./xyqtilde;
%
Yweight_p1p1 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(1);
xylambda_p1p1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1p1)/(2*pi),[np,nmhu])./xyqtilde;
xylambda_b_p1p1 = ~xymaskT.*xylambda_p1p1;
%
Yweight_p1m1p2 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-1).*(YMRBmin./YMR).^(2);
xylambda_p1m1p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m1p2)/(2*pi),[np,nmhu])./xyqtilde;
xylambda_b_p1m1p2 = ~xymaskT.*xylambda_p1m1p2;%Equivalent form: xq.*xRmin.*xBmin./xqtilde/R0./xBTmin
%
%Drift kinetic weights
%
Yweight_p1m1 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-1);
xylambda_p1m1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m1)/(2*pi),[np,nmhu])./xyqtilde;
xylambda_b_p1m1 = ~xymaskT.*xylambda_p1m1;
%
Yweight_p1m2 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-2);
xylambda_p1m2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m2)/(2*pi),[np,nmhu])./xyqtilde;
xylambda_b_p1m2 = ~xymaskT.*xylambda_p1m2;%In old notation: 1-delta/mhu0^2
%
Yweight_p2m2p2 = (YMmhu./YMmhu0).^(2).*YMPSIB.^(-2).*(YMRBmin./YMR).^(2);
xylambda_p2m2p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2m2p2)/(2*pi),[np,nmhu])./xyqtilde;
xylambda_b_p2m2p2 = ~xymaskT.*xylambda_p2m2p2;
%
Yweight_p3m2 = (YMmhu./YMmhu0).^(3).*YMPSIB.^(-2);
xylambda_p3m2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p3m2)/(2*pi),[np,nmhu])./xyqtilde;
xylambda_b_p3m2 = ~xymaskT.*xylambda_p3m2;
%
Yweight_p2 = (YMmhu./YMmhu0).^(2);
xylambda_p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2)/(2*pi),[np,nmhu])./xyqtilde;%In old notation: s*_tilde
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
