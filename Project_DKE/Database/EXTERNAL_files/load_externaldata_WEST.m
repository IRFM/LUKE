function external = load_externaldata_WEST(external_in,opt_gui)
%
% This function loads data from WEST database 
%
if nargin == 0
    %
    % default values
    %
    external.workdir = '';
    external.shotnum = 0;
    external.shotime = 0;
    %external.t1 = 0;
    %external.t2 = 0;
    %
    % description & user help
    %
    external.info.workdir = 'directory for source files';
    external.info.shotnum = 'Shot number';
    external.info.shotime = 'Shot time (s)';
    %external.info.t1 = '';
    %external.info.t2 = '';
    % 
    % expert mode
    %
    external.expert.workdir = 0;
    external.expert.shotnum = 0;
    external.expert.shotime = 0;
    %external.expert.t1 = 0;
    %external.expert.t2 = 0;
    %
    % range of values
    %
    external.values.workdir = '';
    external.values.shotnum = [0;Inf];
    external.values.shotime = [0;Inf];
    %external.values.t1 = [0;Inf];
    %external.values.t2 = [0;Inf];
    %
    return
    %
end
%
%
workdir = external_in.workdir;
shotnum = external_in.shotnum;
shotime = external_in.shotime;
%t1 = external_in.t1;
%t2 = external_in.t2;
%
if nargin < 2,
    opt_gui = false;
end
%
%if isempty(t1) || isempty(t2)
%    t1 = shotime;
%    t2 = shotime;
%end
%
external = '';
basestr = 'WEST';
%
%if exist('remote_tsbase','file') ~= 2 || exist('remote_imas','file') ~= 2,
%    disp('-----> Access to the WEST database is not granted.')
%    disp('-----> You need remote_tsbase.m and remote_imas.m scripts for access to WEST tokamak database.');
%    return;
%end
%
external.basestr = basestr;
external.shotnum = shotnum;
external.shotime = shotime;
%external.t1 = t1;
%external.t2 = t2;
%
if ~ischar(shotnum),
    shotnum = num2str(round(shotnum));
end
%
if ~ischar(shotime),
    shotime = num2str(round(shotime));
end
%
if ~isempty(workdir) && workdir(end) ~= filesep,
    workdir = [workdir,filesep];
end
%
filename = [workdir,'LH_antenna_LH1_',shotnum,'_',shotime,'.mat'];
%
if exist(filename,'file'),
    external.wave.LH.antenna_LH1 = load([workdir,'LH_antenna_LH1_',shotnum,'_',shotime,'.mat']);
else
    disp(['--> WARNING: The file LH_antenna_LH1_',shotnum,'_',shotime,'.mat does not exist in the directory ',workdir]);
end
%
filename = [workdir,'LH_antenna_LH2_',shotnum,'_',shotime,'.mat'];
%
if exist(filename,'file'),
    external.wave.LH.antenna_LH2 = load([workdir,'LH_antenna_LH2_',shotnum,'_',shotime,'.mat']);
else
    disp(['--> WARNING: The file LH_antenna_LH2_',shotnum,'_',shotime,'.mat does not exist in the directory ',workdir]);
end
%
external.id = [basestr,'_',shotnum,'_',shotime]; 
%
if isnan_jd(external,0),
    disp('Warning : NaNs were found in the structure ''external'' : ')
    isnan_jd(external,1),
end


%
% Load LH wave parameters for ALOHA calculations
%
%[flag_LH,LH] = load_LH_tsbase_yp(shotnum,shotime,t1,t2,basestr);
%
%if flag_LH
%    external.wave.LH = LH;
%    disp(['''LH'' data have been well loaded for shot #',int2str(shotnum),'.']);
%else
%    disp(['WARNING: ''LH'' data have not been loaded for shot #',int2str(shotnum),'.']);
%end
%
% Load fast electron bremsstrahlung data
%


%
%if flag_LH
%    external.id = ['WEST_',int2str(shotnum),'_',int2str(shotime),'_ALOHA'];
%else
%    external.id = ['WEST_',int2str(shotnum),'_',int2str(shotime)];
%end


