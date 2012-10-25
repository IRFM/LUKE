function luke_job = runluke_remote_jd(luke_input,remote,debugmode)
%
if nargin < 3
    debugmode = 0;
end
%
% path to LUKE
%
if isempty(remote.host),% same version for local calculations
    luke_job.env.luke_root = luke_input.dkepath.luke_root;
else
    luke_job.env.luke_root = remote.luke_root;
end
luke_job.env.remotematfnc = 'runluke';
%
luke_job.script = [luke_job.env.luke_root,filesep,'Tools/matlabbatch.sh'];
luke_job.args = 'luke_root = getenv(''luke_root'');addpath([luke_root,''Project_DKE/DKE'']);setpath_luke_jd(luke_root);disp(['' Path set to '',luke_root]);remotematrun;';%argument to be passed into script
%
luke_job.savefcn = 'matstandardsave';%'runlukesave';%
luke_job.loadfcn = 'matstandardload';%'runlukeload';%
luke_job.localdatapath = '';
if isfield(remote,'remotedatapath') && ~isempty(remote.remotedatapath),
    luke_job.remotedatapath = remote.remotedatapath;
else
    luke_job.remotedatapath = '';
end
%
luke_job.wait = 0;% (0) return hand (1) wait for result
luke_job.nodes = 1;%number of nodes required
luke_job.nproc = 2;%number of cores required
luke_job.walltime = [];% time required (integers - in hours) - leave empty if no requirement
%
if isfield(luke_input.dkeparam,'luke_memory'),
    luke_job.memory = luke_input.dkeparam.luke_memory;% requested memory specified in dkeparam
elseif ~isempty(luke_input.transpfaste), 
    luke_job.memory = 14000;%mb default value with transport
else
    luke_job.memory = 7000;%mb default value without transport
end
%
luke_job.debugmode = debugmode;
%
luke_job = remoterunbatch(remote,luke_job,luke_input,debugmode);
%
