function antennas = run_aloha_remote(varargin)
%
%LUKE - Run ALOHA remotely for calculating the power spectrum of Tore Supra and WEST.
%
%   Input:
%
%		data_out : LH data structure from Tore Supra or WEST
%		simul_params : ALOHA simulation params
%
%   Output: 
%
%       spectrum : power spectrum structure for LH antennas of Tore Supra and WEST
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin == 1
    %
    antennas = varargin{1};
    %
    for mm = 1:length(antennas)
        %
        if isfield(antennas(mm).aloha,'job')
            %
            antennas(mm).aloha = build_aloha_power_spectrum_yp(antennas(mm).aloha);
            %
        end
        %
    end
    %
elseif nargin == 8
    %
    dkepath = load_structures_yp('dkepath','','');%for remote simulation profiles
    %
    if exist('SLUKE_RFWAVES')
        %
        rfwaves_folder = 'SLUKE_RFWAVES/';
        %
    else
        %
        rfwaves_folder = '';
        %
    end
     %                   
    if ~exist([rfwaves_folder,'ALOHA/Data/'])
        mkdir([rfwaves_folder,'ALOHA/Data/'])
    end
    %
    machine = varargin{1};
    port = varargin{2};
    shot = varargin{3};
    tmin = varargin{4};
    tmax = varargin{5};
    display_results = varargin{6};
    simul_params = varargin{7};
    display_data = varargin{8};
    %
    if ischar(shot)
        shot = str2num(shot);
    end
    %
    if ~exist([rfwaves_folder,'ALOHA/Data/',machine,'_data_lh_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'.mat'])
        %
        data_lh = remote_mlhdata_tsbase(machine,port,shot,tmin,tmax,display_data.display_mode,display_data.display_save,display_data.display_path);
        %
        if ~isfield(data_lh,'err')
            save([rfwaves_folder,'ALOHA/Data/',machine,'_data_lh_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'.mat'],'data_lh')
        else
            antennas.err = data_lh.err;
            return;
        end
    else
        %
        load([rfwaves_folder,'ALOHA/Data/',machine,'_data_lh_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'.mat'],'data_lh');
        %
    end
    %
    n_antennas = length(data_lh);
    %
    % Check simulation parameters consistency
    %
    if ~isfield(simul_params,'id')
        disp(['WARNING : ''id'' field missing in simul_params --> default value : ''test''.']) 
        simul_params.id = 'test';
    end
    %
    if ~isfield(simul_params,'remote')
        disp(['ERROR : ''remote'' field missing in simul_params']) 
        return;
    end
    %
    if ~isfield(simul_params.remote,'profile')
        disp(['WARNING : ''profile'' field missing in simul_params.remote --> default value : 1 for local calculations.']) 
        simul_params.remote.profile = 1;
    end
    %
    if ~isfield(simul_params,'optim')
        %
        disp(['WARNING : ''optim'' field missing in simul_params --> default values are enforced']) 
        simul_params.optim.method = 'fixed ne value';%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
        simul_params.optim.ne_guess = 2.0e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
        simul_params.optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
        simul_params.optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
        simul_params.optim.nitmax = 20;%Maximum number of iterations (if optim.method = 1)
        simul_params.optim.debugmode = 1;%debug if (1)
        %
    else
        %
        if ~isfield(simul_params.optim,'method')
            disp(['WARNING : ''method'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.method = 'fixed ne value';%
        end
        if strcmp(simul_params.optim.method,'fixed ne value') && ~isfield(simul_params.optim,'ne_guess')
            disp(['WARNING : ''ne_guess'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.ne_guess = 2.0e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
        end
        if strcmp(simul_params.optim.method,'ne optimal to fit experimental RC') && ~isfield(simul_params.optim,'tolfun')
        	disp(['WARNING : ''tolfun'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
        end
        if strcmp(simul_params.optim.method,'ne optimal to fit experimental RC') && ~isfield(simul_params.optim,'tolx')
            disp(['WARNING : ''tolx'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
        end
        if strcmp(simul_params.optim.method,'ne optimal to fit experimental RC') && ~isfield(simul_params.optim,'nitmax')
            disp(['WARNING : ''nitmax'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.nitmax = 20;
        end
        %
    end
    %
    % Start remote ALOHA simulation
    %
    m_raws = 2;%The two raws always considered for each antenna
    %
    scheduler.remnum = simul_params.remote.profile;%choice of the remote machine
    %
    if isfield(simul_params.remote,'timeout') && simul_params.remote.timeout > 0
        %
        scheduler.timeout = simul_params.remote.timeout;%timeout is enforced. Waiting for results
        %
    end
    %
    for jj = 1:n_antennas
        %
        for kk = 1:m_raws
            %
            mm = (jj-1)*n_antennas + kk;%simulation index
            %
            sc = scenario_example;%from ALOHA for initialization of the calculations
            %
            sc.options.TSport = data_lh(jj).port;   
            sc.options.choc = data_lh(jj).shot;
            sc.options.tps_1 = data_lh(jj).mean.tmin;
            sc.options.tps_2 = data_lh(jj).mean.tmax;
            %
            sc.options.bool_mesure = true; % activate also the phase correction
            %
            sc.antenna.architecture = data_lh(jj).aloha_architecture;
            %
            sc.plasma.ne0 = simul_params.optim.ne_guess(1);%initial guess (method 1) or fixed value (method 0)
            %
            rc = '';
            %
            sc = aloha_setAntenna(sc,sc.antenna.architecture);%call ALOHA
            %
            if kk == 1
                 %
                 sc.antenna.a_ampl = data_lh(jj).mean.amplitude_mean_aloha_upper;
                 sc.antenna.a_phase = data_lh(jj).mean.phase_mean_aloha_upper;
                 %
                 if strcmp(simul_params.optim.method,'ne optimal to fit experimental RC')
                    rc = data_lh(jj).mean.rc_mean_aloha_upper;
                 end
                 %
            end
            %
            if kk == 2
                %
                sc.antenna.a_ampl = data_lh(jj).mean.amplitude_mean_aloha_lower;
                sc.antenna.a_phase = data_lh(jj).mean.phase_mean_aloha_lower;
                %
                if strcmp(simul_params.optim.method,'ne optimal to fit experimental RC')
                    rc = data_lh(jj).mean.rc_mean_aloha_lower;
                end
                %
            end
            %    
            antennas(mm).aloha = build_aloha_power_spectrum_yp([],sc,rc,simul_params.optim,dkepath,scheduler);%run ALOHA 
            %
        end
    end
end    
    
    
