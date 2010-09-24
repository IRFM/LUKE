function proc_a_sdNpar_scan(filename,savepath,opt,locproc_list)
%
if nargin < 3,
    opt.save = 1;
    opt.nr_dep = 0;
    opt.peak = 'n';
    opt.wave = 'n';
    opt.rho = 't';%%%% g?   
    opt.print = -1;
end
%
if nargin < 2,
    savepath = '';
end
%
load(filename);
%
if nargin < 4,
    locproc_list = 1:na_sdNpar;
end
%
nproc = length(locproc_list);
%
basestr = id_simul0(1:find(id_simul0 == '_',1,'first')-1);
%
if length(dkeparam.rho_S) == 1,
    nrho = dkeparam.rho_S + isfield(dkeparam,'rho0');
else
    nrho = length(dkeparam.rho_S) - 1;
end
%
zI = NaN(1,nproc);
zP = NaN(1,nproc);
zxrho = NaN(nproc,nrho);
zxJ = NaN(nproc,nrho);
zxP = NaN(nproc,nrho);
%
for iproc = 1:nproc,
    %
    id_simul = [id_simul0,'_',locid_simul];
    %
    for iw = 1:length(waves),
        id_simul = [id_simul,'_',ids_wave{iw},'_a_sdNpar_',num2str(a_sdNpar_list(locproc_list(iproc)))];
    end
    %
    data_proc = fproc_data(savepath,id_simul,opt);
    %
    if ~isempty(data_proc),
        %
        zI(iproc) = data_proc.scalar.I_tot;
        zP(iproc) = data_proc.scalar.p_rf_2piRp*2*pi*equil.Rp;
        zxJ(iproc,:) = data_proc.radial.J_tot;
        zxP(iproc,:) = data_proc.radial.P_rf;
        zxrho(iproc,:) = data_proc.radial.xrho;
%         if opt.rho == 'g',
%             zxrho(iproc,:) = data_proc.radial.xrhoG;
%         elseif opt.rho == 'p',
%             zxrho(iproc,:) = data_proc.radial.xrhoP;
%         elseif opt.rho == 't',
%             zxrho(iproc,:) = data_proc.radial.xrhoT;
%         elseif opt.rho == 'v',
%             zxrho(iproc,:) = data_proc.radial.xrhoV;
%         else
%             error('rho type not recognozed')
%         end
        %
    end
    %
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
color = NaN;
color1 = 'k';
color2 = 'r';
color3 = 'b';
color4 = 'g';
color5 = 'm';
color6 = 'c';
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
xmask = find(~isnan(zI));
%
x = a_sdNpar_list;
xlim = [min(a_sdNpar_list),max(a_sdNpar_list)];
xtick = a_sdNpar_list;
xlab = 'a_{sdN_{||}}';
%
figure(1),clf,set(1,'Name','Current')
%
ylab = 'I (kA)';
ylim = NaN;
tit = '';
%
%leg = {'LUKE','I_p - I_{boot}'};%
%
graph1D_jd(x(xmask),zI(xmask)*1e3,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker2,color2,width2,siz,gca,red,lspace,bspace);
%graph1D_jd(x(xmask),Iexp*1e3*ones(1,length(xmask)),0,0,'','','',NaN,xlim,ylim,style,marker1,color3,width,siz);
%
%set(gca,'ytick',ytick);
set(gca,'xtick',xtick);
%
print_jd(opt.print,'Fig_D0_scan_I');
%
figure(2),clf,set(2,'Name','Current profiles')
%
xlab = 'r/a';
xlim = [0:1];
xtick = 0:0.2:1;
%
ylab = 'J (MA/m^2)';
ylim = NaN;
tit = '';
%
graph1D_jd(zxrho(xmask,:).',zxJ(xmask,:).',0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
%
%set(gca,'ytick',ytick);
set(gca,'xtick',xtick);
%
print_jd(opt.print,'Fig_D0_scan_J');
%
figure(3),clf,set(3,'Name','PRF profiles')
%
xlab = 'r/a';
xlim = [0:1];
xtick = 0:0.2:1;
%
ylab = 'P_{rf} (MW/m^3)';
ylim = NaN;
tit = '';
%
graph1D_jd(zxrho(xmask,:).',zxP(xmask,:).',0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
%
%set(gca,'ytick',ytick);
set(gca,'xtick',xtick);
%
print_jd(opt.print,'Fig_D0_scan_J');
%
% figure(2),clf,set(2,'Name','Current profile')
% %
% tit = 'J (kA/m^2)';
% cont = 20;
% fill = 1;
% %
% graph2D_jd(rho,x(xmask),dfrac(:,mask).',xlab,ylab,tit,xlim,ylim,fill,NaN,cont,0,style,color,width2,siz,red);
% hold on
% graph2D_jd(beta_diff_list(mask),alpha_diff_list,dfrac(:,mask).','','','',xlim,ylim,0,NaN,[-Inf,dfrac_exp],0,style,color1,width2,siz);
% hold off
% %
% colorbar
% %
% set(gca,'ytick',ytick);
% set(gca,'xtick',xtick);
% %
% print_jd(p_opt,['Fig_2D_abs_',shotid,printid]);
%

















