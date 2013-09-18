function launch = imake_launch_LH_jd(basestr,equil,external,opt_gui)
%
% This function builts the launch structure for LH waves from external and/or user-specified data
%
if nargin < 4,
    opt_gui = 0;
end
if nargin < 3,
    external = '';
end
%
if nargin < 2,
    error('Not enough arguments')
end
%
signe.ip = sign(equil.psi_apRp(end));
signe.b0 = sign(equil.ptBPHI(1,1));
%
if ~isempty(external),
    %
    if strcmp(basestr,'TS'),
        %
        % !!!! Warning : older antenna configurations not yet operational
        %
        %if str2num(shotnum) > 0,% !!!! to be specified 
            %
            config = 'MIXTE';
            %
        %end
        %
        disp(['-----> The antenna configuration is : ',config]);
        %
        Plh(1) = 1e6*external.Plh_C2;
        Plh(2) = 1e6*external.Plh_C3;
        npar(1) = external.npar_C2;
        npar(2) = external.npar_C3;
        %             l_opt = input_dke_yp('Directivity of the wave',1,[0;1],'',[1,1]);
        l_opt = input_dke_yp('Do you want to include the negative lobe [y/n]','n',{'y','n'},'',[1,1]);
        %
        if strcmp(l_opt,'y'),
            lob = 'Yes';
        else 
            lob = 'No';
        end
        %
    elseif strcmp(basestr,'EAST'),
        %
        Plh = [];
        %
        if isfield(external,'antenna_2p45GHz')
            Plh = [Plh,external.antenna_2p45GHz.total_launched_power.power*1e6];
        end
        %
        if isfield(external,'antenna_4p60GHz')
            Plh = [Plh,external.antenna_4p60GHz.total_launched_power.power*1e6];
        end
        %
        disp(['----> Injected LH power: ',num2str(Plh/1e6),' MW']);
        %
        fexternal = fieldnames(external);
        %
        a_str = '';
        for iw = 1:length(fexternal),
            a_str = [a_str,' (',num2str(iw),') ',fexternal{iw},','];
        end
        %
        if iw > 1,
            %
            a_opt = input_dke_yp(['Please select an antenna :',a_str],1,1:iw,'',[1,1]);
            %
        else
            a_opt = 1;
        end
        %
        power_spectrum = external.(fexternal{a_opt}).power_spectrum;
        frequency = external.(fexternal{a_opt}).frequency;
        position = external.(fexternal{a_opt}).position;
        %
        launch.id = fexternal{a_opt};
        launch.phi0 = 0;
        launch.omega_rf = 2*pi*1e9*frequency.flh;
        launch.LFS = 1;
        launch.m0 = 0;
        %
        disp(['----> The LH antenna has ',int2str(length(position.Z)), ' poloidal rows.']);
        position_rZ0_opt = input_dke_yp('Do you want to consider all of them or just averaged position [y/n]','n',{'y','n'},'',[1,1]);
        %
        if strcmp(position_rZ0_opt,'y'),
            launch.rZ0 = position.Z;
        else 
            launch.rZ0 = sum(position.Z);
            disp(['----> The averaged poloidal position of the LH antenna is ',num2str(launch.rZ0), ' (m).']);
        end
        %
        if ~isfield(power_spectrum,'dn_par'),
            %
            zdP_in = power_spectrum.power;
            zN_in = power_spectrum.n_par;
            %
            zN_in(find(diff(zdP_in)==0)) = [];%remove points with equal power density (for proc_aloha_spec_jd)
            zdP_in(find(diff(zdP_in)==0)) = [];%remove points with equal power density (for proc_aloha_spec_jd)
            %
            [bNpar0,bdNpar0,bPlhtot] = proc_aloha_spec_jd(zN_in,NaN,zdP_in,Plh(a_opt));%ALOHA like spectra
            %
            launch.bPlhtot = bPlhtot;  
            launch.bdNpar0 = bdNpar0;  
            launch.bNpar0 = bNpar0;
            %
        else
            %
            launch.bPlhtot = power_spectrum.power*1e6;  
            launch.bdNpar0 = power_spectrum.dn_par;  
            launch.bNpar0 = power_spectrum.n_par;
            %
        end
    else
        %
        error(['-----> wave data not yet implemented for :',basestr]);
        %
    end
    %
else
    %
    config = basestr;
    %
    nant = 2;%maximum number of antennas in make_wavelaunchs_cronos_lh
    %
    Plh = 1e6*[1]*ones(1,nant);
    npar = -signe.ip*signe.b0*[2]*ones(1,nant);
    %
    lob = 'Yes';
    %
end
%
if strcmp(basestr,'TS') || strcmp(basestr,'JET'),% default values from make_wavelaunchs_cronos_lh
    %
    cons = Plh.*exp(i*npar);
    %
    cons_spec = NaN;
    %
    launchs = make_wavelaunchs_cronos_lh('','',cons,signe,config,lob);
    %
    a_str = '';
    for iw = 1:length(launchs),
        a_str = [a_str,' (',num2str(iw),') ',launchs{iw}.id,','];
    end
    %
    if iw > 1,
        %
        a_opt = input_dke_yp(['Please select an antenna :',a_str],1,1:iw,'',[1,1]);
        %
    else
        a_opt = 1;
    end
    %
    launch = launchs{a_opt};
    %
elseif strcmp(basestr,'EAST'),
    
else % default values
    %
    launch.omega_rf = 2*pi*1e9*4.6;
    launch.LFS = 1;    
    launch.m0 = 0;
    %
    if isnan(launch.m0),
        launch.n0 = 0;
    else
        launch.n0 = NaN;
    end
    %
    launch.phi0 = 0;
    launch.bPlhtot = Plh(1);  
    launch.bNpar0 = npar(1);  
    launch.bdNpar0 = 0.2;
    launch.rZ0 = 0;  
    launch.id = '';
    %
end
%
% Introduction of the tail model for the npar0 fluctuations
%

% N//0 model
%
% Note : The tail spectrum can be described either in a static mode (if
% dtn_fluct_correlation_npar0_lh = Inf) or in a fluctuating mode (if
% dtn_fluct_correlation_npar0_lh < Inf).
%
if length(launch.bNpar0) <= 2,%only if one may main lobe in one or two directions
    %
    tail_opt = input_dke_yp('Do you want to describe the launched power spectrum with the tail model (npar0 fluctuations) [y/n]','n',{'y','n'},'',[1,1]);
    %
    if strcmp(tail_opt,'y'),
    

        dtn_fluct_correlation_npar0_lh = Inf;
        tail_mode = 3;% mode for tail spectrum : (0) no tail model, (1)  Gaussian, (2) Linear, (3) calc_tail_jd
        Nparmax_tail = 0;%npar0 extend from npar_antenna to Nparmax_tail. If Nparmax_tail is 0, it is calculated by the code in main_rayinit_launch_jd.m -> 6.5/sqrt(Te0)
        opt_tail_0 = 0;%Final power fraction of the tail @ Nparmax_tail.
        n_tail = 5;%number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (tail_mode = 3 only). 
        P_tail = 0.5;%Power fraction in the tail. If NaN, it is calculated from n_tail and opt_tail (tail_mode = 3 only). 
        dnpar0_tail = 1;% Adjust (1) or not (0) the initial dNpar0 such that intial and tail lobes have the same width (tail_mode = 3 only).
        %


        tail.dtn = dtn_fluct_correlation_npar0_lh;
        tail.mode = tail_mode;% mode for tail spectrum : (0)  Gaussian, (1) Linear, (2) calc_tail_jd
        tail.bNparmax_tail = Nparmax_tail;%npar0 extend from npar_antenna to Nparmax_tail. If Nparmax_tail is NaN or empty, it is calculated by the code in main_rayinit_launch_jd.m -> 6.5/sqrt(Te0)
        tail.bn_tail = n_tail;%number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (no used if linear_tail is chosen) 
        tail.bP_tail = P_tail;%Power fraction in the tail. If NaN, it is calculated from n_tail and opt_tail (no used if linear_tail is chosen) 
        tail.bopt_tail = opt_tail_0 + dnpar0_tail*1i;%Final power fraction of the tail @ Nparmax_tail (+1i) Adjust initial dNpar0 such that initial and tail lobes have the same width
        %
        if tail_mode > 0,
            locid_tail = make_tail_simulid_jd(tail);
        else
            locid_tail = '';
        end    
        %
        launch.tail = tail;
        %
    end   
end
%
if ~isempty(external),
    %
    return
    %
end
%
launch.i_ref = -1;%index of the flux surface where the rays are launched
%
launch.frequency_GHz = launch.omega_rf/(2*pi*1e9);
launch.phi0_deg = launch.phi0*180/pi;
launch.bPlhtot_MW = launch.bPlhtot/1e6;
launch = rmfield(launch,{'omega_rf','phi0','bPlhtot'});
%
launch = imod_struct_jd(launch,'launch',1,opt_gui);
%
launch.omega_rf = launch.frequency_GHz*(2*pi*1e9);
launch.phi0 = launch.phi0_deg*pi/180;
launch.bPlhtot = launch.bPlhtot_MW*1e6;
launch = rmfield(launch,{'frequency_GHz','phi0_deg','bPlhtot_MW'});
%

