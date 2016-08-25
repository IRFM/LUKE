function [xalphaphi,snui] = alphaphi_cd_yp(ray,equilDKE_Fourier,omega_rf)
%
%   ALPHAPHI_CD_YP 
%
%   This function calculates the collisional damping absorption coefficient,
%   normalized to omega_rf/clum/phi, where omega_rf is the wave angular frequency
%   (in rad/s), clum is the speed of light (in m/s) and phi is the normalized
%   energy flow density. The result is an adimensional quantity.
%
%   INPUTS : 
%
%           - ray: ray structure [1,nx]
%           - equilDKE_Fourier: equil structure [1,nx]
%           - omega_rf: reference fréquency (Hz) [1,1]
%
%   OUTPUTS :
%           - xalphaphi: alpha/(omega_rf/clum/phi) [1,nx]
%           - snui: electron-ion collision frequencies normalized to omega_rf [ns,nx]
%
%   by Y. Peysson CEA-IRFM (yves.peysson@cea.fr)
%
if nargin < 3,
    error('Not enough input arguments in alphaphi_cd_yp.m')
end
%
zZi = equilDKE_Fourier.zZi;
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB] = pc_dke_yp();
%
sbetath = sqrt(ray.sTe./mc2);%Normalized pth_ref/mc as prescribed by Karney
slnc_e = 31.3 - 0.5*log(ray.sne) + log(ray.sTe*1000);%Reference Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
nhu_e = qe^4*ray.sne.*slnc_e./(4.*pi.*e0.^2.*me.^2.*(clum.*sbetath).^3);%Reference relativistic electron-electron collision frequency (s-1)
%
for iz = 1:length(zZi),
    snui(iz,:) = nhu_e.*(sqrt(2/pi)/3).*ray.szni(iz,:).*zZi(iz).*zZi(iz)./ray.sne/omega_rf;
end
%
xalphaphi = ray.swpe2.*sum(snui.*((1./((1-sqrt(ones(length(zZi),1)*ray.swce2)).^2 + snui.^2).*(ones(length(zZi),1)*ray.sepol_pmz(1,:).^2) + (1./((1+sqrt(ones(length(zZi),1)*ray.swce2)).^2 + snui.^2)).*(ones(length(zZi),1)*ray.sepol_pmz(2,:).^2) + (1./(1+snui.^2)).*(ones(length(zZi),1)*ray.sepol_pmz(3,:).^2))),1);
    