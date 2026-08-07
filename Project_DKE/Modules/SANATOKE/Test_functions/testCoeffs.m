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
function testCoeffs(equil)

a=equil.a;
rhos = (0:a/100:a)';
p_rhos = p_rho_input(rhos,equil);
IT_rhos = IT_rho_input(rhos,equil);

p0 = p_rhos(1);
[d2p_0, d4p_0, d6p_0, d8p_0] = pressureCoeffs(equil);
pressure = p0 + d2p_0./2.*rhos.^2 + d4p_0./24.*rhos.^4 + d6p_0./720.*rhos.^6 + d8p_0./40320.*rhos.^8;

figure;
subplot(2,1,1);
plot(rhos,p_rhos./1e3,rhos,pressure./1e3);
legend('Input profile','Profile computed at order 4 in \rho','Location','southwest');
xlabel('\rho (m)');
ylabel('Pressure (kPa)');
title('Pressure profile computed at order 6 in \rho vs input profile');

[d2IT_0, d4IT_0, d6IT_0, d8IT_0] = ITCoeffs(equil);
current = d2IT_0./2.*rhos.^2 + d4IT_0./24.*rhos.^4 + d6IT_0./720.*rhos.^6 + d8IT_0./40320.*rhos.^8;

subplot(2,1,2);
plot(rhos,IT_rhos./1e6,rhos,current./1e6);
legend('Input profile','Profile computed at order 8 in \rho','Location','northwest');
xlabel('\rho (m)');
ylabel('Toroidal current (MA)');
title('Toroidal current profile computed at order 8 in \rho vs input profile');

end

