function fproc_varscan(basestr,file_str,shotnum,shotime,id_simul_o,locid_simul,locpath_simul,var,opt)
%
if ischar(locpath_simul),
    path_simul = [basestr,filesep,shotnum,filesep,locpath_simul];
elseif iscell(locpath_simul),
    path_simul = locpath_simul{1};
end
%
% select shot times if time scan
%
if iscell(shotime),
    equilbase = file_str;
    id_simul_o = basestr;
    var.str = shotnum;
    %
    var.liststr = select_shotimes_jd([equilbase,basestr,'_',shotnum,'_'],[locid_simul,'.mat'],path_simul,shotime);
    nvar = length(var.liststr);
    %
    ivar_disp = [];
    for ivar = 1:nvar,
        ttimes(ivar) = str2num(var.liststr{ivar});
        if any(ttimes(ivar) == var.disp),
            ivar_disp = [ivar_disp,ivar];
        end
    end
    %
    if opt.xdisp == 0 || ~strcmp(basestr,'TS'),
        var.list = ttimes;
    else
        [nvol,tn]=tsbase(str2double(shotnum),'sprofnmoy');
        if isempty(nvol),
            [nvol,tn]=tsbase(str2double(shotnum),'snmoy');
            nvol = nvol/1e19;
        end
        var.list = interp1(tn,nvol,ttimes);
        var.lab = '<n>';
        var.unit = '\times 10^{19} m^{-3}';
    end
else
    equilbase = [file_str,basestr,'_',shotnum,'_',shotime];
    nvar = length(var.list);
    ttimes = repmat(str2num(shotime),[1,nvar]);
    ivar_disp = [];
    for ivar = 1:nvar,
        var.liststr{ivar} = num2str(var.list(ivar));
        if any(abs(var.list(ivar) - var.disp) < 10*eps),
            ivar_disp = [ivar_disp,ivar];
        end
    end
    %
end
%
tol_P0 = 1;%0.04;%tolerance on absorbed power verification
%
%************************************************************************************************************************************
%
% Load structures
%
%[dkepath] = load_structures_yp('dkepath',id_dkepath,path_dkepath);
%
dRp = NaN(1,nvar);
dI_rf = NaN(1,nvar);
dI_exp = NaN(1,nvar);
dP_rf = NaN(1,nvar);
dP_lin_rf = NaN(1,nvar);
dP0_rf = NaN(1,nvar);
drho_J = NaN(1,nvar);
ddrho_J = NaN(1,nvar);
drho_P = NaN(1,nvar);
dTe = NaN(1,nvar);
dne = NaN(1,nvar);
%
ds_c3po = NaN(1,nvar);
ds_luke = NaN(1,nvar);
%
dNpar0 = NaN(1,nvar);
dNpar_c3po = NaN(1,nvar);
dNpar_luke = NaN(1,nvar);
%
dxrho = cell(1,nvar);
dxJ = cell(1,nvar);
dxP = cell(1,nvar);
%
drho_P_lin = NaN(1,nvar);
dTe_lin = NaN(1,nvar);
dne_lin = NaN(1,nvar);
%
datapath = path_simul;
%
for ivar = 1:nvar,
    %
    id_simul = [equilbase,id_simul_o,'_',var.str,'_',var.liststr{ivar},locid_simul];%Simulation ID
    %
    data_proc = fproc_data(datapath,id_simul,opt);
    %
    if isempty(data_proc),
        continue
    end
    %
    dP_rf(ivar) = data_proc.scalar.p_rf_2piRp(1)*2*pi*data_proc.scalar.Rp;
    dP_lin_rf(ivar) = data_proc.scalar.p_rf_2piRp_lin(1)*2*pi*data_proc.scalar.Rp;
    dP0_rf(ivar) = data_proc.scalar.p0_rf_2piRp(1)*2*pi*data_proc.scalar.Rp;
    %
    if data_proc.simul.residue_rf > 1e-2
        disp(['Case ',var.lab,' = ',var.liststr{ivar},' : LUKE run did not converge or numerical instability developed.'])
    elseif abs(dP_rf(ivar) - dP0_rf(ivar))/abs(dP0_rf(ivar)) > tol_P0,
        disp(['Case ',var.lab,' = ',var.liststr{ivar},' : verify wave power absorption'])
        keyboard
    elseif isfield(opt,'P0_min') && dP0_rf(ivar) < opt.P0_min,
        disp(['Case ',var.lab,' = ',var.liststr{ivar},' : some rays did not enter the plasma.'])
    else
        %
        dRp(ivar) = data_proc.scalar.Rp;
        dI_rf(ivar) = data_proc.scalar.I_tot;
        %
        if isfield(data_proc.scalar,'I_exp'),
            dI_exp(ivar) = data_proc.scalar.I_exp;
        end
        %
        if opt.rho == 'g',
            drho_J(ivar) = data_proc.scalar.jrhoG(1);
            ddrho_J(ivar) = data_proc.scalar.jdrhoG(1);
            drho_P(ivar) = data_proc.wave.wrhoG(1);
            drho_P_lin(ivar) = data_proc.wave.wrhoG_lin(1);
            dxrho{ivar} = data_proc.radial.xrhoG;
        elseif opt.rho == 'p',
            drho_J(ivar) = data_proc.scalar.jrhoP(1);
            ddrho_J(ivar) = data_proc.scalar.jdrhoP(1);
            drho_P(ivar) = data_proc.wave.wrhoP(1);
            drho_P_lin(ivar) = data_proc.wave.wrhoP_lin(1);
            dxrho{ivar} = data_proc.radial.xrhoP;
        elseif opt.rho == 't',
            drho_J(ivar) = data_proc.scalar.jrhoT(1);
            ddrho_J(ivar) = data_proc.scalar.jdrhoT(1);
            drho_P(ivar) = data_proc.wave.wrhoT(1);
            drho_P_lin(ivar) = data_proc.wave.wrhoT_lin(1);
            dxrho{ivar} = data_proc.radial.xrhoT;
        elseif opt.rho == 'v',
            drho_J(ivar) = data_proc.scalar.jrhoV(1);
            ddrho_J(ivar) = data_proc.scalar.jdrhoV(1);
            drho_P(ivar) = data_proc.wave.wrhoV(1);
            drho_P_lin(ivar) = data_proc.wave.wrhoV_lin(1);
            dxrho{ivar} = data_proc.radial.xrhoV;
        else
            error('rho type not recognized')
        end
        %
        dTe(ivar) = data_proc.wave.wTe(1);
        dne(ivar) = data_proc.wave.wne(1);
        %
        dTe_lin(ivar) = data_proc.wave.wTe_lin(1);
        dne_lin(ivar) = data_proc.wave.wne_lin(1);
        %
        dxJ{ivar} = data_proc.radial.J_tot;
        dxP{ivar} = data_proc.radial.P_rf;
        %
        ds_c3po(ivar) = 0;
        ds_luke(ivar) = 0;
        %
        if strcmp(var.str,'bNpar0'),
            dNpar0(ivar) = var.list(ivar);
        elseif isfield(opt,'Npar0'),
            dNpar0(ivar) = opt.Npar0;
        end
        %
        dNpar_c3po(ivar) = 0;
        dNpar_luke(ivar) = 0;
        %
        if isfield(data_proc,'wave') && isfield(data_proc.wave,'wrays'),
            xs_c3po = [];
            xNpar_c3po = [];
            xP0_2piRp_c3po = [];
            xs_luke = [];
            xNpar_luke = [];
            xP0_2piRp_luke = [];
            for iw = 1:length(data_proc.wave.wrays),
                for iray = 1:length(data_proc.wave.wrays{iw}),
                    xs_c3po = [xs_c3po,data_proc.wave.wrays{iw}{iray}.c3po.ss];
                    xP0_2piRp_c3po = [xP0_2piRp_c3po,data_proc.wave.wrays{iw}{iray}.c3po.P0_2piRp];
                    xNpar_c3po = [xNpar_c3po,abs(real(data_proc.wave.wrays{iw}{iray}.c3po.sNpar))];
                    if isfield(data_proc.wave.wrays{iw}{iray},'luke'),
                        xs_luke = [xs_luke,data_proc.wave.wrays{iw}{iray}.luke{end}.ss];
                        xNpar_luke = [xNpar_luke,abs(real(data_proc.wave.wrays{iw}{iray}.luke{end}.sNpar))];
                        xP0_2piRp_luke = [xP0_2piRp_luke,data_proc.wave.wrays{iw}{iray}.luke{end}.P0_2piRp];
                    end
                end
            end
            %
            ds_c3po(ivar) = sum(xs_c3po.*xP0_2piRp_c3po)/sum(xP0_2piRp_c3po);
            dNpar_c3po(ivar) = sum(xNpar_c3po.*xP0_2piRp_c3po)/sum(xP0_2piRp_c3po);
            %
            if ~isempty(xs_luke),
                ds_luke(ivar) = sum(xs_luke.*xP0_2piRp_luke)/sum(xP0_2piRp_luke);
                dNpar_luke(ivar) = sum(xNpar_luke.*xP0_2piRp_luke)/sum(xP0_2piRp_luke);
            end
        end
        %
    end
end
%
deta = (dne/1e19).*dI_rf.*dRp./dP_rf;
dksirf = 3.27*deta./dTe;
%
% display results
%
if isfield(opt,'mom') && opt.mom == 'j',
    drho = drho_J;
    ddrho = ddrho_J;
else
    drho = drho_P;
    ddrho = NaN(1,nvar);
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
%
colors = {color1,color2,color3,color4};
markers = {marker1,marker2,marker3,marker4};
%
width = 0.5;
width2 = 2;
siz = 20+14i;
%
red = 0.9;
lspace = 0.5;
lspace2 = 0.7;
bspace = 0.5;
bspace2 = 0.6;
%
if ~isempty(var.unit),
    xlab = [var.lab,' (',var.unit,')'];
else
    xlab = var.lab;
end
%
if isfield(opt,'xlim'),
    xlim = opt.xlim;
else
    xlim = [min(var.list),max(var.list)];
end
%
if isfield(opt,'xtick'),
    xtick = opt.xtick;
else
    xtick = var.list;
end
%
tit0 = [basestr,' #',shotnum];
%
figure(1),clf
%
ylab = '';
%
if isfield(opt,'ylim_Irho'),
    ylim = opt.ylim_Irho;
else
    ylim = [0,1.2];
end
%
if isfield(opt,'Ifac') && opt.Ifac > 1,
    Ifacstr = [' \times',num2str(opt.Ifac)];
else
    opt.Ifac = 1;
    Ifacstr = '';
end
%
leg = {['I_{LH}',Ifacstr,' (MA)'],'\rho_{dep}','Location','NorthWest'};
tit = '';
%
graph1D_jd(var.list,dI_rf/opt.Ifac,0,0,'','','',NaN,xlim,ylim,style,marker1,color2,width2,siz);
graph1D_jd(var.list,drho,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker2,color3,width2,siz,gca,red,lspace2,bspace2);
set(gca,'xtick',xtick);
if isfield(opt,'ytick_Irho') && ~any(isnan(opt.ytick_Irho)),
    set(gca,'ytick',opt.ytick_Irho);
end
%
figure(101),clf
%
if isfield(opt,'ylim_I'),
    ylim = opt.ylim_I;
else
    ylim = 1e3*[0,max(dI_rf)]*1.2;
end
%
ylab = 'I_{LH} (kA)';
tit = '';
%
if isfield(opt,'I_exp') && opt.I_exp == 1,
    graph1D_jd(var.list,1e3*dI_exp/opt.Ifac,0,0,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz);
    leg = {'EXP','LUKE'};
else
    leg = NaN;
end
graph1D_jd(var.list,1e3*dI_rf/opt.Ifac,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace2,bspace2);
set(gca,'xtick',xtick);
if isfield(opt,'ytick_I') && ~any(isnan(opt.ytick_I)),
    set(gca,'ytick',opt.ytick_I);
end
%
figure(102),clf
%
if isfield(opt,'ylim_rho'),
    ylim = opt.ylim_rho;
else
    ylim = [0,1.2];
end
%
ylab = '\rho_{dep}';
tit = '';
%
graph1D_jd(var.list,drho,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker2,color3,width2,siz,gca,red,lspace2,bspace2,ddrho/2);
set(gca,'xtick',xtick);
if isfield(opt,'ytick_rho') && ~any(isnan(opt.ytick_rho)),
    set(gca,'ytick',opt.ytick_rho);
end
%
figure(2),clf
%
if isfield(opt,'ylim_eta'),
    ylim = opt.ylim_eta;
else
    ylim = [0,max(deta)]*1.2;
end
%
ylab = '\eta_{LH} (A/W/m^2) = n_{19}IR/P';
tit = '';
%
graph1D_jd(var.list,deta,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace2,bspace2);
set(gca,'xtick',xtick);
if isfield(opt,'ytick_eta') && ~any(isnan(opt.ytick_eta)),
    set(gca,'ytick',opt.ytick_eta);
end
%
figure(3),clf
%
if isfield(opt,'ylim_xi'),
    ylim = opt.ylim_xi;
else
    ylim = [0,max(dksirf)]*1.2;
end
%
ylab = '\xi_{LH} = 32.7\times n_{20}IR/(PT)';
tit = '';
%
graph1D_jd(var.list,dksirf,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace2,bspace2);
set(gca,'xtick',xtick);
if isfield(opt,'ytick_xi') && ~any(isnan(opt.ytick_xi)),
    set(gca,'ytick',opt.ytick_xi);
end
%
figure(4),clf
%
if isfield(opt,'ylim_P'),
    ylim = opt.ylim_P;
else
    ylim = [0,max(dP0_rf)]*1.2;
end
%
ylab = 'P (MW)';
leg = {'Coupled power','Absorbed power (C3PO)','Absorbed power (LUKE)','Location','NorthWest'};
%
graph1D_jd(var.list,dP0_rf,0,0,'','','',NaN,xlim,ylim,style,marker3,color1,width2,siz);
graph1D_jd(var.list,dP_lin_rf,0,0,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz);
graph1D_jd(var.list,dP_rf,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace2,bspace2);
set(gca,'xtick',xtick);
if isfield(opt,'ytick_P') && ~any(isnan(opt.ytick_P)),
    set(gca,'ytick',opt.ytick_P);
end
%
% --------------------- Weighed ray length -----------------------
%
figure(5),clf
%
if isfield(opt,'ylim_s'),
    ylim = opt.ylim_s;
else
    ylim = [0,max([ds_c3po,ds_luke])]*1.2;
end
%
ylab = 'Weighed ray length (m)';
leg = {'C3PO','LUKE'};
%
graph1D_jd(var.list,ds_c3po,0,0,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz);
graph1D_jd(var.list,ds_luke,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace2,bspace2);
set(gca,'xtick',xtick);
if isfield(opt,'ytick_s') && ~any(isnan(opt.ytick_s)),
    set(gca,'ytick',opt.ytick_s);
end
%
% --------------------- N // -----------------------
%
figure(6),clf
%
if isfield(opt,'ylim_Npar'),
    ylim = opt.ylim_Npar;
else
    ylim = [0,max([dNpar0,dNpar_c3po,dNpar_luke])]*1.2;
end
%
ylab = '';
leg = {'Initial <N//>','C3PO absorbed <N//>','LUKE absorbed <N//>'};
%
graph1D_jd(var.list,dNpar0,0,0,'','','',NaN,xlim,ylim,style,marker3,color1,width2,siz);
graph1D_jd(var.list,dNpar_c3po,0,0,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz);
graph1D_jd(var.list,dNpar_luke,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace2,bspace2);
set(gca,'xtick',xtick);
if isfield(opt,'ytick_Npar') && ~any(isnan(opt.ytick_Npar)),
    set(gca,'ytick',opt.ytick_Npar);
end
%
mask_disp = ~isnan(dI_rf(ivar_disp));
ivar_disp = ivar_disp(mask_disp);
var_disp = var.liststr(ivar_disp);
ndisp = length(ivar_disp);
%
if ndisp >= 1,
    %
    figure(7),clf
    %
    if isfield(opt,'ylim_xJ'),
        ylim = opt.ylim_xJ;
    else
        ylim = NaN;
    end
    %
    xlab = {'r/a'};
    xlim = [0,1];
    ylab = 'J (MA/m^2)';
    tit = '';
    leg = {};
    %
    for idisp = 1:ndisp-1,
        graph1D_jd(dxrho{ivar_disp(idisp)},dxJ{ivar_disp(idisp)},0,0,'','','',NaN,xlim,ylim,style,markers{idisp},colors{idisp},width2,siz);
        leg = [leg,[var.lab,' = ',var_disp{idisp}]];
    end
    %
    leg = [leg,[var.lab,' = ',var_disp{ndisp}]];
    graph1D_jd(dxrho{ivar_disp(ndisp)},dxJ{ivar_disp(ndisp)},0,0,xlab,ylab,tit,leg,xlim,ylim,style,markers{ndisp},colors{ndisp},width2,siz,gca,red,lspace2,bspace2);
    %
    if isfield(opt,'xtick_xJ') && ~any(isnan(opt.xtick_xJ)),
        set(gca,'xtick',opt.xtick_xJ);
    end
    if isfield(opt,'ytick_xJ') && ~any(isnan(opt.ytick_xJ)),
        set(gca,'ytick',opt.ytick_xJ);
    end
    %
    figure(8),clf
    %
    if isfield(opt,'ylim_xP'),
        ylim = opt.ylim_xP;
    else
        ylim = NaN;
    end
    %
    xlab = {'r/a'};
    xlim = [0,1];
    ylab = 'P (MW/m^3)';
    tit = '';
    %
    for idisp = 1:ndisp-1,
        graph1D_jd(dxrho{ivar_disp(idisp)},dxP{ivar_disp(idisp)},0,0,'','','',NaN,xlim,ylim,style,markers{idisp},colors{idisp},width2,siz);
    end
    graph1D_jd(dxrho{ivar_disp(ndisp)},dxP{ivar_disp(ndisp)},0,0,xlab,ylab,tit,leg,xlim,ylim,style,markers{ndisp},colors{ndisp},width2,siz,gca,red,lspace2,bspace2);
    if isfield(opt,'xtick_xP') && ~any(isnan(opt.xtick_xP)),
        set(gca,'xtick',opt.xtick_xP);
    end
    if isfield(opt,'ytick_xP') && ~any(isnan(opt.ytick_xP)),
        set(gca,'ytick',opt.ytick_xP);
    end
    %
end
%
p_opt = input_dke_yp('Printing option (-1->2)',-1,-1:2);%option for printing
% 
print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_I_rho'],[datapath,filesep,'figures',filesep],1);
print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_I'],[datapath,filesep,'figures',filesep],101);
print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_rho'],[datapath,filesep,'figures',filesep],102);
print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_eta'],[datapath,filesep,'figures',filesep],2);
print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_ksi'],[datapath,filesep,'figures',filesep],3);
print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_P'],[datapath,filesep,'figures',filesep],4);
print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_s'],[datapath,filesep,'figures',filesep],5);
print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_Npar'],[datapath,filesep,'figures',filesep],6);
%
if ndisp >= 1,
    %
    print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_xJ'],[datapath,filesep,'figures',filesep],7);
    print_jd(p_opt,[equilbase,id_simul_o,'_',var.str,'_scan',locid_simul,'_xP'],[datapath,filesep,'figures',filesep],8);
    %
end
% 
