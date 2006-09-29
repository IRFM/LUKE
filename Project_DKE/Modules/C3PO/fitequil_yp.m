function [equil_out] = fitequil_yp(equil_in,nharm,method,ngrid)
%
% Build vectorial tokamak magnetic equilibrium from its numerical counterpart
% 1-D: use interp1 MatLab built-in function (spline, bi-cubic, linear,
% nearest,...)
% 2-D: use Fourier series expansion for the poloidal dependence and the
% interp1 for the Fourier series coefficients (spline, bi-cubic, linear,
% nearest,...)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin == 1, 
    nharm = [];
    method = 'spline';
    ngrid = 2000;
elseif nargin == 2, 
    method = 'spline';
    ngrid = 2000;
elseif nargin == 3, 
    ngrid = 2000;   
end
%
equil_out.id = equil_in.id;
equil_out.method = method;
equil_out.zZi = equil_in.zZi;
equil_out.zmi = equil_in.zmi;
%
[rho] = psi2rho_jd(equil_in,equil_in.ppsi/equil_in.ppsi(end),method);
%
%Resampling on a finer mesh before spline-Fourier calculations
%
srho = linspace(0,1,ngrid).^2;
spsin = interp1(rho,equil_in.ppsi/equil_in.ppsi(end),srho,method);
sRstar = interp1(rho,equil_in.R(:,1),srho,method);
%
sTe = interp1(rho,equil_in.pTe,srho,method);
sne = interp1(rho,equil_in.pne,srho,method);
szTi = interp1(rho,equil_in.pzTi',srho',method)';
szni = interp1(rho,equil_in.pzni',srho',method)';
%
sBR = interp1(rho,equil_in.BR,srho,method);%BR field component
sBZ = interp1(rho,equil_in.BZ,srho,method);%BZ field component
sBPHI = interp1(rho,equil_in.BPHI,srho,method);%PHI field component
sR = interp1(rho,equil_in.R,srho,method);%R coordinate
sZ = interp1(rho,equil_in.Z,srho,method);%Z coordinate
%
% Calculation of the vectorial magnetic equilibrium
%
equil_out.psin_fit = interpequil_yp(method,spsin,srho);
%
sRstar_psin_fit = interpequil_yp(method,sR(:,1),spsin);%Rstar = R(:,theta=0)
sdRstardpsin_psin = ppval(sRstar_psin_fit.pp_dfdrho,spsin);
equil_out.dRstardpsin_fit = interpequil_yp(method,sdRstardpsin_psin,srho);
%
equil_out.Te_fit = interpequil_yp(method,sTe,srho);
equil_out.ne_fit = interpequil_yp(method,sne,srho);
equil_out.zTi_fit = interpequil_yp(method,szTi,srho);
equil_out.zni_fit = interpequil_yp(method,szni,srho);
%
equil_out.BR_fit = interpequil_yp(method,sBR,srho,equil_in.theta,nharm);%BR field component
equil_out.BZ_fit = interpequil_yp(method,sBZ,srho,equil_in.theta,nharm);%BZ field component
equil_out.BPHI_fit = interpequil_yp(method,sBPHI,srho,equil_in.theta,nharm);%PHI field component
equil_out.R_fit = interpequil_yp(method,sR,srho,equil_in.theta,nharm);%R coordinate
equil_out.Z_fit = interpequil_yp(method,sZ,srho,equil_in.theta,nharm);%Z coordinate
%
if equil_in.ppsi(1) == 0,
   equil_out.Rp = equil_in.R(1,1);
   equil_out.Zp = equil_in.Z(1,1);
   equil_out.ap = equil_in.R(end,1) - equil_in.R(1,1);
   equil_out.psia = equil_in.ppsi(end);
else
   error('equil_out.ppsi(1) must be equal to zero !');
end
