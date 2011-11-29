function [varargout] = run_lukert(simul,wavestructs,waves,psin_S,rho_S,dkepath,equil,dkeparam_in,dkedisplay_in,ohm,transpfaste,ripple,XXf0,XXsinksource_in,opt_save_in)
%
% Wave and kinetic solver. Self-consistent calculations with or without plasma fluctuations
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));%reset rand with clock (never same state)
%
if nargin < 15,
   opt_save_in = 1;%In case of crash, to restart simulation from an intermediate step stored in a *.mat file (<0 for launching simulation from backup, 0 no backup, >0 for performing backup)
end
%
if ~isstruct(simul),
    simul.id = simul;
    simul.path = './';
end
if ~exist(simul.path,'dir'), 
    mkdir(simul.path);
end
if ~exist([simul.path,'wave_results'],'dir'), 
    mkdir([simul.path,'wave_results']);
end
%
if opt_save_in <0 && ~exist([simul.path,'backup_',simul.id,'.mat'],'file'),
    opt_save_in = 1;
end
%
disp(simul.id);
%
itnmin = 1;
wavetype = 0;
Pnonabs_ray = [];
%
for iw = 1:length(waves),
    if strcmp(waves{iw}.equil_id,equil.id) == 0,
        error('The wave structure was build with an inconsistent equilibrium')
    end
end   
%
f0struct = [];%Ray absorption in C3PO is first calculated with a thermal electron distribution function
%
if isempty(psin_S) && isempty(rho_S),
    dkeparam_in.rt_mode = 0;%Only ray-tracing is done, with or without plasma fluctuations. rt_mode is enforced
    disp('WARNING: dkeparam.rt_mode = 0 has been enforced, since both psin_S and rho_S are empty.');
end
%    
if ~isfield(dkeparam_in,'tn') || (isempty(psin_S) && isempty(rho_S)),
    dkeparam_in.tn = NaN;
    disp('WARNING: dkeparam.tn = NaN has been set, since tn field is not existing in dkeparam structure.');
end
%
if ~isfield(equil,'fluct'),
    equil.fluct = struct;%empty structure
end
%
if ~isfield(dkeparam_in,'Nfluct'),
    dkeparam_in.Nfluct = 1;%ratio of LUKE to fluctuation times
end
%
% fluctuation iteration management
%
flag_LH = 0;%check that LH wave is in one of the wavestruct
%
for iw = 1:length(wavestructs),
    if strcmp(wavestructs{iw}.launch.type,'LH'),
        flag_LH = 1;
    end
end    
%
if flag_LH == 0 && isfield(equil.fluct,'edge'),
    disp('Edge fluctuation model for LH waves only; dismissed.')
    equil.fluct = rmfield(equil.fluct,'edge');
end
%
equil.fluct.dtn_fluct = calc_dtn_fluct_jd(equil.fluct,buildlukestruct_yp('mksa',psin_S,rho_S,equil,dkeparam_in,dkedisplay_in));% maximum fluctuation time
%
dtn_phase = dkeparam_in.Nfluct*equil.fluct.dtn_fluct;%time for phase renewal
%
if isscalar(dkeparam_in.tn) && imag(dkeparam_in.tn) > 0,% the number of fluctuation iterations is specified by imag(tn)
    itnmax = imag(dkeparam_in.tn);
    tn_in = itnmax*dtn_phase;%final time
elseif isscalar(dkeparam_in.tn) && ~isnan(dkeparam_in.tn),% the number of fluctuation iterations is specified by tn and Nfluct*dtn_fluct
    itnmax = max(1,ceil(dkeparam_in.tn/dtn_phase));
    tn_in = dkeparam_in.tn;
else% no fluctuation iterations
    itnmax = 1;
    tn_in = dkeparam_in.tn;
end
%
dkeparam_in = rmfield(dkeparam_in,'tn');%tn is specified in ieration loop
%
if opt_save_in >= 0;
    %
    dkeparam = dkeparam_in;
    dkedisplay = dkedisplay_in;
    opt_save = opt_save_in;
    tn = tn_in;
    %
    if ~isinf(equil.fluct.dtn_fluct),
        xJ = [];
        xP = [];
        Itot = [];
        Ptot = [];
    end
    %
    loadstructs = [];%Structure that pass parameters for recursive calculations between wave and kinetic solvers 
    %
    % Calculate vectorial axisymmetric magnetic equilibrium and eventually plasmas fluctuations (if substructure 'fluct' exists
    %
    if ~isinf(equil.fluct.dtn_fluct),
        equil.fluct = fluctphase_yp(equil.fluct);
    end
    %
    if ~isempty(wavestructs),
        for iws = 1:length(wavestructs),
            [wavestructs{iws}.equil] = equil;
            if isfield(wavestructs{iws},'fitparam'),
                [wavestructs{iws}.equil_fit] = fitequil_yp(equil,wavestructs{iws}.fitparam.mode_equil,wavestructs{iws}.fitparam.method,wavestructs{iws}.fitparam.ngridresample,wavestructs{iws}.fitparam.nharm);
            else
                [wavestructs{iws}.equil_fit] = fitequil_yp(equil,wavestructs{iws}.fitequilparam.mode_equil,wavestructs{iws}.fitequilparam.method,wavestructs{iws}.fitequilparam.ngridresample,wavestructs{iws}.fitequilparam.nharm);%backward compatibility         
            end  
            %
            if ~isinf(equil.fluct.dtn_fluct),
                if isfield(wavestructs{iws},'fitparam'),
                    [wavestructs{iws}.equil_fit.fluct_fit] = fitfluct_yp(equil.fluct,wavestructs{iws}.fitparam.mode_equil,equil.fluct.fitparam.method,equil.fluct.fitparam.ngridresample,equil.fluct.fitparam.nharm);
                else
                    if isfield(equil.fluct,'fitparam'),
                        [wavestructs{iws}.equil_fit.fluct_fit] = fitfluct_yp(equil.fluct,wavestructs{iws}.fitequilparam.mode_equil,equil.fluct.fitparam.method,equil.fluct.fitparam.ngridresample,equil.fluct.fitparam.nharm);
                    else
                        [wavestructs{iws}.equil_fit.fluct_fit] = fitfluct_yp(equil.fluct);                        
                    end
                end
            end     
        end
    end
else
    %
    disp('------------------ RE-LOAD MODE ------------------');
    %
    load([simul.path,'backup_',simul.id,'.mat']);
    %
    if opt_save_in == -1,%interactive update
        %
        overwrite_dkeparam_field = input_dke_yp('If you want to overwrite one field of the reloaded ''dkeparam'' structure, give its name ?');
        overwrite_dkedisplay_field = input_dke_yp('If you want to overwrite one field of the reloaded ''dkedisplay'' structure, give its name ?');
        %
        if ~isempty(overwrite_dkeparam_field),
            if isfield(dkeparam,overwrite_dkeparam_field),
                dkeparam.(overwrite_dkeparam_field) = dkeparam_in.(overwrite_dkeparam_field);
            else
                disp(['The fieldname ''',overwrite_dkeparam_field, ''' does not exist in the structure ''dkeparam''. Nothing has been overwritten.'])    
            end
        end
        %
        if ~isempty(overwrite_dkedisplay_field),
            if isfield(dkedisplay,overwrite_dkedisplay_field),
                dkedisplay.(overwrite_dkedisplay_field) = dkedisplay_in.(overwrite_dkedisplay_field);
            else
                disp(['The fieldname ''',overwrite_dkedisplay_field, ''' does not exist in the structure ''dkedisplay''. Nothing has been overwritten.'])
            end
        end
        %
    elseif opt_save_in == -2,%non interactive update
        dkedisplay.display_mode = dkedisplay_in.display_mode;
        if ~isfield(dkedisplay_in,'display_time_mode');
            dkedisplay.display_time_mode = 0;
        else
            dkedisplay.display_time_mode = dkedisplay_in.display_time_mode;
        end
    end
    %
    if itn == itnmax,
        disp(['The maximum number of iterations ',int2str(itnmax),' has already been reached.']);
    else
        disp(['The number of iterations already done is ',int2str(itn),'/',int2str(itnmax),'.']);
    end
    %
    if opt_save_in == -1 && tn < tn_in,
        overwrite_tn = input_dke_yp(['Do you want to overwrite the total simulation time from ',int2str(tn),' to ',int2str(tn_in),' (y/n) ?'],'n',{'y','n'});
        %
        if overwrite_tn == 'y',
            %
            disp(['- Old tn = ',int2str(tn)]);
            disp(['- New tn = ',int2str(tn_in)]);
            tn = tn_in;
            itnmax = max([1,ceil(tn/dtn_phase)]);
        end
        %
    end
    %
    disp('---------------------------------')
    disp('Iteration status')
    disp('---------------------------------')
    disp([' - tn = ',int2str(tn)])
    disp([' - number of iterations to be done = ',int2str(itnmax - itn)])
    %
    if itn ~= itnmax,
        opt_save = 1;
        itnmin = itn + 1;%restart from the saved iteration
    else
        itnmin = itnmax + 1;%no iteration
    end
end
%
if ~exist('wavestructs_fluct','var'),
    wavestructs_fluct = [];
end
%
for itn = itnmin:itnmax,%time evolution
    %
    if itn < itnmax,
        dkeparam.tn = dtn_phase;% fluctuations, one step
    elseif isscalar(tn) && ~isinf(dtn_phase),%fluctuations, last time step
        dkeparam.tn = tn - dtn_phase*(itnmax - 1);
    else% no fluctutions
        dkeparam.tn = tn;
    end
    %
    %
    % RF wave propagation solver
    %
    if ~isempty(wavestructs), 
        [waves,wavestructs,wavestructs_fluct] = wave_distribution_yp(dkepath,dkeparam,wavestructs,wavestructs_fluct,f0struct,buildlukestruct_yp('mksa',psin_S,rho_S,equil,dkeparam,dkedisplay),itn,Pnonabs_ray);%ray propagation in fluctuating plasma. The fluctuation phase in wavestructs is output to be later re-used by the same function taling into account of the phase evolution
    end
    %
    % RF wave absorption solver (drift kinetic calculations)
    %
    if itn > 1,        
        XXf0 = XXf0_t{itn-1};%internal time evolution. The previous time is the input for the next one
    end
    %
    if isempty(loadstructs),
        [Znorm,Zcurr,ZP0,dke_out,loadstructs.radialDKE,loadstructs.equilDKE,loadstructs.momentumDKE,loadstructs.gridDKE,loadstructs.Zmomcoef,loadstructs.Zbouncecoef,loadstructs.Zmripple,loadstructs.mksa,loadstructs.XXsinksource,loadstructs.loopDKE] = loop_run_lukert(simul,waves,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,XXf0,XXsinksource_in,loadstructs);
    else
        [Znorm,Zcurr,ZP0,dke_out] = loop_run_lukert(simul,waves,psin_S,loadstructs.radialDKE.xrho_S_dke,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,XXf0,XXsinksource_in,loadstructs);   
    end
    %
    Ptot_inj = 0;
    %    
    for iw = 1:length(wavestructs),
        if isfield(wavestructs{iw}.launch,'bPlhtot'),
            Ptot_inj = Ptot_inj + sum(wavestructs{iw}.launch.bPlhtot)/1e6;%LH power injected (MW)
        elseif isfield(wavestructs{iw}.launch,'yP_L'),
            Ptot_inj = Ptot_inj + sum(wavestructs{iw}.launch.yP_L)/1e6;%EC power injected (MW)
        end
    end
    %
    if isfield(dke_out,'zP_0_2piRp_mod');
        for iout = 1:length(dke_out.zP_0_2piRp_mod{end}),
            Pnonabs_ray(iout) = dke_out.zP_0_2piRp_mod{end}{iout}(end);%Linear power density not absorbed P/(2*pi*Rp)
        end
    end
    %
    if itnmax > 1,
        %
        xrho = loadstructs.equilDKE.xrho(:);
        xdA = loadstructs.equilDKE.xdA_dke(:)';
        if isfield(loadstructs.equilDKE,'xdV_dke'),
            xdV = loadstructs.equilDKE.xdV_dke(:)';
        else
            xdV = loadstructs.equilDKE.xdV_2piRp_dke(:)'*2*pi*loadstructs.equilDKE.Rp;
        end
        %
        xtn(itn,:) = min([dtn_phase*itn,tn]);
        %
        xJ(itn,:) = Zcurr.x_0_fsav*loadstructs.mksa.j_ref;
        xP(itn,:) = ZP0.x_rf_fsav'*loadstructs.mksa.P_ref;
        %
        Itot(itn) = sum(xJ(itn,:).*xdA,2);
        Ptot(itn) = sum(xP(itn,:).*xdV,2);
        %
        if ~isfield(dkedisplay,'display_time_mode'), dkedisplay.display_time_mode = 0;end
        %
        if dkedisplay.display_time_mode >= 1,
            %
            figure(figbyname_yp(['Jrf(r,t) / ',simul.id])),
            %
            if itn > 2,
                graph1D_jd(xrho,xJ([1:end-2],:),0,0,'\rho','J_{tot} (MA/m^2)',['Iteration = ',int2str(itn),'/',int2str(itnmax),', I_{tot} = ',num2str(Itot(itn)),' (MA)'],NaN,'','','-','none','g',1);
            end
            %
            if itn > 1,
                graph1D_jd(xrho,xJ(end-1,:),0,0,'\rho','J_{tot} (MA/m^2)',['Iteration = ',int2str(itn),'/',int2str(itnmax),', I_{tot} = ',num2str(Itot(itn)),' (MA)'],NaN,'','','-','none','b',1);            
            end
            %
            graph1D_jd(xrho,xJ(end,:),0,0,'\rho','J_{tot} (MA/m^2)',['I_{tot} = ',num2str(Itot(itn)),' (MA)'],NaN,'','','-','none','r',2);
            %
            figure(figbyname_yp(['Prf(r,t) / ',simul.id])),
            %
            if itn > 2,
                graph1D_jd(xrho,xP([1:end-2],:),0,0,'\rho','P_{abs} (MW/m^3)',['Iteration = ',int2str(itn),'/',int2str(itnmax),', P_{abs} = ',num2str(Ptot(itn)),' (MW)'],NaN,'','','-','none','g',1);
            end
            %
            if itn > 1,
                graph1D_jd(xrho,xP(end-1,:),0,0,'\rho','P_{abs} (MW/m^3)',['Iteration = ',int2str(itn),'/',int2str(itnmax),', P_{abs} = ',num2str(Ptot(itn)),' (MW)'],NaN,'','','-','none','b',1); 
            end
            %
            graph1D_jd(xrho,xP(end,:),0,0,'\rho','P_{abs} (MW/m^3)',['P_{abs} = ',num2str(Ptot(itn)),' (MW)'],NaN,'','','-','none','r',2);
            %
            figure(figbyname_yp(['Irf(t) / ',simul.id])),
            %
            graph1D_jd([1:itn]*dtn_phase,Itot,0,0,'t*\nu','I_{tot} (MA)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'','','none','.','c',2);  
            graph1D_jd([1:itn]*dtn_phase,Itot,0,0,'t*\nu','I_{tot} (MA)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'','','-','none','c',2);  
            %
            figure(figbyname_yp(['Prf(t) / ',simul.id])),
            %
            graph1D_jd([1:itn]*dtn_phase,Ptot,0,0,'t*\nu','P_{tot} (MW)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'',[0,Ptot_inj*2],'none','.','k',2);drawnow
            graph1D_jd([1:itn]*dtn_phase,Ptot,0,0,'t*\nu','P_{tot} (MW)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'',[0,Ptot_inj*2],'-','none','k',2);drawnow
            graph1D_jd([1:itn]*dtn_phase,Ptot_inj*ones(1,itn),0,0,'t*\nu','P_{tot} (MW)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'',[0,Ptot_inj*2],'--','none','k',1);drawnow
        else
            disp(' ');
            disp('------------------------------------------------------------------------------------');
            disp(['Simulation ',simul.id]);
            disp(['Iteration #',int2str(itn),': Pref = ',num2str(Ptot_inj),' (MW) - Ptot = ',num2str(Ptot(itn)),' (MW) - Itot = ',num2str(Itot(itn)),' (MA)']);
            disp('------------------------------------------------------------------------------------');
            disp(' ');
        end
        %
        % Feedback kinetic calculations for calculating the wave absorption with a non-Mawellian electron distribution in the propagation solver 
        %
        f0struct = build_f0struct_yp(dke_out,loadstructs.momentumDKE,loadstructs.equilDKE,loadstructs.mksa);%For absorption in C3PO with a non-Maxwellian electron distribution    
    end
    %
    XXf0_t{itn} = dke_out.XXf0;%for saving the time evolution of the electron velocity distribution function
    %
    % Display ray dynamics on the FP radial grid
    %
    for iws = 1:length(wavestructs),
        if isfield(wavestructs{iws}.launch,'yP_L'); 
            wavetype = wavetype + 1;
        end
    end
    %
    %
	if itnmax > 1,
   		Zcurr.xtn = xtn;
   		Zcurr.t_x_0_fsav = xJ/loadstructs.mksa.j_ref;
    	ZP0.t_x_rf_fsav = xP/loadstructs.mksa.P_ref;
    else
        Zcurr.xtn = tn;
    	Zcurr.t_x_0_fsav = Zcurr.x_0_fsav;
    	ZP0.t_x_rf_fsav = ZP0.x_rf_fsav;
	end
	%
    if itnmax > 1 && opt_save > 0,
        wavetype = wavetype/length(wavestructs);
        %
        if isfield(dkedisplay,'display_time_mode'),
            if dkedisplay.display_time_mode >= 2,
                rayevolution_yp(wavetype,wavestructs{1}.equil_fit,waves,0,loadstructs.radialDKE.xrho_S_dke,itn);
            end
        end
        %
        eval(['save ',simul.path,'wave_results/waves_',simul.id,'_',int2str(itn),'.mat wavetype waves wavestructs rho_S itn']);
        %
        wavetype = 0;
        %
        %Emergency backup of each iteration
        %
        save_str = [simul.path,'backup_',simul.id,'.mat'];
        if isfield(dke_out,'waves'),
            waves = dke_out.waves;
        else
            waves = '';
        end
        %
        eval(['save ',save_str,' tn itn itnmax xrho xJ xP Itot Ptot Pnonabs_ray wavestructs wavestructs_fluct waves f0struct XXf0_t loadstructs simul psin_S dkepath equil dkeparam dkedisplay ohm transpfaste ripple XXsinksource_in opt_save Znorm Zcurr ZP0']);
        disp('--------------------------------------------------------------------------------------------------');
        info_dke_yp(2,['Backup of iteration ',int2str(itn),'/',int2str(itnmax),' done in file ''',save_str,'''.']);
        disp('--------------------------------------------------------------------------------------------------');
        clear waves
    end
end
%
dke_out.dkeparam = dkeparam;%for data transfer only
%
if ~isempty(loadstructs),
    if nargout >= 1,varargout{1} = Znorm;end
    if nargout >= 2,varargout{2} = Zcurr;end
    if nargout >= 3,varargout{3} = ZP0;end
    if nargout >= 4,varargout{4} = dke_out;end
    if nargout >= 5,varargout{5} = loadstructs.radialDKE;end
    %
    if isfield(equil,'fluct'),
        loadstructs.equilDKE.fluct = equil.fluct;%for transfering info about plasma fluctuations
    end
    if nargout >= 6,varargout{6} = loadstructs.equilDKE;end
    %
    if nargout >= 7,varargout{7} = loadstructs.momentumDKE;end
    if nargout >= 8,varargout{8} = loadstructs.gridDKE;end
    if nargout >= 9,varargout{9} = loadstructs.Zmomcoef;end
    if nargout >= 10,varargout{10} = loadstructs.Zbouncecoef;end
    if nargout >= 11,varargout{11} = loadstructs.Zmripple;end
    if nargout >= 12,varargout{12} = loadstructs.mksa;end
    if nargout >= 13,varargout{13} = loadstructs.XXsinksource;end
  %  if nargout >= 14,varargout{14} = loadstructs.dke_warnings;end
else
    if nargout >= 1,varargout{1} = Znorm;end
    if nargout >= 2,varargout{2} = Zcurr;end
    if nargout >= 3,varargout{3} = ZP0;end
    if nargout >= 4,varargout{4} = dke_out;end    
end

