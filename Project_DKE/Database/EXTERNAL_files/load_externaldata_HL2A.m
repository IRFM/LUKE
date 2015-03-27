function external = load_externaldata_HL2A(external_in,opt_gui)%(workdir,shotnum,shotime,t1,t2,opt_gui,dummy)
%
% This function loads data from HL-2A database
%
% INPUTS : 
%   - if nargin == 0, return default external_in to be modified interactively in iload_externaldata_jd

%   - external_in : input structure.
%   - opt_gui     : option for GUI within function (interactive mode only)
%       
%
if nargin == 0,
    %
    % default values
    %
    external.workdir = '';
    external.shotnum = 0;
    external.shotime = 0;
    %
    % description & user halp
    %
    external.info.workdir = 'directory for source files';
    external.info.shotnum = 'Shot number';
    external.info.shotime = 'Shot time (s)';
    % 
    % expert mode
    %
    external.expert.workdir = 0;
    external.expert.shotnum = 0;
    external.expert.shotime = 0;
    %
    % range of values
    %
    external.values.workdir = '';
    external.values.shotnum = [0;Inf];
    external.values.shotime = [0;Inf];
    %
    return
    %
end
%
if nargin < 2,
    opt_gui = false;
end
%
workdir = external_in.workdir;
shotnum = external_in.shotnum;
shotime = external_in.shotime;
%
% ******************************************************************
%
external = '';
basestr = 'HL2A';
%
if ~isempty(workdir) && workdir(end) ~= filesep,
    workdir = [workdir,filesep];
end
%
shotnum = num2str(shotnum);
%
external.basestr = basestr;
external.shotnum = shotnum;
external.shotime = shotime;
%
if ~ischar(shotime),
    shotime = num2str(round(shotime));
end
%
shotnum = [repmat('0',[1,6-length(shotnum)]),shotnum];
shotime = [repmat('0',[1,5-length(shotime)]),shotime];
%
filename = [workdir,'jbdirections_',shotnum,'.',shotime,'.mat'];
%
if exist(filename,'file'),
    external.equil = load([workdir,'jbdirections_',shotnum,'.',shotime,'.mat']);
    display([' --> Ip direction is ',external.equil.jbdirections.Ip]);
    display([' --> Bt direction is ',external.equil.jbdirections.Bt]);
else
    error(['The file jbdirections_',shotnum,'.',shotime,'.mat is missing in the directory ',workdir]);
end
%
filename = [workdir,'g',shotnum,'.',shotime];
%
if exist(filename,'file'),
    external.equil.magnetic.eqdsk = fileread(filename);
    external.equil.shotnum = shotnum;
    external.equil.shotime = shotime;
else
    error(['The EQDSK file g',shotnum,'.',shotime,' is missing in the directory ',workdir]);
end
%
filename = [workdir,'profiles_',shotnum,'.',shotime,'.mat'];
%
if exist(filename,'file'),
    external.equil.prof = load([workdir,'profiles_',shotnum,'.',shotime,'.mat']);
else
    error(['The file profiles_',shotnum,'.',shotime,'.mat is missing in the directory ',workdir]);
end
%
filename = [workdir,'species_',shotnum,'.',shotime,'.mat'];
%
if exist(filename,'file'),
    external.equil.prof.species = load([workdir,'species_',shotnum,'.',shotime,'.mat']);
else
    error(['The file species_',shotnum,'.',shotime,'.mat is missing in the directory ',workdir]);
end
%
filename = [workdir,'LH_antenna_3p70Ghz_',shotnum,'.',shotime,'.mat'];
%
if exist(filename,'file'),
    external.wave.LH.antenna_3p70Ghz = load([workdir,'LH_antenna_3p70Ghz_',shotnum,'.',shotime,'.mat']);
else
    disp(['--> WARNING: The file LH_antenna_3p70Ghz_',shotnum,'.',shotime,'.mat does not exist in the directory ',workdir]);
end
%
filename = [workdir,'EC_mirror_68Ghz_',shotnum,'.',shotime,'.mat'];
%
if exist(filename,'file'),
    external.wave.EC.mirror_68Ghz = load([workdir,'EC_mirror_68Ghz_',shotnum,'.',shotime,'.mat']);
else
    disp(['--> WARNING: The file EC_mirror_68Ghz_',shotnum,'.',shotime,'.mat does not exist in the directory ',workdir]);
end
%
filename = [workdir,'EC_mirror_140Ghz_',shotnum,'.',shotime,'.mat'];
%
if exist(filename,'file'),
    external.wave.EC.mirror_140Ghz = load([workdir,'EC_mirror_140Ghz_',shotnum,'.',shotime,'.mat']);
else
    disp(['--> WARNING: The file EC_mirror_140Ghz_',shotnum,'.',shotime,'.mat does not exist in the directory ',workdir]);
end
%
filename = [workdir,'vloop_',shotnum,'.',shotime,'.mat'];
%
if exist(filename,'file'),
    external.ohm = load([workdir,'vloop_',shotnum,'.',shotime,'.mat']);
else
    disp(['--> WARNING: The file vloop_',shotnum,'.',shotime,'.mat does not exist in the directory ',workdir]);
end
%
external.id = [basestr,'_',shotnum,'_',shotime]; 
%
if isnan_jd(external,0),
    disp('Warning : NaNs were found in the structure ''external'' : ')
    isnan_jd(external,1),
end
%
