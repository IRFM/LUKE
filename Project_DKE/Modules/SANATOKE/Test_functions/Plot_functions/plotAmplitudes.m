function h = plotAmplitudes(equil,amplitudes,figure_title)

a = equil.a;
rhos=(0:a/100:a)';
thetas=-pi:pi/40:pi;
rho_star=equil.rho_star;

markersize = 12;
fontsize = 17;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name',['Amplitudes ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';

sgtitle('Profiles of the poloidal flux and the main Fourier amplitudes','FontSize',20);

subplot(4,2,1);
plot(rhos,phi_p_rho(rhos,equil,amplitudes),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('\Phi_p(\rho) (Wb)','FontSize',fontsize);

subplot(4,2,2);
plot(rhos,R0_rho(rhos,equil,amplitudes),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('R_0(\rho) (m)','FontSize',fontsize);
xline(rho_star,'k--','FontSize',fontsize);

subplot(4,2,3);
plot(rhos,Z0_rho(rhos,equil,amplitudes),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('Z_0(\rho) (m)','FontSize',fontsize);
xline(rho_star,'k--','FontSize',fontsize);

subplot(4,2,4);
plot(rhos,e_rho(rhos,equil,amplitudes),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('e(\rho)','FontSize',fontsize);
xline(rho_star,'k--','FontSize',fontsize);

subplot(4,2,5);
plot(rhos,S2_rho(rhos,equil,amplitudes),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('S_2(\rho)','FontSize',fontsize);
xline(rho_star,'k--','FontSize',fontsize);

subplot(4,2,6)
plot(rhos,A2_rho(rhos,equil,amplitudes),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('A_2(\rho)','FontSize',fontsize);
xline(rho_star,'k--','FontSize',fontsize);

subplot(4,2,7);
plot(rhos,S3_rho(rhos,equil,amplitudes),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('S_3(\rho)','FontSize',fontsize);
xline(rho_star,'k--','FontSize',fontsize);

subplot(4,2,8);
plot(rhos,A3_rho(rhos,equil,amplitudes),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('A_3(\rho)','FontSize',fontsize);
xline(rho_star,'k--','FontSize',fontsize);

%{
subplot(5,2,[9,10]);
plot(thetas,KT_rho_theta(a/4,thetas,equil,amplitudes)/1e6,thetas,KT_rho_theta(a/2,thetas,equil,amplitudes)/1e6,...
    thetas,KT_rho_theta(3*a/4,thetas,equil,amplitudes)/1e6,thetas,KT_rho_theta(a,thetas,equil,amplitudes)/1e6,...
    thetas,KT_rho_theta(rho_star,thetas,equil,amplitudes)/1e6,'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\theta (rad)','FontSize',fontsize);
ylabel('KT(\rho,\theta) (MA/m)','FontSize',fontsize);
legend('\rho = a/4','\rho = a/2','\rho = 3*a/4','\rho = a','\rho = \rho_*','Location','eastoutside');
xlim([-pi,pi]);
%}

try
    sgtitle(figure_title);
catch
end

end