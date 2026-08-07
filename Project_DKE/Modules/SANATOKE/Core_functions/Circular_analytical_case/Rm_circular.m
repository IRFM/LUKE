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
function Rm = Rm_circular(equil)
%RM_CIRCULAR Summary of this function goes here
%   Detailed explanation goes here

[~,~,~,~,~,mu0] = pc_dke_yp;

R0_a = equil.R0_a;
a = equil.a;

% Driving toroidal current profile
BP_r = @(r) mu0.*IT_rho(r,equil)./(2.*pi.*r) ;
% BP2_av_r = @(r) 2./r.^2.*integral(@(rr) rr.*BP_r(rr).^2, 0, r) ;

% Pressure profile
%P_av_r = @(r) 2./r.^2.*integral(@(r) p_rho(r,equil), 0, r) ;

% Computation by hand of the integrals
eps_r = a/1000;
list_r = (eps_r:eps_r:a)';
n_r=length(list_r);
BP2_av_r = zeros(n_r,1);
P_av_r = zeros(n_r,1);
for i=1:n_r
    r = list_r(i);
    BP2_av_r(i) = 2./r.^2.*integral(@(rr) rr.*BP_r(rr).^2, 0, r);
    P_av_r(i) = 2./r.^2.*integral(@(rr) rr.*p_rho(rr,equil), 0, r) ;
end

fun1 = @(r,i) BP2_av_r(i)./BP_r(r).^2 ;
fun2 = @(r,i) (P_av_r(i)-p_rho(r,equil))./BP_r(r).^2 ;
int1=0;
int2=0;
for i=1:n_r % i=1 corresponds to rho=eps_r, i=n_r to rho=a, and we integrate from 0 to a
    r = list_r(i);
    int1 = int1 + 2./a.^2.*r.*fun1(r,i).*eps_r;
    int2 = int2 + 2./a.^2.*r.*fun2(r,i).*eps_r;
end

% Coefficient appearing in eq 3.155 

A = 1./2 .*int1 + 2.*mu0 .*int2 ;

% Computation of Rm by the inversion of eq 3.155 evaluated at r=a
Rm = sqrt(R0_a^2+A*a^2) ;

end
