function soutputs = remotemdsplus(sinputs)
% MATREMOTE - Remote mdsplus database access
%
% Remote mdsplus database access 
%
% INPUTS : (see testremotebach.m for the remote parameters in the spinputs structure)
%
%   - sinputs : structure for remote access and mds+ database
%
% OUTPUTS : 
%
%   - soutputs is a cell array containing job output or error message if the job is completed
%
% by Y. Peysson (CEA/IRFM, yves.peysson@cea.fr) and J. Decker (CRPP/EPFL, joan.decker@epfl.ch)
%
if ~isfield(sinputs,'remote'),
    sinputs.remote.profile = '';
    sinputs.remote.link_mode = NaN;
else
    if ~isfield(sinputs.remote,'profile'),
        sinputs.remote.profile = '';
    end
    %
    if ~isfield(sinputs.remote,'link_mode'),
        sinputs.remote.link_mode = NaN;
    end
    %
end
%
if ~isfield(sinputs,'mdsplus'),
    soutputs.err = 'Error: ''mdsplus'' sub-structure must be setup.';
    return;
end
%
% Select local and remote profiles to be tested
%
[remote] = load_remoteprofiles_jd(sinputs.remote.profile,true,true,NaN,NaN,true,0,sinputs.remote.link_mode);
%
mdsplus_job = matstandardjob_jd;
%
mdsplus_job.wait = 0;%1;% (0) return hand (1) wait for result
mdsplus_job.nodes = 1;%number of nodes required
mdsplus_job.ppn = 1;%number of cores required
mdsplus_job.memory = 2000;% memory required (in mb) - leave empty if no requirement
mdsplus_job.walltime = 1;%[];% time required (integers - in hours) - leave empty if no requirement
mdsplus_job.rempause = 1/60;% in minutes
%
mdsplus_job.remtimout = 10;% in minutes
%
mdsplus_in = sinputs.mdsplus;
%
try
    %
    mdsplus_job.env.remotematfnc = 'mdsplusload'; % matlab function to be called remotely by remotematrun (case of direct call)
    %
    mdsplus_job = remoterunbatch(remote,mdsplus_job,mdsplus_in,0);
    %
    if isfield(mdsplus_job,'err'),
        soutputs.err = mdsplus_job.err;
    else
        [~,soutputs] = remotegetbatch(mdsplus_job,0,0);
    end
    %
catch job_err
    soutputs.err = job_err.message;
end


