function luke_job = runluke_remote_jd(luke_input,remote,debugmode)
%
if nargin < 3
    debugmode = 0;
end
%
luke_job.script = 'mrunluke_batch';
luke_job.savefcn = 'runlukesave';%'matstandardsave';
luke_job.loadfcn = 'runlukeload';%'matstandardload';
luke_job.root = remote.luke_root;
if ~isempty(luke_input.transpfaste) && length(remote.mem) >= 4, 
    luke_job.memory = remote.mem{4};%mb
else
    luke_job.memory = remote.mem{3};%mb
end    
luke_job.localdatapath = '';
luke_job.remotedatapath = '';
if ~isempty(remote.host),
    luke_job.env.LUKE_matlabroot = remote.matlabroot;
else
    luke_job.env.LUKE_matlabroot = [matlabroot,'/bin/'];
end    
luke_job.env.LUKE_path = luke_job.root;
%
luke_job = remoterunbatch(remote,luke_job,luke_input,debugmode);
%
