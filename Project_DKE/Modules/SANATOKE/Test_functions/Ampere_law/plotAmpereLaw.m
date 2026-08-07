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
function plotAmpereLaw(equil,amplitudes)

a = equil.a;
rhos = (0:a/10:a)';
thetas = [0,pi];
nthetas = length(thetas);

[IT,circB] = testAmpereLawIntegral(rhos,equil,amplitudes);

markersize = 12;
fontsize = 20;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name',['Equilibrium ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';

plot(rhos,IT./1e6,rhos,circB./1e6,'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
legend('IT','circB','FontSize',fontsize,'Location','northwest');
xlabel('\rho (m)','FontSize',fontsize);
ylabel('Toroidal current (MA)','FontSize',fontsize)
title("Test of Ampere's circuital law",'FontSize',fontsize);


[j_R,j_Z,j_phi,rotB_R,rotB_Z,rotB_phi] = testAmpereLaw(rhos,thetas,equil,amplitudes);

figure;
sgtitle("Test of local Ampere's Law rot(B) = \mu_0j ",'FontSize',fontsize);

for j=1:nthetas
    theta = thetas(j);

    subplot(nthetas,3,3*j-2);
    plot(rhos,j_R(:,j)./1e6,rhos,rotB_R(:,j)./1e6,'LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    legend('j_R','rotB_R','FontSize',17);
    xlabel('\rho (m)','FontSize',fontsize);
    ylabel('Current density (MA/m2)','FontSize',17)
    title("\theta = "+num2str(theta),'FontSize',fontsize);

    subplot(nthetas,3,3*j-1);
    plot(rhos,j_Z(:,j)./1e6,rhos,rotB_Z(:,j)./1e6,'LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    legend('j_Z','rotB_Z','FontSize',17);
    xlabel('\rho (m)','FontSize',fontsize);
    ylabel('Current density (MA/m2)','FontSize',17)
    title("\theta = "+num2str(theta),'FontSize',fontsize);

    subplot(nthetas,3,3*j);
    plot(rhos,j_phi(:,j)./1e6,rhos,rotB_phi(:,j)./1e6,'LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    legend('j_{\phi}','rotB_{\phi}','FontSize',17);
    xlabel('\rho (m)','FontSize',fontsize);
    ylabel('Current density (MA/m2)','FontSize',17)
    title("\theta = "+num2str(theta),'FontSize',fontsize);
    
end

end