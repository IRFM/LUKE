function fproc_HXR_varscan(basestr,file_str,shotnum,shotime,id_simul_0,locid_simul,locpath_simul,...
    var,ic,krange,dtexp,HXRopt,cnumber,kdisp,opt)
%
savepath = [basestr,filesep,shotnum,filesep];
path_simul = [savepath,locpath_simul];
equilbase = [file_str,basestr,'_',shotnum,'_',shotime];
ttime = str2num(shotime);
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
nvar = length(var.list);
J_ohm = 0;
J_exp = NaN;
xrho_exp = NaN;
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
iexp = 0;
%
texp = [ttime - dtexp/2,ttime + dtexp/2]; 
%
for ivar = 1:nvar,
    %
    id_simul = [equilbase,'_',id_simul_0,'_',var.str,'_',num2str(var.list(ivar)),locid_simul];%Simulation ID
    %
    [hxr_proc,hxr,data_proc] = fproc_hxr(basestr,path_simul,id_simul,hxr_file,exp_file,texp,ic,krange,opt);
    %
    if isempty(hxr_proc),
        if exist('dNdtplasma','var'),
            dNdtplasma(:,:,ivar) = NaN;
            dNdtdiag(:,:,ivar) = NaN;
        end
        %
        continue
    end
    %
    dI_tot(ivar) = data_proc.scalar.I_tot;
    %
    dJ(:,ivar) = data_proc.radial.J_tot.';
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
    Tphplasma(:,ivar) = hxr_proc.Tphplasma;        
    Tphdiag(:,ivar) = hxr_proc.Tphdiag;        
    Aplasma(:,ivar) = hxr_proc.Aplasma;        
    Adiag(:,ivar) = hxr_proc.Adiag;        
    eAplasma(:,ivar) = hxr_proc.eAplasma;        
    eAdiag(:,ivar) = hxr_proc.eAdiag;        
    Qplasma(:,ivar) = hxr_proc.Qplasma;        
    Qdiag(:,ivar) = hxr_proc.Qdiag;        
    eTphplasma(:,ivar) = hxr_proc.eTphplasma;        
    eTphdiag(:,ivar) = hxr_proc.eTphdiag;        
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
    %
    if iexp == 0,
        %
        I_exp = data_proc.scalar.I_exp;
        %
        %dt = hxr.dt;
        %
        k = hxr_proc.k(ik);
        %k2 = hxr_proc.k(ik2);
        %
        Tphexp = hxr_proc.Tphexp;
        eTphexp = hxr_proc.eTphexp;
        Aexp = hxr_proc.Aexp;
        eAexp = hxr_proc.eAexp;
        Qexp = hxr_proc.Qexp;
        %
        dNdtexp = hxr_proc.dNdtexp(ik,ic);
        %dNdtexp2 = hxr_proc.dNdtexp(ik2,ic);
        iexp = 1;
        %
    end
    %
end
%
dt = 0.016;%%%%%
%
nk = length(k);
ikdisp = find(k == mean(kdisp));
%
sdNdtdiag = reshape(sum(dNdtdiag,1),[nc,nvar]);%count rate
sdNdtplasma = reshape(sum(dNdtplasma,1),[nc,nvar]);%count rate
sdNdtexp = reshape(sum(dNdtexp,1),[nc,1]);%count rate
%
ndNdtdiag = sdNdtdiag./repmat(sdNdtdiag(icdisp,:),[nc,1]);%count rate
ndNdtplasma = sdNdtplasma./repmat(sdNdtplasma(icdisp,:),[nc,1]);%count rate
ndNdtexp = sdNdtexp/sdNdtexp(icdisp);%count rate
%
endNdtdiag = sqrt(sdNdtdiag/dt)./repmat(sdNdtdiag(icdisp,:),[nc,1]);%count rate
endNdtplasma = sqrt(sdNdtplasma/dt)./repmat(sdNdtplasma(icdisp,:),[nc,1]);%count rate
endNdtexp = sqrt(sdNdtexp/dt)/sdNdtexp(icdisp);%count rate
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
colors = {color2,color3,color4};
%
width = 0.5;
width2 = 2;
siz = 20+14*1i;
%
red = 0.9;
lspace = 0.7;
lspace2 = 0.5;
bspace = 0.7;
bspace2 = 0.5;
%
xlab = var.lab;
xlim = [min(var.list),max(var.list)];
xtick = var.list;
xlog = var.log;
%
xlab_ic = 'chord #';
xlim_ic = [min(ic),max(ic)];
xtick_ic = 0:5:60;
%
ncol = length(colors);
%
chordstr = ['chord # ',num2str(cnumber)];
%
% --------------------- Current -----------------------
%
ifig = 1;figure(ifig),clf,set(ifig,'Name','Current')
%
ylab = 'Current (kA)';
tit = '';
ylim = [0,max([dI_tot,I_exp])]*1.5;
%
leg = {'LUKE'};
%
if var.firstref,
    graph1D_jd(xlim,[dI_tot(1),dI_tot(1)]*1e3,xlog,0,'','','',NaN,xlim,ylim*1e3,style,marker,color3,width,siz);
    leg = [[var_lab,' = ',num2str(var.list(1))],leg];
end
%
if var.lastref,
    graph1D_jd(xlim,[dI_tot(end),dI_tot(end)]*1e3,xlog,0,'','','',NaN,xlim,ylim*1e3,style2,marker,color3,width,siz);
    leg = [[var_lab,' = ',num2str(var.list(end))],leg];
end
%
if ~isnan(I_exp),
    graph1D_jd(xlim,[I_exp,I_exp]*1e3,xlog,0,'','','',NaN,xlim,ylim*1e3,style,marker,color1,width,siz);
    leg = ['Exp.',leg];
end
graph1D_jd(var.list,dI_tot*1e3,xlog,0,xlab,ylab,tit,leg,xlim,ylim*1e3,style,marker2,color2,width2,siz,gca,red,lspace,bspace);
%
set(gca,'xtick',xtick);
%set(gca,'xminorgrid','off')
%set(gca,'xminortick','off')
%
print_jd(opt.print,['Fig_I_tot_',id_simul_0],[path_simul,'figures/'],ifig);
%
% --------------------- TPH 2D -----------------------
%
ifig = 2;figure(ifig),clf,set(ifig,'Name','TPH2D')
%
ylab = 'Photon Temperature (keV)';
tit = '';
%
ylim = [0,max(max([Tphplasma,Tphdiag,Tphexp.']))]*1.2;
%ytick = 0:2:10;
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~isnan(I_exp),
    graph1D_jd(ic,Tphexp,0,0,'','','',NaN,xlim_ic,ylim,style,marker,color1,width,siz,gca,1,lspace,bspace,eTphexp);
    leg = ['Exp.',leg];
end
%graph1D_jd(ic,Tphplasma(:,1),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,color2,width2,siz,gca,1,lspace,bspace,eTphplasma(:,1));
graph1D_jd(ic,Tphdiag(:,1),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,style,marker3,color3,width2,siz,gca,red,lspace,bspace,eTphdiag(:,1));
for ivar = 2:nvar,
    %graph1D_jd(ic,Tphplasma(:,ivar),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,color2,width2,siz,gca,1,lspace,bspace,eTphplasma(:,ivar));
    graph1D_jd(ic,Tphdiag(:,ivar),0,0,'','','',NaN,xlim_ic,ylim,style,marker3,color3,width2,siz,gca,1,lspace,bspace,eTphdiag(:,ivar));
end
%
set(gca,'xtick',xtick_ic);
%set(gca,'ytick',ytick);
% 
print_jd(opt.print,['Fig_TPH_2D_',id_simul_0],[path_simul,'figures/'],ifig);
%
% --------------------- TPH 1D -----------------------
%
ifig = 3;figure(ifig),clf,set(ifig,'Name','TPH1D')
%
ylab = '';%'Photon Temperature (keV)';
tit = '';
fac = 1e3;
%
%ylim = [0,max([Tphplasma(icdisp,:),Tphdiag(icdisp,:),Tphexp(icdisp)])]*1.2;
ylim = [0,max([Tphplasma(icdisp,:),Tphdiag(icdisp,:),Tphexp(icdisp),sdNdtexp(icdisp)/fac,Tphdiag(icdisp,:),Tphplasma(icdisp,:)])]*1.2;
%ytick = 0:2:10;
%
leg = {'T_{ph} LUKE','CR LUKE (ms^{-1})'};%{'plasma','diag.'};%
%
if ~isnan(I_exp),
    graph1D_jd(var.list,ones(1,nvar)*Tphexp(icdisp),xlog,0,'','','',NaN,xlim,ylim,style,marker,color2,width,siz,gca,1,lspace,bspace,ones(1,nvar)*eTphexp(icdisp));
    graph1D_jd(var.list,ones(1,nvar)*sdNdtexp(icdisp)/fac,xlog,0,'','','',NaN,xlim,ylim,style,marker,color3,width,siz,gca,1,lspace,bspace,ones(1,nvar)*sqrt(sdNdtexp(icdisp)/dt)/fac);
    leg = ['T_{ph} Exp.','CR Exp. (ms^{-1})',leg];
end
%graph1D_jd(var.list,Tphplasma(icdisp,:),xlog,0,'','','',NaN,xlim,ylim,style,marker2,color2,width2,siz,gca,1,lspace,bspace,eTphplasma(icdisp,:));
graph1D_jd(var.list,Tphdiag(icdisp,:),xlog,0,xlab,ylab,tit,NaN,xlim,ylim,style2,marker2,color2,width2,siz,gca,red,lspace,bspace,eTphdiag(icdisp,:));
graph1D_jd(var.list,sdNdtdiag(icdisp,:)/fac,xlog,0,'','','',leg,xlim,ylim,style2,marker2,color3,width2,siz,gca,1,lspace,bspace,sqrt(sdNdtdiag(icdisp,:)/dt)/fac);
%
set(gca,'xtick',xtick);
%set(gca,'ytick',ytick);
% 
print_jd(opt.print,['Fig_TPH_1D_ic_',num2str(icdisp),'_',id_simul_0],[path_simul,'figures/'],ifig);
%
% ifig = 3;figure(ifig),clf,set(ifig,'Name','TPH1D')
% %
% ylab = 'Photon Temperature (keV)';
% tit = '';
% %
% ylim = [0,max([Tphplasma(icdisp,:),Tphdiag(icdisp,:),Tphexp(icdisp)])]*1.2;
% %ytick = 0:2:10;
% %
% leg = {'LUKE'};%{'plasma','diag.'};%
% %
% if var.firstref,
%     graph1D_jd(xlim,[Tph(icdisp,1),Tph(icdisp,1)],xlog,0,'','','',NaN,xlim,ylim,style,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var.list(1))],leg];
% end
% %
% if var.lastref,
%     graph1D_jd(xlim,[Tph(icdisp,end),Tph(icdisp,end)],xlog,0,'','','',NaN,xlim,ylim,style2,marker,color3,width,siz);
%     leg = [[var_lab,' = ',num2str(var.list(end))],leg];
% end
% %
% if ~isnan(I_exp),
%     graph1D_jd(xlim,[Tphexp(icdisp),Tphexp(icdisp)],xlog,0,'','','',NaN,xlim,ylim,style,marker,color1,width,siz,gca,1,lspace,bspace,[eTphexp(icdisp),eTphexp(ic ==icdisp)]);
%     leg = ['Exp.',leg];
% end
% %graph1D_jd(var.list,Tphplasma(icdisp,:),xlog,0,'','','',NaN,xlim,ylim,style,marker2,color2,width2,siz,gca,1,lspace,bspace,eTphplasma(icdisp,:));
% graph1D_jd(var.list,Tphdiag(icdisp,:),xlog,0,xlab,ylab,tit,leg,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace,eTphdiag(icdisp,:));
% %
% set(gca,'xtick',xtick);
% %set(gca,'ytick',ytick);
% % 
% print_jd(opt.print,['Fig_TPH_1D_ic_',num2str(icdisp),'_',id_simul_0],[path_simul,'figures/'],ifig);
%
%keyboard
%
%
% --------------------- COUNT RATE 2D -----------------------
%
kmin = min(k);
kmax = max(k);
%
ifig = 4;figure(ifig),clf,set(ifig,'Name','CR 2D')
%
xlab = 'Chord #';
ylab = ['Count rate (s^{-1}) [',num2str(kmin),' - ',num2str(kmax),' keV]'];
tit = '';
%
% sdNdtdiag = reshape(sum(dNdtdiag,1),[nc,nvar]);%count rate
% sdNdtplasma = reshape(sum(dNdtplasma,1),[nc,nvar]);%count rate
% sdNdtexp = reshape(sum(dNdtexp,1),[nc,1]);%count rate
%
ylim = [0,max(max([sdNdtdiag,sdNdtexp]))]*1.2;%sdNdtplasma,
%ytick = 0:2:10;
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~isnan(I_exp),
    graph1D_jd(ic,sdNdtexp,0,0,'','','',NaN,xlim_ic,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace,sqrt(sdNdtexp/dt));
    leg = ['Exp.',leg];
end
%graph1D_jd(ic,sdNdtplasma(:,1),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,color3,width2,siz,gca,1,lspace,bspace,sqrt(sdNdtplasma(:,1)/dt));
graph1D_jd(ic,sdNdtdiag(:,1),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,style,marker3,color2,width2,siz,gca,red,lspace,bspace,sqrt(sdNdtdiag(:,1)/dt));
for ivar = 2:nvar,
    %graph1D_jd(ic,sdNdtplasma(:,ivar),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,color3,width2,siz,gca,1,lspace,bspace,sqrt(sdNdtplasma(:,ivar)/dt));
    graph1D_jd(ic,sdNdtdiag(:,ivar),0,0,'','','',NaN,xlim_ic,ylim,style,marker3,color2,width2,siz,gca,1,lspace,bspace,sqrt(sdNdtdiag(:,ivar)/dt));
end
%
set(gca,'xtick',xtick_ic);
%set(gca,'ytick',ytick);
% 
print_jd(opt.print,['Fig_CR_2D_',id_simul_0],[path_simul,'figures/'],ifig);
%
%
ifig = 5;figure(ifig),clf,set(ifig,'Name','CR 2D norm')
%
xlab = 'Chord #';
ylab = ['Normalized Count rate [',num2str(kmin),' - ',num2str(kmax),' keV]'];
tit = '';
% %
% ndNdtdiag = sdNdtdiag./repmat(sdNdtdiag(icdisp,:),[nc,1]);%count rate
% ndNdtplasma = sdNdtplasma./repmat(sdNdtplasma(icdisp,:),[nc,1]);%count rate
% ndNdtexp = sdNdtexp/sdNdtexp(icdisp);%count rate
% %
% endNdtdiag = sqrt(sdNdtdiag/dt)./repmat(sdNdtdiag(icdisp,:),[nc,1]);%count rate
% endNdtplasma = sqrt(sdNdtplasma/dt)./repmat(sdNdtplasma(icdisp,:),[nc,1]);%count rate
% endNdtexp = sqrt(sdNdtexp/dt)/sdNdtexp(icdisp);%count rate
%
ylim = [0,1.4];%sdNdtplasma,
ytick = 0:0.2:1.4;
%
leg = {'LUKE'};%{'plasma','diag.'};%
%
if ~isnan(I_exp),
    graph1D_jd(ic,ndNdtexp,0,0,'','','',NaN,xlim_ic,ylim,style,marker,color1,width2,siz,gca,1,lspace,bspace,endNdtexp);
    leg = ['Exp.',leg];
end
%graph1D_jd(ic,ndNdtplasma(:,1),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,color3,width2,siz,gca,1,lspace,bspace,endNdtplasma(:,1);
graph1D_jd(ic,ndNdtdiag(:,1),0,0,xlab_ic,ylab,tit,leg,xlim_ic,ylim,style,marker3,color2,width2,siz,gca,red,lspace,bspace,endNdtdiag(:,1));
for ivar = 2:nvar,
    %graph1D_jd(ic,ndNdtplasma(:,ivar),0,0,'','','',NaN,xlim_ic,ylim,style,marker2,color3,width2,siz,gca,1,lspace,bspace,endNdtplasma(:,ivar));
    graph1D_jd(ic,ndNdtdiag(:,ivar),0,0,'','','',NaN,xlim_ic,ylim,style,marker3,color2,width2,siz,gca,1,lspace,bspace,endNdtdiag(:,ivar));
end
%
set(gca,'xtick',xtick_ic);
set(gca,'ytick',ytick);
% 
print_jd(opt.print,['Fig_CR_2D_norm_',id_simul_0],[path_simul,'figures/'],ifig);
%
%
%
ifig = 6;figure(ifig),clf,set(ifig,'Name','Current profiles')
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
for ivar = 1:length(var.disp),
    ivardisp = find(abs(var.list - var.disp(ivar)) < 10*eps);   
    %
    if isempty(ivardisp),
        continue
    end
    %
    graph1D_jd(dxrho(:,ivardisp),dJ(:,ivardisp).' - J_ohm,0,0,'','','',NaN,xlim,ylim,...
        style,markers{ivar},colors{ivar},width2,siz);
    %
    leg = [leg,[var.lab,' = ',num2str(var.disp(ivar)),' ',var.unit]];
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
print_jd(opt.print,['Fig_Jcomp_',id_simul_0],[path_simul,'figures/'],ifig);
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
for ivar = 1:length(var.disp),
    ivardisp = find(abs(var.list - var.disp(ivar)) < 10*eps);   
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
    leg = [leg,[var.lab,' = ',num2str(var.disp(ivar)),' ',var.unit]];
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
%     ivardisp = find(abs(var.list - var_disp(ivar)) < 10*eps); 
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
%print_jd(opt.print,['Fig_select_countrate_',num2str(vmindisp),'_',id_simul_0],[path_simul,'figures/'],7);
print_jd(opt.print,['Fig_select_countrate_',id_simul_0],[path_simul,'figures/'],7);
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
for ivar = 1:length(var.disp),
    ivardisp = find(abs(var.list - var.disp(ivar)) < 10*eps);   
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
    leg = [leg,[var.lab,' = ',num2str(var.disp(ivar)),' ',var.unit]];
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
%     ivardisp = find(abs(var.list - var_disp(ivar)) < 10*eps); 
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
%print_jd(opt.print,['Fig_select_norm_countrate_',num2str(vmindisp),'_',id_simul_0],[path_simul,'figures/'],8);
print_jd(opt.print,['Fig_select_norm_countrate_',id_simul_0],[path_simul,'figures/'],8);
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
%     ivardisp = find(abs(var.list - var_disp(ivar)) < 10*eps);    
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
%     leg = [leg,[var_lab,' = ',num2str(var_disp(ivar)),' ',var_unit]];
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
%     ivardisp = find(abs(var.list - var_disp(ivar)) < 10*eps);   
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
%     leg = [leg,[var_lab,' = ',num2str(var_disp(ivar)),' ',var_unit]];
%     %
% end
% 
%print_jd(opt.print,['Fig_1D_tph_chord_',num2str(vmindisp),'_',id_simul_0],[path_simul,'figures/'],9);
print_jd(opt.print,['Fig_1D_tph_chord_',id_simul_0],[path_simul,'figures/'],9);
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
%print_jd(opt.print,['Fig_countrate_exp_',num2str(vmindisp),'_',id_simul_0],[path_simul,'figures/'],10);
print_jd(opt.print,['Fig_countrate_exp_',id_simul_0],[path_simul,'figures/'],10);
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
% print_jd(opt.print,['Fig_rho_peak_',id_simul_0],[path_simul,'figures/'],3);
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
% print_jd(opt.print,['Fig_nfrags_',id_simul_0],[path_simul,'figures/'],4);
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
% print_jd(opt.print,['Fig_profile_',id_simul_0],[path_simul,'figures/'],5);
% %
