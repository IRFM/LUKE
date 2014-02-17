function output = getluke_remote_jd(luke_job,debugmode)
%
if nargin < 2,
    debugmode = luke_job.debugmode;
end
%
output = remotegetbatch(luke_job,debugmode);
%