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