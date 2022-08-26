function [BT, BP] = plotMagneticField(equil,amplitudes)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

R0_a = equil.R0_a;
a = equil.a;

rhos = (0:a/500:a)';
thetas = 0:pi/200:2*pi;

BT = BT_rho_theta(rhos,thetas,equil,amplitudes) ;
BP = BP_rho_theta(rhos,thetas,equil,amplitudes) ;
R = R_rho_theta(rhos,thetas,equil,amplitudes);
Z = Z_rho_theta(rhos,thetas,equil,amplitudes);

BP_lin = real(reshape(BP',1,numel(BP)));
BT_lin = real(reshape(BT',1,numel(BT)));
R = reshape(R',1,numel(R));
Z = reshape(Z',1,numel(Z));

% definition of a regular grid
reg_R = min(R):(max(R)-min(R))/length(rhos):max(R) ;
reg_Z = (min(Z):(max(Z)-min(Z))/length(rhos):max(Z))' ;

% interpolation of BT and BP on this grid
[reg_RT, reg_ZT, reg_BT] = griddata(R,Z,BT_lin,reg_R,reg_Z,'linear');
[reg_RP, reg_ZP, reg_BP] = griddata(R,Z,BP_lin,reg_R,reg_Z,'linear');

% plasma boundary
R_boundary = equil.boundary(4:2:end);
Z_boundary = equil.boundary(5:2:end);



% plots

markersize = 12;
fontsize = 20;
visiblemode = 'On';% 'Off' or 'On' : display or not figures on screen

%{
h = figure('Name',['BT ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
surfc(reg_RT, reg_ZT, reg_BT);
ax = gca;
ax.FontSize = 15;
title('BT','FontSize',fontsize);
xlabel('R (m)','FontSize',fontsize);
ylabel('Z (m)','FontSize',fontsize);
c= colorbar;
c.Label.String = 'Magnetic field (T)';
c.Fontsize = fontsize;

h = figure('Name',['BP ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
surfc(reg_RP, reg_ZP, reg_BP);
ax = gca;
ax.FontSize = 15;
title('BP','FontSize',fontsize);
xlabel('R (m)','FontSize',fontsize);
ylabel('Z (m)','FontSize',fontsize);
c.Fontsize = fontsize;
c.Label.String = 'Magnetic field (T)';
%}

h = figure('Name',['BT ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
contourf(reg_RT, reg_ZT, reg_BT);
ax = gca;
ax.FontSize = 15;
title('Toroidal magnetic field','FontSize',fontsize);
xlabel('R (m)','FontSize',fontsize);
ylabel('Z (m)','FontSize',fontsize);
axis equal;
c = colorbar;
c.Label.String = 'Magnetic field (T)';
c.FontSize = fontsize;
hold on;
plot(R_boundary,Z_boundary,'r');

h = figure('Name',['BP ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
contourf(reg_RP, reg_ZP, reg_BP);
ax = gca;
ax.FontSize = 15;
title('Poloidal magnetic field','FontSize',fontsize);
xlabel('R (m)','FontSize',fontsize);
ylabel('Z (m)','FontSize',fontsize);
axis equal;
c = colorbar;
c.Label.String = 'Magnetic field (T)';
c.FontSize = fontsize;
hold on;
plot(R_boundary,Z_boundary,'r');

h = figure('Name',['Phi_p ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
phi_p = phi_p_rho(rhos,equil,amplitudes);
plot(rhos,phi_p,'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
xlabel('rho (m)','FontSize',fontsize);
ylabel('Poloidal flux (Wb)','FontSize',fontsize);
title('Poloidal flux function','FontSize',fontsize);

R_theta0 = R_rho_theta(rhos,0,equil,amplitudes);
R_thetapi = R_rho_theta(rhos,pi,equil,amplitudes);
R_equatorial = cat(1, flip(R_thetapi),R_theta0);

BT_theta0 = BT_rho_theta(rhos,0,equil,amplitudes) ;
BT_thetapi = BT_rho_theta(rhos,pi,equil,amplitudes) ;
BP_theta0 = BP_rho_theta(rhos,0,equil,amplitudes) ;
BP_thetapi = BP_rho_theta(rhos,pi,equil,amplitudes) ;

BT_equatorial = cat(1,flip(BT_thetapi),BT_theta0);
BP_equatorial = cat(1,flip(BP_thetapi),BP_theta0);

h = figure('Name',['Equatorial B ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
plot(R_equatorial,BT_equatorial,R_equatorial,BP_equatorial,'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
legend('Toroidal field','Poloidal field','FontSize',fontsize);
xlabel('R (m)','FontSize',fontsize);
ylabel('Magnetic field (T)','FontSize',fontsize);
title('Magnetic field profile on the equatorial plane','FontSize',fontsize);
xline(R0_a-a,'HandleVisibility','off');
xline(R0_a+a,'HandleVisibility','off');


% plot of BP(rho=cste,theta)
h = figure('Name',['BP ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
rrhos = (a/5:a/5:a)';
tthetas = 0:pi/50:2*pi;
plot(tthetas.*180/pi,BP_rho_theta(rrhos,tthetas,equil,amplitudes),'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
title('Poloidal magnetic field on magnetic surfaces','FontSize',fontsize)
xlabel('Thetas (°)','FontSize',fontsize);
ylabel('BP (T)','FontSize',fontsize);
legend("\rho = " + num2str(a/5)+" m","\rho = " + num2str(2*a/5)+" m","\rho = " + num2str(3*a/5)+" m",...
    "\rho = " + num2str(4*a/5)+" m","\rho = " + num2str(a)+" m",'FontSize',fontsize);

% plot of B(rho=cste,theta)
h = figure('Name',['B ',char(equil.id)],'Visible',visiblemode);
h.WindowState = 'maximized';
rrhos = (a/5:a/5:a)';
tthetas = 0:pi/50:2*pi;
B = sqrt(BP_rho_theta(rrhos,tthetas,equil,amplitudes).^2+BT_rho_theta(rrhos,tthetas,equil,amplitudes).^2);
plot(tthetas.*180/pi,B,'LineWidth',1.5,'MarkerSize',markersize);
ax = gca;
ax.FontSize = 15;
title('Total magnetic field on magnetic surfaces','FontSize',fontsize)
xlabel('Thetas (°)','FontSize',fontsize);
ylabel('B (T)','FontSize',fontsize);
legend("\rho = " + num2str(a/5)+" m","\rho = " + num2str(2*a/5)+" m","\rho = " + num2str(3*a/5)+" m",...
    "\rho = " + num2str(4*a/5)+" m","\rho = " + num2str(a)+" m",'FontSize',fontsize);

end

