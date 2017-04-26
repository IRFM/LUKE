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
    [dkeparam_out,radialDKE,equilDKE,momentumDKE,gridDKE,mksa,Zmomcoef,Zbouncecoef,...
        XXsinksource,Zmripple,XXSavalanches_norm,xnrem_init,xnrep_init,xrr_out_norm,...
        ZXXD_a,ZXXF_a,...
        ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,XXILor,...
        ZXXD_e_init,ZXXF_e_init,ZXXD_e_tp,ZXXF_e_tp,xepsi_init,xEfield_validity,...
        ZXXD_s,ZXXF_s,ZXXD_s_tp,ZXXF_s_tp,...
        waveparam,xyprop_dke,xyP0_2piRp_mod,xyP0_2piRp_mod_coll,xyP0_2piRp_mod_noabs,yb,yP0_2piRp,xys,...
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
    xcurr_rem = cell(1,nit);
    xcurr_rep = cell(1,nit);
    xcurr = cell(1,nit);
    residu_f = cell(1,nit);
    XXf0 = cell(1,nit);
    zP_0_2piRp_mod_old = cell(nit_rf,nit);
    xepsi = cell(1,nit);
    xnorm_0 = cell(1,nit);
    xnorm_rem = cell(1,nit);
    xnorm_rep = cell(1,nit);
    xnorm_rim = cell(1,nit);
    xnorm_rip = cell(1,nit);
    XXRintmask = cell(1,nit);
    %
    if dkeparam_out.timevol == 1,
    %     ZP0 = cell(1,nit);
    %     Zf0_interp = cell(1,nit);
    %     Zcurr = cell(1,nit);
    %     Znorm = cell(1,nit);
    %     Zmom = cell(1,nit);
        XxRR_fsav = cell(1,nit);
        xMRR_flux = cell(1,nit);
        xMRR_tau = cell(1,nit);
        xMRR_power_flux = cell(1,nit);
        xMRR_power_tau = cell(1,nit);
        xRRm_fsav = cell(1,nit);
        xRRp_fsav = cell(1,nit);
        xne_norm_out = cell(1,nit);
        xTe_norm_out = cell(1,nit);
        xft_fsav = cell(1,nit);
        xfteff_fsav = cell(1,nit);        
        %
    elseif dkeparam_out.timevol == 2,
    %     ZP0 = cell(nit_rf,nit);
    %     Zf0_interp = cell(nit_rf,nit);
    %     Zcurr = cell(nit_rf,nit);
    %     Znorm = cell(nit_rf,nit);
    %     Zmom = cell(nit_rf,nit);
        XxRR_fsav = cell(nit_rf,nit);
        xMRR_flux = cell(nit_rf,nit);
        xMRR_tau = cell(nit_rf,nit);
        xMRR_power_flux = cell(nit_rf,nit);
        xMRR_power_tau = cell(nit_rf,nit);
        xRRm_fsav = cell(nit_rf,nit);
        xRRp_fsav = cell(nit_rf,nit);
        xne_norm_out = cell(nit_rf,nit);
        xTe_norm_out = cell(nit_rf,nit);
        xft_fsav = cell(nit_rf,nit);
        xfteff_fsav = cell(nit_rf,nit);
        %
    end
    %
    itn0 = 1;
    XXfin = XXfinit;
    xepsi_in = xepsi_init;
    %
    xqtilde = Zbouncecoef.xqtilde(gridDKE.rdke);
    xqhat = Zbouncecoef.xqhat(gridDKE.rdke);
    xq = Zbouncecoef.xq(gridDKE.rdke);
    xqbar = Zbouncecoef.xqbar(gridDKE.rdke);
    XXlambda = Zbouncecoef.XXlambda(:,:,gridDKE.rdke);
    %
    dpn = gridDKE.dpn;
    dmhu = gridDKE.dmhu;
    XXpn2 = gridDKE.XXpn2(:,:,gridDKE.rdke);
    XXpn = gridDKE.XXpn(:,:,gridDKE.rdke);
    XXmhu = gridDKE.XXmhu(:,:,gridDKE.rdke);
    %
    XXgamma = Zmomcoef.XXgamma(:,:,gridDKE.rdke);
    %
    % Internal RE domain
    %
    % TODO : - calculate the flux through the RR internal boundary
    %
    if isfield(dkeparam_out,'pnmin_S') && isscalar(dkeparam_out.pnmin_S) && ~isnan(dkeparam_out.pnmin_S),% Rfrac calculated from dkeparm.pnmin_S (see Adam's work)
        %
        % partial density above the minimum energy dkeparam.pnmin_S (typically used in runaway studies)
        %
        XXRintmask_init = gridDKE.XXpn > dkeparam_out.pnmin_S;
    else
        %
        % Rfrac calculated from internal RR boundary based on force balance
        %
        XXRintmask_init = ZXXF_c.p_ij + ZXXF_e_init.p_ij + ZXXF_s.p_ij > 0;% internal runaways from force balance
    end
    %
    % initial f0 normalized density
    %
    xnorm_0_init = 2*pi*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*XXfin(:,:,gridDKE.rdke).*XXpn2,1),1).';
    %
    % initial internal source runaway normalized density
    %
    XXRmaskmin0_KOm = gridDKE.XXpn > dkeparam_out.pnmin0_KO & gridDKE.XXmhu < 0;
    XXRmaskmin0_KOp = gridDKE.XXpn > dkeparam_out.pnmin0_KO & gridDKE.XXmhu > 0;
    %
    xnorm_rim_init = 2*pi*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*XXRmaskmin0_KOm(:,:,gridDKE.rdke).*XXfin(:,:,gridDKE.rdke).*XXpn2,1),1).';
    xnorm_rip_init = 2*pi*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*XXRmaskmin0_KOp(:,:,gridDKE.rdke).*XXfin(:,:,gridDKE.rdke).*XXpn2,1),1).';
    %
    % In frozen current mode, LUKE assumes that the current is frozen to either :
    %   - a prescribed scalar value (dkeparam_out.Itot_ohm) assuming a uniform electric field  
    %   - a prescribed profile (dkeparam_out.Jtot_ohm)
    %   - its original value calculated from the initial distribution and number of runaways (beyond pmax)
    %       (It is assumed that the initial distribution function was calculated with the input value for the ohmic field)
    %
    if dkeparam_out.nit_ohm > 1 && isnan(dkeparam_out.Itot_ohm),% frozen current mode with current profile specified
        %
        if ~any(isnan(dkeparam_out.Jtot_ohm)),% prescribed current specified by dkeparam_out.Jtot_ohm on the grid dkeparam_out.rho_ohm
            %
            if length(dkeparam_out.rho_ohm) == 1,
                xcurr_init = dkeparam_out.Jtot_ohm/mksa.j_ref;%Normalized current
            else
                xcurr_init = interp1(dkeparam_out.rho_ohm,dkeparam_out.Jtot_ohm,equilDKE.xrho,'spline')/mksa.j_ref;%Normalized current
            end
            %        
        else % prescribed current specified by xnre_init and XXfin
            %
            % runaways beyond pmax are assumed to have a parallel velocity equal to the speed of light 
            %
            %
            % initial runaway current
            %
            xcurr_rem_init = - (xq./xqbar).*(xqhat./xqtilde).*xnrem_init/mksa.betath_ref;
            xcurr_rep_init =   (xq./xqbar).*(xqhat./xqtilde).*xnrep_init/mksa.betath_ref;
            %
            % initial f0 current
            %
            xcurr_0 = 2*pi*(xq./xqbar).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXfin(:,:,gridDKE.rdke).*XXpn2.*XXpn.*XXmhu./XXgamma,1),1).';
            %
            xcurr_init = xcurr_rem_init + xcurr_rep_init + xcurr_0;
            %
        end
    end
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
flag_exit = false;
%
for itn = itn0:nit,
    %
    dkeparam_out.dtn = dtn_list(itn);
    %
    % The internal and external avalanche terms are proportional to both the runaway fraction and
    % the bulk fraction at time itn-1
    %
    % Note : in the Rosenbluth model, we have to neglect the effect on the incident electron
    %
    [~,xne_norm,~,~,~,xbetath] = normcoef_dke_yp(mksa,equilDKE,gridDKE);
    %    
    if itn == 1,   
        if isnan(dkeparam_out.pnmax1_KO),% count all electrons in bulk except internal runaways
            xnorm_b = xnorm_0_init - xnorm_rim_init;
        elseif dkeparam_out.pnmax1_KO == 0,% count using the value of f(0) - most logical given how the sink term is calculated
            xnorm_b = xne_norm.*reshape(XXfin(1,1,:)./XXfM(1,1,:),[1,gridDKE.nr]);
        elseif imag(dkeparam_out.pnmax1_KO) == 0,% count bulk electrons up to pnmax1_KO normalized to ref temperature
            xnorm_b = 2*pi*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*(XXpn < dkeparam_out.pnmax1_KO).*XXfin(:,:,gridDKE.rdke).*XXpn2,1),1).';
        else% count bulk electrons up to pnmax1_KO normalized to ref temperature
            xnorm_b = 2*pi*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*(XXpn < imag(dkeparam_out.pnmax1_KO)*repmat(reshape(xbetath,[1,1,gridDKE.nr]),[gridDKE.npn,gridDKE.nmhu,1])/mksa.betath_ref).*XXfin(:,:,gridDKE.rdke).*XXpn2,1),1).';
        end
    else
        if isnan(dkeparam_out.pnmax1_KO),% count all electrons in bulk except internal runaways
            xnorm_b = xnorm_0{itn - 1} - xnorm_rim{itn - 1};
        elseif dkeparam_out.pnmax1_KO == 0,% count using the value of f(0) - most logical given how the sink term is calculated
            xnorm_b = xne_norm.*reshape(XXf0{itn - 1}(1,1,:)./XXfM(1,1,:),[1,gridDKE.nr]);
        elseif imag(dkeparam_out.pnmax1_KO) == 0,% count bulk electrons up to pnmax1_KO normalized to ref temperature
            xnorm_b = 2*pi*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*(XXpn < dkeparam_out.pnmax1_KO).*XXf0{itn-1}(:,:,gridDKE.rdke).*XXpn2,1),1).';
        else% count bulk electrons up to pnmax1_KO normalized to ref temperature
            xnorm_b = 2*pi*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*(XXpn < imag(dkeparam_out.pnmax1_KO)*repmat(reshape(xbetath,[1,1,gridDKE.nr]),[gridDKE.npn,gridDKE.nmhu,1])/mksa.betath_ref).*XXf0{itn-1}(:,:,gridDKE.rdke).*XXpn2,1),1).';
        end
    end
    %
    if itn == 1,   
        xnorm_m = (xnrem_init + xnorm_rim_init).*xnorm_b;
        xnorm_p = (xnrep_init + xnorm_rip_init).*xnorm_b;
    else
        xnorm_m = (xnorm_rem{itn - 1} + xnorm_rim{itn - 1}).*xnorm_b;
        xnorm_p = (xnorm_rep{itn - 1} + xnorm_rip{itn - 1}).*xnorm_b;
    end
    %
    XXSavalanches_norm_p = XXSavalanches_norm;
    XXSavalanches_norm_m = flipdim(XXSavalanches_norm,2);
    %
    XXSavalanches_orig = XXSavalanches_norm_m.*repmat(reshape(xnorm_m,[1,1,gridDKE.nr]),[gridDKE.npn,gridDKE.nmhu,1])...% multiple the avalanche source term by the runaway electron density
                  + XXSavalanches_norm_p.*repmat(reshape(xnorm_p,[1,1,gridDKE.nr]),[gridDKE.npn,gridDKE.nmhu,1]);% multiple the avalanche source term by the runaway electron density
    %
    xrr_out_m = xrr_out_norm.*xnorm_m;
    xrr_out_p = xrr_out_norm.*xnorm_p;
    xrr_out = xrr_out_m + xrr_out_p;
    %
    if isnan(dkeparam_out.pnmin2_KO),% count all internal runaways
        if itn == 1,
            XXSavalanches = XXSavalanches_orig.*XXRintmask_init;
        else
            XXSavalanches = XXSavalanches_orig.*XXRintmask{itn-1};
        end
    else
        XXSavalanches = XXSavalanches_orig;
    end
    %
    if itn == 1 && dkeparam_out.finitabs == 1,%The initial distribution is used to first estimate the ray absorption
        conv = -1;
    else
        conv = 0;
    end
    %
    % Convergence on Ohmic field in frozen current mode
    %
    for it_ohm = 1:dkeparam_out.nit_ohm,
        %
        if dkeparam_out.nit_ohm > 1,
            if it_ohm == 1,
                xepsi{itn} = zeros(1,gridDKE.nr);% first iteration without ohmic field
            end
            %
            ZXXD_e = structtimes_jd(ZXXD_e_init,repmat(reshape(xepsi{itn}./xepsi_init,[1,1,gridDKE.nr]),[gridDKE.npn,gridDKE.nmhu,1]));
            ZXXF_e = structtimes_jd(ZXXF_e_init,repmat(reshape(xepsi{itn}./xepsi_init,[1,1,gridDKE.nr]),[gridDKE.npn,gridDKE.nmhu,1]));
            %ZXXD_e_tp = structtimes_jd(ZXXD_e_tp,xepsi{itn}/xepsi_init);
            %ZXXF_e_tp = structtimes_jd(ZXXF_e_tp,xepsi{itn}/xepsi_init);          
            %
        else
            ZXXD_e = ZXXD_e_init;
            ZXXF_e = ZXXF_e_init;
            xepsi{itn} = xepsi_in;
        end
        %
        % Internal RE domain
        %
        % TODO : - calculate the flux through the RR internal boundary
        %
        if isfield(dkeparam_out,'pnmin_S') && isscalar(dkeparam_out.pnmin_S) && ~isnan(dkeparam_out.pnmin_S),% Rfrac calculated from dkeparm.pnmin_S (see Adam's work)
            %
            % partial density above the minimum energy dkeparam.pnmin_S (typically used in runaway studies)
            %
            XXRintmask{itn} = gridDKE.XXpn > dkeparam_out.pnmin_S;
        else
            %
            % Rfrac calculated from internal RR boundary based on force balance
            %
            XXRintmask{itn} = ZXXF_c.p_ij + ZXXF_e.p_ij + ZXXF_s.p_ij > 0;% internal runaways from force balance
        end
        %
        % Convergence on p=0 particle source to compensate for boundary losses
        %
        XXnormsource = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr_dke);
        %
        xRR_fsav_old = 0;
        %
        for it_norm = 1:dkeparam_out.nit_norm,
            %
            % Convergence on RF deposition with ray-tracing formalism
            %
            for it_rf = 1:nit_rf,
            	%
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
                xyP0_2piRp_mod_coll1 = xyP0_2piRp_mod_coll.*xyP0_2piRp_mod./xyP0_2piRp_mod_noabs;%adjust power remaining in fragments including NRCA and RLA
                xyP0_2piRp_mod_coll1(isnan(xyP0_2piRp_mod_coll1)) = 0;
                %
                [ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp] = raysum_rf_jd(dkeparam_out,ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod_coll1/redfac,gridindex_rf);
                [Zdelta,MMXT_f_t,MMXP_f_t,MMXR_f_t,Xmask_r_edge,MMXP_tp,MMXP_g_t,MMH_tp,Zpn2_t,sm_f,sm_g,sm_tp] = matrixcalc_dke_yp(dkeparam_out,dkedisplay,gridDKE,equilDKE,Zbouncecoef,mksa,Zmripple,Zmomcoef,transpfaste,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXILor,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZXXD_s,ZXXF_s,ZXXD_s_tp,ZXXF_s_tp,ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp,ZXXD_a,ZXXF_a);%Build the 3D DKE matrix
                %
                if conv >= 0,
                    [XXf0{itn},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,radial_mode,memoryLU_f,memoryLU_g,time_DKE,normf0{itn},curr0{itn},residu_f{itn}] = solver_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,Zpn2_t,sm_f,sm_g,sm_tp,it_rf,MMXR_f_t,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,XXILor,Xmask_r_edge,XXsinksource + XXnormsource,XXSavalanches,xrr_out,XXfM,XXfin);% Solve the DKE equation
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
                        [ZP0_rf] = fmoments_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi{itn},waveparam,radial_mode,Zdelta,XXsinksource,XXSavalanches,...
                            XXf0{itn},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
                            ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod,gridindex_rf);%Calculate RF absorbed power of the distribution function
                        if dkeparam_out.dke_mode >= 1,
                            xyPabs_rf_dke_fsav_out = ZP0_rf.xy_rf_fsav + ZP0_rf.xy_rf_tp_fsav + ZP0_rf.xy_rf_g_fsav; % flux-surface averaged density of absorbed power.
                        else
                            xyPabs_rf_dke_fsav_out = ZP0_rf.xy_rf_fsav; % flux-surface averaged density of absorbed power.
                        end	    
                    	%
                        xyPabs_rf_dke_fsav_mksa = xyPabs_rf_dke_fsav_out*mksa.P_ref*1e6;%RF power (W)
                        %
                        % Calculation of the power flow along the rays from DKE calculations
                        %
                    	[xyP0_2piRp_out,xyP0_2piRp_mod] = rfprop_dke_jd(yb,yP0_2piRp,xyprop_dke,xyP0_2piRp_mod_old,xyPabs_rf_dke_fsav_mksa,equilDKE.xdV_2piRp_dke,gridDKE.xpsin,gridDKE.xpsin_dke,gridDKE.rdke,dkeparam_out.dke_mode);
                        %
                        zP_0_2piRp_mod_old{it_rf,itn} = raypath_jd(xyP0_2piRp_mod_old,xyprop_dke,yb,radialDKE.r_dke);
                        zP_0_2piRp_mod = raypath_jd(xyP0_2piRp_mod,xyprop_dke,yb,radialDKE.r_dke);
                        zP_0_2piRp_out = raypath_jd(xyP0_2piRp_out,xyprop_dke,yb,radialDKE.r_dke);
                        zP_0_2piRp_mod_coll1{it_rf,itn} = raypath_jd(xyP0_2piRp_mod_coll1,xyprop_dke,yb,radialDKE.r_dke);
                        %
                        P_0_2piRp_in = sum(yP0_2piRp);
                        P_0_2piRp_out = 0;
                    	%
                        for iray = 1:length(yb),
                             P_0_2piRp_out = P_0_2piRp_out + zP_0_2piRp_mod_old{it_rf,itn}{iray}(end);
                        end
                        %
                        abs_frac = (P_0_2piRp_in - P_0_2piRp_out)/P_0_2piRp_in;
                        %
                        for iray = 1:length(yb),
                            yresidue_rf_mod(iray,it_rf) = max(abs(zP_0_2piRp_mod{iray} - zP_0_2piRp_mod_old{it_rf,itn}{iray})./zP_0_2piRp_mod{iray}(1));
                            yresidue_rf_out(iray,it_rf) = max(abs(zP_0_2piRp_mod{iray} - zP_0_2piRp_out{iray})./zP_0_2piRp_mod{iray}(1));
                        end
                        %
                        %residue_rf{itn}(it_rf) = max([yresidue_rf_mod(:,it_rf);yresidue_rf_out(:,it_rf)]);
                        residue_rf{itn}(it_rf) = max(yresidue_rf_mod(:,it_rf));
                        %
                        % Moments of the distribution function
                        %
                        if dkeparam_out.timevol == 2,
                            [ZP0(it_rf,itn),Zcurr(it_rf,itn),Znorm(it_rf,itn),ZXXS,...(itn)
                                XxRR_fsav{it_rf,itn},xMRR_flux{it_rf,itn},xMRR_tau{it_rf,itn},xMRR_power_flux{it_rf,itn},xMRR_power_tau{it_rf,itn},xRRm_fsav{it_rf,itn},xRRp_fsav{it_rf,itn},...
                                xne_norm_out{it_rf,itn},xTe_norm_out{it_rf,itn},xft_fsav{it_rf,itn},xfteff_fsav{it_rf,itn},Zmom(it_rf,itn)] = ...
                                fmoments_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi{itn},waveparam,radial_mode,Zdelta,XXsinksource,XXSavalanches,...
                                XXf0{itn},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
                                ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod_old,gridindex_rf,...
                                ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZXXD_s,ZXXF_s,ZXXD_s_tp,ZXXF_s_tp,XXRintmask{itn},XXILor); %Calculate moments of the distribution function
                        end
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
                                    [ax] = graph1D_jd(zS{iray},zP_0_2piRp_mod_old{it_rf,itn}{iray},0,0,'','P_{LH}/2\piR_p (W/m)',['QL convergence, ray #',int2str(iray)],NaN,'','','--','none','r',2);
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
                            if dkeparam_out.postest_rf && min(min(min(ZP0_rf.xyn_rf_fsav))) < 0,
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
                [ZP0(itn),Zcurr(itn),Znorm(itn),ZXXS,...(itn)
                    XxRR_fsav{itn},xMRR_flux{itn},xMRR_tau{itn},xMRR_power_flux{itn},xMRR_power_tau{itn},xRRm_fsav{itn},xRRp_fsav{itn},...
                    xne_norm_out{itn},xTe_norm_out{itn},xft_fsav{itn},xfteff_fsav{itn},Zmom(itn)] = ...
                    fmoments_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi{itn},waveparam,radial_mode,Zdelta,XXsinksource,XXSavalanches,...
                    XXf0{itn},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
                    ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod_old,gridindex_rf,...
                    ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZXXD_s,ZXXF_s,ZXXD_s_tp,ZXXF_s_tp,XXRintmask{itn},XXILor); %Calculate moments of the distribution function
                %
            end
            %
            % compensation term for boundary losses
            %
            if dkeparam_out.nit_norm > 1,
                %
                xRR_fsav = xRRm_fsav{itn} + xRRp_fsav{itn};
                %
                if all(abs(xRR_fsav) <= abs(dkeparam_out.thres_norm)),% negligible boundary losses
                    if dkedisplay.display_mode >= 1, 
                        disp(['Boundary losses negligible, no p=0 source term is needed at time step ',num2str(itn)])
                    end
                    break
                elseif max(abs(xRR_fsav - xRR_fsav_old)./abs(xRR_fsav)) <= dkeparam_out.tol_norm,
                    if dkedisplay.display_mode >= 1, 
                        disp(['Convergence on p=0 source term reached after ',num2str(it_norm),' iterations at time step ',num2str(itn)])
                    end
                    break
                end
                %
                XXnormsource(1,:,:) = repmat(reshape(xRR_fsav.*xqhat./xqtilde,[1,1,gridDKE.nr_dke]),[1,gridDKE.nmhu,1])./XXlambda(1,:,:)/(4*pi*gridDKE.dpn(1)*gridDKE.pn(1).^2);
                %
                xRR_fsav_old = xRR_fsav;
                %
            end
        end
        %
        if dkeparam_out.nit_norm > 1 && any(abs(xRR_fsav) > abs(dkeparam_out.thres_norm)) && max(abs(xRR_fsav - xRR_fsav_old)./abs(xRR_fsav)) > dkeparam_out.tol_norm,
            disp(['WARNING : Convergence on p=0 source term not reached after ',num2str(it_norm),' iterations at time step ',num2str(itn)])
        end
        %
        if dkeparam_out.timevol == 1,
            %
            % normalization to compensate for numerical errors
            %
            % if imag(dkeparam.norm_mode_f) == 1, particle conservation is enforced but
            % boundary losses are accounted for (including secondary electrons born
            % outside LUKE domain, which are compensated for in solver_dke_yp).
            %
            % with real(dkeparam_out.norm_mode_f) == 0 , this should only compensate for numerical errors. 
            % with real(dkeparam_out.norm_mode_f) == 2 , this should also compensate for boundary losses, which are canceled out in solver_dke_yp. 
            % with real(dkeparam_out.norm_mode_f) == 1 , this option should not be used as the norm of f is enforced to the Maxwellian value
            %
            if Znorm(itn).x_0_fsav < 0,
                disp('WARNING : negative norm of the electron distribution')
                flag_exit = true;
            end
            %
            if ~flag_exit && imag(dkeparam_out.norm_mode_f) == 1,
                %
                if itn == 1,
                    xnorm_0_last = xnorm_0_init;% LUKE edf normalization at previous step
                else
                    xnorm_0_last = xnorm_0{itn - 1};% LUKE edf normalization at previous step
                end
                %
                xnorm_0_corr = xnorm_0_last - (xrr_out_m + xrr_out_p)*dtn_list(itn) + xne_norm_out{itn};% subtract avalanches RE created outside LUKE domain, plus other sources/sinks
                dxnorm_flux = (xRRm_fsav{itn} + xRRp_fsav{itn} - xRR_fsav_old)*dtn_list(itn);% RE leaving LUKE domain (possibly corrected by compensation)
                %
                % this expressions derive from the fact that xRR_fsav{itn} is itself proportional to f
                %
                % it brings first order corrections to the approximate expression :
                %   Znorm(itn).xnorm_fac = Znorm(itn).x_0_fsav./(xnorm_0_corr - dxnorm_flux);
                %
%                 xnorm_fac = Znorm(itn).x_0_fsav./xnorm_0_corr.*(1 + Znorm(itn).x_0_fsav.*dxnorm_flux./xnorm_0_corr.^2);
                xnorm_fac = (Znorm(itn).x_0_fsav + dxnorm_flux)./xnorm_0_corr;
                %
                % renormalize f moments accordingly
                %
                [XXf0{itn},ZP0(itn),Zcurr(itn),Znorm(itn),ZXXS,...
                        XxRR_fsav{itn},xMRR_flux{itn},xMRR_tau{itn},xMRR_power_flux{itn},xMRR_power_tau{itn},xRRm_fsav{itn},xRRp_fsav{itn},xTe_norm_out{itn},Zmom(itn)] = ...
                    renorm_fmoments_jd(xnorm_fac,equilDKE,mksa,...
                        XXf0{itn},ZP0(itn),Zcurr(itn),Znorm(itn),ZXXS,...
                        XxRR_fsav{itn},xMRR_flux{itn},xMRR_tau{itn},xMRR_power_flux{itn},xMRR_power_tau{itn},xRRm_fsav{itn},xRRp_fsav{itn},xTe_norm_out{itn},Zmom(itn));
                %
            end
            %
            xnorm_0{itn} = Znorm(itn).x_0_fsav;
            %
            % the external runaway increment is the sum of :
            %   - the runaways created outside pmax
            %   - the runaways passing through pmax
            %
            dxnorm_rem = (xrr_out_m + xRRm_fsav{itn})*dtn_list(itn);
            dxnorm_rep = (xrr_out_p + xRRp_fsav{itn})*dtn_list(itn);
            %
%             xnorm_ri{itn} = Znorm(itn).x_Rfrac_0_fsav;
            xnorm_rim{itn} = 2*pi*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*XXRmaskmin0_KOm(:,:,gridDKE.rdke).*XXf0{itn}(:,:,gridDKE.rdke).*XXpn2,1),1).';
            xnorm_rip{itn} = 2*pi*(xqtilde./xqhat).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda.*XXRmaskmin0_KOp(:,:,gridDKE.rdke).*XXf0{itn}(:,:,gridDKE.rdke).*XXpn2,1),1).';
            %
        else
            %
            dxnorm_rem = zeros(1,gridDKE.nr);
            dxnorm_rep = zeros(1,gridDKE.nr);
            %
%             xnorm_ri{itn} = 0;
            xnorm_rim{itn} = 0;
            xnorm_rip{itn} = 0;
            %
        end
        %
        if itn == 1,
            xnorm_rem{itn} = xnrem_init + dxnorm_rem;
            xnorm_rep{itn} = xnrep_init + dxnorm_rep;
        else
            xnorm_rem{itn} = xnorm_rem{itn - 1} + dxnorm_rem;
            xnorm_rep{itn} = xnorm_rep{itn - 1} + dxnorm_rep;
        end                
        %
        % runaway current
        %
        xcurr_rem{itn} = - (xq./xqbar).*(xqhat./xqtilde).*xnorm_rem{itn}/mksa.betath_ref;
        xcurr_rep{itn} =   (xq./xqbar).*(xqhat./xqtilde).*xnorm_rep{itn}/mksa.betath_ref;
        %
        % initial f0 current
        %
        xcurr_0 = 2*pi*(xq./xqbar).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0{itn}(:,:,gridDKE.rdke).*XXpn2.*XXpn.*XXmhu./XXgamma,1),1).';
        %
        xcurr{itn} = xcurr_rem{itn} + xcurr_rep{itn} + xcurr_0;% total current
        %
        % adjust ohmic field in frozen current mode
        %
        if dkeparam_out.nit_ohm > 1,% frozen current mode
            %
            if isnan(dkeparam_out.Itot_ohm),% convergence on the current profile
                %
                if imag(dkeparam_out.tol_ohm) > 0,% absolute threshold
                    tol_ohm = imag(dkeparam_out.tol_ohm);
                else%relative threshold
                    tol_ohm = dkeparam_out.tol_ohm*max(abs(xcurr_init));
                end
                %
                if max(abs(xcurr{itn} - xcurr_init)) <= tol_ohm,% *dkeparam_out.dtn,
                    if dkedisplay.display_mode >= 1,
                        disp(['Convergence reached after ',num2str(it_ohm),' iterations at time step ',num2str(itn)])
                    end
                    break
                elseif it_ohm == 1,% first iteration without electric field
                    %
                    xcurr_in = xcurr{itn};
                    xepsi{itn} = xepsi_in;% previous converged field is first guess for new time
                    %
                elseif it_ohm == dkeparam_out.nit_ohm,
                    disp(['WARNING : Convergence not reached after ',num2str(it_ohm),' iterations at time step ',num2str(itn)])
                else
                    %
                    xepsi{itn} = xepsi{itn}.*(1 - (xcurr{itn} - xcurr_init)./(xcurr{itn} - xcurr_in));
                    %
                    if gridDKE.nr > 1,
                        xepsi{itn}(end) = xepsi{itn}(end - 1);% to avoid edge pb
                    end
                    %
                end
                %
            else% convergence on the total current
                %
                I_tot = sum(xcurr{itn}.*equilDKE.xdA_dke*mksa.j_ref);% total driven current
                %
                if it_ohm == 1,% first iteration without electric field
                    %
                    I_tot_in = I_tot;
                    xepsi{itn} = xepsi_in;% previous converged field is first guess for new time
                    %
                elseif abs(I_tot - dkeparam_out.Itot_ohm)/abs(dkeparam_out.Itot_ohm) <= dkeparam_out.tol_ohm,% *dkeparam_out.dtn,
                    if dkedisplay.display_mode >= 1,
                        disp(['Convergence reached after ',num2str(it_ohm),' iterations at time step ',num2str(itn)])
                    end
                    break
                elseif it_ohm == dkeparam_out.nit_ohm,
                    disp(['WARNING : Convergence not reached after ',num2str(it_ohm),' iterations at time step ',num2str(itn)])
                else
                    %
                    xepsi{itn} = xepsi{itn}*(1 - (I_tot - dkeparam_out.Itot_ohm)./(I_tot - I_tot_in));
                    %
                end                
                %
            end
            %
        end
    end
    %
    xepsi_in = xepsi{itn};
    %
    if nit > 1,
        if dkedisplay.display_mode >= 1,
            figure(Fig_TimeIter),
            if length(equilDKE.xrho) == 1,
                graph1D_jd(FPtime(itn),curr0{itn}(end),0,0,'FP time (\tau_c)','J (norm.)','FP Evolution',NaN,[0,max(FPtime)],NaN,'none','+','r',2);
            elseif dkeparam_out.timevol == 1,
                graph1D_jd(FPtime(itn),Zcurr(itn).I_tot,0,0,'FP time (\tau_c)','I (MA)','FP Evolution',NaN,[0,max(FPtime)],NaN,'none','+','r',2);
            elseif dkeparam_out.timevol == 2,
                graph1D_jd(FPtime(itn),Zcurr(it_rf,itn).I_tot,0,0,'FP time (\tau_c)','I (MA)','FP Evolution',NaN,[0,max(FPtime)],NaN,'none','+','r',2);
            else
                graph1D_jd(FPtime(itn),max(abs(curr0{itn}(:,end))),0,0,'FP time (\tau_c)','max(|J|) (norm.)','FP Evolution',NaN,[0,max(FPtime)],NaN,'none','+','r',2);
            end
            grid on
            drawnow;                
        else
            disp(['time step ',num2str(itn),'/',num2str(nit),' completed.'])
        end
    end
    %
    if dkeparam_in.opt_save,
        save(tmpfile);
    end
    %
    XXfin = XXf0{itn};
    %
    if flag_exit,
        if isfield(dkeparam_out,'keyboard') && dkeparam_out.keyboard,
            keyboard;
        else
            break;
        end
    end
    %
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
    xepsi = xepsi(nit);
    %
    [ZP0,Zcurr,Znorm,ZXXS,...
        XxRR_fsav,xMRR_flux,xMRR_tau,xMRR_power_flux,xMRR_power_tau,xRRm_fsav,xRRp_fsav,...
        xne_norm_out,xTe_norm_out,xft_fsav,xfteff_fsav,Zmom] = ...
        fmoments_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,xepsi{1},waveparam,radial_mode,Zdelta,XXsinksource,XXSavalanches,...
        XXf0{1},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,XXfM,...
        ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp_mod_old,gridindex_rf,...
        ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZXXD_s,ZXXF_s,ZXXD_s_tp,ZXXF_s_tp,XXRintmask{1},XXILor);%Calculate moments of the distribution function
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
    [XXf0_bc,XXf0_bc_tp,XXf0_bc_g,XXf0_bc_L_tp,XXf0_bc_L_g,memoryLU_bc_f,memoryLU_bc_g] = solver_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,Zpn2_t,sm_f,sm_g,sm_tp,it_rf,MMXR_f_t,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,XXILor,XXsinksource,XXSavalanches,XXfinit);% Solve the DKE equation
    [ZP0_bc,Zcurr_bc,Znorm_bc,ZXXS_bc,ZYXXD_bc_rf,XxRR_bc_fsav,xMRR_flux_bc,xMRR_tau_bc,xMRR_power_flux_bc,xMRR_power_tau_bc,xRRm_bc_fsav,xRRp_bc_fsav,xne_norm_bc_out_bc,xTe_norm_bc_out,xft_bc_fsav,xfteff_bc_fsav] = fmoments_dke_yp(dkepath,dkeparam_out,dkedisplay,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,[],radial_mode,Zdelta,XXSavalanches,XXf0{nit},XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,ZXXD_rf,ZXXD_rf_tp,ZXXF_rf_tp,ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,ZXXD_s,ZXXF_s,ZXXD_s_tp,ZXXF_s_tp);%Calculate moments of the distribution function
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
dke_out.FPtime = FPtime;
dke_out.normf0 = normf0;
dke_out.curr0 = curr0;
dke_out.xcurr = xcurr;
dke_out.xcurr_rem = xcurr_rem;
dke_out.xcurr_rep = xcurr_rep;
dke_out.residu_f = residu_f;
dke_out.ZXXS = ZXXS;
%
dke_out.ZXXD_c = ZXXD_c;
dke_out.ZXXF_c = ZXXF_c;
dke_out.XXILor = XXILor;
%
dke_out.ZXXD_e = ZXXD_e;
dke_out.ZXXF_e = ZXXF_e;
dke_out.xepsi_init = xepsi_init;
dke_out.xepsi = xepsi;
dke_out.xEfield_validity = xEfield_validity;
%
dke_out.waveparam = waveparam;
dke_out.xyprop_dke = xyprop_dke;
dke_out.xyP0_2piRp_mod = xyP0_2piRp_mod_old;
if exist(xyP0_2piRp_mod_coll1)
    dke_out.xyP0_2piRp_mod_coll = xyP0_2piRp_mod_coll1;
end
dke_out.yb = yb;
dke_out.yP0_2piRp = yP0_2piRp;
dke_out.xys = xys;
%
dke_out.ZXXD_s = ZXXD_s;
dke_out.ZXXF_s = ZXXF_s;
%
dke_out.ZXXD_rf = ZXXD_rf;
dke_out.ZXXF_rf = ZXXF_rf;
%
if dkeparam_out.opt_struct > 1,% save heavy structures containing individual ray element contributions to Dql
    dke_out.ZXYD_rf = ZXYD_rf;
    dke_out.ZXYF_rf = ZXYF_rf;
    dke_out.gridindex_rf = gridindex_rf;
end
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
    if exist(zP_0_2piRp_mod_coll1)
        dke_out.zP_0_2piRp_mod_coll = zP_0_2piRp_mod_coll1;
    end
    %
    %waves = alphaphi_luke_jd(waves,dke_out,equilDKE);% calculates the QL ray absorption
    %
end
%
dke_out.xRRm_fsav = xRRm_fsav;
dke_out.xRRp_fsav = xRRp_fsav;
%
dke_out.xnorm_rem = xnorm_rem;
dke_out.xnorm_rep = xnorm_rep;
dke_out.xnrem_init = xnrem_init;
dke_out.xnrep_init = xnrep_init;
dke_out.xrr_out_norm = xrr_out_norm;
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
    dke_out.xRRm_bc_fsav = xRRm_bc_fsav;
    dke_out.xRRp_bc_fsav = xRRp_bc_fsav;
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
    dke_out.xRRm_bc_fsav = [];
    dke_out.xRRp_bc_fsav = [];
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