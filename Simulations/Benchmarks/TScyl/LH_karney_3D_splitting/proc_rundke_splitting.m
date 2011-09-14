% script proc_rundke_splitting
%
clear all
return
%
Dr0 = 0;
%
load(['DKE_RESULTS_TScyl_LH_karney_3D_splitting_',num2str(Dr0),'.mat'])
%
% total current calculation
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
xlim = [0,tfinal];
ylim = [1e-1,1e2];
xlab = 't/\tau_c';
ylab = 'I(t) (kA)';
tit = '';%str;
%
for icoll = 1:ncoll,
	for iopt = 1:nopt,
        %
        ifig = ifig + 1;
        %
        str = ['D_r = ',num2str(Dr0),' m^2/s; coll. mode = ',num2str(coll_mode_list(icoll)),'; op. split = ',num2str(optsplit_list(iopt))];
        figure(ifig),clf
        set(gcf,'name',str)
        %
        for idtn = 1:ndtn - 1, 
            graph1D_jd(dtn_list(idtn):dtn_list(idtn):tfinal,I{idtn,iopt,icoll},1,1,'','','',NaN,xlim,ylim,style{idtn},marker{idtn},color{idtn},lsize(idtn),20,gca);
            %
            leg{idtn} = ['\Deltat/\tau_c = ',num2str(dtn_list(idtn))];
        end
        leg{length(dtn_list)} = ['\Deltat/\tau_c = ',num2str(dtn_list(end))];
        leg = [leg,'Location','SouthEast'];
        %
        graph1D_jd(dtn_list(idtn):dtn_list(idtn):tfinal,I{idtn,iopt,icoll},1,1,xlab,ylab,tit,leg,xlim,ylim,style{ndtn},marker{ndtn},color{ndtn},lsize(ndtn),20,gca,red,0.7,bspace);
        %
        set(gca,'ytick',10.^[-1:2])
        set(gca,'xtick',10.^[0:5])
        set(gca,'xminorgrid','off')
        set(gca,'yminorgrid','off')
        %
        print_jd(p_opt,['Fig_splitting_',num2str(Dr0),'_coll_',num2str(coll_mode_list(icoll)),'_split_',num2str(optsplit_list(iopt))],'.',ifig)
        %
    end
end
%
