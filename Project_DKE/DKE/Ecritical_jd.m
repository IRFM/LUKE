function xE_c = Ecritical_jd(equil,xrho)
%
% this function calculates the critical field
%
[qe,me,~,~,e0,~,~,~,clum] = pc_dke_yp;%Universal physics constants
%
plnc_e = 31.3 - 0.5*log(equil.pne) + log(equil.pTe*1000);%Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
%
pE_c = equil.pne*qe^3.*plnc_e/(4*pi*e0^2*me*clum^2);
%
if nargin < 2
    xE_c = pE_c;
else
    prho = equil.ptx(:,1)/equil.ptx(end,1);
    xE_c = interp1(prho,pE_c,xrho,'spline');
end