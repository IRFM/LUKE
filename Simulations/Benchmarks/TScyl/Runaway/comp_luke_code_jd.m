clear
p_opt = -1;
c_opt = true;

lukedata = load('DKE_RESULTS_Runaway_alpha3_sync_0p6.mat');
lukedata_4 = load('DKE_RESULTS_Runaway_alpha3_sync_0p6_Zi4.mat');
codedata = load('Z1.mat');
codedata_4 = load('Z4.mat');

% xlog = 0;
% xlim = [0,max(Ec)];
% xtick = 0:20:200;
ylim = 10.^[-20,0];%max([lukedata.f{1}(:);lukedata_4.f{1}(:)])
ytick = 10.^(-20:4:0);

xlog = 1;
xlim = 10.^[-3,2]; 
xtick = 10.^(-3:2);

% LUKE normalization
n_luke = sum(lukedata.f{end}(:,end).'.*lukedata.fgrid.pn.^2.*lukedata.fgrid.dpn);
n_luke_4 = sum(lukedata_4.f{end}(:,end).'.*lukedata_4.fgrid.pn.^2.*lukedata_4.fgrid.dpn);

% pn grid for CODE

pn_code = codedata.gridY*sqrt(2);                           
pn_S_code = (pn_code(1:end-1) + pn_code(2:end))/2;
dpn_code = diff([0,pn_S_code,pn_code(end)]);

pn_code_4 = codedata_4.gridY*sqrt(2);                           
pn_S_code_4 = (pn_code_4(1:end-1) + pn_code_4(2:end))/2;
dpn_code_4 = diff([0,pn_S_code_4,pn_code_4(end)]);

% CODE normalization
n_code = sum(codedata.parallelDist.'.*pn_code.^2.*dpn_code);
n_code_4 = sum(codedata_4.parallelDist.'.*pn_code_4.^2.*dpn_code_4);

if c_opt,
    colors = {'r','b','r','b'};
    styles = {'-','--','-','--'};
    sizes = [2,2,0.5,0.5];
    colstr = '_col';
else
    colors = {'k','k','k','k'};
    styles = {'-','--','-','--'};
    sizes = [2,2,0.5,0.5];
    colstr = '';
end

% PLOT
figure(10),clf

xlab = '$\mathcal{E}_k$ (MeV)';
ylab = '$f(\mathcal{E}_k,\xi = 1)$';
tit = '';
leg = {'LUKE, Z_{eff} = 1','CODE, Z_{eff} = 1','LUKE, Z_{eff} = 4','CODE, Z_{eff} = 4'};%{'LUKE','CODE'};
siz = 20+14i;

graph1D_jd(lukedata.Ec,lukedata.f{end}(:,end),xlog,1,'','','',NaN,xlim,ylim,styles{1},'none',colors{1},sizes(1),siz,gca);
graph1D_jd(codedata.gridMeV,codedata.parallelDist*n_luke/n_code,xlog,1,'','','',NaN,xlim,ylim,styles{2},'none',colors{2},sizes(2),siz,gca);
graph1D_jd(lukedata_4.Ec,lukedata_4.f{end}(:,end),xlog,1,'','','',NaN,xlim,ylim,styles{3},'none',colors{3},sizes(3),siz,gca);
graph1D_jd(codedata_4.gridMeV,codedata_4.parallelDist*n_luke_4/n_code_4,xlog,1,xlab,ylab,tit,leg,xlim,ylim,styles{4},'none',colors{4},sizes(4),siz,gca,0.9,0.7,0.7);

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

print_jd(p_opt,['fig_luke_code',colstr],'figures/',10)
