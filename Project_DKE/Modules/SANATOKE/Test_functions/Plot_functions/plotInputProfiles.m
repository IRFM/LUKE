function h = plotInputProfiles(equil)

rhos = (0:equil.a/100:equil.a)';

markersize = 12;
fontsize = 20;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name',['Input profiles ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';

sgtitle('Input profiles','FontSize',fontsize);

subplot(2,2,1)
plot(rhos,Te_rho(rhos,equil),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
title('Electron temperature profile','FontSize',fontsize);
xlabel('\rho (m)','FontSize',fontsize);
ylabel('Temperature (keV)','FontSize',fontsize);

subplot(2,2,2)
plot(rhos,ne_rho(rhos,equil),'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
title('Electron density profile','FontSize',fontsize);
xlabel('\rho (m)','FontSize',fontsize);
ylabel('Density (/m³)','FontSize',fontsize);

subplot(2,2,3)
plot(rhos,p_rho(rhos,equil)/1e3,'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('Pressure (kPa)','FontSize',fontsize);
title('Plasma pressure profile','FontSize',fontsize);

subplot(2,2,4)
plot(rhos,IT_rho(rhos,equil)/1e6,'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('Toroidal current (MA)','FontSize',fontsize);
title('Toroidal current profile','FontSize',fontsize);

end

