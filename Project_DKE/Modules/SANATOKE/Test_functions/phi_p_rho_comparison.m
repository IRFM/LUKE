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
function phi_p_rho_comparison(equil,amplitudes)

a=equil.a;

rhos=(0:a/50:a)';
phi_p_list=zeros(size(rhos));
sum=0;
for i=2:length(rhos)
    sum=sum+a./(length(rhos)-1).*IT_rho(rhos(i),equil)./K_rho(rhos(i),equil,amplitudes);
    phi_p_list(i)=sum;
end

plot(rhos,phi_p_rho(rhos,equil,amplitudes),rhos,phi_p_list);
xlabel('\rho (m)');
ylabel('\Phi_p (Wb)');
legend('\Phi_p coeffs','\Phi_p = int(IT/K)','Location','northwest');
title('Poloidal flux profile');

figure;
plot(rhos,phi_p_rho(rhos,equil,amplitudes)./phi_p_list);
title('Ratio Phi_p coeffs over Phi_p int(IT/K)');

end