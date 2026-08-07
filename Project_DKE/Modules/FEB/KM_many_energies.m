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
function [BN, ec_tensor, k_tensor, c_tensor] = KM_many_energies(ec_in, k_in, t_in, Z)
% Input variables:
% ec_in - initial kinetic energy of incoming electron in keV
% k_in - vector of values of photon energies in keV
% t_in - vector of cosines of the angle between the direction of displacement of the incoming 
% electron and the photon emitted by bremsstrahlung

% Calculation of differential cross section dsigma/(dk*dOmegak)
% as a function of photon energy k_in
% based on 1BS formula of infinitisymal cross section of Koch and Motz
% 1959 paper
r0 = 2.8179403227*10^(-13); % so-called 'classical electron radius' in centimeters
F = 0; % Atomic form factor

% Conversion to relativistic units
mc2 = 511; % Physics constant

% Creating tensor ec (3D matrix)
% ec - initial kinetic energy of incoming electron in relativistic units
% k_in(:)' - conjugate transposition of vector k_in
% length(t_in) - length of vector t_in
% ones(length(t_in),1) - creates matrix with number of rows equals
% length(t_in) and number of columns equal 1
% *ec_in - mutliplication matrix by vector ec_in
% (:)' - operation of conjugate trasposition of matrix
% /mc2 - dividing matrix by scalar mc2
% repmat (matrix_1, [1,1,length(k_in)] -create 3D matrix of matrices, 
% create 3D matrix ec of matrices matrix_1
% Treating matrix_1 in this 3D matrix as one element, than we can say
% that such kind of matrix of matrices has dimension 1x1xlength(k_in)
% (see 3D repmat example in MATLAB documentation)
ec_tensor = repmat(ones(length(t_in),1)*ec_in(:)'/mc2,[1,1,length(k_in)]);


% Creating tensor k (3D matrix) of photon energies in relativistic units
% shiftdim(matirx, 2) - changing dimensions of matrix from 1x1xlength(t_in)
% to 1xlength(t_in)x1
k_tensor = shiftdim(repmat(ones(length(ec_in),1)*k_in(:)'/mc2,[1,1,length(t_in)]),2);
if (length(ec_in) == 1) && (length(t_in) == 1)%For the case ec_in and t_in are scalars
	k_tensor = reshape(k_tensor,1,1,length(k_in));
end
% Dimensions ov vectors k and t_in=cos(theta_0) must agree
c_tensor = repmat(t_in(:)*ones(1,length(ec_in)),[1,1,length(k_in)]);

s_tensor = sqrt(1-c_tensor.^2); %sin(theta_0) calculated from trygonometric formula
% and cos(theta_0)

p0_tensor = (ec_tensor.*(ec_tensor+2)).^(1/2); %Initial momentum of electron
E0_tensor = ec_tensor + 1; %Initial total energy of electron
E_tensor = E0_tensor - k_tensor; %Final total energy of electron
p_tensor = sqrt(E_tensor.^2-1); %Final momentum of electron

BN2_loop = ones(length(t_in), length(ec_in), length(k_in));
for length_ec_in = 1 : length(ec_in)
for ndisp = 1: length(t_in)
% Taking one row from k, c, s, p0, E0, E, p
k = reshape(k_tensor(ndisp,length_ec_in,:), [1,length(k_in)]);
c = reshape(c_tensor(ndisp,length_ec_in,:), [1,length(k_in)]);
s = reshape(s_tensor(ndisp,length_ec_in,:), [1,length(k_in)]);
p0 = reshape(p0_tensor(ndisp,length_ec_in,:), [1,length(k_in)]);
E0 = reshape(E0_tensor(ndisp,length_ec_in,:), [1,length(k_in)]);
E = reshape(E_tensor(ndisp,length_ec_in,:), [1,length(k_in)]);
p = reshape(p_tensor(ndisp,length_ec_in,:), [1,length(k_in)]);

%Big formula for differential cross section from Koch, Motz 1BS
q = @(t,phi) sqrt(p.^2+p0.^2+k.^2-2*p0.*k.*c+2*p.*k*cos(t)-2*p0.*p.*(cos(t)*c+sin(t)*s*cos(phi)));
d = @(t,phi) Z^2/137*(r0/(2*pi))^2*(1-F)^2*p./(k.*p0.*(q(t,phi)).^4);
b1 = @(t,phi) p.^2.*(sin(t)).^2./(E-p.*cos(t)).^2.*(4*E0.^2-(q(t,phi)).^2);
b2 = @(t,phi) p0.^2.*s.^2./(E0-p0.*c).^2.*(4*E.^2-(q(t,phi)).^2);
b3 = @(t,phi) 2*p.*p0.*sin(t).*s.*cos(phi).*(4*E.*E0-q(t,phi).^2)./((E-p.*cos(t)).*(E0-p0.*c));
b4 = @(t,phi) 2*k.^2.*(p.^2.*sin(t).^2+p0.^2.*s.^2-2*p.*p0.*sin(t).*s.*cos(phi))./((E-p.*cos(t)).*(E0-p0.*c));
b0 = @(t,phi) b1(t,phi)+b2(t,phi)-b3(t,phi)+b4(t,phi);

%Formula of integrated function
ds = @(t,phi) d(t,phi).*b0(t,phi).*sin(t); %We take into account that dOmega_p=sint*dt*dphi

% Limits of integration
phi1 = 0;
phi2 = 2*pi;
t1 = 0;
t2 = pi;

% Integrating, Defining g as the integral of ds(t,phi)*dt*dphi from phi1 to phi2
% Default values of error tolerance"
% relative error tolerance 1e-6
% absolute error tolerance 1e-10
g = @(t) integral(@(phi) ds(t,phi) , phi1, phi2,'RelTol', 1e-6, 'AbsTol', 1e-10, 'ArrayValued', true);
BN2 = integral(@(t) g(t), t1, t2, 'ArrayValued', true,'RelTol', 1e-6, 'AbsTol', 1e-10);
BN2_loop(ndisp, length_ec_in,:) = BN2;
end
end
BN = BN2_loop;