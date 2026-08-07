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
function h = plotEquilibrium(equil,amplitudes,figure_title)
% Plots the flux surfaces describing the equilibrium

a = amplitudes(1);

theta = 0:pi/100:2*pi ;
rho = (0:a/10:a)' ;
rhos = (0:a/30:a)';

R = R_rho_theta(rho,theta,equil,amplitudes) ;
Z = Z_rho_theta(rho,theta,equil,amplitudes) ;


markersize = 12;
fontsize = 20;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name',['Equilibrium ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';

subplot(2,2,[1,3]);
for i=1:length(rho)
    hold on ;
    axis equal;
    grid minor;
    plot(R(i,:),Z(i,:),'r-','LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    xlabel('R (m)','FontSize',fontsize);
    ylabel('Z (m)','FontSize',fontsize);
    title('Flux surface geometry','FontSize',fontsize);
end

subplot(2,2,2);
plot(rhos,p_rho(rhos,equil)/1e3,'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('p (kPa)','FontSize',fontsize);
title('Plasma pressure profile','FontSize',fontsize);

subplot(2,2,4);
plot(rhos,IT_rho(rhos,equil)/1e6,'r-','LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('\rho (m)','FontSize',fontsize);
ylabel('I_T (MA)','FontSize',fontsize);
title('Toroidal current profile','FontSize',fontsize);

try
    sgtitle(figure_title,'FontSize',fontsize);
catch
end

end

