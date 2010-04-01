function [varargout] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam_in,display,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
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
simul.id = id_simul;
simul.timeid = timeid_jd(clock);
simul.userid = userid_jd;
simul.LUKEversion = LUKEversion_jd;
%
dke_warnings = '';
%
if nargin ~= 13,
    error('Wrong number of input arguments in main_dke_yp')
end
%
if dkeparam_in.opt_save & ~exist('temp'),
	mkdir('temp')
end
%
format long e;
global nfig;
%
% set temp path
%
dkepath.temppath = fullfile(dkepath.temppathroot,timeid_jd(clock));
mkdir(dkepath.temppath);%Create calculation directory
%
[dkeparam_out] = paramconsistency_dke_yp(dkeparam_in,equil,psin_S,rho_S);%Check consistency between input parameters 
multithreading_luke(dkepath);
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'.mat']),
   load(['temp',filesep,'DKE_TEMP_',id_simul,'.mat']);
   info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'.mat reloaded.']);
else
   [radialDKE] = radialgrid_dke_jd(equil,dkeparam_out,display,psin_S,rho_S);%Radial grid for DKE
   [equilDKE] = equilibrium_jd(equil,radialDKE,display,'spline',dkeparam_out.mfactor);%Magnetic equilibrium for DKE
   [momentumDKE] = momentumgrid_dke_jd(dkeparam_out,equilDKE,radialDKE);%Momentum space 2D grid for DKE
   [gridDKE] = matrix3Dgridbuilder_dke_yp(dkeparam_out,display,equilDKE,radialDKE,momentumDKE);%General grid structure for the DKE solver
   [mksa] = mksacoefbuilder_dke_yp(dkeparam_out,display,equilDKE,radialDKE,momentumDKE,gridDKE);%MKSA quantities calculations
   [Zmomcoef] = momentumcoefbuilder_dke_yp(gridDKE,mksa);%Momentum space coefficients for FP calculations
   [Zbouncecoef] = bouncecoefbuilder_dke_yp(dkeparam_out,display,equilDKE,gridDKE);%bounce averaging coefficients
   [waveparam,xyprop_dke,xyP0_2piRp_mod,yb,yP0_2piRp,xys] = rfwave_dke_jd(dkeparam_out,display,equil,equilDKE,gridDKE,Zbouncecoef,mksa,waves);%RF wave parameters preprocessing calculations
   [XXsinksource] = sinksourcecoeffbuilder_dke_yp(dkeparam_out,display,gridDKE,mksa,Zbouncecoef,XXsinksource_in);%External sink and source contributions (for right-hand side part of the FP equation)
   [Zmripple] = mripplecoefbuilder_dke_yp(dkeparam_out,display,equil,equilDKE,gridDKE,mksa,ripple);%Magnetic ripple matrix coefficients
   [ZXXD_a,ZXXF_a] = rad_dke_yp(dkeparam_out,display,equilDKE,gridDKE,mksa,Zbouncecoef,Zmomcoef,transpfaste);%Anomalous radial transport super matrix
   [ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,XXILor] = coll_dke_jd(dkepath,dkeparam_out,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef);%Collisions flux coefficients 
   [ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = efield_dke_jd(dkepath,dkeparam_out,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef,ohm,ZXXF_c);%Electric field flux coefficients
%
   if strcmp(waveparam.model,'RT'),% ray tracing simulation
      [ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = rfdiff_dke_jd(dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,waveparam);%RF waves flux coefficients
   elseif strcmp(waveparam.model,'FW_BIL')%full wave model by R. Bilato
      [ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = rfdiff_dke_fw_jd(dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,waves);%RF waves flux coefficients
   else
      error('Wave model not implemented')
   end
%
   [XXfinit] = finit_dke_yp(dkeparam_out,display,equilDKE,gridDKE,mksa,Zmomcoef,waveparam,XXf0_in);%Initial distribution function
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul]);end
end
%
% --------------------------------- Solve the electron drift kinetic --------------------------------
%
time0 = clock;
%
if strcmp(waveparam.model,'RT') & ~isempty(waveparam.bomega_rf),%initialization of wave parameters  
    %
    delta_rt = dkeparam_out.delta_rt;%smoothering parameter of quasilinear iterations
    %
    zP_0_2piRp_mod = raypath_jd(xyP0_2piRp_mod,xyprop_dke,yb,radialDKE.r_dke);
    zS = raypath_jd(xys,xyprop_dke,yb,radialDKE.r_dke);
    nit_rf = dkeparam_out.nit_rf;
    if nit_rf > 1 & display.display_mode >= 1,
        Fig_QLIter = figure('Name','Quasilinear iteration');
        if display.display_mode >= 2,
            Fig_Pray = figure('Name','Power absorption along rays');
        end
    end
else
    nit_rf = 1;
    redfac = 1;
    xyP0_2piRp_mod = '';
end  
%
residue_rf = [];
conv = 0;
XXfin = XXfinit;
%
for it_rf=1:nit_rf, % convergence in the ray-tracing mode
    if strcmp(waveparam.model,'RT') && ~isempty(waveparam.bomega_rf),%in the case of RF waves only
        %
        if it_rf > 1 && conv == 0,
            xyP0_2piRp_mod = delta_rt*xyP0_2piRp_mod_old + (1 - delta_rt)*xyP0_2piRp_mod;
        end
        %
        if 0,%nit_rf > 1,
            if it_rf == 1,
                redfac = max(sum(xyP0_2piRp_mod.'))/sum(max(xyP0_2piRp_in(:,yb)));
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
    [Zdelta,MMXT_f_t,MMXP_f_t,MMXR_f_t,Xmask_r_edge,MMXP_tp,MMXP_g_t,MMH_tp,Zpn2_t,sm_f,sm_g,sm_tp] = matrixcalc_dke_yp(dkeparam_out,display,gridDKE,equilDKE,Zbouncecoef,mksa,Zmripple,Zmomcoef,transpfaste,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXILor,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp,ZXXD_a,ZXXF_a);%Build the 3D DKE matrix
    [XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,radial_mode,memoryLU_f,memoryLU_g,time_DKE,normf0,curr0,residu_f] = solver_dke_yp(dkepath,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,Zpn2_t,sm_f,sm_g,sm_tp,it_rf,MMXR_f_t,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,XXILor,Xmask_r_edge,XXsinksource,XXfM,XXfin);% Solve the DKE equation
    %
    xyP0_2piRp_mod_old = xyP0_2piRp_mod;
    %
    if strcmp(waveparam.model,'RT') & ~isempty(waveparam.bomega_rf),%In the case of RF waves and quasilinear iteration
        if nit_rf > 1,  
            %
            % Calculation of the density of power absorbed for all rays
            %
            [ZP0] = fmoments_dke_yp(dkepath,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi,waveparam,radial_mode,Zdelta,XXsinksource,...
                XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
                ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod,gridindex_rf);%Calculate RF absorbed power of the distribution function
            if dkeparam_out.dke_mode >= 1,
                xyPabs_rf_dke_fsav_out = ZP0.xy_rf_fsav + ZP0.xy_rf_tp_fsav + ZP0.xy_rf_g_fsav; % flux-surface averaged density of absorbed power.
            else
                xyPabs_rf_dke_fsav_out = ZP0.xy_rf_fsav; % flux-surface averaged density of absorbed power.
            end	    
            xyPabs_rf_dke_fsav_mksa = xyPabs_rf_dke_fsav_out*mksa.P_ref*1e6;%RF power (W)
            %
            % Calculation of the power flow along the rays from DKE calculations
            %
            [xyP0_2piRp_out,xyP0_2piRp_mod] = rfprop_dke_jd(yb,yP0_2piRp,xyprop_dke,xyP0_2piRp_mod_old,xyPabs_rf_dke_fsav_mksa,equilDKE.xdV_2piRp_dke,gridDKE.xpsin,gridDKE.xpsin_dke,gridDKE.rdke,dkeparam_out.dke_mode);
            %
            zP_0_2piRp_mod_old = raypath_jd(xyP0_2piRp_mod_old,xyprop_dke,yb,radialDKE.r_dke);
            zP_0_2piRp_mod = raypath_jd(xyP0_2piRp_mod,xyprop_dke,yb,radialDKE.r_dke);
            zP_0_2piRp_out = raypath_jd(xyP0_2piRp_out,xyprop_dke,yb,radialDKE.r_dke);
            %
            P_0_2piRp_in = sum(yP0_2piRp);
            P_0_2piRp_out = 0;
            for iray = 1:length(yb),
                 P_0_2piRp_out = P_0_2piRp_out + zP_0_2piRp_mod_old{iray}(end);
            end
            %
            abs_frac = (P_0_2piRp_in - P_0_2piRp_out)/P_0_2piRp_in;
            %
            for iray = 1:length(yb),
                yresidue_rf_mod(iray,it_rf) = max(abs(zP_0_2piRp_mod{iray} - zP_0_2piRp_mod_old{iray})./zP_0_2piRp_mod{iray}(1));
                yresidue_rf_out(iray,it_rf) = max(abs(zP_0_2piRp_mod{iray} - zP_0_2piRp_out{iray})./zP_0_2piRp_mod{iray}(1));
            end
            %
            %residue_rf(it_rf) = max([yresidue_rf_mod(:,it_rf);yresidue_rf_out(:,it_rf)]);
            residue_rf(it_rf) = max(yresidue_rf_mod(:,it_rf));
            %
            if display.display_mode >= 1,
                figure(Fig_QLIter),
                [ax] = graph1D_jd(1:it_rf,residue_rf,0,1,'Iteration number','\DeltaP/P','Quasilinear convergence',NaN,[0,nit_rf],[dkeparam_out.prec_rf,1],'none','+','r',2);
                grid  on
                drawnow;                
%             
                if display.display_mode >= 2,
                    for iray = 1:length(zS),
                        figure(Fig_Pray + iray - 1);clf
                        [ax] = graph1D_jd(zS{iray},zP_0_2piRp_mod_old{iray},0,0,'','P_{LH}/2\piR_p (W/m)',['QL convergence, ray #',int2str(iray)],NaN,'','','--','none','r',2);
                        [ax] = graph1D_jd(zS{iray},zP_0_2piRp_mod{iray},0,0,'','P_{LH}/2\piR_p (W/m)',['QL convergence, ray #',int2str(iray)],NaN,'','','-','none','r',2);
                        legend(['Iteration #',int2str(it_rf-1)],['Iteration #',int2str(it_rf)])
                        title(['Ray #',num2str(iray),', residue: ',num2str(max([yresidue_rf_mod(iray,it_rf);yresidue_rf_out(iray,it_rf)]))])
                        grid on
                        drawnow;
                    end
                end
            end
%
            if display.display_mode >=1,
                info_dke_yp(2,'---------------------------------------------------------');
                info_dke_yp(2,['Quasilinear iteration : ',int2str(it_rf),', Residu = ',num2str(residue_rf(it_rf)),', delta_rt = ',num2str(delta_rt)]);
                info_dke_yp(2,'---------------------------------------------------------');
            end
%  
            if (residue_rf(it_rf) <= dkeparam_out.prec_rf & redfac == 1 & it_rf > 1 & conv == 1) | it_rf == nit_rf,
                %
                dke_warnings = '';               
                if isfield(dkeparam_out,'abs_lim') && abs_frac < dkeparam_out.abs_lim,
                    dke_warnings = warning('The RF power is not fully absorbed. To bypass this error set dkeparam.abs_lim between 0 and 1')
                end
                %
                if residue_rf(it_rf) <= dkeparam_out.prec_rf & redfac == 1 & it_rf > 1 & conv == 1,
                    if display.display_mode >=1,info_dke_yp(2,['Successfull convergence achieved for ray-tracing coupling after ',int2str(it_rf),' iterations !']);end
                    break
                else
                    info_dke_yp(2,['WARNING: convergence for ray-tracing coupling was not achieved after ',int2str(it_rf),' iterations !']);                  
                end
            else   	
                if display.display_mode >=1,info_dke_yp(2,['Iteration ',int2str(it_rf),', residue = ',num2str(residue_rf(it_rf))]);end       
            end
			if (residue_rf(it_rf) <= dkeparam_out.prec_rf & redfac == 1 & it_rf > 1 & conv == 0),
				conv = 1;
            end		
            if isfield(dkeparam_out,'finsert') && dkeparam_out.finsert == 1,
                XXfin = XXf0;
                abs_frac_rf(it_rf) = abs_frac;
            end
        end     
    end
end
%
[ZP0,Zcurr,Znorm,ZXXS,XxRR_fsav,xMRR_flux,xMRR_tau,xRR_fsav,xne_norm_out,xTe_norm_out,xft_fsav,xfteff_fsav] = ...
    fmoments_dke_yp(dkepath,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi,waveparam,radial_mode,Zdelta,XXsinksource,...
    XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
    ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod_old,gridindex_rf,...
    ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,XXILor);%Calculate moments of the distribution function
%   RF wave quasilinear diffusion
%
if ~isstruct(waveparam) & ~isempty(waveparam.bomega_rf),%In the case of RF waves and quasilinear iteration
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
if display.display_mode >= 1,
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
    [ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = efield_dke_jd(dkepath,dkeparam_out,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef,'',ZXXF_c);%No Ohmic electric field
    %
    [ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp,ylist_rf] = rfdiff_dke_jd(dkeparam_out,display,waveparam_bc,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa);% RF wave flux coefficients
    [MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,Zpn2_t,sm_f,sm_g,sm_tp] = matrixcalc_dke_yp(dkeparam_out,display,gridDKE,equilDKE,Zbouncecoef,mksa,Zmripple,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXILor,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp);%Build the 3D DKE matrix
    [XXf0_bc,XXf0_bc_tp,XXf0_bc_g,XXf0_bc_L_tp,XXf0_bc_L_g,memoryLU_bc_f,memoryLU_bc_g] = solver_dke_yp(dkepath,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,Zpn2_t,sm_f,sm_g,sm_tp,it_rf,MMXR_f_t,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,XXILor,XXsinksource,XXfinit);% Solve the DKE equation
    [ZP0_bc,Zcurr_bc,Znor_bcm,ZXXS_bc,ZYXXD_bc_rf,XxRR_bc_fsav,xMRR_bc_flux,xMRR_bc_tau,xRR_bc_fsav,xne_norm_bc_out_bc,xTe_norm_bc_out,xft_bc_fsav,xfteff_bc_fsav] = fmoments_dke_yp(dkepath,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,[],radial_mode,Zdelta,XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,ZXXD_rf,ZXXD_rf_tp,ZXXF_rf_tp,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp);%Calculate moments of the distribution function
%
    time_bc_out = etime(clock,time0_bc);
    memoryLU_bc_f_out = memoryLU_bc_f;
    memoryLU_bc_g_out = memoryLU_bc_g;
%
    if display.display_mode >= 1,
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
dke_out.XXf0_g = XXf0_g;
dke_out.normf0 = normf0;
dke_out.curr0 = curr0;
dke_out.residu_f = residu_f;
dke_out.ZXXS = ZXXS;
dke_out.ZXXD_c = ZXXD_c;
dke_out.ZXXF_c = ZXXF_c;
dke_out.ZXXD_e = ZXXD_e;
dke_out.ZXXF_e = ZXXF_e;
dke_out.ZXXD_rf = ZXXD_rf;
dke_out.ZXXF_rf = ZXXF_rf;
dke_out.ZXXD_a = ZXXD_a;
dke_out.ZXXF_a = ZXXF_a;
dke_out.gridindex_rf = gridindex_rf;
dke_out.XxRR_fsav = XxRR_fsav;
dke_out.xMRR_flux = xMRR_flux;
dke_out.xMRR_tau = xMRR_tau;
dke_out.xTe_norm_out = xTe_norm_out;
dke_out.xne_norm_out = xne_norm_out;
dke_out.xft_fsav = xft_fsav;
dke_out.xfteff_fsav = xfteff_fsav;
dke_out.memoryLU_f_out = memoryLU_f_out;
dke_out.memoryLU_g_out = memoryLU_g_out;
dke_out.time_out = time_out;
dke_out.time_DKE = time_DKE;
dke_out.waveparam = waveparam;
dke_out.xyprop_dke = xyprop_dke;
dke_out.xyP0_2piRp_mod = xyP0_2piRp_mod_old;
dke_out.xys = xys;
if strcmp(waveparam.model,'RT') & ~isempty(waveparam.bomega_rf) & nit_rf > 1,
    dke_out.yresidue_rf_mod = yresidue_rf_mod;
    dke_out.yresidue_rf_out = yresidue_rf_out;
    dke_out.residue_rf = residue_rf;
    dke_out.zS = zS;
    dke_out.zP_0_2piRp_mod = zP_0_2piRp_mod_old;
end
dke_out.yb = yb;
dke_out.XXsource = XXsinksource_in;
dke_out.xRR_fsav = xRR_fsav;
dke_out.Zmripple = Zmripple;
%
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
savefields_radialDKE = {'xrho_S_dke','xpsin_f','xpsin_f_dke','xdpsin_f_dke','xpsin_S_dke','r_dke'};
savefields_momentumDKE = {'pn','pnp','pn_S','dpn','mhu','mhu_S','dmhu'};
savefields_gridDKE = {'X1mmhu2','xmhubounce2'};
savefields_Zmomcoef = {'gamma','v'};
savefields_Zbouncecoef = {'xq','xqtilde','xqbar','xqhat','XXheaviside','Xxlambda'};
savefields_Zmripple = {'XXlossripple','xdeltaripple','xNq','Xnhuloss','xthetabanana','xthetaloss','xpndetrap','xpnth','xEseuil'};
%
radialDKE = selectfields_jd(radialDKE,savefields_radialDKE);
momentumDKE = selectfields_jd(momentumDKE,savefields_momentumDKE);
gridDKE = selectfields_jd(gridDKE,savefields_gridDKE);
Zmomcoef = selectfields_jd(Zmomcoef,savefields_Zmomcoef);
Zbouncecoef = selectfields_jd(Zbouncecoef,savefields_Zbouncecoef);
Zmripple = selectfields_jd(Zmripple,savefields_Zmripple);
%
rmdir(dkepath.temppath);%Remove calculation directory
%
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