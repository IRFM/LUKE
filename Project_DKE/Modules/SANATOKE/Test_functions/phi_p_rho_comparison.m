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