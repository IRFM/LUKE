% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
clear
p_opt = -1;
c_opt = true;
xi_opt = true;
pmax = 20;

lukedata_1 = load('DKE_RESULTS_Runaway_alpha3_nosync.mat');
lukedata_2 = load('DKE_RESULTS_Runaway_alpha3_sync_0p6.mat');

xlim = [-3,9];
xtick = -3:3:9;
ylim = [0,6];
ytick = [0:2:6];
% 

if c_opt,
    colors = {'r','b','r','b','r'};
    styles = {'-','--','-','--','-.'};
    sizes = [2,2,0.5,0.5,0.5];
    colstr = '_col';
else
    colors = {'k','k','k','k','k'};
    styles = {'-','--','-','--','-.'};
    sizes = [2,2,0.5,0.5,0.5];
    colstr = '';
end

p_1 = lukedata_1.fgrid.pn*sqrt(lukedata_1.betath2);
p_2 = lukedata_2.fgrid.pn*sqrt(lukedata_2.betath2);

if ~isfield(lukedata_1,'pmhucrit') || isempty(lukedata_1.pmhucrit) || all(isnan(lukedata_1.pmhucrit)),
    pmhucrit_1 = NaN(1,length(p_1));
    for ip = 1:length(p_1),
        pmhucrit_1(ip) = min([1,lukedata_1.fgrid.mhu(lukedata_1.tacc{end}(ip,:,:))]);
    end
else
    pmhucrit_1 = lukedata_1.pmhucrit;
end

if ~isfield(lukedata_2,'pmhucrit') || isempty(lukedata_2.pmhucrit) || all(isnan(lukedata_2.pmhucrit)),
    pmhucrit_2 = NaN(1,length(p_2));
    for ip = 1:length(p_2),
        pmhucrit_2(ip) = min([1,lukedata_2.fgrid.mhu(lukedata_2.tacc{end}(ip,:,:))]);
    end
else
    pmhucrit_2 = lukedata_2.pmhucrit;
end

ppar_1 = p_1.*pmhucrit_1;
pperp_1 = p_1.*sqrt(1 - pmhucrit_1.^2);

ppar_2 = p_1.*pmhucrit_2;
pperp_2 = p_1.*sqrt(1 - pmhucrit_2.^2);

pc = 1/sqrt(lukedata_1.alpha - 1);
pperp0 = sqrt((lukedata_2.alpha - 1)/lukedata_2.taurinv);

ppar_xi = p_1/lukedata_1.alpha;
pperp_xi = p_1*sqrt(1 - 1/lukedata_1.alpha^2);

% PLOT

figure(1),clf

xlab = 'p_{||}';
ylab = 'p_{\perp}';
tit = '';
leg = {'without ALD','with ALD'};
siz = 20+14i;

graph1D_jd(ppar_1,pperp_1,0,0,'','','',NaN,xlim,ylim,styles{1},'none',colors{1},sizes(1),siz,gca);
graph1D_jd(ppar_2,pperp_2,0,0,xlab,ylab,tit,leg,xlim,ylim,styles{2},'none',colors{2},sizes(2),siz,gca);
graph1D_jd([pc,pc],ylim,0,0,'','','',NaN,xlim,ylim,styles{3},'none',colors{3},sizes(3),siz,gca);
graph1D_jd(xlim,[pperp0,pperp0],0,0,'','','',NaN,xlim,ylim,styles{4},'none',colors{4},sizes(4),siz,gca);
if xi_opt,
    graph1D_jd(ppar_xi,pperp_xi,0,0,'','','',NaN,xlim,ylim,styles{5},'none',colors{5},sizes(5),siz,gca);
    text(0,ylim(2)/2,'\xi=E_{||}^{-1}','fontsize',20)
    xistr = '_xiopt';
else
    xistr = '';
end
axis('equal');axis([xlim,ylim]);
text(pc,ylim(2)/2,'p_{||}=p_c','fontsize',20)
text(xlim(1)/2,pperp0,'p_{\perp}=p_{\perp0}','fontsize',20)
set(gca,'xtick',xtick)
set(gca,'ytick',ytick)

print_jd(p_opt,['fig_luke_Reregion',xistr,colstr],'figures/',1)
