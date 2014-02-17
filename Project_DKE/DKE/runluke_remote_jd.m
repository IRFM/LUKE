function luke_job = runluke_remote_jd(lukestructs,remote)
%
luke_job = lukestandardjob_jd(remote,'runmat');
%
mat_input.fun = 'run_lukert';
mat_input.args_in = lukestructs;
mat_input.nargout = 2;
%
if isfield(lukestructs.dkeparam,'luke_memory'),
    luke_job.memory = lukestructs.dkeparam.luke_memory;% requested memory specified in dkeparam
elseif isfield(lukestructs,'transpfaste') && ~isempty(lukestructs.transpfaste), 
    luke_job.memory = 14000;%mb default value with transport
else
    luke_job.memory = 7000;%mb default value without transport
end
%
if isfield(lukestructs.dkeparam,'luke_ppn'),
    luke_job.nodes = 1;
    luke_job.ppn = lukestructs.dkeparam.luke_ppn;% requested memory specified in dkeparam
end
%
luke_job = remoterunbatch(remote,luke_job,mat_input);
%
