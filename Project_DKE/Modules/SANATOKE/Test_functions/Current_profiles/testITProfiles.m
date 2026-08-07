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
function testCurrentProfiles(equil)

% IT : initial profile
equil.rho_star = optimizeMatchingRadius(equil);
[amp_initial,~,quality_initial,val_initial] = computeAmplitudes(equil);
plotEquilibrium(equil,amp_initial,"Initial toroidal current profile");

IT_a = equil.current.IT.IT_a;
if ~isfield(equil,'rhos')
    equil.rhos = (0:equil.a/100:equil.a)';
end
if isfield(equil.current.IT,'alpha_j')
    equil.current.IT = rmfield(equil.current.IT,'alpha_j');
end


% IT : rho^2
equil_square = equil;
IT_square = IT_a.*(equil.rhos./equil.a).^2;
dIT_square = 2.*IT_a.*equil.rhos./equil.a.^2;
equil_square.current.IT.profile = IT_square;
equil_square.current.IT.derivative_profile = dIT_square;
equil_square.rho_star = optimizeMatchingRadius(equil_square);
[amp_square,~,quality_square,val_square] = computeAmplitudes(equil_square);
plotEquilibrium(equil_square,amp_square,'Square-like toroidal current profile');

% IT : rho
equil_linear = equil;
IT_linear = IT_a.*(equil.rhos./equil.a);
dIT_linear = IT_a./equil.a.*ones(size(equil.rhos));
equil_linear.current.IT.profile = IT_linear;
equil_linear.current.IT.derivative_profile = dIT_linear;
equil_linear.rho_star = optimizeMatchingRadius(equil_linear);
[amp_linear,~,quality_linear,val_linear] = computeAmplitudes(equil_linear);
plotEquilibrium(equil_linear,amp_linear,'Linear toroidal current profile');


% IT : sqrt(rho)
equil_sqrt = equil;
IT_square = IT_a.*sqrt(equil.rhos./equil.a);
dIT_square = IT_a./(2.*sqrt(equil.a.*equil.rhos));
dIT_square(1) = dIT_square(2)*1000;
equil_sqrt.current.IT.profile = IT_square;
equil_sqrt.current.IT.derivative_profile = dIT_square;
equil_sqrt.rho_star = optimizeMatchingRadius(equil_sqrt);
[amp_sqrt,~,quality_sqrt,val_sqrt] = computeAmplitudes(equil_sqrt);
plotEquilibrium(equil_sqrt,amp_sqrt,'Sqrt-like toroidal current profile');


% IT : binomial1
equil_binomial1 = equil;
alpha_j1 = 1;
IT_binomial1 = IT_a.*(1-(1-equil.rhos.^2./equil.a.^2).^(1+alpha_j1)) ;
dIT_binomial1 = 2.*IT_a.*(1+alpha_j1).*equil.rhos./equil.a.^2.*(1-equil.rhos.^2./equil.a.^2).^alpha_j1 ;
equil_binomial1.current.IT.profile = IT_binomial1;
equil_binomial1.current.IT.derivative_profile = dIT_binomial1;
equil_binomial1.rho_star = optimizeMatchingRadius(equil_binomial1);
[amp_binomial1,~,quality_binomial1,val_binomial1] = computeAmplitudes(equil_binomial1);
plotEquilibrium(equil_binomial1,amp_binomial1,"Binomial 1 toroidal current profile with \alpha_j = "+num2str(alpha_j1));

% IT : binomial2
equil_binomial2 = equil;
alpha_j2 = 2.5;
IT_binomial2 = IT_a.*(1-(1-equil.rhos.^2./equil.a.^2).^(1+alpha_j2)) ;
dIT_binomial2 = 2.*IT_a.*(1+alpha_j2).*equil.rhos./equil.a.^2.*(1-equil.rhos.^2./equil.a.^2).^alpha_j2 ;
equil_binomial2.current.IT.profile = IT_binomial2;
equil_binomial2.current.IT.derivative_profile = dIT_binomial2;
equil_binomial2.rho_star = optimizeMatchingRadius(equil_binomial2);
[amp_binomial2,~,quality_binomial2,val_binomial2] = computeAmplitudes(equil_binomial2);
plotEquilibrium(equil_binomial2,amp_binomial2,"Binomial 2 toroidal current profile with \alpha_j = "+num2str(alpha_j2));


disp("Quality of the solutions initial / square / linear / sqrt / binomial1 /binomial2 :");
disp([quality_initial,quality_square,quality_linear,quality_sqrt,quality_binomial1,quality_binomial2]);

disp("Objective function value of the solutions initial / square / linear / sqrt / binomial1 /binomial2 :");
disp([val_initial,val_square,val_linear,val_sqrt,val_binomial1,val_binomial2]);

disp("rho_star_opt of the solutions initial / square / linear / sqrt / binomial1 /binomial2 :");
disp([equil.rho_star,equil_square.rho_star,equil_linear.rho_star,equil_sqrt.rho_star,equil_binomial1.rho_star,equil_binomial2.rho_star]);

end

