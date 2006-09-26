function [equil_out] = fitequil_yp(equil_in,nharm,method)
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
elseif nargin == 2, 
    method = 'spline';
end
%
equil_out.id = equil_in.id;
equil_out.method = method;
equil_out.zZi = equil_in.zZi;
equil_out.zmi = equil_in.zmi;
%
[rho] = psi2rho_jd(equil_in,equil_in.ppsi/equil_in.ppsi(end),method);
%
equil_out.psin_fit = interpequil_yp(method,equil_in.ppsi/equil_in.ppsi(end),rho);
%
Rstar_psin_fit = interpequil_yp(method,equil_in.R(:,1),equil_in.ppsi/equil_in.ppsi(end));%Rstar = R(:,theta=0)
dRstardpsin_psin = ppval(Rstar_psin_fit.pp_dfdrho,equil_in.ppsi/equil_in.ppsi(end));
equil_out.dRstardpsin_fit = interpequil_yp(method,dRstardpsin_psin,rho);
%
equil_out.Te_fit = interpequil_yp(method,equil_in.pTe,rho);
equil_out.ne_fit = interpequil_yp(method,equil_in.pne,rho);
equil_out.zTi_fit = interpequil_yp(method,equil_in.pzTi,rho);
equil_out.zni_fit = interpequil_yp(method,equil_in.pzni,rho);
%
equil_out.BR_fit = interpequil_yp(method,equil_in.BR,rho,equil_in.theta,nharm);%BR field component
equil_out.BZ_fit = interpequil_yp(method,equil_in.BZ,rho,equil_in.theta,nharm);%BZ field component
equil_out.BPHI_fit = interpequil_yp(method,equil_in.BPHI,rho,equil_in.theta,nharm);%PHI field component
equil_out.R_fit = interpequil_yp(method,equil_in.R,rho,equil_in.theta,nharm);%R coordinate
equil_out.Z_fit = interpequil_yp(method,equil_in.Z,rho,equil_in.theta,nharm);%Z coordinate
%
if equil_in.ppsi(1) == 0,
   equil_out.Rp = equil_in.R(1,1);
   equil_out.Zp = equil_in.Z(1,1);
   equil_out.ap = equil_in.R(end,1) - equil_in.R(1,1);
   equil_out.psia = equil_in.ppsi(end);
else
   error('equil_out.ppsi(1) must be equal to zero !');
end
%