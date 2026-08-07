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
function plotStaticEquilibrium(equil,amplitudes)

a = equil.a;
rhos = (0:a/30:a)';
thetas = [pi/4,5*pi/4];
nthetas = length(thetas);

[gradP_R,jxB_R,gradP_Z,jxB_Z] = testStaticEquilibrium(rhos,thetas,equil,amplitudes);

markersize = 12;
fontsize = 20;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name',['Equilibrium ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';

sgtitle('Comparison of kinetic and magnetic pressure gradients','FontSize',fontsize);

for j=1:nthetas
    theta = thetas(j);

    subplot(nthetas,2,2*j-1);
    plot(rhos,gradP_R(:,j)./1e3,rhos,jxB_R(:,j)./1e3,'LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    legend('\nablaP along R','jxB along R','FontSize',fontsize);
    xlabel('\rho (m)','FontSize',fontsize);
    ylabel('Pressure gradient (kPa/m)','FontSize',fontsize)
    title("Test of static equilibrium at \theta = "+num2str(theta),'FontSize',fontsize);

    subplot(nthetas,2,2*j);
    plot(rhos,gradP_Z(:,j)./1e3,rhos,jxB_Z(:,j)./1e3,'LineWidth',1.5,'MarkerSize',markersize);
    ax = gca;
    ax.FontSize = 15;
    legend('\nablaP along Z','jxB along Z','FontSize',fontsize);
    xlabel('\rho (m)','FontSize',fontsize);
    ylabel('Pressure gradient (kPa/m)','FontSize',fontsize)
    title("Test of static equilibrium at \theta = "+num2str(theta),'FontSize',fontsize);
end

end