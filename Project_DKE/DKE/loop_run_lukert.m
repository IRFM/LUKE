function [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = loop_run_lukert(simul,waves,psin_S,rho_S_init,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,XXf0_in,XXsinksource_in,loadstruct)
%
% Ray-tracing + quasilinear kinetic calculations using LUKE. Tool for implementation in other calculation packages.
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
path_simul = '';
%
nw = length(waves);
nb = zeros(1,nw);
for iw = 1:nw,
    if isfield(waves{iw},'rays'),
        nb(iw) = length(waves{iw}.rays);
    else
        nb(iw) = NaN;
    end
end
%
% Determination of the radial grid optmized according to linear damping
%
if ~isfield(dkeparam,'w_mask'),
    w_mask = NaN;
else
    w_mask = dkeparam.w_mask;%list of waves to account for in the radial grid determination
end
%
if isfield(dkeparam,'rho0') && length(rho_S_init) == 1,
    rho_S_init = rho_S_init + i*dkeparam.rho0;
end
%
if isfield(dkeparam,'nk_abs'),
    nk_abs = dkeparam.nk_abs;
else
    nk_abs = 1;
end
%
[rho_S,dkeparam.pnmax_S] = optgrid_dke_jd(waves,rho_S_init,dkeparam.pnmax_S,equil,w_mask,dkedisplay.display_mode);
%
% 3-D relativistic bounce averaged quasilinear kinetic calculations (LUKE)
%
if dkeparam.rt_mode == 1,
%
% Case with sdNpar given by the waves structure (usualy constant along ray propagation)
%
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in,loadstruct);
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
            if waves{iw}.omega_rf < omega_ce/5 && dNpar0 < dNparmin,
                info_dke_yp(2,['WARNING: wave #',num2str(iw),' ray #',num2str(ib),': initial dNpar increased to ',num2str(dNparmin),' for numerical stability']);
                dNpar0 = dNparmin;
            end
            %
            waves{iw}.rays{ib}.sdNpar = real(waves{iw}.rays{ib}.sNpar)*dNpar0/Npar0;
        end
    end
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in,loadstruct);
%
% *************************************************************************
%
% Case with sdNpar eventually proportional to ss (in waves structure)
%
elseif dkeparam.rt_mode == 4,
    %
    iw_list = [];%list of LH waves
    a_sdNpar = zeros(1,nw);
    %
    for iw = 1:nw,
        if strcmp(waves{iw}.rayinit.launch.type,'LH'),
            iw_list = [iw_list, iw];
            %
            if ~isfield(waves{iw},'a_sdNpar'),
                disp(['a_sdNpar not specified is set to zero for wave ',int2str(iw)])
                a_sdNpar(iw) = 0;% used only in abslim loop
            else
                a_sdNpar(iw) = waves{iw}.a_sdNpar;
            end
        end
    end
    %
    for ik = 1:nk_abs,
        %
        for iw = iw_list;            
            %
            for ib = 1:nb(iw),
                waves{iw}.rays{ib}.sdNpar = waves{iw}.rays{ib}.sdNpar(1) +ik*a_sdNpar(iw)*waves{iw}.rays{ib}.ss;
            end
            %
            if isfield(waves{iw},'waveparam') && isfield(waves{iw}.waveparam,'n_rf_list'),
                n_rf_list = waves{iw}.waveparam.n_rf_list;
            elseif isfield(dkeparam,'n_rf_list'),
                n_rf_list = dkeparam.n_rf_list;
            else
                disp('Warning : no n_rf_list data found, enforced to 0:3')
                n_rf_list = 0:3;
            end
            %
            % the wave linear deposition is recalculated accounting for a_sdNpar effect
            %
            waves{iw}.a_sdNpar = ik*a_sdNpar(iw);
            %
            waves{iw} = wave_process_jd(equil,waves{iw},n_rf_list);%Wave processing and relativistic linear damping
            %
        end
        %
        % the radial grid is recalculated accounting for a_sdNpar effect
        %
        [rho_S,dkeparam.pnmax_S] = optgrid_dke_jd(waves,rho_S_init,dkeparam.pnmax_S,equil,w_mask,dkedisplay.display_mode);
        %
        [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in,loadstruct);
        %
        ny = size(ZP0(end).xy_rf_fsav,2);
        %
        yp_rf = 2*pi*equil.Rp*sum(ZP0(end).xy_rf_fsav*mksa.P_ref.*repmat(equilDKE.xdV_2piRp_dke.',[1,ny]),1);
        %
        P0 = 0;
        Pabs = 0;
        yb = dke_out.yb;
        %
        for iw = iw_list,
            %
            ibmin = sum(nb(1:iw-1)) + 1;
            ibmax = sum(nb(1:iw)) + 1;
            %
            if iw < nw
                ymask = yb(ibmin):(yb(ibmax) - 1);
            else
                ymask = yb(ibmin):ny;
            end            
            %
            Pabs = Pabs + 1e6*sum(yp_rf(ymask));
            for ib = 1:nb(iw),
                P0 = P0 + waves{iw}.rays{ib}.P0_2piRp*2*pi*equil.Rp;
            end
        end
        %
        if P0 > 0 && isfield(dkeparam,'abs_lim') && Pabs/P0 < dkeparam.abs_lim,
            %
            if a_sdNpar(iw) == 0,
                %
                a_sdNpar(iw) = 0.01;
                %
            end
            %
        else
            break
        end
    end
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
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in,loadstruct);
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
            sdNpar_in = cell(1,nw);
            for iw = 1:nw,
                sdNpar_in{iw} = zeros(1,nb(iw));
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
        % eval(['diary ',path_simul,'DKE_DIARY_',equil.id,'_',simul.id,'_',dNstr,'.txt']);
        %
        [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in,loadstruct);
        %
        % CD efficiency (A/W)
        %
        Prf = sum(ZP0.x_rf_fsav(:).*equilDKE.xdV_2piRp_dke(:)*2*pi*equilDKE.Rp*mksa.P_ref);
        Itot = sum(Zcurr.x_tot_fsav(:).*equilDKE.xdA_dke(:)*mksa.j_ref);
        eta = abs(Itot/Prf);
        %
        eval(['save ',path_simul,'DKE_RESULTS_',equil.id,'_',simul.id,'_',dNstr,'.mat']);
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
        if opt_loop == 0 && val < -1000*eps,
            %
            opt_loop = 1;
            %
            val = val - step;
            %
        end
    end
    %
    % eval(['diary ',path_simul,'DKE_DIARY_',equil.id,'_',simul.id,'.txt']);
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
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = main_dke_yp(simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in,loadstruct);
    %
    % diary off
elseif dkeparam.rt_mode == -1,
    %
    % No FP calculations, return equil and waves
    %
    Znorm = [];
    Zcurr.x_0_fsav = [];
    ZP0.x_rf_fsav = [];
    dke_out.equil = equil;
    dke_out.waves = waves;
    dke_out.XXf0 = [];
    radialDKE = [];
    equilDKE = [];
    momentumDKE = [];
    gridDKE = [];
    Zmomcoef = [];
    Zbouncecoef = [];
    Zmripple = [];
    mksa = [];
    XXsinksource = [];  
    dke_warnings = [];
    %
else
    Znorm = [];
    Zcurr = [];
    ZP0 = [];
    dke_out = [];
    radialDKE = [];
    equilDKE = [];
    momentumDKE = [];
    gridDKE = [];
    Zmomcoef = [];
    Zbouncecoef = [];
    Zmripple = [];
    mksa = [];
    XXsinksource = [];  
    dke_warnings = [];
    warning('rt mode not recongized in loop_run_lukert.m');
end
%


















