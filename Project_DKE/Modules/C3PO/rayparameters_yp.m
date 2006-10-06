function [R,Z,Npar,Nperp,epol_pmz,phi_xyz,D,Te,ne,zTi,zni,BP,BPHI,B,r,salpha,gradrho] = rayparameters_yp(rayparam,equil_fit,omega,rho,theta,phi,krho,m,n)
%
% Calculates ray position, Npar and Nperp 
%
% INPUT
%
% OUTPUT: 
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
dRstardpsin_ray = ppval(equil_fit.dRstardpsin_fit.pp_f,rho);
Te = ppval(equil_fit.Te_fit.pp_f,rho);
ne = ppval(equil_fit.ne_fit.pp_f,rho);
zTi = ppval(equil_fit.zTi_fit.pp_f,rho);
zni = ppval(equil_fit.zni_fit.pp_f,rho);
%
R_a0 = ppval_yp(equil_fit.R_fit.pp_a0,rho);
R_an = ppval_yp(equil_fit.R_fit.pp_an,rho);
R_bn = ppval_yp(equil_fit.R_fit.pp_bn,rho);
%
Z_a0 = ppval_yp(equil_fit.Z_fit.pp_a0,rho);
Z_an = ppval_yp(equil_fit.Z_fit.pp_an,rho);
Z_bn = ppval_yp(equil_fit.Z_fit.pp_bn,rho);
%
BR_a0 = ppval(equil_fit.BR_fit.pp_a0,rho);
BR_an = ppval(equil_fit.BR_fit.pp_an,rho);
BR_bn = ppval(equil_fit.BR_fit.pp_bn,rho);
%
BZ_a0 = ppval(equil_fit.BZ_fit.pp_a0,rho);
BZ_an = ppval(equil_fit.BZ_fit.pp_an,rho);
BZ_bn = ppval(equil_fit.BZ_fit.pp_bn,rho);
%
BPHI_a0 = ppval(equil_fit.BPHI_fit.pp_a0,rho);
BPHI_an = ppval(equil_fit.BPHI_fit.pp_an,rho);
BPHI_bn = ppval(equil_fit.BPHI_fit.pp_bn,rho);
%
R = zeros(length(rho),1);
Z = zeros(length(rho),1);
BR = zeros(length(rho),1);
BZ = zeros(length(rho),1);
BPHI = zeros(length(rho),1);
dRdtheta = zeros(length(rho),1);
dZdtheta = zeros(length(rho),1);
%
for ii = 1:length(rho),
   R(ii) = R_a0(ii) + R_an(ii,:)*cos(equil_fit.R_fit.n*theta(ii)) + R_bn(ii,:)*sin(equil_fit.R_fit.n*theta(ii));
   Z(ii) = Z_a0(ii) + Z_an(ii,:)*cos(equil_fit.Z_fit.n*theta(ii)) + Z_bn(ii,:)*sin(equil_fit.Z_fit.n*theta(ii));
   dRdtheta(ii) = -R_an(ii,:)*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta(ii))) + R_bn(ii,:)*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta(ii)));
   dZdtheta(ii) = -Z_an(ii,:)*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta(ii))) + Z_bn(ii,:)*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta(ii)));   
   BR(ii) = BR_a0(ii) + BR_an(ii,:)*cos(equil_fit.BR_fit.n*theta(ii)) + BR_bn(ii,:)*sin(equil_fit.BR_fit.n*theta(ii));
   BZ(ii) = BZ_a0(ii) + BZ_an(ii,:)*cos(equil_fit.BZ_fit.n*theta(ii)) + BZ_bn(ii,:)*sin(equil_fit.BZ_fit.n*theta(ii));
   BPHI(ii) = BPHI_a0(ii) + BPHI_an(ii,:)*cos(equil_fit.BPHI_fit.n*theta(ii)) + BPHI_bn(ii,:)*sin(equil_fit.BPHI_fit.n*theta(ii));
end
%
BP = sqrt(BR.^2 + BZ.^2);
B = sqrt(BR.^2 + BZ.^2 + BPHI.^2);
r = sqrt((R - equil_fit.Rp).^2 + (Z - equil_fit.Zp).^2);
salpha = ((R - equil_fit.Rp).*dRdtheta + (Z - equil_fit.Zp).*dZdtheta)./r./sqrt(dRdtheta.^2 + dZdtheta.^2);
calpha = sqrt(1.0 - salpha.^2);
gradrho = R.*BP.*dRstardpsin_ray/equil_fit.psia;
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
Npar = clum*(m.*calpha.*BP./r./B + n.*BPHI./R./B)./omega;
Nperp = sqrt(clum*clum*(krho.*krho.*gradrho.*gradrho/equil_fit.ap^2 - 2*krho.*m.*gradrho.*salpha./r/equil_fit.ap + (m./r).^2 + (n./R).^2)./omega./omega - Npar.^2);
%
D = zeros(length(rho),1);
epol_pmz = zeros(length(rho),3);
phi_xyz = zeros(length(rho),3);
%
for ii = 1:length(rho),
    if rayparam.tensortype == 0,
        [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk]...
            = colddisp_dke_jd(Npar(ii),omega(ii),ne(ii),zni(ii,:)',equil_fit.zZi,equil_fit.zmi,B(ii),Nperp(ii));
    else
        error('not yet implemented')
    end
%        
    N = [Nperp(ii);0;Npar(ii)];
    N2 = Npar(ii)^2+Nperp(ii)^2;
    D(ii) = det(N*N.'/N2- eye(3) + Kxyz/N2);
%    
    epol_pmz(ii,:) = ep_pmz.';
    phi_xyz(ii,:) = phip_xyz.';
end