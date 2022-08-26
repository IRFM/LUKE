function testRhoStar(equil)

a = equil.a;
equil2 = equil;

rhos=(0:a/100:a)';
rho_stars = a/5:a/5:a;
n=length(rho_stars);
R0s = zeros(length(rhos),n); % R0s(rho_star,rho)

figure;
hold on;
for i=1:n
    equil2.rho_star = rho_stars(i);
    amp = computeAmplitudes(equil2);
    R0s(:,i)=R0_rho(rhos,equil2,amp);
    plot(rhos,R0s(:,i));
    xlabel('\rho (m)');
    ylabel('R_0(\rho) (m)');
    title('Dependance of the computed profile R_0(\rho) on the choice of \rho_*');
end

legend("\rho_* = "+rho_stars(1), "\rho_* = "+rho_stars(2), "\rho_* = "+rho_stars(3), ...
    "\rho_* = "+rho_stars(4), "\rho_* = "+rho_stars(5));

end