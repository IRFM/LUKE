function fproc_HXR_varscan(basestr,file_str,shotnum,shotime,id_simul_o,locid_simul,locpath_simul,...
    var,ic,krange,dtexp,HXRopt,cnumber,kdisp,opt)
%
savepath = [basestr,filesep,shotnum,filesep];
path_simul = [savepath,locpath_simul];
%
hxr_file = [savepath,'HXR_',basestr,'_',shotnum,'.mat'];
if ~exist(hxr_file,'file'),
    get_hxrspec_forLUKE_jd(basestr,str2num(shotnum),savepath)
end
%
exp_file = [savepath,'HXREXP_',basestr,'_',shotnum,'.mat'];
if ~exist(exp_file,'file'),
    collect_hxr_forLUKE_jd(basestr,str2num(shotnum),HXRopt,savepath)
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
    ivar_dispexp = ivar_disp;
    %
    if opt.xdisp == 0,
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
    equilbase = [file_str,basestr,'_',shotnum,'_',shotime,'_'];
    nvar = length(var.list);
    ttimes = repmat(str2num(shotime),[1,nvar]);
    ivar_disp = [];
    for ivar = 1:nvar,
        var.liststr{ivar} = num2str(var.list(ivar));
        if any(var.list(ivar) == var.disp),
            ivar_disp = [ivar_disp,ivar];
            ivar_dispexp = ivar;
        end
    end
    %
end
%
var_disp = var.list(ivar_disp);
ndisp = length(var_disp);
%
% J_exp = NaN;
% xrho_exp = NaN;
%
icdisp = 1 + cnumber - ic(1);
%
nc = length(ic);
%nk = length(ik);
%
dI_tot = NaN(1,nvar);
dI_exp = NaN(1,nvar);
%dt = NaN(1,nvar);
%
ds_c3po = NaN(1,nvar);
ds_luke = NaN(1,nvar);
%
dp0_rf_2piRp = NaN(1,nvar);
dp_rf_2piRp = NaN(1,nvar);
dp_rf_2piRp_lin = NaN(1,nvar);
%
%dJ = NaN(nr,nvar);
%dxrho = NaN(nr,nvar);
%
Tphplasma = NaN(nc,nvar);
Tphexp = NaN(nc,nvar);
Tphdiag = NaN(nc,nvar);
eTphplasma = NaN(nc,nvar);
eTphexp = NaN(nc,nvar);
eTphdiag = NaN(nc,nvar);
Aplasma = NaN(nc,nvar);
Aexp = NaN(nc,nvar);
Adiag = NaN(nc,nvar);
eAplasma = NaN(nc,nvar);
eAexp = NaN(nc,nvar);
eAdiag = NaN(nc,nvar);
Qplasma = NaN(nc,nvar);
Qexp = NaN(nc,nvar);
Qdiag = NaN(nc,nvar);
%
%dNdtplasma = NaN(nk,nc,nvar);
%dNdtdiag = NaN(nk,nc,nvar);
%
dvarplasma = NaN(1,nvar);
dvardiag = NaN(1,nvar);
%
icpeak = NaN(1,nvar);
%
varmask = false(1,nvar);
%
for ivar = 1:nvar,
    %
    texp = [ttimes(ivar) - dtexp/2,ttimes(ivar) + dtexp/2]; 
    %
    id_simul = [equilbase,id_simul_o,'_',var.str,'_',var.liststr{ivar},locid_simul];%Simulation ID
    %
    [hxr_proc,hxr,data_proc] = fproc_hxr(basestr,path_simul,id_simul,hxr_file,exp_file,texp,ic,krange,opt);
    %
    if isempty(hxr_proc),
        varmask(ivar) = true;
        %
        continue
    end
    %
    dI_tot(ivar) = data_proc.scalar.I_tot;
    %
    if isfield(data_proc.scalar,'I_exp'),
        dI_exp(ivar) = data_proc.scalar.I_exp;
    end
    %
    dp0_rf_2piRp(ivar) = data_proc.scalar.p0_rf_2piRp;
    dp_rf_2piRp(ivar) = data_proc.scalar.p_rf_2piRp;
    dp_rf_2piRp_lin(ivar) = data_proc.scalar.p_rf_2piRp_lin;
    %
    dJ(:,ivar) = data_proc.radial.J_tot.';
    dP(:,ivar) = data_proc.radial.P_rf.';
    %
    if opt.rho == 'g',
        dxrho(:,ivar) = data_proc.radial.xrhoG.';
    elseif opt.rho == 'p',
        dxrho(:,ivar) = data_proc.radial.xrhoP.';
    elseif opt.rho == 't',
        dxrho(:,ivar) = data_proc.radial.xrhoT.';
    elseif opt.rho == 'v',
        dxrho(:,ivar) = data_proc.radial.xrhoV.';
    else
        error('rho type not recognized')
    end
    %
    %dxrho(:,ivar) = data_proc.radial.xrho.';
    %
    ds_c3po(ivar) = 0;
    ds_luke(ivar) = 0;
    %
    if isfield(data_proc,'wave') && isfield(data_proc.wave,'wrays'),
        xs_c3po = [];
        xP0_2piRp_c3po = [];
        xs_luke = [];
        xP0_2piRp_luke = [];
        for iw = 1:length(data_proc.wave.wrays),
            for iray = 1:length(data_proc.wave.wrays{iw}),
                xs_c3po = [xs_c3po,data_proc.wave.wrays{iw}{iray}.c3po.ss];
                xP0_2piRp_c3po = [xP0_2piRp_c3po,data_proc.wave.wrays{iw}{iray}.c3po.P0_2piRp];
                if isfield(data_proc.wave.wrays{iw}{iray},'luke'),
                    xs_luke = [xs_luke,data_proc.wave.wrays{iw}{iray}.luke{end}.ss];
                    xP0_2piRp_luke = [xP0_2piRp_luke,data_proc.wave.wrays{iw}{iray}.luke{end}.P0_2piRp];
                end
            end
        end
        %
        ds_c3po(ivar) = sum(xs_c3po.*xP0_2piRp_c3po)/sum(xP0_2piRp_c3po);
        %
        if ~isempty(xs_luke),
            ds_luke(ivar) = sum(xs_luke.*xP0_2piRp_luke)/sum(xP0_2piRp_luke);
        end
    end
    %
    Tphplasma(:,ivar) = hxr_proc.Tphplasma;        
    Tphdiag(:,ivar) = hxr_proc.Tphdiag;        
    Tphexp(:,ivar) = hxr_proc.Tphexp;
    Aplasma(:,ivar) = hxr_proc.Aplasma;        
    Adiag(:,ivar) = hxr_proc.Adiag;        
    Aexp(:,ivar) = hxr_proc.Aexp;
    eAplasma(:,ivar) = hxr_proc.eAplasma;        
    eAdiag(:,ivar) = hxr_proc.eAdiag;        
    eAexp(:,ivar) = hxr_proc.eAexp;
    Qplasma(:,ivar) = hxr_proc.Qplasma;        
    Qdiag(:,ivar) = hxr_proc.Qdiag;        
    Qexp(:,ivar) = hxr_proc.Qexp;
    eTphplasma(:,ivar) = hxr_proc.eTphplasma;        
    eTphdiag(:,ivar) = hxr_proc.eTphdiag;        
    eTphexp(:,ivar) = hxr_proc.eTphexp;
    %
    dvarplasma(ivar) = hxr_proc.dvarplasma;        
    dvardiag(ivar) = hxr_proc.dvardiag;        
    %
    icpeak(ivar) = hxr_proc.icpeak;
    %
    ik = hxr_proc.ik;
    %
    dNdtplasma(:,:,ivar) = hxr_proc.dNdtplasma(ik,ic);
    dNdtdiag(:,:,ivar) = hxr_proc.dNdtdiag(ik,ic);
    dNdtexp(:,:,ivar) = hxr_proc.dNdtexp(ik,ic);
    %dNdtexp2(:,:,ivar) = hxr_proc.dNdtexp(ik2,ic);
    %
    %dt(ivar) = hxr.dt;
    %
    k(:,ivar) = hxr_proc.k(ik);
    %k2 = hxr_proc.k(ik2);
    %
end
%
if ~exist('k','var'),
    disp('No results found. Aborted.')
    return
end
%
dNdtplasma(:,:,varmask) = NaN;
dNdtdiag(:,:,varmask) = NaN;
dNdtexp(:,:,varmask) = NaN;
%
dt = 0.016;%%%%%
%
if ~all(all(k(:,~varmask) == repmat(k(:,1),[1,sum(~varmask)]))),
    error('verify energy list')
else
    k = k(:,1);
end
%
nk = length(k);
ikdisp = find(k == mean(kdisp));
%
dNdtdiag_disp = reshape(dNdtdiag(:,icdisp,:),[nk,nvar]).';
dNdtplasma_disp = reshape(dNdtplasma(:,icdisp,:),[nk,nvar]).';
dNdtexp_disp = reshape(dNdtexp(:,icdisp,:),[nk,nvar]).';
%
sdNdtdiag = reshape(sum(dNdtdiag,1),[nc,nvar]);%count rate
sdNdtplasma = reshape(sum(dNdtplasma,1),[nc,nvar]);%count rate
sdNdtexp = reshape(sum(dNdtexp,1),[nc,nvar]);%count rate
%
ndNdtdiag = sdNdtdiag./repmat(sdNdtdiag(icdisp,:),[nc,1]);%count rate
ndNdtplasma = sdNdtplasma./repmat(sdNdtplasma(icdisp,:),[nc,1]);%count rate
ndNdtexp = sdNdtexp./repmat(sdNdtexp(icdisp,:),[nc,1]);%count rate
%
endNdtdiag = sqrt(sdNdtdiag/dt)./repmat(sdNdtdiag(icdisp,:),[nc,1]);%count rate
endNdtplasma = sqrt(sdNdtplasma/dt)./repmat(sdNdtplasma(icdisp,:),[nc,1]);%count rate
endNdtexp = sqrt(sdNdtexp/dt)./repmat(sdNdtexp(icdisp,:),[nc,1]);%count rate
%
dPfrac = dp_rf_2piRp./dp0_rf_2piRp;
dPfrac_lin = dp_rf_2piRp_lin./dp0_rf_2piRp;
%
style0 = 'none';
style = '-';
style2 = '--';
marker = 'none';
marker1 = '+';
marker2 = 'o';
marker3 = 's';
marker4 = '.';
markers = {marker1,marker2,marker3,marker4};
color = NaN;
color1 = 'k';
color2 = 'r';
color3 = 'b';
color4 = 'g';
color5 = 'm';
color6 = 'c';
colors = {color2,color3,color4,color5};
%
width = 0.5;
width2 = 2;
siz = 20+14*1i;
%
red = 0.9;
lspace = 0.7;
lspace2 = 0.5;
bspace = 0.7;
bspace2 = 0.6;
%
xlab = [var.lab,' (',var.unit,')'];
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
if isfield(opt,'icrej_exp') && ~isempty(opt.icrej_exp),
    maskic_exp = ~any(repmat(ic,[length(opt.icrej_exp),1]) == repmat(opt.icrej_exp.',[1,length(ic)]),1);
else
    maskic_exp = 1:nc;
end
%
xlog = var.log;
%
xlab_ic = 'Chord #';
xlim_ic = [min(ic)-1,max(ic)+1];
xtick_ic = 0:5:60;
%
ncol = length(colors);
%
chordstr = ['chord # ',num2str(cnumber)];
%dispstr = [];
displeg = {};
for ivar = 1:ndisp,
    ivarstr = [var.lab,' = ',num2str(var_disp(ivar)),' ',var.unit];
    %dispstr = [dispstr,ivarstr];
    displeg = [displeg,ivarstr];
end
kstr = ['k = ',num2str(kdisp(1)),' - ',num2str(kdisp(2)),' keV'];
%
kmin = min(k);
kmax = max(k);
%
krangestr = ['k = ',num2str(kmin),' - ',num2str(kmax),' keV'];
%
savestr = [equilbase,id_simul_o,locid_simul];%Save string
%
% --------------------- Current -----------------------
%
ifig = 1;figure(ifig),clf,set(ifig,'Name','Current')
%
ylab = 'Current (kA)';
tit = '';
%
if isfield(opt,'ylim_I'),
    ylim = opt.ylim_I;
else
    ylim = 1e3*[0,max(dI_tot)]*1.2;
end
%
leg = {'LUKE'};
%
if var.firstref,
    graph1D_jd(xlim,[dI_tot(1),dI_tot(1)]*1e3,xlog,0,'','','',NaN,xlim,ylim,style,marker,color3,width,siz);
    leg = [[var.lab,' = ',num2str(var.list(1))],leg];
end
%
if var.lastref,
    graph1D_jd(xlim,[dI_tot(end),dI_tot(end)]*1e3,xlog,0,'','','',NaN,xlim,ylim,style2,marker,color3,width,siz);
    leg = [[var.lab,' = ',num2str(var.list(end))],leg];
end
%
if ~all(isnan(dI_exp)) && (~isfield(opt,'I_exp') || opt.I_exp == 1),
    graph1D_jd(var.list,dI_exp*1e3,0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz);
    leg = ['Exp.',leg];
end
graph1D_jd(var.list,dI_tot*1e3,xlog,0,xlab,ylab,tit,leg,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace);
%
set(gca,'xtick',xtick);
%set(gca,'xminorgrid','off')
%set(gca,'xminortick','off')
%
if isfield(opt,'ytick_I'),
    set(gca,'ytick',opt.ytick_I);
end
%
print_jd(opt.print,['Fig_',savestr,'_I_tot'],[path_simul,'figures/'],ifig);
%
% --------------------- TPH 2D -----------------------
%
plot_2D_jd(opt,path_simul,savestr,'TPH_2D',ic(maskic_exp),Tphexp(maskic_exp,ivar_dispexp),eTphexp(maskic_exp,ivar_dispexp),...
    ic,Tphdiag(:,ivar_disp),eTphdiag(:,ivar_disp),...ic,Tphplasma(:,ivar_disp),eTphplasma(:,ivar_disp),
    {'Exp.','LUKE'},2,'TPH2D',xlab_ic,'Photon Temperature (keV)',displeg,xlim_ic,'ylim_Tph',xtick_ic,'ytick_Tph',...{'Exp.','plasma','diag.'}
    {style2,style},[marker,markers],[color1,colors],[width,width2],siz,red,lspace,bspace2);
% 
% if ndisp >= 1,
%     %
%     ifig = 2;figure(ifig),clf,set(ifig,'Name','TPH2D')
%     %
%     ylab = 'Photon Temperature (keV)';
%     tit = dispstr;
%     if isfield(opt,'ylim_Tph'),
%         ylim = opt.ylim_Tph;
%     else
%         ylim = [0,max(max([Tphdiag(:,ivar_disp);Tphexp(maskic_exp,ivar_disp)]))]*1.2;%Tphplasma(:,ivar_disp),
%     end
%     %
%     leg = {'LUKE'};%{'plasma','diag.'};%
%     %
%     if ~all(isnan(Tphexp(:,ivar_disp(1)))),
%         if ndisp > 1,
%             localcol = colors{rem(1,ncol)};
%             localwidth = width;
%         else
%             localcol = color1;
%             localwidth = width2;
%         end
%         graph1D_jd(ic(maskic_exp),Tphexp(maskic_exp,ivar_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,localcol,localwidth,siz,gca,1,lspace,bspace2,eTphexp(maskic_exp,ivar_disp(1)));
%         leg = ['Exp.',leg];
%     end
%     %graph1D_jd(ic,Tphplasma(:,ivar_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(1,ncol)},width2,siz,gca,1,lspace,bspace2,eTphplasma(:,ivar_disp(1)));
%     graph1D_jd(ic,Tphdiag(:,ivar_disp(1)),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,style,marker3,colors{rem(1,ncol)},width2,siz,gca,red,lspace,bspace2,eTphdiag(:,ivar_disp(1)));
%     for ivar = 2:ndisp,
%         %graph1D_jd(ic,Tphplasma(:,ivar_disp(ivar)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(ivar,ncol)},width2,siz,gca,1,lspace,bspace2,eTphplasma(:,ivar_disp(ivar)));
%         graph1D_jd(ic,Tphdiag(:,ivar_disp(ivar)),0,0,'','','',NaN,xlim_ic,ylim,style,marker3,colors{rem(ivar,ncol)},width2,siz,gca,1,lspace,bspace2,eTphdiag(:,ivar_disp(ivar)));
%         if ~all(isnan(Tphexp(:,ivar_disp(ivar)))),
%             graph1D_jd(ic(maskic_exp),Tphexp(maskic_exp,ivar_disp(ivar)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,colors{rem(ivar,ncol)},width,siz,gca,1,lspace,bspace2,eTphexp(maskic_exp,ivar_disp(ivar)));
%         end
%     end
%     %
%     set(gca,'xtick',xtick_ic);
%     %
%     if isfield(opt,'ytick_Tph'),
%         set(gca,'ytick',opt.ytick_Tph);
%     end
%     % 
%     print_jd(opt.print,['Fig_',savestr,'_TPH_2D'],[path_simul,'figures/'],ifig);
%     %
% end
%
% --------------------- TPH & CR 1D -----------------------
%
ifig = 3;figure(ifig),clf,set(ifig,'Name','TPHCR1D')
%
ylab = '';
tit = [chordstr,'; ',krangestr];
fac = 1e3;
%
if isfield(opt,'ylim_Tph'),
    ylim = opt.ylim_Tph;
else
    ylim_Tph = [0,max(max([Tphdiag(icdisp,:),Tphexp(icdisp,:)]))]*1.2;%Tphplasma(icdisp,:),
    ylim_CR = [0,max(max([sdNdtdiag(icdisp,:),sdNdtexp(icdisp,:)]))]*1.2;%sdNdtplasma(icdisp,:),
    ylim = max([ylim_Tph;ylim_CR/fac]);
end
%
leg = {'T_{ph} LUKE','CR LUKE (ms^{-1})'};%{'plasma','diag.'};%
%
if ~all(isnan(Tphexp(icdisp,:))),
    graph1D_jd(var.list,Tphexp(icdisp,:),xlog,0,'','','',NaN,xlim,ylim,style,marker,color2,width,siz,gca,1,lspace,bspace2,eTphexp(icdisp,:));
    graph1D_jd(var.list,sdNdtexp(icdisp,:)/fac,xlog,0,'','','',NaN,xlim,ylim,style,marker,color3,width,siz,gca,1,lspace,bspace2,sqrt(sdNdtexp(icdisp,:)/dt)/fac);
    leg = ['T_{ph} Exp.','CR Exp. (ms^{-1})',leg];
end
%graph1D_jd(var.list,Tphplasma(icdisp,:),xlog,0,'','','',NaN,xlim,ylim,style,marker2,color2,width2,siz,gca,1,lspace,bspace2,eTphplasma(icdisp,:));
%graph1D_jd(var.list,sdNdtplasma(icdisp,:)/fac,xlog,0,'','','',leg,xlim,ylim,style,marker2,color3,width2,siz,gca,1,lspace2,bspace,sqrt(sdNdtplasma(icdisp,:)/dt)/fac);
graph1D_jd(var.list,Tphdiag(icdisp,:),xlog,0,xlab,ylab,tit,NaN,xlim,ylim,style2,marker2,color2,width2,siz,gca,red,lspace,bspace2,eTphdiag(icdisp,:));
graph1D_jd(var.list,sdNdtdiag(icdisp,:)/fac,xlog,0,'','','',leg,xlim,ylim,style2,marker2,color3,width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtdiag(icdisp,:)/dt)/fac);
%
set(gca,'xtick',xtick);
%
if isfield(opt,'ytick_Tph'),
    set(gca,'ytick',opt.ytick_Tph);
end
% 
print_jd(opt.print,['Fig_',savestr,'_TPHCR_1D_ic_',num2str(icdisp)],[path_simul,'figures/'],ifig);
%
%
% --------------------- TPH 1D -----------------------
%
ifig = 301;figure(ifig),clf,set(ifig,'Name','TPHCR1D')
%
ylab = 'Photon Temperature (keV)';
tit = [chordstr,'; ',krangestr];
%
if isfield(opt,'ylim_Tph'),
    ylim = opt.ylim_Tph;
else
    ylim = [0,max(max([Tphdiag(icdisp,:),Tphexp(icdisp,:)]))]*1.2;%Tphplasma(icdisp,:),
end
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~all(isnan(Tphexp(icdisp,:))),
    graph1D_jd(var.list,Tphexp(icdisp,:),xlog,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace2,eTphexp(icdisp,:));
    leg = ['Exp.',leg];
end
%graph1D_jd(var.list,Tphplasma(icdisp,:),xlog,0,'','','',NaN,xlim,ylim,style2,marker2,color2,width2,siz,gca,1,lspace,bspace2,eTphplasma(icdisp,:));
graph1D_jd(var.list,Tphdiag(icdisp,:),xlog,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace2,eTphdiag(icdisp,:));
%
set(gca,'xtick',xtick);
%
if isfield(opt,'ytick_Tph'),
    set(gca,'ytick',opt.ytick_Tph);
end
% 
print_jd(opt.print,['Fig_',savestr,'_TPH_1D_ic_',num2str(icdisp)],[path_simul,'figures/'],ifig);
%
%
% --------------------- TOTAL COUNT RATE 1D -----------------------
%
ifig = 302;figure(ifig),clf,set(ifig,'Name','CRTOT1D')
%
ylab = 'Count rate (s^{-1})';
tit = [chordstr,'; ',krangestr];
%
if isfield(opt,'ylog_CR'),
    ylog = opt.ylog_CR;
else
    ylog = 0;
end
%
if isfield(opt,'ylim_CRTOT'),
    ylim = opt.ylim_CRTOT;
elseif ylog == 1,
    ylim = [min(min([sdNdtdiag(icdisp,:),sdNdtexp(icdisp,:)]))/2,max(max([sdNdtdiag(icdisp,:),sdNdtexp(icdisp,:)]))*2];%sdNdtplasma(icdisp,:),
else
    ylim = [0,max(max([sdNdtdiag(icdisp,:),sdNdtexp(icdisp,:)]))]*1.2;%sdNdtplasma(icdisp,:),
end
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~all(isnan(sdNdtexp(icdisp,:))),
    graph1D_jd(var.list,sdNdtexp(icdisp,:),xlog,ylog,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtexp(icdisp,:)/dt));
    leg = ['Exp.',leg];
end
%graph1D_jd(var.list,sdNdtplasma(icdisp,:)/fac,xlog,ylog,'','','',leg,xlim,ylim,style2,marker2,color2,width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtplasma(icdisp,:)/dt));
graph1D_jd(var.list,sdNdtdiag(icdisp,:),xlog,ylog,xlab,ylab,tit,NaN,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace2,sqrt(sdNdtdiag(icdisp,:)/dt));
%
set(gca,'xtick',xtick);
%
if isfield(opt,'ytick_CRTOT'),
    set(gca,'ytick',opt.ytick_CRTOT);
end
% 
print_jd(opt.print,['Fig_',savestr,'_CR_TOT_1D_ic_',num2str(icdisp)],[path_simul,'figures/'],ifig);
%
%
% --------------------- SELECTED COUNT RATE 1D -----------------------
%
ifig = 303;figure(ifig),clf,set(ifig,'Name','CRSEL1D')
%
ylab = 'Count rate (s^{-1})';
tit = [chordstr,'; ',kstr];
%
if isfield(opt,'ylog_CR'),
    ylog = opt.ylog_CR;
else
    ylog = 0;
end
%
if isfield(opt,'ylim_CRSEL'),
    ylim = opt.ylim_CRSEL;
elseif ylog == 1,
    ylim = [min([dNdtdiag_disp(:,ikdisp);dNdtexp_disp(:,ikdisp)])/2,max([dNdtdiag_disp(:,ikdisp);dNdtexp_disp(:,ikdisp)])*2];%dNdtplasma_disp(:,ikdisp),
else
    ylim = [0,max([dNdtdiag_disp(:,ikdisp);dNdtexp_disp(:,ikdisp)])]*1.2;%dNdtplasma_disp(:,ikdisp),
end
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~all(isnan(sdNdtexp(icdisp,:))),
    graph1D_jd(var.list,dNdtexp_disp(:,ikdisp),xlog,ylog,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtexp_disp(:,ikdisp)/dt));
    leg = ['Exp.',leg];
end
%graph1D_jd(var.list,dNdtplasma_disp(:,ikdisp)/fac,xlog,ylog,'','','',leg,xlim,ylim,style2,marker2,color2,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtplasma_disp(:,ikdisp)/dt));
graph1D_jd(var.list,dNdtdiag_disp(:,ikdisp),xlog,ylog,xlab,ylab,tit,NaN,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace2,sqrt(dNdtdiag_disp(:,ikdisp)/dt));
%
set(gca,'xtick',xtick);
%
if isfield(opt,'ytick_CRSEL'),
    set(gca,'ytick',opt.ytick_CRSEL);
end
% 
print_jd(opt.print,['Fig_',savestr,'_CR_SEL_1D_ic_',num2str(icdisp)],[path_simul,'figures/'],ifig);
%
%
% --------------------- COUNT RATE 2D -----------------------
%
plot_2D_jd(opt,path_simul,savestr,'CR_2D',ic(maskic_exp),sdNdtexp(maskic_exp,ivar_dispexp),sqrt(sdNdtexp(maskic_exp,ivar_dispexp)/dt),...
    ic,sdNdtdiag(:,ivar_disp),sqrt(sdNdtdiag(:,ivar_disp)/dt),...ic,sdNdtplasma(:,ivar_disp),sqrt(sdNdtplasma(:,ivar_disp)/dt),
    {'Exp.','LUKE'},4,'CR2D',xlab_ic,['Count rate (s^{-1}); ',krangestr],displeg,xlim_ic,'ylim_CRTOT',xtick_ic,'ytick_CRTOT',...{'Exp.','plasma','diag.'}
    {style2,style},[marker,markers],[color1,colors],[width,width2],siz,red,lspace,bspace2);
%
% if ndisp >= 1,
%     %
%     ifig = 4;figure(ifig),clf,set(ifig,'Name','CR 2D')
%     %
%     ylab = ['Count rate (s^{-1}); ',krangestr];
%     tit = dispstr;
%     if isfield(opt,'ylim_CRTOT'),
%         ylim = opt.ylim_CRTOT;
%     else
%         ylim = [0,max(max([sdNdtdiag(:,ivar_disp);sdNdtexp(maskic_exp,ivar_disp)]))]*1.2;%sdNdtplasma(:,ivar_disp),
%     end
%     %
%     leg = {'LUKE'};%{'plasma','diag.'};%
%     %
%     if ~all(isnan(sdNdtexp(:,ivar_disp(1)))),
%         if ndisp > 1,
%             localcol = colors{rem(1,ncol)};
%             localwidth = width;
%         else
%             localcol = color1;
%             localwidth = width2;
%         end
%         graph1D_jd(ic(maskic_exp),sdNdtexp(maskic_exp,ivar_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,localcol,localwidth,siz,gca,1,lspace,bspace2,sqrt(sdNdtexp(maskic_exp,ivar_disp(1))/dt));
%         leg = ['Exp.',leg];
%     end
%     %graph1D_jd(ic,sdNdtplasma(:,ivar_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(1,ncol)},width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtplasma(:,ivar_disp(1))/dt));
%     graph1D_jd(ic,sdNdtdiag(:,ivar_disp(1)),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,style,marker3,colors{rem(1,ncol)},width2,siz,gca,red,lspace,bspace2,sqrt(sdNdtdiag(:,ivar_disp(1))/dt));
%     for ivar = 2:ndisp,
%         %graph1D_jd(ic,sdNdtplasma(:,ivar_disp(ivar)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(ivar,ncol)},width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtplasma(:,ivar_disp(ivar))/dt));
%         graph1D_jd(ic,sdNdtdiag(:,ivar_disp(ivar)),0,0,'','','',NaN,xlim_ic,ylim,style,marker3,colors{rem(ivar,ncol)},width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtdiag(:,ivar_disp(ivar))/dt));
%         if ~all(isnan(sdNdtexp(:,ivar_disp(ivar)))),
%             graph1D_jd(ic(maskic_exp),sdNdtexp(maskic_exp,ivar_disp(ivar)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,colors{rem(ivar,ncol)},width,siz,gca,1,lspace,bspace2,sqrt(sdNdtexp(maskic_exp,ivar_disp(ivar))/dt));
%         end
%     end
%     %
%     set(gca,'xtick',xtick_ic);
%     %
%     if isfield(opt,'ytick_CRTOT'),
%         set(gca,'ytick',opt.ytick_CRTOT);
%     end
%     % 
%     print_jd(opt.print,['Fig_',savestr,'_CR_2D'],[path_simul,'figures/'],ifig);
%     %
% end
%
%
% --------------------- COUNT RATE 2D NORM -----------------------
%
plot_2D_jd(opt,path_simul,savestr,'CR_2D_norm',ic(maskic_exp),ndNdtexp(maskic_exp,ivar_dispexp),endNdtexp(maskic_exp,ivar_dispexp),...
    ic,ndNdtdiag(:,ivar_disp),endNdtdiag(:,ivar_disp),...ic,ndNdtplasma(:,ivar_disp),endNdtplasma(:,ivar_disp),
    {'Exp.','LUKE'},5,'CR2D norm',xlab_ic,['Normalized count rate (s^{-1}); ',krangestr],displeg,xlim_ic,'ylim_CRNORM',xtick_ic,'ytick_CRNORM',...{'Exp.','plasma','diag.'}
    {style2,style},[marker,markers],[color1,colors],[width,width2],siz,red,lspace,bspace2);
%
% if ndisp >= 1,
%     %
%     ifig = 5;figure(ifig),clf,set(ifig,'Name','CR 2D norm')
%     %
%     ylab = ['Normalized Count rate (s^{-1}); ',krangestr];
%     tit = dispstr;
%     if isfield(opt,'ylim_CRNORM'),
%         ylim = opt.ylim_CRNORM;
%     else
%         ylim = [0,max(max([ndNdtdiag(:,ivar_disp);ndNdtexp(maskic_exp,ivar_disp)]))]*1.2;%ndNdtplasma(:,ivar_disp),
%     end
%     %
%     leg = {'LUKE'};%{'plasma','diag.'};%
%     %
%     if ~all(isnan(ndNdtexp(:,ivar_disp(1)))),
%         if ndisp > 1,
%             localcol = colors{rem(1,ncol)};
%             localwidth = width;
%         else
%             localcol = color1;
%             localwidth = width2;
%         end
%         graph1D_jd(ic(maskic_exp),ndNdtexp(maskic_exp,ivar_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,localcol,localwidth,siz,gca,1,lspace,bspace2,endNdtexp(maskic_exp,ivar_disp(1)));
%         leg = ['Exp.',leg];
%     end
%     %graph1D_jd(ic,ndNdtplasma(:,ivar_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(1,ncol)},width2,siz,gca,1,lspace,bspace2,endNdtplasma(:,ivar_disp(1)));
%     graph1D_jd(ic,ndNdtdiag(:,ivar_disp(1)),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,style,marker3,colors{rem(1,ncol)},width2,siz,gca,red,lspace,bspace2,endNdtdiag(:,ivar_disp(1)));
%     for ivar = 2:ndisp,
%         %graph1D_jd(ic,ndNdtplasma(:,ivar_disp(ivar)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(ivar,ncol)},width2,siz,gca,1,lspace,bspace2,endNdtplasma(:,ivar_disp(ivar)));
%         graph1D_jd(ic,ndNdtdiag(:,ivar_disp(ivar)),0,0,'','','',NaN,xlim_ic,ylim,style,marker3,colors{rem(ivar,ncol)},width2,siz,gca,1,lspace,bspace2,endNdtdiag(:,ivar_disp(ivar)));
%         if ~all(isnan(ndNdtexp(:,ivar_disp(ivar)))),
%             graph1D_jd(ic(maskic_exp),ndNdtexp(maskic_exp,ivar_disp(ivar)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,colors{rem(ivar,ncol)},width,siz,gca,1,lspace,bspace2,endNdtexp(maskic_exp,ivar_disp(ivar)));
%         end
%     end
%     %
%     set(gca,'xtick',xtick_ic);
%     %
%     if isfield(opt,'ytick_CRNORM'),
%         set(gca,'ytick',opt.ytick_CRNORM);
%     end
%     % 
%     print_jd(opt.print,['Fig_',savestr,'_CR_2D_norm'],[path_simul,'figures/'],ifig);
%     %
% end
%
%
% --------------------- CURRENT PROFILE -----------------------
%
if ndisp >= 1,
    %
    ifig = 6;figure(ifig),clf,set(ifig,'Name','Current profiles')
    %
    xlab_rho = '\rho';
    xlim_rho = [0,1];
    xtick_rho = 0:0.2:1;
    %
    ylab = 'J (MA/m^2)';
    tit = '';
    %
    if isfield(opt,'ylim_J'),
        ylim = opt.ylim_J;
    else
        ylim = [min(min(dJ(:,ivar_disp))),max(max(dJ(:,ivar_disp)))]*1.2;
    end
    %
    leg = {};%{'LUKE'};%{'plasma','diag.'};%
    %
    for ivar = 1:ndisp-1,
        graph1D_jd(dxrho(:,ivar_disp(ivar)),dJ(:,ivar_disp(ivar)).',0,0,'','','',NaN,xlim_rho,ylim,style,markers{rem(ivar,ncol)},colors{rem(ivar,ncol)},width2,siz);
    end
    %
    graph1D_jd(dxrho(:,ivar_disp(ndisp)),dJ(:,ivar_disp(ndisp)).',0,0,xlab_rho,ylab,tit,displeg,xlim_rho,ylim,style,markers{rem(ndisp,ncol)},colors{rem(ndisp,ncol)},width2,siz,gca,red,lspace,bspace);
    %
    set(gca,'xtick',xtick_rho);
    if isfield(opt,'ytick_J'),
        set(gca,'ytick',opt.ytick_J);
    end
    % 
    print_jd(opt.print,['Fig_',savestr,'_J'],[path_simul,'figures/'],ifig);
    %
end
%
% --------------------- POWER PROFILE -----------------------
%
if ndisp >= 1,
    %
    ifig = 7;figure(ifig),clf,set(ifig,'Name','Power profiles')
    %
    xlab_rho = '\rho';
    xlim_rho = [0,1];
    xtick_rho = 0:0.2:1;
    %
    ylab = 'P_{rf} (MW/m^3)';
    tit = '';
    %
    if isfield(opt,'ylim_P'),
        ylim = opt.ylim_P;
    else
        ylim = [0,max(max(dP(:,ivar_disp)))]*1.2;
    end
    %
    leg = {};%{'LUKE'};%{'plasma','diag.'};%
    %
    for ivar = 1:ndisp-1,
        graph1D_jd(dxrho(:,ivar_disp(ivar)),dP(:,ivar_disp(ivar)).',0,0,'','','',NaN,xlim_rho,ylim,style,markers{rem(ivar,ncol)},colors{rem(ivar,ncol)},width2,siz);
    end
    %
    graph1D_jd(dxrho(:,ivar_disp(ndisp)),dP(:,ivar_disp(ndisp)).',0,0,xlab_rho,ylab,tit,displeg,xlim_rho,ylim,style,markers{rem(ndisp,ncol)},colors{rem(ndisp,ncol)},width2,siz,gca,red,lspace,bspace);
    %
    set(gca,'xtick',xtick_rho);
    if isfield(opt,'ytick_P'),
        set(gca,'ytick',opt.ytick_P);
    end
    % 
    print_jd(opt.print,['Fig_',savestr,'_P'],[path_simul,'figures/'],ifig);
    %
end
%
%
% figure(7),clf,set(7,'Name','Selected Count rate')
% %
% ylab = ['Count rate (s^{-1}) [',num2str(kmin),' - ',num2str(kmax),' keV]'];
% ylim = NaN;%[0,2500];
% %ytick = 0:500:2500;
% %
% leg = {};
% %
% for ivar = 1:length(var.disp),
%     ivardisp = find(abs(var.list - var.disp(ivar)) < 10*eps);   
%     %
%     if isempty(ivardisp),
%         continue
%     end
%     %
%     sdNdtdiag_disp = sdNdtdiag(:,ivardisp);%count rate
%     %
%     graph1D_jd(ic,sdNdtdiag_disp,0,0,'','','',NaN,xlim_ic,ylim,...
%         style,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,sqrt(sdNdtdiag_disp/dt));
%     %
%     leg = [leg,[var.lab,' = ',num2str(var.disp(ivar)),' ',var.unit]];
%     %
% end
% %
% set(gca,'xtick',xtick_ic);
% %set(gca,'ytick',ytick);
% %
% %
% leg = [leg,'Exp.'];
% %
% graph1D_jd(ic,sdNdtexp,0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,...
%     style,marker,color1,width2,siz,gca,red,lspace,bspace,sqrt(sdNdtexp/dt));
% %
% % for ivar = 1:length(var_disp),
% %     ivardisp = find(abs(var.list - var_disp(ivar)) < 10*eps); 
% %     %
% %     if isempty(ivardisp),
% %         continue
% %     end
% %     %
% %     sdNdtplasma_disp = sdNdtplasma(:,ivardisp);%number of counts
% %     %
% %     graph1D_jd(ic,sdNdtplasma_disp,0,0,'','','',NaN,xlim_ic,ylim,...
% %         style2,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,sqrt(sdNdtplasma_disp/dt));
% %     %
% % end
% % 
% %print_jd(opt.print,['Fig_select_countrate_',num2str(vmindisp),'_',id_simul_o],[path_simul,'figures/'],7);
% print_jd(opt.print,['Fig_select_countrate_',id_simul_o],[path_simul,'figures/'],7);
% %
% %
% %
% figure(8),clf,set(8,'Name','Selected Norm Count rate')
% %
% ylab = ['Normalized Count rate [',num2str(kmin),' - ',num2str(kmax),' keV]'];
% ylim = [0,1.4];%sdNdtplasma,
% ytick = 0:0.2:1.4;
% %
% leg = {};
% %
% for ivar = 1:length(var.disp),
%     ivardisp = find(abs(var.list - var.disp(ivar)) < 10*eps);   
%     %
%     if isempty(ivardisp),
%         continue
%     end
%     %
%     ndNdtdiag_disp = ndNdtdiag(:,ivardisp);%count rate
%     endNdtdiag_disp = endNdtdiag(:,ivardisp);%count rate
%     %
%     graph1D_jd(ic,ndNdtdiag_disp,0,0,'','','',NaN,xlim_ic,ylim,...
%         style,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,endNdtdiag_disp);
%     %
%     leg = [leg,[var.lab,' = ',num2str(var.disp(ivar)),' ',var.unit]];
%     %
% end
% %
% set(gca,'xtick',xtick_ic);
% set(gca,'ytick',ytick);
% %
% %
% leg = [leg,'Exp.'];
% %
% graph1D_jd(ic,ndNdtexp,0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,...
%     style,marker,color1,width2,siz,gca,red,lspace,bspace,endNdtexp);
% %
% % for ivar = 1:length(var_disp),
% %     ivardisp = find(abs(var.list - var_disp(ivar)) < 10*eps); 
% %     %
% %     if isempty(ivardisp),
% %         continue
% %     end
% %     %
% %     ndNdtplasma_disp = ndNdtplasma(:,ivardisp);%number of counts
% %     endNdtplasma_disp = endNdtplasma(:,ivardisp);%number of counts
% %     %
% %     graph1D_jd(ic,ndNdtplasma_disp,0,0,'','','',NaN,xlim_ic,ylim,...
% %         style2,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,endNdtplasma_disp);
% %     %
% % end
% % 
% %print_jd(opt.print,['Fig_select_norm_countrate_',num2str(vmindisp),'_',id_simul_o],[path_simul,'figures/'],8);
% print_jd(opt.print,['Fig_select_norm_countrate_',id_simul_o],[path_simul,'figures/'],8);
% %
%
%
% figure(9),clf,set(9,'Name','TPH_chord')
% %
% kmin = min(k);
% %
% ylab = ['Photon temperature (keV)'];
% tit = '';
% %
% ylim = NaN;%[0,2500];
% %ytick = 0:500:2500;
% %
% leg = {};
% %
% % for ivar = 1:length(var_disp),
% %     ivardisp = find(abs(var.list - var_disp(ivar)) < 10*eps);    
% %     %
% %     if isempty(ivardisp),
% %         continue
% %     end
% %     %
% %     maskQdiag = (1 - Qdiag(:,ivardisp,ivdisp) < 1e-2) & (Tphdiag(:,ivardisp,ivdisp) > eTphdiag(:,ivardisp,ivdisp));
% %     %
% %     graph1D_jd(ic(maskQdiag),Tphdiag(maskQdiag,ivardisp,ivdisp),0,0,'','','',NaN,xlim_ic,ylim,...
% %         style,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,eTphdiag(maskQdiag,ivardisp,ivdisp));
% %     %
% %     leg = [leg,[var_lab,' = ',num2str(var_disp(ivar)),' ',var_unit]];
% %     %
% % end
% %
% set(gca,'xtick',xtick_ic);
% %set(gca,'ytick',ytick);
% %
% leg = [leg,'Exp.'];
% %
% maskexp = (1 - Qexp < 1e-2) & (Tphexp > eTphexp);
% %
% graph1D_jd(ic(maskexp),Tphexp(maskexp),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,...
%     style,marker,color1,width2,siz,gca,red,lspace,bspace,eTphexp(maskexp));
% %
% % for ivar = 1:length(var_disp),
% %     ivardisp = find(abs(var.list - var_disp(ivar)) < 10*eps);   
% %     %
% %     if isempty(ivardisp),
% %         continue
% %     end
% %     %
% %     maskQplasma = (1 - Qplasma(:,ivardisp,ivdisp) < 1e-2) & (Tphplasma(:,ivardisp,ivdisp) > eTphplasma(:,ivardisp,ivdisp));
% %     %
% %     graph1D_jd(ic(maskQplasma),Tphplasma(maskQplasma,ivardisp,ivdisp),0,0,'','','',NaN,xlim_ic,ylim,...
% %         style,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,eTphplasma(maskQplasma,ivardisp,ivdisp));
% %     %
% %     leg = [leg,[var_lab,' = ',num2str(var_disp(ivar)),' ',var_unit]];
% %     %
% % end
% % 
% %print_jd(opt.print,['Fig_1D_tph_chord_',num2str(vmindisp),'_',id_simul_o],[path_simul,'figures/'],9);
% print_jd(opt.print,['Fig_1D_tph_chord_',id_simul_o],[path_simul,'figures/'],9);
%
%
% --------------------- Norm. Exp. CR -----------------------
%
if ndisp >= 1,
    %
    ylim = [0,1.2];
    ytick = 0:0.2:1.2;
    nvar_dispexp = length(ivar_dispexp);
    %
    for ivar = 1:nvar_dispexp,
        %
        if nvar_dispexp > 1,
            tit = displeg{ivar};
        else
            tit = '';
        end
        %
        ifig = 700+ivar;figure(ifig),clf,set(ifig,'Name','Exp. CR')
        %
        dNdtexp_sel = dNdtexp(:,maskic_exp,ivar_dispexp(ivar));
        dNdtexp_max = repmat(max(dNdtexp_sel,[],2),[1,nc]);
        Nnorm = dNdtexp_sel./dNdtexp_max;
        eNnorm = sqrt(dNdtexp_sel/dt)./dNdtexp_max;
        %
        leg = {};
        for iik = 1:length(k),
            leg{iik} = ['k = ',num2str(k(iik)),' keV'];
        end
        %
        graph1D_jd(repmat(ic.',[1,length(k)]),Nnorm.',0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,...
            style,marker,color,width2,siz,gca,red,lspace,bspace,eNnorm.');
        % 
        set(gca,'xtick',xtick_ic);
        set(gca,'ytick',ytick);
        %
        %print_jd(opt.print,['Fig_countrate_exp_',num2str(vmindisp),'_',id_simul_o],[path_simul,'figures/'],10);
        print_jd(opt.print,['Fig_',savestr,'_CR_EXP'],[path_simul,'figures/'],ifig);
        %
    end
end
%
% --------------------- Weighed ray length -----------------------
%
ifig = 8;figure(ifig),clf,set(ifig,'Name','Ray length')
%
ylab = 'Weighed ray length (m)';
tit = '';
ylim = [0,max([ds_c3po,ds_luke])]*1.5;
%
leg = {'C3PO','LUKE'};
%
graph1D_jd(var.list,ds_c3po,xlog,0,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz);
graph1D_jd(var.list,ds_luke,xlog,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
%
set(gca,'xtick',xtick);
%set(gca,'xminorgrid','off')
%set(gca,'xminortick','off')
%
print_jd(opt.print,['Fig_',savestr,'_S'],[path_simul,'figures/'],ifig);
%
% --------------------- Power absorption -----------------------
%
ifig = 9;figure(ifig),clf,set(ifig,'Name','Power')
%
ylab = 'Fraction of power absorbed';
tit = '';
ylim = [0,max([dPfrac,dPfrac_lin])]*1.5;
%
leg = {'C3PO','LUKE'};
%
graph1D_jd(var.list,dPfrac_lin,xlog,0,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz);
graph1D_jd(var.list,dPfrac,xlog,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
%
set(gca,'xtick',xtick);
%set(gca,'xminorgrid','off')
%set(gca,'xminortick','off')
%
print_jd(opt.print,['Fig_',savestr,'_Pvar'],[path_simul,'figures/'],ifig);


% %
% figure(3),clf,set(3,'Name','Deposition peak')
% %
% ylab = '\rho_{peak}';
% tit = '';
% ylim = [0,1];
% %
% leg = {'LUKE','C3PO'};
% %
% if var.firstref,
%     graph1D_jd(xlim,[drho(1),drho(1)],xlog,0,'','','',NaN,xlim,ylim,style,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var.list(1))],leg];
% end
% %
% if var.lastref,
%     graph1D_jd(xlim,[drho(end),drho(end)],xlog,0,'','','',NaN,xlim,ylim,style2,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var.list(end))],leg];
% end
% %
% graph1D_jd(var.list,drho,xlog,0,'','','',NaN,xlim,ylim,style,marker2,color2,width2,siz);
% graph1D_jd(var.list,drho_lin,xlog,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,color3,width2,siz,gca,red,lspace,bspace);
% %
% set(gca,'xtick',xtick);
% set(gca,'xminorgrid','off')
% set(gca,'xminortick','off')
% %
% print_jd(opt.print,['Fig_rho_peak_',id_simul_o],[path_simul,'figures/'],3);
% %
% %
% %
% figure(4),clf,set(4,'Name','RF ray fragments')
% %
% ylab = 'RF ray fragments';
% tit = '';
% ylim = NaN;
% %
% leg = {};
% %
% if var.firstref,
%     graph1D_jd(xlim,[dnfrags(1),dnfrags(1)],xlog,0,'','','',NaN,xlim,ylim,style,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var.list(1))],leg];
% end
% %
% if var.lastref,
%     graph1D_jd(xlim,[dnfrags(end),dnfrags(end)],xlog,0,'','','',NaN,xlim,ylim,style2,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var.list(end))],leg];
% end
% %
% graph1D_jd(var.list,dnfrags,xlog,0,xlab,ylab,tit,leg,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace);
% %
% set(gca,'xtick',xtick);
% set(gca,'xminorgrid','off')
% set(gca,'xminortick','off')
% %
% print_jd(opt.print,['Fig_nfrags_',id_simul_o],[path_simul,'figures/'],4);
% %
% %
% xlab = '\rho';
% xlim = [0,1];
% xtick = 0:0.2:1;
% %
% figure(5),clf,set(5,'Name','Deposition profile')
% %
% ylab = 'dP/d\rho/(2\piR_p) (MW/m)';
% tit = '';
% ylim = NaN;
% %
% leg = {'C3PO','LUKE'};
% %
% graph1D_jd(dxrho(ivar_C3PO,:),dwxdPdrho_rf_2piRp_lin(ivar_C3PO,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,style2,marker,color,width,siz,gca,red,lspace,bspace);
% graph1D_jd(dxrho(ivar_C3PO,:),dwxdPdrho_rf_2piRp,0,0,'','','',leg,xlim,ylim,style,marker,color,width2,siz);
% %
% set(gca,'xtick',xtick);
% %
% print_jd(opt.print,['Fig_profile_',id_simul_o],[path_simul,'figures/'],5);
% %
%
end
%
function plot_2D_jd(opt,savepath,savestr,figlabel,x1,y1,ey1,x2,y2,ey2,yleg,ifig,figname,xlab,ylab,displeg,xlim,fylim,xtick,fytick,styles,markers,colors,widths,siz,red,lspace,bspace)
    %
    nexp = size(y1,2);
    %
    if nexp == 0,
        return
    end
    %
    figure(ifig),clf,set(ifig,'Name',figname)
    %
    if isfield(opt,fylim),
        ylim = opt.(fylim);
    else
        ylim = [0,max([max(y1),max(y2)])]*1.2;%,y3
    end
    %
    ncol = length(colors) - 1;
    nmar = length(markers) - 1;
    %
    if nexp > 1,
    else
    end
    %
    if nexp > 1,
        leg = yleg(2);
        tit = [displeg{1},' (',colors{1 + rem(1,ncol)},')'];
        for iexp = 2:nexp,
            tit = [tit,'; ',displeg{iexp},' (',colors{1 + rem(iexp,ncol)},')'];
        end
        %
        if ~all(isnan(y1(:,1))),
            localcol = colors{1 + rem(1,ncol)};
            localwidth = widths(1);
            graph1D_jd(x1,y1(:,1),0,0,'','','',NaN,xlim,ylim,styles{1},markers{1},localcol,localwidth,siz,gca,1,lspace,bspace,ey1(:,1));
            leg = [yleg(1),leg];
        end
        %
        %graph1D_jd(x2,y3(:,1),0,0,'','','',NaN,xlim,ylim,styles{3},markers{1 + rem(1,ncol)},colors{1 + rem(1,ncol)},widths(3),siz,gca,1,lspace,bspace,ey3(:,1));
        graph1D_jd(x2,y2(:,1),0,0,xlab,ylab,tit,leg,xlim,ylim,styles{2},markers{1 + rem(1,ncol)},colors{1 + rem(1,ncol)},widths(2),siz,gca,red,lspace,bspace,ey2(:,1));
        %
        for ivar = 2:size(y2,2),
            %graph1D_jd(x3,y3(:,ivar),0,0,'','','',NaN,xlim,ylim,styles{3},markers{1 + rem(ivar,ncol)},colors{1 + rem(ivar,ncol)},widths(3),siz,gca,1,lspace,bspace,ey3(:,ivar));
            graph1D_jd(x2,y2(:,ivar),0,0,'','','',NaN,xlim,ylim,styles{2},markers{1 + rem(ivar,ncol)},colors{1 + rem(ivar,ncol)},widths(2),siz,gca,1,lspace,bspace,ey2(:,ivar));
            graph1D_jd(x1,y1(:,ivar),0,0,'','','',NaN,xlim,ylim,styles{1},markers{1 + rem(ivar,ncol)},colors{1 + rem(ivar,ncol)},widths(1),siz,gca,1,lspace,bspace,ey1(:,ivar));
        end
        %
    else
        %
        leg = displeg;
        tit = '';
        %
        if ~all(isnan(y1(:,1))),
            localcol = colors{1};
            localwidth = widths(2);
            graph1D_jd(x1,y1(:,1),0,0,'','','',NaN,xlim,ylim,styles{1},markers{1},localcol,localwidth,siz,gca,1,lspace,bspace,ey1(:,1));
            leg = [yleg(1),leg];
        end
        %
        for ivar = 1:size(y2,2)-1,
            graph1D_jd(x2,y2(:,ivar),0,0,'','','',NaN,xlim,ylim,styles{2},markers{1 + rem(ivar,ncol)},colors{1 + rem(ivar,ncol)},widths(2),siz,gca,1,lspace,bspace,ey2(:,ivar));
        end
        %
        graph1D_jd(x2,y2(:,end),0,0,xlab,ylab,tit,leg,xlim,ylim,styles{2},markers{1 + rem(end,ncol)},colors{1 + rem(end,ncol)},widths(2),siz,gca,red,lspace,bspace,ey2(:,end));
        %
        %for ivar = 1:size(y2,2),
            %graph1D_jd(x3,y3(:,ivar),0,0,'','','',NaN,xlim,ylim,styles{3},markers{1 + rem(ivar,ncol)},colors{1 + rem(ivar,ncol)},widths(3),siz,gca,1,lspace,bspace,ey3(:,ivar));
        %end
        %
     end
    %
    %
    set(gca,'xtick',xtick);
    %
    if isfield(opt,fytick),
        set(gca,'ytick',opt.(fytick));
    end
    % 
    print_jd(opt.print,['Fig_',savestr,'_',figlabel],[savepath,'figures/'],ifig);
end
