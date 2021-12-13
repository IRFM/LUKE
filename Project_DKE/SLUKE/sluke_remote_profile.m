function remote_profile = sluke_remote_profile(sparams,ii,kk)
%
remote_profile = [];
%
if nargin == 2 %for LUKE
    %
    if ischar(sparams.simul.remote_profile{ii})
        %
        [indexlist,profile_list] = dispremoteprofiles('','scheduler');%scheduler only
        %
        for jj = 1:length(indexlist)
            %
            if ~isempty(strfind(profile_list{jj},sparams.simul.remote_profile{ii}))
                %
                remote_profile = indexlist(jj);
                return;
                %
            end
            %
        end
        %
    else
        %
        remote_profile = sparams.simul.remote_profile{ii};
        %
    end
    %
elseif nargin == 3 %for antenna code (ALOHA,...)
    %
    if ischar(sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).remote_profile{ii}{kk})
        %
        [indexlist,profile_list] = dispremoteprofiles('','scheduler');%scheduler only
        %
        for jj = 1:length(indexlist)
            %
            if ~isempty(strfind(profile_list{jj},sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).remote_profile{ii}{kk}))
                %
                remote_profile = indexlist(jj);
                return;
                %
            end
            %
        end
        %
    else
        %
        remote_profile = sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).remote_profile{ii}{kk};
        %
    end
    %
end
%
if isempty(remote_profile)
    %
    cprintf('*[1,0.5,0]',['---> No compatible remotre profile has been found. Check LUKE path. Local calculations are enforced.']);disp(' ')
    remote_profile = 0;%local calculations 
    %
end
    