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
function h = plotPlasmaBoundary(equil)
% Plots the boundaries of the plasma and verifies the accuracy of the
% computed solution

dirichlet=setDirichlet(equil);

theta = 0:pi/100:2*pi ;
RZ = RZ_a(theta,dirichlet) ;

markersize = 12;
fontsize = 20;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name',['Plasma boundary ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';

plot(RZ(:,1),RZ(:,2),'r-','LineWidth',1.5,'MarkerSize',markersize) ;
axis equal;
grid minor;
ax = gca;
ax.FontSize = 15;
xlabel('R (m)','FontSize',fontsize) ;
ylabel('Z (m)','FontSize',fontsize) ;
title('Plasma boundary','FontSize',fontsize) ;

end

