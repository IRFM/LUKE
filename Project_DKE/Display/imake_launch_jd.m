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
            opt_module = iselect_jd({'full antenna','upper module','lower module'},'This ALOHA spectrum corresponds to :',opt_gui,select.style,1);
            %
            if opt_module > 1,
                pfac = 1/2;
                pstr = ' (half antenna)';
            else
                pfac = 1;
                pstr = '';
            end                
            %
            val(1) = sum(external.antenna.dP_nz*external.antenna.dnz);
            s{1} = ['Power from ALOHA spectrum',pstr,'        : PLH = ',num2str(val(1)/1e6),' MW'];
            %
            if isfield(equil,'shotnum') && ~isempty(str2double(equil.shotnum)) && isfield(equil,'shotime') && ~isempty(str2double(equil.shotime)),% shot number and time info
                %
                filename = [workdir,'GPHYB_',equil.shotnum,'.mat'];
                %
                if exist(filename,'file'),%power from file
                    %
                    load(filename,'tplh','tbase')
                    %    
                    xplh = pfac*1e6*interp1(tbase(:,1),tplh,str2double(equil.shotime));
                    %
                    xplh = xplh(xplh > 0);
                    %
                    if length(xplh) == 1,
                        val(end+1) = xplh;
                        s{end+1} = ['Power from GPHYB_* file',pstr,'          : PLH = ',num2str(xplh/1e6),' MW'];
                    elseif length(xplh) == 2,
                        val(end+1:end+2) = xplh;
                        s{end+1} = ['Power from GPHYB_* file, ant. #1',pstr,' : PLH = ',num2str(xplh(1)/1e6),' MW'];
                        s{end+1} = ['Power from GPHYB_* file, ant. #2',pstr,' : PLH = ',num2str(xplh(2)/1e6),' MW'];
                    end
                    %
                end
                %
                if exist('tsbase','file') == 3% power from TS database
                    %
                    [tplh,tbase] = tsbase(str2double(equil.shotnum),'GPHYB');
                    %
                    xplh = pfac*1e6*interp1(tbase(:,1),tplh(:,1:2),str2double(equil.shotime));
                    %
                    xplh = xplh(xplh > 0);
                    %
                    if length(xplh) == 1,
                        val(end+1) = xplh;
                        s{end+1} = ['Power from TSBASE',pstr,'                : PLH = ',num2str(xplh/1e6),' MW'];
                    elseif length(xplh) == 2,
                        val(end+1:end+2) = xplh;
                        s{end+1} = ['Power from TSBASE, ant. #1',pstr,'       : PLH = ',num2str(xplh(1)/1e6),' MW'];
                        s{end+1} = ['Power from TSBASE, ant. #2',pstr,'       : PLH = ',num2str(xplh(2)/1e6),' MW'];
                    end
                    %
                end
                %
            end
            %
            s{end+1} = 'Specify power manually';
            %   
            locstyle = select.style;
            locstyle.textwidth = 600;
            %
            opt_Plhtot = iselect_jd(s,['LH power associated with this spectrum',pstr,' :'],opt_gui,locstyle,length(s)-1);
            %
            if opt_Plhtot < length(s),
                spectrum.Plhtot = val(opt_Plhtot);
            else
                spectrum.Plhtot = 1e6*iselect_jd({},['Specify LH power',pstr,' (MW) :'],opt_gui,select.style,val(1)/1e6);
            end
            %
            data = struct;
            data.spectrum = spectrum;
            %
            launchs{1} = imake_launch_LH_jd(basestr,signs,data,opt_gui,select);
            %
            if opt_module == 2,
                launchs{1}.rZ0 = launchs{1}.rZ0(launchs{1}.rZ0 >= 0);
            elseif opt_module == 3,
                launchs{1}.rZ0 = launchs{1}.rZ0(launchs{1}.rZ0 <= 0);
            end                
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
                data.bPlhtot = external.power_spectrum.power*1e6;
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
                    data.bPlhtot = external.LH.(fname).power_spectrum.power*1e6;
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
