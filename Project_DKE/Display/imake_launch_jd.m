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
if isempty(equil) && isfield(external,'equil'),
    equil = external.equil;
end
%
if ~isfield(select,'style'),
    select.style = struct;
end
%    
if isfield(equil,'psi_apRp'),
    signs.ip = sign(equil.psi_apRp(end));
elseif isfield(equil,'ip'),
    signs.ip = sign(equil.ip);
else
    signs.ip = 1;
end
%
if isfield(equil,'ptBPHI'),
    signs.b0 = sign(equil.ptBPHI(1,1));
elseif isfield(equil,'b0'),
    signs.b0 = sign(equil.b0);
else
    signs.b0 = 1;
end
%
launchs = {};
%
if ~isempty(external),% import wave data from external structure
    %
    if isempty(equil),
        error('no equilibrium provided')
    end        
    %
    if isfield(equil,'shotnum'),
        shotnum = equil.shotnum;
    else
        istru = find(equil.id == '_');
        if length(istru) >= 2 && strcmp(equil.id(1:istru(1)-1),basestr),
            shotnum = equil.id(istru(1)+1:istru(2)-1);
        else           
            disp('-----> Shot number information missing. Abort imake_launch_jd.m');
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
    elseif strcmp(basestr,'TS') || strcmp(basestr,'WEST') || strcmp(basestr,'EAST') || strcmp(basestr,'HL2A')
        %
        % Case of LH spectrum from ALOHA file
        %
        if isfield(external,'LH'),
            %
            select.position_rZ0_opt = 'y';
            %
            if strcmp(basestr,'TS') || strcmp(basestr,'WEST')
                external.LH = order_antenna_TS_WEST(external);
            end
            %
            fnames = fieldnames(external.LH);
            %
            for a_opt = 1:length(fnames),
                %
                fname = fnames{a_opt};
                %
                if isfield(external.LH.(fname),'aloha') && ~isfield(external.LH.(fname),'power_spectrum') && ~isfield(external,'antenna')
                    aloha_opt = 0;
                elseif isfield(external.LH.(fname),'aloha') && isfield(external.LH.(fname),'power_spectrum') && isfield(external,'antenna')
                    aloha_opt = input_dke_yp([fname,' : Calculation of the power spectrum using ALOHA [0] or consider an external power spectrum [1] or an already calculated ALOHA spectrum [2] ? '],0,0:2,'',[1,1]);
                elseif isfield(external.LH.(fname),'aloha') && isfield(external.LH.(fname),'power_spectrum') && ~isfield(external,'antenna')
                     aloha_opt = input_dke_yp([fname,' : Calculation of the power spectrum using ALOHA [0] or consider an external power spectrum [1] ? '],0,0:1,'',[1,1]);
                elseif isfield(external.LH.(fname),'aloha') && ~isfield(external.LH.(fname),'power_spectrum') && isfield(external,'antenna')
                      aloha_opt = input_dke_yp([fname,' : Calculation of the power spectrum using ALOHA [0] or consider an already calculated ALOHA spectrum [1] ? '],0,0:1,'',[1,1]);
                      if aloha_opt == 1,
                          aloha_opt = 2;
                      end
                elseif ~isfield(external.LH.(fname),'aloha') && isfield(external.LH.(fname),'power_spectrum') && isfield(external,'antenna')
                      aloha_opt = input_dke_yp('Consider an external power spectrum [0] or an already calculated ALOHA spectrum [1] ? ',0,0:1,'',[1,1]);
                      aloha_opt = aloha_opt + 1;
                end
                %
                if isfield(external.LH.(fname),'aloha') && ~isfield(external.LH.(fname),'power_spectrum') && ~isfield(external,'antenna')
                    aloha_opt = 0;
                end
                %
                if ~isfield(external.LH.(fname),'aloha') && isfield(external.LH.(fname),'power_spectrum') && ~isfield(external,'antenna')
                    aloha_opt = 1;
                end
                %
                if ~isfield(external.LH.(fname),'aloha') && ~isfield(external.LH.(fname),'power_spectrum') && isfield(external,'antenna')
                    aloha_opt = 2;
                end
                %
                if ~isfield(external.LH.(fname),'aloha') && ~isfield(external.LH.(fname),'power_spectrum') && ~isfield(external,'antenna')
                    error('ERROR: no data for the LH power spectrum in the external structure.')
                end
                %
                if aloha_opt == 0,% calculate power spectrum with ALOHA remotely
                    %
                    if strcmp(basestr,'EAST')
                        external.antenna = make_aloha_EAST_yp(external.LH.(fname).aloha,external.LH.(fname).antenna_measured);
                    elseif strcmp(basestr,'HL2A')
                        external.antenna = make_aloha_HL2A_yp(external.LH.(fname).aloha,external.LH.(fname).antenna_measured);
                    elseif strcmp(basestr,'TS')
                        external.antenna = make_aloha_TS_yp(external.LH.(fname).aloha,external.LH.(fname).antenna_measured);
                    elseif strcmp(basestr,'WEST')
                        external.antenna = make_aloha_WEST_yp(external.LH.(fname).aloha,external.LH.(fname).antenna_measured);
                    else
                        error(['Wrong basestr = ''',basestr,''' in imake_launch_jd.m'])
                    end
                    %
                    if isfield(external.antenna,'job')
                        launch.job = external.antenna.job;%remote ALOHA calculation
                        launch.id = [fname,'_ALOHA_nlh_optim_rc'];
                        launch.basestr = basestr;
                        launch.signs = signs;
                        launchs = [launchs,launch];
                    else
                        aloha_opt = 2;% for post-processing analysis when ALOHA is results are obtained
                    end
                end
                %
                if aloha_opt == 2
                    launch = build_spectrum_from_aloha(external,basestr,signs,opt_gui,select);
                    %
                    if isfield(external.antenna,'id')
                        launch.id = external.antenna.id;
                    end
                    %
                    if ~isempty(launch)
                        launchs = [launchs,launch];
                    else
                        return
                    end
                end
                %
                if aloha_opt == 1,% Case of LH spectrum from file
                    %
                    if isfield(external.LH.(fname),'power_spectrum'),
                        %
                        data = struct;
                        %
                        launchsfile = ['get_launchs_',basestr];
                        %
                        if isfield(external.LH.(fname),'id') && exist(launchsfile,'file');
                            [~,a_list] = feval(launchsfile);
                            na_list = length(a_list);
                            a_opt = false(1,na_list);
                            %    
                            for ia_list = 1:na_list,
                                %
                                a_opt(ia_list) = any(strfind(lower(external.LH.(fname).id),lower(a_list{ia_list})));
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
                        data.id = fname;
                        data.omega_rf = 2*pi*1e9*external.LH.(fname).frequency.flh;
                        data.rZ0 = sort(external.LH.(fname).position.Z);
                        %
                        if isfield(external.LH.(fname).power_spectrum,'dn_par'),% lobes already processed
                            %
                            data.bNpar0 = external.LH.(fname).power_spectrum.n_par;
                            data.bdNpar0 = external.LH.(fname).power_spectrum.dn_par;
                            data.bPlhtot = external.LH.(fname).power_spectrum.power*1e6;
                            %
                        else% spectrum to be processed
                            %
                            spectrum = struct;
                            if isfield(external.LH.(fname),'id'),
                                spectrum.id = external.LH.(fname).id;
                            end
                            spectrum.dP_nz = external.LH.(fname).power_spectrum.power;
                            spectrum.nz = external.LH.(fname).power_spectrum.n_par;
                            %   
                            data.spectrum = spectrum;
                            %
                        end
                        %
                        launch = imake_launch_LH_jd(basestr,signs,data,opt_gui,select);
                        %
                        launchs = [launchs,launch];
                        %
                        % Case of structure external
                        %
                    else
                        %
                        data = struct;
                        data.id = fname;
                        %
                        data.omega_rf = 2*pi*1e9*external.LH.(fname).frequency.flh;
                        data.rZ0 = sort(external.LH.(fname).position.Z);
                        %
                        data.bNpar0 = external.LH.(fname).power_spectrum.n_par;
                        data.bdNpar0 = external.LH.(fname).power_spectrum.dn_par;
                        data.bPlhtot = external.LH.(fname).power_spectrum.power*1e6;
                        %
                        launch = imake_launch_LH_jd(basestr,signs,data,opt_gui,select);
                        %
                        launchs = [launchs,launch];
                        %
                    end
                end
            end
        elseif isfield(external,'EC'),
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
    elseif strcmp(basestr,'AUG'),% AUG launching data
        %
        % BUILDING LAUNCH
        %
        type = 'EC';
        %
        if isfield(external,'mmode'),% array of wave structure for each gyrotron
            nw = size(external,1);% number of gyrotrons
            gyrotrons = cell(1,nw);
            for iw=1:nw
                gyrotrons{iw} = external(iw,:);
                gyrotrons{iw}.id = ['EC_gy',num2str(iw)];
            end
        else % each gyrotron is represented by a field in wave structure
            fnames = fieldnames(rmfield(external,'equil'));
            nw = length(fnames);
            gyrotrons = cell(1,nw);
            for iw=1:nw
                gyrotrons{iw} = external.(fnames{iw});
                gyrotrons{iw}.id = fnames{iw};
            end
        end
        %
        for iw = 1:nw 
            launch.id = gyrotrons{iw}.id;
            launch.type = type;
            launch.mmode = gyrotrons{iw}.mmode;
            launch.omega_rf = gyrotrons{iw}.f_GHz*2*pi*1e9;
            launch.yR_L = gyrotrons{iw}.R_L;
            launch.yZ_L = gyrotrons{iw}.Z_L;
            launch.yphi_L = 0;
            launch.yalpha_L = gyrotrons{iw}.alpha_L;
            launch.ybeta_L = gyrotrons{iw}.beta_L;
            launch.yP_L = gyrotrons{iw}.P_MW*1e6;
            %
            if isfield(gyrotrons{iw},'w0')
                launch.w0 = gyrotrons{iw}.w0;
            else
                launch.w0 = 0.02;% test values
            end
            if isfield(gyrotrons{iw},'z0')
                launch.z_L = gyrotrons{iw}.z0;
            else
                launch.z_L = 0.4;% test values
            end
            %
            launch.dNpar0 = NaN;%Calculated from waist and focal point
            %
            launch.external = gyrotrons{iw};
            %
            launchs{end+1} = launch;
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
        elseif strcmp(basestr,'KSTAR')
            %
            launch = imake_launch_KSTAR_jd('',opt_gui,select.style);
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
