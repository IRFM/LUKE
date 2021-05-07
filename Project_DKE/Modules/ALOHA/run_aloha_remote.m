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
elseif nargin == 6
    %
    dkepath = load_structures_yp('dkepath','','');%for remote simulation profiles
    %
    if ~exist('ALOHA/Data/')
        mkdir('ALOHA/Data/')
    end
    %
    port = varargin{1};
    shot = varargin{2};
    tmin = varargin{3};
    tmax = varargin{4};
    display_mode = varargin{5};
    %
    if ~exist(['ALOHA/Data/data_lh_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'.mat'])
        %
        data_lh = remote_mlhdata_tsbase(port,shot,tmin,tmax,display_mode);
        %
        if ~isfield(data_lh,'err')
            save(['ALOHA/Data/data_lh_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'.mat'],'data_lh')
        else
            antennas.err = data_lh.err
            return;
        end
    else
        %
        load(['ALOHA/Data/data_lh_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'.mat'],'data_lh');
        %
    end
    %
    %
    simul_params = varargin{6};
    %
    n_antennas = length(data_lh.type_signal)/4;
    %
    % Check simulation parameters consistency
    %
    if ~isfield(simul_params,'id')
        disp(['WARNING : ''id'' field missing in simul_params --> default value : ''test''.']) 
        simul_params.id = 'test';
    end
    %
    if ~isfield(simul_params,'profile')
        disp(['WARNING : ''profile'' field missing in simul_params --> default value : 1 for local calculations.']) 
        simul_params.profile = 1;
    end
    %
    if ~isfield(simul_params,'optim')
        disp(['WARNING : ''optim'' field missing in simul_params --> default values are enforced']) 
        simul_params.optim.method = 0;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
        simul_params.optim.ne_guess = 1.0e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
        simul_params.optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
        simul_params.optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
        simul_params.optim.nitmax = 2;%Maximum number of iterations (if optim.method = 1)
    else
        %
        if ~isfield(simul_params.optim,'method')
            disp(['WARNING : ''method'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.method = 0;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
        end
        if ~isfield(simul_params.optim,'ne_guess')
            disp(['WARNING : ''ne_guess'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.ne_guess = 1.0e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
        end
        if ~isfield(simul_params.optim,'tolfun')
        	disp(['WARNING : ''tolfun'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
        end
        if ~isfield(simul_params.optim,'tolx')
            disp(['WARNING : ''tolx'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
        end
        if ~isfield(simul_params.optim,'nitmax')
            disp(['WARNING : ''nitmax'' field missing in simul_params.optim --> default value is enforced']) 
            simul_params.optim.nitmax = 2;%Maximum number of iterations (if optim.method = 1)
        end
        %
    end
    %
    if ~isfield(simul_params,'module')
        %
        simul_params.module.upper = 1;%Power spectrum for upper module of each antenna (1), no calculations (0)
        simul_params.module.lower = 1;%Power spectrum for lower module of each antenna (1), no calculations (0)
        %
        disp(['WARNING : ''module'' field missing in simul_params, module.lower = module.upper = 1 enforced'])  
        %
    else
        if ~isfield(simul_params.module,'upper')
            %
            simul_params.module.upper = 0;%Power spectrum for upper module of each antenna (1), no calculations (0)
            disp(['WARNING : ''upper'' field missing in simul_params, module, module.upper = 0 enforced'])  
            %
        end
        if ~isfield(simul_params.module,'lower')
            %
            simul_params.module.lower = 0;%Power spectrum for lower module of each antenna (1), no calculations (0)
            disp(['WARNING : ''lower'' field missing in simul_params, module, module.lower = 0 enforced'])  
            %
        end
    end
    %
    % Start remote ALOHA simulation
    %
    m_raws = simul_params.module.upper + simul_params.module.lower;%number of raws considered in a simulation
    %
    scheduler.remnum = simul_params.remote.profile;%choice of the remote machine
    %
    for jj = 1:n_antennas
        %
        for kk = 1:m_raws
            %
            mm = (jj-1)*n_antennas + kk;%simulation index
            %
            sc(mm) = scenario_example;%from ALOHA for initialization of the calculations
            %
            sc(mm).options.TSport = data_lh.port(jj,:);   
            sc(mm).options.choc = data_lh.shot;
            sc(mm).options.tps_1 = data_lh.mean.tmin;
            sc(mm).options.tps_2 = data_lh.mean.tmax;
            %
            sc(mm).options.bool_mesure = true; % activate also the phase correction
            %
            sc(mm).antenna.architecture = data_lh.aloha_architectures(jj,:);
            %
            sc(mm).plasma.ne0 = simul_params.optim.ne_guess;%initial guess (method 1) or fixed value (method 0)
            %
            rc = '';
            %
            sc(mm) = aloha_setAntenna(sc(mm),sc(mm).antenna.architecture);%call ALOHA
            %
            if kk == 1 && m_raws == 1
                if simul_params.module.upper
                    %
                    sc(mm).antenna.a_ampl = data_lh.mean.amplitude_mean_aloha_upper;
                    sc(mm).antenna.a_phase = data_lh.mean.phase_mean_aloha_upper;
                    %
                    if simul_params.optim.method == 1
                        rc = data_lh.mean.rc_mean_aloha_upper;
                    end
                elseif kk == 1 && simul_params.module.lower
                    %
                    sc(mm).antenna.a_ampl = data_lh.mean.amplitude_mean_aloha_lower;
                    sc(mm).antenna.a_phase = data_lh.mean.phase_mean_aloha_lower;
                    %
                    if simul_params.optim.method == 1
                        rc = data_lh.mean.rc_mean_aloha_lower;
                    end
                end
            elseif kk == 1 && m_raws == 2
                 %
                 sc(mm).antenna.a_ampl = data_lh.mean.amplitude_mean_aloha_upper;
                 sc(mm).antenna.a_phase = data_lh.mean.phase_mean_aloha_upper;
                 %
                 if simul_params.optim.method == 1
                    rc = data_lh.mean.rc_mean_aloha_upper;
                 end
            elseif kk == 2 && m_raws == 2
                %
                sc(mm).antenna.a_ampl = data_lh.mean.amplitude_mean_aloha_lower;
                sc(mm).antenna.a_phase = data_lh.mean.phase_mean_aloha_lower;
                %
                if simul_params.optim.method == 1
                    rc = data_lh.mean.rc_mean_aloha_lower;
                end
            end
            %
             %   sc.antenna.a_ampl = sc.antenna.a_ampl(1,:)';% (first row is considered for coupling calculations, other rows are considered later)
   % sc.antenna.a_phase = sc.antenna.a_phase(1,:)';
    
            antennas(mm).aloha = build_aloha_power_spectrum_yp([],sc(mm),rc,simul_params.optim,dkepath,scheduler);%run ALOHA 
            %
        end
    end
end    
    
    
