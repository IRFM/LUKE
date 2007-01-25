function [R,Z,Npar,Nperp,epol_pmz,phi_xyz,D,Te,ne,zTi,zni,BP,BPHI,B,r,salpha,gradrho,pmode] = rayparameters_yp(rayparam,equil_fit,omega,rho,theta,phi,krho,m,n)
%
% Calculates ray position, Npar and Nperp 
%
% INPUT
%
% OUTPUT: 
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
dRstardpsin_ray = ppval(equil_fit.dxstardpsin_fit.pp_f,rho);
%
if isfield(equil_fit,'Te_fit'),Te = ppval(equil_fit.Te_fit.pp_f,rho);else Te = zeros(size(rho));end
if isfield(equil_fit,'ne_fit'),ne = ppval(equil_fit.ne_fit.pp_f,rho);else ne = zeros(size(rho));end
if isfield(equil_fit,'zTi_fit'),zTi = ppval(equil_fit.zTi_fit.pp_f,rho);else zTi = zeros(length(rho),length(equil_fit.zZi));end
if isfield(equil_fit,'zni_fit'),zni = ppval(equil_fit.zni_fit.pp_f,rho);else zni = zeros(length(rho),length(equil_fit.zZi));end
%
Rp = equil_fit.Rp;
Zp = equil_fit.Zp;
%
x_a0 = ppval_yp(equil_fit.x_fit.pp_a0,rho);
x_an = ppval_yp(equil_fit.x_fit.pp_an,rho);
x_bn = ppval_yp(equil_fit.x_fit.pp_bn,rho);
%
y_a0 = ppval_yp(equil_fit.y_fit.pp_a0,rho);
y_an = ppval_yp(equil_fit.y_fit.pp_an,rho);
y_bn = ppval_yp(equil_fit.y_fit.pp_bn,rho);
%
Bx_a0 = ppval(equil_fit.Bx_fit.pp_a0,rho);
Bx_an = ppval(equil_fit.Bx_fit.pp_an,rho);
Bx_bn = ppval(equil_fit.Bx_fit.pp_bn,rho);
%
By_a0 = ppval(equil_fit.By_fit.pp_a0,rho);
By_an = ppval(equil_fit.By_fit.pp_an,rho);
By_bn = ppval(equil_fit.By_fit.pp_bn,rho);
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
   R(ii) = Rp + x_a0(ii) + x_an(ii,:)*cos(equil_fit.x_fit.n*theta(ii)) + x_bn(ii,:)*sin(equil_fit.x_fit.n*theta(ii));
   Z(ii) = Zp + y_a0(ii) + y_an(ii,:)*cos(equil_fit.y_fit.n*theta(ii)) + y_bn(ii,:)*sin(equil_fit.y_fit.n*theta(ii));
   dRdtheta(ii) = -x_an(ii,:)*(equil_fit.x_fit.n.*sin(equil_fit.x_fit.n*theta(ii))) + x_bn(ii,:)*(equil_fit.x_fit.n.*cos(equil_fit.x_fit.n*theta(ii)));
   dZdtheta(ii) = -y_an(ii,:)*(equil_fit.y_fit.n.*sin(equil_fit.y_fit.n*theta(ii))) + y_bn(ii,:)*(equil_fit.y_fit.n.*cos(equil_fit.y_fit.n*theta(ii)));   
   BR(ii) = Bx_a0(ii) + Bx_an(ii,:)*cos(equil_fit.Bx_fit.n*theta(ii)) + Bx_bn(ii,:)*sin(equil_fit.Bx_fit.n*theta(ii));
   BZ(ii) = By_a0(ii) + By_an(ii,:)*cos(equil_fit.By_fit.n*theta(ii)) + By_bn(ii,:)*sin(equil_fit.By_fit.n*theta(ii));
   BPHI(ii) = BPHI_a0(ii) + BPHI_an(ii,:)*cos(equil_fit.BPHI_fit.n*theta(ii)) + BPHI_bn(ii,:)*sin(equil_fit.BPHI_fit.n*theta(ii));
end
%
sigmaIp =  sign(-BR(1)*sin(theta(1)) + BZ(1)*cos(theta(1)));%Sign of the plasma current
BP = sqrt(BR.^2 + BZ.^2);
B = sqrt(BR.^2 + BZ.^2 + BPHI.^2);
r = sqrt((R - Rp).^2 + (Z - Zp).^2);
salpha = ((R - Rp).*dRdtheta + (Z - Zp).*dZdtheta)./r./sqrt(dRdtheta.^2 + dZdtheta.^2);
calpha = sqrt(1.0 - salpha.^2);
gradrho = R.*BP.*dRstardpsin_ray(:)/abs(equil_fit.psia);
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
Npar = clum*(sigmaIp*m.*calpha.*BP./r./B + n.*BPHI./R./B)./omega;
Nperp = sqrt(clum*clum*(krho.*krho.*gradrho.*gradrho/equil_fit.ap^2 - 2*krho.*m.*gradrho.*salpha./r/equil_fit.ap + (m./r).^2 + (n./R).^2)./omega./omega - Npar.^2);
%
D = zeros(length(rho),1);
pmode = zeros(length(rho),1);
epol_pmz = zeros(length(rho),3);
phi_xyz = zeros(length(rho),3);
%
for ii = 1:length(rho),
    if rayparam.tensortype == 0,
        [dummy,dummy,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk]...
            = colddisp_dke_jd(Npar(ii),omega(ii),ne(ii),zni(ii,:)',equil_fit.zZi,equil_fit.zmi,B(ii),Nperp(ii));
%
        [Nperpp,Nperpm] = colddisp_dke_jd(Npar(ii),omega(ii),ne(ii),zni(ii,:)',equil_fit.zZi,equil_fit.zmi,B(ii));
%
    else
        error('not yet implemented')
    end
%        
    pmode(ii) = abs(Nperpp - Nperp(ii)) <= abs(Nperpm - Nperp(ii)); 
%
    N = [Nperp(ii);0;Npar(ii)];
    N2 = Npar(ii)^2+Nperp(ii)^2;
    D(ii) = det(N*N.'/N2- eye(3) + Kxyz/N2);
%    
    epol_pmz(ii,:) = ep_pmz.';
    phi_xyz(ii,:) = phip_xyz.';
end