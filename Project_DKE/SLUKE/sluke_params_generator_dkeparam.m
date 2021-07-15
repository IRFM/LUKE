function sparams = sluke_params_generator_dkeparam(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (dkeparam). All parameters are in a structure of cell arrays of the SAME SIZE. 
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
    error('Wrong number of input arguments in sluke_params_generator_dkeparam.')
    %
elseif nargin == 1
    %
    if isstruct(sparams) 
        %
        if isfield(sparams,'machine') && isfield(sparams,'discharge') 
            %
            for ii = 1:length(sparams.machine)
                %
                disp([' - Kinetic calculations parameters for discharge ', int2str(ii),'/',int2str(length(sparams.machine)),' (tokamak :',sparams.machine{ii},')']);
                %
                if ii > 1
                    %
                    sparams.dkeparam.id{ii} = input_dke_yp('   - id for the kinetic calculations parameters : ',sparams.dkeparam.id{ii-1});
                    sparams.dkeparam.comment{ii} = input_dke_yp('   - comment for the kinetic calculations parameters : ',sparams.dkeparam.comment{ii-1});
                    %  
                    sparams.dkeparam.source{ii} = input_dke_yp('   - source for the kinetic calculations parameters [preset, file or value]',sparams.dkeparam.source{ii-1},{'preset','file','value'});
                    %
                    if strcmp(sparams.dkeparam.source{ii},'file')
                        %
                        sparams.dkeparam.file{ii} = input_dke_yp('   - name of the file that contains the parameters for the kinetic calculations : ',sparams.dkeparam.file{ii-1});
                        sparams.dkeparam.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the parameters parameters for the kinetic calculations : ',sparams.dkeparam.path{ii-1});
                        %
                    elseif strcmp(sparams.dkeparam.source{ii},'preset')  
                        %
                        sparams.dkeparam.preset{ii} = input_dke_yp('   - name of the preset that contains the parameters for the kinetic calculations : ',sparams.dkeparam.preset{ii-1},{'LH_RT','EC_RT','RT'});%
                        %
                    elseif strcmp(sparams.dkeparam.source{ii},'value')
                        % 
 
                        %
                    end
                else
                    %
                    sparams.dkeparam.id{ii} = input_dke_yp('   - id for the kinetic calculations parameters : ','');
                    sparams.dkeparam.comment{ii} = input_dke_yp('   - comment for the kinetic calculations parameters : ','');
                    %  
                    sparams.dkeparam.source{ii} = input_dke_yp('   - source for the kinetic calculations parameters [preset,file or value]','value',{'preset','file','value'});
                    %
                    if strcmp(sparams.dkeparam.source{ii},'file')
                        %
                        sparams.dkeparam.file{ii} = input_dke_yp('   - name of the file that contains the parameters for the kinetic calculations : ','');
                        sparams.dkeparam.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the parameters parameters for the kinetic calculations : ','.');
                        %
                    elseif strcmp(sparams.dkeparam.source{ii},'preset')  
                        %
                        sparams.dkeparam.preset{ii} = input_dke_yp('   - name of the preset that contains the parameters for the kinetic calculations : ','LH_RT',{'LH_RT','EC_RT','RT'});%
                        %
                    elseif strcmp(sparams.dkeparam.source{ii},'value')
                        %
                        %
                    end                
                end
                %
                disp('------------------------------------------------------------------');
            end
            %
            disp('------------------------------------------------------------------');
            %
        else
            %
            error('Wrong type of input arguments in sluke_params_generator_dkeparam. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_dkeparam. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end