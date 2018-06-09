function [na] = LH_acces_yp(equil,ray,mask,iray) 
%
%   Plot of a ray in the contour plot of the n Stix-Golant criterion
%    
%    Input:
%
%	  - equil: equilibrium structure
%	  - ray: ray structure
%     - mask: mask for linear absorption
%     - iray: ray index
%
%    Output:
%
%         - na: accessible refractive index on the (psi,theta) grid [npsi,mtheta]
%
%by Y.PEYSSON (yves.peysson@cea.fr) and J. Decker (joan.decker@epfl.ch)
%
if nargin < 2, error('Not enough input arguments in LH_acces_yp');end
if nargin < 3,
    mask = ones(size(ray.sx));
    iray = NaN;  
end
%
[na,E,R,Z,psin,B] = stixgolant_yp(equil,ray.omega_rf);
%
if ~isfield(equil,'consistency'),
    equil = equilconsistency_yp(equil,'',0);
end
%
[qe,me,mp,mn,e0] = pc_dke_yp;
%
Bfield = sqrt(equil.ptBx.^2 + equil.ptBy.^2 + equil.ptBPHI.^2);
%
ns = [equil.pne;equil.pzni];
qs = qe*[-1;equil.zZi(:)];    
%
ms = [me;mp*equil.zmi(:)];
%
wps = repmat(sqrt(ns.*(qs*ones(1,length(ns))).^2/e0./ms),[1,1,length(equil.theta)]);
wcs = repmat(qs,[1,length(equil.pne),length(equil.theta)]).*shiftdim(repmat(Bfield,[1,1,length(qs)]),2)./repmat(ms,[1,length(equil.pne),length(equil.theta)]);
%
ps = wps/ray.omega_rf;
ys = wcs/ray.omega_rf;
%
ys(ys.^2 == 1) = ys(ys.^2 == 1) + eps;
%
%   Dielectric tensor elements
%
Kperp = squeeze(1.0 - sum(ps.^2./(1 - ys.^2)));
Kpar = squeeze(1.0 - sum(ps.^2));
Kxy = squeeze(sum(ps.^2.*ys./(1.0 - ys.^2)));
%
ntheta = size(Kpar,2);
xR = [flipud(equil.ptx(:,(ntheta-1)/2));equil.ptx(:,1)]' + equil.Rp;%[HFS:LFS] @ Bmin
xTe = [flipud(equil.pTe(:,1));equil.pTe(:,1)]' + equil.Rp;%[HFS:LFS] @ Bmin
%
epsipar = [flipud(Kpar(:,(ntheta-1)/2));Kpar(:,1)]';%[HFS:LFS] @ Bmin
epsiperp = [flipud(Kperp(:,(ntheta-1)/2));Kperp(:,1)]';%[HFS:LFS] @ Bmin
epsixy = [flipud(Kxy(:,(ntheta-1)/2));Kxy(:,1)]';%[HFS:LFS] @ Bmin
xna = [flipud(na(:,(ntheta-1)/2));na(:,1)]';%[HFS:LFS] @ Bmin
%
npar0 = abs(real(ray.sNpar(1)));%launched N||0
%
nnpar = 10000;
nparmax = 10;%max N|| is 10
M = linspace(1,nparmax,nnpar);
x0 = equil.ptx(:,1)/equil.ptx(end,1); 
xx0 = [flipud(x0(:,1));x0(:,1)]';%[HFS:LFS] @ Bmin
[MM,xx] = meshgrid(M,xx0);
MM = MM';
xx = xx';
qq = interp1(equil.consistency.rho,equil.consistency.q,xx,'spline','extrap');
ap = equil.ptx(end,1);
%
P4 = ones(nnpar,1)*epsiperp;
P2 = (ones(nnpar,1)*(epsipar + epsiperp)).*(MM.*MM - (ones(nnpar,1)*epsiperp)) + (ones(nnpar,1)*epsixy).^2;
P0 = (ones(nnpar,1)*epsipar).*((MM.*MM - P4).^2 - (ones(nnpar,1)*epsixy).^2);
K2 = (-P2 + sqrt(P2.*P2 - 4*P0.*P4))./P4/2 - (MM-npar0).*(MM-npar0).*qq.*qq*(equil.Rp/ap)*(equil.Rp/ap)./xx./xx;%electromagnetic limit
%
MMM = zeros(size(K2));
MMM(K2>0) = MM(K2>0);
xxna = ones(nnpar,1)*xna;
maskna = MMM>xxna;% accessibility condition
MMMM = MMM.*maskna;
maxMMM = max(MMM);
MMM(MMM==0) = MMM(MMM==0) + Inf;
minMMM = min(MMM);
maxMMM(maxMMM == 0) = maxMMM(maxMMM == 0)*NaN;
minMMM(minMMM == 0) = minMMM(minMMM == 0)*NaN;
maxMMMM = max(MMMM);
MMMM(MMMM==0) = MMMM(MMMM==0) + Inf;
minMMMM = min(MMMM);
maxMMMM(maxMMMM == 0) = maxMMMM(maxMMMM == 0)*NaN;
%
boundaryMMMM = [minMMMM',maxMMMM'];
boundaryR = [xR',xR'];
%
figure,
graph1D_jd(boundaryR(:),boundaryMMMM(:),0,0,'R (m)','N_{||}','Z = Z_{p}',NaN,NaN,NaN,'none','o','k',2);
graph1D_jd(xR,6.5./sqrt(xTe),0,0,'R (m)','N_{||}','Z = Z_{p}',NaN,NaN,NaN,'-.','none','r',2);
graph1D_jd(xR,xna,0,0,'R (m)','N_{||}','Z = Z_{p}',NaN,NaN,NaN,'--','none','b',2);
legend('Propagation boundaries','N_{||Landau} = 6.5/\surd{T_e}','N_{||acc.} (Stix-Golant)')
title(['N_{||0} = ',num2str(npar0),' @ B = B_{min}'])
%
if 0,
    M = linspace(1,nparmax,nnpar);
    x0 = equil.ptx(:)'/equil.ptx(end,1); 
    [MM,xx] = meshgrid(M,x0);
    MM = MM';
    xx = xx';
    qq = interp1(equil.consistency.rho,equil.consistency.q,xx,'spline','extrap');
    ap = equil.ptx(end,1);
    %
    P4f = ones(nnpar,1)*Kperp(:)';
    P2f = (ones(nnpar,1)*(Kpar(:)' + Kperp(:)')).*(MM.*MM - (ones(nnpar,1)*Kperp(:)')) + (ones(nnpar,1)*Kxy(:)').^2;
    P0f = (ones(nnpar,1)*Kpar(:)').*((MM.*MM - P4f).^2 - (ones(nnpar,1)*Kxy(:)').^2);
    K2f = (-P2f + sqrt(P2f.*P2f - 4*P0f.*P4f))./P4f/2 - (MM-npar0).*(MM-npar0).*qq.*qq*(equil.Rp/ap)*(equil.Rp/ap)./xx./xx;%electromagnetic limit
    %
    MMM = zeros(size(K2f));
    MMM(K2f>0) = MM(K2f>0);
    xxna = ones(nnpar,1)*na(:)';
    mask = MMM>xxna;% accessibility condition
    MMMM = MMM.*mask;
    maxMMM = max(MMM);
    MMM(MMM==0) = MMM(MMM==0) + Inf;
    minMMM = min(MMM);
    maxMMM(maxMMM == 0) = maxMMM(maxMMM == 0)*NaN;
    minMMM(minMMM == 0) = minMMM(minMMM == 0)*NaN;
    maxMMMM = max(MMMM);
    MMMM(MMMM==0) = MMMM(MMMM==0) + Inf;
    minMMMM = min(MMMM);
    maxMMMM(maxMMMM == 0) = maxMMMM(maxMMMM == 0)*NaN;
    %
    figure,
    plot(equil.ptx(:)'+equil.Rp,minMMMM','b',equil.ptx(:)'+equil.Rp,maxMMMM','b');hold on
    plot(equil.ptx(:)'+equil.Rp,6.5./sqrt(equil.pte(:)'),'r-.');hold on
    plot(equil.ptx(:)'+equil.Rp,na(:)','g--');hold on
    plot(ray.sx+equil.Rp,abs(real(ray.sNpar)),'k.')

end    
%
%Display mode
%
figure('Name','Npar accessible');
subplot(121),graph1D_jd([flipud(R(:,(length(equil.theta)+1)/2));R(:,1)],[flipud(na(:,(length(equil.theta)+1)/2));na(:,1)],0,0,'R (m)','N_{||acc.}','Z = Z_{p}',NaN,NaN,NaN,'-','none','r',2);
grid on
subplot(122),graph2D_jd(R,Z,real(na'),'R (m)','Z (m)',strrep(equil.id,'_','-'),NaN,NaN,1,NaN,NaN,0);colorbar;hold on;
subplot(122),graph2D_jd(R,Z,psin','R (m)','Z (m)',[strrep(equil.id,'_','-'),', ray #',int2str(iray)],NaN,NaN,0,NaN,NaN,0,'--','k');
axis('equal')
set(gca, 'CLim', [1, max(max(na))]);
c = colorbar;
c.Label.String = 'N_{||acc.}';
hold on;
graph1D_jd(ray.sx(mask)+equil.Rp,ray.sy(mask)+equil.Zp,0,0,'','','',NaN,NaN,NaN,'-','none','r',2);
hold off
%
figure('Name','Energy of Resonant Electrons');
subplot(121),graph1D_jd([flipud(R(:,(length(equil.theta)+1)/2));R(:,1)],[flipud(E(:,(length(equil.theta)+1)/2));E(:,1)],0,0,'R (m)','Resonant fast electrons, E_{c} (keV)','Z = Z_{p}',NaN,NaN,NaN,'-','none','r',2);
grid on
subplot(122),graph2D_jd(R,Z,real(E'),'R (m)','Z (m)',strrep(equil.id,'_','-'),NaN,NaN,1,NaN,NaN,0);colorbar;hold on;
subplot(122),graph2D_jd(R,Z,psin','R (m)','Z (m)',[strrep(equil.id,'_','-'),', ray #',int2str(iray)],NaN,NaN,0,NaN,NaN,0,'--','k');
c = colorbar;
c.Label.String = 'Resonant electrons, E_{c} (keV)';
axis('equal')
hold on;
graph1D_jd(ray.sx(mask)+equil.Rp,ray.sy(mask)+equil.Zp,0,0,'','','',NaN,NaN,NaN,'-','none','r',2);
hold off
%