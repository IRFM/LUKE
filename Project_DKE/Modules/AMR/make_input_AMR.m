function AMRcfg_file = make_input_AMR(basestr,equil,AMR_path,opt_gui)
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
dlognedrm1 = (equil.pne(end) + equil.pne(end-1))/2/(equil.pne(end) - equil.pne(end-1))*(equil.ptx(end,1) - equil.ptx(end-1,1));
dlogTedrm1 = (equil.pTe(end) + equil.pTe(end-1))/2/(equil.pTe(end) - equil.pTe(end-1))*(equil.ptx(end,1) - equil.ptx(end-1,1));
%
% Create input (config) files for AMR
%
%
% Creates a structure containing all cfg entries with their default values
%
AMRcfg = cfg2mat([AMR_path,'ebe6_defaults.cfg']);
antennacfg = cfg2mat([AMR_path,'antenna_template.cfg']);
%
% optional read of existing config and antenna files
%
filename_AMRcfg = 'ebe6*.cfg';
filename_antennacfg = 'antenna*.cfg';
%
[AMRcfg_file,AMRcfg_path] = igetfile_jd(opt_gui,filename_AMRcfg,'You may overwrite defaults with an existing AMRcfg file (cancel to skip)',AMR_path);
%
if AMRcfg_file ~= 0,
    AMRcfg = cfg2mat([AMRcfg_path,AMRcfg_file],AMRcfg);
end
%
[antennacfg_file,antennacfg_path] = igetfile_jd(opt_gui,filename_antennacfg,'You may overwrite defaults with an existing antennacfgcfg file (cancel to skip)',AMR_path);
%
if antennacfg_file ~= 0,
    antennacfg = cfg2mat([antennacfg_path,antennacfg_file],antennacfg);
end
% experiment name
AMRcfg.input.experiment = experiment;
% shot number
AMRcfg.input.shot_number = shotnum;
% start time of the simulation
AMRcfg.input.start_time = shotime;
% end time of the simulation
AMRcfg.input.end_time = shotime;
% no. of time steps
AMRcfg.input.time_samples = 1;
%
% == output section ==
% calculate the central rays only
AMRcfg.output.central_ray_only = true;
% generate LUKE output
AMRcfg.output.luke = true;
%
% == cluster section ==
% priority of the master process, i.e. the program itself if run locally
% 0 = lowest (nice 19), 1 = medium (nice 10), 2 = standard (nice 0)
AMRcfg.cluster.master_priority = 0;
%
% == ray tracing section ==
% Zeff (constant)
AMRcfg.ray_tracing.Zeff = Zeff;
% Runge-Kutta accuracy
% AMRcfg.ray_tracing.accuracy = 1.e-5;
% stopping power value (1-power_limit damped)
AMRcfg.ray_tracing.power_limit = 1.e-8;% because it is a NR calculation
%
% == test profiles section ==
% equilibrium and profiles are output on a [R_min;R_max] x [Z_min,Z_max]
% rectangle with R_dim and Z_dim datapoint in R,Z directions
% AMRcfg.test_profiles.R_min = 0.4;
% AMRcfg.test_profiles.R_max = 0.7;
% AMRcfg.test_profiles.Z_min = -0.2;
% AMRcfg.test_profiles.Z_max = 0.2;
% AMRcfg.test_profiles.R_dim = 101;
% AMRcfg.test_profiles.Z_dim = 101;
%
% == profiles section ==
% equilibriuam and ne,Te profiles input type (matlab for LUKE)
AMRcfg.profiles.input_type = 'matlab';
% equilibriuam and ne,Te profiles export type (matlab for LUKE)
AMRcfg.profiles.export = 'matlab';
% no. of datapoints in R,Z,psi
% AMRcfg.profiles.export_nR = 100;
% AMRcfg.profiles.export_nZ = 100;
% AMRcfg.profiles.export_npsi = 100;
% profiles extension behind the last data point
AMRcfg.profiles.extendProfilesDen = 'exp';
AMRcfg.profiles.extendProfilesTe = 'exp';
AMRcfg.profiles.extDataPoints = 5;
AMRcfg.profiles.LSOL_den = dlognedrm1;
AMRcfg.profiles.LSOL_Te = dlogTedrm1;
% SOL width, increase for low frequencies with mode conversion close to or
% out of LCFS
AMRcfg.profiles.LSOL = 0.00;
%
% == antenna section ==
% name of the antenna cfg file
AMRcfg.antenna.cfg_file = 'antenna_LUKE.cfg';
% antenna ids (white space separated)
AMRcfg.antenna.ids = 'antenna_0';
%
% == integration section ==
% min, max in R and r_eff for profiles (deposition, current) integration
% r_eff = a0*sqrt(psi_normalized)
% AMRcfg.integration.R_min = 0.0;
% AMRcfg.integration.R_max = 0.0;
% AMRcfg.integration.r_eff_min = 0;
% AMRcfg.integration.r_eff_max = 0.0;
% no. of datapoints
% AMRcfg.integration.tabdim = 20;
%
% === A N T E N N A   F I L E ===
% == general section ==
% antennacfg.general.noOfCircles = 4;
% antennacfg.general.raysPerCircle = 6;
%
% == antenna_0 section ==
% modify/add any antenna ids, consistently with AMRcfg.antenna.ids
% antenna model
% antennacfg.antenna_0.model = 'gaussian';
% power in kW
% antennacfg.antenna_0.power = 1.0;
% array of toroidal angles (single value for no angle scan)
% antennacfg.antenna_0.toroidal_angles = [-35.2692];
% array of poloidal angles (single value for no angle scan)
% antennacfg.antenna_0.poloidal_angles = [-2.1198];
% array of polarization angles (single value for no angle scan)
% antennacfg.antenna_0.angles_E_equatorial = [0.0];
% select polarization(s) (linear | linear_complementary | circular)
% antennacfg.antenna_0.polarization = 'linear';
% array of frequencies
% antennacfg.antenna_0.frequencies = [33.0];
%
% === SPECIFIC ANTENNA ELEMENTS ===
% waist center coordinates
% antennacfg.antenna_0.x_waist = 0.83;
% antennacfg.antenna_0.y_waist = 0;
% antennacfg.antenna_0.z_waist = 0;
% waist radius [m]
% antennacfg.antenna_0.waist_radius = 0.025;
% fix the beam divergence
% antennacfg.antenna_0.fix_divergence = false;
% divergence in degrees
% antennacfg.antenna_0.fixed_divergence = 0;
% Gaussian beam deformation
% antennacfg.antenna_0.gauss_assymetry = 0;
% antennacfg.antenna_0.gauss_radius_enlargement = 1;
% antennacfg.antenna_0.gauss_width = 1;
%
[AMRcfg] = imod_struct_jd(AMRcfg,'AMRcfg');
[antennacfg] = imod_struct_jd(antennacfg,'antennacfg');
%
AMRcfg = rminfo(AMRcfg);
antennacfg = rminfo(antennacfg);
%
% default save name
AMRcfg_file = 'ebe6_LUKE.cfg';
%
AMRcfg_file = input_dke_yp('Configuration file name',AMRcfg_file,'');
%
sections = fieldnames(AMRcfg);
fid = fopen([AMR_path,AMRcfg_file],'w');
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
fid = fopen([AMR_path,AMRcfg.antenna.cfg_file],'w');
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

        
        
        
        
    