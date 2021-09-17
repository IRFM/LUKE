function sparams = sluke_params_preset(preset_name)
%
%
% LUKE - Generator of parameters structure for sluke calculations from preset name. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - preset_name : nae of the preset (string)
%
% OUTPUT :
%
%   - sparams : structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
sparams = struct;
%
if nargin == 0
    %
    error('Wrong number of input arguments in sluke_params_preset.')
    %
elseif nargin == 1
	%
	if strcmp(upper(preset_name),'TEST_ALOHA') % see Project_FKE/Modules/ALOHA/test_run_aloha_remote
        %
        sparams.machine = {'TS','WEST','TS'};%machine name
        %
        sparams.simul.id = {'','',''};%customized simulation ID
        sparams.simul.enable = {0,1,0};%enable simulation (1) or not (0)
        %
        sparams.discharge.shot = {'27503','55539','28014'};%shot number
        sparams.discharge.tmin = {4.5,4.3,5.5};%time interval for data averaging (s)
        sparams.discharge.tmax = {5.0,4.4,6.5};%time interval for data averaging (s)
        sparams.discharge.nt = {1,1,1};%number of sub-interval times
        %
        % ---------------------------
        % RF waves
        % ---------------------------
        %
        sparams.rfwaves.antenna.type = {{'LH'},{'LH'},{'LH','LH'}};%'LH' lower hybrid wave or 'EC' electron cyclotron waves, or ['LH';'EC'] if both waves are launched
        sparams.rfwaves.antenna.id = {{'ne_enforced'},{'ne_optim'},{'ne_enforced','ne_enforced'}};%LH wave
        sparams.rfwaves.antenna.comment = {{''},{''},{'',''}};%comments on the launch structure calculation
        sparams.rfwaves.antenna.source = {{'code'},{'code'},{'code','code'}};%source of the excited power spectrum : 'code', 'file', 'value'
        sparams.rfwaves.antenna.code = {{'ALOHA'},{'ALOHA'},{'ALOHA','ALOHA'}};%code name for determining the excited power spectrum : 'aloha',... (used if source.method is 'code')
        sparams.rfwaves.antenna.file = {{''},{''},{'',''}};%full path of the file that contains the power spectrum (used if source.method is 'file')
        sparams.rfwaves.antenna.path = {{''},{''},{'',''}};%customized id for the calculation method of the excited power spectrum
        %
        % Lower hybrid wave power spectrum calculated by the ALOHA coupling code 
        %
        sparams.rfwaves.antenna.LH.ALOHA.port = {{'Q6A'},{'Q6A'},{'Q6A','Q6B'}};%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
        sparams.rfwaves.antenna.LH.ALOHA.remote_profile = {{17},{17},{17,17}};%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
        sparams.rfwaves.antenna.LH.ALOHA.display.data = {{-1},{-1},{-1,-1}};%display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist
        sparams.rfwaves.antenna.LH.ALOHA.display.results = {{1},{1},{1,1}};%display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)
        sparams.rfwaves.antenna.LH.ALOHA.optim.method = {{0},{0},{1,1}};%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
        sparams.rfwaves.antenna.LH.ALOHA.optim.ne_guess = {{1e17},{1e17},{[0.7e17,5.0e17],[0.7e17,5.0e17]}};%Edge density in front of the grill (initial guess or enforced value) (m-3)
        sparams.rfwaves.antenna.LH.ALOHA.optim.tolfun = {{1e-2},{1e-2},{1e-2,1e-2}};%Relative tolerance on targets (if aloha.optim.method = 1)
        sparams.rfwaves.antenna.LH.ALOHA.optim.tolx = {{1e-2},{1e-2},{1e-2,1e-2}};%Relative tolerance on inputs (if aloha.optim.method = 1)
        sparams.rfwaves.antenna.LH.ALOHA.optim.nitmax = {{10},{10},{10,10}};%Maximum number of iterations (if aloha.optim.method = 1)
        %
        sparams.rfwaves.antenna.LH.ALOHA.spectrum.param_tor.dir = {{1},{1},{1,1}};%build antenna directivity
        sparams.rfwaves.antenna.LH.ALOHA.spectrum.aloha.param_tor.mode = {{0},{0},{0,0}};%toroidal power spectrum
        sparams.rfwaves.antenna.LH.ALOHA.spectrum.aloha.param_tor.nlobes = {{10},{10},{10,10}};%number of lobes selected in the power spectrum
        %sparams.rfwaves.antenna.LH.ALOHA.spectrum.param_pol.ny = {{0},{0},{0,0}};
        sparams.rfwaves.antenna.LH.ALOHA.spectrum.param_pol.Pin_in = {{NaN},{NaN},{NaN,NaN}}; %corrected initial total power (NaN to read Pin from aloha, 1 for normalized output)
        sparams.rfwaves.antenna.LH.ALOHA.spectrum.sdisplay.inter = {{0},{0},{0,0}};%interactive mode for selecting parameters
        sparams.rfwaves.antenna.LH.ALOHA.spectrum.sdisplay.mode = {{0},{0},{0,0}};%display (0) none (1) text only (2) text and figures (default : 0)
        sparams.rfwaves.antenna.LH.ALOHA.spectrum.opt_optim = {{0},{0},{0,0}};%upper and lower half-antenna modules are considered independently (0) or only half upper module for the whole antenna (1). If sparams.rfwaves.antenna.LH.ALOHA.optim.method == 0, sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum = 1 is enforced.
        sparams.rfwaves.antenna.LH.ALOHA.spectrum.globalspectrum = {{0},{0},{0,0}};%upper and lower half-antenna modules are considered independently (0) or only half upper module for the whole antenna (1). If sparams.rfwaves.antenna.LH.ALOHA.optim.method == 0, sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum = 1 is enforced.
        sparams.rfwaves.antenna.LH.ALOHA.spectrum.cocurrent = {{1},{1},{1,1}};%the Lower Hybrid wave drive co-current (1) or counter-current (-1)
        %
        sparams.rfwaves.antenna.LH.phi0 = {{0},{0},{0,0}};
        sparams.rfwaves.antenna.LH.LFS = {{1},{1},{1,1}};
        sparams.rfwaves.antenna.LH.m0 = {{0 + 1i},{0 + 1i},{0 + 1i,0 + 1i}};
        sparams.rfwaves.antenna.LH.i_ref = {{-1},{-1},{-1,-1}};
        sparams.rfwaves.antenna.LH.mmode = {{-1},{-1},{-1,-1}};
        sparams.rfwaves.antenna.LH.n0 = {{NaN},{NaN},{NaN,NaN}};
        sparams.rfwaves.antenna.LH.kz0 = {{NaN},{NaN},{NaN,NaN}};
        sparams.rfwaves.antenna.LH.ns = {{1000},{1000},{1000,1000}};
        sparams.rfwaves.antenna.LH.method1 = {{'pchip'},{'pchip'},{'pchip','pchip'}};
        sparams.rfwaves.antenna.LH.method2 = {{'spline'},{'spline'},{'spline','spline'}};
        %
        % -------------
        % Ohmic electric field
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

            
	elseif strcmp(upper(preset_name),'LH_SIMPLE')
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
%             sparams.launch.antenna.LH.spectrum.source.method = {'value'};%source of the excited power spectrum : 'code', 'file', 'value'
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
	elseif strcmp(upper(preset_name),'LH_TAIL')
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
	elseif strcmp(upper(preset_name),'LH_TIME')   
        %
        disp('------------------------------------------------------------------');
        %
    else
        %
        disp('WARNING : unkown preset name')
        %
    end
    %
end