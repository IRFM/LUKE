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
%keyboard
if 0,
    %epsipar = 1-wpe.*wpe-wpi.*wpi;
    %epsiperp = 1+(wpe./wce).^2-wpi.*wpi;
    %epsixy = (wpe.*wpe)./wce;
    
    ntheta = size(Kpar,2);
    x = equil.ptx(:,1)/equil.ptx(end,1);
    
    epsipar = [flipud(Kpar(:,(ntheta-1)/2));Kpar(:,1)]';%[HFS:LFS]
    epsiperp = [flipud(Kperp(:,(ntheta-1)/2));Kperp(:,1)]';%[HFS:LFS]ray
    epsixy = [flipud(Kx(:,(ntheta-1)/2));Kx(:,1)]';%[HFS:LFS]
    xna = [flipud(na(:,(ntheta-1)/2));na(:,1)]';%[HFS:LFS]
    
    xR = [flipud(equil.ptx(:,(ntheta-1)/2));equil.ptx(:,1)]'+equil.Rp;%[HFS:LFS]
    
    
    
    npar0 = abs(real(ray.sNpar(1)));%launched N||0
    %
    nnpar = 1000;
    nparmax = 10;%max N|| is 10
    M = linspace(1,nparmax,nnpar);
    x = equil.ptx(:,1)/equil.ptx(end,1);
    [MM,xx] = meshgrid(M,x);
    MM = MM';
    xx = xx';
    qq = ones(nnpar,1)*q;
    %
    P4 = ones(nnpar,1)*epsiperp;
    P2 = (ones(nnpar,1)*(epsipar + epsiperp)).*(MM.*MM - (ones(nnpar,1)*epsiperp)) + (ones(nnpar,1)*epsixy).^2;
    P0 = (ones(nnpar,1)*epsipar).*((MM.*MM - P4).^2 - (ones(nnpar,1)*epsixy).^2);
    K2 = (-P2 + sqrt(P2.*P2 - 4*P0.*P4))./P4/2 - (MM-npar0).*(MM-npar0).*qq.*qq*(Rp/ap)*(Rp/ap)./xx./xx;%electromagnetic limit
    %
    MMM = zeros(size(K2));
    MMM(K2>0) = MM(K2>0);
    clear MM K2 P0 P2 P4 xx qq
    xna = ones(nnpar,1)*na;
    mask = MMM>xna;% accessibility condition
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
end
%
%Display mode
%
figure('Name','Npar accessible');
subplot(121),graph1D_jd([flipud(R(:,(length(equil.theta)+1)/2));R(:,1)],[flipud(na(:,(length(equil.theta)+1)/2));na(:,1)],0,0,'R (m)','N_{||acc.}','Z = Z_{p}',NaN,NaN,NaN,'-','none','r',2);
grid on
subplot(122),graph2D_jd(R,Z,na','R (m)','Z (m)',strrep(equil.id,'_','-'),NaN,NaN,1,NaN,NaN,0);colorbar;hold on;
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
subplot(122),graph2D_jd(R,Z,E','R (m)','Z (m)',strrep(equil.id,'_','-'),NaN,NaN,1,NaN,NaN,0);colorbar;hold on;
subplot(122),graph2D_jd(R,Z,psin','R (m)','Z (m)',[strrep(equil.id,'_','-'),', ray #',int2str(iray)],NaN,NaN,0,NaN,NaN,0,'--','k');
c = colorbar;
c.Label.String = 'Resonant electrons, E_{c} (keV)';
axis('equal')
hold on;
graph1D_jd(ray.sx(mask)+equil.Rp,ray.sy(mask)+equil.Zp,0,0,'','','',NaN,NaN,NaN,'-','none','r',2);
hold off
%