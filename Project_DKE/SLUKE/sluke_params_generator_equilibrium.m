function sparams = sluke_params_generator_equilibrium(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (equilibrium). All parameters are in a structure of cell arrays of the SAME SIZE. 
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
    error('Wrong number of input arguments in sluke_params_generator_equilibrium.')
    %
elseif nargin == 1
    %
    if isstruct(sparams) 
        %
        if isfield(sparams,'machine') && isfield(sparams,'discharge') 
            %
            for ii = 1:length(sparams.machine)
                %
                disp([' - Toroidal MHD equilibrium parameters for discharge ', int2str(ii),'/',int2str(length(sparams.machine)),' (tokamak :',sparams.machine{ii},')']);
                %
                if ii > 1
                    %
                    sparams.equil.id{ii} = input_dke_yp('   - id for the toroidal MHD equilibrium parameters : ',sparams.equil.id{ii-1});%id for the toroial MHD equilibrium parameters
                    sparams.equil.comment{ii} = input_dke_yp('   - comment for the toroidal MHD equilibrium parameters : ',sparams.equil.comment{ii-1});%comments on the toroidal MHD equilibrium parameters
                    %  
                    sparams.equil.source{ii} = input_dke_yp('   - source of the toroidal MHD equilibrium parameters [code, file]',sparams.equil.source{ii-1},{'code','file'});%source of the toroidal MHD equilibrium parameters : 'code', 'file'
                    %
                    if strcmp(sparams.equil.source{ii},'code')
                        %
                        sparams.equil.code{ii} = input_dke_yp('   - name of the code for calculating the toroidal MHD equilibrium parameters [metis,helena,chease]',sparams.equil.code{ii-1},{'metis','helena','chease'});%code name for determining the toroidal MHD equilibrium parameters : 'metis',... (used if source.method is 'code')
                        %
                    elseif strcmp(sparams.equil.source{ii},'file')
                        %
                        sparams.equil.file{ii} = input_dke_yp('   - name of the file that contains the toroidal MHD equilibrium parameters : ',sparams.equil.file{ii-1});%full path of the file that contains the toroidal MHD equilibrium parameters (used if source.method is 'file')
                        sparams.equil.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the toroidal MHD equilibrium parameters : ',sparams.equil.file{ii-1});%full path of the file that contains the toroidal MHD equilibrium parameters (used if source.method is 'file')
                        %
                    end
                else
                    %
                    sparams.equil.id{ii} = input_dke_yp('   - id for the toroidal MHD equilibrium parameters : ','');%id for the toroial MHD equilibrium parameters
                    sparams.equil.comment{ii} = input_dke_yp('   - comment for the toroidal MHD equilibrium parameters : ','');%comments on the toroidal MHD equilibrium parameters
                    %  
                    sparams.equil.source{ii} = input_dke_yp('   - source of the toroidal MHD equilibrium parameters [code, file or value]','code',{'code','file'});%source of the toroidal MHD equilibrium parameters : 'code', 'file'
                    %
                    if strcmp(sparams.equil.source{ii},'code')
                        %
                        sparams.equil.code{ii} = input_dke_yp('   - name of the code for calculating the toroidal MHD equilibrium parameters [metis,helena,chease]','metis',{'metis','helena','chease'});%code name for determining the toroidal MHD equilibrium parameters : 'metis',... (used if source.method is 'code')
                        %
                    elseif strcmp(sparams.equil.source{ii},'file')
                        %
                        sparams.equil.file{ii} = input_dke_yp('   - name of the file that contains the toroidal MHD equilibrium parameters : ','');%full path of the file that contains the toroidal MHD equilibrium parameters (used if source.method is 'file')
                        sparams.equil.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the toroidal MHD equilibrium parameters : ','.');%full path of the file that contains the toroidal MHD equilibrium parameters (used if source.method is 'file')
                        %
                    end                
                end
                %
                disp('------------------------------------------------------------------');
                %
            end
            %
            disp('------------------------------------------------------------------');
            %
            sparams = sluke_params_generator_equilconsistencyparam(sparams);% Interactive mode : parameters for checking the consistency of the toroidal MHD equilibrium. Calculate some additional useful quantities.
            %
        else
            %
            error('Wrong type of input arguments in sluke_params_generator_equilibrium. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_equilibrium. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end