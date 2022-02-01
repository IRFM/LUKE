function [dkepath] = sluke_dkepath(sparams,ii)
%
dkepath = lukeschedulerparam('',sparams.simul.remote.mode{ii},sluke_remote_profile(sparams,ii),sparams.simul.remote.remtimout{ii});
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'scheduler') 
    %
    if ~isempty(sluke_remote_scheduler(sparams,ii))
        %
        dkepath.clustermode.run_lukert.scheduler = conc_struct_jd(dkepath.clustermode.run_lukert.scheduler,sluke_remote_scheduler(sparams,ii));

        %
    end
    %
else
    %
    cprintf('*[1,0.5,0]',['No scheduler is defined. Default option for the remote profile ',sparams.simul.remote.profile{ii},' is considered.']);disp(' ')
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
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'matver')
    %
    if sluke_remote_matver(sparams,ii)
        %
        dkepath.clustermode.run_lukert.scheduler.matdef = sparams.simul.remote.matver{ii};
        %
    end
    %
end
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'mode')
    %
    dkepath.clustermode.run_lukert.scheduler.mode = sparams.simul.remote.mode{ii};
    %
end
%