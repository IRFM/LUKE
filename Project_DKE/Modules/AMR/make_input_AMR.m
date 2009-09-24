function [AMRcfg_file,launch] = make_input_AMR(basestr,equil,launch,AMR_script_path,AMR_simul_path,opt_gui)
%
experiment = basestr;
%
if isfield(equil,'info') && isfield(equil.info,'shotnum'),
    shotnum = str2num(equil.info.shotnum);
else
    shotnum = 0;
end
%
if isfield(equil,'info') && isfield(equil.info,'shotime'),
    shotime = str2num(equil.info.shotime);
else
    shotime = 0;
end
%
Zeff = mean(sum(equil.pzni.*repmat(equil.zZi.',[1,length(equil.pne)]).^2,1)./equil.pne);
dlognedrm1 = -(equil.pne(end) + equil.pne(end-1))/2/(equil.pne(end) - equil.pne(end-1))*(equil.ptx(end,1) - equil.ptx(end-1,1));
dlogTedrm1 = -(equil.pTe(end) + equil.pTe(end-1))/2/(equil.pTe(end) - equil.pTe(end-1))*(equil.ptx(end,1) - equil.ptx(end-1,1));
%
% Create input (config) files for AMR
%
%
% Creates a structure containing all cfg entries with their default values
%
AMRcfg = cfg2mat([AMR_script_path,'ebe6_defaults.cfg']);
antennacfg = cfg2mat([AMR_script_path,'antenna_template.cfg']);
%
% optional read of existing config and antenna files
%
filename_AMRcfg = 'ebe6*.cfg';
filename_antennacfg = 'antenna*.cfg';
%
[AMRcfg_file,AMRcfg_path] = igetfile_jd(opt_gui,filename_AMRcfg,...
'You may overwrite defaults with an existing ebe6.cfg file (cancel to skip)',AMR_simul_path);
%
if AMRcfg_file ~= 0,
    AMRcfg = cfg2mat([AMRcfg_path,AMRcfg_file],AMRcfg);
end
%
[antennacfg_file,antennacfg_path] = igetfile_jd(opt_gui,filename_antennacfg,...
'You may overwrite defaults with an existing antenna.cfg file (cancel to skip)',AMR_simul_path);
%
if antennacfg_file ~= 0,
    antennacfg = cfg2mat([antennacfg_path,antennacfg_file],antennacfg);
end
%
if ~isempty(launch) % Ask for modification of the cfg files with the external database if it exists
    m_sim_opt = input_dke_yp('Do you want the simulation cfg file to be modified with the shot parameters [y/n]','y',{'y','n'},'',[1,1]);
    m_ant_opt = input_dke_yp('Do you want the antenna cfg file to be modified with the shot parameters [y/n]','y',{'y','n'},'',[1,1]);
else
    m_sim_opt = 'n';
    m_ant_opt = 'n';
end
%
ang_scan = input_dke_yp('Do you want to perform an angle scan [y/n]','y',{'y','n'},'',[1,1]);
%
% Default save name
AMRcfg_file = 'ebe6_LUKE.cfg';
% Modify save name
AMRcfg_file = input_dke_yp('Simulation configuration file save name',AMRcfg_file,'');
% Default save name
AMRcfg.antenna.cfg_file = 'antenna_LUKE.cfg';
% Modify save name
AMRcfg.antenna.cfg_file = input_dke_yp('Antenna configuration file save name',AMRcfg.antenna.cfg_file,'');
%
% Modify the simulation configuration file for TCV
if (strcmp(m_sim_opt,'y') & strcmp(experiment,'TCV'))
    %
    % === S I M U L A T I O N   F I L E ===
    %
    % == Input section ==
    AMRcfg.input.device = 'tokamak';
    AMRcfg.input.experiment = experiment;
    AMRcfg.input.shot_number = shotnum;
    AMRcfg.input.start_time = shotime;
    AMRcfg.input.end_time = shotime;
    AMRcfg.input.ts_times = 'no';
    AMRcfg.input.time_samples = 1;
    %
    % == Output section ==
    AMRcfg.output.ray_details = 'yes';
    AMRcfg.output.current_density = 'simple';
    AMRcfg.output.luke = 'yes';
    %
    % == Cluster section ==
    % Priority of the master process, i.e. the program itself if run locally
    % 0 = lowest (nice 19), 1 = medium (nice 10), 2 = standard (nice 0)
    AMRcfg.cluster.master_priority = 2;
    %
    % == Ray tracing section ==
    % Zeff (constant)
    AMRcfg.ray_tracing.Zeff = Zeff;
    % Stopping power value (1-power_limit damped)
    AMRcfg.ray_tracing.power_limit = 1.e-8; % Because it is a NR calculation
    %
    % == Test profiles section ==
    % equilibrium and profiles are output on a [R_min;R_max] x [Z_min,Z_max]
    % rectangle with R_dim and Z_dim datapoint in R,Z directions
    AMRcfg.test_profiles.R_dim = 101;
    AMRcfg.test_profiles.Z_dim = 101;
    AMRcfg.test_profiles.phi_dim = 1;
    %
    % == Profiles section ==
    %if strcmp(experiment,'TCV') % Remove the stellarator fields
    %	AMRcfg.profiles = rmfield(AMRcfg.profiles,{'B_axis','phi0','s_max',...
    %	's_LCFS','epsTrunc','epsA','compute_mesh'});
    %end
    % equilibrium and ne,Te profiles input type (matlab for LUKE)
    AMRcfg.profiles.input_type = 'matlab';
    % profiles extension behind the last data point
    AMRcfg.profiles.extendProfilesDen = 'exp';
    AMRcfg.profiles.extendProfilesTe = 'exp';
    AMRcfg.profiles.extDataPoints = 5;
    AMRcfg.profiles.LSOL_den = dlognedrm1;
    AMRcfg.profiles.LSOL_Te = dlogTedrm1;
    % SOL width, increase for low frequencies with mode conversion close to or
    % out of LCFS
    %AMRcfg.profiles.LSOL = 0.00;
    AMRcfg.profiles.analytical_profiles = 'no';
    %
    % == Figures section ==
    AMRcfg.figures.ext = 'pdf';
    AMRcfg.figures.use_latex = 'no';
    AMRcfg.figures.experimental_data = 'no';
    AMRcfg.figures.experimental_data = 'no';
    AMRcfg.figures.error_bars = 'no';
    AMRcfg.figures.test_profiles = 'no';
    AMRcfg.figures.ray_tracing_details = 'no';
    AMRcfg.figures.power_deposition = 'no';
    AMRcfg.figures.power_deposition_individual = 'no';
elseif (strcmp(m_sim_opt,'y') & ~strcmp(experiment,'TCV'))
    disp('-----> Modification of the ebe6.cfg files with external database implemented only for TCV.')
    return
end
%
if (strcmp(m_ant_opt,'y') & strcmp(experiment,'TCV'))
    %
    % === A N T E N N A   F I L E ===
    % 
    theta_L = input_dke_yp('Confirm the POLOIDAL LAUNCHER angle in degrees',[launch.angles.theta/pi*180],[7;55],'',[1,1]);
    phi_L = input_dke_yp('Confirm the TOROIDAL LAUNCHER angle in degrees',[launch.angles.phi/pi*180],[-180;180],'',[1,1]);
    %
    % == General section ==
    %
    antennacfg.general.noOfCircles = 2;
    antennacfg.general.raysPerCircle = 3;
    antennacfg.general.turnCircles = 'yes';
    %
    % == Remove the default antenna section ==
    %
    antennacfg = rmfield(antennacfg,'antenna_id_00');
    %
    % == Add the TCV antenna section ==
    %
    % Calculate the beam waist position using T.P. Goodman's launchpoint.m
    % This takes into account all the launcher particularities.
    % Now done in TCV antenna model.
    %addpath /home/goodman/psitbx_develop/;
    %[xL,yL,zL,x_h,y_h,z_h,s34] = launch_point(theta_L,phi_L,str2num(launch.id(end)));
    %s4W = launch.z_L-s34; % Distance from last mirror (M4) to the beam waist
    %launch.waist.xW = xL+s4W*x_h;
    %launch.waist.yW = yL+s4W*y_h;
    %launch.waist.zW = zL+s4W*z_h;
    %launch.waist.radius = 0.0188;
    %th_AMR = -asind(sind(theta_L).*cosd(phi_L));
    %ph_AMR = -atand(tand(theta_L).*sind(phi_L));
    % Find the toroidal position of the launcher axis
    %[xL,yL,zL,x_h,y_h,z_h,s34] = launch_point(0,0,str2num(launch.id(end)));
    % Difference between the toroidal positions of the launcher axis and of the beam waist point
    %Delta_phi = atand(launch.waist.yW./launch.waist.xW)-atand(yL./xL);
    %ph_AMR = ph_AMR+Delta_phi;
    %
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
    %antennacfg.(launch.id).x_waist = launch.waist.xW;	% Now calculated in tcv_beam.m
    %antennacfg.(launch.id).y_waist = launch.waist.yW;	% Now calculated in tcv_beam.m
    %antennacfg.(launch.id).z_waist = launch.waist.zW;	% Now calculated in tcv_beam.m
    %antennacfg.(launch.id).waist_radius = 0.0188;		% Now specified in tcv_beam.m
    %antennacfg.(launch.id).fix_divergence = ''no'';	% Now specified in tcv_beam.m
    antennacfg.(launch.id).gauss_assymetry = 0;
    antennacfg.(launch.id).gauss_radius_enlargement = 1;
    antennacfg.(launch.id).gauss_width = 1;
elseif (strcmp(m_ant_opt,'y') & ~strcmp(experiment,'TCV'))
    disp('-----> Modification of the antenna.cfg files with external database implemented only for TCV.')
    return
end
%
% ANGLE SCAN
%
if (strcmp(ang_scan,'y') & strcmp(experiment,'TCV'))
    %
    % Less detailed output
    %
    AMRcfg.output.central_ray_only = 'yes';
    AMRcfg.output.current_density = 'none';
    AMRcfg.output.luke = 'no';
    %
    % Launcher angles
    %
    theta_L = input_dke_yp('Give the minimum and maximum POLOIDAL LAUNCHER angles in degrees',[],[7;55],'',[1,2]);
    n_theta_L = input_dke_yp('Give the number of POLOIDAL LAUNCHER angles in the scan',5,[1;21],'',[1,1]);
    phi_L = input_dke_yp('Give the minimum and maximum TOROIDAL LAUNCHER angles in degrees',[],[-180;180],'',[1,2]);
    n_phi_L = input_dke_yp('Give the number of TOROIDAL LAUNCHER angles',5,[1;21],'',[1,1]);
    %
    % List of angles
    %
    theta_L_list = linspace(theta_L(1),theta_L(2),n_theta_L);
    phi_L_list = linspace(phi_L(1),phi_L(2),n_phi_L);
    %
    % Create all angle pairs and transform launcher angles into AMR angles
    % Calculate the waist position for one of the angles pairs
    %
    %ang_E_equ_list = zeros(1,n_theta_L*n_phi_L);
    %[theta_L_grid phi_L_grid] = meshgrid(theta_L_list,phi_L_list);
    %itheta_L = ceil(n_theta_L/2);
    %iphi_L = ceil(n_phi_L/2);
    %theta_L_waist = input_dke_yp('Give the poloidal LAUNCHER angle (degrees) for which the waist position is calculated',...
    %theta_L_list(itheta_L),[7;55],'',[1,1]);
    %phi_L_waist = input_dke_yp('Give the toroidal LAUNCHER angle (degrees) for which the waist position is calculated',...
    %phi_L_list(iphi_L),[-180;180],'',[1,1]);
    %addpath /home/goodman/psitbx_develop/;	% To be able to use launch_point.m
    %addpath /home/curchod/matlab/ECRH/;	% To be able to use angle_launch_to_AMR.m
    %[theta_AMR_grid,phi_AMR_grid,xW_grid,yW_grid,zW_grid] = angle_launch_to_AMR(1,theta_L_grid,phi_L_grid,[],[],[],str2num(launch.id(end)));
    %theta_AMR_list = reshape(theta_AMR_grid,1,n_theta_L*n_phi_L);
    %phi_AMR_list = reshape(phi_AMR_grid,1,n_theta_L*n_phi_L);
    % Calculate the waist position for the chosen launcher angles pair
    %[xL,yL,zL,x_h,y_h,z_h,s34] = launch_point(theta_L_waist,phi_L_waist,str2num(launch.id(end)));
    %s4W = launch.z_L-s34; % Distance from last mirror (M4) to minimum waist point
    %launch.waist.xW = xL+s4W*x_h;
    %launch.waist.yW = yL+s4W*y_h;
    %launch.waist.zW = zL+s4W*z_h;
    %launch.waist.radius = 0.0188;
    %
    antennacfg.(launch.id).model = 'tcv';
    antennacfg.(launch.id).launcher_no = str2num(launch.id(end));
    antennacfg.(launch.id).power = [num2str(launch.angles.P0/1000),' kW'];
    antennacfg.(launch.id).toroidal_angles = phi_L_list;
    antennacfg.(launch.id).poloidal_angles = theta_L_list;
    antennacfg.(launch.id).angles_E_equatorial = 0;
    antennacfg.(launch.id).angle_scan = 'all';
    antennacfg.(launch.id).n_tor_angles = n_phi_L;
    antennacfg.(launch.id).n_pol_angles = n_theta_L;
    antennacfg.(launch.id).n_E_eq_angles = 1;
    antennacfg.(launch.id).polarization = 'both';
    antennacfg.(launch.id).frequencies = launch.angles.freq/1e9;
    antennacfg.(launch.id).vacuum_window = 'no';
    %antennacfg.(launch.id).x_waist = launch.waist.xW;	% Now calculated in tcv_beam.m
    %antennacfg.(launch.id).y_waist = launch.waist.yW;	% Now calculated in tcv_beam.m
    %antennacfg.(launch.id).z_waist = launch.waist.zW;	% Now calculated in tcv_beam.m
    %antennacfg.(launch.id).waist_radius = launch.waist.radius;% Now specified in tcv_beam.m
    %antennacfg.(launch.id).fix_divergence = ''no'';	% Now specified in tcv_beam.m
    antennacfg.(launch.id).gauss_assymetry = 0;
    antennacfg.(launch.id).gauss_radius_enlargement = 1;
    antennacfg.(launch.id).gauss_width = 1;
    %
    % Save the angle scan parameters in a scan_info.mat file.
    %
    scan.Lnum = str2num(launch.id(end));
    scan.theta_L = theta_L;
    scan.n_theta_L = n_theta_L;
    scan.theta_L_list = theta_L_list;
    scan.phi_L = phi_L;
    scan.n_phi_L = n_phi_L;
    scan.phi_L_list = phi_L_list;
    %
    savename = [AMR_simul_path 'scan_info.mat'];
    save(savename,'scan');
    %
elseif ~strcmp(experiment,'TCV')
    disp('-----> Angle scan implemented only for TCV.')
    return
end
%
[AMRcfg] = imod_struct_jd(AMRcfg,'AMRcfg');
[antennacfg] = imod_struct_jd(antennacfg,'antennacfg');
%
AMRcfg = rminfo(AMRcfg);
antennacfg = rminfo(antennacfg);
%
antenna_ids = fieldnames(rmfield(antennacfg,'general'));
%
AMRcfg.antenna = rmfield(AMRcfg.antenna,'ids');
AMRcfg.antenna.ids = '';
%
for ifield = 1:length(antenna_ids),
    keep = input_dke_yp(['Do you want to include the antenna ',antenna_ids{ifield}],'n',{'y','n'});
    if keep == 'y',
        AMRcfg.antenna.ids = [AMRcfg.antenna.ids,' ',antenna_ids{ifield}];
    end
end
%
sections = fieldnames(AMRcfg);
fid = fopen([AMR_simul_path,AMRcfg_file],'w');
for sec=1:length(sections)
    fprintf(fid,['[',sections{sec},']\n']);
    keys = fieldnames(AMRcfg.(sections{sec}));
    for k=1:length(keys)
        fprintf_key(fid,keys{k},AMRcfg.(sections{sec}).(keys{k}));
    end
    fprintf(fid,'\n');
end
fclose(fid);

sections = fieldnames(antennacfg);
fid = fopen([AMR_simul_path,AMRcfg.antenna.cfg_file],'w');
for sec=1:length(sections)
    fprintf(fid,['[',sections{sec},']\n']);
    keys = fieldnames(antennacfg.(sections{sec}));
    for k=1:length(keys)
        fprintf_key(fid,keys{k},antennacfg.(sections{sec}).(keys{k}));
    end
    fprintf(fid,'\n');
end
fclose(fid);

end

function fprintf_key(fid,key,val)
    if isstr(val)
        keystr = [key,' = ',val,'\n'];
    elseif islogical(val)
        if val
            keystr = [key,' = yes\n'];
        else
            keystr = [key,' = no\n'];
        end
    elseif isinteger(val)
        keystr = [key,' ='];
        for i=1:length(val)
            valstr = sprintf(' %i',val(i));
            keystr = [keystr,valstr];
        end
        keystr = [keystr,'\n'];
    else
        keystr = [key,' ='];
        for i=1:length(val)
            valstr = sprintf(' %g',val(i));
            keystr = [keystr,valstr];
        end
        keystr = [keystr,'\n'];
    end
    fprintf(fid,keystr);
end

function s = rminfo(s)
    fnames = fieldnames(s);
    for iname = 1:length(fnames);
        if strcmp(fnames{iname},'info') || strcmp(fnames{iname},'expert'),
            s = rmfield(s,fnames{iname});
        elseif isstruct(s.(fnames{iname})),
            s.(fnames{iname}) = rminfo(s.(fnames{iname}));
        end
    end
end
