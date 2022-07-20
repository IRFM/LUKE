%
clear all
close all
clc
%
Z = 18;% Atomic number
Z0 = 0;% Ionization state
%
print_opt = 2;%-1: no print, 2:save files (eps,png,fig)
%
p = linspace(0.1,100,1000);
%
[g_dft,gn_dft] = gfp_yp(p,Z,'DFT');
[g_salvat1,gn_salvat1] = gfp_yp(p,Z,'salvat1');
    [g_salvat2,gn_salvat2] = gfp_yp(p,Z,'salvat2');
[g_salvat3,gn_salvat3] = gfp_yp(p,Z,'salvat3');
[g_tpb,gn_tpb] = gfp_yp(p,Z,'Tseng-Pratt-Botto');
[g_tfk,gn_tfk] = gfp_yp(p,Z,'Thomas-Fermi-Kirillov');
%
linestyle(1) = {'-'};
linestyle(2) = {'--'};
linestyle(3) = {'-.'};
linestyle(4) = {':'};
linestyle(5) = {'-'};
linestyle(6) = {'--'};
%
linecolor(1) = {'r'};
linecolor(2) = {'b'};
linecolor(3) = {'g'};
linecolor(4) = {'m'};
linecolor(5) = {'c'};
linecolor(6) = {'k'};
%
marker(1) = {'o'};
marker(2) = {'x'};
marker(3) = {'+'};
marker(4) = {'*'};
marker(5) = {'s'};
marker(6) = {'d'};
%
siz = 20+14i;
%
leg = {'DHFS (Gaussian code)',...
    'Salvat et al. (1 exp)',...
    'Salvat et al. (<=2 exp)',...
    'Salvat et al. (<=3 exp)'};
%
tit = ['Normalized g_{FP} function, ',elements('atomic_number', Z, 'name'),', Z_s = ',int2str(Z),', Z_{s0} = ',int2str(Z0)];
xlab = 'p (mec)';
ylab = 'g_{FP}(p)/(Z_s^2 - Z_{s0}^2)';
%
figure('Name',tit);
%
iZ0 = Z0 + 1;
%
graph1D_jd(p,gn_dft(:,iZ0),0,0,xlab,ylab,tit,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(p,gn_salvat1(:,iZ0),0,0,xlab,ylab,tit,'','','',linestyle{2},'none',linecolor{2},2,siz,gca);hold on
graph1D_jd(p,gn_salvat2(:,iZ0),0,0,xlab,ylab,tit,'','','',linestyle{3},'none',linecolor{6},2,siz,gca);hold on
graph1D_jd(p([1:10:50,50:50:end]),gn_salvat3([1:10:50,50:50:end],iZ0),0,0,xlab,ylab,tit,leg,'','','none','o',linecolor{3},2,siz,gca);hold on
%
drawnow
%
print_jd(print_opt,['gfp_DHFS_salvat_models_',int2str(Z),'_',int2str(Z0)],'./Figs',get(gcf,'Number'))
%
leg = {'DHFS (Gaussian code)',...
    'Salvat et al. (<=3 exp)',...
    'Tseng-Pratt-Botto',...
    'Thomas-Fermi-Kirillov'};
%
tit = ['Normalized g_{FP} function, ',elements('atomic_number', Z, 'name'),', Z_s = ',int2str(Z),', Z_{s0} = ',int2str(Z0)];
xlab = 'p (mec)';
ylab = 'g_{FP}(p)/(Z_s^2 - Z_{s0}^2)';
%
figure('Name',tit);
%
iZ0 = Z0 + 1;
%
graph1D_jd(p,gn_dft(:,iZ0),0,0,xlab,ylab,tit,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(p([1:10:50,50:50:end]),gn_salvat3([1:10:50,50:50:end],iZ0),0,0,xlab,ylab,tit,'','','','none','o',linecolor{3},2,siz,gca);hold on
graph1D_jd(p,gn_tpb(:,iZ0),0,0,xlab,ylab,tit,'','','',linestyle{3},'none',linecolor{2},2,siz,gca);hold on
graph1D_jd(p,gn_tfk(:,iZ0),0,0,xlab,ylab,tit,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca);hold on
%
drawnow
%
print_jd(print_opt,['gfp_all_models_',int2str(Z),'_',int2str(Z0)],'./Figs',get(gcf,'Number'))