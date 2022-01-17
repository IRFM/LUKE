function [dkepath] = sluke_dkepath(sparams,ii)
%
dkepath = lukeschedulerparam('',sparams.simul.remote.mode{ii},sluke_remote_profile(sparams,ii),sparams.simul.remote.remtimout{ii});
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'memory')
    %
    dkepath.clustermode.run_lukert.scheduler.memory = sparams.simul.remote.memory{ii};
    %
end
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'walltime')
    %
    dkepath.clustermode.run_lukert.scheduler.walltime = sparams.simul.remote.walltime{ii};
    %
end
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'debugmode')
    %
    dkepath.clustermode.run_lukert.scheduler.debugmode = sparams.simul.remote.debugmode{ii};
    %
end
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'cleanmode')
    %
    dkepath.clustermode.run_lukert.scheduler.cleanmode = sparams.simul.remote.cleanmode{ii};
    %
end
%