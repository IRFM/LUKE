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
%equil_out.fi = equil_in.fi;
%
equil_out.Te_fit = interpequil_yp(method,equil_in.pTe,equil_in.ppsi);
equil_out.ne_fit = interpequil_yp(method,equil_in.pne,equil_in.ppsi);
equil_out.zTi_fit = interpequil_yp(method,equil_in.pzTi,equil_in.ppsi);
equil_out.zni_fit = interpequil_yp(method,equil_in.pzni,equil_in.ppsi);
%
BP = sqrt(equil_in.BR.^2 + equil_in.BZ.^2);
equil_out.BP_fit = interpequil_yp(method,BP,equil_in.ppsi,equil_in.theta,nharm);%Poloidal B-field
equil_out.BPHI_fit = interpequil_yp(method,equil_in.BPHI,equil_in.ppsi,equil_in.theta,nharm);%Toroidal B-field
equil_out.R_fit = interpequil_yp(method,equil_in.R,equil_in.ppsi,equil_in.theta,nharm);%R coordinate
equil_out.Z_fit = interpequil_yp(method,equil_in.Z,equil_in.ppsi,equil_in.theta,nharm);%Z coordinate
%
if equil_in.ppsi(1) == 0,
   equil_out.Rp = equil_in.R(1,1);
   equil_out.Zp = equil_in.Z(1,1);
else
   error('equil_out.ppsi(1) must be equal to zero !');
end
%
r = sqrt((equil_in.R - equil_out.Rp).^2 + (equil_in.Z - equil_out.Zp).^2);
r(1,:) = eps;%to avoid singularity for cos(alpha) at psi = 0. 
BP(1,:) = eps;%to avoid singularity for cos(alpha) at psi = 0. 
calpha = (-equil_in.BZ.*(equil_in.R - equil_out.Rp) + equil_in.BR.*(equil_in.Z - equil_out.Zp))./r./BP;
%
equil_out.r_fit = interpequil_yp(method,r,equil_in.ppsi,equil_in.theta,nharm);%r coordinate
equil_out.calpha_fit = interpequil_yp(method,calpha,equil_in.ppsi,equil_in.theta,nharm);%cos(alpha) (=1 for circular plasma cross-section)

