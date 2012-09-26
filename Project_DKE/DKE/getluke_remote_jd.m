function output = getluke_remote_jd(luke_job,remote,debugmode)
%
if nargin < 3
    debugmode = 0;
end
%
output = remotegetbatch(remote,luke_job,debugmode);
%