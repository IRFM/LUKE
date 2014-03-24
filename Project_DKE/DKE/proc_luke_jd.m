function data_proc = proc_luke_jd(data,ir_display,p_opt,dp_cyl,pnmax,subtitle,opt)
%LUKE -  Function which plots the results from LUKE data structures
%
% This function plots the results from LUKE data structures
%
% To use this function from saved rundke files:
%		data = load(filename);
%		proc_luke_jd(data,ir_display,p_opt,dp_cyl,pnmax,subtitle);
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr> and J. Decker (CEA/DSM/IRFM) <joan.decker@cea.fr>
%
    if nargin < 7,
        %
        % options for data_proc calculations
        %
        opt.peak = '';
        opt.wave = '';
        opt.jpeak = 0;
        opt.peakmode = 0;
        opt.blist = '';
        %
        % options for result display
        %
        opt.rho = '';
        opt.spec = 1;
        opt.its_rf = true;
        opt.diaryname = [];
    end
    if nargin < 6,
        subtitle = '';
    end
    if nargin < 5,
        pnmax = NaN;
    end
    if nargin < 4,
        dp_cyl = 0.1;
    end
    if nargin < 3,
        p_opt = -1;
    end
    if nargin < 2,
        ir_display = struct;
    end
    %
    if isstruct(ir_display),% case with no display; no user prompt, and all options as structure
        %
        opt = ir_display;
        %
        ir_display = -1;% no display
        %
        if isfield(opt,'p_opt'),
            p_opt = opt.p_opt;
        end
        if isfield(opt,'pnmax'),
            pnmax = opt.pnmax;
        end
        if isfield(opt,'p_opt'),
            p_opt = opt.p_opt;
        end
        if ~isfield(opt,'peak'),
            opt.peak = 'y';
        end
        if ~isfield(opt,'wave'),
            opt.wave = 'y';
        end
        if ~isfield(opt,'peakmode'),
            opt.peakmode = 1;
        end
        if ~isfield(opt,'rho'),
            opt.rho = 't';
        end
        if ~isfield(opt,'spec'),
            opt.spec = 0;
        end
        if ~isfield(opt,'its_rf'),
            opt.its_rf = [];
        end
        if ~isfield(opt,'blist'),
            opt.blist = [];
        end
        if ~isfield(opt,'diaryname'),
            opt.diaryname = [];
        end
    end
    %
    if ~isfield(opt,'peakmode'),
        opt.peakmode = 0;
    end
    %
    if ~isfield(opt,'jpeak'),
        opt.jpeak = 0;
    end
    %
    if ~isfield(opt,'rho') || isempty(opt.rho),
        opt.rho = input_dke_yp('Option for rho definition : ''g'' (geometric), ''p'' (poloidal flux), ''t'' (toroidal flux), ''v'' (volumic rho)','g',{'g','p','t','v'},'',[1,1]);
    end
    %
    if ~isfield(opt,'spec') || isempty(opt.spec)
        opt.spec = 1;
    end
    %
    if isfield(data,'lukestructs'),
        data = data.lukestructs;
    end
    if isfield(data,'output'),
        data = data.output;
    end
    %
    style0 = 'none';
    style = '-';
    style2 = '--';
    marker = 'none';
    marker1 = '+';
    marker2 = 'o';
    marker3 = 's';
    marker4 = '.';
    color1 = 'k';
    color2 = 'r';
    color3 = 'b';
    color4 = 'g';
    color5 = 'm';
    color6 = 'c';
    color7 = 'y';
    colors = {color2,color3,color4,color5,color6,color7};
    %
    width = 0.5;
    width2 = 2;
    %
    if ~isfield(opt,'font'),
        opt.font = 20+14i;
    end
    %
    if isfield(data,'data_proc'),
        %
        data_proc = data.data_proc;
        %
        opt = conc_struct_jd(opt,selectfields_jd(data_proc.opt,{'wave','peak','jpeak','peakmode'}));% these options were used to calculate data_proc
        %
        nr = length(data_proc.radial.xrhoG);
        nn_rf = length(data_proc.scalar.n_rf_list);
        if opt.wave == 'y',
            nw = length(data_proc.wave.wp0_rf_2piRp);
        end
        nit_rf = length(data_proc.simul.residue_rf);%number of RF iterations in last LUKE time
        %
        if ~isfield(data_proc.scalar,'P_rf_rhoG'),% update old data_proc structure,
            %
            data_proc.scalar.P_rf_rhoG = NaN;
            data_proc.scalar.P_rf_rhoP = NaN;
            data_proc.scalar.P_rf_rhoT = NaN;
            data_proc.scalar.P_rf_rhoV = NaN;
            %
            data_proc.scalar.P_rf_drhoG = NaN;
            data_proc.scalar.P_rf_drhoP = NaN;
            data_proc.scalar.P_rf_drhoT = NaN;
            data_proc.scalar.P_rf_drhoV = NaN;
            %
            xpsin_S = zeros(1,nr+1);% initial half-grid was built on psin
            for ir = 1:nr,
                xpsin_S(ir+1) = 2*data_proc.radial.xrhoP(ir)^2 - xpsin_S(ir);
            end
            xrhoP_S = sqrt(xpsin_S);
            xrhoG_S = [0,interp1(data_proc.radial.xrhoP,data_proc.radial.xrhoG,xrhoP_S(2:end-1),'spline'),1];
            xrhoT_S = [0,interp1(data_proc.radial.xrhoP,data_proc.radial.xrhoT,xrhoP_S(2:end-1),'spline'),1];
            xrhoV_S = [0,interp1(data_proc.radial.xrhoP,data_proc.radial.xrhoV,xrhoP_S(2:end-1),'spline'),1];
            %
            data_proc.radial.xdrhoG = diff(xrhoG_S);
            data_proc.radial.xdrhoP = diff(xrhoP_S);
            data_proc.radial.xdrhoT = diff(xrhoT_S);
            data_proc.radial.xdrhoV = diff(xrhoV_S);
            %
            if opt.wave == 'y',
                data_proc.wave.wids = cell(1,nw);
                %
                data_proc.wave.wP_rf_rhoG = data_proc.wave.wrhoG;
                data_proc.wave.wP_rf_rhoP = data_proc.wave.wrhoP;
                data_proc.wave.wP_rf_rhoT = data_proc.wave.wrhoT;
                data_proc.wave.wP_rf_rhoV = data_proc.wave.wrhoV;
            end
            %
        end
        %
    else% data is not processed yet
        %
        Znorm = data.Znorm;
        Zcurr = data.Zcurr;
        ZP0 = data.ZP0;
        if isfield(data.dke_out,'Zmom'),
            Zmom = data.dke_out.Zmom;
        else
            Zmom = struct;
        end
        dke_out = data.dke_out;
        radialDKE = data.radialDKE;
        equilDKE = data.equilDKE;
        momentumDKE = data.momentumDKE;
        gridDKE = data.gridDKE;
        Zmomcoef = data.Zmomcoef;
        Zbouncecoef = data.Zbouncecoef;
        Zmripple = data.Zmripple;
        mksa = data.mksa;
        %
        if isfield(dke_out,'waves'),
            waves = proc_wave_alphaphi_luke_jd(data,dke_out.waves,1);
        else
            waves = {};
        end
        %
        if isfield(dke_out,'dkeparam')
            dkeparam = dke_out.dkeparam;
        elseif isfield(data,'dkeparam')
            dkeparam = data.dkeparam;
        else
            dkeparam = struct;
        end
        %
        xrhoG = equilDKE.xrho; 
        xrhoP = equilDKE.xrhoP; 
        xrhoT = equilDKE.xrhoT; 
        xrhoV = equilDKE.xrhoV; 
        %
        % grids for interpolation
        %
        xrhoG_S = radialDKE.xrho_S_dke;
        xrhoP_S = sqrt(radialDKE.xpsin_S_dke);
        xrhoT_S = [0,interp1(xrhoG,xrhoT,radialDKE.xrho_S_dke(2:end-1),'spline'),1];
        xrhoV_S = [0,interp1(xrhoG,xrhoV,radialDKE.xrho_S_dke(2:end-1),'spline'),1];
        %
        xdrhoG = diff(xrhoG_S);
        xdrhoP = diff(xrhoP_S);
        xdrhoT = diff(xrhoT_S);
        xdrhoV = diff(xrhoV_S);
        %
        xTe = equilDKE.xTe;
        xne = equilDKE.xne;
        %
        pn = momentumDKE.pn;
        dpn = momentumDKE.dpn;
        mhu = momentumDKE.mhu;
        dmhu = momentumDKE.dmhu;
        gamma = Zmomcoef.gamma;
        Ec_ref = Zmomcoef.Ec_ref;%Fast electron kinetic energy in keV
        if isfield(Zmomcoef,'dEc_ref'),
            dEc_ref = Zmomcoef.dEc_ref;
        else
            [dummy,dummy,dummy,dummy,dummy,dummy,dummy,mc2] = pc_dke_yp;
            dEc_ref = diff(mc2*(sqrt(1 + momentumDKE.pn_S.*momentumDKE.pn_S*mksa.betath_ref^2) - 1));
        end
        %
        nr = length(xrhoG);
        nw = length(waves);
        %
        yb = dke_out.yb;
        %
        if isfield(dke_out,'waveparam') && strcmp(dke_out.waveparam.model,'RT'),
            nfrags = length(dke_out.waveparam.biy_rf);
        else
            nfrags = NaN;
        end
        %
        if isfield(dkeparam,'timevol'),
            timevol = dkeparam.timevol;
        else
            timevol = 0;
        end
        %
        scocurr = sign(equilDKE.psia_apRp)*sign(equilDKE.XBphi(1,1));
        %
        % current
        %
        J_tot = Zcurr(end).x_0_fsav*mksa.j_ref*scocurr;
        %
        % power deposition
        %
        P_rf = ZP0(end).x_rf_fsav.'*mksa.P_ref;
        yP_rf = ZP0(end).xy_rf_fsav.'*mksa.P_ref;
        ynP_rf = ZP0(end).xyn_rf_fsav*mksa.P_ref;
        P_e = ZP0(end).x_e_fsav*mksa.P_ref;
        P_tot = P_rf + P_e;
        %
        % parallel momentum transfer rate
        %
        if isfield(Zmom,'x_rf'),
            xdpdt_rf = Zmom(end).x_rf*mksa.dpdt_ref;
        else
            xdpdt_rf = NaN(1,nr);
        end
        %
        if isfield(dke_out,'residue_rf'),
            if iscell(dke_out.residue_rf),
                residue_rf = dke_out.residue_rf{end};
            else
                residue_rf = dke_out.residue_rf;
            end
        else
            residue_rf = NaN;
        end
        %
        nit_rf = length(residue_rf);%number of RF iterations in last LUKE time
        %
        if isfield(dke_out,'zS'),
            zS = dke_out.zS;
            %
            if size(dke_out.zP_0_2piRp_mod,1) >= nit_rf,
                zP_0_2piRp_mod = dke_out.zP_0_2piRp_mod(1:nit_rf,end);% new main_dke_yp - all RF states kept
            else
                zP_0_2piRp_mod = dke_out.zP_0_2piRp_mod(1,end);% old main_dke_yp - only last RF state kept
            end
        else
            zS = '';
            zP_0_2piRp_mod = '';
        end
        %
        ny = size(yP_rf,1);
        nn_rf = size(ynP_rf,3);
        %
        if isfield(ZP0(end),'n_rf_list'),
            n_rf_list = ZP0(end).n_rf_list;
        elseif isfield(dke_out,'waveparam'),
            n_rf_list = dke_out.waveparam.n_rf_list;
        elseif isfield(dkeparam,'n_rf_list'),
            n_rf_list = dkeparam.n_rf_list;
        else
            n_rf_list = NaN(1,nn_rf);
            disp('WARNING : n_rf_list not determined.')
        end
        %
        xI = J_tot.*equilDKE.xdA_dke;
        I_tot = sum(xI);
        %
        [jrhoG,jdrhoG] = calc_peak_jd(xrhoG,xdrhoG,J_tot,equilDKE.xdA_dke,opt.jpeak,opt.peakmode);
        [jrhoP,jdrhoP] = calc_peak_jd(xrhoP,xdrhoP,J_tot,equilDKE.xdA_dke,opt.jpeak,opt.peakmode);
        [jrhoT,jdrhoT] = calc_peak_jd(xrhoT,xdrhoT,J_tot,equilDKE.xdA_dke,opt.jpeak,opt.peakmode);
        [jrhoV,jdrhoV] = calc_peak_jd(xrhoV,xdrhoV,J_tot,equilDKE.xdA_dke,opt.jpeak,opt.peakmode);
        %
        [P_rf_rhoG,P_rf_drhoG] = calc_peak_jd(xrhoG,xdrhoG,P_rf,equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
        [P_rf_rhoP,P_rf_drhoP] = calc_peak_jd(xrhoP,xdrhoP,P_rf,equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
        [P_rf_rhoT,P_rf_drhoT] = calc_peak_jd(xrhoT,xdrhoT,P_rf,equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
        [P_rf_rhoV,P_rf_drhoV] = calc_peak_jd(xrhoV,xdrhoV,P_rf,equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
        %
        jTe = interp1(xrhoG,xTe,jrhoG);
        jne = interp1(xrhoG,xne,jrhoG);
        %
        P_rf_Te = interp1(xrhoG,xTe,P_rf_rhoG);
        P_rf_ne = interp1(xrhoG,xne,P_rf_rhoG);
        %
        if isempty(opt.peak),
            opt.peak = input_dke_yp('Do you want to display specific information for each absorption peak? (y/n)','n',{'n','y'},'',[1,1]);
        end
        %
        if isempty(opt.wave),
            opt.wave = input_dke_yp('Do you want to display specific information for each wave? (y/n)','n',{'n','y'},'',[1,1]);
        end
        %
        if nw == 1 && (~isfield(waves{1},'model') || strcmp(waves{1}.model,'RT')),
            if ~isfield(opt,'blist') || (isscalar(opt.blist) && isnan(opt.blist)),
                nb = length(waves{1}.rays);
                opt_blist = input(['You can group the ',num2str(nb),' rays by vectors in cell (leave empty otherwise) :']);
            else
                opt_blist = opt.blist;
            end
        else
            opt_blist = [];
        end
        %
        xp_rf_2piRp = P_rf.*equilDKE.xdV_2piRp_dke;
        yxp_rf_2piRp = yP_rf.*repmat(equilDKE.xdV_2piRp_dke,[ny,1]);
        yxnp_rf_2piRp = ynP_rf.*repmat(equilDKE.xdV_2piRp_dke.',[1,ny,nn_rf]);
        %
        p_rf_2piRp = sum(xp_rf_2piRp);
        np_rf_2piRp = sum(reshape(sum(yxnp_rf_2piRp,2),[nr,nn_rf]),1);
        xnp_rf_2piRp = reshape(sum(yxnp_rf_2piRp,2),[nr,nn_rf]);
        %
        p_e_2piRp = sum(P_e.*equilDKE.xdV_2piRp_dke);
        p_tot_2piRp = sum(P_tot.*equilDKE.xdV_2piRp_dke);
        EtaRp = I_tot/(p_tot_2piRp*2*pi);
        EtaRFRp = jne*1e-19*I_tot/(p_rf_2piRp*2*pi);
        ksirf = 32.7*I_tot.*P_rf_ne*1e-20./(P_rf_Te*2*pi.*p_rf_2piRp);
        %
        eta = NaN(1,nr);
        eta(P_tot ~= 0) = J_tot(P_tot ~= 0)./P_tot(P_tot ~= 0);
        %
        I_exp = NaN;
        %
        if isfield(dke_out,'equil') && isfield(dke_out.equil,'icd'),% integrated modelling or experimental current drive
            %
            if p_e_2piRp == 0, % ohmic heating in LUKE
                %
                I_exp = dke_out.equil.icd/1e6;
                %
            elseif isfield(dke_out.equil,'iohm')
                %
                I_exp = (dke_out.equil.icd + dke_out.equil.iohm)/1e6;
                %
            else
                %
                disp('Warning : ohmic heating not available, exp. comparison discarded')
            end
        end
        %
        if timevol >= 1,
            %
            FPtime = dke_out.FPtime;
            %
            nit = length(FPtime);
            %
            if timevol == 1,
                %
                tJ_tot = reshape([Zcurr(end-nit+1:end).x_0_fsav],[nr,nit])*mksa.j_ref*scocurr;
                tP_rf = [ZP0(end-nit+1:end).x_rf_fsav]*mksa.P_ref;
                tP_e = reshape([ZP0(end-nit+1:end).x_e_fsav],[nr,nit])*mksa.P_ref;
                %
            elseif timevol == 2,
                %
                tJ_tot = NaN(nr,nit);
                tP_rf = NaN(nr,nit);
                tP_e = NaN(nr,nit);
                %
                for itn = 1:nit,
                    %
                    it_rf = length(dke_out.residue_rf{itn});
                    %
                    tJ_tot(:,itn) = Zcurr(it_rf,itn).x_0_fsav.'*mksa.j_ref*scocurr;
                    tP_rf(:,itn) = ZP0(it_rf,itn).x_rf_fsav*mksa.P_ref;
                    tP_e(:,itn) = ZP0(it_rf,itn).x_e_fsav.'*mksa.P_ref;
                    %
                end
                %
                J_tot_rf = reshape([Zcurr(1:nit_rf,end).x_0_fsav],[nr,nit_rf])*mksa.j_ref*scocurr;
                I_tot_rf = sum(J_tot_rf.*repmat(equilDKE.xdA_dke.',[1,nit_rf]));
                %
            end
            %
            tP_tot = tP_rf + tP_e;
            tI_tot = sum(tJ_tot.*repmat(equilDKE.xdA_dke.',[1,nit]));
            %
            xtdV_2piRp_dke = repmat(equilDKE.xdV_2piRp_dke.',[1,nit]);
            %
            tp_rf_2piRp = sum(tP_rf.*xtdV_2piRp_dke);
            tp_e_2piRp = sum(tP_e.*xtdV_2piRp_dke);
            tp_tot_2piRp = sum(tP_tot.*xtdV_2piRp_dke);
            %
        end
        %
        if iscell(opt_blist),%separate rays by list in the case of one wave
            %
            nw = length(opt_blist);
            %
            nb = NaN(1,nw);
            ymask = cell(1,nw);
            wp0_rf_2piRp = zeros(1,nw);
            %
            wave = waves{1};
            nbw = length(wave.rays);
            %
            for iw = 1:nw,
                %
                waves{iw} = wave;
                waves{iw}.rays = wave.rays(opt_blist{iw});
                %
                nb(iw) = length(opt_blist{iw});
                ymask{iw} = [];
                %
                for iiray = 1:nb(iw),
                    %
                    iray = opt_blist{iw}(iiray);
                    %
                    wp0_rf_2piRp(iw) = wp0_rf_2piRp(iw) + waves{iw}.rays{iiray}.P0_2piRp*1e-6;
                    %
                    if iray < nbw
                        ymaskloc = yb(iray):(yb(iray+1) - 1);
                    else
                        ymaskloc = yb(iray):ny;
                    end          
                    %
                    ymask{iw} = sort([ymask{iw},ymaskloc]);
                    %
                end
                %
            end
            %
            clear wave
            %
        else
            %
            nb = NaN(1,nw);
            ymask = cell(1,nw);
            wp0_rf_2piRp = zeros(1,nw);
            %
            for iw = 1:nw,
                %
                if ~isfield(waves{iw},'model') || strcmp(waves{iw}.model,'RT'),
                    %
                    nb(iw) = length(waves{iw}.rays);
                    for iray = 1:nb(iw),
                        %
                        wp0_rf_2piRp(iw) = wp0_rf_2piRp(iw) + waves{iw}.rays{iray}.P0_2piRp*1e-6;
                        %
                    end
                    %
                elseif strcmp(waves{iw}.model,'FW'),
                    %
                    nb(iw) = 0;
                    if isfield(waves{iw},'P0_2piRp'),
                        wp0_rf_2piRp(iw) = waves{iw}.P0_2piRp*1e-6;
                    else
                        wp0_rf_2piRp(iw) = NaN;
                    end
                    %
                else
                    error('Wave type not recognized.')
                end
                %
                ibmin = sum(nb(1:iw-1)) + 1;
                ibmax = sum(nb(1:iw)) + 1;
                %
                if iw < nw
                    ymask{iw} = yb(ibmin):(yb(ibmax) - 1);
                else
                    ymask{iw} = yb(ibmin):ny;
                end          
                %
            end
        end
        %
        %nbtot = sum(nb);
        %
        if isfield(dke_out,'yP0_2piRp'),
            p0_rf_2piRp = sum(dke_out.yP0_2piRp)/1e6;%sum(wp0_rf_2piRp);
        else
            p0_rf_2piRp = sum(wp0_rf_2piRp);
        end
        %
        %
        if nr > 1,
            %
            if opt.wave == 'y',
                %
                % calculate linear deposition
                %
                wxP_rf_lin = zeros(nw,nr);
                %
                wP_rf_rhoG_lin = zeros(1,nw);
                wP_rf_rhoP_lin = zeros(1,nw);
                wP_rf_rhoT_lin = zeros(1,nw);
                wP_rf_rhoV_lin = zeros(1,nw);
                %
                for iw = 1:nw,
                    %
                    if ~isfield(waves{iw},'model') || strcmp(waves{iw}.model,'RT'),
                        %
                        for iray = 1:nb(iw),
                            %
                            ray = waves{iw}.rays{iray};
                            %
                            if isfield(ray,'sP_2piRp_lin')  && isfield(ray,'srho'),
                                wxP_rf_lin(iw,:) = wxP_rf_lin(iw,:) + 1e-6*radialdampingprofile_jd(ray.srho,ray.sP_2piRp_lin,xrhoG_S)./equilDKE.xdV_2piRp_dke;
                            else
                                wxP_rf_lin(iw,:) = NaN;% if some rays are not accounted for, the comparison is misleading and thus stopped
                            end
                            %
                        end
                        %
                    elseif strcmp(waves{iw}.model,'FW'),
                        %
                        nr_fw = length(waves{iw}.rho);
                        xwmask = zeros(nr,nr_fw);%matrix of individual contributions from each EVE FS
                        %
                        for ir_fw = 1:nr_fw,
                            if waves{iw}.rhotype == 'g',
                                xwmask(:,ir_fw) = max([zeros(1,nr);(min([repmat(waves{iw}.rho_S(ir_fw + 1),[1,nr]);xrhoG_S(2:end)]) - max([repmat(waves{iw}.rho_S(ir_fw),[1,nr]);xrhoG_S(1:end-1)]))]).'./xdrhoG.';
                            elseif waves{iw}.rhotype == 'p',
                                xwmask(:,ir_fw) = max([zeros(1,nr);(min([repmat(waves{iw}.rho_S(ir_fw + 1),[1,nr]);xrhoP_S(2:end)]) - max([repmat(waves{iw}.rho_S(ir_fw),[1,nr]);xrhoP_S(1:end-1)]))]).'./xdrhoP.';
                            elseif waves{iw}.rhotype == 't',
                                xwmask(:,ir_fw) = max([zeros(1,nr);(min([repmat(waves{iw}.rho_S(ir_fw + 1),[1,nr]);xrhoT_S(2:end)]) - max([repmat(waves{iw}.rho_S(ir_fw),[1,nr]);xrhoT_S(1:end-1)]))]).'./xdrhoT.';
                            elseif waves{iw}.rhotype == 'v',
                                xwmask(:,ir_fw) = max([zeros(1,nr);(min([repmat(waves{iw}.rho_S(ir_fw + 1),[1,nr]);xrhoV_S(2:end)]) - max([repmat(waves{iw}.rho_S(ir_fw),[1,nr]);xrhoV_S(1:end-1)]))]).'./xdrhoV.';
                            else
                                error('rho type not recognized')
                            end
                        end
                        %
                        wpe_eve = 1e-6*(waves{iw}.pe_eve(1:end - 1) + waves{iw}.pe_eve(2:end))/2;% EVE linear power density (in MW/m3?)
                        %
                        wxP_rf_lin(iw,:) = (xwmask*wpe_eve).';
                        %
                    else
                        error('Wave type not recognized.')
                    end
                    %    
                    [wP_rf_rhoG_lin(iw)] = calc_peak_jd(xrhoG,xdrhoG,wxP_rf_lin(iw,:),equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
                    [wP_rf_rhoP_lin(iw)] = calc_peak_jd(xrhoP,xdrhoP,wxP_rf_lin(iw,:),equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
                    [wP_rf_rhoT_lin(iw)] = calc_peak_jd(xrhoT,xdrhoT,wxP_rf_lin(iw,:),equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
                    [wP_rf_rhoV_lin(iw)] = calc_peak_jd(xrhoV,xdrhoV,wxP_rf_lin(iw,:),equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
                end
                %
                wxp_rf_2piRp_lin = wxP_rf_lin.*repmat(equilDKE.xdV_2piRp_dke,[nw,1]);
                wp_rf_2piRp_lin = sum(wxp_rf_2piRp_lin,2);
                xp_rf_2piRp_lin = sum(wxp_rf_2piRp_lin,1);
                p_rf_2piRp_lin = sum(wp_rf_2piRp_lin);
                %
                if ~all(isnan(wP_rf_rhoG_lin)),
                    wTe_lin = interp1(xrhoG,xTe,wP_rf_rhoG_lin);
                    wne_lin = interp1(xrhoG,xne,wP_rf_rhoG_lin);
                else
                    wTe_lin = NaN(1,nw);
                    wne_lin = NaN(1,nw);
                end           
                %
                % calculate quasilinear deposition
                %
                wxP_rf = zeros(nw,nr);
                %
                wxp_rf_2piRp = zeros(nw,nr);
                wnp_rf_2piRp = zeros(nw,nn_rf);
                %
                wP_rf_rhoG = zeros(1,nw);
                wP_rf_rhoP = zeros(1,nw);
                wP_rf_rhoT = zeros(1,nw);
                wP_rf_rhoV = zeros(1,nw);
                %
                wids = cell(1,nw);
                %
                wrays = cell(1,nw);
                %
                for iw = 1:nw,
                    %    
                    wids{iw} = waves{iw}.id;
                    %
                    wxP_rf(iw,:) = sum(yP_rf(ymask{iw},:),1);
                    %
                    wxp_rf_2piRp(iw,:) = sum(yxp_rf_2piRp(ymask{iw},:),1);
                    wnp_rf_2piRp(iw,:) = reshape(sum(sum(yxnp_rf_2piRp(:,ymask{iw},:),2),1),[1,nn_rf]);
                    %    
                    [wP_rf_rhoG(iw)] = calc_peak_jd(xrhoG,xdrhoG,wxP_rf(iw,:),equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
                    [wP_rf_rhoP(iw)] = calc_peak_jd(xrhoP,xdrhoP,wxP_rf(iw,:),equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
                    [wP_rf_rhoT(iw)] = calc_peak_jd(xrhoT,xdrhoT,wxP_rf(iw,:),equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
                    [wP_rf_rhoV(iw)] = calc_peak_jd(xrhoV,xdrhoV,wxP_rf(iw,:),equilDKE.xdV_2piRp_dke,opt.jpeak,opt.peakmode);
                    %
                    if ~isfield(waves{iw},'model') || strcmp(waves{iw}.model,'RT'),
                        %
                        wrays{iw} = cell(1,nb(iw));
                        %
                        for iray = 1:nb(iw),
                            %
                            wrays{iw}{iray} = proc_ray_jd(waves{iw}.rays{iray});
                            %
                        end
                        %
                    elseif strcmp(waves{iw}.model,'FW'),
                        %
                    else
                        error('Wave type not recognized.')
                    end
                end
                %
                if ~all(isnan(wP_rf_rhoG)),
                    wTe = interp1(xrhoG,xTe,wP_rf_rhoG);
                    wne = interp1(xrhoG,xne,wP_rf_rhoG);
                else
                    wTe = NaN(1,nw);
                    wne = NaN(1,nw);
                end           
                %
                wp_rf_2piRp = sum(wxp_rf_2piRp,2);
                %
            else
                %
                xp_rf_2piRp_lin = NaN;
                p_rf_2piRp_lin = NaN;
                %
            end
            %
            if opt.peak == 'y',
                %
                % The deposited power and current are split into a series
                % of 'peaks' defined from the density of power absorbed
                %
                dep = 1;
                xP_rf = P_rf;
                xP_rfm = 0;
                %
                xP_rf(xP_rf < 0) = 0;
                %
                p_rf_2piRp_peak = 0;
                I_tot_peak = 0;
                %
                peaks.ir = []; 
                peaks.p_rf_2piRp = [];
                peaks.I_tot = [];
                %
                for ir = 1:nr,
                    if (xP_rf(ir) - xP_rfm)*dep < 0,
                        if dep == 1,% ir-1 is a peak
                            peaks.ir = [peaks.ir,ir-1];
                            dep = -1;
                        else% ir-1 is a low - power and current shared
                            %
                            p_rf_2piRp_peak = p_rf_2piRp_peak - xp_rf_2piRp(ir-1)/2;  
                            I_tot_peak = I_tot_peak - xI(ir-1)/2;
                            %
                            peaks.p_rf_2piRp = [peaks.p_rf_2piRp,p_rf_2piRp_peak];
                            peaks.I_tot = [peaks.I_tot,I_tot_peak];
                            %
                            p_rf_2piRp_peak = xp_rf_2piRp(ir-1)/2;  
                            I_tot_peak = xI(ir-1)/2;
                            %
                            dep = 1;
                        end
                    end
                    %
                    xP_rfm = xP_rf(ir);
                    p_rf_2piRp_peak = p_rf_2piRp_peak + xp_rf_2piRp(ir);  
                    I_tot_peak = I_tot_peak + xI(ir);
                end  
                %
                if dep == 1,%finish with a high
                    peaks.ir = [peaks.ir,nr];
                end
                peaks.p_rf_2piRp = [peaks.p_rf_2piRp,p_rf_2piRp_peak];
                peaks.I_tot = [peaks.I_tot,I_tot_peak];
                %
                peaks.rhoG = xrhoG(peaks.ir);
                peaks.rhoP = xrhoP(peaks.ir);
                peaks.rhoT = xrhoT(peaks.ir);
                peaks.rhoV = xrhoV(peaks.ir);
                peaks.Te = xTe(peaks.ir);
                peaks.ne = xne(peaks.ir);
                peaks.EtaRp = peaks.I_tot./(peaks.p_rf_2piRp*2*pi);
                peaks.ksirf = 32.7*peaks.I_tot.*peaks.ne*1e-20./(peaks.Te*2*pi.*peaks.p_rf_2piRp);
                %
            else
                peaks = '';
            end
            %
            % SIMUL
            %
            data_proc.simul = dke_out.simul;
            data_proc.simul.residue_rf = residue_rf;
            %
            % SCALAR
            %
            data_proc.scalar.p_tot_2piRp = p_tot_2piRp;
            %
            data_proc.scalar.p0_rf_2piRp = p0_rf_2piRp;
            data_proc.scalar.p_rf_2piRp = p_rf_2piRp;
            data_proc.scalar.p_rf_2piRp_lin = p_rf_2piRp_lin;
            %
            data_proc.scalar.np_rf_2piRp = np_rf_2piRp;
            data_proc.scalar.n_rf_list = n_rf_list;
            %
            data_proc.scalar.p_e_2piRp = p_e_2piRp;
            data_proc.scalar.I_tot = I_tot;
            data_proc.scalar.I_exp = I_exp;
            data_proc.scalar.EtaRp = EtaRp;
            data_proc.scalar.EtaRFRp = EtaRFRp;
            data_proc.scalar.ksirf = ksirf;
            data_proc.scalar.nfrags = nfrags;
            data_proc.scalar.Rp = equilDKE.Rp;
            %
            data_proc.scalar.jrhoG = jrhoG;
            data_proc.scalar.jrhoP = jrhoP;
            data_proc.scalar.jrhoT = jrhoT;
            data_proc.scalar.jrhoV = jrhoV;
            data_proc.scalar.jdrhoG = jdrhoG;
            data_proc.scalar.jdrhoP = jdrhoP;
            data_proc.scalar.jdrhoT = jdrhoT;
            data_proc.scalar.jdrhoV = jdrhoV;
            data_proc.scalar.jTe = jTe;
            data_proc.scalar.jne = jne;
            %
            data_proc.scalar.P_rf_rhoG = P_rf_rhoG;
            data_proc.scalar.P_rf_rhoP = P_rf_rhoP;
            data_proc.scalar.P_rf_rhoT = P_rf_rhoT;
            data_proc.scalar.P_rf_rhoV = P_rf_rhoV;
            data_proc.scalar.P_rf_drhoG = P_rf_drhoG;
            data_proc.scalar.P_rf_drhoP = P_rf_drhoP;
            data_proc.scalar.P_rf_drhoT = P_rf_drhoT;
            data_proc.scalar.P_rf_drhoV = P_rf_drhoV;
            data_proc.scalar.P_rf_Te = P_rf_Te;
            data_proc.scalar.P_rf_ne = P_rf_ne;
            %
            % RADIAL
            %
            data_proc.radial.xrhoG = xrhoG;
            data_proc.radial.xrhoP = xrhoP;
            data_proc.radial.xrhoT = xrhoT;
            data_proc.radial.xrhoV = xrhoV;
            data_proc.radial.xdrhoG = xdrhoG;
            data_proc.radial.xdrhoP = xdrhoP;
            data_proc.radial.xdrhoT = xdrhoT;
            data_proc.radial.xdrhoV = xdrhoV;
            %
            data_proc.radial.xdA_dke = equilDKE.xdA_dke;
            data_proc.radial.xdV_2piRp_dke = equilDKE.xdV_2piRp_dke;
            %
            if isfield(dke_out,'xepsi'),
                data_proc.radial.xepsi = dke_out.xepsi;
            end
            %
            data_proc.radial.J_tot = J_tot;
            data_proc.radial.P_tot = P_tot;
            data_proc.radial.eta = eta;
            data_proc.radial.P_rf = P_rf;
            data_proc.radial.P_e = P_e;
            data_proc.radial.xdpdt_rf = xdpdt_rf;    
            %
            data_proc.radial.xnp_rf_2piRp = xnp_rf_2piRp;
            % 
            data_proc.radial.xp_rf_2piRp = xp_rf_2piRp;
            data_proc.radial.xp_rf_2piRp_lin = xp_rf_2piRp_lin;
            %
            % TIME EVOLUTION
            %
            if timevol >= 1,
                data_proc.timevol.FPtime = FPtime;
                data_proc.timevol.tJ_tot = tJ_tot;
                data_proc.timevol.tP_rf = tP_rf;
                data_proc.timevol.tP_e = tP_e;
                data_proc.timevol.tP_tot = tP_tot;
                data_proc.timevol.tI_tot = tI_tot;
                data_proc.timevol.tp_rf_2piRp = tp_rf_2piRp;
                data_proc.timevol.tp_e_2piRp = tp_e_2piRp;
                data_proc.timevol.tp_tot_2piRp = tp_tot_2piRp;
            end
            %
            if timevol >= 2,
                data_proc.timevol.J_tot_rf = J_tot_rf;
                data_proc.timevol.I_tot_rf = I_tot_rf;
            end
            %
            % WAVE QUASI-LINEAR
            %
            if opt.wave == 'y',
                data_proc.wave.wids = wids;
                %
                data_proc.wave.wxP_rf = wxP_rf;
                data_proc.wave.wp0_rf_2piRp = wp0_rf_2piRp;
                data_proc.wave.wp_rf_2piRp = wp_rf_2piRp;
                data_proc.wave.wnp_rf_2piRp = wnp_rf_2piRp;
                data_proc.wave.wn_rf_list = n_rf_list;
                data_proc.wave.wxp_rf_2piRp = wxp_rf_2piRp;
                %
                data_proc.wave.wP_rf_rhoG = wP_rf_rhoG;
                data_proc.wave.wP_rf_rhoP = wP_rf_rhoP;
                data_proc.wave.wP_rf_rhoT = wP_rf_rhoT;
                data_proc.wave.wP_rf_rhoV = wP_rf_rhoV;
                %
                data_proc.wave.wTe = wTe;
                data_proc.wave.wne = wne;
                %
                data_proc.wave.wrays = wrays;
                %
                % WAVE LINEAR
                %
                data_proc.wave.wxP_rf_lin = wxP_rf_lin;
                data_proc.wave.wp_rf_2piRp_lin = wp_rf_2piRp_lin;
                data_proc.wave.wxp_rf_2piRp_lin = wxp_rf_2piRp_lin;
                %
                data_proc.wave.wP_rf_rhoG_lin = wP_rf_rhoG_lin;
                data_proc.wave.wP_rf_rhoP_lin = wP_rf_rhoP_lin;
                data_proc.wave.wP_rf_rhoT_lin = wP_rf_rhoT_lin;
                data_proc.wave.wP_rf_rhoV_lin = wP_rf_rhoV_lin;
                %
                data_proc.wave.wTe_lin = wTe_lin;
                data_proc.wave.wne_lin = wne_lin;
            else
                data_proc.wave = '';
            end
            %
            % PEAKS
            %
            data_proc.peaks = peaks;
            %
            % OPTIONS
            %
            data_proc.opt = opt;
            %
        else
            %
            data_proc = struct;
            %
        end
    end
    %
    if opt.rho == 'g',
        xrho = data_proc.radial.xrhoG;
        dxrho = data_proc.radial.xdrhoG;
        xlab_rho = '\rho_G';
    elseif  opt.rho == 'p',
        xrho = data_proc.radial.xrhoP;
        dxrho = data_proc.radial.xdrhoP;
        xlab_rho = '\rho_P';
    elseif  opt.rho == 't',
        xrho = data_proc.radial.xrhoT;
        dxrho = data_proc.radial.xdrhoT;
        xlab_rho = '\rho_T';
    elseif  opt.rho == 'v',
        xrho = data_proc.radial.xrhoV;
        dxrho = data_proc.radial.xdrhoV;
        xlab_rho = '\rho_V';
    end
    %
    if ir_display >= 0,
        %
        if isfield(opt,'diaryname') && ischar(opt.diaryname),
            diaryname = opt.diaryname;
        else
            if ir_display == 0,
                diaryname = ['res_',data_proc.simul.id,'.log'];
            else
                tir_display = num2str(ir_display);
                diaryname = ['res_',data_proc.simul.id,'_irho_',tir_display,'.log'];
            end
            %
            if exist(diaryname,'file') && gettime_jd(diaryname) > datenum(timeid_jd(data_proc.simul.timeid),'mm/dd/yyyy HH:MM:SS'),
                diaryname = '';
            end
            %
            diaryname = input_dke_yp('Provide a name for the log file? (return empty string if no log file)',diaryname);
        end
        %
        if ~isempty(diaryname),
            if exist(diaryname,'file'),
                delete(diaryname)
            end
            diary(diaryname)
        end
        %
        disp(['Simulation id: ',data_proc.simul.id]);
        disp(['Simulation date: ',timeid_jd(data_proc.simul.timeid)]);
        disp(['User id: ',data_proc.simul.userid]);
        disp(['LUKE Version: ',data_proc.simul.LUKEversion]);
        if all(isfield(data_proc.simul,{'matver','hostname'})),
            disp(['MATLAB Version: ',data_proc.simul.matver]);
            disp(['MACHINE: ',data_proc.simul.hostname]);
        end
        disp(['Final RF convergence parameter: ',num2str(data_proc.simul.residue_rf(end))]);
        disp(' ');
        %
        if nr > 1,
            %
            disp(['Total current (I): ',num2str(data_proc.scalar.I_tot),' MA (positive for co-current)'])
            disp(['Exp. current  (I): ',num2str(data_proc.scalar.I_exp),' MA (positive for co-current)'])
            %
            if opt.rho == 'g',
                jrho = data_proc.scalar.jrhoG;
                jdrho = data_proc.scalar.jdrhoG;
                %
                P_rf_rho = data_proc.scalar.P_rf_rhoG;
                P_rf_drho = data_proc.scalar.P_rf_drhoG;
            elseif opt.rho == 'p',
                jrho = data_proc.scalar.jrhoP;
                jdrho = data_proc.scalar.jdrhoP;
                %
                P_rf_rho = data_proc.scalar.P_rf_rhoP;
                P_rf_drho = data_proc.scalar.P_rf_drhoP;
            elseif  opt.rho == 't',
                jrho = data_proc.scalar.jrhoT;
                jdrho = data_proc.scalar.jdrhoT;
                %
                P_rf_rho = data_proc.scalar.P_rf_rhoT;
                P_rf_drho = data_proc.scalar.P_rf_drhoT;
            elseif  opt.rho == 'v',
                jrho = data_proc.scalar.jrhoV;
                jdrho = data_proc.scalar.jdrhoV;
                %
                P_rf_rho = data_proc.scalar.P_rf_rhoV;
                P_rf_drho = data_proc.scalar.P_rf_drhoV;
            end
            disp(['Location of current peak (rho',opt.rho,'): ',num2str(jrho),' (peak mode = ',num2str(opt.peakmode),'; jpeak = ',num2str(opt.jpeak),')'])
            disp(['Current FWHM (drho',opt.rho,'): ',num2str(jdrho),' (peak mode = ',num2str(opt.peakmode),'; jpeak = ',num2str(opt.jpeak),')'])
            disp(['RF efficiency (n_19*I*Rp/P): ',num2str(data_proc.scalar.EtaRFRp),' 10^19 A/(W.m^2)'])
            disp(['Location of RF power deposition peak (rho',opt.rho,'): ',num2str(P_rf_rho),' (peak mode = ',num2str(opt.peakmode),'; jpeak = ',num2str(opt.jpeak),')'])
            disp(['RF power deposition FWHM (drho',opt.rho,'): ',num2str(P_rf_drho),' (peak mode = ',num2str(opt.peakmode),'; jpeak = ',num2str(opt.jpeak),')'])
            disp(['Number of RF ray fragments: ',num2str(data_proc.scalar.nfrags)])
            %
            if isinf(data_proc.scalar.Rp),
                disp(['Launched RF power (P/2piRp): ',num2str(data_proc.scalar.p0_rf_2piRp),' MW/m'])
                disp(['RF power absorbed (P/2piRp): ',num2str(data_proc.scalar.p_rf_2piRp),' MW/m ---> ',num2str(100*data_proc.scalar.p_rf_2piRp/data_proc.scalar.p0_rf_2piRp),' %.'])
                for in_rf = 1:nn_rf,
                    disp(['RF power absorbed on harm. ',num2str(data_proc.scalar.n_rf_list(in_rf)),' (P/2piRp): ',num2str(data_proc.scalar.np_rf_2piRp(in_rf)),' MW/m ---> ',num2str(100*data_proc.scalar.np_rf_2piRp(in_rf)/data_proc.scalar.p0_rf_2piRp),' %.'])
                end
                if opt.wave == 'y',
                    disp(['Linear RF power absorbed (P/2piRp): ',num2str(data_proc.scalar.p_rf_2piRp_lin),' MW/m ---> ',num2str(100*data_proc.scalar.p_rf_2piRp_lin/data_proc.scalar.p0_rf_2piRp),' %.'])
                end
                disp(['Ohmic power deposited (P/2piRp): ',num2str(data_proc.scalar.p_e_2piRp),' MW/m'])
                disp(['Total power deposited (P/2piRp): ',num2str(data_proc.scalar.p_tot_2piRp),' MW/m'])
                disp(['CD efficiency (I*Rp/P): ',num2str(data_proc.scalar.EtaRp),' A.m/W'])
                disp(['Normalized CD efficiency xi: ',num2str(data_proc.scalar.ksirf)])
                %
                if opt.peak == 'y',
                    %
                    for ipeak = 1:length(data_proc.peaks.ir),
                        disp(' ');
                        disp('----------------------------------------');
                        disp(' ');
                        disp(['RF Peak # ',num2str(ipeak)])
                        disp(['Position rho G: ',num2str(data_proc.peaks.rhoG(ipeak))])
                        disp(['Position rho P: ',num2str(data_proc.peaks.rhoP(ipeak))])
                        disp(['Position rho T: ',num2str(data_proc.peaks.rhoT(ipeak))])
                        disp(['Position rho V: ',num2str(data_proc.peaks.rhoV(ipeak))])
                        disp(['Temperature Te: ',num2str(data_proc.peaks.Te(ipeak)),' keV'])
                        disp(['Density ne: ',num2str(data_proc.peaks.ne(ipeak)/1e20),' *10^20 m^-3'])
                        disp(' ');
                        disp(['RF power (P/2piRp): ',num2str(data_proc.peaks.p_rf_2piRp(ipeak)),' MW/m'])
                        disp(['Total current (I): ',num2str(data_proc.peaks.I_tot(ipeak)),' MA'])
                        disp(['CD efficiency (I*Rp/P): ',num2str(data_proc.peaks.EtaRp(ipeak)),' A.m/W'])
                        disp(['Normalized CD efficiency xi: ',num2str(data_proc.peaks.ksirf(ipeak))])
                    end
                end
                %
                if opt.wave == 'y',
                    %
                    for iw = 1:nw,
                        disp(' ');
                        disp('----------------------------------------');
                        disp(' ');
                        disp(['RF Wave # ',num2str(iw)])
                        disp(['Position rho G: ',num2str(data_proc.wave.wP_rf_rhoG(iw))])
                        disp(['Position rho P: ',num2str(data_proc.wave.wP_rf_rhoP(iw))])
                        disp(['Position rho T: ',num2str(data_proc.wave.wP_rf_rhoT(iw))])
                        disp(['Position rho V: ',num2str(data_proc.wave.wP_rf_rhoV(iw))])
                        disp(['Temperature Te: ',num2str(data_proc.wave.wTe(iw)),' keV'])
                        disp(['Density ne: ',num2str(data_proc.wave.wne(iw)/1e20),' *10^20 m^-3'])
                        disp(' ');
                        disp(['Launched RF power (P/2piRp): ',num2str(data_proc.wave.wp0_rf_2piRp(iw)),'MW/m'])
                        disp(['RF power absorbed (P/2piRp): ',num2str(data_proc.wave.wp_rf_2piRp(iw)),' MW/m ---> ',num2str(100*data_proc.wave.wp_rf_2piRp(iw)/data_proc.wave.wp0_rf_2piRp(iw)),' %.'])
                        for in_rf = 1:nn_rf,
                            disp(['RF power absorbed on harm. ',num2str(data_proc.wave.wn_rf_list(in_rf)),' (P/2piRp): ',num2strdata_proc.wave.(wnp_rf_2piRp(iw,in_rf)),' MW/m ---> ',num2str(100*data_proc.wave.wnp_rf_2piRp(iw,in_rf)/data_proc.wave.wp0_rf_2piRp(iw)),' %.'])
                        end
                        disp(['Linear RF power absorbed (P/2piRp): ',num2str(data_proc.wave.wp_rf_2piRp_lin(iw)),' MW/m ---> ',num2str(100*data_proc.wave.wp_rf_2piRp_lin(iw)/data_proc.wave.wp0_rf_2piRp(iw)),' %.'])
                    end
                end
                %
            else
                disp(['Launched RF power (P): ',num2str(data_proc.scalar.p0_rf_2piRp*(2*pi*data_proc.scalar.Rp)),' MW'])
                disp(['RF power absorbed (P): ',num2str(data_proc.scalar.p_rf_2piRp*(2*pi*data_proc.scalar.Rp)),' MW ---> ',num2str(100*data_proc.scalar.p_rf_2piRp/data_proc.scalar.p0_rf_2piRp),' %.'])
                for in_rf = 1:nn_rf,
                    disp(['RF power absorbed on harm. ',num2str(data_proc.scalar.n_rf_list(in_rf)),' (P): ',num2str(data_proc.scalar.np_rf_2piRp(in_rf)*(2*pi*data_proc.scalar.Rp)),' MW ---> ',num2str(100*data_proc.scalar.np_rf_2piRp(in_rf)/data_proc.scalar.p0_rf_2piRp),' %.'])
                end
                disp(['Linear RF power absorbed (P): ',num2str(data_proc.scalar.p_rf_2piRp_lin*(2*pi*data_proc.scalar.Rp)),' MW ---> ',num2str(100*data_proc.scalar.p_rf_2piRp_lin/data_proc.scalar.p0_rf_2piRp),' %.'])
                disp(['Ohmic power deposited (P): ',num2str(data_proc.scalar.p_e_2piRp*(2*pi*data_proc.scalar.Rp)),' MW'])
                disp(['Total power deposited (P): ',num2str(data_proc.scalar.p_tot_2piRp*(2*pi*data_proc.scalar.Rp)),' MW'])
                disp(['CD efficiency (I/P): ',num2str(data_proc.scalar.EtaRp/data_proc.scalar.Rp),' A/W'])
                %
                if opt.peak == 'y',
                    %
                    for ipeak = 1:length(data_proc.peaks.ir),
                        disp(' ');
                        disp('----------------------------------------');
                        disp(' ');
                        disp(['RF Peak # ',num2str(ipeak)])
                        disp(['Position rho G: ',num2str(data_proc.peaks.rhoG(ipeak))])
                        disp(['Position rho P: ',num2str(data_proc.peaks.rhoP(ipeak))])
                        disp(['Position rho T: ',num2str(data_proc.peaks.rhoT(ipeak))])
                        disp(['Position rho V: ',num2str(data_proc.peaks.rhoV(ipeak))])
                        disp(['Temperature Te: ',num2str(data_proc.peaks.Te(ipeak)),' keV'])
                        disp(['Density ne: ',num2str(data_proc.peaks.ne(ipeak)/1e20),' *10^20 m^-3'])
                        disp(' ');
                        disp(['RF power (P): ',num2str(data_proc.peaks.p_rf_2piRp(ipeak)*(2*pi*data_proc.scalar.Rp)),' MW'])
                        disp(['Total current (I): ',num2str(data_proc.peaks.I_tot(ipeak)),' MA'])
                        disp(['CD efficiency (I/P): ',num2str(data_proc.peaks.EtaRp(ipeak)/data_proc.scalar.Rp),' A/W'])
                        disp(['Normalized CD efficiency xi: ',num2str(data_proc.peaks.ksirf(ipeak))])
                    end
                end
                %
                if opt.wave == 'y',
                    %
                    for iw = 1:nw,
                        disp(' ');
                        disp('----------------------------------------');
                        disp(' ');
                        disp(['RF Wave # ',num2str(iw),' : ',data_proc.wave.wids{iw}])
                        disp(['Position rho G: ',num2str(data_proc.wave.wP_rf_rhoG(iw))])
                        disp(['Position rho P: ',num2str(data_proc.wave.wP_rf_rhoP(iw))])
                        disp(['Position rho T: ',num2str(data_proc.wave.wP_rf_rhoT(iw))])
                        disp(['Position rho V: ',num2str(data_proc.wave.wP_rf_rhoV(iw))])
                        disp(['Temperature Te: ',num2str(data_proc.wave.wTe(iw)),' keV'])
                        disp(['Density ne: ',num2str(data_proc.wave.wne(iw)/1e20),' *10^20 m^-3'])
                        disp(' ');
                        disp(['Launched RF power (P): ',num2str(data_proc.wave.wp0_rf_2piRp(iw)*(2*pi*data_proc.scalar.Rp)),'MW'])
                        disp(['RF power absorbed (P): ',num2str(data_proc.wave.wp_rf_2piRp(iw)*(2*pi*data_proc.scalar.Rp)),' MW ---> ',num2str(100*data_proc.wave.wp_rf_2piRp(iw)/data_proc.wave.wp0_rf_2piRp(iw)),' %.'])
                        for in_rf = 1:nn_rf,
                            disp(['RF power absorbed on harm. ',num2str(data_proc.wave.wn_rf_list(in_rf)),' (P): ',num2str(data_proc.wave.wnp_rf_2piRp(iw,in_rf)*(2*pi*data_proc.scalar.Rp)),' MW ---> ',num2str(100*data_proc.wave.wnp_rf_2piRp(iw,in_rf)/data_proc.wave.wp0_rf_2piRp(iw)),' %.'])
                        end
                        disp(['Linear RF power absorbed (P): ',num2str(data_proc.wave.wp_rf_2piRp_lin(iw)*(2*pi*data_proc.scalar.Rp)),' MW ---> ',num2str(100*data_proc.wave.wp_rf_2piRp_lin(iw)/data_proc.wave.wp0_rf_2piRp(iw)),' %.'])
                    end
                end
            end
            %
            diary off
            %
            % RF power density profile
            %
            if ~isfield(opt,'axs'),
                red = 0.9;
                lspace = 0.7;
                lspace2 = 0.5;
                bspace = 0.7;
                bspace2 = 0.5;
                %
            else
                red = 1;
                lspace = NaN;
                lspace2 = NaN;
                bspace = NaN;
                bspace2 = NaN;
                %
            end   
            %
            tit = '';
            %
            xlim_rho = [0,1];
            xtick_rho = 0:0.2:1;
            %
            if ~isfield(opt,'axs'),
                %
                figure(1),clf,set(1,'Name',['RF power density profile - ',data_proc.simul.id])
                %
                ylab = 'P_{RF} (MW/m^3)';
                %
                graph1D_jd(xrho,data_proc.radial.P_rf,0,0,xlab_rho,ylab,tit,NaN,xlim_rho,NaN,style,marker1,color2,width2,opt.font,gca,red,lspace,bspace);
                %
                set(gca,'xtick',xtick_rho);
                %
                print_jd(p_opt,[data_proc.simul.id,'_Prf_profile'],'figures_LUKE');
                %
            end
            %
            % power dPdrho profile - comparison with linear profile
            %
            if ~isfield(opt,'axs'),
                figure(101),clf,set(101,'Name',['Ohmic power density profile - ',data_proc.simul.id])
                ax = gca;
            else
                ax = opt.axs(1);
            end          
            %
            ylab = 'P_{RF}/d\rho/(2\piR_p) (MW/m)';
            %
            leg = {'linear','LUKE'};
            %
            graph1D_jd(xrho,data_proc.radial.xp_rf_2piRp_lin./dxrho,0,0,'','','',NaN,xlim_rho,NaN,style,marker,color3,width,opt.font,ax);
            graph1D_jd(xrho,data_proc.radial.xp_rf_2piRp./dxrho,0,0,xlab_rho,ylab,tit,leg,xlim_rho,NaN,style,marker1,color2,width2,opt.font,ax,red,lspace,bspace);
            %
            set(ax,'xtick',xtick_rho);
            %
            print_jd(p_opt,[data_proc.simul.id,'_Prf_lincomp_profile'],'figures_LUKE');
            %
            % power dPdrho profiles - by wave number
            %
            if ~isfield(opt,'axs') && opt.wave == 'y' && nw > 1,
                %
                figure(101),clf,set(101,'Name',['RF power deposition profile per wave # - ',data_proc.simul.id])
                %
                leg = cell(1,2*nw);
                %
                for iw = 1:nw,
                    %
                    if ~isempty(data_proc.wave.wids{iw}),
                        leg{nw+iw} = data_proc.wave.wids{iw};
                    else
                        leg{nw+iw} = ['# ',num2str(iw)];
                    end
                    leg{iw} = [leg{nw+iw},' (linear)'];
                end
                %
                for iw = 1:nw,
                    graph1D_jd(xrho,data_proc.wave.wxp_rf_2piRp_lin(iw,:)./dxrho,0,0,'','','',NaN,xlim_rho,NaN,style2,marker,colors{iw},width,opt.font);
                end
                %
                for iw = 1:nw-1,
                    graph1D_jd(xrho,data_proc.wave.wxp_rf_2piRp(iw,:)./dxrho,0,0,'','','',NaN,xlim_rho,NaN,style,marker1,colors{iw},width2,opt.font);
                end
                graph1D_jd(xrho,data_proc.wave.wxp_rf_2piRp(nw,:)./dxrho,0,0,xlab_rho,ylab,tit,leg,xlim_rho,NaN,style,marker1,colors{nw},width2,opt.font,gca,red,lspace,bspace);
                %
                set(gca,'xtick',xtick_rho);
                %
                print_jd(p_opt,[data_proc.simul.id,'_Prf_wave_profile'],'figures_LUKE');
                %
            end
            %
            % power dPdrho profiles - by harmonic number
            %
            if ~isfield(opt,'axs') && nn_rf > 1,
                %
                figure(102),clf,set(102,'Name',['RF power deposition profile per harmonic # - ',data_proc.simul.id])
                %
                leg = cell(1,nn_rf);
                %
                for in_rf = 1:nn_rf,
                    leg{in_rf} = ['n = ',num2str(data_proc.scalar.n_rf_list(in_rf))];
                end
                %
                graph1D_jd(xrho,data_proc.radial.xnp_rf_2piRp./repmat(dxrho.',[1,nn_rf]),0,0,xlab_rho,ylab,tit,leg,xlim_rho,NaN,style,marker1,NaN,width2,opt.font,gca,red,lspace,bspace);
                %
                set(gca,'xtick',xtick_rho);
                %
                print_jd(p_opt,[data_proc.simul.id,'_Prf_nrf_profile'],'figures_LUKE');
                %
            end
            %
            % Ohmic power density profile
            %
            if ~isfield(opt,'axs'),
                figure(2),clf,set(2,'Name',['Ohmic power density profile - ',data_proc.simul.id])
                ax = gca;
            else
                ax = opt.axs(2);
            end          
            %
            ylab = 'P_{OHM} (MW/m^3)';
            %
            graph1D_jd(xrho,data_proc.radial.P_e,0,0,xlab_rho,ylab,tit,NaN,xlim_rho,NaN,style,marker1,color2,width2,opt.font,ax,red,lspace,bspace);
            %
            set(ax,'xtick',xtick_rho);
            %
            print_jd(p_opt,[data_proc.simul.id,'_Pe_profile'],'figures_LUKE');
            %
            % Total power density profile
            %
            if ~isfield(opt,'axs'),
                %
                figure(3),clf,set(3,'Name',['Total power density profile - ',data_proc.simul.id])
                %
                ylab = 'P_{TOT} (MW/m^3)';
                %
                graph1D_jd(xrho,data_proc.radial.P_tot,0,0,xlab_rho,ylab,tit,NaN,xlim_rho,NaN,style,marker1,color2,width2,opt.font,gca,red,lspace,bspace);
                %
                set(gca,'xtick',xtick_rho);
                %
                print_jd(p_opt,[data_proc.simul.id,'_Ptot_profile'],'figures_LUKE');
                %
            end
            %
            % current profile (positive for co-current)
            %
            if ~isfield(opt,'axs'),
                figure(4),clf,set(4,'Name',['Co-current density profile - ',data_proc.simul.id])
                ax = gca;
            else
                ax = opt.axs(3);
            end   
            %
            ylab = 'J (MA/m^2)';
            %
            graph1D_jd(xrho,data_proc.radial.J_tot,0,0,xlab_rho,ylab,tit,NaN,xlim_rho,NaN,style,marker1,color2,width2,opt.font,ax,red,lspace,bspace);
            %
            set(ax,'xtick',xtick_rho);
            %
            print_jd(p_opt,[data_proc.simul.id,'_J_profile'],'figures_LUKE');
            %
            % parallel momentum transfer rate profile
            %
            if ~isfield(opt,'axs'),
                %
                figure(401),clf,set(3,'Name',['Parallel Momentum transfer rate density profile - ',data_proc.simul.id])
                %
                ylab = 'dp_{RF}/dt (N/m^3)';
                %
                graph1D_jd(xrho,data_proc.radial.xdpdt_rf,0,0,xlab_rho,ylab,tit,NaN,xlim_rho,NaN,style,marker1,color2,width2,opt.font,gca,red,lspace,bspace);
                %
                set(gca,'xtick',xtick_rho);
                %
                print_jd(p_opt,[data_proc.simul.id,'_Ptrans_profile'],'figures_LUKE');
                %
            end
            %
            % current convergence
            %
            if ~isfield(opt,'axs') && isfield(data_proc,'timevol') && isfield(data_proc.timevol,'I_tot_rf'),
                %
                figure(402),clf,set(402,'Name',['Current convergence - ',data_proc.simul.id])
                %
                xlab = 'RF iterations';
                ylab = 'I (MA)';
                xlim = [0,nit_rf + 1];
                %
                if ~isnan(I_exp),
                    graph1D_jd(xlim,I_exp*[1,1],0,0,'','','',NaN,xlim,NaN,style,marker,color1,width2,opt.font);
                end
                graph1D_jd(1:nit_rf,data_proc.timevol.I_tot_rf,0,0,xlab,ylab,tit,NaN,xlim,0,style,marker1,color2,width2,opt.font,gca,red,lspace,bspace);
                %
                print_jd(p_opt,[data_proc.simul.id,'_I_convergence'],'figures_LUKE');
            end
            %
            % rf convergence
            %
            if ~isfield(opt,'axs') && ~all(isnan(data_proc.simul.residue_rf)),
                %
                figure(403),clf,set(403,'Name',['RF convergence - ',data_proc.simul.id])
                %
                xlab = 'RF iterations';
                ylab = 'Conv. Param.';
                xlim = [0,nit_rf + 1];
                %
                graph1D_jd(1:nit_rf,data_proc.simul.residue_rf,0,1,xlab,ylab,tit,NaN,xlim,NaN,style,marker1,color2,width2,opt.font,gca,red,lspace,bspace);
                %
                print_jd(p_opt,[data_proc.simul.id,'_RF_convergence'],'figures_LUKE');
            end
            %
            % efficiency profile
            %
            if ~isfield(opt,'axs'),
                %
                figure(5),clf,set(5,'Name',['Current efficiency profile - ',data_proc.simul.id])
                %
                ylab = '\eta (A.m/W)';
                %
                if ~isnan(data_proc.scalar.P_rf_rhoG),
                    eta_peak = interp1(data_proc.radial.xrhoG,data_proc.radial.eta,data_proc.scalar.P_rf_rhoG);
                elseif ~isnan(data_proc.scalar.jrhoG),
                    eta_peak = interp1(data_proc.radial.xrhoG,data_proc.radial.eta,data_proc.scalar.jrhoG);
                else
                    eta_peak = max(abs(data_proc.radial.eta));
                end
                ylim = 2*[min([0,eta_peak]),max([0,eta_peak])];
                %
                graph1D_jd(xrho,data_proc.radial.eta,0,0,xlab_rho,ylab,tit,NaN,xlim_rho,ylim,style,marker1,color2,width2,opt.font,gca,red,lspace,bspace);
                set(gca,'xtick',xtick_rho);
                %
                print_jd(p_opt,[data_proc.simul.id,'_eta_profile'],'figures_LUKE');
                %
            end
            %
            % combined current and power density profiles
            %
            if ~isfield(opt,'axs'),
                %
                figure(6),clf,set(6,'Name',['Current and RF power density profiles - ',data_proc.simul.id])
                %    
                ylab1 = 'J (MA/m^2)';
                ylab2 = 'P_{RF} (MW/m^3)';
                ylim1 = NaN;
                ylim2 = NaN;
                %
                graph1D2jd(xrho,data_proc.radial.J_tot,xrho,data_proc.radial.P_rf,xlab_rho,ylab1,ylab2,tit,xlim_rho,ylim1,ylim2,...
                style,marker1,color2,width2,style,marker1,color3,width2,opt.font,red,lspace2,bspace);
                %
                print_jd(p_opt,[data_proc.simul.id,'_J_Prf_profile'],'figures_LUKE');
                %
            end
            %
            % magnetic ripple losses
            %
            if ~isfield(opt,'axs') && exist('Zmripple','var'),
                if ~isempty(Zmripple) && sum(sum(Zmripple.Xnhuloss)) ~= 0,
                    figure(7),clf,set(7,'Name',['Magnetic ripple losses - ',data_proc.simul.id])
                    [ax] = graph1D_jd(xrho,dke_out.xMRR_flux,0,0,'\rho','Ripple losses (m-3.s-1)',subtitle,NaN,[0,1],[0,max(max([dke_out.xMRR_flux(:),dke_out.xMRR_tau(:)]))],style,marker1,color2,width2,opt.font,gca,red,lspace,bspace);hold on
                    [ax] = graph1D_jd(xrho,dke_out.xMRR_tau,0,0,'\rho','Ripple losses (m-3.s-1)',subtitle,NaN,[0,1],[0,max(max([dke_out.xMRR_flux(:),dke_out.xMRR_tau(:)]))],style,marker1,color3,width2,opt.font,gca,red,lspace,bspace);hold on
                    legend('Boundary losses','Volumic losses');
                    print_jd(p_opt,[data_proc.simul.id,'_RippleLosses_profile'],'figures_LUKE');
                    %
                    figure(8),clf,set(8,'Name',['Cones angles - ',data_proc.simul.id])
                    [ax] = graph1D_jd(xrho,Zmripple.xthetabanana,0,0,'\rho','Angle (Deg.)',subtitle,NaN,[0,1],[0,60],style,marker1,color2,width2,opt.font,gca,red,lspace,bspace);hold on
                    [ax] = graph1D_jd(xrho,Zmripple.xthetaloss,0,0,'\rho','Angle (Deg.)',subtitle,NaN,[0,1],[0,60],style,marker1,color3,width2,opt.font,gca,red,lspace,bspace);hold on
                    legend('Banana cone angle','Loss cone angle');
                    print_jd(p_opt,[data_proc.simul.id,'_RippleConeAngles_profile'],'figures_LUKE');
                    %
                    ylab1 = 'p/p_{Te}';
                    ylab2 = 'p/p_{Te(loc.)}';
                    ytick = [0:2:10];
                    ylim1 = [0,10];
                    ylim2 = [0,40];
                    figure(9),clf,set(9,'Name',['Collision detrapping threshold - ',data_proc.simul.id])
                    [ax] = graph1D_jd(xrho,Zmripple.xpndetrap,0,0,'\rho','',subtitle,NaN,[0,1],'',style,marker1,color2,width2,opt.font,gca,red,lspace,bspace);hold on
                    [ax] = graph1D_jd(xrho,Zmripple.xpnth,0,0,'\rho','',subtitle,NaN,[0,1],'',style,marker1,color3,width2,opt.font,gca,red,lspace,bspace);hold on
                    [ax] = graph1D2jd(xrho,Zmripple.xpnth,xrho,Zmripple.xpndetrap./Zmripple.xpnth,xlab,ylab1,ylab2,tit,xlim_rho,ylim1,ylim2,style,marker1,color3,width2,style,marker1,color4,width2,opt.font,red,lspace2,bspace);
                    set(gca,'ytick',ytick);
                    legend('p_{c}/p_{Te}','p_{Te(loc.)}/p_{Te}','p_{c}/p_{Te(loc.)}');
                    print_jd(p_opt,[data_proc.simul.id,'_RippleDetrapping_profile'],'figures_LUKE');
                end  
            end
            %
            if ~isfield(opt,'axs') && isfield(data_proc,'timevol') && isfield(data_proc.timevol,'I_tot_rf') && isfield(opt,'its_rf') && any(opt.its_rf),
                %
                if islogical(opt.its_rf),
                    its_rf = input_dke_yp('RF interation indices to compare',[1,nit_rf],[1;nit_rf]);
                else
                    its_rf = opt.its_rf;
                end
                %
                nits_rf = length(its_rf);
                %
                % current profile
                %
                figure(404),clf,set(404,'Name',['Current density profile it_rf comp - ',data_proc.simul.id])
                %
                ylab = 'J (MA/m^2)';
                leg = cell(1,nits_rf);
                %
                for iit_rf = 1:nits_rf-1,
                    graph1D_jd(xrho,Zcurr(its_rf(iit_rf),end).x_0_fsav*mksa.j_ref*scocurr,0,0,'','','',NaN,xlim_rho,NaN,style,marker1,colors{iit_rf},width2,opt.font);
                    leg{iit_rf} = ['Iteration # ',num2str(its_rf(iit_rf))];
                end
                leg{nits_rf} = ['Iteration # ',num2str(its_rf(nits_rf))];
                graph1D_jd(xrho,Zcurr(its_rf(nits_rf),end).x_0_fsav*mksa.j_ref*scocurr,0,0,xlab,ylab,tit,leg,xlim_rho,NaN,style,marker1,colors{nits_rf},width2,opt.font,gca,red,lspace,bspace);
                %
                set(ax,'xtick',xtick_rho);
                set(ax,'ytickmode','auto')
                %
                print_jd(p_opt,[data_proc.simul.id,'_J_rfcomp_profile'],'figures_LUKE');
                %
                % power profile
                %
                figure(405),clf,set(404,'Name',['Power density profile it_rf comp - ',data_proc.simul.id])
                %
                ylab = 'P_{RF} (MW/m^3)';
                %
                for iit_rf = 1:nits_rf-1,
                    graph1D_jd(xrho,ZP0(its_rf(iit_rf),end).x_rf_fsav.'*mksa.P_ref,0,0,'','','',NaN,xlim_rho,NaN,style,marker1,colors{iit_rf},width2,opt.font);
                end
                graph1D_jd(xrho,ZP0(its_rf(nits_rf),end).x_rf_fsav.'*mksa.P_ref,0,0,xlab,ylab,tit,leg,xlim_rho,NaN,style,marker1,colors{nits_rf},width2,opt.font,gca,red,lspace,bspace);
                %
                set(ax,'xtick',xtick_rho);
                set(ax,'ytickmode','auto')
                %
                print_jd(p_opt,[data_proc.simul.id,'_P_rfcomp_profile'],'figures_LUKE');
                %
            end
            %
            if opt.spec == 1
                disp('******** power absorption along specific rays ********');
                %
                iw = NaN;
                ibb = NaN;
                ib = 0;
                iwdef = 0;%1;
                %
                while iw ~= 0 && ibb ~= 0
                    %
                    ib = ib + 1;
                    %
                    iw = input_dke_yp('wave index (0 to return)',iwdef,0:nw,'',[1,1]);
                    %
                    if iw == 0,
                        continue
                    end
                    %
                    ibb = input_dke_yp('ray index (0 to return)',1,0:nb(iw),'',[1,1]);
                    %
                    if ibb == 0,
                        continue
                    end
                    %
                    iwdef = 0;
                    %
                    iy = sum(nb(1:iw - 1)) + ibb;
                    %
                    ray = waves{iw}.rays{ibb};
                    %
                    sS_c3po = ray.ss;
                    sP_c3po = ray.sP_2piRp_lin*2*pi*data_proc.scalar.Rp;
                    %
                    sS_luke = zS{iy};
                    sP_luke = zP_0_2piRp_mod{end}{iy}*2*pi*data_proc.scalar.Rp;
                    %
                    leg = {'Ray-Tracing','Fokker-Planck'};
                    %    
                    % power deposition
                    %
                    figlab = ['wave #',num2str(iw),'; ray #',num2str(ibb)];
                    %
                    figure(14+iy),clf;set(gcf,'name',figlab);
                    %
                    xlim = [0,max([sS_c3po,sS_luke])];
                    ylim = [0,1.2*max([sP_c3po,sP_luke])/1e3];
                    xlab = 's (m)';
                    ylab = 'P (kW)';
                    %
                    graph1D_jd(sS_c3po,sP_c3po/1e3,0,0,xlab,ylab,figlab,NaN,xlim,ylim,style2,marker,color3,width2,opt.font,gca,red,lspace,bspace2);
                    graph1D_jd(sS_luke,sP_luke/1e3,0,0,'','','',leg,xlim,ylim,style,marker2,color2,width2,opt.font);
                    %
                    if timevol == 2 && isfield(opt,'its_rf') && any(opt.its_rf) && length(zP_0_2piRp_mod) == nit_rf;
                        %
                        figure(414+iy),clf,set(404,'Name',['Power it_rf comp - ',figlab])
                        %
                        for iit_rf = 1:nits_rf-1,
                            graph1D_jd(sS_luke,zP_0_2piRp_mod{its_rf(iit_rf)}{iy}*2*pi*data_proc.scalar.Rp/1e3,0,0,'','','',NaN,xlim,ylim,style,marker1,colors{iit_rf},width2,opt.font);
                        end
                        graph1D_jd(sS_luke,zP_0_2piRp_mod{its_rf(nits_rf)}{iy}*2*pi*data_proc.scalar.Rp/1e3,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,colors{nits_rf},width2,opt.font,gca,red,lspace,bspace);
                        %
                        set(ax,'ytickmode','auto')
                        %
                    end
                    %
                end
            %
            end
            %
        else
            %
            disp(['normalized current: ',num2str(Zcurr(end).x_0_fsav)])
            disp(['normalized RF power: ',num2str(ZP0(end).x_rf_fsav)])
            disp(['normalized Ohmic power: ',num2str(ZP0(end).x_e_fsav)])
            disp(['normalized Total power: ',num2str(ZP0(end).x_e_fsav+ZP0(end).x_rf_fsav)])
            disp(['normalized CD efficiency: ',num2str(Zcurr(end).x_0_fsav./(ZP0(end).x_e_fsav+ZP0(end).x_rf_fsav))])
            %
            diary off
            %
        end
        %
    end
    %
    if ir_display > 0 && ir_display <= nr,
        %
        disp(['normalized radius for distribution plots: ',num2str(xrho(ir_display))])
        %
        Xf0 = dke_out.XXf0{end}(:,:,ir_display);
        Xfinit = dke_out.XXfinit(:,:,ir_display);
        Xmhu = repmat(mhu,[length(pn),1]);
        %
        Xlambda = repmat(Zbouncecoef.Xxlambda(:,ir_display).',[length(pn),1]);
        qtilde = Zbouncecoef.xqtilde(ir_display);
        qhat =  Zbouncecoef.xqhat(ir_display);
        %
        % energy-space density of current deposition
        %
        pdj0dp = scocurr*mksa.j_ref*2*pi*pn.*pn.*pn.*integral_dke_jd(dmhu,Xf0.*Xmhu,2).'./gamma;
        %
        % energy distribution function
        %
        pdN0_dEc_ref = 2*pi.*(qtilde./qhat).*integral_dke_jd(dmhu,Xlambda.*Xf0,2).'.*pn.*pn.*dpn./dEc_ref;
        pdNinit_dEc_ref = 2*pi.*(qtilde./qhat).*integral_dke_jd(dmhu,Xlambda.*Xfinit,2).'.*pn.*pn.*dpn./dEc_ref;
        %
        % spherical to cylindrical transformation
        %
        [logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xf0),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
        Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
        %
        logXfinit_cyl_ref = s2c_dke_yp(log(Xfinit),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
        Xfinit_cyl_ref = exp(logXfinit_cyl_ref);%For accurate representation in figures 
        %
        XDparpar_cyl_ref = s2c_dke_yp(dke_out.ZXXD_rf.parpar_ij(:,:,ir_display),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
        XDpp_cyl_ref = s2c_dke_yp(dke_out.ZXXD_rf.pp_ij(:,:,ir_display),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation    
        %
        Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';%Grid for the distribution functions only
        Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
        Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
        %
        Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
        Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
        Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
        %
        Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xfinit_cyl_ref>0);%Remove negative values
        Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
        Xfinit_cyl_ref(isnan(Xfinit_cyl_ref)) = 0;%Remove NaN values
        %
        % Remove values less than computer accuracy
        %
        Xmask = abs(Xf0_cyl_ref) < eps;
        %
        pnmax_S = max(momentumDKE.pn_S);
        pnmax_0 = min(min(Xp_cyl_ref(Xmask)));
        %
        if isnan(pnmax),
            pnmax = min([pnmax_0,pnmax_S]);
        end
        %
        Xmask = Xp_cyl_ref >= pnmax;    
        %
        Xf0_cyl_ref(Xmask) = 0;
        Xfinit_cyl_ref(Xmask) = 0;
        XDparpar_cyl_ref(Xmask) = 0;
        XDpp_cyl_ref(Xmask) = 0;
        %
        Fpar0_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_cyl_ref,1);
        Fparinit_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xfinit_cyl_ref,1);	
        %
        data_proc.cyl.ppar_ref = ppar_cyl_ref;
        data_proc.cyl.Fpar0_ref = Fpar0_cyl_ref;
        data_proc.cyl.Fparinit_ref = Fparinit_cyl_ref;
        data_proc.cyl.Dparpar_ref = XDparpar_cyl_ref(1,:);
        %
        nhnorm = mean((Xfinit(1,:) - Xf0(1,:))./Xfinit(1,:));
        %
        disp(['Fraction of suprathermal electrons : ',num2str(nhnorm)]);
        %
        Xfh_cyl_ref = (Xf0_cyl_ref - (1 - nhnorm)*Xfinit_cyl_ref)/nhnorm;
        %
        % Figures
        %
        radialloc = ['\rho = ',num2str(xrho(ir_display))];
        %
        % ---------- energy-space density of current deposition -----------
        %
        figure(10),clf,set(10,'Name',['dj/dp - ',data_proc.simul.id])
        %
        xlab = 'p/p_{Te}';
        ylab = 'dj/dp_n (MA/m^2)';
        xlim = [0,pnmax];
        %
        graph1D_jd(pn,pdj0dp,0,0,xlab,ylab,[radialloc,' ; dj/dp positive for co-current'],NaN,xlim,NaN,style,marker,color2,width2,opt.font,gca,red,lspace,bspace2);
        %
        print_jd(p_opt,[data_proc.simul.id,'_djdp_',tir_display],'figures_LUKE');
        %
        % ---------- 2D distribution function -----------
        %
        figure(11),clf,set(11,'Name',['2-D contour of f - ',data_proc.simul.id])
        %
        x1 = ppar_cyl_ref;
        xlab1 = 'p_{||}/p_{Te}';
        xlim1 = [-pnmax,pnmax];
        %
        x2 = pperp_cyl_ref;
        xlab2 = 'p_{\perp}/p_{Te}';
        xlim2 = [0,pnmax];
        %
        leg = {'f_M','f'};
        %
        y1 = Xfinit_cyl_ref;
        y2 = Xf0_cyl_ref;
        %
        if max(max(XDparpar_cyl_ref)) > max(max(XDpp_cyl_ref)),
            y3 = XDparpar_cyl_ref;
            y3lab = 'D||';
        else
            y3 = XDpp_cyl_ref;
            y3lab = 'Dpp';
        end
        y3max = max(max(y3));
        %
        y9 = sqrt(pnmax^2 - x1.^2);
        %
        graph2D_jd(x1,x2,y1','','',radialloc,xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color3,width,opt.font,1,max(max(y1)));
        hold on
        graph2D_jd(x1,x2,y2','','',radialloc,xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color2,width2,opt.font,1,max(max(y1)));
        %
        if y3max > 1e-5,
            graph2D_jd(x1,x2,y3','','',radialloc,xlim1,xlim2,0,NaN,y3max/100,0,style,color4,width2,opt.font);
        end
        hold off
        %
        graph1D_jd(x1,y9,0,0,xlab1,xlab2,radialloc,NaN,xlim1,xlim2,style,marker,color1,width2,opt.font,gca,red,lspace,bspace2);
        %
        axis('equal');axis([xlim1,xlim2]);
        legend(leg);
        %
        if data_proc.scalar.Rp ~= Inf,
            bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,Zmripple);
        end
        %
        print_jd(p_opt,[data_proc.simul.id,'_f_2D',tir_display],'figures_LUKE');
        %
        if max(max(abs(y3))) > 0,
            %
            figure(12),clf,set(12,'Name',['2-D contour of ',y3lab,' - ',data_proc.simul.id])
            %
            cont = input_dke_yp('contours for DQL',10);
            %
            graph2D_jd(x1,x2,y3','','',radialloc,xlim1,xlim2,1,NaN,cont,0,style,NaN,width,opt.font,1);
            graph1D_jd(x1,y9,0,0,xlab1,xlab2,radialloc,NaN,xlim1,xlim2,style,marker,color1,width2,opt.font,gca,red,lspace,bspace2);
            axis('equal');axis([xlim1,xlim2])
            %
            if data_proc.scalar.Rp ~= Inf,
                bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,Zmripple);
            end
            colorbar
            %
            print_jd(p_opt,[data_proc.simul.id,'_DQL',tir_display],'figures_LUKE');
            %
            if strcmp(y3lab,'D||'),
                %
                figure(121),clf,set(121,'Name',['1-D plot of ',y3lab,' - ',data_proc.simul.id])
                %
                y1 = y3(1,:);
                ylab = 'D_{||} (p_\perp = 0)';
                %
                graph1D_jd(x1,y1,0,0,xlab1,ylab,radialloc,NaN,xlim1,NaN,style,marker,color2,width2,opt.font,gca,red,lspace,bspace2);
                %
                print_jd(p_opt,[data_proc.simul.id,'_DQL_1D',tir_display],'figures_LUKE');
                %
            end
        end
        %
        % ---------- 2D suprathermal distribution function -----------
        %
        figure(111),clf,set(11,'Name',['2-D contour of fh - ',data_proc.simul.id])
        %
        x1 = ppar_cyl_ref;
        xlab1 = 'p_{||}/p_{Te}';
        xlim1 = [-pnmax,pnmax];
        %
        x2 = pperp_cyl_ref;
        xlab2 = 'p_{\perp}/p_{Te}';
        xlim2 = [0,pnmax];
        %
        y = Xfh_cyl_ref;
        %
        if max(max(XDparpar_cyl_ref)) > max(max(XDpp_cyl_ref)),
            y3 = XDparpar_cyl_ref;
            y3lab = 'D||';
        else
            y3 = XDpp_cyl_ref;
            y3lab = 'Dpp';
        end
        y3max = max(max(y3));
        %
        y9 = sqrt(pnmax^2 - x1.^2);
        %
        graph2D_jd(x1,x2,y','','',radialloc,xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color3,width,opt.font,1,max(max(y1)));
        hold on
        %
        if y3max > 1e-5,
            graph2D_jd(x1,x2,y3','','',radialloc,xlim1,xlim2,0,NaN,y3max/100,0,style,color4,width2,opt.font);
        end
        hold off
        %
        graph1D_jd(x1,y9,0,0,xlab1,xlab2,radialloc,NaN,xlim1,xlim2,style,marker,color1,width2,opt.font,gca,red,lspace,bspace2);
        %
        axis('equal');axis([xlim1,xlim2]);
        legend(leg);
        %
        if data_proc.scalar.Rp ~= Inf,
            bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,Zmripple);
        end
        %
        print_jd(p_opt,[data_proc.simul.id,'_fh_2D',tir_display],'figures_LUKE');
        %
        %
        % ---------- parallel distribution difference-----------
        %
        figure(13),clf,set(13,'Name',['F||-F||M - ',data_proc.simul.id])
        %
        y1 = Fpar0_cyl_ref - Fparinit_cyl_ref;
        ylab = 'F_{||} - F_{||M}';
        %
        graph1D_jd(x1,y1,0,0,xlab1,ylab,radialloc,NaN,xlim1,NaN,style,marker,color2,width2,opt.font,gca,red,lspace,bspace2);
        %
        print_jd(p_opt,[data_proc.simul.id,'_F0mFM_1D',tir_display],'figures_LUKE');
        %
        % ---------- parallel distribution -----------
        %
        figure(14),clf,set(14,'Name',['F|| - ',data_proc.simul.id])
        %
        y1 = Fparinit_cyl_ref;
        y2 = Fpar0_cyl_ref;
        ylab = 'F_{||}';
        ylim = [eps,1];
        %
        graph1D_jd(x1,y1,0,1,'','',radialloc,NaN,xlim1,ylim,style,marker,color3,width,opt.font,gca,red,lspace,bspace2);
        graph1D_jd(x1,y2,0,1,xlab1,ylab,radialloc,leg,xlim1,ylim,style,marker,color2,width2,opt.font);
        legend(leg);
        %
        print_jd(p_opt,[data_proc.simul.id,'_F0pFM_1D_',tir_display],'figures_LUKE');
        %
        % ---------- energy distribution -----------
        %
        figure(15),clf,set(14,'Name',['dNdEc - ',data_proc.simul.id])
        %
        x1 = Ec_ref;
        xlab1 = 'E_c (keV)';
        xlim1 = [0,max(x1)];
        y1 = pdNinit_dEc_ref;
        y2 = pdN0_dEc_ref;
        ylab = 'dn_e/dE_c/n_0 (keV^{-1})';
        %
        graph1D_jd(x1,y1,0,1,'','',radialloc,NaN,xlim1,NaN,style2,marker,color3,width2,opt.font,gca,red,lspace,bspace2);
        graph1D_jd(x1,y2,0,1,xlab1,ylab,radialloc,leg,xlim1,NaN,style,marker,color2,width2,opt.font);
        legend(leg);
        %
        print_jd(p_opt,[data_proc.simul.id,'_dNdEc_',tir_display],'figures_LUKE');
        %
    end
end
%
function [rho,drho] = calc_peak_jd(xrho,xdrho,xQ,xdV,opt_dens,opt_peak)
%
% This function calculates the peak and width of some quantity density profile. There are various options.
%
%   INPUTS :
%       - xrho      : radial grid
%       - xdrho     : radial grid steps
%       - xQ        : quantity density profile (can be current, power, ...)
%       - xdV       : poloidal incremental volume (or surface...) of a flux surface
%       - opt_dens 	: (0) find peak on dQ*xdV/drho, (1) find peak on xQ
%       - opt_peak  : (0) peak is discrete point of max value (1) peak calculated as a moment of xrho weigthed by quantity profile
%
%   OUTPUTS :
%       - rho   : peak position
%       - drho  : FWHM
%
    %
    nr = length(xrho);
    %
    if opt_dens == 0,%peak defined on xQ.*xdV./xdrho profile
        xprof = xQ.*xdV./xdrho;% profile
        xint = xQ.*xdV;% incremental contributions
    else% peak defined on xQ profile
        xprof = xQ;% profile
        xint = xQ.*xdrho;% incremental contributions
    end 
    %
    profmax = max(abs(xprof));
    ipeak = find(abs(xprof) == profmax,1,'first');% peak on absolute value
    peaksign = sign(xprof(ipeak));
    %
    xmaskp = ipeak:nr;
    xmaskm = 1:ipeak;
    %
    if opt_peak == 0,%peak is discrete point of max value
        %
        ixp = find(diff(xprof(xmaskp))*peaksign >= 0,1,'first');
        xmaskp = xmaskp(1:min([ixp,length(xmaskp)]));% first point for the current lobe containing peak
        %
        ixm = 1 + find(diff(xprof(xmaskm))*peaksign <= 0,1,'last');
        xmaskm = xmaskm(max([1,ixm]):end);% last point for the current lobe containing peak
        %
        rho = xrho(ipeak);
        drho = interp1(peaksign*xprof(xmaskp),xrho(xmaskp),profmax/2) - interp1(peaksign*xprof(xmaskm),xrho(xmaskm),profmax/2);% FWHM
    else
        %
        ixp = find(xint(xmaskp)*peaksign <= 0,1,'first') - 1;
        xmaskp = xmaskp(1:min([ixp,length(xmaskp)]));
        %
        ixm = find(xint(xmaskm)*peaksign <= 0,1,'last') + 1;
        xmaskm = xmaskm(max([1,ixm]):end);
        %
        xmask = unique([xmaskm,xmaskp]);% select points around peak up to change in sign
        %
        rho = sum(xint(xmask).*xrho(xmask))/sum(xint(xmask));
        drho = 2*sqrt(2*log(2))*sqrt(sum(xint(xmask).*(xrho(xmask) - rho).^2)/sum(xint(xmask)));
    end
end

