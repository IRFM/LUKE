%
clear all
close all
clc
%
Z = 74;% Atomic number
Z0 = 42;% Ionization state
%
print_opt = -1;%-1: no print, 2:save files (eps,png,fig)
%
p = linspace(0.1,100,1000);mode=0;fig_comment = '';
%p = linspace(0.001,1,1000);mode=1;fig_comment = '_small_p';
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
leg = {'DFT ({\itGAUSSIAN} code)',...
    'Multi-Yukawa/DFT (1 exp.)',...
    'Multi-Yukawa/DFT (2 exp.)',...
    'Multi-Yukawa/DFT (3 exp.)'};
%
tit = [elements('atomic_number', Z, 'name'),', Z_s = ',int2str(Z),', Z_{s0} = ',int2str(Z0)];
xlab = 'Normalized momentum $\bar{p}$';
ylab = '$g_{FP}(\bar{p})/(Z_s^2 - Z_{0,s}^2)$';
%
figure('Name',tit);
%
iZ0 = Z0 + 1;
%
graph1D_jd(p([1:10:50,50:50:end]),gn_dft([1:10:50,50:50:end],iZ0),0,0,xlab,ylab,tit,'','','','none','o',linecolor{1},2,siz,gca);hold on
graph1D_jd(p,gn_salvat1(:,iZ0),0,0,xlab,ylab,tit,'','','',linestyle{2},'none',linecolor{2},2,siz,gca);hold on
graph1D_jd(p,gn_salvat2(:,iZ0),0,0,xlab,ylab,tit,'','','',linestyle{3},'none',linecolor{3},2,siz,gca);hold on
graph1D_jd(p,gn_salvat3(:,iZ0),0,0,xlab,ylab,tit,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca);hold on
%
xlabel(xlab , 'Interpreter', 'latex')
ylabel(ylab , 'Interpreter', 'latex')
if mode == 1
    ylim([0,max(gn_salvat3(:,iZ0))]);
end
%
grid minor
drawnow
%
print_jd(print_opt,['gfp_DHFS_salvat_models_',int2str(Z),'_',int2str(Z0),fig_comment],'./Figs',get(gcf,'Number'))
%
leg = {'DFT ({\itGAUSSIAN} code)',...
    'Multi-Yukawa/DFT (≤ 3 exp.)',...
    'Yukawa-Tseng-Pratt-Botto/DHFS (1 exp.)',...
    'Thomas-Fermi-Kirillov'};
%
tit = [elements('atomic_number', Z, 'name'),', Z_s = ',int2str(Z),', Z_{s0} = ',int2str(Z0)];
xlab = 'Normalized momentum $\bar{p}$';
ylab = '$g_{FP}(\bar{p})/(Z_s^2 - Z_{0,s}^2)$';
%
figure('Name',tit);
%
iZ0 = Z0 + 1;
%
graph1D_jd(p([1:10:50,50:50:end]),gn_dft([1:10:50,50:50:end],iZ0),0,0,xlab,ylab,tit,'','','','none','o',linecolor{1},2,siz,gca);hold on
graph1D_jd(p,gn_salvat3(:,iZ0),0,0,xlab,ylab,tit,'','','',linestyle{4},'none',linecolor{4},2,siz,gca);hold on
graph1D_jd(p,gn_tpb(:,iZ0),0,0,xlab,ylab,tit,'','','',linestyle{2},'none',linecolor{2},2,siz,gca);hold on
graph1D_jd(p,gn_tfk(:,iZ0),0,0,xlab,ylab,tit,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca);hold on
%
xlabel(xlab , 'Interpreter', 'latex')
ylabel(ylab , 'Interpreter', 'latex')
if mode == 1
    ylim([0,max(gn_salvat3(:,iZ0))]);
end
%
grid minor
drawnow
%
print_jd(print_opt,['gfp_all_models_',int2str(Z),'_',int2str(Z0),fig_comment],'./Figs',get(gcf,'Number'))
%