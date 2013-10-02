function launch = imake_launch_LH_jd(basestr,signs,data,opt_gui,select)
%
% This function builts the launch structure for LH waves from external data and/or user-specified data
%
% - The data structure is assumed to have a standard form here. 
%
% - Processing of original data structures (ex : external) is done upstream, for example
%   in imake_launch_jd.
%
% - The data structure may also be originally loaded from the output of 
%   spectrum codes or files.
%
%   - INPUTS : 
%       - basestr           : tokamak name [string]
%
%       - signs (optional)  : signs [struct]
%           o ip : sign of current seen from top. (1) if clockwise, (-1) otherwise
%           o b0 : sign of toroidal field seen from top. (1) if clockwise, (-1) otherwise
%
%       - data (optional)   : [struct] data structure with the following optional fields :
%           o id : antenna identification, could exist in get_launchs_* file [string}
%           o type : must be 'LH'
%           o omega_rf :  wave angular frequency (rad/s) [1,1]
%           o rZ0 :  vertical launching positions (m) [1,m_pol]
%           o phi0 : toroidal angle position [1,1]
%           o LFS : (-1) high field side launching, (1) low field side launching [1,1]
%           o spectrum : spectrum structure with the following fields
%               - param_tor : parameters structure for toroidal direction :
%                   o nlobes : number of lobes selected
%                   o dir : sort peaks according to : 
%                       (0) P     + preserve repartition and total power 
%                       (1) P/N^2 + preserve directivity and repartition 
%                       (2) P/N^2 + preserve directivity and total power (treating positive and negative spectra as blocks. Warning : some transfer of P/N^2 across N=0 necessary in this case)
%                       (3) P/N^2 + preserve repartition and total power 
%                   o mode : process mode :
%                       (0) select a number of Gaussian peaks left unchanged (WARNING : total power less than Pin)
%                       (1) assemble peaks fixing Pmax and N, allowing dN to change
%                       (2) assemble peaks allowing Pmax, N and dN to change
%               - param_pol : parameters structure for poloidal direction :
%                   o same as param_tor
%                   o opt_ny : treat poloidal direction in (0) real space with multiple vertical positions, or (1) with poloidal spectral lobes
%
%       - opt_gui (optional): (false, defaut) use of command line (true) use of an independent GUI, (handle) GUI used within handle (ex : iluke) [boolean or handle]
%
%       - select (optional) : structure containing the following optional fields :
%           o style [struct] (style properties for GUI. See iselect_jd and graph1D_jd for specific properties 
%           o inter : interactive mode (1) or not (0)
%           o tail : tail model with (1) 5 lobes, or (0) disabled : 0 lobes
%           o mode : display (0) none (1) text only (2) text and figures (default : 0)
%           o axs (optional) : use axs to plot spectrum (iluke only)
%
if nargin < 5,
    select = struct;
end
if nargin < 4,
    opt_gui = false;
end
if nargin < 3,
    data = struct;
end
if nargin < 2,
    signs = struct;
end
if nargin < 1,
    basestr = 'default';
end
%
if ~isfield(select,'style'),
    select.style = struct;
end
%
if ~isfield(signs,'ip'),
    signs.ip = 1;
end
if ~isfield(signs,'b0'),
    signs.b0 = -1;% to keep default npar positive for co-current
end
%
% ********** FIXED ANTENNA PARAMETERS **********
%
% default launch structure
%
launchs_default = get_launchs_default;
launch_default = launchs_default{1};
%
% select main antenna properties from get_launchs_* file
%
launchsfile = ['get_launchs_',basestr];
%
if exist(launchsfile,'file'),% antennas for this tokamak are registered in this file
    launchs = feval(launchsfile);
else
    launchs = {};
end
%
nlaunchs = length(launchs);
%
s = cell(1,nlaunchs);
for ilaunch = 1:nlaunchs,
    s{ilaunch} = launchs{ilaunch}.id;
end
%
% see whether antenna is pre-selected in data or not
%
if isfield(data,'id'),% Antenna id specified in data structure
    ilaunch = find(strcmp(s,data.id),1,'first');
    %    
    if isempty(ilaunch),% antenna id not found in get_launchs_* file
        disp(['Antenna id ',data.id,' not found in ',launchsfile,'. Default parameters used for missing fields'])
    end
    %
elseif nlaunchs > 0,% select antenna from list
    %
    if nlaunchs == 1,
        ilaunch = 1;
    else
        titletext = ['Select antenna for tokamak ',basestr,' :'];      
        %    
        ilaunch = iselect_jd(s,titletext,opt_gui,select.style,1);
        %
    end
    %
    disp(['Antenna selected from ',launchsfile,' : ',launchs{ilaunch}.id]);
    %
else
    %
    ilaunch = [];
    %
    disp('Default Antenna selected. Default parameters used for missing fields');
    %
end
%
if isempty(ilaunch),% default launch parameters overriden by data
    %
    launch = conc_struct_jd(launch_default,selectfields_jd(data,{'id','type','omega_rf','rZ0','phi0','LFS'},false));    
    %
else% launch parameters from antenna
    %
    launch = launchs{ilaunch};
    %
    if isfield(data,'omega_rf') && data.omega_rf ~= launch.omega_rf,
        disp(['WARNING : the frequency was changed from ',num2str(launch.omega_rf/(2*pi*1e9)),' to ',num2str(data.omega_rf/(2*pi*1e9)),' GHz.']);
        launch.omega_rf = data.omega_rf;
    end
    %
    if isfield(data,'rZ0') && (any(size(data.rZ0) ~= size(launch.rZ0)) || any(data.rZ0 ~= launch.rZ0)),
        disp(['WARNING : the vertical positions were changed from ',num2str(launch.rZ0),' to ',num2str(data.rZ0),' m.']);
        launch.rZ0 = data.rZ0;
    end
    %
    if isfield(data,'phi0') && data.phi0 ~= launch.phi0,
        disp(['WARNING : the toroidal launching position was changed from ',num2str(launch.phi0*180/pi),' to ',num2str(data.phi0*180/pi),'°.']);
        launch.phi0 = data.phi0;
    end
    %
    if isfield(data,'LFS') && data.LFS ~= launch.LFS,
        str = {'HFS','LFS'};
        disp(['WARNING : the position was changed from ',str{1+(launch.LFS == 1)},' to ',str{1+(launch.LFS == 1)},'.']);
        launch.LFS = data.LFS;
    end
    %
end
%
% ********** SPECTRAL PARAMETERS **********
%
launch = rmfield(conc_struct_jd(launch,launch.default),'default');% create default missing fields
%
launch.bNpar0 = - launch.bNpar0*signs.ip*signs.b0;% default bNpar0 adjusted for co-current
%
if isfield(data,'spectrum'),% spectral parameters specified by data - to be processed by proc_aloha_spec_jd
    %
    if ~isfield(data.spectrum,'param_tor'),
        % Default toroidal spectrum treatment is :
        % - to keep main lobes unchanged
        % - select them by order of decreasing P/N^2
        %
        data.spectrum.param_tor.nlobes = length(launch.bNpar0); 
        data.spectrum.param_tor.dir = 1;
        data.spectrum.param_tor.mode = 0;
    end
    %
    if ~isfield(data.spectrum,'param_pol'),
        %
        % Default poloidal spectrum treatment is :
        % - treat poloidal direction in real space with multiple vertical positions, 
        % otherwise
        % - to keep 2 main lobes unchanged
        % - select them by order of decreasing power
        %
        data.spectrum.param_pol.opt_ny = 0;
        %
        data.spectrum.param_pol.nlobes = 2; 
        data.spectrum.param_pol.dir = 0;
        data.spectrum.param_pol.mode = 0;
    end
    %
    launch.spectrum = data.spectrum;
    %
    select.opt_gui = opt_gui;
    %
    [launch.bNpar0,launch.bdNpar0,launch.bPlhtot,launch.spectrum.param_tor,launch.spectrum.param_pol] = iproc_spectrum_jd(data.spectrum,select,signs);
    %
else% spectral parameters directly specified - no spectrum to process
    %
    launch = conc_struct_jd(launch,selectfields_jd(data,{'bNpar0','bdNpar0','bPlhtot','m0','i_ref','mmode'},false));% replace default values by prescription from data  
    %
end
%
if ~isfield(select,'tail'),
    if isfield(select,'inter') && select.inter,% interactive mode
        select.tail = iselect_jd({'No','Yes'},'Include spectral tail model with 5 tail lobes?',opt_gui,select.style,1) - 1;
    else
        select.tail = 0;
    end
end
%
tail = struct;
tail.dtn = Inf;
tail.mode = 3;% mode for tail spectrum : (0) no tail model, (1)  Gaussian, (2) Linear, (3) calc_tail_jd
tail.bNparmax_tail = 0;%npar0 extend from npar_antenna to Nparmax_tail. If Nparmax_tail is NaN or empty, it is calculated by the code in main_rayinit_launch_jd.m -> 6.5/sqrt(Te0)
if select.tail,
    tail.bn_tail = 5;%number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (no used if linear_tail is chosen) 
else
    tail.bn_tail = 0;%number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (no used if linear_tail is chosen) 
end
tail.bP_tail = 0.5;%Power fraction in the tail. If NaN, it is calculated from n_tail and opt_tail (no used if linear_tail is chosen) 
tail.bopt_tail = 1 + 1i;%Final power fraction of the tail @ Nparmax_tail (+1i) Adjust initial dNpar0 such that initial and tail lobes have the same width
%
launch.tail = tail;
%
return
%

if ~isempty(external),
    %
    if isfield(external,'plasma') && isfield(external,'antenna'),% spectrum from ALOHA type structure
    elseif strcmp(basestr,'TS'),
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
        fexternal = fieldnames(external);
        %
        if isfield(select,'a_opt'),
            a_opt = select.a_opt;
        else
            %
            s = fexternal;
            for iw = 1:length(s),
                s{iw} = [s{iw},' ; Injected LH power : ',num2str(external.(fexternal{iw}).total_launched_power.power/1e6),' MW'];
            end
            a_opt = fexternal{iselect_jd(s,'Please select an antenna :',opt_gui,select.style,1)};
        end
        %
        omega_rf = 2*pi*1e9*external.(a_opt).frequency.flh;
        if isfield(launch,'omega_rf') && launch.omega_rf ~= omega_rf,
            disp(['WARNING : the frequency was changed from ',num2str(launch.omega_rf/(2*pi*1e9)),' to ',num2str(omega_rf/(2*pi*1e9)),' GHz.']);
        end
        launch.omega_rf = omega_rf;
        %
        rZ0 = external.(a_opt).position.Z;
        if isfield(launch,'rZ0') && launch.rZ0 ~= rZ0,
            disp(['WARNING : the vertical positions were changed from ',num2str(launch.rZ0),' to ',num2str(rZ0),' m.']);
        end
        launch.rZ0 = rZ0;
        %
        launch.id = a_opt;
        launch.phi0 = 0;
        
        launch.LFS = 1;
        launch.m0 = 0;
        %
        disp(['----> The LH antenna has ',int2str(length(position.Z)), ' poloidal rows.']);
        %
        if isfield(select,'position_rZ0_opt'),
            position_rZ0_opt = select.position_rZ0_opt;
        else
            position_rZ0_opt = input_dke_yp('Do you want to consider all poloidal rows [y]','y',{'y','n'},'',[1,1]);
        end
        %
        if strcmp(position_rZ0_opt,'y'),
            launch.rZ0 = position.Z;
        else 
            launch.rZ0 = sum(position.Z);
            disp(['----> The averaged poloidal position of the LH antenna at the vertical position Zant = ',num2str(launch.rZ0), ' (m).']);
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
    % default spectrum values for the antenna specified
    %
    launch = rmfield(conc_struct_jd(launch,launch.default),'default');
    %
    launch.bNpar0 = - launch.bNpar0*signe.ip*signe.b0;
    %
end
%
% if strcmp(basestr,'TS') || strcmp(basestr,'JET'),% default values from make_wavelaunchs_cronos_lh
%     %
%     cons = Plh.*exp(i*npar);
%     %
%     cons_spec = NaN;
%     %
%     launchs = make_wavelaunchs_cronos_lh('','',cons,signe,config,lob);
%     %
%     a_str = '';
%     for iw = 1:length(launchs),
%         a_str = [a_str,' (',num2str(iw),') ',launchs{iw}.id,','];
%     end
%     %
%     if iw > 1,
%         %
%         a_opt = input_dke_yp(['Please select an antenna :',a_str],1,1:iw,'',[1,1]);
%         %
%     else
%         a_opt = 1;
%     end
%     %
%     launch = launchs{a_opt};
%     %
% elseif strcmp(basestr,'EAST'),
%     
% else % default values
%     %
%     launch.omega_rf = 2*pi*1e9*4.6;
%     launch.LFS = 1;    
%     launch.m0 = 0;
%     %
%     if isnan(launch.m0),
%         launch.n0 = 0;
%     else
%         launch.n0 = NaN;
%     end
%     %
%     launch.phi0 = 0;
%     launch.bPlhtot = Plh(1);  
%     launch.bNpar0 = npar(1);  
%     launch.bdNpar0 = 0.2;
%     launch.rZ0 = 0;  
%     launch.id = '';
%     %
% end
%

%
% Introduction of the tail model for the npar0 fluctuations
%
% Note : The tail spectrum can be described either in a static mode (if
% dtn_fluct_correlation_npar0_lh = Inf) or in a fluctuating mode (if
% dtn_fluct_correlation_npar0_lh < Inf).
%
if isfield(select,'tail') && select.tail,% add default tail model
    tail.dtn = Inf;
    tail.mode = 3;% mode for tail spectrum : (0) no tail model, (1)  Gaussian, (2) Linear, (3) calc_tail_jd
    tail.bNparmax_tail = 0;%npar0 extend from npar_antenna to Nparmax_tail. If Nparmax_tail is NaN or empty, it is calculated by the code in main_rayinit_launch_jd.m -> 6.5/sqrt(Te0)
    tail.bn_tail = 0;%number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (no used if linear_tail is chosen) 
    tail.bP_tail = 0.5;%Power fraction in the tail. If NaN, it is calculated from n_tail and opt_tail (no used if linear_tail is chosen) 
    tail.bopt_tail = 1 + 1i;%Final power fraction of the tail @ Nparmax_tail (+1i) Adjust initial dNpar0 such that initial and tail lobes have the same width
    %
    launch.tail = tail;
    %
elseif length(launch.bNpar0) <= 2,%only if one may main lobe in one or two directions
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
% launch.id = make_launchid_jd(launch);
%
if ~isempty(external),
    %
    return
    %
end
%
% launch.i_ref = -1;%index of the flux surface where the rays are launched
% %
% launch.frequency_GHz = launch.omega_rf/(2*pi*1e9);
% launch.phi0_deg = launch.phi0*180/pi;
% launch.bPlhtot_MW = launch.bPlhtot/1e6;
% launch = rmfield(launch,{'omega_rf','phi0','bPlhtot'});
% %
% launch = imod_struct_jd(launch,'launch',1,opt_gui);
% %
% launch.omega_rf = launch.frequency_GHz*(2*pi*1e9);
% launch.phi0 = launch.phi0_deg*pi/180;
% launch.bPlhtot = launch.bPlhtot_MW*1e6;
% launch = rmfield(launch,{'frequency_GHz','phi0_deg','bPlhtot_MW'});
% %

