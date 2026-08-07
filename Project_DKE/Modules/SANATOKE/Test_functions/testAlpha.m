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
function testAlpha(equil,amplitudes)

a = equil.a;
rhos = (a/5:a/5:a)';
thetas = 0:pi/50:2*pi;

alphas = alpha_rho_theta(rhos,thetas,equil,amplitudes);

figure;
plot(180/pi*thetas,180/pi*alphas);
legend("\rho = "+num2str(a/5),"\rho = "+num2str(2*a/5),"\rho = "+num2str(3*a/5),...
    "\rho = "+num2str(4*a/5),"\rho = "+num2str(a));
title('Angle \alpha as a function of analytical \theta');
xlabel('\theta (°)');
ylabel('\alpha (°)');

end