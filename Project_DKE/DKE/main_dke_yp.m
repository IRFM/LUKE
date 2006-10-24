function [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam_in,display,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
%
%  Main function of the 3-D relativistic bounce-averaged electron drift kinetic equation solver 
%  for the RF wave absorption problem in presence of an Ohmic electric field (electron bootstrap current consistent with non-Maxwellian distribution)
%  Small banana width approximation
%  Arbitrary axisymmetric plasma equilibrium (linked arbitrary tokamak magnetic equilibrium code, via mexfile)
%  Plasma current, RF power absorption, runaway rate, magnetic ripple loss and fast electron bremsstrahlung calculations
%  See dke_1_4yp.m
%
%by Y.Peysson (CEA-DRFC) <yves.peysson@cea.fr> and J. Decker (MIT/RLE) <joan.decker@cea.fr>
%
if nargin < 12,
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
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_dkeparam_out.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_dkeparam_out.mat']);
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_dkeparam_out.mat reloaded.']);
else
   [dkeparam_out] = paramconsistency_dke_yp(dkeparam_in,psin_S,rho_S);%Check consistency between input parameters 
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',equil.id,'_dkeparam_out.mat']);end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_radialDKE.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_radialDKE.mat'],'radialDKE');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_radialDKE.mat reloaded.']);
else
   [radialDKE] = radialgrid_dke_jd(equil,dkeparam_out,display,psin_S,rho_S);%Radial grid for DKE
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_radialDKE.mat'],'radialDKE');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_equilDKE.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_equilDKE.mat'],'equilDKE');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_equilDKE.mat reloaded.']);
else
   [equilDKE] = equilibrium_jd(equil,radialDKE,display,'spline',10);%Magnetic equilibrium for DKE
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_equilDKE.mat'],'equilDKE');end
end
%   
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_momentumDKE.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_momentumDKE.mat'],'momentumDKE');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_momentumDKE.mat reloaded.']);
else   
   [momentumDKE] = momentumgrid_dke_jd(dkeparam_out,equilDKE,radialDKE);%Momentum space 2D grid for DKE
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_momentumDKE.mat'],'momentumDKE');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_gridDKE.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_gridDKE.mat'],'gridDKE');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_gridDKE.mat reloaded.']);
else   
   [gridDKE] = matrix3Dgridbuilder_dke_yp(dkeparam_out,display,equilDKE,radialDKE,momentumDKE);%General grid structure for the DKE solver
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_gridDKE.mat'],'gridDKE');end
end
%   
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_mksa.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_mksa.mat'],'mksa');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_mksa.mat reloaded.']);
else   
   [mksa] = mksacoefbuilder_dke_yp(dkeparam_out,display,equilDKE,radialDKE,momentumDKE,gridDKE);%MKSA quantities calculations
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_mksa.mat'],'mksa');end
end
%   
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_Zmomcoef.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_Zmomcoef.mat'],'Zmomcoef');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_Zmomcoef.mat reloaded.']);
else   
   [Zmomcoef] = momentumcoefbuilder_dke_yp(gridDKE,mksa);%Momentum space coefficients for FP calculations
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_Zmomcoef.mat'],'Zmomcoef');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_Zbouncecoef.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_Zbouncecoef.mat'],'Zbouncecoef');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_Zbouncecoef.mat reloaded.']);
else   
   [Zbouncecoef] = bouncecoefbuilder_dke_yp(path,dkeparam_out,display,equilDKE,gridDKE);%bounce averaging coefficients
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_Zbouncecoef.mat'],'Zbouncecoef');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_rfwave.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_rfwave.mat'],'waveparam','xyprop_dke','xyPinc_in','yb','xys');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_rfwave.mat reloaded.']);
else   
   [waveparam,xyprop_dke,xyPinc_in,yb,xys] = rfwave_dke_jd(dkeparam_out,display,equil,equilDKE,gridDKE,mksa,waves);%RF wave parameters preprocessing calculations
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_rfwave.mat'],'waveparam','xyprop_dke','xyPinc_in','yb','xys');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_XXsinksource.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_XXsinksource.mat'],'XXsinksource');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_XXsinksource.mat reloaded.']);
else   
   [XXsinksource] = sinksourcecoeffbuilder_dke_yp(dkeparam_out,display,equil,equilDKE,gridDKE,mksa,XXsinksource_in);%External sink and source contributions (for right-hand side part of the FP equation)
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_XXsinksource.mat'],'XXsinksource');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_Zmripple.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_Zmripple.mat'],'Zmripple');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_Zmripple.mat reloaded.']);
else   
   [Zmripple] = mripplecoefbuilder_dke_yp(dkeparam_out,display,equil,equilDKE,gridDKE,mksa,ripple);%Magnetic ripple matrix coefficients
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_Zmripple.mat'],'Zmripple');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_rad_dke.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_rad_dke.mat'],'MMXR_f_t','Xmask_r_edge');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_rad_dke.mat reloaded.']);
else   
   [MMXR_f_t,Xmask_r_edge] = rad_dke_yp(path,dkeparam_out,display,equilDKE,gridDKE,mksa,Zbouncecoef,Zmomcoef,transpfaste);%Radial transport super matrix
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_rad_dke.mat'],'MMXR_f_t','Xmask_r_edge');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_coll_dke.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_coll_dke.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','XXILor');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_coll_dke.mat reloaded.']);
else   
   [ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,XXILor] = coll_dke_jd(path,dkeparam_out,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef);%Collisions flux coefficients 
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_coll_dke.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','XXILor');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_efield_dke.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_efield_dke.mat'],'ZXXD_e','ZXXF_e','ZXXD_e_tp','ZXXF_e_tp','xepsi','xEfield_validity');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_efield_dke.mat reloaded.']);
else   
   [ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = efield_dke_jd(path,dkeparam_out,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef,ohm,ZXXF_c);%Electric field flux coefficients
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_efield_dke.mat'],'ZXXD_e','ZXXF_e','ZXXD_e_tp','ZXXF_e_tp','xepsi','xEfield_validity');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_rfdiff_dke.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_rfdiff_dke.mat'],'ZXYD_rf','ZXYD_rf_tp','ZXYF_rf_tp','gridindex_rf');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_rfdiff_dke.mat reloaded.']);
else   
   [ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,gridindex_rf] = rfdiff_dke_jd(dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,radialDKE,waveparam);%RF waves flux coefficients
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_rfdiff_dke.mat'],'ZXYD_rf','ZXYD_rf_tp','ZXYF_rf_tp','gridindex_rf');end
end
%
if dkeparam_in.opt_load*exist(['temp',filesep,'DKE_TEMP_',id_simul,'_finit_dke.mat']),
	load(['temp',filesep,'DKE_TEMP_',id_simul,'_finit_dke.mat'],'XXfinit');
    info_dke_yp(2,['File temp',filesep,'DKE_TEMP_',id_simul,'_finit_dke.mat reloaded.']);
else   
   [XXfinit] = finit_dke_yp(dkeparam_out,display,equilDKE,gridDKE,mksa,Zmomcoef,waveparam,XXf0_in);%Initial distribution function
   if dkeparam_in.opt_save,save(['temp',filesep,'DKE_TEMP_',id_simul,'_finit_dke.mat'],'XXfinit');end
end
%
% --------------------------------- Solve the electron drift kinetic --------------------------------
%
time0 = clock;
%
if ~isempty(waveparam),%initialization of wave parameters  
    xyD0_rf_in = waveparam(:,:,4);%initial value of the constant diffusion coefficient
    delta_rt = dkeparam_out.delta_rt;%smoothering parameter of quasilinear iterations
    %
    % initial absorbed power density estimate: either none or from linear model if calculated
    %
    if sum(sum(isnan(waveparam(:,:,13)))),
       xyPabs_rf_dke_fsav_mksa = 0;
    else
       xyPabs_rf_dke_fsav_mksa = waveparam(:,:,13).*waveparam(:,:,4).*waveparam(:,:,1)*mksa.wmabs2;
    end
    %    
    % initial power flow along the ray, calculated from xyPabs_rf_dke_fsav_mksa
    %
    [xyPinc_out,xyPinc_mod] = rfprop_dke_jd(yb,xyprop_dke,xyPinc_in,xyPabs_rf_dke_fsav_mksa,equilDKE.xdV_dke,gridDKE.xpsin,gridDKE.xpsin_dke,gridDKE.rdke,dkeparam_out.dke_mode);
    %
    xyPinc_mod_old = xyPinc_in;
    xymask = (xyPinc_in == 0);
    xyPinc_in(xymask) = eps; %to avoid singularities
    nit_rf = dkeparam_out.nit_rf;
    if nit_rf > 1 & display.display_mode >= 1,Fig_QLIter = figure('Name','Quasilinear iteration');end
else
    nit_rf = 1;
    xyPinc_mod = '';
    xyPinc_mod_old = '';
end  
%
residue_rf = [];
%
for it_rf=1:nit_rf % convergence in the ray-tracing mode
    if ~isempty(waveparam),%in the case of RF waves only
        %
        if it_rf > 1,%1,
            xyPinc_mod = delta_rt*xyPinc_mod_old + (1 - delta_rt)*xyPinc_mod;
        end
        %
        xyD0_rf_mod = xyD0_rf_in.*xyPinc_mod./xyPinc_in;% The diffusion coefficient is proportional to the incident power
        %
        if 0,%nit_rf > 1,
            if it_rf == 1,
                redfac = max(sum(xyPinc_mod.'))/sum(max(xyPinc_in(:,yb)));
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
        xyD0_rf = xyD0_rf_mod./redfac;
    else
        xyD0_rf = zeros(gridDKE.nr,0);
    end     
%
    [ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp] = raysum_rf_jd(dkeparam_out,ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyD0_rf,gridindex_rf);
    [Zdelta,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,Zpn2_t,sm_f,sm_g,sm_tp] = matrixcalc_dke_yp(dkeparam_out,display,gridDKE,equilDKE,Zbouncecoef,mksa,Zmripple,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXILor,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp,Xmask_r_edge);%Build the 3D DKE matrix
    [XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,radial_mode,memoryLU_f,memoryLU_g] = solver_dke_yp(path,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,Zpn2_t,sm_f,sm_g,sm_tp,it_rf,MMXR_f_t,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,XXILor,Xmask_r_edge,XXsinksource,XXfM,XXfinit);% Solve the DKE equation
%
    if ~isempty(waveparam),%In the case of RF waves and quasilinear iteration
        if nit_rf > 1,  
            %
            % Calculation of the density of power absorbed for all rays
            %
            [ZP0] = fmoments_dke_yp(path,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi,waveparam,radial_mode,Zdelta,XXsinksource,...
                XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
                ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyD0_rf,gridindex_rf);%Calculate RF absorbed power of the distribution function
            if dkeparam_out.dke_mode >= 1,
                xyPabs_rf_dke_fsav_out = ZP0.xy_rf_fsav + ZP0.xy_rf_tp_fsav + ZP0.xy_rf_g_fsav; % flux-surface averaged density of absorbed power.
            else
                xyPabs_rf_dke_fsav_out = ZP0.xy_rf_fsav; % flux-surface averaged density of absorbed power.
            end	    
            xyPabs_rf_dke_fsav_mksa = xyPabs_rf_dke_fsav_out*mksa.P_ref*1e6;%RF power (W)
            if nit_rf > 1,
                xyPabs_rf_dke_fsav_mksa = xyPabs_rf_dke_fsav_mksa*redfac;
            end
            %
            % Calculation of the power flow along the rays from DKE calculations
            %
            xyPinc_mod_old = xyPinc_mod;
            %
            [xyPinc_out,xyPinc_mod] = rfprop_dke_jd(yb,xyprop_dke,xyPinc_mod_old,xyPabs_rf_dke_fsav_mksa,equilDKE.xdV_dke,gridDKE.xpsin,gridDKE.xpsin_dke,gridDKE.rdke,dkeparam_out.dke_mode);
            %
            residue_rf(it_rf) = max(max(abs(xyPinc_mod - xyPinc_mod_old)./xyPinc_in));
            %
            if display.display_mode >= 1,figure(Fig_QLIter),plot(1:it_rf,residue_rf,'r+'),set(gca,'yscale','log'),axis([0,nit_rf,1e-5,1]),drawnow;end
            %
            if display.display_mode >=1,
               info_dke_yp(2,'---------------------------------------------------------');
               info_dke_yp(2,['Quasilinear iteration : ',int2str(it_rf),', Residu = ',num2str(residue_rf(it_rf)),', delta_rt = ',num2str(delta_rt)]);
               info_dke_yp(2,'---------------------------------------------------------');
            end
            %
%      
            if residue_rf(it_rf) <= dkeparam_out.prec_rf & redfac == 1 & it_rf > 1,
            	 if display.display_mode >=1,info_dke_yp(2,['Successfull convergence achieved for ray-tracing coupling after ',int2str(it_rf),' iterations !']);end
                break
            else   	
               if display.display_mode >=1,info_dke_yp(2,['Iteration ',int2str(it_rf),', residue = ',num2str(residue_rf(it_rf))]);end       
            end
        end
    end
end
%
[ZP0,Zcurr,Znorm,ZXXS,XxRR_fsav,xMRR_flux,xMRR_tau,xRR_fsav,xne_norm_out,xTe_norm_out,xft_fsav,xfteff_fsav] = ...
    fmoments_dke_yp(path,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi,waveparam,radial_mode,Zdelta,XXsinksource,...
    XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
    ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyD0_rf,gridindex_rf,...
    ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,XXILor);%Calculate moments of the distribution function
%   RF wave quasilinear diffusion
%
if ~isempty(waveparam),%In the case of RF waves and quasilinear iteration
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
    [ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = efield_dke_jd(path,dkeparam_out,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef,'',ZXXF_c);%No Ohmic electric field
    %
    [ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp,ylist_rf] = rfdiff_dke_jd(dkeparam_out,display,waveparam_bc,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa);% RF wave flux coefficients
    [MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,Zpn2_t,sm_f,sm_g,sm_tp] = matrixcalc_dke_yp(dkeparam_out,display,gridDKE,equilDKE,Zbouncecoef,mksa,Zmripple,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXILor,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp);%Build the 3D DKE matrix
    [XXf0_bc,XXf0_bc_tp,XXf0_bc_g,XXf0_bc_L_tp,XXf0_bc_L_g,memoryLU_bc_f,memoryLU_bc_g] = solver_dke_yp(path,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,Zpn2_t,sm_f,sm_g,sm_tp,it_rf,MMXR_f_t,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,XXILor,XXsinksource,XXfinit);% Solve the DKE equation
    [ZP0_bc,Zcurr_bc,Znor_bcm,ZXXS_bc,ZYXXD_bc_rf,XxRR_bc_fsav,xMRR_bc_flux,xMRR_bc_tau,xRR_bc_fsav,xne_norm_bc_out_bc,xTe_norm_bc_out,xft_bc_fsav,xfteff_bc_fsav] = fmoments_dke_yp(path,dkeparam_out,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,[],radial_mode,Zdelta,XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,ZXXD_rf,ZXXD_rf_tp,ZXXF_rf_tp,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp);%Calculate moments of the distribution function
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
dke_out.XXf0_tp = XXf0_tp;
dke_out.XXf0_g = XXf0_g;
dke_out.XXf0_L_tp = XXf0_L_tp;
dke_out.XXf0_L_g = XXf0_L_g;
dke_out.ZXXS = ZXXS;
dke_out.ZXYD_rf = ZXYD_rf;
dke_out.ZXYD_rf_tp = ZXYD_rf_tp;
dke_out.ZXYF_rf_tp = ZXYF_rf_tp;
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
dke_out.waveparam = waveparam;
dke_out.xyprop_dke = xyprop_dke;
dke_out.xyPinc_in = xyPinc_in;
dke_out.xyPinc_mod = xyPinc_mod_old;
dke_out.xys = xys;
dke_out.residue_rf = residue_rf;
dke_out.yb = yb;
dke_out.XXsource = XXsinksource_in;
dke_out.xRR_fsav = xRR_fsav;
dke_out.Zmripple = Zmripple;
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
    dke_out.xTe_norm_bc_out = xne_norm_bc_out;
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
    dke_out.xTe_norm_bc_out = [];
    dke_out.xTe_norm_bc_out = [];
    dke_out.xft_bc_fsav = [];
    dke_out.xfteff_bc_fsav = [];
    dke_out.memoryLU_bc_g_out = [];
    dke_out.memoryLU_bc_f_out = [];
    dke_out.time_bc_out = [];
    dke_out.xRR_bc_fsav = [];
end
%



