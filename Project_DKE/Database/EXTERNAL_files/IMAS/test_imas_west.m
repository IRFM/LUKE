% IMAS read WEST equilibrium

% IMAS parameters
% For METIS example run:
%shot    = 53259;
shot    = 55539;
run     = 0;
% For EQUINOX example run:
%shot    = 52705;
%run     = 0;

user    = 'imas_public';
machine = 'west';
t_ignitron = tsbase(shot, 'RIGNITRON');
time_requested_rel = 10;%relative time
time_requested = time_requested_rel + t_ignitron;%absolute time

% Other parameters
Z_for_R_plot     = 50; %Percentage for plot in cartesian grid
Font_size_graphs = 14;

% Prints
fprintf('shot     = %d \n', shot);
fprintf('run      = %d \n', run);
fprintf('user     = %s \n', user);
fprintf('machine  = %s \n', machine);
fprintf('time_req = %f \n', time_requested);

% Open IMAS file: function imas_open_env('ids', shot, run, user, machine, imas_version_number);
idx = imas_open_env('ids', shot, run, user, machine, '3');

% Function ids_get_slice(id_from_imas_open, IDS_name, time_requested, interpolation_method)
% -interpolation_method: 1 = closest time, 2 = previous time, 3 = linear interpolation
equi  = ids_west_get(idx, 'equilibrium',0,1);
corep = ids_get_slice(idx, 'core_profiles', time_requested, 1);
%
mask_eq = equi.code.output_flag >= 0;%
[~, ind_time] = min(abs(equi.time(mask_eq) - time_requested));
%
% For METIS run:
nbr_points = length(equi.time_slice{1,1}.ggd{1,1}.r{1,1}.values);
flag_equinox = 0;
if nbr_points==0
  % For EQUINOX run:
  nbr_points = length(equi.grids_ggd{1,1}.grid{1}.space{1,1}.objects_per_dimension{1,1}.object);%inside and outside separatrix
  flag_equinox = 1;
end
%
R_nodes = zeros(1, nbr_points);
Z_nodes = zeros(1, nbr_points);
Psi_val = zeros(1, nbr_points);
B_R     = zeros(1, nbr_points);
B_Z     = zeros(1, nbr_points);
B_tor   = zeros(1, nbr_points);
%
for i=1:nbr_points
 
    % For EQUINOX run:
    if flag_equinox
      R_nodes(i) = equi.grids_ggd{1,1}.grid{1}.space{1,1}.objects_per_dimension{1,1}.object{1,i}.geometry(1);
      Z_nodes(i) = equi.grids_ggd{1,1}.grid{1}.space{1,1}.objects_per_dimension{1,1}.object{1,i}.geometry(2);
    else
      % For METIS run:
      R_nodes(i) = equi.grids_ggd{1,1}.ggd{1,1}.r{1,1}.values(i);
      Z_nodes(i) = equi.grids_ggd{1,1}.ggd{1,1}.z{1,1}.values(i);
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
saveas(fig1, ['Matlab_equi_corep_IMAS_Time', num2str(time_requested), ...
    '_Shot', num2str(shot), '_Run', num2str(run), '_', machine, '_', ...
    user, '.png'], 'png');