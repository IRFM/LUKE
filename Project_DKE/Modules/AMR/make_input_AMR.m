function make_input_AMR()
%
% Create input (config) files for AMR
%
% default values
[AMRcfg,antennacfg] = default_cfg_AMR();
% == input section ==
% experiment name
AMRcfg.input.experiment = 'COMPASS';
% shot number
AMRcfg.input.shot_number = 0;
% start time of the simulation
AMRcfg.input.start_time = 0;
% end time of the simulation
AMRcfg.input.end_time = 0;
% no. of time steps
AMRcfg.input.time_samples = 0;
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
AMRcfg.ray_tracing.Zeff = 1.0;
% Runge-Kutta accuracy
AMRcfg.ray_tracing.accuracy = 1.e-5;
% stopping power value (1-power_limit damped)
AMRcfg.ray_tracing.power_limit = 1.e-8;
%
% == test profiles section ==
% equilibrium and profiles are output on a [R_min;R_max] x [Z_min,Z_max]
% rectangle with R_dim and Z_dim datapoint in R,Z directions
AMRcfg.test_profiles.R_min = 0.0;
AMRcfg.test_profiles.R_max = 0.0;
AMRcfg.test_profiles.Z_min = 0.0;
AMRcfg.test_profiles.Z_max = 0.0;
AMRcfg.test_profiles.R_dim = 0;
AMRcfg.test_profiles.Z_dim = 0;
%
% == profiles section ==
% equilibriuam and ne,Te profiles input type (matlab for LUKE)
AMRcfg.profiles.input_type = 'matlab';
% equilibriuam and ne,Te profiles export type (matlab for LUKE)
AMRcfg.profiles.export = 'matlab';
% no. of datapoints in R,Z,psi
AMRcfg.profiles.export_nR = 100;
AMRcfg.profiles.export_nZ = 100;
AMRcfg.profiles.export_npsi = 100;
% profiles extension behind the last data point
AMRcfg.profiles.extendProfilesDen = 'exp';
AMRcfg.profiles.extendProfilesTe = 'exp';
AMRcfg.profiles.extDataPoints = 5;
AMRcfg.profiles.LSOL_den = 0.1;
AMRcfg.profiles.LSOL_Te = 0.1;
% SOL width, increase for low frequencies with mode conversion close to or
% out of LCFS
AMRcfg.profiles.LSOL = 0.0;
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
AMRcfg.integration.R_min = 0.0;
AMRcfg.integration.R_max = 0.0;
AMRcfg.integration.r_eff_min = 0;
AMRcfg.integration.r_eff_max = 0.0;
% no. of datapoints
AMRcfg.integration.tabdim = 20;
%
% === A N T E N N A   F I L E ===
% == general section ==
antennacfg.general.noOfCircles = 4;
antennacfg.general.raysPerCircle = 6;
%
% == antenna_0 section ==
% modify/add any antenna ids, consistently with AMRcfg.antenna.ids
% antenna model
antennacfg.antenna_0.model = 'gaussian';
% power in kW
antennacfg.antenna_0.power = 1.0;
% array of toroidal angles (single value for no angle scan)
antennacfg.antenna_0.toroidal_angles = [0.0];
% array of poloidal angles (single value for no angle scan)
antennacfg.antenna_0.poloidal_angles = [0.0];
% array of polarization angles (single value for no angle scan)
antennacfg.antenna_0.angles_E_equatorial = [0.0];
% select polarization(s) (linear | linear_complementary | circular)
antennacfg.antenna_0.polarization = 'linear';
% array of frequencies
antennacfg.antenna_0.frequencies = [33.0];

sections = fieldnames(AMRcfg);
fid = fopen('ebe6.cfg','w');
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
fid = fopen(AMRcfg.antenna.cfg_file,'w');
for sec=1:length(sections)
    fprintf(fid,['[',sections{sec},']\n']);
    keys = fieldnames(antennacfg.(sections{sec}));
    for k=1:length(keys)
        fprintf_key(fid,keys{k},antennacfg.(sections{sec}).(keys{k}));
    end
    fprintf(fid,'\n');
end
fclose(fid);

function fprintf_key(fid,key,val)
    if isstr(val)
        keystr = [key,' = ',val,'\n'];
    elseif islogical(val)
        if val
            keystr = [key,' = yes\n'];
        else
            keystr = [key,' = no\n'];
        end
    elseif isint(val)
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
    