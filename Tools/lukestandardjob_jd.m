function job = lukestandardjob_jd(remotematfnc,remotepathfnc,remotepath)
%
% Standard preparation for remote luke job. Only with use of remotematrun
%
% INPUTS :
%       - remotematfnc : function to be called remotely. ex : runmat
%       - remotepathfnc : function to set up the path on the remote machine. ex : setpath_luke_jd
%       - remotepath : path on the remote machine where 'remotepathfnc' is to be found. 
%           If 'remotepath' is empty and funcopy >= 0, the function 'remotepathfnc' is copied from guest machine
%       
% OUTPUTS :
%       - job : default structure for job with remotematrun
job = matstandardjob_jd(remotematfnc);
%
if nargin < 3,
    remotepath = '';
end
if nargin >= 2,
    job.env.remotepathfnc = [remotepath,remotepathfnc];% (optional, called by remotematrun) matlab function to set the path on the remote machine
end
%
