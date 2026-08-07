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
function [IT,circB] = testAmpereLawIntegral(rhos,equil,amplitudes)
% compares the circulation of the magnetic field along a line of constant psi
% with the toroidal current encircled by this line

[~,~,~,~,~,mu0] = pc_dke_yp;

thetas = 0:pi/100:2*pi;


R = R_rho_theta(rhos,thetas,equil,amplitudes);
Z = Z_rho_theta(rhos,thetas,equil,amplitudes);
R0 = repmat(R0_rho(rhos,equil,amplitudes),1,length(thetas));
Z0 = repmat(Z0_rho(rhos,equil,amplitudes),1,length(thetas));
r = sqrt((R-R0).^2 + (Z-Z0).^2);
thetas_g = theta_geometrical_R_Z(R,Z,rhos,equil,amplitudes);
thetas_g(2:end,end) = 2*pi;
alphas = alpha_rho_theta(rhos,thetas,equil,amplitudes,thetas_g);

% circulation of B
ds = r./cos(alphas).*gradient(thetas_g);
BP = BP_rho_theta(rhos,thetas,equil,amplitudes);
circB = sum(BP.*ds,2)./mu0;

% comparison with IT
IT = IT_rho(rhos,equil);

disp('IT (MA) / circB (MA) / relative difference :');
disp(cat(2,IT./1e6,circB./1e6,abs((IT-circB)./IT)));

end
