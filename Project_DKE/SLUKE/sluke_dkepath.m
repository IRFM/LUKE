function [dkepath] = sluke_dkepath(sparams,ii)
%
dkepath = lukeschedulerparam('',sparams.simul.remote.mode{ii},sluke_remote_profile(sparams,ii),sparams.simul.remote.remtimout{ii});
%
[remote_profile_num,~] = sluke_remote_profile(sparams,ii,0,1);
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'scheduler') && remote_profile_num > 0
    %
    if ~isempty(sluke_remote_scheduler(sparams,ii))
        %
        dkepath.clustermode.run_lukert.scheduler = conc_struct_jd(dkepath.clustermode.run_lukert.scheduler,sluke_remote_scheduler(sparams,ii));
        %
    end
    %
else
    %
    dkepath.remnum = 0;%local calculations
    %
end
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'debugmode') && remote_profile_num > 0
    %
    dkepath.clustermode.run_lukert.scheduler.debugmode = sparams.simul.remote.debugmode{ii};
    %
else
    %
    dkepath.debugmode = sparams.simul.remote.debugmode{ii};;
    %
end
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'cleanmode') && remote_profile_num > 0
    %
    dkepath.clustermode.run_lukert.scheduler.cleanmode = sparams.simul.remote.cleanmode{ii};
    %
else
    %
    dkepath.cleanmode = sparams.simul.remote.cleanmode{ii};
    %
end
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'matver') && remote_profile_num > 0
    %
    if sluke_remote_matver(sparams,ii)
        %
        dkepath.clustermode.run_lukert.scheduler.matdef = sparams.simul.remote.matver{ii};
        %
    end
    %
end
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'mode') && remote_profile_num > 0
    %
    dkepath.clustermode.run_lukert.scheduler.mode = sparams.simul.remote.mode{ii};
    %
end
%
if remote_profile_num == 0
    %   
    dkepath.remtimout = sparams.simul.remote.remtimout{ii};
    %    dkepath.rempause = 1;%TODO 
    if isfield(dkepath,'clustermode')
        %
        dkepath = rmfield(dkepath,'clustermode');
        %
    end
    %
end

           
