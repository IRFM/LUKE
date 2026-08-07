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
function sparams = sluke_params_generator_launch(sparams)
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
    error('Wrong number of input arguments in sluke_params_generator_launch.')
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
            error('Wrong type of input arguments in sluke_params_generator_launch. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_launch. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end
%
  
   
    %{
    % RF WAVES
    %
    launch_option = input_dke_yp('Do you want to launch RF wave ?',0,[0,1]);
    %
    if launch_option == 1
        %
        for itok = 1:ntoks
            %
            for jdischarge = 1:ndischarges(itok)
                %
                ii = (itok-1)*ndischarges(itok)+jdischarge;
                %
                disp('------------------------------------------------------------------');
                disp([' - Discharge ',int2str(jdischarge),'/',int2str(ndischarges(itok)),' for tokamak ',tokname{itok}]);
                %
                sparams.launch.antenna.type{ii} = input_dke_yp('   - antenna type(s) [lh, ec or lh+ec]','lh',{'lh','ec','lh+ec'});%(lh) lower hybrid wave or (ec) electron cyclotron waves, or 'lh+ec' if both waves are launched
                sparams.launch.antenna.comment{ii} = input_dke_yp('   - antenna comment : ','');%comments on the launch structure calculation
                %
                % Lower hybrid wave (lh)
                %
                if strfind(sparams.launch.antenna.type{ii},'lh')
                    %
                    sparams.launch.antenna.lh.spectrum.source.method{ii} = input_dke_yp('   - antenna power spectrum source [code, file or value]','code',{'code','file','value'});%source of the excited power spectrum : 'code', 'file', 'value'
                    %
                    if strcmp(sparams.launch.antenna.lh.spectrum.source.method{ii},'code')
                        %
                        sparams.launch.antenna.lh.spectrum.source.code{ii} = input_dke_yp('   - name of the code for calculating the power spectrum source [aloha]','aloha',{'aloha'});%code name for determining the excited power spectrum : 'aloha',... (used if source.method is 'code')
                        %
                    elseif strcmp(sparams.launch.antenna.lh.spectrum.source.method{ii},'file')
                        %
                        sparams.launch.antenna.lh.spectrum.source.file{ii} = input_dke_yp('   - full path of the file that contains the power spectrum : ','');%full path of the file that contains the power spectrum (used if source.method is 'file')
                        %
                    end
                    %
                    sparams.launch.antenna.lh.spectrum.id{ii} = input_dke_yp('   - id for the calculation method of the excited power spectrum : ','');%id for the calculation method of the excited power spectrum
                    %
                    % Lower hybrid wave power spectrum calculated by the ALOHA coupling code 
                    %
                    if strcmp(sparams.launch.antenna.lh.spectrum.source.code{ii},'aloha')
                        %
                        disp('------------------------------------------------------------------');
                        disp('Settings for ALOHA power spectrum calculations.');
                        disp('------------------------------------------------------------------');
                        %
                        dispremoteprofiles % list of available remote profile numbers
                        %
                        sparams.launch.antenna.lh.spectrum.aloha.remote_profile{ii} = input_dke_yp('   - remote profile number (use those corresponding to a scheduler : condor, slurm, pbs, torque, ...). Option (0) corresponds to local interactive run.');%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
                        sparams.launch.antenna.lh.spectrum.aloha.display.data{ii} = input_dke_yp('   - display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1))',2,[-1,0,1,2]);%display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist
                        %
                        if strcmp(sparams.machine{itok},'TS') || strcmp(sparams.machine{itok},'WEST')
                            %
                            sparams.launch.antenna.lh.spectrum.aloha.port{ii} = input_dke_yp('   - antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST','Q6A',{'Q6A','Q6B','Q6A+Q6B'});%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
                            %
                        else
                            %
                            sparams.launch.antenna.lh.spectrum.aloha.port{ii} = input_dke_yp('   - antenna ports : ','');
                            %
                        end
                        %
                        sparams.launch.antenna.lh.spectrum.aloha.display.results{ii} = input_dke_yp('   - display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)',2,[-1,0,1,2]);%display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)
                        sparams.launch.antenna.lh.spectrum.aloha.optim.method{ii} = input_dke_yp('   - (1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess',1,[0,1]);%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
                        %
                        if sparams.launch.antenna.lh.spectrum.aloha.optim.method{ii} == 0
                            %
                            sparams.launch.antenna.lh.spectrum.aloha.optim.ne_guess{ii} = input_dke_yp('   - Edge density in front of the grill (initial guess interval or enforced value) (m-3)',1e17);%Edge density in front of the grill (initial guess interval or enforced value) (m-3)
                            sparams.launch.antenna.lh.spectrum.aloha.optim.tolfun{ii} = '';%Relative tolerance on targets (if aloha.optim.method = 1)
                            sparams.launch.antenna.lh.spectrum.aloha.optim.tolx{ii} = '';%Relative tolerance on inputs (if aloha.optim.method = 1)
                            sparams.launch.antenna.lh.spectrum.aloha.optim.nitmax{ii} = '';%Maximum number of iterations (if aloha.optim.method = 1)
                            %
                        else
                            %
                            sparams.launch.antenna.lh.spectrum.aloha.optim.ne_guess{ii} = input_dke_yp('   - Edge density in front of the grill (initial guess interval) (m-3)',[0.8e17,5e17]);%Edge density in front of the grill (initial guess or enforced value) (m-3)
                            sparams.launch.antenna.lh.spectrum.aloha.optim.tolfun{ii} = input_dke_yp('   - Relative tolerance on targets',1e-2);%Relative tolerance on targets (if aloha.optim.method = 1)
                            sparams.launch.antenna.lh.spectrum.aloha.optim.tolx{ii} = input_dke_yp('   - Relative tolerance on inputs',1e-2);%Relative tolerance on inputs (if aloha.optim.method = 1)
                            sparams.launch.antenna.lh.spectrum.aloha.optim.nitmax{ii} = input_dke_yp('   - Maximum number of iterations',20);%Maximum number of iterations (if aloha.optim.method = 1)
                            %
                        end
                        %
                        disp('------------------------------------------------------------------');
                        disp('Settings for ALOHA power spectrum to C3PO launch structure');
                        disp('------------------------------------------------------------------');
                        %
                        sparams.launch.antenna.lh.spectrum.aloha.param_tor.dir{ii} = input_dke_yp('   - build antenna directivity',1);%build antenna directivity
                        sparams.launch.antenna.lh.spectrum.aloha.aloha.param_tor.mode{ii} = input_dke_yp('   - toroidal power spectrum',0);%toroidal power spectrum
                        sparams.launch.antenna.lh.spectrum.aloha.aloha.param_tor.nlobes{ii} = input_dke_yp('   - number of lobes selected in the power spectrum',5);%number of lobes selected in the power spectrum
                        sparams.launch.antenna.lh.spectrum.aloha.param_pol.ny{ii} = input_dke_yp('   - ny',0);
                        sparams.launch.antenna.lh.spectrum.aloha.sdisplay.inter{ii} = input_dke_yp('   - Interactive mode (yes : 1, no : 0)',0,[0,1]);%interactive mode
                        sparams.launch.antenna.lh.spectrum.aloha.opt_optim{ii} = input_dke_yp('   - opt_optim',0);
                        %
                    end
                    %
                    % Initial parameters for building LAUNCH structures used by C3PO ray-tracing
                    %
                    disp('------------------------------------------------------------------');
                    disp('General settings for C3PO launch structure');
                    disp('------------------------------------------------------------------');
                    %
                    sparams.launch.antenna.lh.phi0{ii} = input_dke_yp('   - Position of the antenna : toroidal angle phi0 (rad)',0);
                    sparams.launch.antenna.lh.LFS{ii} = input_dke_yp('   - Position of the antenna : (1) Low magnetic Field Side (LFS), (0) High magnetic Field Side (HFS)',1,[0,1]);
                    sparams.launch.antenna.lh.m0{ii} = input_dke_yp('   - Poloidal mode number of the wave vector at launch',0+1i);
                    sparams.launch.antenna.lh.i_ref{ii} = input_dke_yp('   - iref ',100);
                    sparams.launch.antenna.lh.mmode{ii} = input_dke_yp('   - mmode (-1 or +1)',-1,[-1,1]);
                    sparams.launch.antenna.lh.n0{ii} = input_dke_yp('   - n0',NaN);
                    sparams.launch.antenna.lh.kz0{ii} = input_dke_yp('   - kz0',NaN);
                    sparams.launch.antenna.lh.ns{ii} = input_dke_yp('   - ns',1000);
                    sparams.launch.antenna.lh.cocurrent{ii} = input_dke_yp('   - RF current drives co-current (1) or counter-current (-1)',1,[-1,1]);%the Lower Hybrid wave drive co-current (1) or counter-current (-1)
                    %
                    sparams.launch.antenna.lh.method1{ii} = input_dke_yp('   - method1 (pchip or spline)','pchip');
                    sparams.launch.antenna.lh.method2{ii} = input_dke_yp('   - method2 (pchip or spline)','spline');
                    %
                elseif strfind(sparams.launch.antenna.type{ii},'ec')
                    %
                    % TODO interactive input for ec wave
                    %
                end
            end
        end
        %
        disp('------------------------------------------------------------------');
    end
%}



