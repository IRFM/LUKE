% IMAS read WEST equilibrium

imas.version = '3';
imas.user = 'imas_public';%database
imas.machine = 'west';%machine name
imas.shot = 53223;%shot number
imas.run = 0;
imas.time_requested = 37;%absolute time at which data are read (s)
imas.command = 'ids_get_slice';%IMAS command
imas.matlabpath = '/Applications/Matlab_2013B/bin/matlab';%Matlab version used by IMAS
imas.remote_profile = 'CEA_SIRRAH';%Remote profile for reading data (SIRRAH or ANDROMEDE for WEST/TORE SUPRA)
imas.remote_enforce = 1;%Enforce remote connection (1) or not (0)
%
% Other parameters
%
Z_for_R_plot     = 50; %Percentage for plot in cartesian grid
Font_size_graphs = 14;
%
% Prints
%
fprintf('shot     = %d \n', imas.shot);
fprintf('run      = %d \n', imas.run);
fprintf('user     = %s \n', imas.user);
fprintf('machine  = %s \n', imas.machine);
fprintf('time_req = %f \n', imas.time_requested);
%
% read data in IMAS database
%
equi  = remote_imas(imas,'equilibrium');
if isempty(equi),
    error('Problem reading equilibrium structure in IMAS database');
else
    corep  = remote_imas(imas,'core_profiles');
    if isempty(corep),
        error('Problem reading core_profiles structure in IMAS database');
    end
end
%
% For METIS run:
%
nbr_points = length(equi.time_slice{1,1}.ggd{1,1}.r{1,1}.values);
flag_equinox = 0;
if nbr_points==0
  % For EQUINOX run:
  nbr_points = length(equi.time_slice{1,1}.ggd{1,1}.grid.space{1,1}.objects_per_dimension{1,1}.object);%inside and outside separatrix
  flag_equinox = 1;
end

R_nodes = zeros(1, nbr_points);
Z_nodes = zeros(1, nbr_points);
Psi_val = zeros(1, nbr_points);
B_R     = zeros(1, nbr_points);
B_Z     = zeros(1, nbr_points);
B_tor   = zeros(1, nbr_points);
for i=1:nbr_points
 
    % For EQUINOX run:
    if flag_equinox,
      R_nodes(i) = equi.time_slice{1,1}.ggd{1,1}.grid.space{1,1}.objects_per_dimension{1,1}.object{1,i}.geometry(1);
      Z_nodes(i) = equi.time_slice{1,1}.ggd{1,1}.grid.space{1,1}.objects_per_dimension{1,1}.object{1,i}.geometry(2);
    else
      % For METIS run:
      R_nodes(i) = equi.time_slice{1,1}.ggd{1,1}.r{1,1}.values(i);
      Z_nodes(i) = equi.time_slice{1,1}.ggd{1,1}.z{1,1}.values(i);
    end

    Psi_val(i) = equi.time_slice{1,1}.ggd{1,1}.psi{1,1}.values(i);
    B_R(i)     = equi.time_slice{1,1}.ggd{1,1}.b_field_r{1,1}.values(i);
    B_Z(i)     = equi.time_slice{1,1}.ggd{1,1}.b_field_z{1,1}.values(i);
    B_tor(i)   = equi.time_slice{1,1}.ggd{1,1}.b_field_tor{1,1}.values(i);
end

[Rq, Zq] = meshgrid(linspace(min(R_nodes), max(R_nodes), 100), ...
                    linspace(min(Z_nodes), max(Z_nodes), 100));

B_NORM = sqrt(B_R.^2 + B_Z.^2 + B_tor.^2);

Psi_interp    = griddata(R_nodes, Z_nodes, Psi_val, Rq, Zq);
B_NORM_interp = griddata(R_nodes, Z_nodes, B_NORM,  Rq, Zq);

% Plot data
fig1 = figure(1);
subplot(2, 3, 1); plot(equi.time_slice{1,1}.profiles_1d.rho_tor, ...
                       equi.time_slice{1,1}.profiles_1d.q, ...
                       '-o', 'LineWidth', 1.5);
grid on;
set(gca, 'FontSize', Font_size_graphs);
xlabel('Rho_{tor} [m]', 'FontSize', Font_size_graphs);
ylabel('q', 'FontSize', Font_size_graphs);

subplot(2, 3, 2); plot(Rq(Z_for_R_plot,:), ...
                       B_NORM_interp(Z_for_R_plot,:), ...
                       '-o', 'LineWidth', 1.5);
grid on;
set(gca, 'FontSize', Font_size_graphs);
xlabel('R [m]', 'FontSize', Font_size_graphs);
ylabel(['B NORM [T] at Z=', num2str(Zq(Z_for_R_plot), '%5.4f'), ' m'], ...
    'FontSize', Font_size_graphs);

subplot(2, 3, 3); contour(Rq, Zq, Psi_interp, 30, 'b', 'LineWidth', 1);
axis equal;
grid on;
set(gca, 'FontSize', Font_size_graphs);
xlabel('R [m]', 'FontSize', Font_size_graphs);
ylabel('Z [m]', 'FontSize', Font_size_graphs);
title('Psi', 'FontSize', Font_size_graphs);


%subplot(2, 3, 4); surf(Rq, Zq, B_NORM_interp);
%axis equal;
%shading interp;
%view(0, 90);
%grid on;
%set(gca, 'FontSize', Font_size_graphs);
%xlabel('R [m]', 'FontSize', Font_size_graphs);
%ylabel('Z [m]', 'FontSize', Font_size_graphs);
%title('B NORM [T]', 'FontSize', Font_size_graphs);
%colorbar;

subplot(2, 3, 5); plot(corep.profiles_1d{1,1}.grid.rho_tor_norm, ...
                       corep.profiles_1d{1,1}.electrons.density, ...
                       '-xr', 'LineWidth', 1.5);
grid on;
set(gca, 'FontSize', Font_size_graphs);
xlabel('Rho_{tor norm}', 'FontSize', Font_size_graphs);
ylabel('n_{e} [m^{-3}]', 'FontSize', Font_size_graphs);

subplot(2, 3, 6); plot(corep.profiles_1d{1,1}.grid.rho_tor_norm, ...
                       corep.profiles_1d{1,1}.electrons.temperature, ...
                       '-sk', 'LineWidth', 1.5);
grid on;
set(gca, 'FontSize', Font_size_graphs);
xlabel('Rho_{tor norm}', 'FontSize', Font_size_graphs);
ylabel('T_{i} [eV]', 'FontSize', Font_size_graphs);

% Save figure in png format
saveas(fig1, ['Matlab_equi_corep_IMAS_Time', num2str(imas.time_requested), ...
    '_Shot', num2str(imas.shot), '_Run', num2str(imas.run), '_', imas.machine, '_', ...
    imas.user, '.png'], 'png');