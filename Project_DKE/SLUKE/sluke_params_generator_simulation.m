function sparams = sluke_params_generator_simulation(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (simulation). All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : none (interactive mode), string (preset parameters) or 'sparams' structure for modifications
%
% OUTPUT :
%
%   - sparams : structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin == 0
    %
    error('Wrong number of input arguments in sluke_params_generator_simulation.')
    %
elseif nargin == 1
    %
    if isstruct(sparams) 
        %
        if isfield(sparams,'machine') && isfield(sparams,'discharge') 
            %
            for ii = 1:length(sparams.machine)
                %
                disp([' - General simulation parameters for discharge ', int2str(ii),'/',int2str(length(sparams.machine)),' (tokamak :',sparams.machine{ii},')']);
                %
                if ii > 1
                    sparams.simul.id{ii} = input_dke_yp('   - simulation id',sparams.simul.id{ii-1});
                else
                    sparams.simul.id{ii} = input_dke_yp('   - simulation id','');
                end
                %
                if ii > 1
                    sparams.simul.comment{ii} = input_dke_yp('   - comment on simulation',sparams.simul.comment{ii-1});
                else
                    sparams.simul.comment{ii} = input_dke_yp('   - comment on simulation','');
                end
                %
                sparams.simul.enable{ii} = input_dke_yp('   - enable simulation [0 or 1]',1,[0,1]);
                %
                sparams.simul.enforce{ii} = input_dke_yp('   - enforce simulation if enabled [0 or 1]',1,[0,1]);
                %
                indexlist = dispremoteprofiles('','scheduler'); % list of available remote profile numbers
                %
                if ii > 1
                    sparams.simul.remote_profile{ii} = input_dke_yp('   - remote profile number where LUKE will run.',sparams.simul.remote_profile{ii-1},indexlist);%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
                else
                    sparams.simul.remote_profile{ii} = input_dke_yp('   - remote profile number where LUKE will run.',0,indexlist);%remote profile number (list available by typing 'dispremoteprofiles' in command window)                        
                end
                %
                if sparams.simul.remote_profile{ii} > 0
                    sparams.simul.wait4results{ii} = input_dke_yp('   - wait for results (y/n)','n',{'y','n'});%
                else
                    sparams.simul.wait4results{ii} = 'y';
                end
                %
                disp('------------------------------------------------------------------');
            end
             %
            disp('------------------------------------------------------------------');
            %
        else
            %
            error('Wrong type of input arguments in sluke_params_generator_simulation. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_simulation. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end