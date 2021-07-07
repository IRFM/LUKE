function sparams = sluke_params_generator_fitequilparam(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (fitequilparam : fit the toroidal MHD equilibrium for ray-tracing calculations, equilibrium consistency, ...). All parameters are in a structure of cell arrays of the SAME SIZE. 
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
    error('Wrong number of input arguments in sluke_params_generator_fitequilparam.')
    %
elseif nargin == 1
    %
    if isstruct(sparams) 
        %
        if isfield(sparams,'machine') && isfield(sparams,'discharge') 
            %
            for ii = 1:length(sparams.machine)
                %
                disp([' - Parameters for the fit of the toroidal MHD equilibrium (used by ray-tracing, equilibrium consistency,...) for discharge ', int2str(ii),'/',int2str(length(sparams.machine)),' (tokamak :',sparams.machine{ii},')']);
                %
                if ii > 1
                    %
                    sparams.equil.fit.id{ii} = input_dke_yp('   - id for the fit of the toroidal MHD equilibrium parameters : ',sparams.equil.fit.id{ii-1});%id for the fit of the toroidal MHD equilibrium parameters
                    sparams.equil.fit.comment{ii} = input_dke_yp('   - comment for the fit of the toroidal MHD equilibrium parameters : ',sparams.equil.fit.comment{ii-1});%comments for the fit on the toroidal MHD equilibrium parameters
                    %  
                    sparams.equil.fit.source{ii} = input_dke_yp('   - source for the fit of the toroidal MHD equilibrium parameters [file or value]',sparams.equil.fit.source{ii-1},{'file','value'});%source for the fit of the toroidal MHD equilibrium parameters : 'file', 'value'
                    %
                    if strcmp(sparams.equil.fit.source{ii},'file')
                        %
                        sparams.equil.fit.file{ii} = input_dke_yp('   - name of the file that contains the parameters for the fit of the toroidal MHD equilibrium : ',sparams.equil.fit.file{ii-1});%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        sparams.equil.fit.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the parameters for the fit of the toroidal MHD equilibrium : ',sparams.equil.fit.path{ii-1});%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        %
                    elseif strcmp(sparams.equil.fit.source{ii},'value')
                        % 
                        sparams.equil.fit.mode_equil{ii} = input_dke_yp('   - (1) : spline-Fourier fit for (psi,theta) equilibrium, (2) : spline-spline fit for (x,y) magnetic equilibrium',sparams.equil.fit.mode_equil{ii-1},[1,2]);
                        sparams.equil.fit.method{ii} = input_dke_yp('   - method for the fit (''spline'' or ''cubic'') : ',sparams.equil.fit.method{ii-1},{'spline','cubic'});
                        %
                        if sparams.equil.fit.mode_equil{ii} == 1
                            sparams.equil.fit.nharm{ii} = input_dke_yp('   - number of harmonics for the Fourier series expansion (Empty : automatic calculation from the equilibrium theta grid size)',sparams.equil.fit.nharm{ii-1});%
                            sparams.equil.fit.ngridresample{ii} = input_dke_yp('   - radial grid resampling on a finer mesh of the equilibrium before fit',sparams.equil.fit.ngridresample{ii-1});
                        else
                            sparams.equil.fit.nharm{ii} = '';
                            sparams.equil.fit.ngridresample{ii} = NaN;
                        end  
                        %
                        sparams.equil.fit.opt_load{ii} = 0;%TODO : must be defined more precisely
                        %
                    end
                else
                    %
                    sparams.equil.fit.id{ii} = input_dke_yp('   - id for the fit of the toroidal MHD equilibrium parameters : ','');%id for the toroial MHD equilibrium parameters
                    sparams.equil.fit.comment{ii} = input_dke_yp('   - comment for the fit of the toroidal MHD equilibrium parameters : ','');%comments on the toroidal MHD equilibrium parameters
                    %  
                    sparams.equil.fit.source{ii} = input_dke_yp('   - source for the fit of of the toroidal MHD equilibrium parameters [code, file or value]','value',{'file','value'});%source of the toroidal MHD equilibrium parameters : 'code', 'file', 'value'
                    %
                    if strcmp(sparams.equil.fit.source{ii},'file')
                        %
                        sparams.equil.fit.file{ii} = input_dke_yp('   - name of the file that contains the parameters for the fit of the toroidal MHD equilibrium : ','');%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        sparams.equil.fit.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the parameters for the fit of the toroidal MHD equilibrium : ','.');%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        %
                    elseif strcmp(sparams.equil.fit.source{ii},'value')
                        %
                        sparams.equil.fit.mode_equil{ii} = input_dke_yp('   - (1) : spline-Fourier fit for (psi,theta) equilibrium, (2) : spline-spline fit for (x,y) magnetic equilibrium',1,[1,2]);
                        sparams.equil.fit.method{ii} = input_dke_yp('   - method for the fit (''spline'' or ''cubic'') : ','spline',{'spline','cubic'});
                        %
                        if sparams.equil.fit.mode_equil{ii} == 1
                            sparams.equil.fit.nharm{ii} = input_dke_yp('   - number of harmonics for the Fourier series expansion (Empty : automatic calculation from the equilibrium theta grid size)');
                            sparams.equil.fit.ngridresample{ii} = input_dke_yp('   - radial grid resampling on a finer mesh of the equilibrium before fit',1001);
                        else
                            sparams.equil.fit.nharm{ii} = '';
                            sparams.equil.fit.ngridresample{ii} = NaN;
                        end  
                        %
                        sparams.equil.fit.opt_load{ii} = 0;%TODO : must be defined more precisely
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
            error('Wrong type of input arguments in sluke_params_generator_fitequilparam. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_fitequilparam. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end