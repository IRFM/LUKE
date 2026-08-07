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
function testDirichlet(equil)
% compares the otiginal plasma boundary with the boundary produced by the
% Dirichlet parameters

R_original = equil.boundary(4:2:end);
Z_original = equil.boundary(5:2:end);

dirichlet=setDirichlet(equil);
theta = 0:pi/100:2*pi ;
RZ = RZ_a(theta,dirichlet) ;

markersize = 12;
fontsize = 17;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

h = figure('Name',['Plasma boundary ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';

plot(R_original,Z_original,RZ(:,1),RZ(:,2),'LineWidth',1.5,'MarkerSize',markersize) ;
axis equal;
grid minor;
ax = gca;
ax.FontSize = 15;
legend('Original boundary','Boundary from Dirichlet','FontSize',fontsize);
xlabel('R (m)','FontSize',fontsize) ;
ylabel('Z (m)','FontSize',fontsize) ;
title('Comparison between the original boundary and the boundary calculated from Dirichlet parameters','FontSize',fontsize) ;

end

