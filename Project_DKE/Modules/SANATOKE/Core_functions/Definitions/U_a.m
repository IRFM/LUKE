function Ua = U_a(equil,amplitudes)
% Computation of the internal energy

a = equil.a;
n = 500;
rho = linspace(1e-10,equil.a,n+1)';

fun = IT_rho(rho,equil)./(2.*K_rho(rho,equil,amplitudes)).*(IT_rho(rho,equil)+2.*L_rho(rho,equil,amplitudes)...
    ./dL_rho(rho,equil,amplitudes).*dIT_rho(rho,equil)) + dV_rho(rho,equil,amplitudes).*(p_rho(rho,equil)+...
    L_rho(rho,equil,amplitudes)./dL_rho(rho,equil,amplitudes).*dp_rho(rho,equil)) ;

Ua = a./n.*sum(fun(1:end));

end