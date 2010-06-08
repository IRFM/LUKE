function [AMRcfg_file,launch] = make_input_AMR(experiment,equil,launch,AMR_script_path,AMR_simul_path,opt_gui)
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
% Default save name
AMRcfg_file = 'ebe6_LUKE.cfg';
% Modify save name
AMRcfg_file = input_dke_yp('Simulation configuration file save name',AMRcfg_file,'');
% Default save name
AMRcfg.antenna.cfg_file = 'antenna_LUKE.cfg';
% Modify save name
AMRcfg.antenna.cfg_file = input_dke_yp('Antenna configuration file save name',AMRcfg.antenna.cfg_file,'');
%
% === S I M U L A T I O N   F I L E ===
%
if strcmp(m_sim_opt,'y')% overwrite parameters with shot parameters
    %
    % == Input section ==
    %
    AMRcfg.input.device = 'tokamak';
    AMRcfg.input.experiment = experiment;
    AMRcfg.input.shot_number = shotnum;
    AMRcfg.input.start_time = shotime;
    AMRcfg.input.end_time = shotime;
    %
    % == Ray tracing section ==
    %
    AMRcfg.ray_tracing.Zeff = Zeff; % Zeff (flat profile)
    %
    % == Profiles section ==
    %
    AMRcfg.profiles.LSOL_den = dlognedrm1;
    AMRcfg.profiles.LSOL_Te = dlogTedrm1;
    %
end
%
% === A N T E N N A   F I L E ===
% 
if strcmp(m_ant_opt,'y')% overwrite antenna parameters with shot parameters
    %
    if strcmp(experiment,'TCV'),
        %
        [AMRcfg,antennacfg,launch] = make_AMR_antenna_TCV(AMRcfg,antennacfg,launch,AMR_simul_path);
        %
    end
end        
%
[AMRcfg] = imod_struct_jd(AMRcfg,'AMRcfg',1,opt_gui);
[antennacfg] = imod_struct_jd(antennacfg,'antennacfg',1,opt_gui);
%
antenna_ids = fieldnames(rmfield(antennacfg,'general'));
%
AMRcfg.antenna = rmfield(AMRcfg.antenna,'ids');
AMRcfg.antenna.ids = '';
%
for ifield = 1:length(antenna_ids),
    keep = input_dke_yp(['Do you want to include the antenna ',antenna_ids{ifield}],'y',{'y','n'});
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
