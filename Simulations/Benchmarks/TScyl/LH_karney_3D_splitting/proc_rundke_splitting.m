% script proc_rundke_splitting
%
clear all
%
Dr0 = 1;
%
load(['DKE_RESULTS_TScyl_LH_karney_3D_splitting_',num2str(Dr0),'.mat'])
%
opt_print = -1;
%
% total current calculation
%
jfac = -1e3*repmat(equilDKE.xdA_dke.'*mksa.j_ref,[1,nit_max + 1,ndtn,nopt,ncoll]);
%
I_0 = squeeze(sum(curr0_0.*jfac./normf0_0,1));
I_Dr0 = squeeze(sum(curr0_Dr0.*jfac./normf0_Dr0,1));
%
ifig = 0;
%
%color = {'b','g','r','m'};
%style = {'-','-','-','-'};
%marker = {'none','none','none','none'};
%lsize = [2,2,2,2];
%
%red = 0.85;
%bspace = 0.55;
%
color = {'k','k','k','k'};
style = {'-','--','-.','none'};
marker = {'none','none','none','o'};
lsize = [0.5,2,2,2];
%
red = 0.9;
bspace = 0.7;
%
for icoll = 1:ncoll,
	for iopt = 1:nopt,
        %
        ifig = ifig + 1;
        %
        str = ['D_r = 0 m^2/s; coll. mode = ',num2str(coll_mode_list(icoll)),'; op. split = ',num2str(optsplit_list(iopt))];
        %
        figure(ifig),clf
        set(gcf,'name',str)
        %
        xlim = [0,tfinal];
        ylim = [1e-1,1e2];
        xlab = 't/\tau_c';
        ylab = 'I(t) (kA)';
        tit = '';%str;
        %
        for idtn = 1:ndtn - 1, 
            graph1D_jd(0:dtn_list(idtn):tfinal,I_0(1:(nit_f(idtn)+1),idtn,iopt,icoll),1,1,'','','',NaN,xlim,ylim,style{idtn},marker{idtn},color{idtn},lsize(idtn),20,gca);
            %
            leg{idtn} = ['\Deltat/\tau_c = ',num2str(dtn_list(idtn))];
        end
        leg{length(dtn_list)} = ['\Deltat/\tau_c = ',num2str(dtn_list(end))];
        %
        graph1D_jd(0:dtn_list(end):tfinal,I_0(1:(nit_f(end)+1),end,iopt,icoll),1,1,xlab,ylab,tit,leg,xlim,ylim,style{ndtn},marker{ndtn},color{ndtn},lsize(ndtn),20,gca,red,0.7,bspace);
        %
        set(gca,'ytick',10.^[-1:2])
        set(gca,'xtick',10.^[0:5])
        set(gca,'xminorgrid','off')
        set(gca,'yminorgrid','off')
        %
        ch = get(gcf,'children');
        set(ch(1),'Location','SouthEast','Fontsize',20)
        %
        %
        ifig = ifig + 1;
        %
        str = ['D_r = ',num2str(Dr0),' m^2/s; coll. mode = ',num2str(coll_mode_list(icoll)),'; op. split = ',num2str(optsplit_list(iopt))];
        figure(ifig),clf
        set(gcf,'name',str)
        %
        tit = '';%str;
        %
        for idtn = 1:ndtn - 1, 
            graph1D_jd(0:dtn_list(idtn):tfinal,I_Dr0(1:(nit_f(idtn)+1),idtn,iopt,icoll),1,1,'','','',NaN,xlim,ylim,style{idtn},marker{idtn},color{idtn},lsize(idtn),20,gca);
            %
            leg{idtn} = ['\Deltat/\tau_c = ',num2str(dtn_list(idtn))];
        end
        leg{length(dtn_list)} = ['\Deltat/\tau_c = ',num2str(dtn_list(end))];
        %
        graph1D_jd(0:dtn_list(end):tfinal,I_Dr0(1:(nit_f(end)+1),end,iopt,icoll),1,1,xlab,ylab,tit,leg,xlim,ylim,style{ndtn},marker{ndtn},color{ndtn},lsize(ndtn),20,gca,red,0.7,bspace);
        %
        set(gca,'ytick',10.^[-1:2])
        set(gca,'xtick',10.^[0:5])
        set(gca,'xminorgrid','off')
        set(gca,'yminorgrid','off')
        %
        ch = get(gcf,'children');
        set(ch(1),'Location','SouthEast','Fontsize',20)
        %
    end
end
%
print_jd(opt_print,'Fig_splitting_0_0_0',NaN,1)
print_jd(opt_print,['Fig_splitting_',num2str(Dr0),'_0_0'],NaN,2)
print_jd(opt_print,'Fig_splitting_0_0_1',NaN,3)
print_jd(opt_print,['Fig_splitting_',num2str(Dr0),'_0_1'],NaN,4)
print_jd(opt_print,'Fig_splitting_0_1_0',NaN,5)
print_jd(opt_print,['Fig_splitting_',num2str(Dr0),'_1_0'],NaN,6)
print_jd(opt_print,'Fig_splitting_0_1_1',NaN,7)
print_jd(opt_print,['Fig_splitting_',num2str(Dr0),'_1_1'],NaN,8)
%
% coll_mode = 0
%
% figure(1),semilogy([1:1100]*1,squeeze(normf0_0(1,1,10,1:1100,1)),'r'),hold on
% figure(1),semilogy([1:200]*10,squeeze(normf0_0(1,1,10,1:200,2)),'r-.')
% figure(1),semilogy([1:110]*100,squeeze(normf0_0(1,1,10,1:110,3)),'r:')
% figure(1),semilogy([1:100]*1000,squeeze(normf0_0(1,1,10,1:100,4)),'r*')
% %
% figure(2),semilogy([1:1100]*1,squeeze(normf0_0(2,1,10,1:1100,1)),'r'),hold on
% figure(2),semilogy([1:200]*10,squeeze(normf0_0(2,1,10,1:200,2)),'r-.')
% figure(2),semilogy([1:110]*100,squeeze(normf0_0(2,1,10,1:110,3)),'r:')
% figure(2),semilogy([1:100]*1000,squeeze(normf0_0(2,1,10,2:100,4)),'r*')
% %
% figure(3),semilogy([1:1100]*1,squeeze(curr0_0(1,1,10,1:1100,1)),'b'),hold on
% figure(3),semilogy([1:200]*10,squeeze(curr0_0(1,1,10,1:200,2)),'b-.')
% figure(3),semilogy([1:110]*100,squeeze(curr0_0(1,1,10,1:110,3)),'b:')
% figure(3),semilogy([1:100]*1000,squeeze(curr0_0(1,1,10,2:100,4)),'b*')
% %
% figure(4),semilogy([1:1100]*1,squeeze(curr0_0(2,1,10,1:1100,1)),'b'),hold on
% figure(4),semilogy([1:200]*10,squeeze(curr0_0(2,1,10,1:200,2)),'b-.')
% figure(4),semilogy([1:110]*100,squeeze(curr0_0(2,1,10,1:110,3)),'b:')
% figure(4),semilogy([1:100]*1000,squeeze(curr0_0(2,1,10,2:100,4)),'b*')
% %
% figure(5),semilogy([1:1100]*1,squeeze(normf0_10(1,1,10,1:1100,1)),'r'),hold on
% figure(5),semilogy([1:200]*10,squeeze(normf0_10(1,1,10,1:200,2)),'r-.')
% figure(5),semilogy([1:110]*100,squeeze(normf0_10(1,1,10,1:110,3)),'r:')
% figure(5),semilogy([1:100]*1000,squeeze(normf0_10(1,1,10,2:100,4)),'r*')
% %
% figure(6),semilogy([1:1100]*1,squeeze(normf0_10(2,1,10,1:1100,1)),'r'),hold on
% figure(6),semilogy([1:200]*10,squeeze(normf0_10(2,1,10,1:200,2)),'r-.')
% figure(6),semilogy([1:110]*100,squeeze(normf0_10(2,1,10,1:110,3)),'r:')
% figure(6),semilogy([1:100]*1000,squeeze(normf0_10(2,1,10,2:100,4)),'r*')
% %
% figure(7),semilogy([1:1100]*1,squeeze(curr0_10(1,1,10,1:1100,1)),'b'),hold on
% figure(7),semilogy([1:200]*10,squeeze(curr0_10(1,1,10,1:200,2)),'b-.')
% figure(7),semilogy([1:110]*100,squeeze(curr0_10(1,1,10,1:110,3)),'b:')
% figure(7),semilogy([1:100]*1000,squeeze(curr0_10(1,1,10,2:100,4)),'b*')
% %
% figure(8),semilogy([1:1100]*1,squeeze(curr0_10(2,1,10,1:1100,1)),'b'),hold on
% figure(8),semilogy([1:200]*10,squeeze(curr0_10(2,1,10,1:200,2)),'b-.')
% figure(8),semilogy([1:110]*100,squeeze(curr0_10(2,1,10,1:110,3)),'b:')
% figure(8),semilogy([1:100]*1000,squeeze(curr0_10(2,1,10,2:100,4)),'b*')
% %
% % coll_mode = 2
% %
% figure(9),semilogy([1:1100]*1,squeeze(normf0_0(1,3,10,1:1100,1)),'r'),hold on
% figure(9),semilogy([1:200]*10,squeeze(normf0_0(1,3,10,1:200,2)),'r-.')
% figure(9),semilogy([1:110]*100,squeeze(normf0_0(1,3,10,1:110,3)),'r:')
% figure(9),semilogy([1:100]*1000,squeeze(normf0_0(1,3,10,1:100,4)),'r*')
% %
% figure(10),semilogy([1:1100]*1,squeeze(normf0_0(2,3,10,1:1100,1)),'r'),hold on
% figure(10),semilogy([1:200]*10,squeeze(normf0_0(2,3,10,1:200,2)),'r-.')
% figure(10),semilogy([1:110]*100,squeeze(normf0_0(2,3,10,1:110,3)),'r:')
% figure(10),semilogy([1:100]*1000,squeeze(normf0_0(2,3,10,2:100,4)),'r*')
% %
% figure(11),semilogy([1:1100]*1,squeeze(curr0_0(1,3,10,1:1100,1)),'b'),hold on
% figure(11),semilogy([1:200]*10,squeeze(curr0_0(1,3,10,1:200,2)),'b-.')
% figure(11),semilogy([1:110]*100,squeeze(curr0_0(1,3,10,1:110,3)),'b:')
% figure(11),semilogy([1:100]*1000,squeeze(curr0_0(1,3,10,2:100,4)),'b*')
% %
% figure(12),semilogy([1:1100]*1,squeeze(curr0_0(2,3,10,1:1100,1)),'b'),hold on
% figure(12),semilogy([1:200]*10,squeeze(curr0_0(2,3,10,1:200,2)),'b-.')
% figure(12),semilogy([1:110]*100,squeeze(curr0_0(2,3,10,1:110,3)),'b:')
% figure(12),semilogy([1:100]*1000,squeeze(curr0_0(2,3,10,2:100,4)),'b*')
% %
% figure(13),semilogy([1:1100]*1,squeeze(normf0_10(1,3,10,1:1100,1)),'r'),hold on
% figure(13),semilogy([1:200]*10,squeeze(normf0_10(1,3,10,1:200,2)),'r-.')
% figure(13),semilogy([1:110]*100,squeeze(normf0_10(1,3,10,1:110,3)),'r:')
% figure(13),semilogy([1:100]*1000,squeeze(normf0_10(1,3,10,2:100,4)),'r*')
% %
% figure(14),semilogy([1:1100]*1,squeeze(normf0_10(2,3,10,1:1100,1)),'r'),hold on
% figure(14),semilogy([1:200]*10,squeeze(normf0_10(2,3,10,1:200,2)),'r-.')
% figure(14),semilogy([1:110]*100,squeeze(normf0_10(2,3,10,1:110,3)),'r:')
% figure(14),semilogy([1:100]*1000,squeeze(normf0_10(2,3,10,2:100,4)),'r*')
% %
% figure(15),semilogy([1:1100]*1,squeeze(curr0_10(1,3,10,1:1100,1)),'b'),hold on
% figure(15),semilogy([1:200]*10,squeeze(curr0_10(1,3,10,1:200,2)),'b-.')
% figure(15),semilogy([1:110]*100,squeeze(curr0_10(1,3,10,1:110,3)),'b:')
% figure(15),semilogy([1:100]*1000,squeeze(curr0_10(1,3,10,2:100,4)),'b*')
% %
% figure(16),semilogy([1:1100]*1,squeeze(curr0_10(2,3,10,1:1100,1)),'b'),hold on
% figure(16),semilogy([1:200]*10,squeeze(curr0_10(2,3,10,1:200,2)),'b-.')
% figure(16),semilogy([1:110]*100,squeeze(curr0_10(2,3,10,1:110,3)),'b:')
% figure(16),semilogy([1:100]*1000,squeeze(curr0_10(2,3,10,2:100,4)),'b*')
% %


