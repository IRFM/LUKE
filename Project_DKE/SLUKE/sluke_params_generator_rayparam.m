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
function sparams = sluke_params_generator_rayparam(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (rayparam : fit the toroidal MHD equilibrium for ray-tracing calculations, equilibrium consistency, ...). All parameters are in a structure of cell arrays of the SAME SIZE. 
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
    error('Wrong number of input arguments in sluke_params_generator_rayparam.')
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
                    sparams.launch.rayparam.id{ii} = input_dke_yp('   - id for the C3PO ray-tracing parameters : ',sparams.launch.rayparam.id{ii-1});
                    sparams.launch.rayparam.comment{ii} = input_dke_yp('   - comment for the C3PO ray-tracing parameters : ',sparams.launch.rayparam.comment{ii-1});
                    %  
                    sparams.launch.rayparam.source{ii} = input_dke_yp('   - source for the C3PO ray-tracing parameters [file or value]',sparams.launch.rayparam.source{ii-1},{'file','value'});
                    %
                    if strcmp(sparams.launch.rayparam.source{ii},'file')
                        %
                        sparams.launch.rayparam.file{ii} = input_dke_yp('   - name of the file that contains the parameters for the ray-tracing C3PO : ',sparams.launch.rayparam.file{ii-1});
                        sparams.launch.rayparam.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the parameters for the ray-tracing C3PO : ',sparams.launch.rayparam.path{ii-1});
                        %
                    elseif strcmp(sparams.rayparam.source{ii},'value')
                        % 
                        sparams.launch.rayparam.test_mode{ii} = input_dke_yp('   - (1) : test mode, (0) : standard calculations',sparams.launch.rayparam.test_mode{ii-1},[0,1]);
                        sparams.launch.rayparam.tensortype{ii} = input_dke_yp('   - type of dielectric tensor ((0:cold, 1:warm, 2:hot, 3:weak realtivistic, 4:full relativistic)',sparams.launch.rayparam.method{ii-1},[0,1,2,3,4]);
                        sparams.launch.rayparam.t0{ii} = input_dke_yp('   - initial time for the ray-tracing (default = 0)',sparams.launch.rayparam.t0{ii-1});
                        sparams.launch.rayparam.dt0{ii} = input_dke_yp('   - minimum time step for the ray-tracing (default = 1e-4)',sparams.launch.rayparam.dt0{ii-1});
                        sparams.launch.rayparam.dS{ii} = input_dke_yp('   - minimum curvilinear step dS (default = 1e-4)',sparams.launch.rayparam.dS{ii-1});
                        sparams.launch.rayparam.tol{ii} = input_dke_yp('   - when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly (default = 1e-12)',sparams.launch.rayparam.tol{ii-1});
                        sparams.launch.rayparam.kmax{ii} = input_dke_yp('   - maximum number of steps (default = 30000)',sparams.launch.rayparam.kmax{ii-1});
                        sparams.launch.rayparam.ncyclharm{ii} = input_dke_yp('   - number of cyclotron harmonics (just for hot and relativistic dielectric tensors). One for the LH wave, 3 for the EC wave.',sparams.launch.rayparam.ncyclharm{ii-1});
                        sparams.launch.rayparam.reflection{ii} = input_dke_yp('   - 1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma',sparams.launch.rayparam.reflection{ii-1});
                        sparams.launch.rayparam.rel_opt{ii} = input_dke_yp('   - option (1) for relativistic or (0) for non-relativistic calculations',sparams.launch.rayparam.rel_opt{ii-1});
                        sparams.launch.rayparam.nperp{ii} = input_dke_yp('   - number of points in pperp integration for damping calculations',sparams.launch.rayparam.nperp{ii-1});
                        sparams.launch.rayparam.pperpmax{ii} = input_dke_yp('   - maximum value of pperp in damping calculations',sparams.launch.rayparam.pperpmax{ii-1});
                        sparams.launch.rayparam.tau_lim{ii} = input_dke_yp('   - value of optical depth beyond which the wave is considered absorbed(default = 20)',sparams.launch.rayparam.tau_lim{ii-1});
                        sparams.launch.rayparam.metricmode{ii} = input_dke_yp('   - metricmode -> 1 : only curvilinear metric, 2 : both curvilinear and cartesian metric',sparams.launch.rayparam.metricmode{ii-1});
                        sparams.launch.rayparam.rhoswitch{ii} = input_dke_yp('   - Radial position at which the switch occurs when metricmode = 2',sparams.launch.rayparam.rhoswitch{ii-1});
                        sparams.launch.rayparam.substitution_method{ii} = input_dke_yp('   - Method of substitution : 1->dichotomy1D, 2->dichotomy2D, 3->newton_numeric1D, 4->newton_numeric2D, 5->newton_analytic1D, 6->newton_analytic2D, 7->newton_mix2D',sparams.launch.rayparam.substitution_method{ii-1});
                        %
                    end
                else
                    %
                    sparams.launch.rayparam.id{ii} = input_dke_yp('   - id for the C3PO ray-tracing parameters : ','');%id for the toroial MHD equilibrium parameters
                    sparams.launch.rayparam.comment{ii} = input_dke_yp('   - comment for the C3PO ray-tracing parameters : ','');%comments on the toroidal MHD equilibrium parameters
                    %  
                    sparams.launch.rayparam.source{ii} = input_dke_yp('   - source for the C3PO ray-tracing parameters [file or value]','value',{'file','value'});%source of the toroidal MHD equilibrium parameters : 'code', 'file', 'value'
                    %
                    if strcmp(sparams.launch.rayparam.source{ii},'file')
                        %
                        sparams.launch.rayparam.file{ii} = input_dke_yp('   - name of the file that contains the parameters for the fit of the toroidal MHD equilibrium : ','');%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        sparams.launch.rayparam.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the parameters for the fit of the toroidal MHD equilibrium : ','.');%full path of the file that contains the parameters for the fit of the toroidal MHD equilibrium (used if source.method is 'file')
                        %
                    elseif strcmp(sparams.launch.rayparam.source{ii},'value')
                        %
                        sparams.launch.rayparam.test_mode{ii} = input_dke_yp('   - ray-tracing mode (1) : (0) standard, (1) test mode',0,[0,1]);
                        sparams.launch.rayparam.tensortype{ii} = input_dke_yp('   - type of dielectric tensor ((0: cold, 1: warm, 2: hot, 3: weak relativistic, 4: full relativistic)',0,[0,1,2,3,4]);
                        sparams.launch.rayparam.t0{ii} = input_dke_yp('   - initial time for the ray-tracing',0);
                        sparams.launch.rayparam.dt0{ii} = input_dke_yp('   - minimum time step for the ray-tracing',1e-4);
                        sparams.launch.rayparam.dS{ii} = input_dke_yp('   - minimum curvilinear step dS ',1e-4);
                        sparams.launch.rayparam.tol{ii} = input_dke_yp('   - ray-tracing tolerance. When it is increased (less accurate calculation of D=0), tfinal must be increased accordingly.',1e-12);
                        sparams.launch.rayparam.kmax{ii} = input_dke_yp('   - maximum number of steps',30000);
                        sparams.launch.rayparam.ncyclharm{ii} = input_dke_yp('   - number of cyclotron harmonics (just for hot and relativistic dielectric tensors). One for the LH wave, 3 for the EC wave.',1);
                        sparams.launch.rayparam.reflection{ii} = input_dke_yp('   - wave reflection : (1) enforced at the plasma boundary, (0) the code calculates itself if the ray must leave of not the plasma',1);
                        sparams.launch.rayparam.rel_opt{ii} = input_dke_yp('   - relativistic calculations : (1) yes, (0) non',1);
                        sparams.launch.rayparam.nperp{ii} = input_dke_yp('   - number of points in pperp integration for damping calculations',1000);
                        sparams.launch.rayparam.pperpmax{ii} = input_dke_yp('   - maximum value of pperp in damping calculations',10);
                        sparams.launch.rayparam.tau_lim{ii} = input_dke_yp('   - value of optical depth beyond which the wave is considered absorbed',20);
                        sparams.launch.rayparam.metricmode{ii} = input_dke_yp('   - metric mode (for EC wave at plasma center) : (1) only curvilinear metric, (2) both curvilinear and cartesian metric',1);
                        sparams.launch.rayparam.rhoswitch{ii} = input_dke_yp('   - normalized radial position at which the switch occurs when metric mode = 2',0.1);
                        sparams.launch.rayparam.substitution_method{ii} = input_dke_yp('   - Method of substitution : (1) dichotomy1D, (2) dichotomy2D, (3) newton_numeric1D, (4) newton_numeric2D, (5) newton_analytic1D, (6) newton_analytic2D, (7) newton_mix2D',7);
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
            error('Wrong type of input arguments in sluke_params_generator_rayparam. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_rayparam. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end