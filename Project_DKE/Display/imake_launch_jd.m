function launchs = imake_launch_jd(dkepath,basestr,equil,external,workdir,opt_gui,select)
%
% This function manages and standardizes the heterogeneous external data 
% from different sources and tokamaks, then builds the launch structure.
%
% In interactive mode, the RF wave types and launching structures and
% selected from user input
%
% In non-interactive mode, in the presence of external data, all the RF
% structures listed in external are processed with default missing parameters
% 
%
if nargin < 7,
	select = struct;
end
%
if nargin < 6,
	opt_gui = true;
end
%
if nargin < 5,
	workdir = pwd;
end
%
if nargin < 4,
	external = '';
end
%
if nargin < 3,
	error('Not enough arguments')
end
%
if ~isfield(select,'style'),
    select.style = struct;
end
%    
signs.ip = sign(equil.psi_apRp(end));
signs.b0 = sign(equil.ptBPHI(1,1));
%
launchs = {};
%
if ~isempty(external),% import wave data from external structure
    %
    if isfield(equil,'shotnum'),
        shotnum = equil.shotnum;
    else
        istru = find(equil.id == '_');
        if length(istru) >= 2 && strcmp(equil.id(1:istru(1)-1),basestr),
            shotnum = equil.id(istru(1)+1:istru(2)-1);
        else           
            disp('-----> Shot number information missing');
            return
        end
    end
    %
    if strcmp(basestr,'TCV'),% TCV launching data
        %
        % BUILDING LAUNCH
        %
        type = 'EC';
        %
        for l_opt = external.laun,
            angles = imake_angles_TCV_jd(external,shotnum,l_opt,true,'',opt_gui,select.style);
            %
            if isnan(angles.P0) || angles.P0 == 0,
                continue
            end
            %
            launch = imake_launch_angles_TCV_jd(angles);
            launch.type = type;
            %
            launchs{end+1} = launch;
        end
        %
    elseif strcmp(basestr,'TS'),
        %
        % Case of LH spectrum from ALOHA file
        %
        if isfield(external,'antenna'),
            %
            spectrum = struct;
            if isfield(external,'id'),
                spectrum.id = external.id;
            end
            spectrum.dP = external.antenna.dP;
            spectrum.dP_nz = external.antenna.dP_nz;
            spectrum.nz = external.antenna.nz;
            spectrum.ny = external.antenna.ny;
            %   
            data = struct;
            data.spectrum = spectrum;
            %
            launchs{1} = imake_launch_LH_jd(basestr,signs,data,opt_gui,select);
        %
        % Case of structure external
        %
        else
            %
            % WAVE TYPE
            %
            if isfield(external,'LH') && isfield(external,'EC')
                %
                t_opt = input_dke_yp('Option for wave type : 0 (LH), 1 (EC)',0,0:1,'',[1,1]);
                %
                if t_opt == 0,
                    %
                    type = 'LH';
                else
                    %
                    type = 'EC';
                end
                %
            elseif isfield(external,'LH'),
                %
                type = 'LH';
                %
            elseif isfield(external,'EC'),
                %
                type = 'EC';
                %
            else
                disp('WAVE type not recognized in external structure. Aborted')
                return
            end
            %
            % BUILDING LAUNCH
            %
            if strcmp(type,'LH'),
                %
                launch = imake_launch_LH_jd(basestr,equil,external.LH);
                %
            elseif strcmp(type,'EC'),
                %
                launch = imake_launch_TS_jd(external.EC); 
                %
            end
        end
        %
    elseif strcmp(basestr,'EAST'),
        %
        % Case of LH spectrum from file
        %
        if isfield(external,'power_spectrum'),
            %
            data = struct;
            %
            launchsfile = ['get_launchs_',basestr];
            %
            if isfield(external,'id') && exist(launchsfile,'file');
                [~,a_list] = feval(launchsfile);
                na_list = length(a_list);
                a_opt = false(1,na_list);
                %    
                for ia_list = 1:na_list,
                    %
                    a_opt(ia_list) = any(strfind(lower(external.id),lower(a_list{ia_list})));
                    %
                end
                %
                if sum(a_opt) == 1,
                    data.id = a_list{a_opt};
                else
                    disp(['The antenna index could not be determined from the filename']);
                end
                %
            end
            %
            data.omega_rf = 2*pi*1e9*external.frequency.flh;
            data.rZ0 = sort(external.position.Z);
            %
            if isfield(external.power_spectrum,'dn_par'),% lobes already processed
                %
                data.bNpar0 = external.power_spectrum.n_par;
                data.bdNpar0 = external.power_spectrum.dn_par;
                data.bPlhtot = external.power_spectrum.power;
                %
            else% spectrum to be processed
                %
                spectrum = struct;
                if isfield(external,'id'),
                    spectrum.id = external.id;
                end
                spectrum.dP_nz = external.power_spectrum.power;
                spectrum.nz = external.power_spectrum.n_par;
                %   
                data.spectrum = spectrum;
                %
            end
            %
            launchs{1} = imake_launch_LH_jd(basestr,signs,data,opt_gui,select);
            %
            % Case of structure external
            %
        else
            if isfield(external,'LH'),
                %
                select.position_rZ0_opt = 'y';
                %
                fnames = fieldnames(external.LH);
                %
                for a_opt = 1:length(fnames),
                    %
                    fname = fnames{a_opt};
                    %
                    data = struct;
                    data.id = fname;
                    %
                    data.omega_rf = 2*pi*1e9*external.LH.(fname).frequency.flh;
                    data.rZ0 = sort(external.LH.(fname).position.Z);
                    %
                    data.bNpar0 = external.LH.(fname).power_spectrum.n_par;
                    data.bdNpar0 = external.LH.(fname).power_spectrum.dn_par;
                    data.bPlhtot = external.LH.(fname).power_spectrum.power;
                    %
                    launch = imake_launch_LH_jd(basestr,signs,data,opt_gui,select);
                    %
                    launchs = [launchs,launch];
                    %
                end
            end
            %
            if isfield(external,'EC'),
                %
                fnames = fieldnames(external.EC);
                %
                for l_opt = 1:length(fnames),% launcher list
                    %
                    fname = fnames{l_opt};
                    %
                    external.EC.(fname).id = fname;
                    %
                    launch = imake_launch_EAST_jd(external.EC.(fname));
                    %
                    launchs = [launchs,launch];
                    %
                end
                %
            end
        end
        %
    else
        %
        disp(['-----> wave data not yet implemented for :',basestr]);
        return      
        %
    end
    %
else% create default launch structure
    %
    % WAVE TYPE
    %
    % We allow to create structures with arbitrary wave type even is the
    % system is not installed, for predictive calculations
    %
    if any(strcmp(basestr,{'TCV','ITER','D3D'})),
        t_opt_presel = 2;
    elseif any(strcmp(basestr,{'TS','JET','FTU','EAST'})),
        t_opt_presel = 1;
    else
        t_opt_presel = 1;
    end
    %
    t_opt = iselect_jd({'LH','EC'},'Specify wave type',opt_gui,select.style,t_opt_presel) - 1;
    %
    if t_opt == 0,
        %
        type = 'LH';
    else
        %
        type = 'EC';
    end
    %
    % BUILDING LAUNCH
    %
    if strcmp(type,'LH'),
        %
        select.inter = 1;%interactive mode
        %
        launch = imake_launch_LH_jd(basestr,signs,struct,opt_gui,select);
        %
    elseif strcmp(type,'EC'),
        % 
        if strcmp(basestr,'TCV'),% TCV launching data
            %
            % default angles (perpendicular midplane launching)
            %
            angles = imake_angles_TCV_jd('',NaN,NaN,1,NaN,opt_gui,select.style);
            %
            launch = imake_launch_angles_TCV_jd(angles);
            %
        elseif strcmp(basestr,'TS')
            %
            launch = imake_launch_TS_jd('');
            %
        elseif strcmp(basestr,'EAST')
            %
            launch = imake_launch_EAST_jd('',opt_gui,select.style);
            %
        else
            %
            launch = imake_launch_EC_jd;
            %
        end
    else
        %
        disp('-----> wave type not yet implemented');
        %
    end   
    %
    launchs{1} = launch;
    %
end
%
return























wave = '';
wavestruct = struct;
type = '';
%
if ~isempty(external) && ~isfield(external,'wavestructs'),% wave data from external database
    %
    titletext = 'For the wave structure :';      
    s = {'Use data loaded from the external database',...
         'Use data from an existing file',...
         'Build the wave data locally'};
    %    
    i_opt = iselect_jd(s,titletext,opt_gui,select.style,1) - 1;
    %
elseif ~isempty(external) && isfield(external,'wavestructs'),% wave data from wavestructs
    %
    titletext = 'For the wave structure :';      
    s = {'Use data from an existing file',...
         'Build the wave data locally',...
         'Use data from wavestructs'};
    %    
    i_opt = iselect_jd(s,titletext,opt_gui,select.style,1);
    %
else
    %
    titletext = 'For the wave structure :';      
    s = {'Use data from an existing file',...
         'Build the wave data locally'};
    %    
    i_opt = iselect_jd(s,titletext,opt_gui,select.style,1);
    %
end
% 
if i_opt == 0,% use data from external database
    %
    d_opt = 0;% rayinit built from launching conditions
    %
    %
elseif i_opt == 1,% use data from an existing file
    %
    w_opt = input_dke_yp('Code used to generate data : 1 (TORAY), 2 (ART), 3 (AMR), 4 (EVE)',1,1:4,'',[1,1]);
    %
    launch = [];
    %
elseif i_opt == 2,% build the wave data locally
    %
    d_opt = input_dke_yp(['Initial conditions :',...
        '\n0 (user-specified conditions)',...
        '\n1 (from an existing LAUNCH file)',...
        '\n2 (from an existing RAYINIT file)',...
        '\n3 (from an existing ALOHA file)',...
        '\n4 (from TORAY data)',...
        '\n5 (from ART data)',...
        '\n6 (from AMR data)'],0,0:4,'',[1,1]);
    %
    %
    if d_opt == 0,% user-specified initial conditions 
        %
    elseif d_opt == 1,%initial conditions from an existing LAUNCH file 
        %
        launch = iload_struct_jd('launch','LAUNCH',workdir,opt_gui);
        launch = imod_struct_jd(launch,'launch',1,opt_gui);
        %
        type = launch.type;
        %
    elseif d_opt == 2,%initial conditions from an existing RAYINIT file 
        %
        rayinit = iload_struct_jd('rayinit','RAYINIT',workdir,opt_gui);
        rayinit = imod_struct_jd(rayinit,'rayinit',1,opt_gui);
        %
        type = rayinit.type;
        %
    elseif d_opt == 3,%initial conditions from an existing ALOHA file 
        %
        [alohafile,alohapath] = igetfile_jd(opt_gui,'*.*','Please select the ALOHA output file',workdir,0);
        %
        if ischar(alohafile),
            %
            aloha = load([alohapath,alohafile]);
            launch = make_launch_aloha_jd(aloha);
            %
        else
            disp('No file selected, aborted.')
            return
        end
        %
        type = launch.type;
        %
    elseif d_opt == 4,%initial conditions from TORAY 
        %
        disp('-----> initial conditions from TORAY not implemented yet');
        return
        %
    elseif d_opt == 5,% wave from ART calculations
        %
        disp('-----> initial conditions from ART not implemented yet');
        return
        %
    elseif d_opt == 6,% wave from AMR calculations
        %
        disp('-----> initial conditions from AMR not implemented yet');
        return
        %
    end
    %
elseif i_opt == 3,% use data from wavestructs
    %
    d_opt = 0;% rayinit built from launching conditions
    %
    wavestructs = external.wavestructs;
    %
    if length(wavestructs) > 1,
        t_opt = input_dke_yp(['Select the wave number (1:',num2str(length(wavestructs)),')'],1,1:length(wavestructs),'',[1,1]);
    else
        t_opt = 1;
    end
    %
    wavestruct = wavestructs{t_opt};
    %
    % WAVE TYPE
    %
    launch = wavestruct.launch;
    type = launch.type;
    %
end
%
% Select the ray tracing code to be launched from LUKE
%
if any(i_opt == [0,2,3]),
    %
    titletext = 'Which ray-tracing code do you want to run :';      
    s = {'C3PO',...
         'TORAY',...
         'ART',...
         'AMR'};
    %    
    w_opt = iselect_jd(s,titletext,opt_gui,select.style,1) - 1;
    %
    if w_opt == 1,% Run TORAY from LUKE interface
        %
        disp('-----> TORAY run from LUKE not implemented yet');
        return
        %
    elseif w_opt == 2,% Run ART from LUKE interface
        %
        disp('-----> ART run from LUKE not implemented yet');
        return
        %
    end
end
%
% C3PO CALCULATIONS
%
if w_opt == 0; % C3PO Calculation
    %
    % WAVE TYPE AND DEFAULT WAVE PARAMETERS
    %
    if strcmp(type,'LH') || strcmp(type,'IC') || strcmp(type,'FW'),
        %
        ftype = 'LF';
        rtparam = load_structures_yp('rtparam','LH','');
        %
    elseif strcmp(type,'EC') || strcmp(type,'EB'),
        %
        ftype = 'HF';
        rtparam = load_structures_yp('rtparam','EC','');
        %
    else
        %
        disp('-----> wave type not yet implemented');
        return                
        %
    end
    %
    wavestruct = conc_struct_jd(rtparam,wavestruct);
    %
    wavestruct = imod_struct_jd(wavestruct,'wavestruct',1,opt_gui,struct,select.style);
    %
    % BUILDING RAYINIT
    %
    if d_opt <= 1,% rayinit built from launching conditions
        %
        if strcmp(ftype,'HF') && ~isfield(launch,'dNpar0'),
            %
            dNpar0 = 0.06;
            %
            % SPECTRAL WIDTH
            %
            titletext = 'Spectral width :';      
            if isfield(launch,'w0'),
                s = {'Calculated from waist and focal point',...
                     'Fixed value',...
                     'Minimum width within numerical constraints'};
                %    
                dNpar0_opt = iselect_jd(s,titletext,opt_gui,select.style,1) - 1;
                %
            else
                s = {'Specify fixed value',...
                     'Minimum width within numerical constraints'};
                %    
                dNpar0_opt = iselect_jd(s,titletext,opt_gui,select.style,1);
                %
            end
            %
            if dNpar0_opt == 0,
                launch.dNpar0 = NaN;
            elseif dNpar0_opt == 2,
                launch.dNpar0 = 0;
            else
                launch.dNpar0 = input_dke_yp(['Specify fixed dNpar0 value'],dNpar0,[0;Inf],'',[1,1]);
            end
            %
        end
        %
        launch.type = type;
        %
        launch.ns = 1000;
        launch.method = 'cubic';
        %
        % BUILDING RAYINIT
        %
        rayinit = main_rayinit_launch_jd(equil,launch);
        %
        rayinit.id = ['C3PO_',launch.id];
        rayinit.type = launch.type;
        %
        r_opt = iselect_jd({'No','Yes'},'Do you want to save the rayinit structure ?',opt_gui,select.style,1) - 1;
        %
        if r_opt == 1,
            sd = pwd;
            cd(workdir);
            [rayinit_file,rayinit_path] = iputfile_jd(opt_gui,['RAYINIT_',equil.id,'*.mat'],'Please provide the RAYINIT file name',['RAYINIT_',equil.id,'_',rayinit.id,'.mat']);
            %
            if rayinit_file == 0,
                disp('-----> No file name specified, rayinit structure not saved.')
            else
                save([rayinit_path,rayinit_file],'rayinit');
                disp('-----> The rayinit structure is saved')
            end
            cd(sd);
        end        
        %
    end
    %
    % C3PO ray tracing
    %
    sd = pwd;
    cd(workdir);
    %
    wave = main_C3PO_jd(dkepath,rayinit.id,equil,[],rayinit,wavestruct.waveparam,wavestruct.fitparam,wavestruct.rayparam,wavestruct.C3POdisplay,wavestruct.C3POparam);
    %
    cd(sd);
    %
    wave.info.type = 'RT';
    wave.info.RT = 'C3PO';
    wave.info.ftype = ftype;
    %
    s_opt = iselect_jd({'No','Yes'},'Do you want to generate an equivalent make_wave script ?',opt_gui,select.style,1) - 1;
    %
    if s_opt == 'y',
        % 
        imake_makewave_jd(workdir,wave,opt_gui);
        %
    end
    %
    n_rf_list = wavestruct.waveparam.n_rf_list;
    %
elseif w_opt == 1,% TORAY calculations
    %
    wave = imake_wave_TORAY_jd(equil);
    %
    n_rf_list = NaN;
    %
elseif w_opt == 2,% ART calculations
    %
    wave = imake_wave_ART_jd(workdir,equil,opt_gui);
    %
    n_rf_list = NaN;
    %
elseif w_opt == 3, % AMR calculations
    %
    wave = imake_wave_AMR_jd(basestr,equil,launch,workdir,opt_gui);
    %
    n_rf_list = 1:3;
    %
elseif w_opt == 4, % EVE calculations
    %
    wave = imake_wave_EVE_jd(basestr,equil,workdir,opt_gui);
    %
    n_rf_list = 0;
    %
end
%
if isempty(wave),
    return
end
%
% Wave processing and relativistic linear damping
%
wave = wave_process_jd(equil,wave,n_rf_list);
%
