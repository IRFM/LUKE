% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [seBHE,seBH,Elwert,ec_out,k_out,c0_out,smodel,params] = bhe_moliere(ec_in,k_in,t0_in,Z)
%
%   Analytical differential electron-ion bremstrahlung cross-section (dsigma/dk.domegak) with Moliere's screening model (three Yukawa potentials) based
%   on the Fronsdal-Uberall fully analytical formula valid for a single exponential (C. Fronsdal and H. Uberall, Phys. Rev., 1958, 111, 2, pp. 580-586 ; 
%   E. Haug,Radiation Physics and Chemistry, 2008, 207, pp. 207-214)
%
%	Input:
%
%		- ec_in: kinetic energy of the incoming electron (keV) [1,m] 
%		- kc_in: photon energy (keV)  [1,n] 
%		- t0_in: cosine of the angle between the direction of displacement of the incoming 
%		  electron and the photon emitted by bremsstrahlung (radian) [1,p]
%		  (default = 0)
%		- Z: target ion charge (default = 1) [1,1]
%
%	Output: 
%
%		- seBHE: Bethe-Heitler + Elwert factor bremstrahlung cross-section (m^2) [p,m,n]
%		- seBH: Bethe-Heitler bremstrahlung cross-section (m^2) [p,m,n]
%		- Elwert: Elwert correction factor [p,m,n]
%		- ec_out: kinetic energy of the incoming electron (mc2) [p,m,n] 
%		- k_out: photon energy (mc2)  [p,m,n] 
%		- c0_out: cosine angle between the direction of displacement of the incoming electron and the photon emitted by bremsstrahlung (radian) [p,m,n]
%
%	Warning: Cross-section units : m^2 but energies are in relativistic units. To get 
%			 cross-sections in standard m^2/keV units, seBH or seBHe must be divided 
%			 by 511 keV.
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
if nargin < 4
	infoyp(2,'Wrong number of input arguments for bhe_moliere');
	return;
end
%
[~,~,~,~,~,~,re,mc2,~,alpha] = pc_dke_yp;%Physics constant
%
% For Elwert factor calculation (3-D) and some outputs
%
ec_out = repmat(ones(length(t0_in),1)*ec_in(:)'/mc2,[1,1,length(k_in)]);%Relativistic units
k_out = shiftdim(repmat(ones(length(ec_in),1)*k_in(:)'/mc2,[1,1,length(t0_in)]),2);%Relativistic units
if (length(ec_in) == 1) && (length(t0_in) == 1),%For the case ec_in and t_in are scalars
	k_out = reshape(k_out,1,1,length(k_in));
end
%
c0_out = repmat(t0_in(:)*ones(1,length(ec_in)),[1,1,length(k_in)]);
%
e0 = ec_out + 1; %Initial total energy of electron
p0 = sqrt(e0.^2-1);
ep = e0 - k_out; %Final total energy of electron
p = sqrt(ep.^2-1); %Final momentum of electron
%
mask = ec_out > k_out;%Photon are only emitted by electron of higher energies
%
ksi0 = alpha*Z*e0./p0;
ksi1 = alpha*Z*ep./p;
%
Elwert = (ksi1./ksi0).*((1-exp(-2*pi*ksi0))./(1-exp(-2*pi*ksi1)));%Elwert factor for Coulomb corrections
%
smodel.Z0 = [0:1:Z];
%
ds3 = permute(repmat(zeros(length(smodel.Z0),1),[1,length(ec_in),length(k_in),length(t0_in)]),[4,2,3,1]);%size(ds3)
%
Xk = {zeros(size(k)),zeros(size(k)),k};
%
Xp0 = {p0.*s0,zeros(size(p0)),p0.*c0};
%
dotkp0 = sdot(Xk,Xp0);
modp0crossk2 = smod(svec(Xp0,Xk)).^2;
modp0mk = smod(Xp0 - Xk);
%
D1 = 2*(E0.*k - dotkp0);
%
for iZ = 1:Z+1 %all ionized states  
    %
    [smodel.Z0(iZ),smodel.N(iZ),smodel.qZ(iZ),smodel.a_Z0(iZ),smodel.nff(iZ)] = fionradius_yp(Z,smodel.Z0(iZ),'moliere');
    %
    ds3(:,:,:,iZ) = a(1)*I1(a(1),b(1)) + a(2)*I1(a(2),b(2)) + a(3)*I1(a(3),b(3)) ...
    + 2*a(1)*a(2)*(I2(a(1),b(1)) - I2(a(2),b(2)))/(b(2)^2 - b(1)^2) ...
    + 2*a(1)*a(3)*(I2(a(1),b(1)) - I2(a(3),b(3)))/(b(3)^2 - b(1)^2) ...
    + 2*a(2)*a(3)*(I2(a(2),b(2)) - I2(a(3),b(3)))/(b(3)^2 - b(2)^2);
    %

end
%
mask = repmat(mask,[1,1,1,length(smodel.Z0)]);%size(mask)
Elwert = repmat(Elwert,[1,1,1,length(smodel.Z0)]);%size(mask)
%
seBH = alpha*(re/(2*pi))^2.*ds3.*mask;
%
seBHE = seBH.*Elwert;
%
seBHE(isnan(seBHE)) = 0;
%
seBHE(~isreal(seBHE)) = 0;
%
return


function I1(Xk,Xp0,E0,E,k,D1,dotkp0,modp0crossk2,modp0mk,a,b)
    %
    if a ~= 0
        %
        W = sqrt((E.*D1./k - 2 + b^2).^2 + 4.*modp0crossk2./k.^2);
        L1 = log((E0.*E1 - 1).*D1./k + E*b^2 + p.*W)./(E0.*E1 - 1).*D1./k + E*b^2 - p.*W));
        L2 = log(((modp0mk + p).^2 + b^2)./((modp0mk - p).^2 + b2));
        %
        I1_1 = 16*p*(4*E0.2 + b^2).*modp0crossk2./k.^2./W.^4;
        %
        I1_2 = 2*p.*(4*E.^2 + 2*E0.*E - E.*D1./k + b^2*(1 - 2*E.*k./D1))./W.^2;
        %
        I1_3 = 2*p.*((D1.^2 + 2*(E0.*E -1).*D1 + b^2*(D1 - 2*E.*k))./((D1 + b^2).^2 + 4*p.^2.*b^2)
              .*((16*E0.*E - 4*E.^2*b^2 - b^4)./D1 - (4*E0.^2 + b^2).*(D1.^2 + 2*(E0.*E - 1).*D1 + b^2*(D1 - 2*E.*k))./k.^2./W.^2)./W.^2;
        %
        I1_4 = (2*k.^2.*p).*(4*()./D1.^2 + (D1.^2 + 2*(E0.*E - 1).*D1 + b^2*(D1 - 2*E.*k))./D1./modp0mk.^2)./((D1 + b^2).^2 + 4*p.^2.*b^2);
        %
        I1_5 = -4*k.*log(E+p)./D1;
        %
        I1_6 = L1.*(2*k + 4*k.*(E0.^2 + p.^2 + b^2)./D1 ...
            + 2*(E0.*D1 - 2*k + b^2*k).*(8*E0.*E - D1.^2/2 - b2*(2*E0.^2+ 2*p.^2 + D1) - b^4)./D1./W.^2 ...
            + (2*(2*E0.^2 + b^2).*(D1 - 2*E.*k) + D1.^2 + 2*(E0.*E - 1).*D1)./k./W.^2) ...
            -3*(4*E0.^2 + b^2).*(e0.*D1./k - 2 + b^2).*(D1.^2 + 2*(E0.*E - 1).*D1 + b^2.*(D1 - 2*E.*k))./k./W.^4)./W;

        I1_7 = k.^2.*L2.*(2./D1 - 2 + (D1 -2*E.*k)./modp0mk.^2/2)./D1./modp0mk;
        %
        I1 = I1_1 - I1_2 + I1_3 - I1_4 + I1_5 + I1_6 + I1_7;
        %
    else
        %
        I1 = 0;
        %
    end
    %
end

function I2(Xk,Xp0,E0,E,p0,p,k,D1,dotkp0,modp0crossk2,modp0mk,a,b)
    %
    if a ~= 0
        %
        W = sqrt((E.*D1./k - 2 + b^2).^2 + 4.*modp0crossk2./k.^2);
        L1 = log((E0.*E1 - 1).*D1./k + E*b^2 + p.*W)./(E0.*E1 - 1).*D1./k + E*b^2 - p.*W));
        L2 = log(((modp0mk + p).^2 + b^2)./((modp0mk - p).^2 + b2));
        %
        I2_1 = 2*p.(4*E0.^2 + b^2).*(E0.*D1./k - 2 + b^2)./W.^2;
        I2_2 = L1.*(k.*(D1+2*b^2) +2*k.*(b^4 + 2*b^2*(E0.^2+p.^2) - 8*E0.*E)./D1 + (4*E0.^2 + b^2).*((D1 + 2*E0.*E -2).*D1 + b^2*(D1 - 2*E.*k))./k./W.^2)./W;
        I2_3 = k.^2.*L2.*(2*(4*E.^2 + b^2*(1-D1))./D1 + (D1.^2 + 2*D1.*(E0.*E - 1) +b2*(D1 - 2* E.*k))./modp0mk.^2/2)./D1./modp0mk;
        I2_4 = 4*k*b^2.*log(E+p)./D1;
        %
        I2 = -I2_1 - I2_2 - I2_3 + I2_4;
        %
    else
        %
        I2 = 0;
        %
    end
end

function [s] = sdot(X,Y)
    %
    % generalized scalar product for vectorial calculations
    %
    s = X{1}.*Y{1} + X{2}.*Y{2} + X{3}.*Y{3};
    %
end

function [s] = svec(X,Y)
    %
    % generalized vector product for vectorial calculations
    %
    s = {X{2}.*Y{3} - X{3}.*Y{2},X{3}.*Y{1} - X{1}.*Y{3},X{1}.*Y{2} - X{2}.*Y{1}};
    %
end

function [s] = smod(X)
    %
    % generalized vector module for vectorial calculations
    %
    s = sqrt(X{1}.*X{1} + X{2}.*Y{2} + X{3}.*Y{3});
    %
end


