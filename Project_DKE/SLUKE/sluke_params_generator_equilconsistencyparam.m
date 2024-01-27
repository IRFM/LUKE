function sparams = sluke_params_generator_equilconsistencyparam(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (equilconsistencyparam : spline-fourier fit of the toroidal MHD equilibrium for : ray-tracing calculations, equilibrium consistency, ...). All parameters are in a structure of cell arrays of the SAME SIZE. 
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
    error('Wrong number of input arguments in sluke_params_generator_equilconsistencyparam.')
    %
elseif nargin == 1
    %
    if isstruct(sparams) 
        %
        if isfield(sparams,'machine') && isfield(sparams,'discharge') 
            %
            % Interactive mode for buiding sparams
            %
            ntoks = length(sparams.machine);
            disp('------------------------------------------------------------------');
            %
            for ii = 1:length(sparams.machine)
                %
                disp([' - Parameters for checking the consistency of the toroidal MHD equilibrium for discharge ', int2str(ii),'/',int2str(length(sparams.machine)),' (tokamak :',sparams.machine{ii},')']);
                %
                if ii > 1
                    %
                    sparams.equil.equilconsistency.id{ii} = input_dke_yp('   - id of the parameters for checking the consistency of the toroidal MHD equilibrium : ',sparams.equil.equilconsistency.id{ii-1});
                    sparams.equil.equilconsistency.comment{ii} = input_dke_yp('   - comment on the parameters for checking the consistency of the toroidal MHD equilibrium : ',sparams.equil.equilconsistency.comment{ii-1});
                    %  
                    sparams.equil.equilconsistency.source{ii} = input_dke_yp('   - source for parameters for checking the consistency of the toroidal MHD equilibrium [file or value]',sparams.equil.equilconsistency.source{ii-1},{'file','value'});
                    %
                    if strcmp(sparams.equil.equilconsistency.source{ii},'file')
                        %
                        sparams.equil.equilconsistency.file{ii} = input_dke_yp('   - name of the file that contains the parameters for checking the consistency of the toroidal MHD equilibrium : ',sparams.equil.equilconsistency.file{ii-1});%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        sparams.equil.equilconsistency.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the parameters for checking the consistency of the toroidal MHD equilibrium : ',sparams.equil.equilconsistency.path{ii-1});%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        %
                    else
                        %
                        sparams.equil.equilconsistency.auto_mode{ii} = input_dke_yp('   - automatic calculations (1) or not (0)',sparams.equil.equilconsistency.auto_mode{ii-1},[0,1]);
                        %
                        if sparams.equil.equilconsistency.auto_mode{ii} == 0
                            sparams.equil.equilconsistency.display_mode{ii} = input_dke_yp('   - display figures (1) or not (0)',sparams.equil.equilconsistency.display_mode{ii-1},[0,1]);
                        else
                            sparams.equil.equilconsistency.display_mode{ii} = 0;
                        end
                        %
                        sparams.equil.equilconsistency.prho{ii} = input_dke_yp('   - number of radial points for equilibrium reconstruction from equil_fit. If ''NaN'' or empty, prho = max(101,length(equil.psi_apRp)) automatically.',sparams.equil.equilconsistency.prho{ii-1});
                        sparams.equil.equilconsistency.mtheta{ii} = input_dke_yp('   - number of poloidal points for equilibrium reconstruction from equil_fit. If ''NaN'' or empty, mtheta = max(105,length(equil.theta))) automatically.',sparams.equil.equilconsistency.mtheta{ii-1});
                        %
                    end
                    %
                else
                    %
                    sparams.equil.equilconsistency.id{ii} = input_dke_yp('   - id of the parameters for checking the consistency of the toroidal MHD equilibrium : ','');
                    sparams.equil.equilconsistency.comment{ii} = input_dke_yp('   - comment on the parameters for checking the consistency of the toroidal MHD equilibrium : ','');
                    %  
                    sparams.equil.equilconsistency.source{ii} = input_dke_yp('   - source for parameters for checking the consistency of the toroidal MHD equilibrium [file or value]','value',{'file','value'});
                    %
                    if strcmp(sparams.equil.equilconsistency.source{ii},'file')
                        %
                        sparams.equil.equilconsistency.file{ii} = input_dke_yp('   - name of the file that contains the parameters for checking the consistency of the toroidal MHD equilibrium : ','');%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        sparams.equil.equilconsistency.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the parameters for checking the consistency of the toroidal MHD equilibrium : ','.');%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        %
                    else
                        %
                        sparams.equil.equilconsistency.auto_mode{ii} = input_dke_yp('   - automatic calculations (1) or not (0)',1,[0,1]);
                        %
                        if sparams.equil.equilconsistency.auto_mode{ii} == 0
                            sparams.equil.equilconsistency.display_mode{ii} = input_dke_yp('   - display figures (1) or not (0)',1,[0,1]);
                        else
                            sparams.equil.equilconsistency.display_mode{ii} = 0;
                        end
                        %
                        sparams.equil.equilconsistency.prho{ii} = input_dke_yp('   - number of radial points for equilibrium reconstruction from equil_fit. If ''NaN'' or empty, prho = max(101,length(equil.psi_apRp)) automatically.');
                        sparams.equil.equilconsistency.mtheta{ii} = input_dke_yp('   - number of poloidal points for equilibrium reconstruction from equil_fit. If ''NaN'' or empty, mtheta = max(105,length(equil.theta))) automatically.');
                        %
                    end 
                    %
                end
                %
                disp('------------------------------------------------------------------');
            end
             %
            disp('------------------------------------------------------------------');
            %
            sparams = sluke_params_generator_fitequilparam(sparams);% Interactive mode : parameters for the fit of the toroidal MHD equilibrium (spline-fourier fit of the toroidal MHD equilibrium for : ray-tracing calculations, equilibrium consistency, ...)
            %
        else
            %
            error('Wrong type of input arguments in sluke_params_generator_equilconsistencyparam. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_equilconsistencyparam. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end