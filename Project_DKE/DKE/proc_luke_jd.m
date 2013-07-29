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
    opt.nr_dep = '';
    opt.peak = '';
    opt.wave = '';
    opt.peakmode = 0;
    opt.rho = '';
    opt.spec = 1;
    opt.blist = '';
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
    ir_display = 0;
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
Znorm = data.Znorm;
Zcurr = data.Zcurr;
ZP0 = data.ZP0;
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
simul_id = dke_out.simul.id;
waves = proc_wave_alphaphi_luke_jd(data,dke_out.waves,1);
if isfield(dke_out,'dkeparam')
    dkeparam = dke_out.dkeparam;
elseif isfield(data,'dkeparam')
    dkeparam = data.dkeparam;
else
    dkeparam = struct;
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
siz = 20;
%
red = 0.9;
lspace = 0.7;
lspace2 = 0.5;
bspace = 0.7;
bspace2 = 0.5;
%
xrhoG = equilDKE.xrho; 
xrhoP = equilDKE.xrhoP; 
xrhoT = equilDKE.xrhoT; 
xrhoV = equilDKE.xrhoV; 
%
% grids for interpolation
%
xrhoG_I = [0,xrhoG,1];
xrhoP_I = [0,xrhoP,1];
xrhoT_I = [0,xrhoT,1];
xrhoV_I = [0,xrhoV,1];
%
xrhoG_S = radialDKE.xrho_S_dke;
%
if opt.rho == 'g',
    xrho = xrhoG;
    xrho_S = xrhoG_S;
elseif  opt.rho == 'p',
    xrho = xrhoP;
    xrho_S = sqrt(radialDKE.xpsin_S_dke);
elseif  opt.rho == 't',
    xrho = xrhoT;
    xrho_S = [0,interp1(xrhoG,xrhoT,radialDKE.xrho_S_dke(2:end-1),'spline'),1];
elseif  opt.rho == 'v',
    xrho = xrhoV;
    xrho_S = [0,interp1(xrhoG,xrhoV,radialDKE.xrho_S_dke(2:end-1),'spline'),1];
end
xdrho = diff(xrho_S);
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
if isfield(dkeparam,'timevol') && dkeparam.timevol == 1,
    timevol = 1;
else
    timevol = 0;
end
%
scocurr = sign(equilDKE.psia_apRp)*sign(equilDKE.XBphi(1,1));
%
J_tot = Zcurr(end).x_0_fsav*mksa.j_ref*scocurr;
P_rf = ZP0(end).x_rf_fsav.'*mksa.P_ref;
yP_rf = ZP0(end).xy_rf_fsav.'*mksa.P_ref;
ynP_rf = ZP0(end).xyn_rf_fsav*mksa.P_ref;
P_e = ZP0(end).x_e_fsav*mksa.P_ref;
P_tot = P_rf + P_e;
%
% parallel momentum
%
np = length(pn);
nmhu = length(mhu);
%
XXpnm = repmat(momentumDKE.pn_S(1:end-1).',[1,nmhu,nr]);
XXpn = repmat(pn.',[1,nmhu,nr]);
XXpnp = repmat(momentumDKE.pn_S(2:end).',[1,nmhu,nr]);
XXmhu = repmat(mhu,[np,1,nr]);
XX1mmhu2m = repmat(1 - momentumDKE.mhu_S(1:end-1).*momentumDKE.mhu_S(1:end-1),[np,1,nr]);
XX1mmhu2p = repmat(1 - momentumDKE.mhu_S(2:end).*momentumDKE.mhu_S(2:end),[np,1,nr]);
%
XXIntegrand_im = XXpnm.*XXpnm.*XXmhu;
XXIntegrand_ip = XXpnp.*XXpnp.*XXmhu;
%
XXIntegrand_jm = XXpn.*XXpn.*sqrt(XX1mmhu2m);
XXIntegrand_jp = XXpn.*XXpn.*sqrt(XX1mmhu2p);
%
Zmom.x_rf = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXIntegrand_im.*dke_out.ZXXS.p0_rf_imj + XXIntegrand_ip.*dke_out.ZXXS.p0_rf_ipj)/2,1),1).'...
           -2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXIntegrand_jm.*dke_out.ZXXS.m0_rf_ijm + XXIntegrand_jp.*dke_out.ZXXS.m0_rf_ijp)/2,1),1).';
%
[~,me,~,~,~,~,~,~,clum] = pc_dke_yp;%Universal physics constants
dpdt_ref = me*clum*mksa.betath_ref*mksa.nhu_ref*mksa.ne_ref; %power normalization constant (N/m^3)
dpdt_rf = Zmom.x_rf*dpdt_ref;
%
if isfield(dke_out,'residue_rf'),
    if iscell(dke_out.residue_rf),
        residue_rf = dke_out.residue_rf{end}(end);
    else
        residue_rf = dke_out.residue_rf(end);
    end
else
    residue_rf = NaN;
end
%
if isfield(dke_out,'zS'),
    zS = dke_out.zS;
    zP_0_2piRp_mod = dke_out.zP_0_2piRp_mod{end};
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
    disp(['WARNING : n_rf_list not determined.'])
end
%
I_tot = sum(J_tot.*equilDKE.xdA_dke);
%
if opt.jpeak == 0,%peak defined as dIdrho
    xI = J_tot.*equilDKE.xdA_dke;
    xdIdrho = xI./xdrho;
else% peak defined as J
    xI = J_tot.*xdrho;
    xdIdrho = J_tot;
end    
dIdrhomax = max(xdIdrho);
wi_jpeak = find(xdIdrho == dIdrhomax);% co-current peak
%
xmaskp = wi_jpeak:nr;
ixp = find(diff(xdIdrho(xmaskp)) >= 0,1,'first');
xmaskp = xmaskp(1:min([ixp,length(xmaskp)]));
%
xmaskm = 1:wi_jpeak;
ixm = 1 + find(diff(xdIdrho(xmaskm)) <= 0,1,'last');
xmaskm = xmaskm(max([1,ixm]):end);
%
if opt.peakmode == 0,
    jrhoG = xrhoG(wi_jpeak);
    jrhoP = xrhoP(wi_jpeak);
    jrhoT = xrhoT(wi_jpeak);
    jrhoV = xrhoV(wi_jpeak);
    jTe = xTe(wi_jpeak);
    jne= xne(wi_jpeak);
    %
    % FWHM
    %
    jdrhoG = interp1(xdIdrho(xmaskp),xrhoG(xmaskp),dIdrhomax/2) - interp1(xdIdrho(xmaskm),xrhoG(xmaskm),dIdrhomax/2);
    jdrhoP = interp1(xdIdrho(xmaskp),xrhoP(xmaskp),dIdrhomax/2) - interp1(xdIdrho(xmaskm),xrhoP(xmaskm),dIdrhomax/2);
    jdrhoT = interp1(xdIdrho(xmaskp),xrhoT(xmaskp),dIdrhomax/2) - interp1(xdIdrho(xmaskm),xrhoT(xmaskm),dIdrhomax/2);
    jdrhoV = interp1(xdIdrho(xmaskp),xrhoV(xmaskp),dIdrhomax/2) - interp1(xdIdrho(xmaskm),xrhoV(xmaskm),dIdrhomax/2);
else
    %
    %xmaskj = unique([xmaskm,xmaskp]);
    %xmaskj = xmaskj(xI(xmaskj) >= 0);
    %
    xmaskp = wi_jpeak:nr;
    ixp = find(xI(xmaskp) <= 0,1,'first') - 1;
    xmaskp = xmaskp(1:min([ixp,length(xmaskp)]));
    %
    xmaskm = 1:wi_jpeak;
    ixm = find(xI(xmaskm) <= 0,1,'last') + 1;
    xmaskm = xmaskm(max([1,ixm]):end);
    %
    xmaskj = unique([xmaskm,xmaskp]);
    %
    I_totj = sum(xI(xmaskj));
    %
    jrhoG = sum(xI(xmaskj).*xrhoG(xmaskj))/I_totj;
    jrhoP = interp1(xrhoG,xrhoP,jrhoG);
    jrhoT = interp1(xrhoG,xrhoT,jrhoG);
    jrhoV = interp1(xrhoG,xrhoV,jrhoG);
    jTe = interp1(xrhoG,xTe,jrhoG);
    jne = interp1(xrhoG,xne,jrhoG);
    %
    % FWHM
    %
    jdrhoG = 2*sqrt(2*log(2))*sqrt(sum(xI(xmaskj).*(xrhoG(xmaskj) - jrhoG).^2)/I_totj);
    jdrhoP = 2*sqrt(2*log(2))*sqrt(sum(xI(xmaskj).*(xrhoP(xmaskj) - jrhoP).^2)/I_totj);
    jdrhoT = 2*sqrt(2*log(2))*sqrt(sum(xI(xmaskj).*(xrhoT(xmaskj) - jrhoT).^2)/I_totj);
    jdrhoV = 2*sqrt(2*log(2))*sqrt(sum(xI(xmaskj).*(xrhoV(xmaskj) - jrhoV).^2)/I_totj);
end
%            
if isempty(opt.nr_dep),
    nr_dep = input_dke_yp('Comparison with linear deposition : (-1) none, (0) on LUKE grid, or indicate the number of fine grid points',0,0:100,'',[1,1]);
else
    nr_dep = opt.nr_dep;
end
%
if isempty(opt.peak),
    opt_peak = input_dke_yp('Do you want to display specific information for each absorption peak? (y/n)','n',{'n','y'},'',[1,1]);
else
    opt_peak = opt.peak;
end
%
if isempty(opt.wave),
    opt_wave = input_dke_yp('Do you want to display specific information for each wave? (y/n)','n',{'n','y'},'',[1,1]);
else
    opt_wave = opt.wave;
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
if ir_display >= 0,
    %
    if isfield(opt,'diaryname') && ischar(opt.diaryname) && ~isempty(opt.diaryname),
        diaryname = opt.diaryname;
    else
        if ir_display == 0,
            diaryname = ['res_',simul_id,'.log'];
        else
            tir_display = num2str(ir_display);
            diaryname = ['res_',simul_id,'_irho_',tir_display,'.log'];
        end
        %
        if exist(diaryname,'file') && gettime_jd(diaryname) > datenum(timeid_jd(dke_out.simul.timeid),'mm/dd/yyyy HH:MM:SS'),
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
    disp(['Simulation id: ',dke_out.simul.id]);
    disp(['Simulation date: ',timeid_jd(dke_out.simul.timeid)]);
    disp(['User id: ',dke_out.simul.userid]);
    disp(['LUKE Version: ',dke_out.simul.LUKEversion]);
    if all(isfield(dke_out.simul,{'matver','hostname'})),
        disp(['MATLAB Version: ',dke_out.simul.matver]);
        disp(['MACHINE: ',dke_out.simul.hostname]);
    end
    disp(['Final RF convergence parameter: ',num2str(residue_rf)]);
    disp(' ');
    %
end
%
%if I_tot < 0,
%    disp('Warning : sign of J inverted for positive total current')
%    J_tot = -J_tot;
%    I_tot = -I_tot;
%end
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
%
xdPdrho_rf_2piRp = xp_rf_2piRp./xdrho;
xndPdrho_rf_2piRp = xnp_rf_2piRp./repmat(xdrho.',[1,nn_rf]);
yxdPdrho_rf_2piRp = yxp_rf_2piRp./repmat(xdrho,[ny,1]);
%
eta = NaN(1,nr);
eta(P_tot ~= 0) = J_tot(P_tot ~= 0)./P_tot(P_tot ~= 0);
i_peak = find(P_rf == max(P_rf));
eta_peak = eta(i_peak);
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
if timevol == 1,
    %
    FPtime = dke_out.FPtime;
    %
    nit = length(FPtime);
    %
    tJ_tot = reshape([Zcurr(end-nit+1:end).x_0_fsav],[nr,nit])*mksa.j_ref*scocurr;
    tP_rf = [ZP0(end-nit+1:end).x_rf_fsav]*mksa.P_ref;
    tP_e = reshape([ZP0(end-nit+1:end).x_e_fsav],[nr,nit])*mksa.P_ref;
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
p0_rf_2piRp = sum(wp0_rf_2piRp);
%
%
if nr > 1,
    %
    if nr_dep >= 0,
        %
        if nr_dep >= 1,
            %
            rhoG_dep_S = optgrid_dke_jd(waves,nr_dep,NaN,0);
            %
            rho_dep_S = interp1(xrhoG_S,xrho_S,rhoG_dep_S,'spline');
            %
        else
            %
            rhoG_dep_S = xrhoG_S;
            rho_dep_S = xrho_S;
            %
        end
        %
        nr_dep_S = length(rhoG_dep_S);
        %
        drho_dep = diff(rho_dep_S);
        drhoG_dep = diff(rhoG_dep_S);
        rho_dep = (rho_dep_S(1:end-1) + rho_dep_S(2:end))/2;
        rhoG_dep = (rhoG_dep_S(1:end-1) + rhoG_dep_S(2:end))/2;
        %
        wxdPdrho_rf_2piRp_lin = zeros(nw,nr_dep_S-1);
        wxdPdrhoG_rf_2piRp_lin = zeros(nw,nr_dep_S-1);
        %
        wxp_rf_2piRp_lin = zeros(nw,nr_dep_S-1);
        %
        wi_peak_lin = zeros(1,nw);
        %
        for iw = 1:nw;
            if ~isfield(waves{iw},'model') || strcmp(waves{iw}.model,'RT'),
                %
                for iray = 1:nb(iw),
                    %
                    ray = waves{iw}.rays{iray};
                    %
                    if isfield(ray,'sP_2piRp_lin')  && isfield(ray,'srho'),
                        wxdPdrhoG_rf_2piRp_lin(iw,:) = wxdPdrhoG_rf_2piRp_lin(iw,:) + 1e-6*radialdampingprofile_jd(ray.srho,ray.sP_2piRp_lin,rhoG_dep_S);
                    else
                        wxdPdrhoG_rf_2piRp_lin(iw,:) = NaN;% if some rays are not accounted for, the comparison is misleading and thus stopped
                    end
                    %
                end
                %
            elseif strcmp(waves{iw}.model,'FW'),
                %
                if waves{iw}.rhotype == 'g',
                    wrho_S = waves{iw}.rho_S;
                elseif waves{iw}.rhotype == 'p',
                    wrho_S = interp1(xrhoP_I,xrhoG_I,waves{iw}.rho_S,'spline');
                elseif waves{iw}.rhotype == 't',
                    wrho_S = interp1(xrhoT_I,xrhoG_I,waves{iw}.rho_S,'spline');
                elseif waves{iw}.rhotype == 'v',
                    wrho_S = interp1(xrhoV_I,xrhoG_I,waves{iw}.rho_S,'spline');
                else
                    error('rho type not recognized')
                end
                %
                nr_fw = length(waves{iw}.rho);
                xwmask = zeros(nr_dep_S - 1,nr_fw);%matrix of individual contributions from each EVE FS
                %
                for ir_fw = 1:nr_fw,
                    xwmask(:,ir_fw) = max([zeros(1,nr);(min([repmat(wrho_S(ir_fw + 1),[1,nr]);rhoG_dep_S(2:end)]) - max([repmat(wrho_S(ir_fw),[1,nr]);rhoG_dep_S(1:end-1)]))]).'./drhoG_dep.';
                end
                %
                wpe_eve = 1e-6*(waves{iw}.pe_eve(1:end - 1) + waves{iw}.pe_eve(2:end))/2;% EVE linear power density (in MW/m3?)
                %
                if nr_dep >= 1,
                    %
                    equilDKE_dep = equilibrium_jd(dke_out.equil,struct('xpsin_S_dke',rho2psi_jd(dke_out.equil,rhoG_dep_S),'xpsin_f',rho2psi_jd(dke_out.equil,rhoG_dep)));
                    %
                else
                    %
                    equilDKE_dep = equilDKE;
                    %
                end
                %
                wxdPdrhoG_rf_2piRp_lin(iw,:) = (xwmask*wpe_eve).'.*equilDKE_dep.xdV_2piRp_dke./drhoG_dep;
                %
            else
                error('Wave type not recognized.')
            end
            %
            wxdPdrho_rf_2piRp_lin(iw,:) = wxdPdrhoG_rf_2piRp_lin(iw,:).*drhoG_dep./drho_dep;
            %    
            if ~all(isnan(wxdPdrho_rf_2piRp_lin(iw,:))),
                wi_peak_lin(iw) = find(wxdPdrho_rf_2piRp_lin(iw,:) == max(wxdPdrho_rf_2piRp_lin(iw,:)));
            else
                wi_peak_lin(iw) = NaN;
            end
            %
            wxp_rf_2piRp_lin(iw,:) = wxdPdrho_rf_2piRp_lin(iw,:).*drho_dep;
            %
        end
        %
        wp_rf_2piRp_lin = sum(wxp_rf_2piRp_lin,2);
        xp_rf_2piRp_lin = sum(wxp_rf_2piRp_lin,1);
        xdPdrho_rf_2piRp_lin = sum(wxdPdrho_rf_2piRp_lin,1);
        p_rf_2piRp_lin = sum(wp_rf_2piRp_lin);
        %
        if ~isnan(wi_peak_lin),
            wrhoG_lin = rhoG_dep(wi_peak_lin);
            wrhoP_lin = interp1(xrhoG_I,xrhoP_I,wrhoG_lin);
            wrhoT_lin = interp1(xrhoG_I,xrhoT_I,wrhoG_lin);
            wrhoV_lin = interp1(xrhoG_I,xrhoV_I,wrhoG_lin);
            wTe_lin = interp1(xrhoG,xTe,wrhoG_lin);
            wne_lin = interp1(xrhoG,xne,wrhoG_lin);
        else
            wrhoG_lin = NaN;
            wrhoP_lin = NaN;
            wrhoT_lin = NaN;
            wrhoV_lin = NaN;
            wTe_lin = NaN;
            wne_lin = NaN;
        end           
        %
    else
        %
        rho_dep = '';
        wxdPdrho_rf_2piRp_lin = '';
        xp_rf_2piRp_lin = '';
        xdPdrho_rf_2piRp_lin = '';
        wp_rf_2piRp_lin = '';
        wxp_rf_2piRp_lin = '';
        p_rf_2piRp_lin = '';
        %
        wrhoG_lin ='';
        wrhoP_lin = '';
        wrhoT_lin = '';
        wrhoV_lin = '';
        wTe_lin = '';
        wne_lin = '';
        %
    end
    %
    if nw > 0 && opt_wave == 'y',
        %
        wxp_rf_2piRp = zeros(nw,nr);
        wnp_rf_2piRp = zeros(nw,nn_rf);
        wxdPdrho_rf_2piRp = zeros(nw,nr);
        %
        wrhoG = zeros(1,nw);
        wrhoP = zeros(1,nw);
        wrhoT = zeros(1,nw);
        wrhoV = zeros(1,nw);
        wTe = zeros(1,nw);
        wne = zeros(1,nw);
        %
        wNpar = zeros(1,nw);
        wtheta = zeros(1,nw);
        %
            %
            % bxdPdrho_rf_2piRp = zeros(nbtot,nx);
            %
        for iw = 1:nw,
            %
            % keep this in case we move on to ray analysis
            %
            % for ibb = 1:nb(iw),
            %     %
            %     ib = sum(nb(1:iw-1)) + ibb;
            %     %
            %     if ib < nbtot,
            %         ymask = yb(ib):(yb(ib+1) - 1);
            %     else
            %         ymask = yb(ib):ny;
            %     end
            %     %
            %     bxdPdrho_rf_2piRp(ib,:) = sum(yxdPdrho_rf_2piRp(ymask,:),1);
            %     %
            % end
            %
            wxp_rf_2piRp(iw,:) = sum(yxp_rf_2piRp(ymask{iw},:),1);
            wnp_rf_2piRp(iw,:) = reshape(sum(sum(yxnp_rf_2piRp(:,ymask{iw},:),2),1),[1,nn_rf]);
            wxdPdrho_rf_2piRp(iw,:) = sum(yxdPdrho_rf_2piRp(ymask{iw},:),1);
            %    
            wi_peak = find(wxdPdrho_rf_2piRp(iw,:) == max(wxdPdrho_rf_2piRp(iw,:)));
            %
            if opt.peakmode == 0,
                wrhoG(iw) = xrhoG(wi_peak);
                wrhoP(iw) = xrhoP(wi_peak);
                wrhoT(iw) = xrhoT(wi_peak);
                wrhoV(iw) = xrhoV(wi_peak);
                wTe(iw) = xTe(wi_peak);
                wne(iw) = xne(wi_peak);
            else
                wrhoG(iw) = sum(wxp_rf_2piRp(iw,:).*xrhoG)/sum(wxp_rf_2piRp(iw,:));
                wrhoP(iw) = interp1(xrhoG_I,xrhoP_I,wrhoG(iw));
                wrhoT(iw) = interp1(xrhoG_I,xrhoT_I,wrhoG(iw));
                wrhoV(iw) = interp1(xrhoG_I,xrhoV_I,wrhoG(iw));
                wTe(iw) = interp1(xrhoG,xTe,wrhoG(iw));
                wne(iw) = interp1(xrhoG,xne,wrhoG(iw));
            end
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
        wp_rf_2piRp = sum(wxp_rf_2piRp,2);
        %
    else
        %
        wxdPdrho_rf_2piRp = '';
        wxp_rf_2piRp = '';
        wnp_rf_2piRp = '';
        wp_rf_2piRp = '';
        wrhoG = '';
        wrhoP = '';
        wrhoT = '';
        wrhoV = '';
        wTe = '';        
        wne = '';     
        wrays = '';
        %
    end
    %
    if opt_peak == 'y',
        %
        dep = 1;
        ip_rf_2piRp = 0;
        xI_tot = J_tot.*equilDKE.xdA_dke;
        %
        xdPdrho_rf_2piRp(xdPdrho_rf_2piRp < 0) = 0;
        %
        p_rf_2piRp_peak = 0;
        I_tot_peak = 0;
        %
        peaks.ir = []; 
        peaks.p_rf_2piRp = [];
        peaks.I_tot = [];
        %
        for ir = 1:nr,
            if (xdPdrho_rf_2piRp(ir) - ip_rf_2piRp)*dep < 0,
                if dep == 1,% ir-1 is a peak
                    peaks.ir = [peaks.ir,ir-1];
                    dep = -1;
                else% ir-1 is a low - power and current shared
                    %
                    p_rf_2piRp_peak = p_rf_2piRp_peak - xp_rf_2piRp(ir-1)/2;  
                    I_tot_peak = I_tot_peak - xI_tot(ir-1)/2;
                    %
                    peaks.p_rf_2piRp = [peaks.p_rf_2piRp,p_rf_2piRp_peak];
                    peaks.I_tot = [peaks.I_tot,I_tot_peak];
                    %
                    p_rf_2piRp_peak = xp_rf_2piRp(ir-1)/2;  
                    I_tot_peak = xI_tot(ir-1)/2;
                    %
                    dep = 1;
                end
            end
            %
            ip_rf_2piRp = xdPdrho_rf_2piRp(ir);
            p_rf_2piRp_peak = p_rf_2piRp_peak + xp_rf_2piRp(ir);  
            I_tot_peak = I_tot_peak + xI_tot(ir);
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
        %
    else
        peaks = '';
    end
    % SIMUL
    data_proc.simul = dke_out.simul;
    data_proc.simul.residue_rf = residue_rf;
    % SCALAR
    data_proc.scalar.p_tot_2piRp = p_tot_2piRp;
    data_proc.scalar.p0_rf_2piRp = p0_rf_2piRp;
    data_proc.scalar.p_rf_2piRp = p_rf_2piRp;
    data_proc.scalar.np_rf_2piRp = np_rf_2piRp;
    data_proc.scalar.n_rf_list = n_rf_list;
    data_proc.scalar.p_rf_2piRp_lin = p_rf_2piRp_lin;
    data_proc.scalar.p_e_2piRp = p_e_2piRp;
    data_proc.scalar.I_tot = I_tot;
    data_proc.scalar.I_exp = I_exp;
    data_proc.scalar.EtaRp = EtaRp;
    data_proc.scalar.EtaRFRp = EtaRFRp;
    data_proc.scalar.nfrags = nfrags;
    data_proc.scalar.Rp = equilDKE.Rp;
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
    % RADIAL QUASI-LINEAR
    data_proc.radial.xrhoG = xrhoG;
    data_proc.radial.xrhoP = xrhoP;
    data_proc.radial.xrhoT = xrhoT;
    data_proc.radial.xrhoV = xrhoV;
    data_proc.radial.xdA_dke = equilDKE.xdA_dke;
    data_proc.radial.xdV_2piRp_dke = equilDKE.xdV_2piRp_dke;
    data_proc.radial.xepsi = dke_out.xepsi;
    data_proc.radial.J_tot = J_tot;
    data_proc.radial.P_tot = P_tot;
    data_proc.radial.eta = eta;
    data_proc.radial.P_rf = P_rf;
    data_proc.radial.P_e = P_e;
    data_proc.radial.xp_rf_2piRp = xp_rf_2piRp;
    data_proc.radial.xnp_rf_2piRp = xnp_rf_2piRp;
    data_proc.radial.xdPdrho_rf_2piRp = xdPdrho_rf_2piRp;
    data_proc.radial.xndPdrho_rf_2piRp = xndPdrho_rf_2piRp;
    % RADIAL LINEAR
    data_proc.radial.xrho_lin = rho_dep;
    data_proc.radial.xp_rf_2piRp_lin = xp_rf_2piRp_lin;
    data_proc.radial.xdPdrho_rf_2piRp_lin = xdPdrho_rf_2piRp_lin;
    % TIME EVOLUTION
    if timevol == 1,
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
    % WAVE QUASI-LINEAR
    data_proc.wave.wxrho = xrho;
    data_proc.wave.wp0_rf_2piRp = wp0_rf_2piRp;
    data_proc.wave.wp_rf_2piRp = wp_rf_2piRp;
    data_proc.wave.wnp_rf_2piRp = wnp_rf_2piRp;
    data_proc.wave.wn_rf_list = n_rf_list;
    data_proc.wave.wxp_rf_2piRp = wxp_rf_2piRp;
    data_proc.wave.wxdPdrho_rf_2piRp = wxdPdrho_rf_2piRp;
    data_proc.wave.wrhoG = wrhoG;
    data_proc.wave.wrhoP = wrhoP;
    data_proc.wave.wrhoT = wrhoT;
    data_proc.wave.wrhoV = wrhoV;
    data_proc.wave.wTe = wTe;
    data_proc.wave.wne = wne;
    data_proc.wave.wrays = wrays;
    % WAVE LINEAR
    data_proc.wave.wxrho_lin = rho_dep;
    data_proc.wave.wp_rf_2piRp_lin = wp_rf_2piRp_lin;
    data_proc.wave.wxp_rf_2piRp_lin = wxp_rf_2piRp_lin;
    data_proc.wave.wxdPdrho_rf_2piRp_lin = wxdPdrho_rf_2piRp_lin;
    data_proc.wave.wrhoG_lin = wrhoG_lin;
    data_proc.wave.wrhoP_lin = wrhoP_lin;
    data_proc.wave.wrhoT_lin = wrhoT_lin;
    data_proc.wave.wrhoV_lin = wrhoV_lin;
    data_proc.wave.wTe_lin = wTe_lin;
    data_proc.wave.wne_lin = wne_lin;
    % PEAKS
    data_proc.peaks = peaks;
    % OPTIONS
    data_proc.opt = opt;
    %
    if ir_display >= 0,
        %
        disp(['Total current (I): ',num2str(I_tot),' MA (positive for co-current)'])
        %
        if opt.rho == 'g',
            jrho = jrhoG;
            jdrho = jdrhoG;
        elseif opt.rho == 'p',
            jrho = jrhoG;
            jdrho = jdrhoG;
        elseif  opt.rho == 't',
            jrho = jrhoT;
            jdrho = jdrhoT;
        elseif  opt.rho == 'v',
            jrho = jrhoV;
            jdrho = jdrhoV;
        end
        disp(['Location of current peak (rho',opt.rho,'): ',num2str(jrho),' (peak mode = ',num2str(opt.peakmode),'; jpeak = ',num2str(opt.jpeak),')'])
        disp(['Current FWHM (drho',opt.rho,'): ',num2str(jdrho),' (peak mode = ',num2str(opt.peakmode),'; jpeak = ',num2str(opt.jpeak),')'])
        disp(['RF efficiency (n_19*I*Rp/P): ',num2str(EtaRFRp),' 10^19 A/(W.m^2)'])
        %
        if isinf(equilDKE.Rp),
            disp(['Launched RF power (P/2piRp): ',num2str(p0_rf_2piRp),' MW/m'])
            disp(['RF power (P/2piRp): ',num2str(p_rf_2piRp),' MW/m ---> ',num2str(100*p_rf_2piRp/p0_rf_2piRp),' %.'])
            for in_rf = 1:nn_rf,
                disp(['RF power on harm. ',num2str(n_rf_list(in_rf)),' (P/2piRp): ',num2str(np_rf_2piRp(in_rf)),' MW/m ---> ',num2str(100*np_rf_2piRp(in_rf)/p0_rf_2piRp),' %.'])
            end
            if nr_dep >= 0,
                disp(['Linear RF power (P/2piRp): ',num2str(p_rf_2piRp_lin),' MW/m ---> ',num2str(100*p_rf_2piRp_lin/p0_rf_2piRp),' %.'])
            end
            disp(['Ohmic power (P/2piRp): ',num2str(p_e_2piRp),' MW/m'])
            disp(['Total power (P/2piRp): ',num2str(p_tot_2piRp),' MW/m'])
            disp(['CD efficiency (I*Rp/P): ',num2str(EtaRp),' A.m/W'])
            %
            if opt_peak == 'y',
                %
                for ipeak = 1:length(peaks.ir),
                    disp(' ');
                    disp('----------------------------------------');
                    disp(' ');
                    disp(['RF Peak # ',num2str(ipeak)])
                    disp(['Position rho G: ',num2str(peaks.rhoG(ipeak))])
                    disp(['Position rho P: ',num2str(peaks.rhoP(ipeak))])
                    disp(['Position rho T: ',num2str(peaks.rhoT(ipeak))])
                    disp(['Position rho V: ',num2str(peaks.rhoV(ipeak))])
                    disp(['Temperature Te: ',num2str(peaks.Te(ipeak)),' keV'])
                    disp(['Density ne: ',num2str(peaks.ne(ipeak)/1e20),' *10^20 m^-3'])
                    disp(' ');
                    disp(['RF power (P/2piRp): ',num2str(peaks.p_rf_2piRp(ipeak)),' MW/m'])
                    disp(['Total current (I): ',num2str(peaks.I_tot(ipeak)),' MA'])
                    disp(['CD efficiency (I*Rp/P): ',num2str(peaks.EtaRp(ipeak)),' A.m/W'])
                    disp(['Normalized CD efficiency xi: ',num2str(peaks.ksirf(ipeak))])
                end
            end
            %
            if opt_wave == 'y',
                %
                for iw = 1:nw,
                    disp(' ');
                    disp('----------------------------------------');
                    disp(' ');
                    disp(['RF Wave # ',num2str(iw)])
                    disp(['Position rho G: ',num2str(wrhoG(iw))])
                    disp(['Position rho P: ',num2str(wrhoP(iw))])
                    disp(['Position rho T: ',num2str(wrhoT(iw))])
                    disp(['Position rho V: ',num2str(wrhoV(iw))])
                    disp(['Temperature Te: ',num2str(wTe(iw)),' keV'])
                    disp(['Density ne: ',num2str(wne(iw)/1e20),' *10^20 m^-3'])
                    disp(' ');
                    disp(['Launched RF power (P/2piRp): ',num2str(wp0_rf_2piRp(iw)),'MW/m'])
                    disp(['Deposited RF power (P/2piRp): ',num2str(wp_rf_2piRp(iw)),' MW/m ---> ',num2str(100*wp_rf_2piRp(iw)/wp0_rf_2piRp(iw)),' %.'])
                    for in_rf = 1:nn_rf,
                        disp(['RF power on harm. ',num2str(n_rf_list(in_rf)),' (P/2piRp): ',num2str(wnp_rf_2piRp(iw,in_rf)),' MW/m ---> ',num2str(100*wnp_rf_2piRp(iw,in_rf)/wp0_rf_2piRp(iw)),' %.'])
                    end
                    if nr_dep >= 0,
                        disp(['Linear RF power (P/2piRp): ',num2str(wp_rf_2piRp_lin(iw)),' MW/m ---> ',num2str(100*wp_rf_2piRp_lin(iw)/wp0_rf_2piRp(iw)),' %.'])
                    end
                end
            end
            %
        else
            disp(['Launched RF power (P): ',num2str(p0_rf_2piRp*(2*pi*equilDKE.Rp)),' MW'])
            disp(['RF power (P): ',num2str(p_rf_2piRp*(2*pi*equilDKE.Rp)),' MW ---> ',num2str(100*p_rf_2piRp/p0_rf_2piRp),' %.'])
            for in_rf = 1:nn_rf,
                disp(['RF power on harm. ',num2str(n_rf_list(in_rf)),' (P): ',num2str(np_rf_2piRp(in_rf)*(2*pi*equilDKE.Rp)),' MW ---> ',num2str(100*np_rf_2piRp(in_rf)/p0_rf_2piRp),' %.'])
            end
            if nr_dep >= 0,
                disp(['Linear RF power (P): ',num2str(p_rf_2piRp_lin*(2*pi*equilDKE.Rp)),' MW ---> ',num2str(100*p_rf_2piRp_lin/p0_rf_2piRp),' %.'])
            end
            disp(['Ohmic power (P): ',num2str(p_e_2piRp*(2*pi*equilDKE.Rp)),' MW'])
            disp(['Total power (P): ',num2str(p_tot_2piRp*(2*pi*equilDKE.Rp)),' MW'])
            disp(['CD efficiency (I/P): ',num2str(EtaRp/equilDKE.Rp),' A/W'])
            %
            if opt_peak == 'y',
                %
                for ipeak = 1:length(peaks.ir),
                    disp(' ');
                    disp('----------------------------------------');
                    disp(' ');
                    disp(['RF Peak # ',num2str(ipeak)])
                    disp(['Position rho G: ',num2str(peaks.rhoG(ipeak))])
                    disp(['Position rho P: ',num2str(peaks.rhoP(ipeak))])
                    disp(['Position rho T: ',num2str(peaks.rhoT(ipeak))])
                    disp(['Position rho V: ',num2str(peaks.rhoV(ipeak))])
                    disp(['Temperature Te: ',num2str(peaks.Te(ipeak)),' keV'])
                    disp(['Density ne: ',num2str(peaks.ne(ipeak)/1e20),' *10^20 m^-3'])
                    disp(' ');
                    disp(['RF power (P): ',num2str(peaks.p_rf_2piRp(ipeak)*(2*pi*equilDKE.Rp)),' MW'])
                    disp(['Total current (I): ',num2str(peaks.I_tot(ipeak)),' MA'])
                    disp(['CD efficiency (I/P): ',num2str(peaks.EtaRp(ipeak)/equilDKE.Rp),' A/W'])
                    disp(['Normalized CD efficiency xi: ',num2str(peaks.ksirf(ipeak))])
                end
            end
            %
            if opt_wave == 'y',
                %
                for iw = 1:nw,
                    disp(' ');
                    disp('----------------------------------------');
                    disp(' ');
                    disp(['RF Wave # ',num2str(iw)])
                    disp(['Position rho G: ',num2str(wrhoG(iw))])
                    disp(['Position rho P: ',num2str(wrhoP(iw))])
                    disp(['Position rho T: ',num2str(wrhoT(iw))])
                    disp(['Position rho V: ',num2str(wrhoV(iw))])
                    disp(['Temperature Te: ',num2str(wTe(iw)),' keV'])
                    disp(['Density ne: ',num2str(wne(iw)/1e20),' *10^20 m^-3'])
                    disp(' ');
                    disp(['Launched RF power (P): ',num2str(wp0_rf_2piRp(iw)*(2*pi*equilDKE.Rp)),'MW'])
                    disp(['Deposited RF power (P): ',num2str(wp_rf_2piRp(iw)*(2*pi*equilDKE.Rp)),' MW ---> ',num2str(100*wp_rf_2piRp(iw)/wp0_rf_2piRp(iw)),' %.'])
                    for in_rf = 1:nn_rf,
                        disp(['RF power on harm. ',num2str(n_rf_list(in_rf)),' (P): ',num2str(wnp_rf_2piRp(iw,in_rf)*(2*pi*equilDKE.Rp)),' MW ---> ',num2str(100*wnp_rf_2piRp(iw,in_rf)/wp0_rf_2piRp(iw)),' %.'])
                    end
                    if nr_dep >= 0,
                        disp(['Linear RF power (P): ',num2str(wp_rf_2piRp_lin(iw)*(2*pi*equilDKE.Rp)),' MW ---> ',num2str(100*wp_rf_2piRp_lin(iw)/wp0_rf_2piRp(iw)),' %.'])
                    end
                end
            end
        end
        %
        diary off
        %
        % power profiles
        %
        figure(1),clf,set(1,'Name',['RF power deposition profile - ',dke_out.simul.id])
        %
        xlab = '\rho';
        ylab = 'dP_{RF}/d\rho/(2\piR_p) (MW/m)';
        tit = '';
        %
        xlim = [0,1];
        xtick = 0:0.2:1;
        ylim = NaN;
        %
        if opt_wave == 'y',
            %
            leg = {};
            %
            for iw = 1:nw,
                if isfield(waves{iw},'rayinit') && isfield(waves{iw}.rayinit,'launch') && isfield(waves{iw}.rayinit.launch,'id'),
                    leg = [leg,['LUKE ',waves{iw}.rayinit.launch.id]];
                elseif isfield(waves{iw},'rayinit') && isfield(waves{iw}.rayinit,'id'),
                    leg = [leg,['LUKE ',waves{iw}.rayinit.id]];
                else
                    leg = [leg,['LUKE ',waves{iw}.id]];
                end
                %
                graph1D_jd(xrho,wxdPdrho_rf_2piRp(iw,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,colors{iw},width2,siz,gca,red,lspace,bspace);
            end
            %
            if ~isnan(p_rf_2piRp_lin),
                %
                for iw = 1:nw,
                    if isfield(waves{iw},'rayinit') && isfield(waves{iw}.rayinit,'launch') && isfield(waves{iw}.rayinit.launch,'id'),
                        leg = [leg,['C3PO ',waves{iw}.rayinit.launch.id]];
                    elseif isfield(waves{iw},'rayinit') && isfield(waves{iw}.rayinit,'id'),
                        leg = [leg,[waves{iw}.rayinit.id]];
                    else
                        leg = [leg,['Linear ',waves{iw}.id]];
                    end
                    %
                    graph1D_jd(rho_dep,wxdPdrho_rf_2piRp_lin(iw,:),0,0,'','','',leg,xlim,ylim,style2,marker,colors{iw},width,siz);
                end
                %
            end
        else
            %
            graph1D_jd(xrho,xdPdrho_rf_2piRp,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
            %
            if ~isnan(p_rf_2piRp_lin),
                %
                leg = {'LUKE','linear'};
                %
                graph1D_jd(rho_dep,xdPdrho_rf_2piRp_lin,0,0,'','','',leg,xlim,ylim,style,marker,color3,width,siz);
                %
            end
        end            
        %
        set(gca,'xtick',xtick);
        %
        print_jd(p_opt,[simul_id,'_Prf_profile'],'figures_LUKE');
        %
        % power profiles - by harmonic number
        %
        if nn_rf > 1,
            %
            figure(101),clf,set(1,'Name',['RF power deposition profile per harmonic # - ',dke_out.simul.id])
            %
            if 0,%~isnan(xndPdrho_rf_2piRp_lin),
                %
                leg = cell(1,2*nn_rf);
                %
                for in_rf = 1:nn_rf,
                    %
                    leg{in_rf} = ['linear, n = ',num2str(n_rf_list(in_rf))];
                    %
                end
                %
                graph1D_jd(rho_dep,xndPdrho_rf_2piRp_lin,0,0,'','','',NaN,xlim,ylim,style,marker,NaN,width,siz);
                %
            else
                %
                in_rf = 0;
                leg = cell(1,nn_rf);
                %
            end   
            %
            iin_rf = in_rf;
            %
            for in_rf = 1:nn_rf,
                leg{iin_rf + in_rf} = ['LUKE, n = ',num2str(n_rf_list(in_rf))];
            end
            %
            graph1D_jd(xrho,xndPdrho_rf_2piRp,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,NaN,width2,siz,gca,red,lspace,bspace);
            %
            set(gca,'xtick',xtick);
            %
            print_jd(p_opt,[simul_id,'_Prf_nrf_profile'],'figures_LUKE');
            %
        end
        %
        figure(2),clf,set(2,'Name',['Ohmic power density profile - ',dke_out.simul.id])
        %
        xlab = '\rho';
        ylab = 'P_{OHM} (MW/m^3)';
        tit = '';
        %
        xlim = [0,1];
        xtick = 0:0.2:1;
        ylim = NaN;
        %
        graph1D_jd(xrho,P_e,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
        set(gca,'xtick',xtick);
        %
        print_jd(p_opt,[simul_id,'_Pe_profile'],'figures_LUKE');
        %
        figure(3),clf,set(3,'Name',['Total power density profile - ',dke_out.simul.id])
        %
        xlab = '\rho';
        ylab = 'P_{TOT} (MW/m^3)';
        tit = '';
        %
        xlim = [0,1];
        xtick = 0:0.2:1;
        ylim = NaN;
        %
        graph1D_jd(xrho,P_tot,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
        set(gca,'xtick',xtick);
        %
        print_jd(p_opt,[simul_id,'_Ptot_profile'],'figures_LUKE');
        %
        % current profile
        %
        figure(4),clf,set(4,'Name',['Current density profile - ',dke_out.simul.id])
        %
        ylab = 'J (MA/m^2)';
        tit = 'J > 0 for co-current';
        ylim = NaN;
        %
        graph1D_jd(xrho,J_tot,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace2);
        set(gca,'xtick',xtick);
        %set(gca,'ylim',[0,max(get(gca,'ylim'))])
        %
        print_jd(p_opt,[simul_id,'_J_profile'],'figures_LUKE');
        %
        % parallel momentum transfer rate profile
        %
        figure(401),clf,set(3,'Name',['Parallel Momentum transfer rate density profile - ',dke_out.simul.id])
        %
        xlab = '\rho';
        ylab = 'dp_{RF}/dt (N/m^3)';
        tit = '';
        %
        xlim = [0,1];
        xtick = 0:0.2:1;
        ylim = NaN;
        %
        graph1D_jd(xrho,dpdt_rf,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
        set(gca,'xtick',xtick);
        %
        print_jd(p_opt,[simul_id,'_Ptrans_profile'],'figures_LUKE');
        %
        % efficiency profile
        %
        figure(5),clf,set(5,'Name',['Current efficiency profile - ',dke_out.simul.id])
        %
        ylab = '\eta (A.m/W)';
        tit = '';
        ylim = 2*[min([0,eta_peak]),max([0,eta_peak])];
        %
        graph1D_jd(xrho,eta,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
        set(gca,'xtick',xtick);
        %
        print_jd(p_opt,[simul_id,'_eta_profile'],'figures_LUKE');
        %
        figure(6),clf,set(6,'Name',['Current and RF power density profiles - ',dke_out.simul.id])
        %    
        ylab1 = 'J (MA/m^2)';
        ylab2 = 'P_{RF} (MW/m^3)';
        tit = 'J > 0 for co-current';
        ylim1 = NaN;
        ylim2 = NaN;
        %
        graph1D2jd(xrho,J_tot,xrho,P_rf,xlab,ylab1,ylab2,tit,xlim,ylim1,ylim2,...
        style,marker1,color2,width2,style,marker1,color3,width2,siz,red,lspace2,bspace2);
        %
        print_jd(p_opt,[simul_id,'_J_Prf_profile'],'figures_LUKE');
        %
        if exist('Zmripple'),
            if ~isempty(Zmripple) & sum(sum(Zmripple.Xnhuloss)) ~= 0,
                figure(7),clf,set(7,'Name',['Magnetic ripple losses - ',dke_out.simul.id])
                [ax] = graph1D_jd(xrho,dke_out.xMRR_flux,0,0,'\rho','Ripple losses (m-3.s-1)',subtitle,NaN,[0,1],[0,max(max([dke_out.xMRR_flux(:),dke_out.xMRR_tau(:)]))],style,marker1,color2,width2,siz,gca,red,lspace,bspace);hold on
                [ax] = graph1D_jd(xrho,dke_out.xMRR_tau,0,0,'\rho','Ripple losses (m-3.s-1)',subtitle,NaN,[0,1],[0,max(max([dke_out.xMRR_flux(:),dke_out.xMRR_tau(:)]))],style,marker1,color3,width2,siz,gca,red,lspace,bspace);hold on
                legend('Boundary losses','Volumic losses');
                print_jd(p_opt,[simul_id,'_RippleLosses_profile'],'figures_LUKE');
                %
                figure(8),clf,set(8,'Name',['Cones angles - ',dke_out.simul.id])
                [ax] = graph1D_jd(xrho,Zmripple.xthetabanana,0,0,'\rho','Angle (Deg.)',subtitle,NaN,[0,1],[0,60],style,marker1,color2,width2,siz,gca,red,lspace,bspace);hold on
                [ax] = graph1D_jd(xrho,Zmripple.xthetaloss,0,0,'\rho','Angle (Deg.)',subtitle,NaN,[0,1],[0,60],style,marker1,color3,width2,siz,gca,red,lspace,bspace);hold on
                legend('Banana cone angle','Loss cone angle');
                print_jd(p_opt,[simul_id,'_RippleConeAngles_profile'],'figures_LUKE');
                %
                ylab1 = 'p/p_{Te}';
                ylab2 = 'p/p_{Te(loc.)}';
                ytick = [0:2:10];
                ylim1 = [0,10];
                ylim2 = [0,40];
                figure(9),clf,set(9,'Name',['Collision detrapping threshold - ',dke_out.simul.id])
                [ax] = graph1D_jd(xrho,Zmripple.xpndetrap,0,0,'\rho','',subtitle,NaN,[0,1],'',style,marker1,color2,width2,siz,gca,red,lspace,bspace);hold on
                [ax] = graph1D_jd(xrho,Zmripple.xpnth,0,0,'\rho','',subtitle,NaN,[0,1],'',style,marker1,color3,width2,siz,gca,red,lspace,bspace);hold on
                [ax] = graph1D2jd(xrho,Zmripple.xpnth,xrho,Zmripple.xpndetrap./Zmripple.xpnth,xlab,ylab1,ylab2,tit,xlim,ylim1,ylim2,style,marker1,color3,width2,style,marker1,color4,width2,siz,red,lspace2,bspace);
                set(gca,'ytick',ytick);
                legend('p_{c}/p_{Te}','p_{Te(loc.)}/p_{Te}','p_{c}/p_{Te(loc.)}');
                print_jd(p_opt,[simul_id,'_RippleDetrapping_profile'],'figures_LUKE');
            end  
        end
        %
        if opt.spec == 1
            disp('******** power absorption along specific rays ********');
            %
            iw = NaN;
            ibb = NaN;
            ib = 0;
            iwdef = 1;
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
                sP_c3po = ray.sP_2piRp_lin*2*pi*equilDKE.Rp;
                %
                sS_luke = zS{iy};
                sP_luke = zP_0_2piRp_mod{iy}*2*pi*equilDKE.Rp;
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
                graph1D_jd(sS_c3po,sP_c3po/1e3,0,0,xlab,ylab,figlab,NaN,xlim,ylim,style2,marker,color3,width2,siz,gca,red,lspace,bspace2);
                graph1D_jd(sS_luke,sP_luke/1e3,0,0,'','','',leg,xlim,ylim,style,marker2,color2,width2,siz);
                %
            end
        %
        end
    %
    end
    %
else
    %
    if ir_display >= 0,
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
    figure(10),clf,set(10,'Name',['dj/dp - ',dke_out.simul.id])
    %
    xlab = 'p/p_{Te}';
    ylab = 'dj/dp_n (MA/m^2)';
    xlim = [0,pnmax];
    ylim = NaN;
    %
    graph1D_jd(pn,pdj0dp,0,0,xlab,ylab,[radialloc,' ; dj/dp positive for co-current'],NaN,xlim,ylim,style,marker,color2,width2,siz,gca,red,lspace,bspace2);
    %
    print_jd(p_opt,[simul_id,'_djdp_',tir_display],'figures_LUKE');
    %
    % ---------- 2D distribution function -----------
    %
    figure(11),clf,set(11,'Name',['2-D contour of f - ',dke_out.simul.id])
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
    graph2D_jd(x1,x2,y1','','',radialloc,xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color3,width,siz,1,max(max(y1)));
    hold on
    graph2D_jd(x1,x2,y2','','',radialloc,xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color2,width2,siz,1,max(max(y1)));
    %
    if y3max > 1e-5,
        graph2D_jd(x1,x2,y3','','',radialloc,xlim1,xlim2,0,NaN,y3max/100,0,style,color4,width2,siz);
    end
    hold off
    %
    graph1D_jd(x1,y9,0,0,xlab1,xlab2,radialloc,NaN,xlim1,xlim2,style,marker,color1,width2,siz,gca,red,lspace,bspace2);
    %
    axis('equal');axis([xlim1,xlim2]);
    legend(leg);
    %
    if equilDKE.Rp ~= Inf,
        bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,Zmripple);
    end
    %
    print_jd(p_opt,[simul_id,'_f_2D',tir_display],'figures_LUKE');
    %
    if max(max(abs(y3))) > 0,
        %
        figure(12),clf,set(12,'Name',['2-D contour of ',y3lab,' - ',dke_out.simul.id])
        %
        cont = input_dke_yp('contours for DQL',10);
        %
        graph2D_jd(x1,x2,y3','','',radialloc,xlim1,xlim2,1,NaN,cont,0,style,NaN,width,siz,1);
        graph1D_jd(x1,y9,0,0,xlab1,xlab2,radialloc,NaN,xlim1,xlim2,style,marker,color1,width2,siz,gca,red,lspace,bspace2);
        axis('equal');axis([xlim1,xlim2])
        %
        if equilDKE.Rp ~= Inf,
            bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,Zmripple);
        end
        colorbar
        %
        print_jd(p_opt,[simul_id,'_DQL',tir_display],'figures_LUKE');
        %
        if strcmp(y3lab,'D||'),
            %
            figure(121),clf,set(121,'Name',['1-D plot of ',y3lab,' - ',dke_out.simul.id])
            %
            y1 = y3(1,:);
            ylab = 'D_{||} (p_\perp = 0)';
            ylim = NaN;
            %
            graph1D_jd(x1,y1,0,0,xlab1,ylab,radialloc,NaN,xlim1,ylim,style,marker,color2,width2,siz,gca,red,lspace,bspace2);
            %
            print_jd(p_opt,[simul_id,'_DQL_1D',tir_display],'figures_LUKE');
            %
        end
    end
    %
    % ---------- 2D suprathermal distribution function -----------
    %
    figure(111),clf,set(11,'Name',['2-D contour of fh - ',dke_out.simul.id])
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
    graph2D_jd(x1,x2,y','','',radialloc,xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color3,width,siz,1,max(max(y1)));
    hold on
    %
    if y3max > 1e-5,
        graph2D_jd(x1,x2,y3','','',radialloc,xlim1,xlim2,0,NaN,y3max/100,0,style,color4,width2,siz);
    end
    hold off
    %
    graph1D_jd(x1,y9,0,0,xlab1,xlab2,radialloc,NaN,xlim1,xlim2,style,marker,color1,width2,siz,gca,red,lspace,bspace2);
    %
    axis('equal');axis([xlim1,xlim2]);
    legend(leg);
    %
    if equilDKE.Rp ~= Inf,
        bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,Zmripple);
    end
    %
    print_jd(p_opt,[simul_id,'_fh_2D',tir_display],'figures_LUKE');
    %
    %
    % ---------- parallel distribution difference-----------
    %
    figure(13),clf,set(13,'Name',['F||-F||M - ',dke_out.simul.id])
    %
    y1 = Fpar0_cyl_ref - Fparinit_cyl_ref;
    ylab = 'F_{||} - F_{||M}';
    ylim = NaN;
    %
    graph1D_jd(x1,y1,0,0,xlab1,ylab,radialloc,NaN,xlim1,ylim,style,marker,color2,width2,siz,gca,red,lspace,bspace2);
    %
    print_jd(p_opt,[simul_id,'_F0mFM_1D',tir_display],'figures_LUKE');
    %
    % ---------- parallel distribution -----------
    %
    figure(14),clf,set(14,'Name',['F|| - ',dke_out.simul.id])
    %
    y1 = Fparinit_cyl_ref;
    y2 = Fpar0_cyl_ref;
    ylab = 'F_{||}';
    ylim = [eps,1];
    %
    graph1D_jd(x1,y1,0,1,'','',radialloc,NaN,xlim1,ylim,style,marker,color3,width,siz,gca,red,lspace,bspace2);
    graph1D_jd(x1,y2,0,1,xlab1,ylab,radialloc,leg,xlim1,ylim,style,marker,color2,width2,siz);
    legend(leg);
    %
    print_jd(p_opt,[simul_id,'_F0pFM_1D_',tir_display],'figures_LUKE');
    %
    % ---------- energy distribution -----------
    %
    figure(15),clf,set(14,'Name',['dNdEc - ',dke_out.simul.id])
    %
    x1 = Ec_ref;
    xlab1 = 'E_c (keV)';
    xlim1 = [0,max(x1)];
    y1 = pdNinit_dEc_ref;
    y2 = pdN0_dEc_ref;
    ylab = 'dn_e/dE_c/n_0 (keV^{-1})';
    ylim = NaN;
    %
    graph1D_jd(x1,y1,0,1,'','',radialloc,NaN,xlim1,ylim,style2,marker,color3,width2,siz,gca,red,lspace,bspace2);
    graph1D_jd(x1,y2,0,1,xlab1,ylab,radialloc,leg,xlim1,ylim,style,marker,color2,width2,siz);
    legend(leg);
    %
    print_jd(p_opt,[simul_id,'_dNdEc_',tir_display],'figures_LUKE');
    %
end
%


