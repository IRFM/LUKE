function job = lukestandardjob_jd(remotematfnc)
%
% Standard preparation for remote luke job
%
job = matstandardjob_jd(remotematfnc);
%
job.env.remotepathfnc = 'setpath_luke_jd';% (optional, called by remotematrun) matlab function to set the path on the remote machine
%
