function equil = makeEquilLudwig(rho_star)
% the argument rho_star is optional and should normally not be set manually

% id
equil.id = 'Ludwig';

% Plasma boundary
equil.R0_a = 6.2;
equil.Z0_a = 0.55;
equil.a = 2;
theta = 0:pi/50:2*pi;
RZ_Ludwig = RZ_a(theta,[6.2, 0.55, 2, 1.75718, 0.109542, -0.00344217, -0.00734624, -0.00817006]);
equil.boundary = cat(2,6.2,0.55,2,reshape(RZ_Ludwig',1,2*length(theta)));

% Value of rho_star if specified
if nargin>0
    equil.rho_star = rho_star;
end

% Magnetic field at R0_a
equil.B0 = 5.3;

% Electron temperature profile
equil.temperature.electron.Te_0 = 10 ; % in keV
equil.temperature.electron.Te_a = 0 ;
equil.temperature.electron.eTe = 1.4;

% Ion temperature profile
equil.temperature.ion.Ti_0 = equil.temperature.electron.Te_0 ;
equil.temperature.ion.Ti_a = 0 ;
equil.temperature.ion.eTi = equil.temperature.electron.eTe;

% Electron density profile
equil.density.electron.ne_0 = 1e20 ;
equil.density.electron.ne_a = 0;
equil.density.electron.ene = 2*equil.temperature.electron.eTe;

% Effective charge profile (used to compute the ion density profile)
equil.Zeff.Zeff_0 = 3/2 ;
equil.Zeff.Zeff_a = 3/2 ;
equil.Zeff.eZeff = 0 ;

% Toroidal current profile
equil.current.IT.IT_a = 7.22e6; % in A
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