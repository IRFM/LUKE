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
function sparams = sluke_params_generator_raydisplay(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (raydisplay). All parameters are in a structure of cell arrays of the SAME SIZE. 
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
    error('Wrong number of input arguments in sluke_params_generator_raydisplay.')
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
                    sparams.launch.raydisplay.id{ii} = input_dke_yp('   - id for the C3PO ray-tracing display options : ',sparams.launch.raydisplay.id{ii-1});
                    sparams.launch.raydisplay.comment{ii} = input_dke_yp('   - comment for the C3PO ray-tracing display options : ',sparams.launch.raydisplay.comment{ii-1});
                    %  
                    sparams.launch.raydisplay.source{ii} = input_dke_yp('   - source for the C3PO ray-tracing display options [file or value]',sparams.launch.raydisplay.source{ii-1},{'file','value'});
                    %
                    if strcmp(sparams.launch.raydisplay.source{ii},'file')
                        %
                        sparams.launch.raydisplay.file{ii} = input_dke_yp('   - name of the file that contains the display options for  C3PO ray-tracing : ',sparams.launch.raydisplay.file{ii-1});
                        sparams.launch.raydisplay.path{ii} = input_dke_yp('   - full or local (.) path of the file that containss the display options for C3PO ray-tracing : ',sparams.launch.raydisplay.path{ii-1});
                        %
                    elseif strcmp(sparams.launch.raydisplay.source{ii},'value')
                        % 
                        sparams.launch.raydisplay.ray{ii} = input_dke_yp('   - display steps of C3PO ray-tracing (1) yes, (0) no',sparams.launch.raydisplay.ray{ii-1},[0,1]);
                        sparams.launch.raydisplay.equilibrium{ii} = input_dke_yp('   - display toroidal MHD equilibrium (1) yes, (0) no',sparams.launch.raydisplay.equilibrium{ii-1},[0,1]);
                        sparams.launch.raydisplay.fluctuations{ii} = input_dke_yp('   - display fluctuations (activate if fluctutations are on in ray calculations) (0: no, 1: yes)',sparams.launch.raydisplay.fluctuations{ii-1},[0,1]);
                        sparams.launch.raydisplay.p_opt{ii} = input_dke_yp('   - Printing or saving ray-tracing figures',sparams.launch.raydisplay.p_opt{ii-1},[-1,0,1,2]);
                        sparams.launch.raydisplay.mdce{ii} = input_dke_yp('   - distributed computing (1) yes, (0) no',sparams.launch.raydisplay.mdce{ii-1},[0,1]); 
                        %
                    end
                else
                    %
                    sparams.launch.raydisplay.id{ii} = input_dke_yp('   - id for the C3PO ray-tracing display options : ','');
                    sparams.launch.raydisplay.comment{ii} = input_dke_yp('   - comment for the C3PO ray-tracing display options : ','');
                    %  
                    sparams.launch.raydisplay.source{ii} = input_dke_yp('   - source for the C3PO ray-tracing display options [file or value]','value',{'file','value'});
                    %
                    if strcmp(sparams.launch.raydisplay.source{ii},'file')
                        %
                        sparams.launch.raydisplay.file{ii} = input_dke_yp('   - name of the file that contains the display options for  C3PO ray-tracing : ','');
                        sparams.launch.raydisplay.path{ii} = input_dke_yp('   - full or local (.) path of the file that containss the display options for C3PO ray-tracing : ','.');
                        %
                    elseif strcmp(sparams.launch.raydisplay.source{ii},'value')
                        %
                        sparams.launch.raydisplay.ray{ii} = input_dke_yp('   - display steps of C3PO ray-tracing (1) yes, (0) no',0,[0,1]);
                        sparams.launch.raydisplay.equilibrium{ii} = input_dke_yp('   - display toroidal MHD equilibrium (1) yes, (0) no',0,[0,1]);
                        sparams.launch.raydisplay.fluctuations{ii} = input_dke_yp('   - display fluctuations (activate if fluctutations are on in ray calculations) (0: no, 1: yes)',0,[0,1]);
                        sparams.launch.raydisplay.p_opt{ii} = input_dke_yp('   - Printing or saving ray-tracing figures',0,[-1,0,1,2]);
                        sparams.launch.raydisplay.mdce{ii} = input_dke_yp('   - distributed computing (1) yes, (0) no',0,[0,1]);
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
            error('Wrong type of input arguments in sluke_params_generator_raydisplay. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_raydisplay. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end