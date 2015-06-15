clear
p_opt = -1;
c_opt = true;

lukedata = load('DKE_RESULTS_Runaway_alpha3_sync_0p6.mat');
lukedata_2 = load('DKE_RESULTS_Runaway_alpha3_sync_0p6_coll2.mat');

% xlog = 0;
% xlim = [0,max(Ec)];
% xtick = 0:20:200;
ylim = 10.^[-20,0];%max([lukedata.f{1}(:);lukedata_2.f{1}(:)]);
ytick = 10.^(-20:4:0);

xlog = 1;
xlim = 10.^[-3,2]; 
xtick = 10.^(-3:2);


if c_opt,
    color1 = 'b';
    color2 = 'r';
    style1 = '-';
    style2 = '--';
    size1 = 2;
    size2 = 2;
    colstr = '_col';
else
    color1 = 'k';
    color2 = 'k';
    style1 = '-';
    style2 = '--';
    size1 = 0.5;
    size2 = 2;
    colstr = '';
end

% PLOT
figure(11),clf

xlab = '$\mathcal{E}_k$ (MeV)';
ylab = '$f(\mathcal{E}_k,\xi = 1)$';
tit = '';
leg = {'with I_{FP}','without I_{FP}'};
siz = 20+14i;

graph1D_jd(lukedata_2.Ec,lukedata_2.f{end}(:,end),xlog,1,'','','',NaN,xlim,ylim,style1,'none',color1,size1,siz,gca);
graph1D_jd(lukedata.Ec,lukedata.f{end}(:,end),xlog,1,xlab,ylab,tit,leg,xlim,ylim,style2,'none',color2,size2,siz,gca,0.9,0.7,0.7);

set(gca,'xtick',xtick)
set(gca,'ytick',ytick)

set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
if xlog,
    set(gca,'XMinorGrid','off')
    set(gca,'XMinorTick','on')
end
set(get(gca,'xlabel'),'interpreter','latex')
set(get(gca,'ylabel'),'interpreter','latex')

print_jd(p_opt,['fig_luke_coll2',colstr],'figures/',11)
