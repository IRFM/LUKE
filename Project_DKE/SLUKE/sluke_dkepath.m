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
function [dkepath] = sluke_dkepath(sparams,ii)
%
dkepath = lukeschedulerparam('',sparams.simul.remote.mode{ii},sluke_remote_profile(sparams,ii),sparams.simul.remote.remtimout{ii});
%
[remote_profile_num,~] = sluke_remote_profile(sparams,ii,0,1);
%
if remote_profile_num > 0
    %
    if isfield(sparams.simul,'remote')
        %
        if isfield(sparams.simul.remote,'scheduler') && isfield(sparams.simul.remote.scheduler,dkepath.remote(remote_profile_num).scheduler) && ~isempty(sluke_remote_scheduler(dkepath.remote(remote_profile_num).scheduler,sparams,ii)) 
            %
            dkepath.clustermode.run_lukert.scheduler = conc_struct_jd(dkepath.clustermode.run_lukert.scheduler,sluke_remote_scheduler(dkepath.remote(remote_profile_num).scheduler,sparams,ii));
            %
        end
        %
    end
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
    dkepath.debugmode = sparams.simul.remote.debugmode{ii};
    %
end
%{
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'remtimout') && remote_profile_num > 0
    %
    %dkepath.clustermode.run_lukert.scheduler.remtimout = sparams.simul.remote.remtimout{ii};
    %
else
    %
    dkepath.remtimout = sparams.simul.remote.remtimout{ii};
    %
end
%}
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
%


           
