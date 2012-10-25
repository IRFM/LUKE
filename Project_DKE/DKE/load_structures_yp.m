function [varargout] = load_structures_yp(varargin);
%LUKE - Load structures for LUKE 
%
% Load structures for LUKE 
%
% INPUTS: 
%
%   - type: 'dkepath','equil','dkeparam','display','ohm','waves','transpfaste','ripple', 'fluct' or 'hxr' (order not important)
%   - id: id of the field type
%   - path: path of the field type
%
% OUTPUTS:
%
%   - structures: as indicated by the order specified in the types
%
% WARNING: several types may be used, the order in unimportant. The output
% corresponds to the number and the order of types
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker CEA-DRFC (joan.decker@cea.fr)
%
if rem(nargin,3) > 0 | nargin == 0, error('Wrong number of input arguments in load_structures_yp !');end
%
id_path = '';
path_path = '';
id_equil = '';
path_equil = '';
id_dkeparam = '';
path_dkeparam = '';
id_display = '';
path_display = '';
id_ohm = '';
path_ohm = '';
ids_wave = '';
paths_wave = '';
ids_wavestruct = '';
paths_wavestruct = '';
ids_rayinit = '';
paths_rayinit = '';
ids_launch = '';
paths_launch = '';
ids_angles = '';
paths_angles = '';
id_transpfaste = '';
path_transpfaste = '';
id_ripple = '';
path_ripple = '';
id_fluct = '';
path_fluct = '';
id_hxr = '';
path_hxr = '';
id_external = '';
path_external = '';
%
j = 1;
for i=1:3:length(varargin),
    if strcmp(varargin{i},'dkepath'),
       id_path = varargin{i+1};
       path_path = varargin{i+2};
       flag_path = j;
    elseif strcmp(varargin{i},'dkeparam'),
       id_dkeparam = varargin{i+1};
       path_dkeparam = varargin{i+2};
       flag_dkeparam = j;
    elseif strcmp(varargin{i},'dkedisplay'),
       id_display = varargin{i+1};
       path_display = varargin{i+2};
       flag_display = j;
    elseif strcmp(varargin{i},'equil'),
       id_equil = varargin{i+1};
       path_equil = varargin{i+2};
       flag_equil = j;
    elseif strcmp(varargin{i},'ohm'),
       id_ohm = varargin{i+1};
       path_ohm = varargin{i+2};
       flag_ohm = j;
    elseif strcmp(varargin{i},'waves'),
       ids_wave = varargin{i+1};
       paths_wave = varargin{i+2};
       flag_wave = j;
    elseif strcmp(varargin{i},'wavestructs'),
       ids_wavestruct = varargin{i+1};
       paths_wavestruct = varargin{i+2};
       flag_wavestruct = j;
    elseif strcmp(varargin{i},'rayinits'),
       ids_rayinit = varargin{i+1};
       paths_rayinit = varargin{i+2};
       flag_rayinit = j;
    elseif strcmp(varargin{i},'launchs'),
       ids_launch = varargin{i+1};
       paths_launch = varargin{i+2};
       flag_launch = j;
    elseif strcmp(varargin{i},'angles'),
       ids_angles = varargin{i+1};
       paths_angles = varargin{i+2};
       flag_angles = j;
    elseif strcmp(varargin{i},'transpfaste'),
       id_transpfaste = varargin{i+1};
       path_transpfaste = varargin{i+2};
       flag_transpfaste = j;
    elseif strcmp(varargin{i},'ripple'),
       id_ripple = varargin{i+1};
       path_ripple = varargin{i+2};
       flag_ripple = j;
    elseif strcmp(varargin{i},'fluct'),
       id_fluct = varargin{i+1};
       path_fluct = varargin{i+2};
       flag_fluct = j;
    elseif strcmp(varargin{i},'hxr'),
       id_hxr = varargin{i+1};
       path_hxr = varargin{i+2};
       flag_hxr = j;
       j = j+1;
       flag_hxrparam = j;
    elseif strcmp(varargin{i},'external'),
       id_external = varargin{i+1};
       path_external = varargin{i+2};
       flag_external = j;
    end
    j = j + 1;
end
%
if exist('flag_path','var'),%Paths
    %
    if isnumeric(id_path),% path profile number selected
        profnum = id_path;
        id_path = '';
    else
        profnum = NaN;% default profile number
    end
    %
    if isempty(id_path),%path is taken relative to local directory
        dkepath = path_LUKE_LOCAL;
        info_dke_yp(2,['Local LUKE path selected']);
    else
        %
        filename = [path_path,'PATH_',id_path,'.mat'];
        %
        if exist(filename) == 0,
            error([filename,' does not exist']);
        else
            load(filename);
            info_dke_yp(2,['Structure ''path'': ',filename,' successfully loaded']);
            %
        end
    end
    %
    if isfield(dkepath,'hostname') && isstruct(dkepath.hostname),
        %
        hostnames = fieldnames(dkepath.hostname);
        nhosts = length(hostnames);
        hostname = '';
        %
        [s,lhostname] = system('hostname');
        if s ~= 0,
            lhostname = getenv('HOSTNAME');%For remote computing (xgrid)
        end
        %
        for ihost = 1:nhosts, 
            if strfind(lhostname,dkepath.hostname.(hostnames{ihost})),
                hostname = hostnames{ihost};
            end
        end
        if isempty(hostname),
            if isfield(dkepath,'default'),
                hostname = 'default';
                warning('The computer is not listed in dkepath: default hostname.')
            else
                error('The computer is not listed in dkepath')
            end
        end
        %
        path_id = dkepath.id;
        %
        username = getenv('USER');
        %
        if ~isfield(dkepath.(hostname),username),%user not listed in machine profiles
            if isfield(dkepath.(hostname),'default'),
                disp(['Warning : user ',username,' not found on machine ',hostname,'; selecting profile from default user ',dkepath.(hostname).default])
                username = dkepath.(hostname).default;
            else
                error(['Warning : user ',username,' not found on machine ',hostname,'; no default profile found.'])
            end
        end
        %
        dkepath_local = dkepath.(hostname).(username);
        %
        if profnum > length(dkepath_local),
            disp(['Warning : profile index exceeds number of profiles for user ',username,' on machine ',hostname,'; selecting default profile.'])
            profnum = NaN;
        end
        %
        if isnan(profnum),
            if isfield(dkepath.(hostname),'path_profile') && isfield(dkepath.(hostname).path_profile,username),
                profnum = dkepath.(hostname).path_profile.(username);
            else
                profnum = 1;
            end
        end
        %
        dkepath_local = dkepath_local(profnum);
        %
        info_dke_yp(2,['Path profile number ',num2str(profnum),' for user ',username,' on machine ',hostname,' selected'],'','Green');
        %
        dkepath_local.hostname = hostname;
        dkepath_local.computer = dkepath.(hostname).computer;
        dkepath_local.id = path_id;
        %
        dkepath = dkepath_local;
        %
        if ~isfield(dkepath,'remote'),
            dkepath.remote = '';
        end
        %
    end
    %
    if ~strcmp(dkepath.computer,computer),
        error('The path structure is not consistent with the computer !'),
    end
    %
    % dynamic compilation of MEX files
    %
    % Set path for Project_DKE
    %
    setpath_luke_jd(dkepath.luke_root,dkepath);
    %
    varargout{flag_path} = dkepath;
end
%
if exist('flag_equil','var'),%Magnetic equilibrium
    if strfind(path_equil,'database')
		if strfind(path_equil,'ITM'),
			[machine,user,ver] = which_MDSdatabase(dkepath);%Check access to database (Environment variable must be set-up before launching MatLab)
			if isempty(machine) | isempty(user) | isempty(ver),
				error(['WARNING: Unsuccessful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
			else
				disp(['Successful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
				if ischar(id_equil),
					[numshot,path_equil] = LUKE2ITM(dkepath,'equil',id_equil);%Conversion for accessing to the ITM MDS+ reference shot number
				else
					numshot = id_equil;%Direct access to the ITM MDS+ reference shot number
				end
				%
				[equil,status,result] = read_equil_ITM(numshot,1,NaN,1);
				if ~status,
					disp(['LUKE magnetic equilibrium ',id_equil,' successfully read from the ITM-MDS+ database']);
					varargout{flag_equil} = equil;
				else
					error(result);
				end
			end
		else	
			error(['The database ',path_equil,' is not recognized']);
		end
	else
    	filename = [path_equil,'EQUIL_',id_equil,'.mat'];
    	if exist(filename) == 0,
	    	error([filename,' does not exist']);
    	else
	    	load(filename);
	    	info_dke_yp(2,['Structure ''equil'': ',filename,' successfully loaded']);
    	end
    	varargout{flag_equil} = equil;	
    end
end
%
if exist('flag_dkeparam','var'),%DKE simulation parameters 
    filename = [path_dkeparam,'DKEPARAM_',id_dkeparam,'.mat'];
    if exist(filename) == 0,
	    error([filename,' does not exist']);
    else
	    load(filename);
	    info_dke_yp(2,['Structure ''dkeparam'': ',filename,' successfully loaded']);
    end
    varargout{flag_dkeparam} = dkeparam;
end
%
if exist('flag_display','var'),%DKE display parameters
    filename = [path_display,'DISPLAY_',id_display,'.mat'];
    if exist(filename) == 0,
	    error([filename,' does not exist']);
    else
	    load(filename);
	    info_dke_yp(2,['Structure ''dkedisplay'': ',filename,' successfully loaded']);
    end
    varargout{flag_display} = dkedisplay;
end
%
if exist('flag_ohm','var'),%Ohmic electric field 
    filename = [path_ohm,'OHM_',id_equil,'_',id_ohm,'.mat'];
	ohm = '';
    if isempty(id_ohm),
        info_dke_yp(2,['Simulations are performed without Ohmic E-field']);
    elseif exist(filename) == 0,
	    info_dke_yp(2,['Warning : Structure ',filename,' could not be loaded']);
    else
	    load(filename);
	    info_dke_yp(2,['Structure ''ohm'': ',filename,' successfully loaded']);
    end
    varargout{flag_ohm} = ohm;
end
%
if exist('flag_wave','var'),
    ii = 0;
    waves = '';%List of structures for multiple RF waves
    %
    if ~iscell(ids_wave),
        ids_wave={ids_wave};
    end
    if ~iscell(paths_wave),
        paths_wave=repmat({paths_wave},[1,length(ids_wave)]);
    end
    %
    if isempty(ids_wave{1}),
        info_dke_yp(2,['Simulations are performed without RF Waves']);
    else
        for iw = 1:length(ids_wave),
            filename = ['WAVE_',id_equil,'_',ids_wave{iw},'.mat'];
            filenames = getlist_jd(paths_wave{iw},filename);
            if isempty(filenames),
                info_dke_yp(2,['Warning : Structure ',filename,' could not be found in directory',paths_wave{iw},'.']);
            else
                for ifile = 1:length(filenames),
                    filename = [paths_wave{iw},filenames{ifile}];
                    load(filename);
                    info_dke_yp(2,['Structure ''wave'': ',filename,' successfully loaded']);
                    ii = ii + 1;
                    waves{ii} = wave;
                end
            end
        end
    end
    varargout{flag_wave} = waves;
end
%
if exist('flag_wavestruct','var'),
    ii = 0;
    wavestructs = '';%List of structures for multiple RF waves
    %
    if ~iscell(ids_wavestruct),
        ids_wavestruct={ids_wavestruct};
    end
    if ~iscell(paths_wavestruct),
        paths_wavestruct=repmat({paths_wavestruct},[1,length(ids_wavestruct)]);
    end
    %
    if isempty(ids_wavestruct{1}),
        info_dke_yp(2,['Simulations are performed without RF Wavestructs']);
    else
        for iw = 1:length(ids_wavestruct),
            filename = ['WAVESTRUCT_',id_equil,'_',ids_wavestruct{iw},'.mat'];
            filenames = getlist_jd(paths_wavestruct{iw},filename);
            if isempty(filenames),
                info_dke_yp(2,['Warning : Structure ',filename,' could not be found in directory',paths_wavestruct{iw},'.']);
            else
                for ifile = 1:length(filenames),
                    filename = [paths_wavestruct{iw},filenames{ifile}];
                    load(filename);
                    info_dke_yp(2,['Structure ''wavestruct'': ',filename,' successfully loaded']);
                    ii = ii + 1;
                    wavestructs{ii} = wavestruct;
                end
            end
        end
    end
    varargout{flag_wavestruct} = wavestructs;
end
%
if exist('flag_rayinit','var'),
    ii = 0;
    rayinits = '';%List of structures for multiple RF waves
    if isempty(ids_rayinit{1}),
        info_dke_yp(2,['No initial conditions requested']);
    else
        for iw = 1:length(ids_rayinit),
            filename = [paths_rayinit{iw},'RAYINIT_',id_equil,'_',ids_rayinit{iw},'.mat'];
            if exist(filename) == 0,
                info_dke_yp(2,['Warning : Structure ',filename,' could not be loaded']);
            else
                load(filename);
                info_dke_yp(2,['Structure ''rayinit'': ',filename,' successfully loaded']);
                ii = ii + 1;
                rayinits{ii} = rayinit;
            end
        end
    end
    varargout{flag_rayinit} = rayinits;
end
%
if exist('flag_launch','var'),
    ii = 0;
    launchs = '';%List of structures for multiple RF waves
    if isempty(ids_launch{1}),
        info_dke_yp(2,['No launching conditions requested']);
    else
        for iw = 1:length(ids_launch),
            filename = [paths_launch{iw},'LAUNCH_',ids_launch{iw},'.mat'];
            if exist(filename) == 0,
                info_dke_yp(2,['Warning : Structure ',filename,' could not be loaded']);
            else
                load(filename);
                info_dke_yp(2,['Structure ''launch'': ',filename,' successfully loaded']);
                ii = ii + 1;
                launchs{ii} = launch;
            end
        end
    end
    varargout{flag_launch} = launchs;
end
%
if exist('flag_angles','var'),
    ii = 0;
    angless = '';%List of structures for multiple RF waves
    if isempty(ids_angles{1}),
        info_dke_yp(2,['No angles conditions requested']);
    else
        for iw = 1:length(ids_angles),
            filename = [paths_angles{iw},'ANGLES_',ids_angles{iw},'.mat'];
            if exist(filename) == 0,
                info_dke_yp(2,['Warning : Structure ',filename,' could not be loaded']);
            else
                load(filename);
                info_dke_yp(2,['Structure ''angles'': ',filename,' successfully loaded']);
                ii = ii + 1;
                angless{ii} = angles;
            end
        end
    end
    varargout{flag_angles} = angless;
end
%
if exist('flag_transpfaste','var'),
    filename = [path_transpfaste,'TRANSP_',id_equil,'_',id_transpfaste,'.mat'];
	transpfaste = '';
    if isempty(id_transpfaste),
        info_dke_yp(2,['Simulations are performed without fast electron transport']);
    elseif exist(filename) == 0,
	    info_dke_yp(2,['Warning : Structure ',filename,' could not be loaded']);
    else
	    load(filename);
	    info_dke_yp(2,['Structure ''transpfaste'': ',filename,' successfully loaded']);
    end
    varargout{flag_transpfaste} = transpfaste;
end
%
if exist('flag_ripple','var'),
    filename = [path_ripple,'RIPPLE_',id_equil,'_',id_ripple,'.mat'];
	ripple = '';
    if isempty(id_ripple),
        info_dke_yp(2,['Simulations are performed without magnetic ripple effects']);
    elseif exist(filename) == 0,
	    info_dke_yp(2,['Warning : Structure ',filename,' could not be loaded']);
    else
	    load(filename);
	    info_dke_yp(2,['Structure ''ripple'': ',filename,' successfully loaded']);
    end
    varargout{flag_ripple} = ripple;
end
%
if exist('flag_fluct','var'),
    filename = [path_fluct,'FLUCT_',id_equil,'_',id_fluct,'.mat'];
	fluct = '';
    if isempty(id_fluct),
        info_dke_yp(2,['Simulations are performed without density or magnetic field fluctuations']);
    elseif exist(filename) == 0,
	    info_dke_yp(2,['Warning : Structure ',filename,' could not be loaded']);
    else
	    load(filename);
	    info_dke_yp(2,['Structure ''fluct'': ',filename,' successfully loaded']);
    end
    varargout{flag_fluct} = fluct;
end
%
if exist('flag_hxr','var'),%HXR
    filename = [path_hxr,'HXR_',id_hxr,'.mat'];
	hxr = '';
    hxrparam = '';
    if exist(filename) == 0,
	    info_dke_yp(2,['Warning : Structure ',filename,' could not be loaded']);
    else
	    load(filename);
	    info_dke_yp(2,['Structure ''hxr'': ',filename,' successfully loaded']);
    end
    varargout{flag_hxr} = hxr;
    varargout{flag_hxrparam} = hxrparam;
end
%
if exist('flag_external','var'),%DKE external parameters
    filename = [path_external,'EXTERNAL_',id_external,'.mat'];
    if exist(filename) == 0,
	    error([filename,' does not exist']);
    else
	    load(filename);
	    info_dke_yp(2,['Structure ''external'': ',filename,' successfully loaded']);
    end
    varargout{flag_external} = external;
end
%
        

    
    
    
    
    
    
    
    


