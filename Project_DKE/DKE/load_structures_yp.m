function [varargout] = load_structures_yp(varargin);
%
% Load structures for LUKE 
%
% INPUTS: 
%
%   - type: 'dkepath','equil','dkeparam','display','ohm','waves','transpfaste' or 'ripple' (order not important)
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
id_path = [];
path_path = [];
id_equil = [];
path_equil = [];
id_dkeparam = [];
path_dkeparam = [];
id_display = [];
path_display = [];
id_ohm = [];
path_ohm = [];
ids_wave = [];
paths_wave = [];
id_transpfaste = [];
path_transpfaste = [];
id_transpfaste = [];
path_transpfaste = [];
id_ripple = [];
path_ripple = [];
%
j = 1;
for i=1:3:length(varargin),
    if strcmp(varargin(i),'dkepath'),
       id_path = varargin(i+1);
       path_path = varargin(i+2);
       flag_path = j;
    elseif strcmp(varargin(i),'equil'),
       id_equil = varargin(i+1);
       path_equil = varargin(i+2);
       flag_equil = j;
    elseif strcmp(varargin(i),'dkeparam'),
       id_dkeparam = varargin(i+1);
       path_dkeparam = varargin(i+2);
       flag_dkeparam = j;
    elseif strcmp(varargin(i),'dkedisplay'),
       id_display = varargin(i+1);
       path_display = varargin(i+2);
       flag_display = j;
    elseif strcmp(varargin(i),'ohm'),
       id_ohm = varargin(i+1);
       path_ohm = varargin(i+2);
       flag_ohm = j;
    elseif strcmp(varargin(i),'waves'),
       ids_wave = varargin(i+1);
       paths_wave = varargin(i+2);
       flag_wave = j;
    elseif strcmp(varargin(i),'transpfaste'),
       id_transpfaste = varargin(i+1);
       path_transpfaste = varargin(i+2);
       flag_transpfaste = j;
    elseif strcmp(varargin(i),'ripple'),
       id_ripple = varargin(i+1);
       path_ripple = varargin(i+2);
       flag_ripple = j;
    end
    j = j + 1;
end
%
if iscell(id_path) & iscell(path_path),
    if exist([path_path{1},'PATH_',id_path{1},'.mat']) == 0,%Paths
	    error([path_path{1},'PATH_',id_path{1},'.mat does not exist']);
    else
	    eval(['load ',path_path{1},'PATH_',id_path{1},'.mat']);
	    info_dke_yp(2,'Structure ''path'' successfully loaded');
        if ~strcmp(dkepath.computer,computer),error('The path structure is not consistent with the computer !'),end
        dkepath.temppath = [dkepath.temppathroot,filesep,timeid_jd(clock)];
    end
    varargout{flag_path} = dkepath;
end
%
if iscell(id_equil) & iscell(path_equil),
    if exist([path_equil{1},'EQUIL_',id_equil{1},'.mat']) == 0,%Magnetic equilibrium
	    error([path_equil{1},'EQUIL_',id_equil{1},'.mat does not exist']);
    else
	    eval(['load ',path_equil{1},'EQUIL_',id_equil{1},'.mat']);
	    info_dke_yp(2,'Structure ''equil'' successfully loaded');
    end
    varargout{flag_equil} = equil;
end
%
if iscell(id_dkeparam) & iscell(path_dkeparam),
    if exist([path_dkeparam{1},'DKEPARAM_',id_dkeparam{1},'.mat']) == 0,%DKE simulation parameters 
	    error([path_dkeparam{1},'DKEPARAM_',id_dkeparam{1},'.mat does not exist']);
    else
	    eval(['load ',path_dkeparam{1},'DKEPARAM_',id_dkeparam{1},'.mat']);
	    info_dke_yp(2,'Structure ''dkeparam'' successfully loaded');
    end
    varargout{flag_dkeparam} = dkeparam;
end
%
if iscell(id_display) & iscell(path_display),
    if exist([path_display{1},'DISPLAY_',id_display{1},'.mat']) == 0,%DKE output display parameters
	    error([path_display{1},'DISPLAY_',id_display{1},'.mat does not exist']);
    else
	    eval(['load ',path_display{1},'DISPLAY_',id_display{1},'.mat']);
	    info_dke_yp(2,'Structure ''dkedisplay'' successfully loaded');
	  end
    varargout{flag_display} = dkedisplay;
end
%
if iscell(id_ohm) & iscell(path_ohm),
    if exist([path_ohm{1},'OHM_',id_equil{1},'_',id_ohm{1},'.mat']) == 0,%Ohmic electric field 
	    info_dke_yp(2,['Simulations are performed without Ohmic Efield']);
	    ohm = '';
    else
	    eval(['load ',path_ohm{1},'OHM_',id_equil{1},'_',id_ohm{1},'.mat']);
	    info_dke_yp(2,['Structure ''ohm'' ',id_ohm{1},' successfully loaded']);
    end
    varargout{flag_ohm} = ohm;
end
%
ii=1;
waves = '';%List of structure for multiple RF waves
if iscell(ids_wave) & iscell(paths_wave),
    for iw = 1:length(ids_wave{1}),
	    if exist([paths_wave{iw}{1},'WAVE_',id_equil{1},'_',ids_wave{iw}{1},'.mat']) == 0,%RF waves
		    info_dke_yp(2,['Simulations are performed without the RF wave number: ',int2str(iw)]);
        else
		    eval(['load ',paths_wave{iw}{1},'WAVE_',id_equil{1},'_',ids_wave{iw}{1},'.mat']);
		    info_dke_yp(2,['Structure ''wave'' ',ids_wave{iw}{1},' successfully loaded']);
		    waves{ii} = wave;
		    ii = ii + 1;
        end
    end
    varargout{flag_wave} = waves;
end
%
if iscell(id_transpfaste) & iscell(path_transpfaste),
    if exist([path_transpfaste{1},'TRANSP_',id_transpfaste{1},'.mat']) == 0,%Fast electron radial transport 
	    info_dke_yp(2,'Simulations are performed without fast electron radial transport');
	    transpfaste = '';
    else
	    eval(['load ',path_transpfaste{1},'TRANSP_',id_transpfaste{1},'.mat']);
	    info_dke_yp(2,'Structure ''transpfaste'' successfully loaded');
    end
    varargout{flag_transpfaste} = transpfaste;
end
%
if iscell(id_ripple) & iscell(path_ripple),
    if exist([path_ripple{1},'RIPPLE_',id_ripple{1},'.mat']) == 0,%Magnetic ripple losses
	    info_dke_yp(2,'Simulations are performed without fast electron magnetic ripple losses');
	    ripple = '';
    else
	    eval(['load ',path_ripple{1},'RIPPLE_',id_ripple{1},'.mat']);
	    info_dke_yp(2,'Structure ''ripple'' successfully loaded');
    end
    varargout{flag_ripple} = ripple;
end
%


