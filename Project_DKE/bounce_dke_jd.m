function [xylambda_p0p0,xylambda_p2m1,xylambda_p2p0,xysstar,xymaskT,xmhu0T2] = bounce_dke_jd(tokamak,xia,ymhu0)
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
%       - lambda: = 1/qtilde int_thetamin^2thetamax dtheta/2pi F(rho,theta,xi) xi0/xi, normalized bounce time 
%       - delta: = {1-1/psi}
%       - sstar = lambda.{psi.xi/xi0}
%       - sstar_tp = lambda.{xi^2/xi0^2}
%       - lambda_tp = lambda.{xi^2/xi0^2.psi} = lambda.(1-delta/xi0^2)
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
[YMdt,YMmask,YMF,YMPSIB,YMmhu0,YMmhu,YMR,YMRBmin,xymaskT] = banana_dke_jd(ymhu0,R0,Z0,XR,XZ,XBR,XBZ,XBphi);
%
Yweight_p0p0 = (YMmhu./YMmhu0).^(0).*YMPSIB.^(0);
Yweight_p1m1p2 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-1).*(YMRBmin./YMR).^(2);
%Yweight_p1p1 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(1);
Yweight_p2m1 = (YMmhu./YMmhu0).^(2).*YMPSIB.^(-1);
Yweight_p2p0 = (YMmhu./YMmhu0).^(2).*YMPSIB.^(0);
%Yweight_p2p1 = (YMmhu./YMmhu0).^(2).*YMPSIB.^(1);
%
xylambda_p0p0 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p0p0)/(2*pi),[np,nmhu])./xyqtilde;
xylambda_p1m1p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m1p2)/(2*pi),[np,nmhu])./xyqtilde;
%xylambda_p1p1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1p1)/(2*pi),[np,nmhu])./xyqtilde;
xylambda_p2m1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2m1)/(2*pi),[np,nmhu])./xyqtilde;
xylambda_p2p0 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2p0)/(2*pi),[np,nmhu])./xyqtilde;
%xylambda_p2p1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2p1)/(2*pi),[np,nmhu])./xyqtilde;
%
xylambda_b_p1m1p2 = ~xymaskT.*xylambda_p1m1p2;%In old notation: xsstar = xq.*xRmin.*xBmin./xqtilde/R0./xBTmin
xysstar = xylambda_b_p1m1p2;%***************notation to be changed according to the notice **********************
%
%xydelta = reshape(sum(YMmask.*YMdt.*YMF.*(1 - 1./YMPSIB))/(2*pi),[np,nmhu])./xylambdaqt;
%xydelta = (1 - reshape(sum(YMmask.*YMdt.*YMF.*YMmhu.^2./YMmhu0.^2./YMPSIB)/(2*pi),[np,nmhu])./xylambdaqt).*xymhu0.^2;;
%xysstar = reshape(sum(YMmask.*YMdt.*YMF.*YMPSIB.*YMmhu./YMmhu0)/(2*pi),[np,nmhu]).*~xymaskT./xyqtilde;
%xysstar_tp = reshape(sum(YMmask.*YMdt.*YMF.*YMmhu.^2./YMmhu0.^2)/(2*pi),[np,nmhu])./xyqtilde;
%xylambda_tp = reshape(sum(YMmask.*YMdt.*YMF.*YMPSIB.*YMmhu.^2./YMmhu0.^2)/(2*pi),[np,nmhu])./xyqtilde;
	
ymask = find(ymhu0 == 0);
if ~isempty(ymask),
	xylambda_p0p0(:,ymask) = eps;
	%xylambda_p1p1(:,ymask) = 0;
	xylambda_p2m1(:,ymask) = eps;
	xylambda_b_p1m1p2(:,ymask) = eps;
	xylambda_p2p0(:,ymask) = eps;
%	xylambda_p2p1(:,ymask) = eps;
end
