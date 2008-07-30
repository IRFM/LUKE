function [varargout] = load_structures_yp(varargin);
%LUKE - Load structures for LUKE 
%
% Load structures for LUKE 
%
% INPUTS: 
%
%   - type: 'dkepath','equil','dkeparam','display','ohm','waves','transpfaste','ripple' or 'hxr' (order not important)
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
ids_rayinit = '';
paths_rayinit = '';
ids_launch = '';
paths_launch = '';
id_transpfaste = '';
path_transpfaste = '';
id_transpfaste = '';
path_transpfaste = '';
id_ripple = '';
path_ripple = '';
id_hxr = '';
path_hxr = '';
%
j = 1;
for i=1:3:length(varargin),
    if strcmp(varargin{i},'dkepath'),
       id_path = varargin{i+1};
       path_path = varargin{i+2};
       flag_path = j;
    elseif strcmp(varargin{i},'equil'),
       id_equil = varargin{i+1};
       path_equil = varargin{i+2};
       flag_equil = j;
    elseif strcmp(varargin{i},'dkeparam'),
       id_dkeparam = varargin{i+1};
       path_dkeparam = varargin{i+2};
       flag_dkeparam = j;
    elseif strcmp(varargin{i},'dkedisplay'),
       id_display = varargin{i+1};
       path_display = varargin{i+2};
       flag_display = j;
    elseif strcmp(varargin{i},'ohm'),
       id_ohm = varargin{i+1};
       path_ohm = varargin{i+2};
       flag_ohm = j;
    elseif strcmp(varargin{i},'waves'),
       ids_wave = varargin{i+1};
       paths_wave = varargin{i+2};
       flag_wave = j;
    elseif strcmp(varargin{i},'rayinits'),
       ids_rayinit = varargin{i+1};
       paths_rayinit = varargin{i+2};
       flag_rayinit = j;
    elseif strcmp(varargin{i},'launchs'),
       ids_launch = varargin{i+1};
       paths_launch = varargin{i+2};
       flag_launch = j;
    elseif strcmp(varargin{i},'transpfaste'),
       id_transpfaste = varargin{i+1};
       path_transpfaste = varargin{i+2};
       flag_transpfaste = j;
    elseif strcmp(varargin{i},'ripple'),
       id_ripple = varargin{i+1};
       path_ripple = varargin{i+2};
       flag_ripple = j;
    elseif strcmp(varargin{i},'hxr'),
       id_hxr = varargin{i+1};
       path_hxr = varargin{i+2};
       flag_hxr = j;
       j = j+1;
       flag_hxrparam = j;
    end
    j = j + 1;
end
%
if exist('flag_path','var'),%Paths
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
            if ~strcmp(dkepath.computer,computer),
                error('The path structure is not consistent with the computer !'),
            end
            %
        end
    end
    %
    % dynamic compilation of MEX files
    %
    if (isfield(dkepath,'id') && ~strcmp(dkepath.id,'LOCAL')) || (isfield(dkepath,'path_id') && ~strcmp(dkepath.path_id,'LOCAL')),
        dkepath.mex = [dkepath.temppath,'/MEX'];    
        mex_compile_luke(dkepath);
    end
    %
    % Set path for Project_DKE
    %
    setpath_luke_jd(dkepath.luke_root,dkepath);
    %
    varargout{flag_path} = dkepath;
end
%
if exist('flag_equil','var'),%Magnetic equilibrium
    filename = [path_equil,'EQUIL_',id_equil,'.mat'];
    if exist(filename) == 0,
	    error([filename,' does not exist']);
    else
	    load(filename);
	    info_dke_yp(2,['Structure ''equil'': ',filename,' successfully loaded']);
    end
    varargout{flag_equil} = equil;
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
    if isempty(ids_wave{1}),
        info_dke_yp(2,['Simulations are performed without RF Waves']);
    else
        for iw = 1:length(ids_wave),
            filename = [paths_wave{iw},'WAVE_',id_equil,'_',ids_wave{iw},'.mat'];
            if exist(filename) == 0,
                info_dke_yp(2,['Warning : Structure ',filename,' could not be loaded']);
            else
                load(filename);
                info_dke_yp(2,['Structure ''wave'': ',filename,' successfully loaded']);
                ii = ii + 1;
                waves{ii} = wave;
            end
        end
    end
    varargout{flag_wave} = waves;
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


