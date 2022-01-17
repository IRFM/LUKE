function remote_profile = sluke_remote_profile(sparams,ii,kk)
%
remote_profile = [];
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
                remote_profile = indexlist(jj);
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
                remote_profile = indexlist(jj);
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
    cprintf([1,0.5,0],['---> WARNING : no remote profile has been defined in sparams structure for the simulations. Local simulations are enforced. Set sparams.simul.remote.profile subfield to perform calculations on another machine. Type dispremoteprofiles('''',''scheduler'') to get available machines.']);disp(' ')
    remote_profile = 0;%local calculations enforced
    %
end
%
if isempty(remote_profile)
    %
    cprintf('*[1,0.5,0]',['---> No compatible remote profile has been found. Check LUKE path. Local calculations are enforced.']);disp(' ')
    remote_profile = 0;%local calculations 
    %
end
%
if nargin == 3 %for antenna code (ALOHA,...)
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
                    remote_profile = indexlist(jj);
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
                    remote_profile = indexlist(jj);
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
        cprintf([1,0.5,0],['---> WARNING : no remote profile has been defined in sparams structure for antenna calculations. Set sparams.rfwaves.antenna.',sparams.rfwaves.antenna.type{ii}{kk},'.',sparams.rfwaves.antenna.code{ii}{kk},'.remote_profile to perform calculations on another machine. Type dispremoteprofiles('''',''scheduler'') to get available machines.']);disp(' ')
        cprintf([1,0.5,0],['---> WARNING : Antenna calculations are enforced on the same machine defined in the subfield sparams.simul.remote.profile ']);disp(' ')
        %
    end
    %
end
%

    