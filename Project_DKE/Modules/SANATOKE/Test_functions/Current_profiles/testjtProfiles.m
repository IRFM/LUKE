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
function testjtProfiles(equil,num_profile_to_test)

if nargin>1
    test_jt1 = (num_profile_to_test==1);
    test_jt2 = (num_profile_to_test==2);
    test_jt3 = (num_profile_to_test==3);
else
    test_jt1 = true;
    test_jt2 = true;
    test_jt3 = true;
end

equill = equil;
IT_a = equill.current.IT.IT_a;
a = equill.a;

if ~isfield(equill,'rhos')
    equill.rhos = (0:a/100:a)';
end
rhos = equill.rhos;
drhos = gradient(rhos);

if isfield(equill.current.IT,'alpha_j')
    equill.current.IT = rmfield(equill.current.IT,'alpha_j');
end

markersize = 12;
fontsize = 17;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

% jt1 : gaussian centered in rho=0
if test_jt1
    sig = a/3; % standard deviation
    jt1 = exp(-rhos.^2./(2.*sig.^2));
    fun_to_int1 = jt1.*rhos.*drhos;
    IT1 = cumsum(fun_to_int1);
    jt1 = IT_a./IT1(end).*jt1; % normalisation to get IT(a) = IT_a
    IT1 = IT_a./IT1(end).*IT1; 
    equil_1 = equill;
    equil_1.current.IT.profile = IT1;
    equil_1.current.IT.derivative_profile = gradient(IT1,rhos);
    equil_1.rho_star = optimizeMatchingRadius(equil_1);
    amp_1 = computeAmplitudes(equil_1);
    plotEquilibrium(equil_1,amp_1,'Toroidal surface current profile n°1');
    %plotAmplitudes(equil_1,amp_1,'Toroidal surface current profile n°1');

    h = figure('Name','jt1','Visible',visiblemode);
    h.WindowState = 'maximized';
    
    plot(rhos,jt1./1e6,'r-','LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    title('Toroidal surface current profile n°1','FontSize',fontsize);
    xlabel('\rho (m)','FontSize',fontsize);
    ylabel('j_T (MA/m^2)','FontSize',fontsize);
    
    if nargin>1
        [amps,vals,exit_conditions,exit_messages,algorithms] = analyseSolutions(equil_1);
    end
end

% jt2 : peaked at rho=0.2*a, non zero at rho=0
if test_jt2
    rho_points = 0:0.05*a:a;
    jt2_points = [0.7 0.74 0.81 0.92 1 0.985 0.92 0.83 0.72 0.6 0.49 0.4 0.32 0.25 0.2 0.16 0.13 0.10 0.08 0.06 0.05]';
    jt2 = interp1(rho_points,jt2_points,rhos,"spline","extrap");
    fun_to_int2 = jt2.*rhos.*drhos;
    IT2 = cumsum(fun_to_int2);
    jt2 = IT_a./IT2(end).*jt2; % normalisation to get IT(a) = IT_a
    IT2 = IT_a./IT2(end).*IT2; 
    equil_2 = equill;
    equil_2.current.IT.profile = IT2;
    equil_2.current.IT.derivative_profile = gradient(IT2,rhos);
    equil_2.rho_star = optimizeMatchingRadius(equil_2);
    amp_2 = computeAmplitudes(equil_2);
    plotEquilibrium(equil_2,amp_2,'Toroidal surface current profile n°2');
    %plotAmplitudes(equil_2,amp_2,'Toroidal surface current profile n°2');

    h = figure('Name','jt2','Visible',visiblemode);
    h.WindowState = 'maximized';
    
    plot(rhos,jt2./1e6,'r-','LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    title('Toroidal surface current profile n°2','FontSize',fontsize);
    xlabel('\rho (m)','FontSize',fontsize);
    ylabel('j_T (MA/m^2)','FontSize',fontsize);
    
    if nargin>1
        [amps,vals,exit_conditions,exit_messages,algorithms] = analyseSolutions(equil_2);
    end
end

% jt3 : peaked at rho=0.2*a, zero at rho=0
if test_jt3
    rho_points = 0:0.05*a:a;
    jt3_points = [0 0.25 0.55 0.9 1 0.985 0.92 0.83 0.72 0.6 0.49 0.4 0.32 0.25 0.2 0.16 0.13 0.10 0.08 0.06 0.05]';
    jt3 = interp1(rho_points,jt3_points,rhos,"spline","extrap");
    fun_to_int3 = jt3.*rhos.*drhos;
    IT3 = cumsum(fun_to_int3);
    jt3 = IT_a./IT3(end).*jt3; % normalisation to get IT(a) = IT_a
    IT3 = IT_a./IT3(end).*IT3; 
    equil_3 = equill;
    equil_3.current.IT.profile = IT3;
    equil_3.current.IT.derivative_profile = gradient(IT3,rhos);
    equil_3.rho_star = optimizeMatchingRadius(equil_3);
    amp3 = computeAmplitudes(equil_3);
    plotEquilibrium(equil_3,amp3,'Toroidal surface current profile n°3');
    %plotAmplitudes(equil_3,amp3,'Toroidal surface current profile n°3');

    h = figure('Name','jt3','Visible',visiblemode);
    h.WindowState = 'maximized';
    
    plot(rhos,jt3./1e6,'r-','LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    title('Toroidal surface current profile n°3','FontSize',fontsize);
    xlabel('\rho (m)','FontSize',fontsize);
    ylabel('j_T (MA/m^2)','FontSize',fontsize);
    
    if nargin>1
        [amps,vals,exit_conditions,exit_messages,algorithms] = analyseSolutions(equil_3);
    end
    
end

end

