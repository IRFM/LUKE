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
function fproc_runaway_scan_2D(scanstr1,scanstr2,scanvar,scanval,scanlab,RR,mksa,Ec,f,tn,tRR,tnorm,fgrid,alpha,betath2,wpr,Zi,opt,grid,id_equil,rho_S,graph,iscandisp,xlim,xlog,xtick,p_opt,id_simul_scan,nan_enforce)
%
nscan1 = length(scanval.(scanstr1));
nscan2 = length(scanval.(scanstr2));
%
snorm.re = NaN(nscan1,nscan2);
snorm.ri = NaN(nscan1,nscan2);
snorm.rtot = NaN(nscan1,nscan2);
snorm.b = NaN(nscan1,nscan2);
snorm.tot = NaN(nscan1,nscan2);
%
sRR.re = NaN(nscan1,nscan2);
sRR.ri = NaN(nscan1,nscan2);
sRR.rtot = NaN(nscan1,nscan2);
%
spnmin = NaN(nscan1,nscan2);
spnmax = NaN(nscan1,nscan2);
sEcmin = NaN(nscan1,nscan2);
sEcmax = NaN(nscan1,nscan2);
%
salpha = NaN(nscan1,nscan2);
sbetath2 = NaN(nscan1,nscan2);
%
spnmax_S = NaN(nscan1,nscan2);
spnmax_S_tail = NaN(nscan1,nscan2);
%
sfpar = cell(nscan1,nscan2);
%
for iscan1 = 1:nscan1,
    for iscan2 = 1:nscan2,
        %
        snorm.re(iscan1,iscan2) = tnorm{iscan1,iscan2}.re(end);
        snorm.ri(iscan1,iscan2) = tnorm{iscan1,iscan2}.ri(end);
        snorm.rtot(iscan1,iscan2) = tnorm{iscan1,iscan2}.re(end) + tnorm{iscan1,iscan2}.ri(end);
        snorm.b(iscan1,iscan2) = tnorm{iscan1,iscan2}.b(end);
        snorm.tot(iscan1,iscan2) = tnorm{iscan1,iscan2}.tot(end);
        %
        sRR.re(iscan1,iscan2) = tRR{iscan1,iscan2}.re(end);
        sRR.ri(iscan1,iscan2) = tRR{iscan1,iscan2}.ri(end);
        sRR.rtot(iscan1,iscan2) = tRR{iscan1,iscan2}.re(end) + tRR{iscan1,iscan2}.ri(end);
        %
        if ~isempty(f{iscan1,iscan2}{end}),
            sfpar{iscan1,iscan2} = f{iscan1,iscan2}{end}(:,end).';
            np = length(sfpar{iscan1,iscan2});
            ipparnan = find(sfpar{iscan1,iscan2} < 0,1);
            if ~isempty(ipparnan),
                sfpar{iscan1,iscan2}(ipparnan:end) = NaN;
            end
            ipparmin = find(diff(sfpar{iscan1,iscan2}) > 0,1);
            if ~isempty(ipparmin),
                spnmin(iscan1,iscan2) = fgrid{iscan1,iscan2}.pn(ipparmin);
                sEcmin(iscan1,iscan2) = Ec{iscan1,iscan2}(ipparmin);
                %
                ipparmax = find(diff(sfpar{iscan1,iscan2}) < 0 & 1:np-1 > ipparmin,1);
                if ~isempty(ipparmax),
                    spnmax(iscan1,iscan2) = fgrid{iscan1,iscan2}.pn(ipparmax);
                    sEcmax(iscan1,iscan2) = Ec{iscan1,iscan2}(ipparmax);
                end
            end
        end
        if strcmp(scanstr1,'alpha'),
            salpha(iscan1,iscan2) = scanval.(scanstr1)(iscan1);
        elseif strcmp(scanstr2,'alpha'),
            salpha(iscan1,iscan2) = scanval.(scanstr2)(iscan2);
        else
            salpha(iscan1,iscan2) = alpha;
        end
        if strcmp(scanstr1,'betath2'),
            sbetath2(iscan1,iscan2) = scanval.(scanstr1)(iscan1);
        elseif strcmp(scanstr2,'betath2'),
            sbetath2(iscan1,iscan2) = scanval.(scanstr2)(iscan2);
        else
            sbetath2(iscan1,iscan2) = betath2;
        end
        %
        if strcmp(scanstr1,'grid.pnmax_S'),
            spnmax_S(iscan1,iscan2) = scanval.(scanstr1)(iscan1);
        else
            spnmax_S(iscan1,iscan2) = grid.pnmax_S;
        end
        if strcmp(scanstr1,'grid.pnmax_S_tail'),
            spnmax_S_tail(iscan1,iscan2) = scanval.(scanstr1)(iscan1);
        else
            spnmax_S_tail(iscan1,iscan2) = grid.pnmax_S_tail;
        end
    end
end
%
for ienforce = 1:size(nan_enforce,1),
    spnmin(nan_enforce(ienforce,1),nan_enforce(ienforce,2)) = NaN;
    spnmax(nan_enforce(ienforce,1),nan_enforce(ienforce,2)) = NaN;
end
%
spc = 1./sqrt((salpha - 1).*sbetath2);
sgammac = sqrt(salpha./(salpha - 1));
%
[~,~,~,~,~,~,~,mc2] = pc_dke_yp;%Universal physics constants
sEcc = 1e-3*mc2*(sgammac - 1);
%
if grid.np_tail > 0,
    if imag(grid.pnmax_S_tail) == 0,
        spnmax_S = spnmax_S_tail;
    else
        spnmax_S = spnmax_S.*imag(spnmax_S_tail);
    end
end
%
sgammamax_S = sqrt(1 + spnmax_S.^2.*sbetath2);
sEcmax_S = 1e-3*mc2*(sgammamax_S - 1);
%
siz = 20+14i;
colors = {'b','r','g','m','y','c','k'};
%
x1 = scanval.(scanstr1);
x2 = scanval.(scanstr2);
%
xlim1 = NaN;
xlim2 = NaN;
%
xlog1 = xlog.(scanstr1);
xlog2 = xlog.(scanstr2);
%
xtick1 = xtick.(scanstr1);
xtick2 = xtick.(scanstr2);
%
figure(1),clf
%
xlab1 = scanlab.(scanstr1);
xlab2 = scanlab.(scanstr2);
tit = 'n_r/n_e';
%
y = -log10(snorm.rtot);
cont = -log10(graph.cont_norm);
cont_lab = -log10(graph.cont_norm_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);%colorbar
hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,0,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
figure(2),clf
%
tit = '\Gamma_R\tau_c';
%
y = -log10(sRR.rtot);
cont = -log10(graph.cont_gamma);
cont_lab = -log10(graph.cont_gamma_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);%colorbar
hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,0,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
figure(3),clf
%
tit = 'p_c/p_T';
%
y = spc;
cont = NaN;%-log10(graph.cont_gamma);
% cont_lab = -log10(graph.cont_gamma_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);colorbar
% hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,1,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
%
figure(4),clf
%
tit = 'p_{grid}/p_T';
%
y = spnmax_S;
cont = NaN;%-log10(graph.cont_gamma);
% cont_lab = -log10(graph.cont_gamma_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);colorbar
% hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,1,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
%
figure(5),clf
%
tit = 'p_{min}/p_T';
%
y = spnmin;
cont = NaN;%-log10(graph.cont_gamma);
% cont_lab = -log10(graph.cont_gamma_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);colorbar
% hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,1,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
figure(6),clf
%
tit = 'p_{max}/p_T';
%
y = spnmax;
cont = NaN;%-log10(graph.cont_gamma);
% cont_lab = -log10(graph.cont_gamma_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);colorbar
% hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,1,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
%
figure(7),clf
%
tit = 'E_c (keV)';
%
y = sEcc;
cont = NaN;%-log10(graph.cont_gamma);
% cont_lab = -log10(graph.cont_gamma_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);colorbar
% hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,1,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
%
figure(8),clf
%
tit = 'E_{grid} (keV)';
%
y = sEcmax_S;
cont = NaN;%-log10(graph.cont_gamma);
% cont_lab = -log10(graph.cont_gamma_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);colorbar
% hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,1,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
%
figure(9),clf
%
tit = 'E_{min} (keV)';
%
y = sEcmin;
cont = NaN;%-log10(graph.cont_gamma);
% cont_lab = -log10(graph.cont_gamma_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);colorbar
% hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,1,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
figure(10),clf
%
tit = 'E_{max} (keV)';
%
y = sEcmax;
cont = NaN;%-log10(graph.cont_gamma);
% cont_lab = -log10(graph.cont_gamma_lab);
%
ax = graph2D_jd(x1,x2,y,xlab1,xlab2,tit,xlim1,xlim2,1,NaN,cont,0,'--',NaN,0.5,siz,0.9);colorbar
% hold on,graph2D_jd(x1,x2,y,'','','',xlim1,xlim2,0,NaN,cont_lab,1,'-','k',2,siz,1,NaN,ax);hold off%colorbar
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
figure(11),clf
%
tit = 'threshold';
%
y2min = NaN(1,nscan1);
y2max = NaN(1,nscan1);
%
for iscan1 = 1:nscan1,
    testres = ~isnan(spnmax(iscan1,:));
    if any(testres),
        y2min(iscan1) = x2(find(testres,1,'first'));
        y2max(iscan1) = x2(find(testres,1,'last'));
    end
end
%
leg = {'min','max'};
%
graph1D_jd(x1,y2min,xlog.(scanstr1),xlog.(scanstr2),'','','',NaN,xlim.(scanstr1),xlim.(scanstr2),'-','o','r',2,siz);
graph1D_jd(x1,y2max,xlog.(scanstr1),xlog.(scanstr2),scanlab.(scanstr1),scanlab.(scanstr2),tit,leg,xlim.(scanstr1),xlim.(scanstr2),'-','o','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',xtick1,'ytick',xtick2)
%
figure(12),clf
%
y1min = NaN(1,nscan2);
y1max = NaN(1,nscan2);
%
for iscan2 = 1:nscan2,
    testres = ~isnan(spnmax(:,iscan2));
    if any(testres),
        y1min(iscan2) = x1(find(testres,1,'first'));
        y1max(iscan2) = x1(find(testres,1,'last'));
    end
end
%
graph1D_jd(x2,y1min,xlog.(scanstr2),xlog.(scanstr1),'','','',NaN,xlim.(scanstr2),xlim.(scanstr1),'-','o','r',2,siz);
graph1D_jd(x2,y1max,xlog.(scanstr2),xlog.(scanstr1),scanlab.(scanstr2),scanlab.(scanstr1),tit,leg,xlim.(scanstr2),xlim.(scanstr1),'-','o','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',xtick2,'ytick',xtick1)
%
print_jd(p_opt,['fig_',id_simul_scan,'_nr'],['./figures',filesep,scanstr1,'_',scanstr2],1)
print_jd(p_opt,['fig_',id_simul_scan,'_rr'],['./figures',filesep,scanstr1,'_',scanstr2],2)
print_jd(p_opt,['fig_',id_simul_scan,'_pc'],['./figures',filesep,scanstr1,'_',scanstr2],3)
print_jd(p_opt,['fig_',id_simul_scan,'_pgrid'],['./figures',filesep,scanstr1,'_',scanstr2],4)
print_jd(p_opt,['fig_',id_simul_scan,'_pmin'],['./figures',filesep,scanstr1,'_',scanstr2],5)
print_jd(p_opt,['fig_',id_simul_scan,'_pmax'],['./figures',filesep,scanstr1,'_',scanstr2],6)
print_jd(p_opt,['fig_',id_simul_scan,'_Ec'],['./figures',filesep,scanstr1,'_',scanstr2],7)
print_jd(p_opt,['fig_',id_simul_scan,'_Egrid'],['./figures',filesep,scanstr1,'_',scanstr2],8)
print_jd(p_opt,['fig_',id_simul_scan,'_Emin'],['./figures',filesep,scanstr1,'_',scanstr2],9)
print_jd(p_opt,['fig_',id_simul_scan,'_Emax'],['./figures',filesep,scanstr1,'_',scanstr2],10)
print_jd(p_opt,['fig_',id_simul_scan,'_y2'],['./figures',filesep,scanstr1,'_',scanstr2],11)
print_jd(p_opt,['fig_',id_simul_scan,'_y1'],['./figures',filesep,scanstr1,'_',scanstr2],12)
%
if isfield(iscandisp,scanstr1) && isfield(iscandisp,scanstr2),
    %
    xlab = 'E_c (MeV)';
    ylab = 'f(E_c,\xi = 1)';
    xlim = [0,max(sEcmax_S(:))];    
    if isfield(graph,'ylim_f'),
        ylim = graph.ylim_f;
    else
        ylim = [eps,2];
        graph.ytick_f = 10.^(-18:2:2);
    end    
    %
    nscandisp1 = length(iscandisp.(scanstr1));
    nscandisp2 = length(iscandisp.(scanstr2));
    %
    leg = cell(1,nscandisp2);
    for iiscan2 = 1:nscandisp2,
        iscan2 = iscandisp.(scanstr2)(iiscan2);
        leg{iiscan2} = [scanlab.(scanstr2),' = ',num2str(scanval.(scanstr2)(iscan2))];
    end
    %
    for iiscan1 = 1:nscandisp1,
        %
        figure(20+iiscan1),clf,
        iscan1 = iscandisp.(scanstr1)(iiscan1);
        %
        for iiscan2 = 1:nscandisp2-1,
            iscan2 = iscandisp.(scanstr2)(iiscan2);
            graph1D_jd(Ec{iscan1,iscan2},sfpar{iscan1,iscan2},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iiscan2},2,siz);
        end
        iscan2 = iscandisp.(scanstr2)(nscandisp2);
        graph1D_jd(Ec{iscan1,iscan2},sfpar{iscan1,iscan2},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{nscandisp2},2,siz,gca,0.9,0.7,0.7);
        %
        if isfield(graph,'ytick_f'),
            set(gca,'ytick',graph.ytick_f)
        end
        set(gca,'YMinorGrid','off')
        set(gca,'YMinorTick','on')
        %
        print_jd(p_opt,['fig_',id_simul_scan,'_f_',num2str(iiscan1)],['./figures',filesep,scanstr1,'_',scanstr2],20+iiscan1)
        %
    end
    %
end
%
