function [na,E] = stixgolant_yp(equil,omega_lh)
%
%    Calculation of the Stix-Golant LH ray accessibility
%    
%    Input:
%
%	  - equil: equilibrium structure from equil_fit
%	  - omaga_lh : lh wave frequency = 2*pi*f (Hz)
%
%    Output:
%
%         - na: accessible refractive index on the (psi,theta) grid [npsi,mtheta]
%         - E: resonant electron energies at na (psi,theta) grid [npsi,mtheta]
%
%by Y.PEYSSON (yves.peysson@cea.fr) and J. Decker (joan.decker@epfl.ch)
%
%
[qe,me,mp,~,e0] = pc_dke_yp;%Universal physics constant
%
%Calculation of epsiperp
%
omega_cen = (qe/me).*equil.B/omega_lh;
omega_pen = qe*sqrt(equil.ne(:)*ones(1,size(equil.B,2))/e0/me)/omega_lh;
%
omega_cin = shiftdim(repmat((qe*equil.zZi./mp./equil.zmi)',1,size(equil.B,1),size(equil.B,2)),1).*repmat(equil.B,1,1,length(equil.zZi))/omega_lh;
omega_pin = shiftdim(repmat((qe*equil.zZi./sqrt(e0.*mp.*equil.zmi))',1,size(equil.B,1),size(equil.B,2)),1).*shiftdim(repmat(sqrt(equil.zni'),1,1,size(equil.B,2)),1)/omega_lh;
%
Xperp = -omega_pen.^2./(1.0 - omega_cen.^2) - sum(omega_pin.^2./(1.0 - omega_cin.^2),3);
Xpar = -omega_pen.^2 - sum(omega_pin.^2,3);
Xx = omega_pen.^2.*omega_cen./(1.0 - omega_cen.^2) + sum(omega_pin.^2.*omega_cin./(1.0 - omega_cin.^2),3);
%
Kperp = 1 + Xperp;
Kpar = 1 + Xpar;
Kx = Xx;
%
% Cold fast-slow wave conversion when P2^2 - 4*P0*P4 = 0 sets the Stix-Golant LH ray accessibility condition
%
a = (Kpar - Kperp).^2;
b = -2*Kpar.^2.*Kperp + 4*Kpar.*Kperp.^2 - 2*Kperp.^3 + 2*Kpar.*Kx.^2 + 2*Kperp.*Kx.^2;
c = Kpar.^2.*Kperp.^2 - 2*Kpar.*Kperp.^3 + Kperp.^4 + 2*Kpar.*Kperp.*Kx.^2 - 2*Kperp.^2.*Kx.^2 + Kx.^4;
%
delta = b.^2 - 4*a.*c;
%
na = sqrt((-b + sqrt(delta))./2./a);%N||acc
%
E = 511*(1.0./sqrt(1-1.0./na.^2)-1);%Energy of the resonant electrons
