function [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource,dke_warnings] = ...
    main_dke_yp(simul_in,dkepath,equil,dkeparam_in,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in,loadstruct)
%
%  Main function of the 3-D relativistic bounce-averaged electron drift kinetic equation solver 
%  for the RF wave absorption problem in presence of an Ohmic electric field (electron bootstrap current consistent with non-Maxwellian distribution)
%  Small banana width approximation
%  Arbitrary axisymmetric plasma equilibrium (linked arbitrary tokamak magnetic equilibrium code, via mexfile)
%  Plasma current, RF power absorption, runaway rate, magnetic ripple loss
%  and fast electron bremsstrahlung calculations
%
%by Y.Peysson (CEA-DRFC) <yves.peysson@cea.fr> and J. Decker (CEA-DRFC) <joan.decker@cea.fr>
%
%
if ~isstruct(simul_in),
    simul.id = simul_in;
    simul.path = './';
else
    simul = simul_in;
end
%
simul.timeid = timeid_jd(clock);
simul.userid = userid_jd;
[simul.LUKEversion,simul.matver] = LUKEversion_jd;
simul.hostname = dkepath.hostname;
%
dke_warnings = '';
%
if nargin < 11,
    error('Wrong number of input arguments in main_dke_yp');
elseif nargin == 11,
    loadstruct = [];
end
%
if dkeparam_in.opt_save && ~ exist('tmp','dir'),
	mkdir('tmp')
end
%
format long e;
%
% set temp path
%
mkdirmessage = 'Directory already exists.';
while strcmp(mkdirmessage,'Directory already exists.'),
    dkepath.temppath = fullfile(dkepath.temppathroot,timeid_jd(clock,3));
    [dummy,mkdirmessage] = mkdir(dkepath.temppath);%Create calculation directory
end
%
tmpfile = [simul.path,'LUKE_RESULTS_',simul.id,'_TMP.mat'];
%
if dkeparam_in.opt_load && exist(tmpfile,'file'),
    %
    load(tmpfile);
    info_dke_yp(2,['File ',tmpfile,' reloaded.']);
    %
    itn0 = itn;
    %
else
    %
    % Load data if existing in 'loadstruct' structure or recalculate them otherwise
    %
    [dkeparam_out,radialDKE,equilDKE,momentumDKE,gridDKE,mksa,Zmomcoef,Zbouncecoef,XXsinksource,Zmripple,...
        ZXXD_a,ZXXF_a,...
        ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,XXILor,...
        ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity,...
        waveparam,xyprop_dke,xyP0_2piRp_mod,yb,yP0_2piRp,xys,...
        ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf,...
        XXfinit]...
         = buildlukestruct_yp(loadstruct,equil,dkeparam_in,dkedisplay,dkepath,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
    %
    time0 = clock;
    %
    if strcmp(waveparam.model,'RT') && ~isempty(waveparam.bomega_rf),%initialization of wave parameters  
        %
        delta_rt = dkeparam_out.delta_rt;%smoothering parameter of quasilinear iterations
        %
        zS = raypath_jd(xys,xyprop_dke,yb,radialDKE.r_dke);
        nit_rf = dkeparam_out.nit_rf;
        if nit_rf > 1 && dkedisplay.display_mode >= 1,
            Fig_QLIter = figbyname_yp('Quasilinear iteration');
            if dkedisplay.display_mode >= 2,
                Fig_Pray = figbyname_yp('Power absorption along rays');
            end
        end
    else
        nit_rf = 1;
        redfac = 1;
        xyP0_2piRp_mod = ones(gridindex_rf.nr,gridindex_rf.ny);
    end 
    %
    FPtime = dkeparam_out.tn;
    nit = length(FPtime);
    dtn_list = diff([0,FPtime]);
    %
    if nit > 1 && dkedisplay.display_mode >= 1,
        Fig_TimeIter = figure('Name','Time evolution');        
    end
    %
    residue_rf = cell(1,nit);
    normf0 = cell(1,nit);
    curr0 = cell(1,nit);
    residu_f = cell(1,nit);
    XXf0 = cell(1,nit);
    zP_0_2piRp_mod_old = cell(1,nit);
    %
    if dkeparam_out.timevol == 1,
    %     ZP0 = cell(1,nit);
    %     Zf0_interp = cell(1,nit);
    %     Zcurr = cell(1,nit);
    %     Znorm = cell(1,nit);
        XxRR_fsav = cell(1,nit);
        xMRR_flux = cell(1,nit);
        xMRR_tau = cell(1,nit);
        xRR_fsav = cell(1,nit);
        xne_norm_out = cell(1,nit);
        xTe_norm_out = cell(1,nit);
        xft_fsav = cell(1,nit);
        xfteff_fsav = cell(1,nit);
    end
    %
    itn0 = 1;
    %
end
%
% --------------------------------- Solve the electron drift kinetic --------------------------------
%
% The evolution of the distribution function is calculated from time 0 to
% time dkeparam.tn, by time steps dkeparam.dtn. For each time step,
% nested convergence on the wave absorption and explicit collision
% integral term must be obtained.
%
for itn = itn0:nit,
    %
    dkeparam_out.dtn = dtn_list(itn);
    %
    if itn == 1,
        XXfin = XXfinit;
        %
        if dkeparam_out.finitabs == 1,%The initial distribution is used to first estimate the ray absorption
            conv = -1;
        else
            conv = 0;
        end
    else
        XXfin = XXf0{itn - 1};
        %
        conv = 0;
    end
    %
    for it_rf=1:nit_rf, % convergence in the ray-tracing mode
        if strcmp(waveparam.model,'RT') && ~isempty(waveparam.bomega_rf),%in the case of RF waves only
            %
            if it_rf > 1 && conv <= 0,
                xyP0_2piRp_mod = delta_rt*xyP0_2piRp_mod_old + (1 - delta_rt)*xyP0_2piRp_mod;
            end
            %
            if dkeparam_out.redfac == 1 && nit_rf > 1,
                if it_rf == 1,
                    redfac = max(sum(xyP0_2piRp_mod.'))/sum(max(xyP0_2piRp_mod(:,yb)));
                else
                    redfac = redfac - 1;
                end
                %redfac = 10/it_rf;
                %
                redfac = max([redfac,1]);
                %
            else
                redfac = 1;
            end
        end
        %
        [ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp] = raysum_rf_jd(dkeparam_out,ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod/redfac,gridindex_rf);
        [Zdelta,MMXT_f_t,MMXP_f_t,MMXR_f_t,Xmask_r_edge,MMXP_tp,MMXP_g_t,MMH_tp,Zpn2_t,sm_f,sm_g,sm_tp] = matrixcalc_dke_yp(dkeparam_out,dkedisplay,gridDKE,equilDKE,Zbouncecoef,mksa,Zmripple,Zmomcoef,transpfaste,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXILor,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp,ZXXD_a,ZXXF_a);%Build the 3D DKE matrix
        %
        if conv >= 0,
            [XXf0{itn},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,radial_mode,memoryLU_f,memoryLU_g,time_DKE,normf0{itn},curr0{itn},residu_f{itn}] = solver_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,Zpn2_t,sm_f,sm_g,sm_tp,it_rf,MMXR_f_t,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,XXILor,Xmask_r_edge,XXsinksource,XXfM,XXfin);% Solve the DKE equation
        else% case where the initial distribution is used to first estimate the ray absorption
            XXf0{itn} = XXfin;
            XXf0_tp = zeros(size(XXf0{itn}));
            XXf0_g = zeros(size(XXf0{itn}));
            XXf0_L_tp = zeros(size(XXf0{itn}));
            XXf0_L_g = zeros(size(XXf0{itn}));
            radial_mode = NaN;
        end
        %
        xyP0_2piRp_mod_old = xyP0_2piRp_mod;
        %
        if strcmp(waveparam.model,'RT') && ~isempty(waveparam.bomega_rf),%In the case of RF waves and quasilinear iteration
            if nit_rf > 1,  
                %
                % Calculation of the density of power absorbed for all rays
                %
                [ZP0_rf] = fmoments_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi,waveparam,radial_mode,Zdelta,XXsinksource,...
                    XXf0{itn},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
                    ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod,gridindex_rf);%Calculate RF absorbed power of the distribution function
                if dkeparam_out.dke_mode >= 1,
                    xyPabs_rf_dke_fsav_out = ZP0_rf.xy_rf_fsav + ZP0_rf.xy_rf_tp_fsav + ZP0_rf.xy_rf_g_fsav; % flux-surface averaged density of absorbed power.
                else
                    xyPabs_rf_dke_fsav_out = ZP0_rf.xy_rf_fsav; % flux-surface averaged density of absorbed power.
                end	    
                xyPabs_rf_dke_fsav_mksa = xyPabs_rf_dke_fsav_out*mksa.P_ref*1e6;%RF power (W)
                %
                % Calculation of the power flow along the rays from DKE calculations
                %
                [xyP0_2piRp_out,xyP0_2piRp_mod] = rfprop_dke_jd(yb,yP0_2piRp,xyprop_dke,xyP0_2piRp_mod_old,xyPabs_rf_dke_fsav_mksa,equilDKE.xdV_2piRp_dke,gridDKE.xpsin,gridDKE.xpsin_dke,gridDKE.rdke,dkeparam_out.dke_mode);
                %
                zP_0_2piRp_mod_old{itn} = raypath_jd(xyP0_2piRp_mod_old,xyprop_dke,yb,radialDKE.r_dke);
                zP_0_2piRp_mod = raypath_jd(xyP0_2piRp_mod,xyprop_dke,yb,radialDKE.r_dke);
                zP_0_2piRp_out = raypath_jd(xyP0_2piRp_out,xyprop_dke,yb,radialDKE.r_dke);
                %
                P_0_2piRp_in = sum(yP0_2piRp);
                P_0_2piRp_out = 0;
                for iray = 1:length(yb),
                     P_0_2piRp_out = P_0_2piRp_out + zP_0_2piRp_mod_old{itn}{iray}(end);
                end
                %
                abs_frac = (P_0_2piRp_in - P_0_2piRp_out)/P_0_2piRp_in;
                %
                for iray = 1:length(yb),
                    yresidue_rf_mod(iray,it_rf) = max(abs(zP_0_2piRp_mod{iray} - zP_0_2piRp_mod_old{itn}{iray})./zP_0_2piRp_mod{iray}(1));
                    yresidue_rf_out(iray,it_rf) = max(abs(zP_0_2piRp_mod{iray} - zP_0_2piRp_out{iray})./zP_0_2piRp_mod{iray}(1));
                end
                %
                %residue_rf{itn}(it_rf) = max([yresidue_rf_mod(:,it_rf);yresidue_rf_out(:,it_rf)]);
                residue_rf{itn}(it_rf) = max(yresidue_rf_mod(:,it_rf));
                %
                if dkedisplay.display_mode >= 1,
                    figure(Fig_QLIter),
                    [ax] = graph1D_jd(1:it_rf,residue_rf{itn},0,1,'Iteration number','\DeltaP/P','Quasilinear convergence',NaN,[0,nit_rf],[dkeparam_out.prec_rf,1],'none','+','r',2);
                    grid  on
                    drawnow;                
    %             
                    if dkedisplay.display_mode >= 2,
                        for iray = 1:length(zS),
                            figure(Fig_Pray + iray - 1);clf
                            [ax] = graph1D_jd(zS{iray},zP_0_2piRp_mod_old{itn}{iray},0,0,'','P_{LH}/2\piR_p (W/m)',['QL convergence, ray #',int2str(iray)],NaN,'','','--','none','r',2);
                            [ax] = graph1D_jd(zS{iray},zP_0_2piRp_mod{iray},0,0,'','P_{LH}/2\piR_p (W/m)',['QL convergence, ray #',int2str(iray)],NaN,'','','-','none','r',2);
                            legend(['Iteration #',int2str(it_rf-1)],['Iteration #',int2str(it_rf)])
                            title(['Ray #',num2str(iray),', residue: ',num2str(max([yresidue_rf_mod(iray,it_rf);yresidue_rf_out(iray,it_rf)]))])
                            grid on
                            drawnow;
                        end
                    end
                end
    %
                if dkedisplay.display_mode >=1,
                    info_dke_yp(2,'---------------------------------------------------------');
                    info_dke_yp(2,['Quasilinear iteration : ',int2str(it_rf),', Residu = ',num2str(residue_rf{itn}(it_rf)),', delta_rt = ',num2str(delta_rt)]);
                    info_dke_yp(2,'---------------------------------------------------------');
                end
    %  
                if (residue_rf{itn}(it_rf) <= dkeparam_out.prec_rf && redfac == 1 && it_rf > 1 && conv == 1) || it_rf == nit_rf,
                    %
                    dke_warnings = '';               
                    if isfield(dkeparam_out,'abs_lim') && abs_frac < dkeparam_out.abs_lim,
                        dke_warnings = 'The RF power is not fully absorbed. To bypass this error set dkeparam.abs_lim between 0 and 1';
                    end
                    %
                    if residue_rf{itn}(it_rf) <= dkeparam_out.prec_rf && redfac == 1 && it_rf > 1 && conv == 1,
                        if dkedisplay.display_mode >=1,info_dke_yp(2,['Successfull convergence achieved for ray-tracing coupling after ',int2str(it_rf),' iterations !']);end
                        break
                    else
                        info_dke_yp(2,['WARNING: convergence for ray-tracing coupling was not achieved after ',int2str(it_rf),' iterations !']);                  
                    end
                else   	
                    if dkedisplay.display_mode >=1,info_dke_yp(2,['Iteration ',int2str(it_rf),', residue = ',num2str(residue_rf{itn}(it_rf))]);end       
                end
                %
                if (residue_rf{itn}(it_rf) <= dkeparam_out.prec_rf && redfac == 1 && it_rf > 1 && conv == 0),
                    if min(min(min(ZP0_rf.xyn_rf_fsav))) < 0,
                         info_dke_yp(2,['WARNING: residue below threshold but iterations continue while negative absorbed power occurs somewhere!']);                  
                    else
                        conv = 1;
                    end
                end		
                %
                if (residue_rf{itn}(it_rf) <= dkeparam_out.prec_rf && redfac == 1 && it_rf > 1 && conv == -1),
                    if dkedisplay.display_mode >=1,info_dke_yp(2,['Successfull convergence achieved for ray-tracing coupling on initial distribution after ',int2str(it_rf),' iterations !']);end
                    conv = 0;
                end	
                %
                if 0,%dkeparam_out.finsert == 1,
                    XXfin = XXf0{itn};
                    abs_frac_rf(it_rf) = abs_frac;
                end
            end     
        end
    end
    %
    % Moments of the distribution function
    %
    if dkeparam_out.timevol == 1,
        [ZP0(itn),Zf0_interp(itn),Zcurr(itn),Znorm(itn),ZXXS,...(itn)
            XxRR_fsav{itn},xMRR_flux{itn},xMRR_tau{itn},xMRR_power_flux{itn},xMRR_power_tau{itn},xRR_fsav{itn},...
            xne_norm_out{itn},xTe_norm_out{itn},xft_fsav{itn},xfteff_fsav{itn},XXRintmask{itn},Zmom(itn)] = ...
            fmoments_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi,waveparam,radial_mode,Zdelta,XXsinksource,...
            XXf0{itn},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
            ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod_old,gridindex_rf,...
            ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,XXILor);%Calculate moments of the distribution function
    end
    %
    if nit > 1 && dkedisplay.display_mode >= 1,
        figure(Fig_TimeIter),
        if length(equilDKE.xrho) == 1,
            graph1D_jd(FPtime(itn),curr0{itn}(end),0,0,'FP time (\tau_c)','J (norm.)','FP Evolution',NaN,[0,max(FPtime)],NaN,'none','+','r',2);
        elseif dkeparam_out.timevol == 1,
            graph1D_jd(FPtime(itn),Zcurr(itn).I_tot,0,0,'FP time (\tau_c)','I (MA)','FP Evolution',NaN,[0,max(FPtime)],NaN,'none','+','r',2);
        else
            graph1D_jd(FPtime(itn),max(abs(curr0{itn}(:,end))),0,0,'FP time (\tau_c)','max(|J|) (norm.)','FP Evolution',NaN,[0,max(FPtime)],NaN,'none','+','r',2);
        end
        grid on
        drawnow;                
    end
    %
    if dkeparam_in.opt_save,
        save(tmpfile);
    end
end
%
if nit > 1 && dkedisplay.display_mode >= 1,
    close(Fig_TimeIter)
end
%
% Moments of the distribution function
%
if dkeparam_out.timevol == 0,
    %
    XXf0 = XXf0(nit);
    residue_rf = residue_rf(nit);
    %
    [ZP0,Zf0_interp,Zcurr,Znorm,ZXXS,...
        XxRR_fsav,xMRR_flux,xMRR_tau,xMRR_power_flux,xMRR_power_tau,xRR_fsav,...
        xne_norm_out,xTe_norm_out,xft_fsav,xfteff_fsav,XXRintmask,Zmom] = ...
        fmoments_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi,waveparam,radial_mode,Zdelta,XXsinksource,...
        XXf0{1},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
        ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod_old,gridindex_rf,...
        ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,XXILor);%Calculate moments of the distribution function
    %
end
%   RF wave quasilinear diffusion
%
if ~isstruct(waveparam) && ~isempty(waveparam.bomega_rf),%In the case of RF waves and quasilinear iteration
    [qe,me] = pc_dke_yp;%Universal physics constants
    blist_lh = find(round(waveparam(1,:,1)./(qe*min(equilDKE.xB0)/me)) == 0);
    nb_lh = length(blist_lh);
    waveparam_lh = waveparam(:,blist_lh,:);
    blist_ec = find(round(waveparam(1,:,1)./(qe*min(equilDKE.xB0)/me)) > 0);
    nb_ec = length(blist_ec);
    waveparam_ec = waveparam(:,blist_ec,:);
%
%For displaying RF quasilinear domain only
%
   if nb_ec > 0,
      xDperp_cy_ref = waveparam_ec(:,1,4);
   end
   if nb_lh > 0,
      xD0_lh_ref = waveparam_lh(:,1,4);
      xvparmin_lh = 1./waveparam_lh(:,1,6)/mksa.betath_ref;
      xvparmax_lh = 1./waveparam_lh(:,1,5)/mksa.betath_ref;
   end
else 
    nb_lh = 0;
    nb_ec = 0;
end
%
time_out = etime(clock,time0);
memoryLU_f_out = memoryLU_f;
memoryLU_g_out = memoryLU_g;
%
if dkedisplay.display_mode >= 1,
    if dkeparam_out.dke_mode == 0,
        info_dke_yp(2,['Full elapsed time for solving the electron Fokker-Planck equation: ',num2str(time_out),' (s)']) 
    else
        info_dke_yp(2,['Full elapsed time for solving the electron Drift Kinetic equation: ',num2str(time_out),' (s)']) 
    end
    disp('-------------------------------------------------------------------------------------------------------------------');
end
%
%   Maxwellian bootstrap current calculations (for synergy calculations), no RF waves
%
if dkeparam_out.syn_mode == 1,
    time0_bc = clock;
    %
    waveparam_bc = [];
    [ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = efield_dke_jd(dkepath,dkeparam_out,dkedisplay,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef,'',ZXXF_c);%No Ohmic electric field
    %
    [ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp,ylist_rf] = rfdiff_dke_jd(dkeparam_out,dkedisplay,waveparam_bc,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa);% RF wave flux coefficients
    [MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,Zpn2_t,sm_f,sm_g,sm_tp] = matrixcalc_dke_yp(dkeparam_out,dkedisplay,gridDKE,equilDKE,Zbouncecoef,mksa,Zmripple,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXILor,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp);%Build the 3D DKE matrix
    [XXf0_bc,XXf0_bc_tp,XXf0_bc_g,XXf0_bc_L_tp,XXf0_bc_L_g,memoryLU_bc_f,memoryLU_bc_g] = solver_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,Zpn2_t,sm_f,sm_g,sm_tp,it_rf,MMXR_f_t,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,XXILor,XXsinksource,XXfinit);% Solve the DKE equation
    [ZP0_bc,Zcurr_bc,Znorm_bc,ZXXS_bc,ZYXXD_bc_rf,XxRR_bc_fsav,xMRR_flux_bc,xMRR_tau_bc,xMRR_power_flux_bc,xMRR_power_tau_bc,xRR_bc_fsav,xne_norm_bc_out_bc,xTe_norm_bc_out,xft_bc_fsav,xfteff_bc_fsav] = fmoments_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,[],radial_mode,Zdelta,XXf0{nit},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,ZXXD_rf,ZXXD_rf_tp,ZXXF_rf_tp,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp);%Calculate moments of the distribution function
%
    time_bc_out = etime(clock,time0_bc);
    memoryLU_bc_f_out = memoryLU_bc_f;
    memoryLU_bc_g_out = memoryLU_bc_g;
%
    if dkedisplay.display_mode >= 1,
        if dke_mode == 0,
            info_dke_yp(2,['Full elapsed time for solving the electron Fokker-Planck equation (Bootstrap Calc. Only): ',num2str(time_bc_out),' (s)']) 
        else
            info_dke_yp(2,['Full elapsed time for solving the electron Drift Kinetic equation (Bootstrap Calc. Only): ',num2str(time_bc_out),' (s)']) 
        end
        disp('-------------------------------------------------------------------------------------------------------------------');
    end
%
end
%
% DKE data output structure
%
dke_out.XXfinit = XXfinit;
dke_out.XXf0 = XXf0;
dke_out.XXfM = XXfM;
dke_out.Zf0_interp = Zf0_interp;
dke_out.XXf0_g = XXf0_g;
dke_out.FPtime = FPtime;
dke_out.normf0 = normf0;
dke_out.curr0 = curr0;
dke_out.residu_f = residu_f;
dke_out.ZXXS = ZXXS;
%
dke_out.ZXXD_c = ZXXD_c;
dke_out.ZXXF_c = ZXXF_c;
dke_out.XXILor = XXILor;
%
dke_out.ZXXD_e = ZXXD_e;
dke_out.ZXXF_e = ZXXF_e;
dke_out.xepsi = xepsi;
dke_out.xEfield_validity = xEfield_validity;
%
dke_out.waveparam = waveparam;
dke_out.xyprop_dke = xyprop_dke;
dke_out.xyP0_2piRp_mod = xyP0_2piRp_mod_old;
dke_out.yb = yb;
dke_out.yP0_2piRp = yP0_2piRp;
dke_out.xys = xys;
%
dke_out.ZXXD_rf = ZXXD_rf;
dke_out.ZXXF_rf = ZXXF_rf;
if dkeparam_out.opt_struct == 1,
    dke_out.ZXYD_rf = ZXYD_rf;
    dke_out.ZXYF_rf = ZXYF_rf;
end
dke_out.gridindex_rf = gridindex_rf;
%
dke_out.ZXXD_a = ZXXD_a;
dke_out.ZXXF_a = ZXXF_a;
%
dke_out.XxRR_fsav = XxRR_fsav;
dke_out.xMRR_flux = xMRR_flux;
dke_out.xMRR_tau = xMRR_tau;
dke_out.xMRR_power_flux = xMRR_power_flux;
dke_out.xMRR_power_tau = xMRR_power_tau;
dke_out.xTe_norm_out = xTe_norm_out;
dke_out.xne_norm_out = xne_norm_out;
dke_out.xft_fsav = xft_fsav;
dke_out.xfteff_fsav = xfteff_fsav;
dke_out.XXRintmask = XXRintmask;
dke_out.Zmom = Zmom;
dke_out.memoryLU_f_out = memoryLU_f_out;
dke_out.memoryLU_g_out = memoryLU_g_out;
dke_out.time_out = time_out;
dke_out.time_DKE = time_DKE;
%
if strcmp(waveparam.model,'RT') && ~isempty(waveparam.bomega_rf) && nit_rf > 1,
    dke_out.yresidue_rf_mod = yresidue_rf_mod;
    dke_out.yresidue_rf_out = yresidue_rf_out;
    dke_out.residue_rf = residue_rf;
    dke_out.zS = zS;
    dke_out.zP_0_2piRp_mod = zP_0_2piRp_mod_old;
    %
    %waves = alphaphi_luke_jd(waves,dke_out,equilDKE);% calculates the QL ray absorption
    %
end
%
dke_out.XXsource = XXsinksource_in;
dke_out.xRR_fsav = xRR_fsav;
dke_out.Zmripple = Zmripple;
%
dke_out.equil = equil;
dke_out.waves = waves;
dke_out.simul = simul;
%
if exist('abs_frac_rf','var'),
    dke_out.abs_frac_rf = abs_frac_rf;
end
%
if dkeparam_out.syn_mode == 1,
    dke_out.XXf0_bc = XXf0_bc;
    dke_out.XXf0_bc_tp = XXf0_bc_tp;
    dke_out.XXf0_bc_g = XXf0_bc_g;
    dke_out.XXf0_bc_L_tp = XXf0_bc_L_tp;
    dke_out.XXf0_bc_L_g = XXf0_bc_L_g;
    dke_out.Znorm_bc = Znorm_bc;
    dke_out.Zcurr_bc = Zcurr_bc;
    dke_out.ZP0_bc = ZP0_bc;
    dke_out.ZXXS_bc = ZXXS_bc;
    dke_out.ZYXXD_bc_rf = ZYXXD_bc_rf;
    dke_out.XxRR_bc_fsav = XxRR_bc_fsav;
    dke_out.xMRR_flux_bc = xMRR_flux_bc;
    dke_out.xMRR_tau_bc = xMRR_tau_bc;
    dke_out.xMRR_power_flux_bc = xMRR_power_flux_bc;
    dke_out.xMRR_power_tau_bc = xMRR_power_tau_bc;
    dke_out.xne_norm_bc_out = xne_norm_bc_out;
    dke_out.xTe_norm_bc_out = xTe_norm_bc_out;
    dke_out.xft_bc_fsav = xft_bc_fsav;
    dke_out.xfteff_bc_fsav = xfteff_bc_fsav;
    dke_out.memoryLU_bc_g_out = memoryLU_bc_g_out;
    dke_out.memoryLU_bc_f_out = memoryLU_bc_f_out;
    dke_out.time_bc_out = time_bc_out;
    dke_out.xRR_bc_fsav = xRR_bc_fsav;
else
    dke_out.XXf0_bc = [];
    dke_out.XXf0_bc_tp = [];
    dke_out.XXf0_bc_g = [];
    dke_out.XXf0_bc_L_tp = [];
    dke_out.XXf0_bc_L_g = [];
    dke_out.Znorm_bc = [];
    dke_out.Zcurr_bc = [];
    dke_out.ZP0_bc = [];
    dke_out.ZXXS_bc = [];
    dke_out.ZYXXD_bc_rf = [];
    dke_out.XxRR_bc_fsav = [];
    dke_out.xMRR_flux_bc = [];
    dke_out.xMRR_tau_bc = [];
    dke_out.xMRR_power_flux_bc = [];
    dke_out.xMRR_power_tau_bc = [];    
    dke_out.xne_norm_bc_out = [];
    dke_out.xTe_norm_bc_out = [];
    dke_out.xft_bc_fsav = [];
    dke_out.xfteff_bc_fsav = [];
    dke_out.memoryLU_bc_g_out = [];
    dke_out.memoryLU_bc_f_out = [];
    dke_out.time_bc_out = [];
    dke_out.xRR_bc_fsav = [];
end
%
% Flexible output
%
if dkeparam_out.opt_struct == 0,
    savefields_radialDKE = {'xrho_S_dke','xpsin_f','xpsin_f_dke','xdpsin_f_dke','xpsin_S_dke','r_dke'};
    savefields_momentumDKE = {'pn','pnp','pn_S','dpn','mhu','mhu_S','dmhu'};
    savefields_gridDKE = {'X1mmhu2','xmhubounce2'};
    savefields_Zmomcoef = {'gamma','v','Ec_ref','dEc_ref'};
    savefields_Zbouncecoef = {'xq','xqtilde','xqbar','xqhat','XXheaviside','Xxlambda'};
    savefields_Zmripple = {'XXlossripple','xdeltaripple','xNq','Xnhuloss','xthetabanana','xthetaloss','xpndetrap','xpnth','xEseuil'};
    %
    radialDKE = selectfields_jd(radialDKE,savefields_radialDKE);
    momentumDKE = selectfields_jd(momentumDKE,savefields_momentumDKE);
    gridDKE = selectfields_jd(gridDKE,savefields_gridDKE);
    Zmomcoef = selectfields_jd(Zmomcoef,savefields_Zmomcoef);
    Zbouncecoef = selectfields_jd(Zbouncecoef,savefields_Zbouncecoef);
    Zmripple = selectfields_jd(Zmripple,savefields_Zmripple);
end
%
if exist(dkepath.temppath,'dir')
    try
       rmdir(dkepath.temppath);%Remove calculation directory
    catch
       disp(['WARNING: The calculation directory:',dkepath.temppath,' has NOT been removed.']),
    end
end
%

