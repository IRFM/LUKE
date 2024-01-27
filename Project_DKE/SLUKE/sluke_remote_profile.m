function [remote_profile_num,remote_profile_char] = sluke_remote_profile(sparams,ii,kk,displaymode)
%
if nargin < 4
    %
    displaymode = 0;
    %
end
%
remote_profile_num = [];
remote_profile_char = '';
%
[indexlist,profile_list] = dispremoteprofiles('','scheduler',0);%scheduler only
%
if isfield(sparams.simul.remote,'profile')
    %
    if ischar(sparams.simul.remote.profile{ii})
        %
        for jj = 1:length(indexlist)
            %
            if ~isempty(strfind(profile_list{jj},sparams.simul.remote.profile{ii}))
                %
                remote_profile_num = indexlist(jj);
                %
                if remote_profile_num == 0
                    remote_profile_char = 'local';
                else
                    remote_profile_char = profile_list{jj}(1:strfind(profile_list{jj},':')-2);
                end
                %
                break;
                %            
            end
            %
        end
        %
    else
        %
        for jj = 1:length(indexlist)
            %
            if indexlist(jj) == sparams.simul.remote.profile{ii}
                %
                remote_profile_num = indexlist(jj);
                %
                if remote_profile_num == 0
                    remote_profile_char = 'local';
                else
                    remote_profile_char = profile_list{jj}(1:strfind(profile_list{jj},':')-2);
                end
                %
                break;
                %
            end
            %
        end
        %
    end
    %
else
    %
    if displaymode
        cprintf([1,0.5,0],'---> WARNING : no remote profile has been defined in sparams structure for the simulations.');disp(' ')
    end
    remote_profile_num = 0;%local calculations enforced
    remote_profile_char = 'local';%local calculations enforced
    %
end
%
if isempty(remote_profile_num)
    %
    if displaymode
        cprintf('*[1,0.5,0]','---> No compatible remote profile has been found. Check LUKE path.');disp(' ')
    end
    remote_profile_num = 0;%local calculations enforced
    remote_profile_char = 'local';%local calculations enforced
    %
end
%
if nargin >= 3 && kk > 0 %for antenna code (ALOHA,...)
    %
    if isfield(sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}),'remote_profile')
        %
        if ischar(sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).remote_profile{ii}{kk})
            %
            [indexlist,profile_list] = dispremoteprofiles('','scheduler',0);%scheduler only
            %
            for jj = 1:length(indexlist)
                %
                if ~isempty(strfind(profile_list{jj},sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).remote_profile{ii}{kk}))
                    %
                    remote_profile_num = indexlist(jj);
                    %
                    if remote_profile_num == 0
                        remote_profile_char = 'local';
                    else
                        remote_profile_char = profile_list{jj}(1:strfind(profile_list{jj},':')-2);
                    end
                    %
                    break;
                    %
                end
                %
            end
            %
        else
            %
            for jj = 1:length(indexlist)
                %
                if indexlist(jj) == sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).remote_profile{ii}{kk}
                    %
                    remote_profile_num = indexlist(jj);
                    %
                    if remote_profile_num == 0
                        remote_profile_char = 'local';
                    else
                        remote_profile_char = profile_list{jj}(1:strfind(profile_list{jj},':')-2);
                    end
                    %
                    break;
                    %
                end
                %
            end
            %
        end
        %
    else
        %
        if displaymode
            cprintf([1,0.5,0],'---> WARNING : no remote profile has been defined in sparams structure for antenna calculations.');disp(' ')
            cprintf([1,0.5,0],'---> WARNING : antenna calculations are enforced on the same machine defined in the subfield sparams.simul.remote.profile ');disp(' ')
        end
        %
    end
    %
end
%
if remote_profile_num == 0
    %
    if displaymode
        cprintf([1,0.5,0],'---> WARNING : Local simulations are enforced. Set sparams.simul.remote.profile subfield to perform calculations on another machine. Type dispremoteprofiles('''',''scheduler'') to get available machines.');disp(' ')
    end
    %
end
    