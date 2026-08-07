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
function I = I_rho(rhos,equil,amplitudes)
% Total poloidal current

[~,~,~,~,~,mu0] = pc_dke_yp;

R0_a = equil.R0_a;
a = equil.a;
B0 = equil.B0;

% I_a = current in the toroidal field coils
I_a = 2*pi*R0_a*B0/mu0 ; 


drhos = a/200;
rrhos = (0:drhos:a)';
fun_to_int = 2./dL_rho(rrhos,equil,amplitudes).*(dphi_p_rho(rrhos,equil,amplitudes).* ...
    dIT_rho(rrhos,equil) + dV_rho(rrhos,equil,amplitudes).*dp_rho(rrhos,equil)) ;
fun_int = cumsum(fun_to_int,'reverse').*drhos;
fun_int = cat(1,fun_int(2:end),0);
I_rhos = sqrt(I_a.^2 + fun_int);
I = interp1(rrhos,I_rhos,rhos,"spline","extrap");


%{
for k=1:length(rhos)
    rho=rhos(k);
    if rho==0
        rho = 1e-10;
    end
    if rho==a
        rho = 0.9999999*a;
    end
    fun = @(x) 2./dL_rho(x,equil,a_amplitudes,boundary_amplitudes).*(dphi_p_rho(x,equil,a_amplitudes,boundary_amplitudes).* ...
        dIT_rho(x,equil) + dV_rho(x,equil,a_amplitudes,boundary_amplitudes).*dp_rho(x,equil)) ;
    
    rhos_int = linspace(rho,0.9999999999*a,100)';
    fun_to_int = fun(rhos_int);
    
    I(k) = sqrt(I_a.^2 + trapz(rhos_int,fun_to_int));
    %I(k) = sqrt(I_a.^2 + integral(@(x) fun(x),rho,a)) ;
end
%}


end

