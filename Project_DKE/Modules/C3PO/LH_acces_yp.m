function [na] = LH_acces_yp(equil,wave,iray) 
%
%    Calculation of the Stix-Golant LH ray accessibility and plot of a ray in the contour plot
%    
%    Input:
%
%	  - equil: equilibrium structure
%	  - wave: wave structure
%     - iray: ray index
%
%    Output:
%
%         - na: accessible refractive index on the (psi,theta) grid [npsi,mtheta]
%
%by Y.PEYSSON (yves.peysson@cea.fr) and J. Decker (joan.decker@epfl.ch)
%
if nargin < 2, error('Not enough input arguments in LH_acces_yp');end
%
[qe,me,mp,~,e0] = pc_dke_yp;%Universal physics constant
%
R = equil.Rp + equil.ptx;
Z = equil.Zp + equil.pty;
B = sqrt(equil.ptBPHI.^2 + equil.ptBx.^2 + equil.ptBy.^2);%magnetic field
psin = equil.psi_apRp(:)*ones(1,length(equil.theta))/equil.psi_apRp(end);%normal poloidal mahnetic flux
%
%Calculation of epsiperp
%
omega_lh = wave.omega_rf;%rad/s
omega_cen = (qe/me).*B/omega_lh;
omega_pen = qe*sqrt(equil.pne(:)*ones(1,length(equil.theta))/e0/me)/omega_lh;
omega_cin = shiftdim(repmat((qe*equil.zZi./mp./equil.zmi)',1,length(equil.psi_apRp),length(equil.theta)),1).*repmat(B,1,1,length(equil.zZi))/omega_lh;
omega_pin = shiftdim(repmat((qe*equil.zZi./sqrt(e0.*mp.*equil.zmi))',1,length(equil.psi_apRp),length(equil.theta)),1).*shiftdim(repmat(sqrt(equil.pzni),1,1,length(equil.theta)),1)/omega_lh;
%
Xperp = -omega_pen.^2./(1.0 - omega_cen.^2) - sum(omega_pin.^2./(1.0 - omega_cin.^2),3);
Xpar = -omega_pen.^2 - sum(omega_pin.^2,3);
Xx = omega_pen.^2.*omega_cen./(1.0 - omega_cen.^2) + sum(omega_pin.^2.*omega_cin./(1.0 - omega_cin.^2),3);
%
Kperp = 1 + Xperp;
Kpar = 1 + Xpar;
Kx = Xx;
%
% Cold fast-slow wave conversion when P2^2 - 4P0P4 = 0 sets the Stix-Golant LH ray accessibility condition
%
a = (Kpar + Kperp).^2 - 4*Kpar.*Kperp;
b = 8*Kpar.*Kperp.^2 - 2*Kperp.*(Kpar + Kperp).^2 + 2*(Kpar + Kperp).*Kx.^2; 
c = -4*Kpar.*Kperp.^3 + Kperp.^2.*(Kpar + Kperp).^2 + 4*Kpar.*Kperp.*Kx.^2 - 2*Kperp.*(Kpar + Kperp).*Kx.^2 + Kx.^4;
delta = b.^2 - 4*a.*c;
%
na = sqrt((-b + sqrt(delta))./2./a);%N||acc
%
E = 511*(1.0./sqrt(1-1.0./na.^2)-1);%Energy of the resonant electrons
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
if ~isnan(iray),
	hold on;
    graph1D_jd(wave.rays{iray}.sx+equil.Rp,wave.rays{iray}.sy+equil.Zp,0,0,'','','',NaN,NaN,NaN,'-','none','r',2);
    hold off
end
%
figure('Name','Energy of Resonant Electrons');
subplot(121),graph1D_jd([flipud(R(:,(length(equil.theta)+1)/2));R(:,1)],[flipud(E(:,(length(equil.theta)+1)/2));E(:,1)],0,0,'R (m)','Resonant fast electrons, E_{c} (keV)','Z = Z_{p}',NaN,NaN,NaN,'-','none','r',2);
grid on
subplot(122),graph2D_jd(R,Z,E','R (m)','Z (m)',strrep(equil.id,'_','-'),NaN,NaN,1,NaN,NaN,0);colorbar;hold on;
subplot(122),graph2D_jd(R,Z,psin','R (m)','Z (m)',[strrep(equil.id,'_','-'),', ray #',int2str(iray)],NaN,NaN,0,NaN,NaN,0,'--','k');
c = colorbar;
c.Label.String = 'Resonant electrons, E_{c} (keV)';
axis('equal')
if ~isnan(iray),
	hold on;
    graph1D_jd(wave.rays{iray}.sx+equil.Rp,wave.rays{iray}.sy+equil.Zp,0,0,'','','',NaN,NaN,NaN,'-','none','r',2);
    hold off
end
%
