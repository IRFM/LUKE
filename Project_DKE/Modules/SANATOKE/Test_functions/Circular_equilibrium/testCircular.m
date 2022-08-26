function testCircular(equil,amplitudes)

a = equil.a;
R0_a = equil.R0_a;

% Comparison of boundaries

thetas = 0:pi/100:2*pi;
R_input = equil.boundary(4:2:end);
Z_input = equil.boundary(5:2:end);
R_boundary = R_rho_theta(a,thetas,equil,amplitudes);
Z_boundary = Z_rho_theta(a,thetas,equil,amplitudes);
boundary2 = RZ_a(thetas,setDirichlet(equil));
R_boundary2 = boundary2(:,1)';
Z_boundary2 = boundary2(:,2)';

markersize = 12;
fontsize = 20;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name',['Boundaries ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
ax = gca;
ax.FontSize = 15;
plot(R_boundary,Z_boundary,R_boundary2,Z_boundary2,R_input,Z_input,'LineWidth',1.5,'MarkerSize',markersize);
title('Boundary','FontSize',fontsize);
xlabel('R (m)','FontSize',fontsize);
ylabel('Z (m)','FontSize',fontsize);
legend('R,Z(\rho=a,\theta)','RZ(a)','Input','FontSize',fontsize);
axis equal;


% Comparison of R0(rho)

rhos = (0:a/50:a)';
R0_analytic = R0_rho_circular(rhos,equil);

h = figure('Name',['R0_rho ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
plot(rhos,R0_analytic,rhos,R0_rho(rhos,equil,amplitudes),'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
legend('R_{0,ana}(\rho)','R_{0,sim}(\rho)','FontSize',fontsize);
xlabel('\rho (m)','FontSize',fontsize);
ylabel('R_0(\rho) (m)','FontSize',fontsize);
title("Analytic and simulated profile of R_0(\rho) for a circular plasma boundary and a aspect ratio of " + num2str(R0_a/a),'FontSize',fontsize);

disp("Shafranov shift computed by this code : " + num2str(amplitudes(2)-R0_a) + " m");
disp("Shafranov shift computed theoreticaly : " + num2str(Rm_circular(equil)-R0_a) + " m");

end

