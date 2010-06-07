function [AMRcfg,antennacfg,launch] = make_AMR_antenna_TCV(AMRcfg,antennacfg,launch)
%
% TCV Antenna model for AMR
%
% L. Curchod, J. Urban and J. Decker
%
ang_scan = input_dke_yp('Do you want to perform an angle scan [y/n]','n',{'y','n'},'',[1,1]);
model_opt = input_dke_yp('Do you want to use (0) Gaussian antenna model (1) TCV antenna model',0,{0,1},'Invalid selection');
launch.AMR.Lnum = str2num(launch.id(end));
launch.AMR.ang_scan = ang_scan;
launch.AMR.model_opt = model_opt;
scan.Lnum = str2num(launch.id(end));
scan.ang_scan = ang_scan;
scan.model_opt = model_opt;
%
% Subroutine for the angle and waist position calculation.
% Should be moved to CRPP SVN server soon.
%
addpath /home/goodman/psitbx_develop/; % For launch_point.m
addpath /home/curchod/matlab/ECRH/;	% For angle_launch_to_AMR.m
%
% NO ANGLE SCAN
%
if strcmp(ang_scan,'n')
    % Launcher angles
    theta_L = input_dke_yp('Confirm the POLOIDAL LAUNCHER angle in degrees',[launch.angles.theta/pi*180],[7;55],'',[1,1]);
    phi_L = input_dke_yp('Confirm the TOROIDAL LAUNCHER angle in degrees',[launch.angles.phi/pi*180],[-180;180],'',[1,1]);
    launch.AMR.theta_L = theta_L;
    launch.AMR.phi_L = phi_L;
    % Beam waist radius
    Wradius = 0.0188;
    launch.AMR.Wradius = Wradius;
    %
    % == General section ==
    %
    antennacfg.general.noOfCircles = input_dke_yp('How many circles of rays around the central ray?',[2],[0;10],'',[1,1]);
    antennacfg.general.raysPerCircle = input_dke_yp('How many rays per circle?',[3],[0;10],'',[1,1]);
    antennacfg.general.turnCircles = 'yes';
    antennacfg.general.n_window_points = 30;
    %
    % == Remove the default antenna section ==
    %
    if isfield(antennacfg,'antenna_id_00')
	antennacfg = rmfield(antennacfg,'antenna_id_00');
    end
    %
    % == Add the TCV antenna section ==
    % 
    if ~model_opt
    	disp('Use Gaussian antenna model.');
    	disp('AMR angles and waist position calculated using angle_launch_to_AMR.m (calling launchpoint.m).');
    	[theta_AMR,phi_AMR,xW,yW,zW] = angle_launch_to_AMR(1,theta_L,phi_L,[],[],[],str2num(launch.id(end)),0);
    	launch.AMR.theta_AMR = theta_AMR;
    	launch.AMR.phi_AMR = phi_AMR;
    	launch.AMR.xW = xW;
    	launch.AMR.yW = yW;
        launch.AMR.zW = zW;
    	%
    	antennacfg.(launch.id).model = 'gaussian';
    	antennacfg.(launch.id).power = [num2str(launch.angles.P0/1000),' kW'];
    	antennacfg.(launch.id).toroidal_angles = phi_AMR;
    	antennacfg.(launch.id).poloidal_angles = theta_AMR;
    	antennacfg.(launch.id).angles_E_equatorial = 0;
    	antennacfg.(launch.id).angle_scan = 'none';
    	antennacfg.(launch.id).n_tor_angles = 1;
    	antennacfg.(launch.id).n_pol_angles = 1;
    	antennacfg.(launch.id).n_E_eq_angles = 1;
    	antennacfg.(launch.id).polarization = 'both';
    	antennacfg.(launch.id).frequencies = launch.angles.freq/1e9;
    	antennacfg.(launch.id).vacuum_window = 'no';
    	antennacfg.(launch.id).x_waist = xW;
    	antennacfg.(launch.id).y_waist = yW;
    	antennacfg.(launch.id).z_waist = zW;
    	antennacfg.(launch.id).waist_radius = Wradius;
    	antennacfg.(launch.id).fix_divergence = 'no';
    	antennacfg.(launch.id).gauss_assymetry = 0;
    	antennacfg.(launch.id).gauss_radius_enlargement = 1;
    	antennacfg.(launch.id).gauss_width = 1;
    else
    	disp('Use TCV model antenna.');
    	disp('Wave vector and waist position calculated using tcv_beam.m (calling launchpoint.m).');
    	antennacfg.(launch.id).model = 'tcv';
    	antennacfg.(launch.id).launcher_no = str2num(launch.id(end));
    	antennacfg.(launch.id).power = [num2str(launch.angles.P0/1000),' kW'];
    	antennacfg.(launch.id).toroidal_angles = phi_L;
    	antennacfg.(launch.id).poloidal_angles = theta_L;
    	antennacfg.(launch.id).angles_E_equatorial = 0;
    	antennacfg.(launch.id).angle_scan = 'none';
    	antennacfg.(launch.id).n_tor_angles = 1;
    	antennacfg.(launch.id).n_pol_angles = 1;
    	antennacfg.(launch.id).n_E_eq_angles = 1;
    	antennacfg.(launch.id).polarization = 'both';
    	antennacfg.(launch.id).frequencies = launch.angles.freq/1e9;
    	antennacfg.(launch.id).vacuum_window = 'no';
    	%antennacfg.(launch.id).x_waist = xW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).y_waist = yW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).z_waist = zW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).waist_radius = Wradius;	% Now specified in tcv_beam.m
    	%antennacfg.(launch.id).fix_divergence = 'no';	% Now specified in tcv_beam.m
    	antennacfg.(launch.id).gauss_assymetry = 0;
    	antennacfg.(launch.id).gauss_radius_enlargement = 1;
    	antennacfg.(launch.id).gauss_width = 1;
    end
else
%
% ANGLE SCAN
%
    %
    % Launcher angles
    %
    theta_L = input_dke_yp('Give the minimum and maximum POLOIDAL LAUNCHER angles in degrees',[],[7;55],'',[1,2]);
    n_theta_L = input_dke_yp('Give the number of POLOIDAL LAUNCHER angles in the scan',5,[1;21],'',[1,1]);
    phi_L = input_dke_yp('Give the minimum and maximum TOROIDAL LAUNCHER angles in degrees',[],[-180;180],'',[1,2]);
    n_phi_L = input_dke_yp('Give the number of TOROIDAL LAUNCHER angles',5,[1;21],'',[1,1]);
    theta_L_list = linspace(theta_L(1),theta_L(2),n_theta_L);
    phi_L_list = linspace(phi_L(1),phi_L(2),n_phi_L);
    launch.AMR.theta_L = theta_L;
    launch.AMR.n_theta_L = n_theta_L;
    launch.AMR.theta_L_list = theta_L_list;
    launch.AMR.phi_L = phi_L;
    launch.AMR.n_phi_L = n_phi_L;
    launch.AMR.phi_L_list = phi_L_list;
    scan.theta_L = theta_L;
    scan.n_theta_L = n_theta_L;
    scan.theta_L_list = theta_L_list;
    scan.phi_L = phi_L;
    scan.n_phi_L = n_phi_L;
    scan.phi_L_list = phi_L_list;
    % Beam waist radius
    Wradius = 0.0188;
    launch.AMR.Wradius = Wradius;
    scan.Wradius = Wradius;
    %
    % === Modify SIMULATION file ===
    % Less detailed outputs + conversion efficiency calculation method
    %
    % == Output and LUKE sections ==
    AMRcfg.output.central_ray_only = 'yes';
    AMRcfg.output.ray_details = 'no';
    AMRcfg.output.power_deposition = 'no';
    AMRcfg.output.current_density = 'none';
    AMRcfg.output.conv_eff = 'yes';
    AMRcfg.output.temperature = 'yes';
    AMRcfg.output.test_profiles = 'yes';
    AMRcfg.output.run_code = 'yes';
    AMRcfg.output.postprocess = 'yes';
    AMRcfg.output.sum_antennas = 'yes';
    AMRcfg.output.run_luke = 'no';
    AMRcfg.luke.outputs = 'no';
    %
    % == Adaptive section ==
    %
    method = input_dke_yp('Which method do you want to use ? 0 (Adaptive), 1 (Preinhaelter), ',0,0:1,'',[1,1]);
    if method==0
    	AMRcfg.adaptive.method = 'adaptive';
        scan.method = 'adaptive';
    elseif method==1
    	AMRcfg.adaptive.method = 'preinh';
        scan.method = 'preinh';
    end
    %
    % === Modify ANTENNA file ===
    %
    % == General section ==
    %
    antennacfg.general.noOfCircles = 1;
    antennacfg.general.raysPerCircle = 1;
    antennacfg.general.turnCircles = 'no';
    antennacfg.general.n_window_points = 30;
    %
    % == Remove the default antenna section ==
    %
    if isfield(antennacfg,'antenna_id_00')
        antennacfg = rmfield(antennacfg,'antenna_id_00');
    end
    %
    % == Add the TCV antenna section ==
    % 
    if ~model_opt
    	disp('Use Gaussian antenna model.');
    	disp('AMR angles and waist position calculated using angle_launch_to_AMR.m (calling launchpoint.m).');
    	%
    	% Create all angle pairs and transform launcher angles into AMR angles
    	% Calculate the waist position for the central pair of angles pair
    	%
        ang_E_equ_list = zeros(1,n_theta_L*n_phi_L);
        % Angles grids
        [theta_L_grid phi_L_grid] = meshgrid(theta_L_list,phi_L_list);
    	launch.AMR.theta_L_grid = theta_L_grid;
    	launch.AMR.phi_L_grid = phi_L_grid;
    	scan.theta_L_grid = theta_L_grid;
    	scan.phi_L_grid = phi_L_grid;
    	% Angles pair for the waist position calculation
    	itheta_L = ceil(n_theta_L/2);
    	iphi_L = ceil(n_phi_L/2);
        theta_L_waist = input_dke_yp('Confirm the poloidal LAUNCHER angle (degrees) for which the waist position is calculated',...
        theta_L_list(itheta_L),[7;55],'',[1,1]);
        phi_L_waist = input_dke_yp('Confirm the toroidal LAUNCHER angle (degrees) for which the waist position is calculated',...
        phi_L_list(iphi_L),[-180;180],'',[1,1]);
        % Angles conversion
        [theta_AMR_grid,phi_AMR_grid,xW_grid,yW_grid,zW_grid] =...
    	angle_launch_to_AMR(1,theta_L_grid,phi_L_grid,[],[],[],str2num(launch.id(end)),0);
    	theta_AMR_list = reshape(theta_AMR_grid,1,n_theta_L*n_phi_L);
    	phi_AMR_list = reshape(phi_AMR_grid,1,n_theta_L*n_phi_L);
    	launch.AMR.theta_AMR_grid = theta_AMR_grid;
    	launch.AMR.phi_AMR_grid = phi_AMR_grid;
    	launch.AMR.theta_AMR_list = theta_AMR_list;
    	launch.AMR.phi_AMR_list = phi_AMR_list;
    	scan.theta_AMR_grid = theta_AMR_grid;
    	scan.phi_AMR_grid = phi_AMR_grid;
    	scan.theta_AMR_list = theta_AMR_list;
    	scan.phi_AMR_list = phi_AMR_list;
    	% Calculate the waist position for the chosen launcher angles pair
    	[theta_AMR_waist,phi_AMR_waist,xW,yW,zW] = angle_launch_to_AMR(1,theta_L_waist,phi_L_waist,[],[],[],str2num(launch.id(end)),0);
    	launch.AMR.theta_L_waist = theta_L_waist;
    	launch.AMR.phi_L_waist = phi_L_waist;
    	launch.AMR.theta_AMR_waist = theta_AMR_waist;
    	launch.AMR.phi_AMR_waist = phi_AMR_waist;
    	launch.AMR.xW = xW;
    	launch.AMR.yW = yW;
        launch.AMR.zW = zW;
        scan.theta_L_waist = theta_L_waist;
        scan.phi_L_waist = phi_L_waist;
    	scan.theta_AMR_waist = theta_AMR_waist;
    	scan.phi_AMR_waist = phi_AMR_waist;
    	scan.xW = xW;
    	scan.yW = yW;
        scan.zW = zW;
    	%
    	antennacfg.(launch.id).model = 'gaussian';
        antennacfg.(launch.id).power = [num2str(launch.angles.P0/1000),' kW'];
        antennacfg.(launch.id).toroidal_angles = phi_AMR_list;
    	antennacfg.(launch.id).poloidal_angles = theta_AMR_list;
    	antennacfg.(launch.id).angles_E_equatorial = ang_E_equ_list;
    	antennacfg.(launch.id).angle_scan = 'coupled';
    	antennacfg.(launch.id).n_tor_angles = n_phi_L;
    	antennacfg.(launch.id).n_pol_angles = n_theta_L;
    	antennacfg.(launch.id).n_E_eq_angles = 1;
    	antennacfg.(launch.id).polarization = 'both';
    	antennacfg.(launch.id).frequencies = launch.angles.freq/1e9;
    	antennacfg.(launch.id).vacuum_window = 'no';
    	antennacfg.(launch.id).x_waist = xW;	
    	antennacfg.(launch.id).y_waist = yW;	
    	antennacfg.(launch.id).z_waist = zW;	
    	antennacfg.(launch.id).waist_radius = Wradius;
    	antennacfg.(launch.id).fix_divergence = 'no';
    	antennacfg.(launch.id).gauss_assymetry = 0;
    	antennacfg.(launch.id).gauss_radius_enlargement = 1;
    	antennacfg.(launch.id).gauss_width = 1;
    else
    	disp('Use TCV model antenna.');
    	disp('Wave vector and waist position calculated using tcv_beam.m (calling launchpoint.m).');
    	antennacfg.(launch.id).model = 'tcv';
    	antennacfg.(launch.id).launcher_no = str2num(launch.id(end));
    	antennacfg.(launch.id).power = [num2str(launch.angles.P0/1000),' kW'];
    	antennacfg.(launch.id).toroidal_angles = phi_L;
    	antennacfg.(launch.id).poloidal_angles = theta_L;
    	antennacfg.(launch.id).angles_E_equatorial = 0;
    	antennacfg.(launch.id).angle_scan = 'all';
    	antennacfg.(launch.id).n_tor_angles = n_phi_L;
    	antennacfg.(launch.id).n_pol_angles = n_theta_L;
    	antennacfg.(launch.id).n_E_eq_angles = 1;
    	antennacfg.(launch.id).polarization = 'both';
    	antennacfg.(launch.id).frequencies = launch.angles.freq/1e9;
    	antennacfg.(launch.id).vacuum_window = 'no';
    	%antennacfg.(launch.id).x_waist = xW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).y_waist = yW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).z_waist = zW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).waist_radius = Wradius; % Now specified in tcv_beam.m
    	%antennacfg.(launch.id).fix_divergence = 'no';	% Now specified in tcv_beam.m
        antennacfg.(launch.id).gauss_assymetry = 0;
    	antennacfg.(launch.id).gauss_radius_enlargement = 1;
    	antennacfg.(launch.id).gauss_width = 1;
    end
    savename = [AMR_simul_path 'scan_info.mat'];
    save(savename,'scan');
    %
end
