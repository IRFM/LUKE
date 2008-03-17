function wave = imake_wave_jd(workdir,basestr,equil)
%
% This function interactively builds the wave structure
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
    i_opt = input('Option for initial conditions? \n0 (from launching data), \n1 (from an existing RAYINIT file), \n2 (from TORAY), \n3 (from ART) \n: ');
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
        if strcmp(basestr,'TCV'),% TCV launching data
            %
            if isfield(equil.info,'shotnum');
                shotnum = equil.info.shotnum;
            else
                disp('-----> Shot number information missing');
                return
            end
            %
            if isfield(equil.info,'shotime');
                shotime = equil.info.shotime;
            else
                disp('-----> Shot time information missing');
                return
            end
            %
            % LAUNCHING ANGLES
            %
            n_opt = input('Option for launching data? 0 (data file), 1 (TCV database) [0] : ');
            if isempty(n_opt),
                n_opt = 0;
            end
            if ~isnumeric(n_opt) | ~any(n_opt == [0,1]),
                disp('-----> Invalid launching data option');
                return
            end
            %
            if n_opt == 0,% launching data from file
                %
                if isfield(equil.info,'prof');
                    proffile = equil.info.prof;
                else
                    proffile = '';
                end                
                %
                [data_file,data_path] = uigetfile('*.*',['Please select the data file for shot ',shotnum,' at time ',shotime,' :'],proffile);
                %
                if data_file == 0,
                    return
                end
                %
                data = load([data_path,data_file],'shot','laun','angles*');
                %
            elseif n_opt == 1,% launching data from TCV database
                %
                disp('-----> launching data from TCV database not implemented yet');
                return
            end
            %
            angles = imake_angles_TCV_jd(data,shotnum);
            if isempty(angles),
                disp(['-----> launching data not determined for shot :',shotnum]);
                return
            end
            %
            % BUILDING LAUNCH
            %
            launch = imake_launch_angles_TCV_jd(angles);
            %
            launch.type = 'EC';
            launch.omega_rf = angles.freq*2*pi;
            launch.ns = 1000;
            launch.method = 'cubic';
            %
            dNpar0 = input('Spectral width (Choose NaN if calculated from waist and focal point) [0.06] :');
            if isempty(dNpar0),
                dNpar0 = 0.06;
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
        else
            %
            disp(['-----> profiles data not implemented yet for :',basestr]);
            return    
            %
        end
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
            [rayinit_file,rayinit_path] = uiputfile(['RAYINIT_',equil.id,'*.mat'],'Please provide the RAYINIT file name',['RAYINIT_',equil.id,'_',rayinit.id,'.mat']);
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
        [rayinit_file,rayinit_path] = uigetfile(['RAYINIT_',equil.id,'_*.mat'],'Please select the RAYINIT file ',workdir);
        %
        if rayinit_file == 0,
            return
        end
        %
        load([rayinit_path,rayinit_file],'rayinit');
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
    [c3poparam_file,c3poparam_path] = uigetfile('*.*',['Please select the C3PO default parameters file'],c3poparam_file);
    if c3poparam_file == 0,
        return
    end
    load([c3poparam_path,c3poparam_file],'fitparam','rayparam');
    %
    c_opt = input('Do you want to see/modify the C3PO parameters? [y/n] : ','s');
    if strcmp(c_opt,'y'),
        fitparam,rayparam,
        %
        f_opt = input('Do you want to modify fitparam? [y/n] : ','s');
        if strcmp(f_opt,'y'),
            %
            fname = input('Name of fitparam field to modify (press enter if finished): ','s');
            while fname ~= 0,
                %
                if isfield(fitparam,fname),
                    eval(['f_val_o = fitparam.',fname,';']);
                    if isnumeric(f_val_o),
                        f_val_o_s = num2str(f_val_o);
                    else
                        f_val_o_s =f_val_o;
                    end
                    f_val = input(['Provide value for field ',fname,' [',f_val_o_s,'] : ']);
                    if isempty(f_val),
                        f_val = f_val_o;
                    end
                    eval(['fitparam.',fname,' = f_val;']);
                end
                %
                fname = input('Name of fitparam field to modify (press enter if finished): ','s');
            end
        end
        %
        f_opt = input('Do you want to modify rayparam? [y/n] : ','s');
        if strcmp(f_opt,'y'),
            %
            fname = input('Name of rayparam field to modify (press enter if finished): ','s');
            while fname ~= 0,
                %
                if isfield(rayparam,fname),
                    eval(['f_val_o = rayparam.',fname,';']);
                    if isnumeric(f_val_o),
                        f_val_o_s = num2str(f_val_o);
                    else
                        f_val_o_s =f_val_o;
                    end
                    f_val = input(['Provide value for field ',fname,' [',f_val_o_s,'] : ']);
                    if isempty(f_val),
                        f_val = f_val_o;
                    end
                    eval(['rayparam.',fname,' = f_val;']);
                end
                %
                fname = input('Name of rayparam field to modify (press enter if finished): ','s');
            end
        end
        %
    end
    %
    mmode = input('Polarization : (1) m (-1) p, (slow/fast LH wave: -1/+1, O/X mode: -1/+1) :');
    if isempty(mmode) | ~isnumeric(mmode) | ~any(mmode == [-1,1]),
        disp('-----> Invalid polarization option');
        return
    end
    %
    kmode = input('Plasma model for wave propagation : (0:cold, 1:warm, 2:hot, 3:weakly relativistic, 4:fully relativistic) [0] :');
    if isempty(kmode),
        kmode = 0;
    end
    if ~isnumeric(kmode) | ~any(kmode == [0:4]),
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
    nd = input('Number of transverse distance positions for beamlets: [3] :');
    if isempty(nd),
        nd = 3;
    end
    if ~isnumeric(nd),
        disp('-----> Invalid choice');
        return
    end
    %
    nchi = input('Number of angular positions for beamlets: [4] :');
    if isempty(nchi),
        nchi = 4;
    end
    if ~isnumeric(nchi),
        disp('-----> Invalid choice');
        return
    end
    %
    waveparam.mmode = mmode;
    waveparam.kmode = kmode;
    waveparam.opt_rf = opt_rf;
    waveparam.dsmin = dsmin;
    waveparam.nd = nd;
    waveparam.nchi = nchi;
    %
    n_rf_list = NaN;
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
        if strcmp(basestr,'TCV')
            if n_opt == 0,
                wave.info.launch = [data_path,data_file];
            end
            wave.info.angles = angles;
        end
    elseif i_opt == 1,
        wave.info.rayinit = [rayinit_path,rayinit_file];
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
    disp('-----> wave from ART calculations not implemented yet');
    return
end
        


