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
function plot_Ua_rhostar(equil)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

a = equil.a;
equill = equil;

Uas = [] ;
rho_stars=a/10:a/10:a;
for rho=rho_stars
    equill.rho_star = rho;
    amplitudes = computeAmplitudes(equill);
    Uas = cat(2,Uas,U_a(equill,amplitudes));
end

figure;
plot(rho_stars,Uas);
xlabel('rho_* (m)');
ylabel('U(a) (J)');
title('Internal energy U(a) as a function of the matching radius');

end