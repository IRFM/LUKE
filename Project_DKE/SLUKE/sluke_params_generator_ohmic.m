function sparams = sluke_params_generator_ohmic(sparams)
%
%
% LUKE - Generator of simulation parameters structure for sluke calculations (ohmic fied). All parameters are in a structure of cell arrays of the SAME SIZE. 
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
    error('Wrong number of input arguments in sluke_params_generator_ohmic.')
    %
elseif nargin == 1
    %
    if isstruct(sparams) 
        %
        if isfield(sparams,'machine') && isfield(sparams,'discharge') 
            %
            for ii = 1:length(sparams.machine)
                %
                disp([' - Ohmic field parameters for discharge ', int2str(ii),'/',int2str(length(sparams.machine)),' (tokamak :',sparams.machine{ii},')']);
                %
                if ii > 1
                    %
                    sparams.ohm.id{ii} = input_dke_yp('   - id for the Ohmic field parameters : ',sparams.equil.id{ii-1});%id for the Ohmic field parameters
                    sparams.ohm.comment{ii} = input_dke_yp('   - comment for the Ohmic field parameters : ',sparams.equil.comment{ii-1});%comments on the Ohmic field parameters
                    %  
                    sparams.ohm.source{ii} = input_dke_yp('   - source of the Ohmic field parameters [code, file or value]',sparams.ohm.source{ii-1},{'code','file','value'});%source of the Ohmic field parameters : 'code', 'file', 'value'
                    %
                    if strcmp(sparams.ohm.source{ii},'code')
                        %
                        sparams.ohm.code{ii} = input_dke_yp('   - name of the code for calculating the Ohmic field parameters [metis]',sparams.ohm.code{ii-1},{'metis'});%code name for determining the Ohmic field parameters : 'metis',... (used if source.method is 'code')
                        %
                    elseif strcmp(sparams.ohm.source{ii},'file')
                        %
                        sparams.ohm.file{ii} = input_dke_yp('   - name of the file that contains the Ohmic field parameters : ',sparams.ohm.file{ii-1});%full path of the file that contains the Ohmic field parameters (used if source.method is 'file')
                        sparams.ohm.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the Ohmic field parameters : ',sparams.ohm.file{ii-1});%full path of the file that contains the Ohmic field parameters (used if source.method is 'file')
                        %
                    end
                else
                    %
                    sparams.ohm.id{ii} = input_dke_yp('   - id for the Ohmic field parameters : ','');%id for the Ohmic field parameters
                    sparams.ohm.comment{ii} = input_dke_yp('   - comment for the Ohmic field parameters: ','');%comments on the Ohmic field parameters 
                    %  
                    sparams.ohm.source{ii} = input_dke_yp('   - source of the toroidal MHD equilibrium [code, file or value]','code',{'code','file','value'});%source of the Ohmic field parameters : 'code', 'file', 'value'
                    %
                    if strcmp(sparams.ohm.source{ii},'code')
                        %
                        sparams.ohm.code{ii} = input_dke_yp('   - name of the code for calculating the Ohmic field parameters [metis]','metis',{'metis'});%code name for determining the Ohmic field parameters : 'metis',... (used if source.method is 'code')
                        %
                    elseif strcmp(sparams.ohm.source{ii},'file')
                        %
                        sparams.ohm.file{ii} = input_dke_yp('   - name of the of the file that contains the Ohmic field parameters : ','');%full path of the file that contains the Ohmic field parameters (used if source.method is 'file')
                        sparams.ohm.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the Ohmic field parameters : ','.');%full path of the file that contains the Ohmic field parameters (used if source.method is 'file')
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
            error('Wrong type of input arguments in sluke_params_generator_ohmic. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_ohmic. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end