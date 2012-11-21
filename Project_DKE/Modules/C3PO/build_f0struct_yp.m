function f0struct = build_f0struct_yp(dke_out,momentumDKE,equilDKE,mksa,mode,method,ngrid,nharm)
%
% Build vectorial tokamak magnetic equilibrium from its numerical counterpart
% Two operating modes :
% 1) Spline-Fourier description for (psi,theta) magnetic equilibrium (HELENA for example)
%
%    1-D: use interp1.m MatLab built-in function (Hermite polynomials (pchip), spline, linear,  nearest,...)
%    2-D: use Fourier series expansion for the poloidal dependence and the
%    interp1.m for the Fourier series coefficients (Hermite polynomials (pchip), spline, linear,
%    nearest,...)
%
% 2) Spline-Spline description for (x,y) magnetic equilibrium (EFIT for example)
%
%    1-D: use interp1.m MatLab built-in function (Hermite polynomials (pchip), spline, linear, nearest,...)
%    2-D: use interp1.m for the x-direction and the interp1.m again for the coefficients of the 
%    previous spline (Hermite polynomials (pchip), spline, linear, nearest,...)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 4, 
    error('Wrong number of input arguments in build_f0struct_yp.m');
end
%
if nargin == 4, 
    mode = 1;%Spline-Fourier case
    method = 'pchip';
    ngrid = 200;
    nharm = [];
end
%
if nargin == 5, 
    method = 'pchip';
    ngrid = 200;
    nharm = [];
end
%
if nargin == 6, 
    ngrid = 200;  
    nharm = [];
end
%
if nargin == 7, 
    nharm = [];%For Spline-Fourier case only
end
%
f0struct.ne_ref = mksa.ne_ref;
f0struct.betath_ref = mksa.betath_ref;
%
f0struct.pn = momentumDKE.pn;
f0struct.mhu = momentumDKE.mhu;
%
if mode == 1,
    %
	srho = linspace(0,1,ngrid).^2;
    %
    sBx = interp1(equilDKE.xrho,equilDKE.XBx,srho,method);%Bx field component
    sBy = interp1(equilDKE.xrho,equilDKE.XBy,srho,method);%By field component
    sBphi = interp1(equilDKE.xrho,equilDKE.XBphi,srho,method);%PHI field component
    %
    sB = sqrt(sBx.*sBx + sBy.*sBy + sBphi.*sBphi);%Module of the total magnetic field
    sB0 = interp1(equilDKE.xrho,equilDKE.xB0(:)*ones(1,length(equilDKE.mtheta)),srho,method);%Module of the total magnetic field at theta = 0 (where it is minimum)
    sPSI = sB./sB0;
    %
    f0struct.PSI_fit = interpequilpt_yp(method,sPSI,srho,equilDKE.mtheta,nharm);
    %
	sXXf0 = interp1(equilDKE.xrho,reshape(dke_out.XXf0{end},length(momentumDKE.pn)*length(momentumDKE.mhu),length(equilDKE.xrho))',srho,method);
	f0struct.XXf0_fit = interpequilpt_yp(method,sXXf0',srho);
    %
else
   error('XY equilibrium is not yet implemented for f0struct interpolation.');
end


