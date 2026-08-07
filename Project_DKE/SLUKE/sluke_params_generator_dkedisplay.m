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
function sparams = sluke_params_generator_dkedisplay(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (dkedisplay). All parameters are in a structure of cell arrays of the SAME SIZE. 
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
    error('Wrong number of input arguments in sluke_params_generator_dkedisplay.')
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
                    sparams.dkedisplay.id{ii} = input_dke_yp('   - id for the display options of the kinetic calculations : ',sparams.dkedisplay.id{ii-1});
                    sparams.dkedisplay.comment{ii} = input_dke_yp('   - comment for the display options of the kinetic calculations : ',sparams.dkedisplay.comment{ii-1});
                    %  
                    sparams.dkedisplay.source{ii} = input_dke_yp('   - source for the kinetic calculations display options [preset, file or value]',sparams.dkedisplay.source{ii-1},{'preset','file','value'});
                    %
                    if strcmp(sparams.dkedisplay.source{ii},'file')
                        %
                        sparams.dkedisplay.file{ii} = input_dke_yp('   - name of the file that contains the display options for the kinetic calculations : ',sparams.dkedisplay.file{ii-1});
                        sparams.dkedisplay.path{ii} = input_dke_yp('   - full or local (.) path of the file that containss the display options for the kinetic calculations : ',sparams.dkedisplay.path{ii-1});
                        %
                    elseif strcmp(sparams.dkedisplay.source{ii},'preset')  
                        %
                        sparams.dkedisplay.preset{ii} = input_dke_yp('   - name of the preset that contains the parameters for the kinetic calculations : ',sparams.dkedisplay.preset{ii-1},{'NO_DISPLAY','PARTIAL_VISUAL','VISUAL'});
                        %
                    elseif strcmp(sparams.dkedisplay.source{ii},'value')
                        % 
 
                        %
                    end
                else
                    %
                    sparams.dkedisplay.id{ii} = input_dke_yp('   - id for the display options of the kinetic calculations : ','');
                    sparams.dkedisplay.comment{ii} = input_dke_yp('   - comment for the display options of the kinetic calculations : ','');
                    %  
                    sparams.dkedisplay.source{ii} = input_dke_yp('   - source for the kinetic calculations display options [preset, file or value]','value',{'preset','file','value'});
                    %
                    if strcmp(sparams.dkedisplay.source{ii},'file')
                        %
                        sparams.dkedisplay.file{ii} = input_dke_yp('   - name of the file that contains the display options for the kinetic calculations : ','');
                        sparams.dkedisplay.path{ii} = input_dke_yp('   - full or local (.) path of the file that containss the display options for the kinetic calculations : ','.');
                        %
                    elseif strcmp(sparams.dkedisplay.source{ii},'preset')  
                        %
                        sparams.dkedisplay.preset{ii} = input_dke_yp('   - name of the preset that contains the parameters for the kinetic calculations : ','NO_DISPLAY',{'NO_DISPLAY','PARTIAL_VISUAL','VISUAL'});
                        %
                    elseif strcmp(sparams.dkedisplay.source{ii},'value')
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
            error('Wrong type of input arguments in sluke_params_generator_dkedisplay. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_dkedisplay. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end