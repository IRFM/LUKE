% IMAS read WEST equilibrium remotely

close all
clear all
clc

% IMAS parameters
shot    = 52702;
time_requested = 10;% real : relative to ignitron time, imag : absolute time
run     = 0;
occ     = 1;
user    = 'imas_public';
machine = 'west';

% Other parameters
Z_for_R_plot     = 30; % Z position for 1D plot in cartesian grid
Font_size_graphs = 14;

% Prints
fprintf('shot       = %d \n', shot);
fprintf('run        = %d \n', run);
fprintf('occurrence = %d \n', occ);
fprintf('user       = %s \n', user);
fprintf('machine    = %s \n', machine);

% Open IMAS file: function imas_west_get(shot, ids_name, run, occ, user, machine)

[equi]= remote_ids_get_slice(shot,'equilibrium',time_requested,run,occ,user,machine);

% Filter no converged equilibrium computations
mask_eq = equi.code.output_flag >= 0;

% Time index for plots
ind_mid = round(0.5*length(equi.time_slice{1}.time(mask_eq)));

% Plot data
fig1 = figure(1);

subplot(2, 2, 1);

rho_tor = equi.time_slice{1}.profiles_1d.rho_tor(mask_eq, :);
q       = equi.time_slice{1}.profiles_1d.q(mask_eq, :);
plot(rho_tor(ind_mid, :), q(ind_mid, :), '-o', 'LineWidth', 1.5);

grid on;
set(gca, 'FontSize', Font_size_graphs);
xlabel('Rho_{tor} [m]', 'FontSize', Font_size_graphs);
ylabel('q', 'FontSize', Font_size_graphs);


subplot(2, 2, 2);
b_field_r   = equi.time_slice{1}.interp2D.b_field_r(mask_eq, :, :);
b_field_z   = equi.time_slice{1}.interp2D.b_field_z(mask_eq, :, :);
b_field_tor = equi.time_slice{1}.interp2D.b_field_tor(mask_eq, :, :);
B_NORM = squeeze(sqrt(b_field_r(ind_mid, :, :).^2. + b_field_z(ind_mid, :, :).^2. + b_field_tor(ind_mid, :, :).^2.));

plot(equi.time_slice{1}.interp2D.r(:, Z_for_R_plot), B_NORM(:, Z_for_R_plot), '-o', 'LineWidth', 1.5);

grid on;
set(gca, 'FontSize', Font_size_graphs);
xlabel('R [m]', 'FontSize', Font_size_graphs);
ylabel(['B NORM [T] at Z=',num2str(equi.time_slice{1}.interp2D.z(Z_for_R_plot, Z_for_R_plot), '%5.4f'), ' m'], 'FontSize', Font_size_graphs);


subplot(2, 2, 3);

psi = equi.time_slice{1}.interp2D.psi(mask_eq, :, :);
contour(equi.time_slice{1}.interp2D.r, equi.time_slice{1}.interp2D.z, squeeze(psi(ind_mid, :, :)), 30, 'b', 'LineWidth', 1);

axis equal;
grid on;
set(gca, 'FontSize', Font_size_graphs);
xlabel('R [m]', 'FontSize', Font_size_graphs);
ylabel('Z [m]', 'FontSize', Font_size_graphs);
title('Psi', 'FontSize', Font_size_graphs);

subplot(2, 2, 4);

surf(equi.time_slice{1}.interp2D.r, equi.time_slice{1}.interp2D.z, B_NORM);

axis equal;
shading interp;
view(0, 90);
grid on;
set(gca, 'FontSize', Font_size_graphs);
xlabel('R [m]', 'FontSize', Font_size_graphs);
ylabel('Z [m]', 'FontSize', Font_size_graphs);
title('B NORM [T]', 'FontSize', Font_size_graphs);
colorbar;

% Save figure in png format
% saveas(fig1, ['Matlab_equi_corep_IMAS_Time','_Shot', num2str(shot), '_Run', num2str(run), '_', machine, '_',user, '.png'], 'png');