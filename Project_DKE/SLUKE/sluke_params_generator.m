function sparams = sluke_params_generator(varargin)
%
% LUKE - Generator of simulation parameters structure for sluke calculations. All parameters are in a structure of cell arrays of the SAME SIZE. 
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
clc
%
sparams = struct;
%
if nargin == 0
    %
    % Interactive mode for buiding sparams
    %
    disp('------------------------------------------------------------------');
    disp('------------------------------------------------------------------');
    disp('Interactive input of simulation parameters for sluke calculations');
    disp('------------------------------------------------------------------');
    disp('------------------------------------------------------------------');
    disp('WARNING : this procedure may be long if many inputs are considered');
    disp('------------------------------------------------------------------');
    ntoks = input_dke_yp('Number of tokamaks',1);
    disp('------------------------------------------------------------------');
    %
    for itok = 1:ntoks
        %
        tokname{itok} = input_dke_yp(['Name of tokamak #',int2str(itok),'/#',int2str(ntoks),' (TS,WEST,EAST,CMOD,ITER,HL2A,TOK)'],'WEST',{'TS','WEST','EAST','CMOD','ITER','TOK'});
        %
        ndischarges(itok) = input_dke_yp(['Number of discharges (as many as time intervals) for tokamak ',tokname{itok}],1);
        disp('------------------------------------------------------------------');
        %
        for jdischarge = 1:ndischarges(itok)
            %
            disp([' - Discharge ',int2str(jdischarge),'/',int2str(ndischarges(itok)),' for tokamak ',tokname{itok}]);
            %
            if jdischarge > 1
                discharge{itok,jdischarge} = input_dke_yp('   - shot number',discharge{itok,jdischarge-1});
            else
                discharge{itok,jdischarge} = input_dke_yp('   - shot number','');
            end
            %
            if jdischarge > 1
                tmin(itok,jdischarge) = input_dke_yp('   - tmin (s)',tmin(itok,jdischarge-1));
            else
                tmin(itok,jdischarge) = input_dke_yp('   - tmin (s)',0);
            end
            %
            if jdischarge > 1
                tmax(itok,jdischarge) = input_dke_yp('   - tmax (s)',tmax(itok,jdischarge-1));
            else
                tmax(itok,jdischarge) = input_dke_yp('   - tmax (s)',0);
            end
            %
            nt(itok,jdischarge) = input_dke_yp('  - Number of time subintervals between tmin and tmax (max = 100)',1,[1:100]);
            %
            if jdischarge > 1
                id{itok,jdischarge} = input_dke_yp('   - simulation id',id{itok,jdischarge-1});
            else
                id{itok,jdischarge} = input_dke_yp('   - simulation id','');
            end
            %
            enable(itok,jdischarge) = input_dke_yp('   - enable simulation [0 or 1]',1,[0,1]);
            %
            disp('------------------------------------------------------------------');
        end
        %
        disp('------------------------------------------------------------------');
        %
    end
    %
    % MACHINES (TOKAMAK)
    %
    for itok = 1:ntoks
        %
        for jdischarge = 1:ndischarges(itok)
            %
            if itok == 1 && jdischarge == 1
                %
                sparams.machine{1} = tokname{1};
                %
            else
                %
                sparams.machine = [sparams.machine,{tokname{itok}}];
                %
            end
        end
        %
    end
    %
    % DISCHARGES
    %
    for itok = 1:ntoks
        %
        for jdischarge = 1:ndischarges(itok)
            %
            if itok == 1 && jdischarge == 1
                %
                sparams.discharge.shot{1} = discharge{1,1};%shot number
                sparams.discharge.tmin{1} = tmin(1,1);
                sparams.discharge.tmax{1} = tmax(1,1);
                sparams.discharge.nt{1} = nt(1,1);
                %
            else
                %
                sparams.discharge.shot = [sparams.discharge.shot,{discharge{itok,jdischarge}}];
                sparams.discharge.tmin = [sparams.discharge.tmin,{tmin(itok,jdischarge)}];
                sparams.discharge.tmax = [sparams.discharge.tmax,{tmax(itok,jdischarge)}];
                sparams.discharge.nt = [sparams.discharge.nt,{nt(itok,jdischarge)}];
                %
            end
        end
        %
    end
    %
    % SIMULATIONS
    %
    for itok = 1:ntoks
        %
        for jdischarge = 1:ndischarges(itok)
            %
            if itok == 1 && jdischarge == 1
                %
                sparams.simul.id{1} = id{1,1};
                sparams.simul.enable{1} = enable(1,1);  
                %
            else
                %
                sparams.simul.id  = [sparams.simul.id ,{id{itok,jdischarge}}];
                sparams.simul.enable  = [sparams.simul.enable ,{enable(itok,jdischarge)}];
                %
            end
        end
        %
    end
    %
    % TOROIDAL MHD EQUILIBRIUM
    %
    for itok = 1:ntoks
        %
        for jdischarge = 1:ndischarges(itok)
            %
            ii = (itok-1)*ndischarges(itok)+jdischarge;
            %
            disp('------------------------------------------------------------------');
            disp([' - Equilibrium ',int2str(jdischarge),'/',int2str(ndischarges(itok)),' for tokamak ',tokname{itok}]);
            %
            if ii > 1
                %
                sparams.equil.id{ii} = input_dke_yp('   - id for the toroidal MHD equilibrium : ',sparams.equil.id{ii-1});%id for the toroial MHD equilibrium
                sparams.equil.comment{ii} = input_dke_yp('   - comment for the toroidal MHD equilibrium : ',sparams.equil.comment{ii-1});%comments on the toroidal MHD equilibrium 
                %  
                sparams.equil.source.method{ii} = input_dke_yp('   - source of the toroidal MHD equilibrium [code, file or value]',sparams.equil.source.method{ii-1},{'code','file','value'});%source of the toroidal MHD equilibrium : 'code', 'file', 'value'
                %
                if strcmp(sparams.equil.source.method{ii},'code')
                    %
                    sparams.equil.source.code{ii} = input_dke_yp('   - name of the code for calculating the toroidal MHD equilibrium [metis,helena,chease]',sparams.equil.source.code{ii-1},{'metis','helena','chease'});%code name for determining the excited power spectrum : 'aloha',... (used if source.method is 'code')
                    %
                elseif strcmp(sparams.equil.source.method{ii},'file')
                    %
                    sparams.equil.source.file{ii} = input_dke_yp('   - name of the file that contains the toroidal MHD equilibrium : ',sparams.equil.source.file{ii-1});%full path of the file that contains the power spectrum (used if source.method is 'file')
                    sparams.equil.source.path{ii} = input_dke_yp('   - full or loacal (.) path of the file that contains the toroidal MHD equilibrium : ',sparams.equil.source.file{ii-1});%full path of the file that contains the power spectrum (used if source.method is 'file')
                    %
                elseif strcmp(sparams.equil.source.method{ii},'value')
                    %
                    %TODO : implement manual equilibrium construction
                    %
                end
            else
                %
                sparams.equil.id{ii} = input_dke_yp('   - id for the toroidal MHD equilibrium : ','');%id for the toroial MHD equilibrium
                sparams.equil.comment{ii} = input_dke_yp('   - comment for the toroidal MHD equilibrium : ','');%comments on the toroidal MHD equilibrium 
                %  
                sparams.equil.source.method{ii} = input_dke_yp('   - source of the toroidal MHD equilibrium [code, file or value]','code',{'code','file','value'});%source of the toroidal MHD equilibrium : 'code', 'file', 'value'
                %
                if strcmp(sparams.equil.source.method{ii},'code')
                    %
                    sparams.equil.source.code{ii} = input_dke_yp('   - name of the code for calculating the toroidal MHD equilibrium [metis,helena,chease]','metis',{'metis','helena','chease'});%code name for determining the excited power spectrum : 'aloha',... (used if source.method is 'code')
                    %
                elseif strcmp(sparams.equil.source.method{ii},'file')
                    %
                    sparams.equil.source.file{ii} = input_dke_yp('   - name of the of the file that contains the toroidal MHD equilibrium : ','');%full path of the file that contains the power spectrum (used if source.method is 'file')
                    sparams.equil.source.path{ii} = input_dke_yp('   - full or loacal (.) path of the file that contains the toroidal MHD equilibrium : ','.');%full path of the file that contains the power spectrum (used if source.method is 'file')
                    %
                elseif strcmp(sparams.equil.source.method{ii},'value')
                    %
                    %TODO : implement manual equilibrium construction
                    %
                end                
            end
        end
    end
    %
    % OHMIC FIELD
    %
    ohmic_option = input_dke_yp('Do you want to consider Ohmic electric field ?',0,[0,1]);
    %
    if ohmic_option == 1
        %
        %
    end
    %
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
                        sparams.launch.antenna.lh.spectrum.aloha.remote_profile{ii} = input_dke_yp('   - remote profile number (use those corresponding to a scheduler : condor, slurm, pbs, torque, ...)');%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
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
    %
    % ANOMALOUS FAST ELECTRON TRANSPORT
    %
    transp_option = input_dke_yp('Do you want to consider anomalous radial transport ?',0,[0,1]);
    %
    if transp_option == 1
        %
        %
    end
    %
    % TOROIDAL MAGNETIC LOSSES
    %
    ripple_option = input_dke_yp('Do you want to consider toroidal magnetic ripple ?',0,[0,1]);
    %
    if ripple_option == 1
        %
        %
    end
    %
else
    if ~isstruct(varargin{1})
        %
        if strcmp(upper(varargin{1}),'TEST_ALOHA')
            %
            sparams.machine = {'TS','WEST','TS'};%machine name
            %
            sparams.simul.id = {'','',''};%customized simulation ID
            sparams.simul.enable = {1,1,1};%enable simulation (1) or not (0)
            %
            sparams.discharge.shot = {'27503','55539','28014'};%shot number
            sparams.discharge.tmin = {4.5,4.3,5.5};%time interval for data averaging (s)
            sparams.discharge.tmax = {5.0,4.4,6.5};%time interval for data averaging (s)
            sparams.discharge.nt = {4,1,2};%number of sub-interval times
            %
            % ---------------------------
            % LAUNCH structure (rf waves)
            % ---------------------------
            %
            sparams.launch.antenna.type = {'lh','lh','lh'};%(lh) lower hybrid wave or (ec) electron cyclotron waves, or 'lh+ec' if both waves are launched
            sparams.launch.antenna.comment = {'','',''};%comments on the launch structure calculation
            %
            % Lower hybrid wave (lh)
            %
            sparams.launch.antenna.lh.spectrum.source.method = {'code','code','code'};%source of the excited power spectrum : 'code', 'file', 'value'
            sparams.launch.antenna.lh.spectrum.source.code = {'aloha','aloha','aloha'};%code name for determining the excited power spectrum : 'aloha',... (used if source.method is 'code')
            sparams.launch.antenna.lh.spectrum.source.file = {'','',''};%full path of the file that contains the power spectrum (used if source.method is 'file')
            sparams.launch.antenna.lh.spectrum.id = {'ne_enforced_scan','ne_optim','ne_enforced'};%customized id for the calculation method of the excited power spectrum
            %
            % Lower hybrid wave power spectrum calculated by the ALOHA coupling code 
            %
            sparams.launch.antenna.lh.spectrum.aloha.remote_profile = {17,17,17};%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
            sparams.launch.antenna.lh.spectrum.aloha.display.data = {-1,-1,-1};%display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist
            sparams.launch.antenna.lh.spectrum.aloha.port = {'Q6A','Q6A','Q6A+Q6B'};%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
            sparams.launch.antenna.lh.spectrum.aloha.display.results = {1,1,1};%display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)
            sparams.launch.antenna.lh.spectrum.aloha.optim.method = {0,1,0};%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
            sparams.launch.antenna.lh.spectrum.aloha.optim.ne_guess = {2e17,[0.7e17,5.0e17],1e17};%Edge density in front of the grill (initial guess or enforced value) (m-3)
            sparams.launch.antenna.lh.spectrum.aloha.optim.tolfun = {'',1e-2,''};%Relative tolerance on targets (if aloha.optim.method = 1)
            sparams.launch.antenna.lh.spectrum.aloha.optim.tolx = {'',1e-2,''};%Relative tolerance on inputs (if aloha.optim.method = 1)
            sparams.launch.antenna.lh.spectrum.aloha.optim.nitmax = {'',10,''};%Maximum number of iterations (if aloha.optim.method = 1)
            %
            sparams.launch.antenna.lh.spectrum.aloha.param_tor.dir = {1,1,1};%build antenna directivity
            sparams.launch.antenna.lh.spectrum.aloha.aloha.param_tor.mode = {0,0,0};%toroidal power spectrum
            sparams.launch.antenna.lh.spectrum.aloha.aloha.param_tor.nlobes = {10,10,10};%number of lobes selected in the power spectrum
            sparams.launch.antenna.lh.spectrum.aloha.param_pol.ny = {0,0,0};
            sparams.launch.antenna.lh.spectrum.aloha.sdisplay.inter = {0,0,0};%interactive mode
            sparams.launch.antenna.lh.spectrum.aloha.opt_optim = {0,0,0};
            %
            % Initial parameters for building LAUNCH structures used by C3PO ray-tracing (here applied to all antennas)
            %
            sparams.launch.antenna.lh.phi0 = {0,0,0};
            sparams.launch.antenna.lh.LFS = {1,1,1};
            sparams.launch.antenna.lh.m0 = {0 + 1i,0 + 1i,0 + 1i};
            sparams.launch.antenna.lh.i_ref = {100,100,100};
            sparams.launch.antenna.lh.mmode = {-1,-1,-1};
            sparams.launch.antenna.lh.n0 = {NaN,NaN,NaN};
            sparams.launch.antenna.lh.kz0 = {NaN,NaN,NaN};
            sparams.launch.antenna.lh.ns = {1000,1000,1000};
            sparams.launch.antenna.lh.cocurrent = {1,1,1};%the Lower Hybrid wave drive co-current (1) or counter-current (-1)
            %
            sparams.launch.antenna.lh.method1 = {'pchip','pchip','pchip'};
            sparams.launch.antenna.lh.method2 = {'spline','spline','spline'};
            %
            % -------------
            % OHM structure 
            % -------------
            %
%             sparams.ohm.id = {'','',''};
%             sparams.ohm.comment = {'','',''};%comments on the ohm structure
%             
%             sparams.ohm.source.method = {'code','code','code'};%source of the Ohmic electric field : 'code', 'file', 'value'
%             sparams.ohm.source.code = {'metis','metis','metis'};%code name for determining Ohmic electric field : 'metis',... (used if source.method is 'code')
            sparams.ohm.source.file = {'','',''};%full path of the file that contains the Ohmic electric field (used if source.method is 'file')
            %
           
            %
            %sparams.ohm.vloop.value = {0,0,0};%Mean value of Vloop in the above time interval 
            %
                       %
            % ---------------
            % TRANSP structure  
            % ---------------
            %
%             sparams.transp.id = {'','',''};
%             sparams.transp.comment = {'','',''};%comments on the equil structure
%             %
%             sparams.transp.source.method = {'code','code','code'};%source of the anomalous radial transport : 'code', 'file', 'value'
%             sparams.transp.source.code = {'value','value','value'};%code name for determining of the anomalous radial transport : ... (used if source.method is 'code')
%             sparams.transp.source.file = {'','',''};%full path of the file that contains of the anomalous radial transport (used if source.method is 'file')
            %
            % ---------------
            % RIPPLE structure  
            % ---------------
            %
%             sparams.ripple.id = {'','',''};
%             sparams.ripple.comment = {'','',''};%comments on the equil structure
%             %
%             sparams.ripple.source.method = {'code','code','code'};%source of the toroidal magnetic ripple : 'code', 'file', 'value'
%             sparams.ripple.source.code = {'value','value','value'};%code name for determining of the toroidal magnetic ripple : ... (used if source.method is 'code')
%             sparams.ripple.source.file = {'','',''};%full path of the file that contains of the toroidal magnetic ripple (used if source.method is 'file')
%             %

            
        elseif strcmp(upper(varargin{1}),'LH_SIMPLE')
            %
%             sparams.machine = {'WEST'};%machine name
%             %
%             sparams.simul.id = {''};%customized simulation ID
%             sparams.simul.enable = {1};%enable simulation (1) or not (0)
%             %
%             sparams.discharge.shot = {'TScyl'};%shot number (Tore Supra or WEST)
%             sparams.discharge.tmin = {0};%time interval for data averaging (s)
%             sparams.discharge.tmax = {0};%time interval for data averaging (s)
%             %
%             % LAUNCH structure for the rf waves
%             %
%             sparams.launch.antenna.type = {'lh'};%(lh) lower hybrid wave or (ec) electron cyclotron waves, or 'lh+ec' if both waves are launched
%             sparams.launch.antenna.comment = {''};%comments on the launch structure calculation
%             %
%             % Lower hybrid wave (lh)
%             %   
%             sparams.launch.antenna.lh.spectrum.source.method = {'value'};%source of the excited power spectrum : 'code', 'file', 'value'
%             sparams.launch.antenna.lh.spectrum.source.code = {''};%code name for determining the excited power spectrum : 'aloha',... (used if source.method is 'code')
%             sparams.launch.antenna.lh.spectrum.source.file = {''};%full path of the file that contains the power spectrum (used if source.method is 'file')
%             sparams.launch.antenna.lh.spectrum.id = {'LH_Karney'};%customized id for the calculation method of the excited power spectrum
%             %
%             sparams.launch.antenna.lh.spectrum.value.bNpar0 = {[],[],[],[-1.9176 6]};
%             sparams.launch.antenna.lh.spectrum.value.bPlhtot = {[],[],[],[700000 3.0000e+05]};%Watts
%             sparams.launch.antenna.lh.spectrum.value.bdNpar0 = {[],[],[],[0.2000 0.2000]};
%             sparams.launch.antenna.lh.spectrum.value.rZ0 = [0];%Vertical position of the modules
%             sparams.launch.antenna.lh.spectrum.value.rf_frequency = [3.7e9];%Hz
%             %
%             sparams.launch.antenna.lh.phi0 = 0;
%             sparams.launch.antenna.lh.LFS = 1;
%             sparams.launch.antenna.lh.m0 = 0 + 1i;
%             sparams.launch.antenna.lh.i_ref = 100;
%             sparams.launch.antenna.lh.mmode = -1;
%             sparams.launch.antenna.lh.n0 = NaN;
%             sparams.launch.antenna.lh.kz0 = NaN;
%             sparams.launch.antenna.lh.ns = 1000;
%             %
%             sparams.launch.antenna.lh.method1 = 'pchip';
%             sparams.launch.antenna.lh.method2 = 'spline';
            %
        elseif strcmp(upper(varargin{1}),'LH_TAIL')
            %
%             sparams.machine = {'WEST'};%machine name
%             %
%             sparams.simul.id = {''};%customized simulation ID
%             sparams.simul.enable = {1};%enable simulation (1) or not (0)
%             %
%             sparams.discharge.shot = {'55539'};%shot number (Tore Supra or WEST)
%             sparams.discharge.tmin = {4.3,4.3};%time interval for data averaging (s)
%             sparams.discharge.tmax = {4.4,4.4};%time interval for data averaging (s)
%             %
%             % LAUNCH structure for the rf waves
%             %
%             sparams.launch.antenna.type = {'lh','lh',};%(lh) lower hybrid wave or (ec) electron cyclotron waves, or 'lh+ec' if both waves are launched
%             %
%             % Lower hybrid wave (lh)
%             %
%             sparams.launch.antenna.lh.spectrum.method = {'aloha','aloha','aloha'};%calculation method of the excited power spectrum : aloha or manual (see launch substructure directly)
%             sparams.launch.antenna.lh.spectrum.id = {'ne_enforced_scan','ne_optim','ne_enforced'};%customized id for the calculation method of the excited power spectrum
%             %
%             % Lower hybrid wave power spectrum calculated by the ALOHA coupling code 
%             %
%             sparams.launch.antenna.lh.spectrum.aloha.display.data = {1,1,1};%display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)
%             sparams.launch.antenna.lh.spectrum.aloha.port = {'Q6A','Q6A','Q6A+Q6B'};%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
%             sparams.launch.antenna.lh.spectrum.aloha.remote_profile = {17,17,17};%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
%             sparams.launch.antenna.lh.spectrum.aloha.display.results = {1,1,1};%display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)
%             sparams.launch.antenna.lh.spectrum.aloha.optim.method = {0,1,0};%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
%             sparams.launch.antenna.lh.spectrum.aloha.optim.ne_guess = {2e17,[0.7e17,5.0e17],1e17};%Edge density in front of the grill (initial guess or enforced value) (m-3)
%             sparams.launch.antenna.lh.spectrum.aloha.optim.tolfun = {[],1e-2,[]};%Relative tolerance on targets (if aloha.optim.method = 1)
%             sparams.launch.antenna.lh.spectrum.aloha.optim.tolx = {[],1e-2,[]};%Relative tolerance on inputs (if aloha.optim.method = 1)
%             sparams.launch.antenna.lh.spectrum.aloha.optim.nitmax = {[],10,[]};%Maximum number of iterations (if aloha.optim.method = 1)
%             %

% params.launch.tail.dtn = Inf;
% params.launch.tail.mode = 3;
% params.launch.tail.bNparmax_tail = 0;
% params.launch.tail.bn_tail = 0;
% params.launch.tail.bP_tail = 0.5000;
% params.launch.tail.bopt_tail = 0.0000 + 1.0000i;
        elseif strcmp(upper(varargin{1}),'LH_TIME')   
            
            
        elseif strcmp(lower(varargin{1}),'help') || strcmp(lower(varargin{1}),'h') 
            %
            disp('---------------------------------------------------------------------------------------------')
            disp('---------------------------------- HELP SPARAMS_GENERATOR -----------------------------------')
            disp('---------------------------------------------------------------------------------------------')
            disp('The function ''sluke_sparams_generator'' helps the user to build a structure ''sparams'' for ')
            disp('running the ''sluke'' code. This structure contains all parameters for full or partial sluke')
            disp('simulations. It is recommended to read the script ''sluke_sparams_generator.m'' before ')
            disp('using it.')
            disp(' ')
            disp('Various calls :')
            disp(' ')
            disp('sparams = sluke_params_generator; --> interactive mode to build a new sparams structure.')
            disp(' ')
            disp('sparams = sluke_params_generator(''h''); or sparams = sluke_params_generator(''help'') --> ')
            disp('help mode only. The sparams structure is empty.')
            disp(' ')
            disp('sparams = sluke_params_generator(''PRESET''); --> default preset sparams where ''PRESET'' may')
            disp('be : ')
            disp(' - ''ALOHA_TEST'' : test case to build LAUNCH structures using ALOHA coupling code. ')
            disp(' ')
            disp('sparams = sluke_params_generator(sparams); --> interactive mode to build a modified sparams');
            disp('structure.');
            disp(' ')
            disp('NOTE : The sparams structures may be build by a dedicated and customized script.')
            disp('---------------------------------------------------------------------------------------------')
            disp('---------------------------------------------------------------------------------------------')
            disp('---------------------------------------------------------------------------------------------')
            %
        else
            %
            disp(['WARNING : ',varargin{1},' is not a recognized preset. ''sparams'' structure is empty.']);
            %
        end
        %
    else
        %
            
        %
    end
end
%
fns = fieldnamesr(sparams);
%
if ~isempty(find(contains(fns,'machine')))
    %
    sparams.help.machine = 'Name of tokamaks';
    sparams.format.machine = 'string';
    %
end
%
if ~isempty(find(contains(fns,'discharge')))
    %
    sparams.help.discharge.shot = 'Discharge index';
    sparams.help.discharge.tmin = 'Minimum of the considered time interval (s)';
    sparams.help.discharge.tmax = 'Maximum of the considered time interval (s)';
    sparams.help.discharge.nt = 'Number of sub-intervals between tmin and tmax (n>=1). If none, n = 1 is considered in the calculations. Use sluke_params_time to expand the params structure.';
    %
    sparams.help.simul.id = 'Customized identification of the parameters';
    sparams.help.simul.enable = 'Enable (1) or not (0) the simulations';
    %
    sparams.help.equil.id = '';
    %
    sparams.help.launch.id = '';
    %
    sparams.help.transp.id = '';
    %
    sparams.help.ripple.id = '';
    %
    sparams.format.discharge.shot = 'string';
    sparams.format.discharge.tmin = 'float';
    sparams.format.discharge.tmax = 'float';
    sparams.format.discharge.nt = 'integer';
    %
    sparams.format.simul.id = 'string';
    sparams.format.simul.enable = 'boolean';
    %
    sparams.format.equil.id = 'string';
    %
    sparams.format.launch.id = 'string';
    %
    sparams.format.transp.id = 'string';
    %
    sparams.format.ripple.id = 'string';

    %
end
        

        
        