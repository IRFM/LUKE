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
function flag = sluke_remote_matver(sparams,ii)
%
flag = 0;%no enforcement by default
%
if isfield(sparams.simul.remote,'matver') && ~isempty(sparams.simul.remote.matver{ii})
    %
    [remote_profile_num,remote_profile_char] = sluke_remote_profile(sparams,ii);
    %
    if remote_profile_num > 0 %non local calculations
        %
        if exist(['remote_',remote_profile_char],'file')
            %
            eval(['remote_profile = remote_',remote_profile_char,';']);
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
                            cprintf([1,0.5,0],['---> WARNING : the required remote matlab version ''',sparams.simul.remote.matver{ii},''' cannot be enforced since it is not a string in remote_profile ''remote_',remote_profile_char,'''.m. The default Matlab version for this machine is considered.']);disp(' ')
                            return
                            %
                        end
                        %
                    end
                    %
                end
                %
                cprintf([1,0.5,0],['---> WARNING : the required remote matlab version ''',sparams.simul.remote.matver{ii},''' cannot be enforced since it does not exist in remote_profile ''remote_',remote_profile_char,'''.m. The default Matlab version for this machine is considered.']);disp(' ')
                return
                %
            else
                %
                cprintf([1,0.5,0],['---> WARNING : the required remote matlab version ''',sparams.simul.remote.matver{ii},''' cannot be enforced since no ''matver'' field is found in remote_profile ''remote_',remote_profile_char,'''.m. The default Matlab version for this machine is considered.']);disp(' ')
                return
                %
            end
            %
        else
            %
            cprintf('*red',['---> ERROR : the remote_profile ''remote_',remote_profile_char,'''.m does not exist.']);disp(' ')
            error('The field sparams.simul.remote.machine must be modified. Type dispremoteprofiles('''',''scheduler'') for available remote profiles with schedulers.')
            %
        end
        %
    else
        %
        cprintf([1,0.5,0],['---> Local calculations. The default Matlab version for this machine is considered.']);disp(' ')
        
        %
    end
end
