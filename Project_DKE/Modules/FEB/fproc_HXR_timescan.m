function fproc_HXR_timescan(basestr,file_str,shotnum,shotimes,id_simul_o,locpath_simul,it_disp,ic,krange,dtexp,HXRopt,cnumber,kdisp,p_opt,opt)
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
% select shot times
%
equilbase = [file_str,basestr,'_',shotnum,'_'];
[shotimes,isel] = select_shotimes_jd(equilbase,[id_simul_o,'.mat'],path_simul,shotimes);
nt = length(shotimes);
%
icdisp = 1 + cnumber - ic(1);
%
nc = length(ic);
%nk = length(ik);
%
dI_tot = NaN(1,nt);
dI_exp = NaN(1,nt);
%dt = NaN(1,nt);
%
%dJ = NaN(nr,nt);
%dxrho = NaN(nr,nt);
%
Tphplasma = NaN(nc,nt);
Tphexp = NaN(nc,nt);
Tphdiag = NaN(nc,nt);
eTphplasma = NaN(nc,nt);
eTphexp = NaN(nc,nt);
eTphdiag = NaN(nc,nt);
Aplasma = NaN(nc,nt);
Aexp = NaN(nc,nt);
Adiag = NaN(nc,nt);
eAplasma = NaN(nc,nt);
eAexp = NaN(nc,nt);
eAdiag = NaN(nc,nt);
Qplasma = NaN(nc,nt);
Qexp = NaN(nc,nt);
Qdiag = NaN(nc,nt);
%
%dNdtplasma = NaN(nk,nc,nt);
%dNdtdiag = NaN(nk,nc,nt);
%
dvarplasma = NaN(1,nt);
dvardiag = NaN(1,nt);
%
icpeak = NaN(1,nt);
%
for it = 1:nt,
    %
    shotime = shotimes{it};
    ttimes(it) = str2num(shotime);
    %
    id_equil = [equilbase,shotime];%For plasma equilibrium
    %
    id_simul = [id_equil,id_simul_o];
    %
    texp = [ttimes(it) - dtexp/2,ttimes(it) + dtexp/2]; 
    %
    [hxr_proc,hxr,data_proc] = fproc_hxr(basestr,path_simul,id_simul,hxr_file,exp_file,texp,ic,krange,opt);
    %
    if isempty(hxr_proc),
        if exist('dNdtplasma','var'),
            dNdtplasma(:,:,it) = NaN;
            dNdtdiag(:,:,it) = NaN;
        end
        %
        continue
    end
    %
    dI_tot(it) = data_proc.scalar.I_tot;
    dI_exp(it) = data_proc.scalar.I_exp;
    %
    dJ(:,it) = data_proc.radial.J_tot.';
    %
    if opt.rho == 'g',
        dxrho(:,it) = data_proc.radial.xrhoG.';
    elseif opt.rho == 'p',
        dxrho(:,it) = data_proc.radial.xrhoP.';
    elseif opt.rho == 't',
        dxrho(:,it) = data_proc.radial.xrhoT.';
    elseif opt.rho == 'v',
        dxrho(:,it) = data_proc.radial.xrhoV.';
    else
        error('rho type not recognized')
    end
    %
    %dxrho(:,it) = data_proc.radial.xrho.';
    %
    Tphplasma(:,it) = hxr_proc.Tphplasma;        
    Tphdiag(:,it) = hxr_proc.Tphdiag;        
    Aplasma(:,it) = hxr_proc.Aplasma;        
    Adiag(:,it) = hxr_proc.Adiag;        
    eAplasma(:,it) = hxr_proc.eAplasma;        
    eAdiag(:,it) = hxr_proc.eAdiag;        
    Qplasma(:,it) = hxr_proc.Qplasma;        
    Qdiag(:,it) = hxr_proc.Qdiag;        
    eTphplasma(:,it) = hxr_proc.eTphplasma;        
    eTphdiag(:,it) = hxr_proc.eTphdiag;        
    %
    dvarplasma(it) = hxr_proc.dvarplasma;        
    dvardiag(it) = hxr_proc.dvardiag;        
    %
    icpeak(it) = hxr_proc.icpeak;
    %
    ik = hxr_proc.ik;
    %
    dNdtplasma(:,:,it) = hxr_proc.dNdtplasma(ik,ic);
    dNdtdiag(:,:,it) = hxr_proc.dNdtdiag(ik,ic);
    %
    %dt(it) = hxr.dt;
    %
    k(:,it) = hxr_proc.k(ik);
    %k2 = hxr_proc.k(ik2);
    %
    Tphexp(:,it) = hxr_proc.Tphexp;
    eTphexp(:,it) = hxr_proc.eTphexp;
    Aexp(:,it) = hxr_proc.Aexp;
    eAexp(:,it) = hxr_proc.eAexp;
    Qexp(:,it) = hxr_proc.Qexp;
    %
    dNdtexp(:,:,it) = hxr_proc.dNdtexp(ik,ic);
    %dNdtexp2(:,:,it) = hxr_proc.dNdtexp(ik2,ic);
    %
end
%
dt = 0.016;%%%%%
%
if ~all(all(k == repmat(k(:,1),[1,nt]))),
    error('verify energy list')
else
    k = k(:,1);
end
%
nk = length(k);
ikdisp = find(k == mean(kdisp));
%
dNdtdiag_disp = reshape(dNdtdiag(:,icdisp,:),[nk,nt]).';
dNdtplasma_disp = reshape(dNdtplasma(:,icdisp,:),[nk,nt]).';
dNdtexp_disp = reshape(dNdtexp(:,icdisp,:),[nk,nt]).';
%
sdNdtdiag = reshape(sum(dNdtdiag,1),[nc,nt]);%count rate
sdNdtplasma = reshape(sum(dNdtplasma,1),[nc,nt]);%count rate
sdNdtexp = reshape(sum(dNdtexp,1),[nc,nt]);%count rate
%
ndNdtdiag = sdNdtdiag./repmat(sdNdtdiag(icdisp,:),[nc,1]);%count rate
ndNdtplasma = sdNdtplasma./repmat(sdNdtplasma(icdisp,:),[nc,1]);%count rate
ndNdtexp = sdNdtexp./repmat(sdNdtexp(icdisp,:),[nc,1]);%count rate
%
endNdtdiag = sqrt(sdNdtdiag/dt)./repmat(sdNdtdiag(icdisp,:),[nc,1]);%count rate
endNdtplasma = sqrt(sdNdtplasma/dt)./repmat(sdNdtplasma(icdisp,:),[nc,1]);%count rate
endNdtexp = sqrt(sdNdtexp/dt)./repmat(sdNdtexp(icdisp,:),[nc,1]);%count rate
%
style0 = 'none';
style = '-';
style2 = '--';
marker = 'none';
marker1 = '+';
marker2 = 'o';
marker3 = 's';
marker4 = '.';
markers = {marker1,marker2,marker3};
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
bspace2 = 0.6;%0.5;
%
xlab_ic = 'chord #';
xlim_ic = [min(ic),max(ic)];
xtick_ic = 0:5:60;
%
ncol = length(colors);
%
chordstr = ['chord # ',num2str(cnumber)];
timestr = '';
for it = 1:length(it_disp),
    timestr = [timestr,'t = ',shotimes{it_disp(it)},' (',colors{rem(it,ncol)},'); '];
end
kstr = ['k = ',num2str(kdisp(1)),'-',num2str(kdisp(2)),' keV'];
%
kmin = min(k);
kmax = max(k);
%
krangestr = ['k = ',num2str(kmin),' - ',num2str(kmax),' keV'];
%
if opt.xdisp == 0,
    x = ttimes;
    xlab = 't (s)';
else
    [nvol,tn]=tsbase(str2double(shotnum),'sprofnmoy');
    if isempty(nvol),
        [nvol,tn]=tsbase(str2double(shotnum),'snmoy');
        nvol = nvol/1e19;
    end
    x = interp1(tn,nvol,ttimes);
    xlab = 'volumic density (\times 10^{19} m^{-3})';
end
%
if isfield(opt,'xlim'),
    xlim = opt.xlim;
else
    xlim = [fix(x(1)),ceil(x(end))];
end
%
if isfield(opt,'xtick'),
    xtick = opt.xtick;
else
    xtick = xlim(1):ceil(diff(xlim)/5):xlim(2);
end
%
if isfield(opt,'icrej_exp') && ~isempty(opt.icrej_exp),
    maskic_exp = ~any(repmat(ic,[length(opt.icrej_exp),1]) == repmat(opt.icrej_exp.',[1,length(ic)]),1);
else
    maskic_exp = 1:nc;
end
%
% --------------------- Current -----------------------
%
ifig = 1;figure(ifig),clf,set(ifig,'Name','Current')
%
ylab = 'Current (kA)';
tit = '';
if isfield(opt,'ylim_I'),
    ylim = opt.ylim_I;
else
    ylim = 1e3*[0,max([dI_tot,dI_exp])]*1.2;
end
%
leg = {'LUKE'};
%
if ~all(isnan(dI_exp)) && (~isfield(opt,'I_exp') || opt.I_exp == 1),
    graph1D_jd(x,dI_exp*1e3,0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz);
    leg = ['Exp.',leg];
end
graph1D_jd(x,dI_tot*1e3,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace);
%
set(gca,'xtick',xtick);
%set(gca,'xminorgrid','off')
%set(gca,'xminortick','off')
%
print_jd(p_opt,['Fig_I_tot',id_simul_o],[savepath,'figures/'],ifig);
%
% --------------------- TPH 2D -----------------------
%
ifig = 2;figure(ifig),clf,set(ifig,'Name','TPH2D')
%
ylab = 'Photon Temperature (keV)';
tit = timestr;
%
ylim = [0,60];%[0,max(max([Tphplasma,Tphdiag,Tphexp]))]*1.2;
%ytick = 0:2:10;
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~all(isnan(Tphexp(:,it_disp(1)))),
    if length(it_disp) > 1,
        localcol = colors{rem(1,ncol)};
        localwidth = width;
    else
        localcol = color1;
        localwidth = width2;
    end
    graph1D_jd(ic(maskic_exp),Tphexp(maskic_exp,it_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,localcol,localwidth,siz,gca,1,lspace,bspace2,eTphexp(maskic_exp,1));
    leg = ['Exp.',leg];
end
%graph1D_jd(ic,Tphplasma(:,1),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(1,ncol)},width2,siz,gca,1,lspace,bspace2,eTphplasma(:,1));
graph1D_jd(ic,Tphdiag(:,it_disp(1)),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,style,marker3,colors{rem(1,ncol)},width2,siz,gca,red,lspace,bspace2,eTphdiag(:,1));
for it = 2:length(it_disp),
    %graph1D_jd(ic,Tphplasma(:,it_disp(it)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(it,ncol)},width2,siz,gca,1,lspace,bspace2,eTphplasma(:,it));
    graph1D_jd(ic,Tphdiag(:,it_disp(it)),0,0,'','','',NaN,xlim_ic,ylim,style,marker3,colors{rem(it,ncol)},width2,siz,gca,1,lspace,bspace2,eTphdiag(:,it));
    if ~all(isnan(Tphexp(:,it_disp(it)))),
        graph1D_jd(ic(maskic_exp),Tphexp(maskic_exp,it_disp(it)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,colors{rem(it,ncol)},width,siz,gca,1,lspace,bspace2,eTphexp(maskic_exp,it));
    end
end
%
set(gca,'xtick',xtick_ic);
%set(gca,'ytick',ytick);
% 
print_jd(p_opt,['Fig_TPH_2D',id_simul_o],[savepath,'figures/'],ifig);
%
% --------------------- TPH 1D -----------------------
%
ifig = 3;figure(ifig),clf,set(ifig,'Name','TPH1D')
%
ylab = 'Photon Temperature (keV)';
tit = chordstr;
%
ylim = [0,max([Tphplasma(icdisp,:),Tphdiag(icdisp,:),Tphexp(icdisp,:)])]*1.2;
%ytick = 0:2:10;
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~all(isnan(Tphexp(icdisp,:))),
    graph1D_jd(x,Tphexp(icdisp,:),0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace2,eTphexp(icdisp,:));
    leg = ['Exp.',leg];
end
%graph1D_jd(x,Tphplasma(icdisp,:),0,0,'','','',NaN,xlim,ylim,style,marker2,color2,width2,siz,gca,1,lspace,bspace2,eTphplasma(icdisp,:));
graph1D_jd(x,Tphdiag(icdisp,:),0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace2,eTphdiag(icdisp,:));
%
set(gca,'xtick',xtick);
%set(gca,'ytick',ytick);
% 
print_jd(p_opt,['Fig_TPH_1D_ic',num2str(cnumber),id_simul_o],[savepath,'figures/'],ifig);
%
% --------------------- COUNT RATE 1D total -----------------------
%
ifig = 4;figure(ifig),clf,set(ifig,'Name','CR 1D Total')
%
ylab = ['Count rate (s^{-1})'];
tit = [chordstr,'; ',krangestr];
%
if isfield(opt,'ylim_CR1D_tot'),
    ylim = opt.ylim_CR1D_tot;
else
    ylim = 10.^[3,5];%[0,max(max([dNdtdiag_disp,dNdtexp_disp]))]*1.2;%dNdtplasma_disp,
end
%ytick = 10.^[3:5];
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~all(isnan(dNdtexp(1,icdisp,:))),
    graph1D_jd(x,sdNdtexp(icdisp,:),0,1,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtdiag_disp(:,1)/dt));
    leg = ['Exp.',leg];
end
%graph1D_jd(x,sdNdtplasma(icdisp,:),0,1,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtplasma_disp(:,1)/dt));
graph1D_jd(x,sdNdtdiag(icdisp,:),0,1,xlab,ylab,tit,leg,xlim,ylim,style,marker3,color2,width2,siz,gca,red,lspace,bspace2,sqrt(dNdtdiag_disp(:,1)/dt));
%
set(gca,'xtick',xtick);
%set(gca,'ytick',ytick);
% 
print_jd(p_opt,['Fig_CR_1D_tot_ic',num2str(cnumber),id_simul_o],[savepath,'figures/'],ifig);
%
% --------------------- COUNT RATE 1D selected -----------------------
%
ifig = 5;figure(ifig),clf,set(ifig,'Name','CR 1D Selected')
%
ylab = ['Count rate (s^{-1})'];
tit = [chordstr,'; ',kstr];
%
if isfield(opt,'ylim_CR1D_sel'),
    ylim = opt.ylim_CR1D_sel;
else
    ylim = 10.^[3,5];%[0,max(max([dNdtdiag_disp,dNdtexp_disp]))]*1.2;%dNdtplasma_disp,
end
%ytick = 10.^[3:5];
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~all(isnan(dNdtexp(1,icdisp,:))),
%     graph1D_jd(x,dNdtexp_disp(:,1),0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtdiag_disp(:,1)/dt));
    graph1D_jd(x,dNdtexp_disp(:,ikdisp),0,1,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtdiag_disp(:,1)/dt));
    leg = ['Exp.',leg];
end
% %graph1D_jd(x,dNdtplasma_disp(:,1),0,0,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtplasma_disp(:,1)/dt));
% graph1D_jd(x,dNdtdiag_disp(:,1),0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker3,color2,width2,siz,gca,red,lspace,bspace2,sqrt(dNdtdiag_disp(:,1)/dt));
%graph1D_jd(x,dNdtplasma_disp(:,ikdisp),0,1,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtplasma_disp(:,1)/dt));
graph1D_jd(x,dNdtdiag_disp(:,ikdisp),0,1,xlab,ylab,tit,leg,xlim,ylim,style,marker3,color2,width2,siz,gca,red,lspace,bspace2,sqrt(dNdtdiag_disp(:,1)/dt));
% for ik = 2:nk,
%     %graph1D_jd(x,dNdtplasma_disp(:,ik),0,0,'','','',NaN,xlim,ylim,style,marker2,color3,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtplasma_disp(:,ik)/dt));
%     graph1D_jd(x,dNdtdiag_disp(:,ik),0,0,'','','',NaN,xlim,ylim,style,marker3,color2,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtdiag_disp(:,ik)/dt));
%     if ~all(isnan(dNdtexp_disp(:,ik))),
%         graph1D_jd(x,dNdtexp_disp(:,ik),0,0,'','','',NaN,xlim,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace2,sqrt(dNdtexp_disp(:,ik)/dt));
%     end
% end
%
set(gca,'xtick',xtick);
%set(gca,'ytick',ytick);
% 
print_jd(p_opt,['Fig_CR_1D_ic',num2str(cnumber),id_simul_o],[savepath,'figures/'],ifig);
%
%
% --------------------- COUNT RATE 2D -----------------------
%
ifig = 6;figure(ifig),clf,set(ifig,'Name','CR 2D')
%
xlab = 'Chord #';
ylab = ['Count rate (s^{-1}); ',krangestr];
tit = timestr;
%
ylim = [0,max(max([sdNdtdiag;sdNdtexp(maskic_exp,:)]))]*1.2;%sdNdtplasma,
%ytick = 0:2:10;
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~all(isnan(sdNdtexp(:,it_disp(1)))),
    if length(it_disp) > 1,
        localcol = colors{rem(1,ncol)};
        localwidth = width;
    else
        localcol = color1;
        localwidth = width2;
    end
    graph1D_jd(ic(maskic_exp),sdNdtexp(maskic_exp,it_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,localcol,localwidth,siz,gca,1,lspace,bspace2,sqrt(sdNdtexp(maskic_exp,1)/dt));
    leg = ['Exp.',leg];
end
%graph1D_jd(ic,sdNdtplasma(:,it_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(1,ncol)},width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtplasma(:,1)/dt));
graph1D_jd(ic,sdNdtdiag(:,it_disp(1)),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,style,marker3,colors{rem(1,ncol)},width2,siz,gca,red,lspace,bspace2,sqrt(sdNdtdiag(:,1)/dt));
for it = 2:length(it_disp),
    %graph1D_jd(ic,sdNdtplasma(:,it_disp(it)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(it,ncol)},width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtplasma(:,it)/dt));
    graph1D_jd(ic,sdNdtdiag(:,it_disp(it)),0,0,'','','',NaN,xlim_ic,ylim,style,marker3,colors{rem(it,ncol)},width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtdiag(:,it)/dt));
    if ~all(isnan(sdNdtexp(:,it_disp(it)))),
        graph1D_jd(ic(maskic_exp),sdNdtexp(maskic_exp,it_disp(it)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,colors{rem(it,ncol)},width2,siz,gca,1,lspace,bspace2,sqrt(sdNdtexp(maskic_exp,it)/dt));
    end
end
%
set(gca,'xtick',xtick_ic);
%set(gca,'ytick',ytick);
% 
print_jd(p_opt,['Fig_CR_2D',id_simul_o],[savepath,'figures/'],ifig);
%
%
ifig = 7;figure(ifig),clf,set(ifig,'Name','CR 2D norm')
%
xlab = 'Chord #';
ylab = ['Normalized Count rate; ',krangestr];
tit = timestr;
%
ylim = [0,1.4];%sdNdtplasma,
ytick = 0:0.2:1.4;
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~all(isnan(sdNdtexp(:,it_disp(1)))),
    if length(it_disp) > 1,
        localcol = colors{rem(1,ncol)};
        localwidth = width;
    else
        localcol = color1;
        localwidth = width2;
    end
    graph1D_jd(ic(maskic_exp),ndNdtexp(maskic_exp,it_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,localcol,localwidth,siz,gca,1,lspace,bspace2,endNdtexp(maskic_exp,1));
    leg = ['Exp.',leg];
end
%graph1D_jd(ic,ndNdtplasma(:,it_disp(1)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(1,ncol)},width2,siz,gca,1,lspace,bspace2,endNdtplasma(:,1);
graph1D_jd(ic,ndNdtdiag(:,it_disp(1)),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,style,marker3,colors{rem(1,ncol)},width2,siz,gca,red,lspace,bspace2,endNdtdiag(:,1));
for it = 2:length(it_disp),
    %graph1D_jd(ic,ndNdtplasma(:,it_disp(it)),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,colors{rem(it,ncol)},width2,siz,gca,1,lspace,bspace2,endNdtplasma(:,it));
    graph1D_jd(ic,ndNdtdiag(:,it_disp(it)),0,0,'','','',NaN,xlim_ic,ylim,style,marker3,colors{rem(it,ncol)},width2,siz,gca,1,lspace,bspace2,endNdtdiag(:,it));
    if ~all(isnan(sdNdtexp(:,it_disp(it)))),
        graph1D_jd(ic(maskic_exp),ndNdtexp(maskic_exp,it_disp(it)),0,0,'','','',NaN,xlim_ic,ylim,style,marker,colors{rem(it,ncol)},width2,siz,gca,1,lspace,bspace2,endNdtexp(maskic_exp,it));
    end
end
%
set(gca,'xtick',xtick_ic);
set(gca,'ytick',ytick);
% 
print_jd(p_opt,['Fig_CR_2D_norm',id_simul_o],[savepath,'figures/'],ifig);
%
%
return
%
ifig = 7;figure(ifig),clf,set(ifig,'Name','Current profiles')
%
xlab = '\rho';
ylab = 'J - J_{\Omega} (MA/m^2)';
tit = '';
%
xlim = [0,1];
ylim = NaN;
xtick = 0:0.2:1;
%ytick = 0:0.2:1.4;
%
leg = {};%{'LUKE'};%{'plasma','diag.'};%
%
for ivar = 1:length(var_disp),
    ivardisp = find(abs(var_list - var_disp(ivar)) < 10*eps);   
    %
    if isempty(ivardisp),
        continue
    end
    %
    graph1D_jd(dxrho(:,ivardisp),dJ(:,ivardisp).' - J_ohm,0,0,'','','',NaN,xlim,ylim,...
        style,markers{ivar},colors{ivar},width2,siz);
    %
    leg = [leg,['D_0 = ',num2str(var_disp(ivar)),' m^2/s']];
    %
end
%
Jfac = max(dJ(:,3).' - J_ohm);
leg = [leg,'Exp.'];
graph1D_jd(xrho_exp,J_exp*Jfac,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color1,width2,siz,gca,red,lspace,bspace);
%
set(gca,'xtick',xtick);
%set(gca,'ytick',ytick);
% 
print_jd(p_opt,['Fig_Jcomp_',id_simul_0],[path_simul,'figures/'],ifig);
%
%
%
figure(7),clf,set(7,'Name','Selected Count rate')
%
xlim = [min(ic)-1,max(ic)+1];
ylab = ['Count rate (s^{-1}) [',num2str(kmin),' - ',num2str(kmax),' keV]'];
ylim = NaN;%[0,2500];
%ytick = 0:500:2500;
%
leg = {};
%
for ivar = 1:length(var_disp),
    ivardisp = find(abs(var_list - var_disp(ivar)) < 10*eps);   
    %
    if isempty(ivardisp),
        continue
    end
    %
    sdNdtdiag_disp = sdNdtdiag(:,ivardisp);%count rate
    %
    graph1D_jd(ic,sdNdtdiag_disp,0,0,'','','',NaN,xlim,ylim,...
        style,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,sqrt(sdNdtdiag_disp/dt));
    %
    leg = [leg,['D_0 = ',num2str(var_disp(ivar)),' m^2/s']];
    %
end
%
set(gca,'xtick',xtick_ic);
%set(gca,'ytick',ytick);
%
%
leg = [leg,'Exp.'];
%
graph1D_jd(ic,sdNdtexp,0,0,xlab,ylab,tit,leg,xlim,ylim,...
    style,marker,color1,width2,siz,gca,red,lspace,bspace,sqrt(sdNdtexp/dt));
%
% for ivar = 1:length(var_disp),
%     ivardisp = find(abs(var_list - var_disp(ivar)) < 10*eps); 
%     %
%     if isempty(ivardisp),
%         continue
%     end
%     %
%     sdNdtplasma_disp = sdNdtplasma(:,ivardisp);%number of counts
%     %
%     graph1D_jd(ic,sdNdtplasma_disp,0,0,'','','',NaN,xlim,ylim,...
%         style2,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,sqrt(sdNdtplasma_disp/dt));
%     %
% end
% 
print_jd(p_opt,['Fig_select_countrate_',num2str(vmindisp),'_',id_simul_0],[path_simul,'figures/'],7);
%
%
%
figure(8),clf,set(8,'Name','Selected Norm Count rate')
%
xlim = [min(ic)-1,max(ic)+1];
ylab = ['Normalized Count rate [',num2str(kmin),' - ',num2str(kmax),' keV]'];
ylim = [0,1.4];%sdNdtplasma,
ytick = 0:0.2:1.4;
%
leg = {};
%
for ivar = 1:length(var_disp),
    ivardisp = find(abs(var_list - var_disp(ivar)) < 10*eps);   
    %
    if isempty(ivardisp),
        continue
    end
    %
    ndNdtdiag_disp = ndNdtdiag(:,ivardisp);%count rate
    endNdtdiag_disp = endNdtdiag(:,ivardisp);%count rate
    %
    graph1D_jd(ic,ndNdtdiag_disp,0,0,'','','',NaN,xlim,ylim,...
        style,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,endNdtdiag_disp);
    %
    leg = [leg,['D_0 = ',num2str(var_disp(ivar)),' m^2/s']];
    %
end
%
set(gca,'xtick',xtick_ic);
set(gca,'ytick',ytick);
%
%
leg = [leg,'Exp.'];
%
graph1D_jd(ic,ndNdtexp,0,0,xlab,ylab,tit,leg,xlim,ylim,...
    style,marker,color1,width2,siz,gca,red,lspace,bspace,endNdtexp);
%
% for ivar = 1:length(var_disp),
%     ivardisp = find(abs(var_list - var_disp(ivar)) < 10*eps); 
%     %
%     if isempty(ivardisp),
%         continue
%     end
%     %
%     ndNdtplasma_disp = ndNdtplasma(:,ivardisp);%number of counts
%     endNdtplasma_disp = endNdtplasma(:,ivardisp);%number of counts
%     %
%     graph1D_jd(ic,ndNdtplasma_disp,0,0,'','','',NaN,xlim,ylim,...
%         style2,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,endNdtplasma_disp);
%     %
% end
% 
print_jd(p_opt,['Fig_select_norm_countrate_',num2str(vmindisp),'_',id_simul_0],[path_simul,'figures/'],8);
%
%
figure(9),clf,set(9,'Name','TPH_chord')
%
kmin = min(k);
%
xlab = 'Chord #';
ylab = ['Photon temperature (keV)'];
tit = '';
%
xlim = [min(ic)-1,max(ic)+1];
ylim = NaN;%[0,2500];
%ytick = 0:500:2500;
%
leg = {};
%
% for ivar = 1:length(var_disp),
%     ivardisp = find(abs(var_list - var_disp(ivar)) < 10*eps);    
%     %
%     if isempty(ivardisp),
%         continue
%     end
%     %
%     maskQdiag = (1 - Qdiag(:,ivardisp,ivdisp) < 1e-2) & (Tphdiag(:,ivardisp,ivdisp) > eTphdiag(:,ivardisp,ivdisp));
%     %
%     graph1D_jd(ic(maskQdiag),Tphdiag(maskQdiag,ivardisp,ivdisp),0,0,'','','',NaN,xlim,ylim,...
%         style,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,eTphdiag(maskQdiag,ivardisp,ivdisp));
%     %
%     leg = [leg,['D_0 = ',num2str(var_disp(ivar)),' m^2/s']];
%     %
% end
%
set(gca,'xtick',xtick_ic);
%set(gca,'ytick',ytick);
%
leg = [leg,'Exp.'];
%
maskexp = (1 - Qexp < 1e-2) & (Tphexp > eTphexp);
%
graph1D_jd(ic(maskexp),Tphexp(maskexp),0,0,xlab,ylab,tit,leg,xlim,ylim,...
    style,marker,color1,width2,siz,gca,red,lspace,bspace,eTphexp(maskexp));
%
% for ivar = 1:length(var_disp),
%     ivardisp = find(abs(var_list - var_disp(ivar)) < 10*eps);   
%     %
%     if isempty(ivardisp),
%         continue
%     end
%     %
%     maskQplasma = (1 - Qplasma(:,ivardisp,ivdisp) < 1e-2) & (Tphplasma(:,ivardisp,ivdisp) > eTphplasma(:,ivardisp,ivdisp));
%     %
%     graph1D_jd(ic(maskQplasma),Tphplasma(maskQplasma,ivardisp,ivdisp),0,0,'','','',NaN,xlim,ylim,...
%         style,markers{ivar},colors{ivar},width2,siz,gca,1,lspace,bspace,eTphplasma(maskQplasma,ivardisp,ivdisp));
%     %
%     leg = [leg,['D_0 = ',num2str(var_disp(ivar)),' m^2/s']];
%     %
% end
% 
print_jd(p_opt,['Fig_1D_tph_chord_',num2str(vmindisp),'_',id_simul_0],[path_simul,'figures/'],9);
%
%
figure(10),clf,set(10,'Name','Exp prof')
%
ylim = [0,1.2];
ytick = 0:0.2:1.2;
%
Nnorm = dNdtexp.'./repmat(max(dNdtexp.'),[nc,1]);
eNnorm = sqrt(dNdtexp.'/dt)./repmat(max(dNdtexp.'),[nc,1]);
%
leg = {};
for iik = 1:length(k),
    leg{iik} = ['k = ',num2str(k(iik)),' keV'];
end
%
graph1D_jd(repmat(ic.',[1,length(k)]),Nnorm,0,0,xlab,ylab,tit,leg,xlim,ylim,...
    style,marker,color,width2,siz,gca,red,lspace,bspace,eNnorm);
% 
set(gca,'xtick',xtick_ic);
set(gca,'ytick',ytick);
%
print_jd(p_opt,['Fig_countrate_exp_',num2str(vmindisp),'_',id_simul_0],[path_simul,'figures/'],10);
%


% %
% figure(3),clf,set(3,'Name','Deposition peak')
% %
% ylab = '\rho_{peak}';
% tit = '';
% ylim = [0,1];
% %
% leg = {'LUKE','C3PO'};
% %
% if firstref,
%     graph1D_jd(xlim,[drho(1),drho(1)],xlog,0,'','','',NaN,xlim,ylim,style,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var_list(1))],leg];
% end
% %
% if lastref,
%     graph1D_jd(xlim,[drho(end),drho(end)],xlog,0,'','','',NaN,xlim,ylim,style2,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var_list(end))],leg];
% end
% %
% graph1D_jd(var_list(mask),drho(mask),xlog,0,'','','',NaN,xlim,ylim,style,marker2,color2,width2,siz);
% graph1D_jd(var_list(mask),drho_lin(mask),xlog,0,xlab,ylab,tit,leg,xlim,ylim,style,marker1,color3,width2,siz,gca,red,lspace,bspace);
% %
% set(gca,'xtick',xtick);
% set(gca,'xminorgrid','off')
% set(gca,'xminortick','off')
% %
% print_jd(p_opt,['Fig_rho_peak_',id_simul_0],[path_simul,'figures/'],3);
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
% if firstref,
%     graph1D_jd(xlim,[dnfrags(1),dnfrags(1)],xlog,0,'','','',NaN,xlim,ylim,style,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var_list(1))],leg];
% end
% %
% if lastref,
%     graph1D_jd(xlim,[dnfrags(end),dnfrags(end)],xlog,0,'','','',NaN,xlim,ylim,style2,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var_list(end))],leg];
% end
% %
% graph1D_jd(var_list(mask),dnfrags(mask),xlog,0,xlab,ylab,tit,leg,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace);
% %
% set(gca,'xtick',xtick);
% set(gca,'xminorgrid','off')
% set(gca,'xminortick','off')
% %
% print_jd(p_opt,['Fig_nfrags_',id_simul_0],[path_simul,'figures/'],4);
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
% print_jd(p_opt,['Fig_profile_',id_simul_0],[path_simul,'figures/'],5);
% %
