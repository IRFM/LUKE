function jt_av = jt_average_rho(rho,equil,amplitudes)

n = 200;
thetas = linspace(0,2*pi,n);

jt = jt_rho_theta(rho,thetas,equil,amplitudes);

jt_av = sum(jt,2)./n;

end