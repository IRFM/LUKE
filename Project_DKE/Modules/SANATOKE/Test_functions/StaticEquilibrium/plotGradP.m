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
function plotGradP(equil,amplitudes)
% plots the kinetic and magnetic pressure gradient profiles on the
% equatorial plane

a = equil.a;
rhos = (0:a/10:a)';

[gradP_kin_0,gradP_mag_0] = testGradP(rhos,0,equil,amplitudes);
[gradP_kin_pi,gradP_mag_pi] = testGradP(rhos,pi,equil,amplitudes);

gradP_kin = cat(1,flip(gradP_kin_pi),gradP_kin_0);
gradP_mag = cat(1,flip(gradP_mag_pi),gradP_mag_0);

R_theta0 = R_rho_theta(rhos,0,equil,amplitudes);
R_thetapi = R_rho_theta(rhos,pi,equil,amplitudes);
R_equatorial = cat(1, flip(R_thetapi),R_theta0);

figure;
plot(R_equatorial,gradP_kin,R_equatorial,gradP_mag);
%plot(R_theta0,gradP_kin_0,R_theta0,gradP_mag_0);
legend('Kinetic pressure gradient','Magnetic pressure gradient','Location','south');
title("Comparison between \nablaP_{kin} and \nablaP_{mag} on the equatorial plane (equil : "+string(equil.id)+")");
xlabel('R (m)');
ylabel('\nablaP/\nabla\rho (Pa)');

end

