function wave = imake_wave_jd(dkepath,basestr,equil,external,workdir,opt_gui)
%
% This function interactively builds the wave structure
%
if nargin < 6,
	opt_gui = 1;
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
wave = '';
wavestruct = '';
type = '';
%
if ~isempty(external) && ~isfield(external,'wavestructs'),% wave data from external database
    %
    i_opt = input_dke_yp(['Do you want to :\n',...
        '(0) use data loaded from the external database \n',...
        '(1) use data from an existing file \n',...
        '(2) build the wave data locally \n'],...
        0,{0,1,2},'Invalid selection');
    %
elseif ~isempty(external) && isfield(external,'wavestructs'),% wave data from wavestructs
    %
    i_opt = input_dke_yp(['Do you want to :\n',...
        '(1) use data from an existing file \n',...
        '(2) build the wave data locally \n',...
        '(3) use data from wavestructs \n'],...
        1,{1,2,3},'Invalid selection');
    %
else
    %
    i_opt = input_dke_yp(['Do you want to :\n',...
        '(1) use data from an existing file \n',...
        '(2) build the wave data locally \n'],...
        1,{1,2},'Invalid selection');
    %
end
% 
if i_opt == 0,% use data from external database
    %
    d_opt = 0;% rayinit built from launching conditions
    %
    istru = find(equil.id == '_');
    if length(istru) >= 2 && strcmp(equil.id(1:istru(1)-1),basestr),
        shotnum = equil.id(istru(1)+1:istru(2)-1);
    else           
        disp('-----> Shot number information missing');
        return
    end
    %
    if strcmp(basestr,'TCV'),% TCV launching data
        %
        % BUILDING LAUNCH
        %
        type = 'EC';
        %
        angles = imake_angles_TCV_jd(external,shotnum);
        %
        if isempty(angles),
            disp(['-----> launching data not determined for shot :',shotnum]);
            return
        end
        %
        launch = imake_launch_angles_TCV_jd(angles);
		launch.type = type;
        %
    elseif strcmp(basestr,'TS'),
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
        %
    else
        %
        disp(['-----> wave data not yet implemented for :',basestr]);
        return      
        %
    end
    %
elseif i_opt == 1,% use data from an existing file
    %
    w_opt = input_dke_yp('Code used to generate data : 1 (TORAY), 2 (ART), 3 (AMR)',1,1:3,'',[1,1]);
    %
    launch = [];
    %
elseif i_opt == 2,% build the wave data locally
    %
    d_opt = input_dke_yp(['Initial conditions :',...
        '\n0 (user-specified conditions)',...
        '\n1 (from an existing RAYINIT file)',...
        '\n2 (from TORAY data)',...
        '\n3 (from ART data)',...
        '\n4 (from AMR data)'],0,0:4,'',[1,1]);
    %
    %
    if d_opt == 0,% user-specified initial conditions 
        %
        % WAVE TYPE
        %
        if strcmp(basestr,'TCV'),
            %
            type = 'EC';
            %
        else
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
        end
        %
        % BUILDING LAUNCH
        %
        if strcmp(type,'LH'),
            %
            launch = imake_launch_LH_jd(basestr,equil,'',opt_gui);
            %
        elseif strcmp(type,'EC'),
            % 
            if strcmp(basestr,'TCV'),% TCV launching data
                %
				a_opt = input_dke_yp('Do you want to specify : launcher angles (0) or initial ray parameters (1)',0,0:1,'',[1,1]);
				%
				if a_opt == 0,
					angles = imake_angles_TCV_jd;
					%
					if isempty(angles),
						disp('-----> launching data not determined');
						return
					end
					%
					launch = imake_launch_angles_TCV_jd(angles);
					launch.type = type;
					%
				else
					launch = imake_launch_EC_jd;
				end
                %
            elseif strcmp(basestr,'TS')
                %
                launch = imake_launch_TS_jd('');
                %
            else
                %
                launch = imake_launch_EC_jd;
                %
            end
        else
            %
            disp('-----> wave type not yet implemented');
            return  
            %
        end
        %
    elseif d_opt == 1,%initial conditions from an existing RAYINIT file 
        %
        rayinit = iload_struct_jd('rayinit','RAYINIT',workdir,opt_gui);
        %
        type = rayinit.type;
        %
    elseif d_opt == 2,%initial conditions from TORAY 
        %
        disp('-----> initial conditions from TORAY not implemented yet');
        return
        %
    elseif d_opt == 3,% wave from ART calculations
        %
        disp('-----> initial conditions from ART not implemented yet');
        return
        %
    elseif d_opt == 4,% wave from AMR calculations
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
    w_opt = input_dke_yp('Which ray-tracing code do you want to run ? 0 (C3PO), 1 (TORAY), 2 (ART), 3 (AMR), ',0,0:3,'',[1,1]);
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
    % WAVE TYPE
    %
    if strcmp(type,'LH') || strcmp(type,'IC') || strcmp(type,'FW'),
        %
        ftype = 'LF';
        %
    elseif strcmp(type,'EC') || strcmp(type,'EB'),
        %
        ftype = 'HF';
        %
    else
        %
        disp('-----> wave type not yet implemented');
        return                
        %
    end
    %
    [qe,me] = pc_dke_yp;
    %
    if isfield(wavestruct,'waveparam'),
        %
        waveparam = wavestruct.waveparam;
        %mmode = wavestruct.waveparam.mmode;
        %kmode = wavestruct.waveparam.kmode;
        %opt_rf = wavestruct.waveparam.opt_rf;
        %dsmin = wavestruct.waveparam.dsmin;
        %
        waveparam.nd = 1;
        waveparam.nchi = 1;
        %
        if strcmp(ftype,'LF'),
            %
            reflection = 1;
            method = 'pchip';
            %
        else
            %
            reflection = 0;
            method = 'spline';
            %
        end
        %
    elseif strcmp(ftype,'LF'), 
        %
        waveparam.mmode = -1;
        waveparam.kmode = 0;
        waveparam.opt_rf = 1;
        waveparam.dsmin = 0.01;
        waveparam.nd = 1;
        waveparam.nchi = 1;
        waveparam.n_rf_list = 0;%List of cyclotron harmonics to consider in wave power deposition
        %
        reflection = 1;
		method = 'pchip';
		%
    else
        %        
        %if exist('launch','var') && isfield(launch,'omega_rf'),
        %    omega_rf = launch.omega_rf;
        %elseif exist('rayinit','var') && isfield(rayinit,'omega_rf'),
        %    omega_rf = rayinit.omega_rf;
        %else
        %    disp('-----> wave frequency not specified');
        %    return       
        %end
        %
        waveparam.mmode = 1;
        waveparam.kmode = 0;
        waveparam.opt_rf = 0;
        waveparam.dsmin = 0.001;
        waveparam.nd = 3;
        waveparam.nchi = 4;
        waveparam.n_rf_list = 1:3;%List of cyclotron harmonics to consider in wave power deposition
        %
        reflection = 0;
		method = 'spline';
        %
    end
    %
    % BUILDING RAYINIT
    %
    if d_opt == 0,% rayinit built from launching conditions
        %
        if strcmp(ftype,'HF'), 
            %
            dNpar0 = 0.06;
            %
            % SPECTRAL WIDTH
            %
            if isfield(launch,'w0'),
                launch.dNpar0 = input_dke_yp(['Spectral width :',...
                    '\n - specify fixed value, or ',...
                    '\n - type ''NaN'' if calculated from waist and focal point, or ',...
                    '\n - type ''0'' if minimum width within numerical constraints'],NaN,[0;Inf],'',[1,1]);
                %
            else
                launch.dNpar0 = input_dke_yp(['Spectral width :',...
                    '\n - specify fixed value, or ',...
                    '\n - type ''0'' if minimum width within numerical constraints'],dNpar0,[0;Inf],'',[1,1]);
                %
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
        r_opt = input_dke_yp('Do you want to save the rayinit structure [y/n]','n',{'y','n'},'',[1,1]);
        if strcmp(r_opt,'y'),
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
    waveparam.ns = 1;%Ray smoothing parameter
    %
    waveparam = imod_struct_jd(waveparam,'waveparam',1,opt_gui);
    %
    d_opt = input_dke_yp('Do you want to display the rays [y/n]','n',{'y','n'},'',[1,1]);
    if strcmp(d_opt,'y'),
        wavedisplay.ray = 2;
    else
        wavedisplay.ray = 0;
    end
    %
    p_opt = input_dke_yp('Option for equilibrium figures : -1 (nothing), 0 (print), 1 (print and save), 2 (save)',-1,-1:2,'',[1,1]);
    %
    %waveparam.a_sdNpar = a_sdNpar;
    %
    wavedisplay.equilibrium = 0;
    wavedisplay.p_opt = p_opt;%Printing or saving option of the figures
    %
    if ~isfield(rayinit,'id'),
        rayinit.id = input_dke_yp('The existing rayinit structure has no ''id'' field. Please provide an id','');%backward compatibility
    end
    %
    % RAY, WAVE, AND DISPLAY PARAMETERS
    %
    if isfield(wavestruct,'fitequilparam') && isfield(wavestruct,'rayparam') && isfield(wavestruct,'C3POparam'),
        fitparam = wavestruct.fitequilparam;
        rayparam = wavestruct.rayparam;
        C3POparam = wavestruct.C3POparam;
    else    
        c3poparam_file = which('C3POPARAM.mat');
        [c3poparam_file,c3poparam_path] = igetfile_jd(opt_gui,'*.*','Please select the C3PO default parameters file',c3poparam_file);
        if c3poparam_file == 0,
            return
        end
        load([c3poparam_path,c3poparam_file],'fitparam','rayparam','C3POparam');
    end
    %
    rayparam.tensortype = waveparam.kmode;
    rayparam.reflection = reflection;
	fitparam.method = method;
    %
    c_opt = input_dke_yp('Do you want to see/modify the C3PO parameters [y/n]','n',{'y','n'},'',[1,1]);
    if strcmp(c_opt,'y'),
        %
        fitparam = imod_struct_jd(fitparam,'fitparam',1,opt_gui);
        rayparam = imod_struct_jd(rayparam,'rayparam',1,opt_gui);
		C3POparam.clustermode.main_C3PO_jd = imod_struct_jd(C3POparam.clustermode.main_C3PO_jd,'clustermode',1,opt_gui);
        %
    end
    %
    % C3PO ray tracing
    %
    sd = pwd;
    cd(workdir);
    wave = main_C3PO_jd(dkepath,rayinit.id,equil,rayinit,waveparam,fitparam,rayparam,wavedisplay,C3POparam);
    cd(sd);
    %
    wave.info.type = 'RT';
    wave.info.RT = 'C3PO';
    wave.info.ftype = ftype;
    %
    wave.display = wavedisplay;
    %
    s_opt = input_dke_yp('Do you want to generate an equivalent make_wave script? [y/n]','n',{'y','n'},'',[1,1]);
    %
    if s_opt == 'y',
        % 
        imake_makewave_jd(workdir,wave,opt_gui);
        %
    end
    %
    n_rf_list = waveparam.n_rf_list;
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
