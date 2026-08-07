% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
if ~isfield(sinputs,'remote'),
    sinputs.remote.profile = '';
    sinputs.remote.link_mode = NaN;
    sinputs.remote.profilename = NaN;
else
    if ~isfield(sinputs.remote,'profile'),
        sinputs.remote.profile = '';
    end
    %
    if ~isfield(sinputs.remote,'link_mode'),
        sinputs.remote.link_mode = NaN;
    end
    %
    if ~isfield(sinputs.remote,'profilename'),
        sinputs.remote.profilename = NaN;
    end
end
%
if ~isfield(sinputs,'mdsplus'),
    soutputs.err = 'Error: ''mdsplus'' sub-structure must be setup first !';
    return;
end
%
mdsplus_in = sinputs.mdsplus;
%
if isempty(sinputs.remote.profile) || strcmp(sinputs.remote.profile,'local'),
    %
    soutputs = mdsplusload(mdsplus_in);
    %
else
    %
    [remote] = load_remoteprofiles_jd(sinputs.remote.profile,true,true,NaN,sinputs.remote.profilename,true,0,sinputs.remote.link_mode);
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
end

