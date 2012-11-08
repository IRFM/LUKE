function luke_job = runluke_remote_jd(luke_input,remote,debugmode)
%
if nargin < 3
    debugmode = 0;
end
%
% path to LUKE
%
luke_job = matstandardjob_jd(remote,'runluke');
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
