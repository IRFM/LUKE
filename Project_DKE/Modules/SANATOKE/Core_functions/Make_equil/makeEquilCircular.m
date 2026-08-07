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
function equil = makeEquilCircular(R0_a,Z0_a,a,rho_star)
% the argument rho_star is optional and should normally not be set manually
% the 3 geometrical arguments are optional too, defaut values are the 
% following : R0_a = 3 m (major radius) ; Z0_a = 0 ; a = 1 m (minor radius)

if nargin==0
    R0_a = 3;
    Z0_a = 0;
    a = 1;
end

% id
equil.id = "Circular R_0/a = "+num2str(R0_a/a);

% Plasma boundary
equil.R0_a = R0_a;
equil.Z0_a = Z0_a;
equil.a = a;
theta = 0:pi/100:2*pi;
R = R0_a + a.*cos(theta)+a./100.*(rand(size(theta))-0.5);
Z = Z0_a + a.*sin(theta)+a./100.*(rand(size(theta)));
points = reshape(cat(1,R,Z),1,2*length(theta));
equil.boundary = cat(2,R0_a,Z0_a,a,points);

% Value of rho_star if specified
if nargin>3
    equil.rho_star = rho_star;
end

% Magnetic field at R0_a
equil.B0 = 5.3;

% Effective charge profile
equil.Zeff.Zeff_0 = 3/2 ;
equil.Zeff.Zeff_a = 3/2 ;
equil.Zeff.eZeff = 0 ;

% Temperature profile
equil.temperature.electron.Te_0 = 10 ; % in keV
equil.temperature.electron.Te_a = 0 ;
equil.temperature.electron.eTe = 1.4;
equil.temperature.ion.Ti_0 = equil.temperature.electron.Te_0 ;
equil.temperature.ion.Ti_a = 0 ;
equil.temperature.ion.eTi = equil.temperature.electron.eTe;

% Density profile
equil.density.electron.ne_0 = 1e20 ;
equil.density.electron.ne_a = 0;
equil.density.electron.ene = 2*equil.temperature.electron.eTe; % factor 2 in Ludwig's profile

% Toroidal current profile
equil.current.IT.IT_a = 7.22e6; % in A, not MA
equil.current.IT.alpha_j = 3/2*equil.temperature.electron.eTe;

% value of rho_star if not specified
if ~isfield(equil,'rho_star')
    [rho_star,has_converged] = optimizeMatchingRadius(equil);
    if has_converged
        equil.rho_star = rho_star;
    else
        equil.rho_star = 0.7*a ; % arbitrary default value for rho_star
        warning('No maximum in rho_star has been found for the internal energy, a default value is taken. Therefore, the computed solution will not be reliable.');
    end
end

end