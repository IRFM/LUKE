function wave = imake_wave_jd(basestr,equil,external,workdir,opt_gui)
%
% This function interactively builds the wave structure
%
if nargin < 5,
	opt_gui = 1;
end
%
if nargin < 4,
	workdir = pwd;
end
%
if nargin < 3,
	external = '';
end
%
wave = '';
type = '';
%
if ~isempty(external),% magnetic equilibrium from external database?
    %
    i_opt = input_dke_yp(['Do you want to :\n',...
        '(0) use data loaded from the external database \n',...
        '(1) use data from an existing file \n',...
        '(2) build the wave data locally \n'],...
        0,{0,1,2},'Invalid selection');
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
if i_opt == 0,% use data from from external database
    %
    w_opt = 0;% C3PO calculations
    d_opt = 0;% rayinit built from launching conditions
    %
    if isfield(equil.info,'shotnum');
        shotnum = equil.info.shotnum;
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
            % !!!! Warning : older antenna configurations not yet operational
            %
            if str2num(shotnum) > 0,% !!!! to be specified 
                %
                config = 'MIXTE';
                %
            end
            %
            disp(['-----> The antenna configuration is : ',config]);
            %
            cons(1) = external.LH.Plh_C2*1e6*exp(i*external.LH.npar_C2);
            cons(2) = external.LH.Plh_C3*1e6*exp(i*external.LH.npar_C3);
            %
%             l_opt = input_dke_yp('Directivity of the wave',1,[0;1],'',[1,1]);
            l_opt = input_dke_yp('Do you want to include the negative lobe [y/n]','n',{'y','n'},'',[1,1]);
            %
            if strcmp(l_opt,'y'),
                lob = 'Yes';
            else 
                lob = 'No';
            end
            %
            cons_spec = NaN;
            %
            signe.ip = sign(equil.psi_apRp(end));
            signe.b0 = sign(equil.ptBPHI(1,1));
            %
            launchs = make_wavelaunchs_cronos_lh(equil,signe,config,cons,cons_spec,lob);
            %
            a_str = '(1) C2 antenna, (2) C3 antenna';
            a_opts = [1,2];                    
            %
            if length(a_opts) > 1,
                %
                a_opt = input_dke_yp(['Please select an antenna : ',a_str],1,1:length(a_opts),'',[1,1]);
                %
            else
                a_opt = a_opts;
            end
            %
            launch = launchs{a_opt};
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
elseif i_opt == 2,% build the wave data locally
    %
    w_opt = 0;
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
            launch = imake_launch_LH_jd;
            %
        elseif strcmp(type,'EC'),
            % 
            if strcmp(basestr,'TCV'),% TCV launching data
                %
                angles = imake_angles_TCV_jd;
                %
                if isempty(angles),
                    disp('-----> launching data not determined');
                    return
                end
                %
                launch = imake_launch_angles_TCV_jd(angles);
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
    elseif d_opt == 4,% wave from ART calculations
        %
        disp('-----> initial conditions from AMR not implemented yet');
        return
        %
    end
    %
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
    if strcmp(ftype,'LF'), 
        %
        mmode = -1;
        opt_rf = 1;
        dsmin = 0.01;
        nd = 1;
        nchi = 1;
        n_rf_list = 0;
        %
        reflection = 1;
        %
    else
        %        
        if exist('launch','var') && isfield(launch,'omega_rf'),
            omega_rf = launch.omega_rf;
        elseif exist('rayinit','var') && isfield(rayinit,'omega_rf'),
            omega_rf = rayinit.omega_rf;
        else
            disp('-----> wave frequency not specified');
            return       
        end
        %
        %
        mmode = 1;
        opt_rf = 0;
        dsmin = 0.001;
        nd = 3;
        nchi = 4;
        n_rf_list = max([1,floor(omega_rf/(qe*max(abs(equil.ptBPHI(end,:)))/me))]):...
            ceil(omega_rf/(qe*min(abs(equil.ptBPHI(end,:)))/me));
        %
        reflection = 0;
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
            launch.dNpar0 = input_dke_yp(['Spectral width :',...
                '\n - specify fixed value, or ',...
                '\n - type ''NaN'' if calculated from waist and focal point, or ',...
                '\n - type ''0'' if minimum width within numerical constraints'],dNpar0,[0;Inf],'',[1,1]);
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
    mmode = input_dke_yp('Polarization : (1) m (-1) p, (slow/fast LH wave: -1/+1, O/X mode: -1/+1)',mmode,{-1,1},'',[1,1]);
    %
    %kmode = input_dke_yp('Plasma model for wave propagation : (0:cold, 1:warm, 2:kinetic non rel., 3:weakly rel., 4:fully rel.)',0,0:4,'',[1,1]);
    kmode = input_dke_yp('Plasma model for wave propagation : (0:cold, 1:kinetic)',0,0:1,'',[1,1])*2;
    %
    opt_rf = input_dke_yp('FLR effects : (0:all, 1:small)',opt_rf,0:1,'',[1,1]);
    %
    dsmin = input_dke_yp('Minimum length of ray fragments: [0] :',dsmin,[0;Inf],'',[1,1]);
    %
    nd = input_dke_yp('Number of transverse distance positions for beamlets',nd,1:10,'',[1,1]);
    %
    nchi = input_dke_yp('Number of angular positions for beamlets',nchi,1:12,'',[1,1]);
    %
    %a_sdNpar = input_dke_yp('Spectral width parameter a_sdNpar (m^-1)',0,[0;Inf],'',[1,1]);
    %
    n_rf_list = input_dke_yp('List of cyclotron harmonics to consider in power deposition',n_rf_list,0:10,'');
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
    waveparam.mmode = mmode;
    waveparam.kmode = kmode;
    waveparam.opt_rf = opt_rf;
    waveparam.dsmin = dsmin;
    waveparam.nd = nd;
    waveparam.nchi = nchi;
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
    c3poparam_file = which('C3POPARAM.mat');
    [c3poparam_file,c3poparam_path] = igetfile_jd(opt_gui,'*.*','Please select the C3PO default parameters file',c3poparam_file);
    if c3poparam_file == 0,
        return
    end
    load([c3poparam_path,c3poparam_file],'fitparam','rayparam','C3POparam');
    %
    rayparam.tensortype = kmode;
    rayparam.reflection = reflection;
    %
    c_opt = input_dke_yp('Do you want to see/modify the C3PO parameters [y/n]','n',{'y','n'},'',[1,1]);
    if strcmp(c_opt,'y'),
        %
        fitparam = imod_struct_jd(fitparam,'fitparam',1);
        rayparam = imod_struct_jd(rayparam,'rayparam',1);
		C3POparam = imod_struct_jd(C3POparam,'C3POparam',1);
        %
    end
    %
    % C3P0 ray tracing
    %
    sd = pwd;
    cd(workdir);
    wave = main_C3PO_jd(rayinit.id,equil,rayinit,waveparam,fitparam,rayparam,wavedisplay,C3POparam);
    cd(sd);
    %
    wave.info.type = 'RT';
    wave.info.RT = 'C3PO';
    wave.info.ftype = ftype;
    %
    if d_opt == 0,
        wave.launch = launch;
        if strcmp(basestr,'TCV'),
            wave.angles = angles;
        end
    end
    wave.rayinit = rayinit;
    wave.fitparam = fitparam;
    wave.rayparam = rayparam;
    wave.display = wavedisplay;
    wave.C3POparam = C3POparam;    
    %
elseif w_opt == 1,% wave from TORAY calculations
    %
    wave = imake_wave_TORAY_jd(equil);
    %
    n_rf_list = NaN;
    %
elseif w_opt == 2,% wave from ART calculations
    %
    wave = imake_wave_ART_jd(workdir,equil,opt_gui);
    %
    n_rf_list = NaN;
    %
elseif w_opt == 3,% wave from ART calculations
    %
    wave = imake_wave_AMR_jd(basestr,equil,workdir,opt_gui);
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
      
