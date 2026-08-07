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
function [theta,dtheta] = relativistic_thetagrid_yp(Ec,ntheta,display_mode)
%
%	Optimal theta grid for relativistic effects (forward ellipse)
%
%	Input:
%
%		- Ec: kinetic energy of the incoming electron (keV) [1,1] 
%		- ntheta: size of theta grid [1,1] 
%       - display_mode: display grids
%
%	Output: 
%
%		- theta: non-uniform theta grid (rad) [1,ntheta]
%		- dtheta: non-uniform dtheta grid (rad) [1,ntheta]
%
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>

if nargin == 1
    %
    ntheta = 100;
    display_mode = 0;
    %
elseif nargin == 2
    %
    display_mode = 0;
    %
end
%
[~,~,~,~,~,~,~,mc2,~,~] = pc_dke_yp;%Physics constant
%
gamma = Ec/mc2 + 1;%relativistic beta
beta = sqrt(1 - 1/gamma^2);%relativistic gamma
%
a = gamma*(1+beta);
b = 1;
%
p = b^2/a;
e = sqrt(a^2 - b^2)/a;
h = b^2/sqrt(a^2 - b^2);
%
hpellipse_ramanujan = pi*(3*(a+b)- sqrt((3*a+b)*(a+3*b)))/2;%Ramanujan formula number 1 for the half ellipse perimeter
%
theta0 = linspace(0,pi,ntheta);
dtheta0 = gradient(theta0);
%
dssdtheta0 = p.*sqrt(1+e^2-2*e*cos(theta0))./(1-e*cos(theta0)).^2;%ellipse elementary arc length
ds0 = dssdtheta0.*dtheta0;
s0 = cumsimps(ds0);
hp_num = s0(end);%numerical galf ellipse perimeter
%
if abs(hp_num-hpellipse_ramanujan)/hpellipse_ramanujan > 0.01
    %
    error('Numerical ellipse perimeter is inconsistent with Ramanujan formula number 1. Number of theta points must be increased.')
    %
end
%
s = linspace(0,hp_num,ntheta);
ds = gradient(s);
%
theta = interp1(s0,theta0,s);
dtheta = gradient(theta);
%
theta = theta(:)';
dtheta = dtheta(:)';
%
if display_mode == 1
    %
    figure,plot(theta0/pi,s0,'rx',theta/pi,s,'bo',theta0/pi,hp_num*ones(size(theta0)),'k','LineWidth',2,'MarkerSize',2)
    %
    xlabel('\theta/\pi')
    ylabel('Arc length [a.u.]')
    legend('Uniform \theta grid','Uniform arc grid','Ellipse perimeter (Ramanujan #1)','Location','SouthEast')
    title(['Optimal grid for relativistic effects, Ec = ',num2str(Ec),' (keV)'])
    grid minor
    %
    figure,plot(theta0/pi,dtheta0,'rx',theta/pi,dtheta,'bo','LineWidth',2,'MarkerSize',2)
    xlabel('\theta/\pi')
    ylabel('d\theta [rad.]')
    title(['Optimal grid for relativistic effects, Ec = ',num2str(Ec),' (keV)'])
    legend('Uniform \theta grid','Uniform arc grid','Location','NorthWest')
    grid minor
    axis([0,1,0,max(dtheta)])
    %
end
