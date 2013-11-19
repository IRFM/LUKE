function [x,y,Npar,Nperp,epol_pmz,phi_xyz,D,Te,ne,zTi,zni,Brho,BP,Bz,B,r,salpha,gradrho,Upsilon,pmode,wpe2,wce2] = rayparameters_yp(rayparam,equil_fit,fluct_fit,omega,rho,theta,z,krho,m,kz)
%
% Calculates ray position, Npar and Nperp 
%
% INPUT
%
% OUTPUT: 
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
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
Bz_a0 = ppval(equil_fit.Bz_fit.pp_a0,rho);
Bz_an = ppval(equil_fit.Bz_fit.pp_an,rho);
Bz_bn = ppval(equil_fit.Bz_fit.pp_bn,rho);
%
BP_a0 = ppval(equil_fit.BP_fit.pp_a0,rho);
BP_an = ppval(equil_fit.BP_fit.pp_an,rho);
BP_bn = ppval(equil_fit.BP_fit.pp_bn,rho);
%
B_a0 = ppval(equil_fit.B_fit.pp_a0,rho);
B_an = ppval(equil_fit.B_fit.pp_an,rho);
B_bn = ppval(equil_fit.B_fit.pp_bn,rho);
%
r_a0 = ppval(equil_fit.r_fit.pp_a0,rho);
r_an = ppval(equil_fit.r_fit.pp_an,rho);
r_bn = ppval(equil_fit.r_fit.pp_bn,rho);
%
calpha_a0 = ppval(equil_fit.calpha_fit.pp_a0,rho);
calpha_an = ppval(equil_fit.calpha_fit.pp_an,rho);
calpha_bn = ppval(equil_fit.calpha_fit.pp_bn,rho);
%
salpha_a0 = ppval(equil_fit.salpha_fit.pp_a0,rho);
salpha_an = ppval(equil_fit.salpha_fit.pp_an,rho);
salpha_bn = ppval(equil_fit.salpha_fit.pp_bn,rho);
%
gradrho_a0_fit = ppval(equil_fit.gradrho_fit.pp_a0,xrho);
gradrho_an_fit = ppval(equil_fit.gradrho_fit.pp_an,xrho);
gradrho_bn_fit = ppval(equil_fit.gradrho_fit.pp_bn,xrho);
%
x = zeros(length(rho),1);
y = zeros(length(rho),1);
%
r = zeros(length(rho),1);
%
calpha = zeros(length(rho),1);
salpha = zeros(length(rho),1);
gradrho = zeros(length(rho),1);
%
Bx = zeros(length(rho),1);
By = zeros(length(rho),1);
Bz = zeros(length(rho),1);
%
Brho = zeros(length(rho),1);
BP = zeros(length(rho),1);
B = zeros(length(rho),1);
%
for ii = 1:length(rho),
   x(ii) = x_a0(ii) + x_an(ii,:)*cos(equil_fit.x_fit.n*theta(ii)) + x_bn(ii,:)*sin(equil_fit.x_fit.n*theta(ii));
   y(ii) = y_a0(ii) + y_an(ii,:)*cos(equil_fit.y_fit.n*theta(ii)) + y_bn(ii,:)*sin(equil_fit.y_fit.n*theta(ii));
   %
   r(ii) = r_a0(ii) + r_an(ii,:)*cos(equil_fit.r_fit.n*theta(ii)) + r_bn(ii,:)*sin(equil_fit.r_fit.n*theta(ii));
   %
   calpha(ii) = calpha_a0(ii) + calpha_an(ii,:)*cos(equil_fit.calpha_fit.n*theta(ii)) + calpha_bn(ii,:)*sin(equil_fit.calpha_fit.n*theta(ii));
   salpha(ii) = salpha_a0(ii) + salpha_an(ii,:)*cos(equil_fit.salpha_fit.n*theta(ii)) + salpha_bn(ii,:)*sin(equil_fit.salpha_fit.n*theta(ii));
   gradrho(ii) = gradrho_a0(ii) + gradrho_an(ii,:)*cos(equil_fit.gradrho_fit.n*theta(ii)) + gradrho_bn(ii,:)*sin(equil_fit.gradrho_fit.n*theta(ii));
   %
   Bx(ii) = Bx_a0(ii) + Bx_an(ii,:)*cos(equil_fit.Bx_fit.n*theta(ii)) + Bx_bn(ii,:)*sin(equil_fit.Bx_fit.n*theta(ii));
   By(ii) = By_a0(ii) + By_an(ii,:)*cos(equil_fit.By_fit.n*theta(ii)) + By_bn(ii,:)*sin(equil_fit.By_fit.n*theta(ii));
   Bz(ii) = Bz_a0(ii) + Bz_an(ii,:)*cos(equil_fit.Bz_fit.n*theta(ii)) + Bz_bn(ii,:)*sin(equil_fit.Bz_fit.n*theta(ii));
   %
   BP(ii) = BP_a0(ii) + BP_an(ii,:)*cos(equil_fit.BP_fit.n*theta(ii)) + BP_bn(ii,:)*sin(equil_fit.BP_fit.n*theta(ii));
   B(ii) = B_a0(ii) + B_an(ii,:)*cos(equil_fit.B_fit.n*theta(ii)) + B_bn(ii,:)*sin(equil_fit.B_fit.n*theta(ii));
end
%
if isinf(equil_fit.Rp),
    Upsilon = 1.0;
else
    Upsilon = 1 + x/equil_fit.Rp;%toroidal factor (1 -> cylindrical limit)
end
%
Bs = BP;%Bs is always positive by definition
%
if exist('fluct_fit'),
    if isstruct(fluct_fit),
        for ii = 1:length(rho),
            [fluctval] = fluctval_yp(equil_fit,fluct_fit,rho(ii),theta(ii),phi(ii)); 
            %
            ne(ii) = ne(ii) + ne(ii)*fluctval.ner;
            Te(ii) = Te(ii) + Te(ii)*fluctval.Ter;
            zni(ii,:) = zni(ii,:) + zni(ii,:).*fluctval.znir;
            zTi(ii,:) = zTi(ii,:) + zTi(ii,:).*fluctval.zTir;
            %
            cta = cos(theta(ii)).*calpha(ii) + sin(theta(ii)).*salpha(ii);
            sta = -cos(theta(ii)).*salpha(ii) + sin(theta(ii)).*calpha(ii);
            %
            Brho(ii) = Brho(ii) + B(ii)*(cta*fluctval.Bxr + sta*fluctval.Byr);%normalized to unperturbed magnetic equilibrium
            Bs(ii) = Bs(ii) + B(ii)*(cta*fluctval.Byr - sta*fluctval.Bxr);%normalized to unperturbed magnetic equilibrium            
            Bz(ii) = Bz(ii) + B(ii)*fluctval.Bzr;%normalized to unperturbed magnetic equilibrium
            %
            B(ii) = sqrt(Brho(ii).^2 + Bs(ii).^2 + Bz(ii).^2);%perturbed magnetic field
            %
        end
       %
    end
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
Npar = clum*(krho.*krho.*gradrho.*gradrho.*Brho./B + m.*(calpha.*Bs./B - salpha.*Brho./B)./r + kz.*Bz./Upsilon./B)./omega;
Nperp = sqrt(clum*clum*(krho.*krho.*gradrho.*gradrho - 2*krho.*m.*gradrho.*salpha./r + (m./r).^2 + (kz./Upsilon).^2)./omega./omega - Npar.^2);
%
D = zeros(length(rho),1);
pmode = zeros(length(rho),1);
epol_pmz = zeros(length(rho),3);
phi_xyz = zeros(length(rho),3);
wpe2 = zeros(length(rho),1);
wce2 = zeros(length(rho),1);
%
for ii = 1:length(rho),
    if rayparam.tensortype == 0,
        [dummy,dummy,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk,sigmap,sigmam,Dp,Dm,ps,ys]...
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
    %
    wpe2(ii) = ps(1)^2;
    wce2(ii) = ys(1)^2;
end