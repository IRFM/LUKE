function [varargout] = run_lukert(id_simul,wavestructs,waves,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,XXf0_in,XXsinksource_in,opt_save)
%
% Ray-tracing + quasilinear kinetic calculations using LUKE. Tool for implementation in other calculation packages.
%
% by 	Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
%Ray-tracing calculations
%
if nargin < 15,
   opt_save = 0;%rays are calculated by C3PO and not reload
end 
%
path_simul = '';
%
for iw = 1:length(waves),
    if strcmp(waves{iw}.equil_id,equil.id) == 0,
        error('The wave structure was build with an inconsistent equilibrium')
    end
end
%
if opt_save == 1 & exist(['EQUIL/EQUIL_',equil.id,'.mat']) == 0,
    mkdir('EQUIL')
    savestr = ['EQUIL/EQUIL_',equil.id,'.mat'];
    save(savestr,'equil');
end    
%
equil.opt_save = opt_save;
%
nw0 = length(waves);
%
for iw = (nw0 + 1):(nw0 + length(wavestructs)),
    %
    wavestruct = wavestructs{iw};
    %
    if strcmp(wavestruct.wavesolver,'C3PO'),% C3P0 ray tracing
	    rayinit = main_rayinit_launch_jd(equil,wavestruct.launch);
	    if ~isfield(wavestruct,'C3POparam'),wavestruct.C3POparam = [];end
	    wave = main_C3PO_jd(wavestruct.id,equil,rayinit,wavestruct.waveparam,wavestruct.fitequilparam,wavestruct.rayparam,wavestruct.raydisplay,wavestruct.C3POparam);%Ray calculations
        %
        wave = wave_process_jd(equil,wave,dkeparam.n_rf_list);%Wave processing and relativistic linear damping
        %
        if isfield(wavestruct.launch,'b_sdNpar') == 1,
            wave.b_sdNpar = wavestruct.launch.b_sdNpar;
        end
        %
        if opt_save == 1,
            mkdir('WAVE')
            cd WAVE
            mkdir('C3PO')
            cd ..
            savestr = ['WAVE/C3PO/RAYINIT_',equil.id,'_',wavestruct.id,'.mat'];
            save(savestr,'rayinit');
            %
            savestr = ['WAVE/C3PO/WAVE_',equil.id,'_',wavestruct.id,'.mat'];
            save(savestr,'wave');
        end
        %
        waves{iw} = wave;    
    else
	    error('This ray-tracing is not yet linked to LUKE !')
    end
end
%
clear wavestruct rayinit wave 
%
nw = length(waves);
for iw = 1:nw,
    nb(iw) = length(waves{iw}.rays);
end
%
% Determination of the radial grid optmized according to linear damping
%
rho_S = optgrid_dke_jd(waves,rho_S,dkedisplay.display_mode);
%
% 3-D relativistic bounce averaged quasilinear kinetic calculations (LUKE)
%
if dkeparam.rt_mode == 1,
%
% Case with sdNpar given by the waves structure (usualy constant along ray propagation)
%
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
%
% Case with sdNpar proportional to sNpar (in waves structure)
%
elseif dkeparam.rt_mode == 2,
    %
    [qe,me] = pc_dke_yp;
    %
    for iw = 1:nw,
        for ib = 1:nb(iw),
            %
            dNpar0 = waves{iw}.rays{ib}.sdNpar(1);
            Npar0 = real(waves{iw}.rays{ib}.sNpar(1));
            %
            npresmin = 5;%minimum number of resonant points for numerical stability
            vparres = 4;%resonant velocity
            %
            dNparmin = abs(Npar0)*npresmin*dkeparam.pnmax_S/dkeparam.np_S/vparres;
            %
            omega_ce = qe*equil.ptBPHI(1,1)/me;
            %
            if waves{iw}.omega_rf < omega_ce/5 & dNpar0 < dNparmin,
                info_dke_yp(2,['WARNING: wave #',num2str(iw),' ray #',num2str(ib),': initial dNpar increased to ',num2str(dNparmin),' for numerical stability']);
                dNpar0 = dNparmin;
            end
            %
            waves{iw}.rays{ib}.sdNpar = real(waves{iw}.rays{ib}.sNpar)*dNpar0/Npar0;
        end
    end
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
%
% *************************************************************************
%
% Case with sdNpar proportional to ss (in waves structure)
%
elseif dkeparam.rt_mode == 4,
    %
    for iw = 1:nw,
        if ~isfield(waves{iw},'a_sdNpar') == 1,
            warning(['a_sdNpar not specified is set to zero for wave ',int2str(iw)])
            waves{iw}.a_sdNpar = 0;
        end
%
        for ib = 1:nb(iw),
            waves{iw}.rays{ib}.sdNpar = waves{iw}.rays{ib}.sdNpar(1) + waves{iw}.a_sdNpar*waves{iw}.rays{ib}.ss;
        end
    end
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
%
% *************************************************************************
%
% Case with sdNpar increasing at each caustic point
%
elseif dkeparam.rt_mode == 5,
    %
    for iw = 1:nw,
        for ib = 1:nb(iw),
            scaustic = logical([0,diff(waves{iw}.rays{ib}.pmode) ~= 0]);
            sscattering = cumsum(scaustic);
            %
            waves{iw}.rays{ib}.sdNpar = waves{iw}.rays{ib}.sdNpar(1)*waves{iw}.b_sdNpar.^sscattering;
        end
    end
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
%
% *************************************************************************
%
% Seek mode : optimize according to highest driven current
%
elseif dkeparam.rt_mode == 3,%
    %
    if isfield(dkeparam,'seekparam'),
        %
        submode = dkeparam.seekparam.submode;
        %
        if submode == 1,%case where sdNpar/sNar is a constant factor
            val = dkeparam.seekparam.f_sdNpar_in;%This is in dkeparam because it is the same for all waves
            step = dkeparam.seekparam.f_step;
        elseif submode == 2,
            val = dkeparam.seekparam.a_sdNpar_in;%This is in dkeparam because it is the same for all waves
            step = dkeparam.seekparam.a_step;
            %
            for iw = 1:nw,
                for ib = 1:nb(iw),
                    sdNpar_in{iw}(ib) = waves{iw}.rays{ib}.sdNpar(1);
                end
            end
        else
            error('unknown method in rt_mode 3')
        end
    else
        error('dkeparam.seekparam must be specified for rt_mode 3')
    end
    %
    opt_loop = 0;
    eta = 0;
    firststep = 1;
    %
    while opt_loop == 0,
        %
        eta_old = eta;
        %
        for iw = 1:nw,
            for ib = 1:nb(iw),
                if submode == 1,
                    waves{iw}.rays{ib}.sdNpar = abs(real(waves{iw}.rays{ib}.sNpar))*val;
                elseif submode == 2,
                    waves{iw}.rays{ib}.sdNpar = sdNpar_in{iw}(ib) + waves{iw}.rays{ib}.ss*val;
                end
            end
        end
        %
        dNstr = num2str(val);
        dNstr = dNstr(1:min(5,length(dNstr)));
        %
        for is=1:length(dNstr),if dNstr(is) == '.',dNstr(is) = 'p';end,end
        %
        % eval(['diary ',path_simul,'DKE_DIARY_',equil.id,'_',id_simul,'_',dNstr,'.txt']);
        %
        [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
        %
        % CD efficiency (A/W)
        %
        Prf = sum(ZP0.x_rf_fsav(:).*equilDKE.xdV_2piRp_dke(:)*2*pi*equilDKE.Rp*mksa.P_ref);
        Itot = sum(Zcurr.x_tot_fsav(:).*equilDKE.xdA_dke(:)*mksa.j_ref);
        eta = abs(Itot/Prf);
        %
        eval(['save ',path_simul,'DKE_RESULTS_',equil.id,'_',id_simul,'_',dNstr,'.mat']);
        %
        disp(['--> Step ',dNstr,' calculated. eta = ',num2str(eta),' A/W'])
        %
        % diary off
        %
        % This function calculates the power deposited along each ray using LUKE results. 
        %
        waves = alphaphi_luke_jd(waves,dke_out,gridDKE);
        %
        if eta > eta_old,
            %
            val = val + step;
            %
            if eta_old > 0,
                firststep = 0;
            end
            %
        elseif firststep == 1,
            %
            step = - step;
            val = val + 2*step;
            %
            firststep = 0;
            %
        else
            %
            opt_loop = 1;
            %
            val = val - step;
            %
        end
        %
        if opt_loop == 0 & val < -1000*eps,
            %
            opt_loop = 1;
            %
            val = val - step;
            %
        end
    end
    %
    % eval(['diary ',path_simul,'DKE_DIARY_',equil.id,'_',id_simul,'.txt']);
    %
    for iw = 1:nw,
        for ib = 1:nb(iw),
            if submode == 1,
                waves{iw}.rays{ib}.sdNpar = abs(waves{iw}.rays{ib}.sNpar)*val;
            elseif submode == 2,
                waves{iw}.rays{ib}.sdNpar = sdNpar_in{iw}(ib) + waves{iw}.rays{ib}.ss*val;
            end
        end
    end
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
    %
    % diary off
end
%
dke_out.waves = waves;
%
if dkeparam.rt_mode >= 1,%Variable number of outputs (only if LUKE is running otherwise no output)
	if nargout >= 1,varargout{1} = Znorm;end
	if nargout >= 2,varargout{2} = Zcurr;end
	if nargout >= 3,varargout{3} = ZP0;end
	if nargout >= 4,varargout{4} = dke_out;end
	if nargout >= 5,varargout{5} = radialDKE;end
	if nargout >= 6,varargout{6} = equilDKE;end
	if nargout >= 7,varargout{7} = momentumDKE;end
	if nargout >= 8,varargout{8} = gridDKE;end
	if nargout >= 9,varargout{9} = Zmomcoef;end
	if nargout >= 10,varargout{10} = Zbouncecoef;end
	if nargout >= 11,varargout{11} = Zmripple;end
	if nargout >= 12,varargout{12} = mksa;end
	if nargout >= 13,varargout{13} = XXsinksource;end
    if nargout >= 14,varargout{14} = dke_warnings;end   
end		






















