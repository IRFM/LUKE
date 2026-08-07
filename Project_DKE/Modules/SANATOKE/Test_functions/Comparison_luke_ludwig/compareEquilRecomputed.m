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
function compareEquilRecomputed(equil,equil_rec)

rhos = linspace(0,equil.a,101)';
thetas = 0:pi/100:2*pi ;

amp = computeAmplitudes(equil);
amp_rec = computeAmplitudes(equil_rec);

% boundary comparison
dirichlet = setDirichlet(equil);
dirichlet_rec = setDirichlet(equil_rec);
RZ = RZ_a(thetas,dirichlet) ;
RZ_rec = RZ_a(thetas,dirichlet_rec);

markersize = 12;
fontsize = 20;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name',['Equilibrium ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
plot(RZ(:,1),RZ(:,2),RZ_rec(:,1),RZ_rec(:,2),'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
grid minor ;
xlabel('R (m)','FontSize',fontsize) ;
ylabel('Z (m)','FontSize',fontsize) ;
legend('Original equilibrium','Recomputed equilibrium','FontSize',fontsize);
title('Comparison of plasma boundaries','FontSize',fontsize) ;
axis equal;

% Poloidal flux profile
h = figure('Name',['Equilibrium ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
plot(rhos,phi_p_rho(rhos,equil,amp),rhos,phi_p_rho(rhos,equil_rec,amp_rec),'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
legend('Original equilibrium','Recomputed equilibrium','FontSize',fontsize);
xlabel('\rho (m)','FontSize',fontsize);
ylabel('Poloidal flux (Wb)','FontSize',fontsize);
title('Comparison of poloidal flux profiles','FontSize',fontsize);

% Pressure and current profiles
h = figure('Name',['Equilibrium ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
sgtitle('Comparison of pressure and current profiles','FontSize',fontsize);

subplot(2,1,1)
plot(rhos,p_rho(rhos,equil)/.1e3,rhos,p_rho(rhos,equil_rec)/.1e3,'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
legend('Original equilibrium','Recomputed equilibrium','FontSize',fontsize);
xlabel('\rho (m)','FontSize',fontsize);
ylabel('Pressure (kPa)','FontSize',fontsize);
title('Plasma pressure profile','FontSize',fontsize);

subplot(2,1,2)
plot(rhos,IT_rho(rhos,equil)/1e6,rhos,IT_rho(rhos,equil_rec)/1e6,'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
legend('Original equilibrium','Recomputed equilibrium',"Location","northwest",'FontSize',fontsize);
xlabel('\rho (m)','FontSize',fontsize);
ylabel('Toroidal current (MA)','FontSize',fontsize);
title('Toroidal current profile','FontSize',fontsize);

% Flux surfaces
plotEquilibrium(equil,amp,"Original equilibrium");
plotEquilibrium(equil_rec,amp_rec,"Recomputed equilibrium");

disp(' '); disp(' ');
disp("Comparison of key parameters of the two equilibria : ");

% geometrical inputs
disp("Geometrical centre (R_0(a) ; Z_0(a)) : ("+num2str(equil.R0_a)+" ; "+num2str(equil.Z0_a)+")  /  ("+num2str(equil_rec.R0_a)+" ; "+num2str(equil_rec.Z0_a)+")");
disp("Minor radius a (m) : "+num2str(equil.a)+"  /  "+num2str(equil_rec.a));

% amplitudes comparison
disp("Magnetic axis position (R_m ; Z_m) : ("+num2str(amp(2))+" ; "+num2str(amp(5))+")  /  ("+num2str(amp_rec(2))+" ; "+num2str(amp_rec(5))+")");
disp("Elongation \kappa_m : "+num2str(amp(8))+"  /  "+num2str(amp_rec(8)));
disp("Relative difference between amplitudes : "+num2str(abs((amp-amp_rec)./amp)));

% Toroidal magnetic field at the geometric center 
disp("Toroidal magnetic field at the geometric center B_0 (T) : "+num2str(equil.B0)+"  /  "+num2str(equil_rec.B0));
disp("Remark : the recomputed value of B0 is logically greater than the original one : the original B0 is indeed used as the toroidal field created by external coils only, whereas the recomputed B0 is the actual toroidal field at the geometrical center (ie. created by external coils AND by the plasma itself)");

% Value of rho_star
disp("Value of the optimum matching radius (m) : "+num2str(equil.rho_star)+"  /  "+num2str(equil_rec.rho_star));

end