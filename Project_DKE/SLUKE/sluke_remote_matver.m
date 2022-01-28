function flag = sluke_remote_matver(sparams,ii)
%
flag = 0;%no enforcement by default
%
if isfield(sparams.simul.remote,'matver') && ~isempty(sparams.simul.remote.matver{ii})
    %
    if exist(['remote_',sparams.simul.remote.profile{ii}],'file')
        %
        eval(['remote_profile = remote_',sparams.simul.remote.profile{ii},';']);
        %
        if isfield(remote_profile,'matver')
            %
            registred_matlabversion = fieldnames(remote_profile.matver);
            %
            for jj = 1:length(registred_matlabversion)-1
                %
                if strcmp(registred_matlabversion{jj},sparams.simul.remote.matver{ii})
                    %
                    if ischar(remote_profile.matver.(registred_matlabversion{jj}))
                        %
                        flag = 1;
                        return
                        %
                    else
                        %
                        flag = 0;
                        cprintf([1,0.5,0],['---> WARNING : the required remote matlab version ''',sparams.simul.remote.matver{ii},''' cannot be enforced since it is not a string in remote_profile ''remote_',sparams.simul.remote.profile{ii},'''.m.']);disp(' ')
                        return
                        %
                    end
                    %
                end
                %
            end
            %
            cprintf([1,0.5,0],['---> WARNING : the required remote matlab version ''',sparams.simul.remote.matver{ii},''' cannot be enforced since it does not exist in remote_profile ''remote_',sparams.simul.remote.profile{ii},'''.m.']);disp(' ')
            return
            %
        else
            %
            cprintf([1,0.5,0],['---> WARNING : the required remote matlab version ''',sparams.simul.remote.matver{ii},''' cannot be enforced since no ''matver'' field is found in remote_profile ''remote_',sparams.simul.remote.profile{ii},'''.m.']);disp(' ')
            return
            %
        end
        %
    else
        %
        cprintf('*red',['---> ERROR : the remote_profile ''remote_',sparams.simul.remote.profile{ii},'''.m does not exist.']);disp(' ')
        error('The field sparams.simul.remote.machine must be modified. Type dispremoteprofiles('''',''scheduler'') for available remote profiles with schedulers.')
        %
    end
    %
end
