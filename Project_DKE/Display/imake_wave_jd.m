function wave = imake_wave_jd(workdir,basestr,equil,opt_gui)
%
% This function interactively builds the wave structure
%
if nargin < 4,
    opt_gui = 1;
end
%
wave = '';
%
w_opt = input('Option for wave calculation? 0 (C3PO), 1 (TORAY), 2 (ART) [0] : ');
%
if isempty(w_opt),
    w_opt = 0;
end
if ~isnumeric(w_opt) | ~any(w_opt == [0,1,2]),
    disp('-----> Invalid wave option');
    return
end
%
if w_opt == 0,% wave from C3PO calculations
    %
    i_opt = input('Option for initial conditions? \n0 (from launching data), \n1 (from an existing RAYINIT file), \n2 (from TORAY data), \n3 (from ART data) \n[0] : ');
    %
    if isempty(i_opt),
        i_opt = 0;
    end
    if ~isnumeric(i_opt) | ~any(i_opt == [0,1,2,3]),
        disp('-----> Invalid initial conditions option');
        return
    end
    %
    if i_opt == 0,%initial conditions from launching data 
        %
        % WAVE TYPE
        %
        if strcmp(basestr,'TCV'),% TCV launching data
            %
            launch.type = 'EC';            
            %
        elseif strcmp(basestr,'TS'),% TS launching data
            %
            t_opt = input('Option for wave type? 0 (LH), 1 (EC) [0] : ');
            %
            if isempty(t_opt),
                t_opt = 0;
            end
            if ~isnumeric(t_opt) | ~any(t_opt == [0,1]),
                disp('-----> Invalid option');
                return
            end
            %
            if t_opt == 0,
                %
                launch.type = 'LH';
            else
                %
                launch.type = 'EC';
            end
            %
        else
            %
            disp(['-----> wave data not implemented yet for :',basestr]);
            return                
        end
        %
        if strcmp(launch.type,'EC'),
            %
            dNpar0_in = 0.06;
            %
            % LAUNCHING ANGLES
            %
            n_opt = input('Option for launching data? 0 (user specified angles), 1 (shot database) [1] : ');
            if isempty(n_opt),
                n_opt = 1;
            end
            if ~isnumeric(n_opt) | ~any(n_opt == [0,1]),
                disp('-----> Invalid launching data option');
                return
            end
            %
            if strcmp(basestr,'TCV'),% TCV launching data
                %
                if n_opt == 0,% launching data specified by user
                    %
                    shotnum = '';
                    data = '';
                    %
                elseif n_opt == 1,% launching data from TCV database
                    %
                    if isfield(equil.info,'shotnum');
                        shotnum = equil.info.shotnum;
                    else
                        disp('-----> Shot number information missing');
                        return
                    end
                    %
    %             	if isfield(equil.info,'shotime');
    %                 	shotime = equil.info.shotime;
    %             	else
    %                 	disp('-----> Shot time information missing');
    %                 	return
    %             	end
                    %
                    data = load(equil.info.data,'shot','laun','angles*');
                    %
                end
                %
                angles = imake_angles_TCV_jd(data,shotnum);
                %
                if isempty(angles),
                    disp(['-----> launching data not determined for shot :',shotnum]);
                    return
                end
                %
                % BUILDING LAUNCH
                %
                launch = conc_struct_jd(launch,imake_launch_angles_TCV_jd(angles));
                %
            elseif strcmp(basestr,'TS'),% TS launching data
                %
                if n_opt == 0,% launching data specified by user
                    %
                    data = '';
                    %
                elseif n_opt == 1,% launching data from TS database
                    %
                    data = load(equil.info.data,'EC');
                    %
                    if ~isfield(data,'EC'),
                        disp('-----> EC data missing.');
                        return
                    end
                    %
                end
                %
                % BUILDING LAUNCH
                %
                launch = conc_struct_jd(launch,imake_launch_TS_jd(data));
                %
            else
                %
                disp(['-----> EC wave data not implemented yet for :',basestr]);
                return                
            end
            %
            launch.ns = 1000;
            launch.method = 'cubic';
            %
        elseif strcmp(launch.type,'LH'),
            %
            dNpar0_in = 0.2;
            %
            n_opt = input(['Option for wave characteristics? 0 (specify data), 1 (',basestr,' database) [1] : ']);
            %
            if isempty(n_opt),
                n_opt = 1;
            end
            if ~isnumeric(n_opt) | ~any(n_opt == [0,1]),
                disp('-----> Invalid option');
                return
            end
            %
            if n_opt == 0,% launching data specified by user
                %
                
                %
            else % launching data from database
                %
                if isfield(equil.info,'shotnum');
                    shotnum = equil.info.shotnum;
                else
                    disp('-----> Shot number information missing');
                    return
                end
                %
                if strcmp(basestr,'TS'),% TS data
                    %
                    % !!!! Warning : older antenna configurations not yet
                    % operational
                    %
                    if str2num(shotnum) > 0,% !!!! to be specified 
                        %
                        config = 'MIXTE';
                        %
                    end
                    %    
                    data = load(equil.info.data,'LH');
                    %
                    cons(1) = data.LH.Plh_C2*1e6*exp(i*data.LH.npar_C2);
                    cons(2) = data.LH.Plh_C3*1e6*exp(i*data.LH.npar_C3);
                    %
                    a_str = '(1) C2 antenna, (2) C3 antenna';
                    a_opts = [1,2];                    
                    %
                else
                    %
                    disp(['-----> LH wave data not implemented yet for :',basestr]);
                    return                
                end
                %
                disp(['-----> The antenna configuration is : ',config]);
                %
    %             %
    %             l_opt = input(['Directivity of the wave ? (0-1) [1] : ']);
    %             %
    %             if isempty(l_opt),
    %                 l_opt = 1;
    %             end
    %             if ~isnumeric(l_opt) | l_opt < 0 | l_opt > 1,
    %                 disp('-----> Invalid option');
    %                 return
    %             end
                %
                l_opt = input(['Do you want to include the negative lobe ? [y/n] : '],'s');
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
                if length(a_opts) > 1,
                    %
                    a_opt = input(['Please select an antenna ? ',a_str,' [1] : ']);
                    %
                    if isempty(a_opt),
                        a_opt = 1;
                    end
                    if ~isnumeric(a_opt) | ~any(a_opt == a_opts),
                        disp('-----> Invalid option');
                        return
                    end
                else
                    a_opt = a_opts;
                end
                %
                launch = launchs{a_opt};
                %
            end
            %
        else
            %
            disp(['-----> wave type not yet implemented']);
            return                
        end
        %
        % SPECTRAL WIDTH
        %
        dNpar0 = input(['Spectral width (Choose NaN if calculated from waist and focal point) [',num2str(dNpar0_in),'] :']);
        if isempty(dNpar0),
            dNpar0 = dNpar0_in;
        end
        if ~isnumeric(dNpar0),
            disp('-----> Invalid choice');
            return
        end
        if isnan(dNpar0),
            disp('-----> Option not yet implemented');
            return
        end            
        %
        launch.dNpar0 = dNpar0;
        %
        % BUILDING RAYINIT
        %
        rayinit = main_rayinit_launch_jd(equil,launch);
        %
        rayinit.id = ['C3PO_',launch.id];%
        %
        r_opt = input('Do you want to save the rayinit structure? [y/n] : ','s');
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
    elseif i_opt == 1,%initial conditions from an existing RAYINIT file 
        %
        rayinit = iload_struct_jd('rayinit','RAYINIT',workdir,opt_gui);
        %
    elseif i_opt == 2,%initial conditions from TORAY 
        %
        disp('-----> initial conditions from TORAY not implemented yet');
        return
        %
    elseif i_opt == 3,% wave from ART calculations
        %
        disp('-----> initial conditions from ART not implemented yet');
        return
    end
    %
    % RAY, WAVE, AND DISPLAY PARAMETERS
    %
    c3poparam_file = which('C3POPARAM.mat');
    [c3poparam_file,c3poparam_path] = igetfile_jd(opt_gui,'*.*',['Please select the C3PO default parameters file'],c3poparam_file);
    if c3poparam_file == 0,
        return
    end
    load([c3poparam_path,c3poparam_file],'fitparam','rayparam');
    %
    [qe,me] = pc_dke_yp;
    %
    if rayinit.omega_rf < (qe*equil.ptBPHI(1,1)/me)/5,% Low frequency wave (LHW, ICW)
        %
        nd_in = 1;
        nchi_in = 1;
        rayparam.reflection = 1;
        a_sdNpar_in = 0.05;
        %
    else% High frequency wave (ECW, EBW)
        %
        nd_in = 3;
        nchi_in = 4;
        rayparam.reflection = 0;
        a_sdNpar_in = 0;
        %        
    end
    %
    c_opt = input('Do you want to see/modify the C3PO parameters? [y/n] : ','s');
    if strcmp(c_opt,'y'),
        %
        fitparam = imod_struct_jd(fitparam,'fitparam',1);
        rayparam = imod_struct_jd(rayparam,'rayparam',1);
        %
    end
    %
    mmode = input('Polarization : (1) m (-1) p, (slow/fast LH wave: -1/+1, O/X mode: -1/+1) :');
    if isempty(mmode) | ~isnumeric(mmode) | ~any(mmode == [-1,1]),
        disp('-----> Invalid polarization option');
        return
    end
    %
    %kmode = input('Plasma model for wave propagation : (0:cold, 1:warm, 2:kinetic non rel., 3:weakly rel., 4:fully rel.) [0] :');
    kmode = input('Plasma model for wave propagation : (0:cold, 1:kinetic) [0] :')*2;
    if isempty(kmode),
        kmode = 0;
    end
%    if ~isnumeric(kmode) | ~any(kmode == [0:4]),
    if ~isnumeric(kmode) | ~any(kmode == [0,2]),
        disp('-----> Invalid plasma model option');
        return
    end
    %
    opt_rf = input('FLR effects : (0:all, 1:small) [0] :');
    if isempty(opt_rf),
        opt_rf = 0;
    end
    if ~isnumeric(opt_rf) | ~any(opt_rf == [0:1]),
        disp('-----> Invalid FLR effects option');
        return
    end
    %
    dsmin = input('Minimum length of ray fragments: [0] :');
    if isempty(dsmin),
        dsmin = 0;
    end
    if ~isnumeric(dsmin),
        disp('-----> Invalid choice');
        return
    end
    %
    nd = input(['Number of transverse distance positions for beamlets: [',num2str(nd_in),'] :']);
    if isempty(nd),
        nd = nd_in;
    end
    if ~isnumeric(nd),
        disp('-----> Invalid choice');
        return
    end
    %
    nchi = input(['Number of angular positions for beamlets: [',num2str(nchi_in),'] :']);
    if isempty(nchi),
        nchi = nchi_in;
    end
    if ~isnumeric(nchi),
        disp('-----> Invalid choice');
        return
    end
    %
    if a_sdNpar_in > 0,
        a_sdNpar = input(['Spectral width parameter a_sdNpar (m^-1): [',num2str(a_sdNpar_in),'] :']);
        if isempty(a_sdNpar),
            a_sdNpar = a_sdNpar_in;
        end
        if ~isnumeric(a_sdNpar),
            disp('-----> Invalid choice');
            return
        end
    else
        a_sdNpar = a_sdNpar_in;
    end 
    %
    waveparam.mmode = mmode;
    waveparam.kmode = kmode;
    waveparam.opt_rf = opt_rf;
    waveparam.dsmin = dsmin;
    waveparam.nd = nd;
    waveparam.nchi = nchi;
    waveparam.a_sdNpar = a_sdNpar;
    %
    rayparam.tensortype = kmode;
    %
    n_rf_list = [0:3];
    %
    d_opt = input('Do you want to display the rays? [y/n] : ','s');
    if strcmp(d_opt,'y'),
        display.ray = 2;
    else
        display.ray = 0;
    end
    %
    p_opt = input('Option for equilibrium figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save) [-1] : ');
    if isempty(p_opt) | ~isnumeric(p_opt) | ~any(p_opt == [0,1,2]),
        p_opt = -1;
    end
    %
    display.equilibrium = 0;
    display.p_opt = p_opt;%Printing or saving option of the figures
    %
    % C3P0 ray tracing
    %
    sd = pwd;
    cd(workdir);
    %
    if ~isfield(rayinit,'id'),
        while 1,
            rayinit.id = input_dke_yp('The existing rayinit structure has no ''id'' field. Please give it a unique ''id''',' ');%backward compatibility
            if ~isempty(deblank(rayinit.id)),break;end
        end
    end
    wave = main_C3PO_jd(rayinit.id,equil,rayinit,waveparam,fitparam,rayparam,display);
    cd(sd);
    %
    % Wave processing and relativistic linear damping
    %
    wave = wave_process_jd(equil,wave,n_rf_list);
    %
    wave.info.type = 'RT';
    wave.info.RT = 'C3PO';
    %
    if i_opt == 0,
        wave.launch = launch;
        if strcmp(basestr,'TCV'),
            wave.angles = angles;
        end
    end
    wave.rayinit = rayinit;
    wave.fitparam = fitparam;
    wave.rayparam = rayparam;
    wave.display = display;
    %
elseif w_opt == 1,% wave from TORAY calculations
    %
    wave = imake_wave_TORAY_jd(equil);
    %
    if isempty(wave),
        return
    end
    %
    wave = wave_process_jd(equil,wave,NaN);
    %
elseif w_opt == 2,% wave from ART calculations
    %
    wave = imake_wave_ART_jd(workdir,equil);
    %
    if isempty(wave),
        return
    end
    %
    wave = wave_process_jd(equil,wave,NaN);
    %
end
        


