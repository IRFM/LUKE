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
function fproc_quench(xTe,Efield,J,pfM,pf0,pfbM,savedata,trbetath,graph,p_opt,f_opt,c_opt,id_simul)
%
tn = savedata.t;
%
figure(1),clf
%
if ~c_opt,
    leg = {'Prescr.','LUKE','Bulk','Supra.'};%,'Max.'
else
%     leg = {'Prescr.','Max.','LUKE'};
    leg = {'Prescr.','LUKE Bulk','LUKE Full'};
end
xlim = [0,max(tn)];
ylim = NaN;%[0,1.4];%
ytick = 0:0.2:1.4;
xlab = 't/\tau_c';
ylab = 'T_e/T_{e0}';
tit = '';
siz = 20+14i;
%
graph1D_jd(tn,trbetath.^2,0,0,'','','',NaN,xlim,ylim,'-','none','k',0.5,siz,gca);
if 0,%c_opt,
    graph1D_jd(tn,xTe.normM,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,siz,gca);
end
graph1D_jd(tn,xTe.normb,0,0,'','','',NaN,xlim,ylim,'none','o','b',2,siz,gca);
graph1D_jd(tn,xTe.norm0,0,0,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
if ~c_opt,
    graph1D_jd(tn,xTe.normb,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,siz,gca);
    graph1D_jd(tn,xTe.norms,0,0,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,siz,gca);
end
% graph1D_jd(tn,xTe.delta,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',[0.5,0,0.5],2,siz,gca,0.9,0.7,0.7);
graph1D_jd(tn,NaN*xTe.delta,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',[0.5,0,0.5],2,siz,gca,0.9,0.7,0.7);
%
%set(gca,'ytick',ytick)
%
print_jd(p_opt,['fig_',id_simul,'_T'],'./figures',1)
%
figure(2),clf
%
ylim = NaN;%[0,1.4];%
ytick = NaN;%0:0.2:1.4;
ylab = 'E/E_c';
tit = '';
siz = 20+14i;
%
graph1D_jd(tn,Efield,0,0,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
graph1D_jd(xlim,[1,1],0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','k',2,siz,gca,0.9,0.7,0.7);
%
%set(gca,'ytick',ytick)
%
print_jd(p_opt,['fig_',id_simul,'_E'],'./figures',2)
%
figure(3),clf
%
leg = {'Spitzer','Hot','Internal RE','External RE','Total'};%,'Max.'
ylim = [0,1.2];%
ytick = 0:0.2:1.2;
ylab = 'J/J_0';
tit = '';
siz = 20+14i;
%
graph1D_jd(tn,J.lin/J.j0,0,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(tn,J.hot/J.j0,0,0,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
graph1D_jd(tn,J.rei/J.j0,0,0,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,siz,gca);
graph1D_jd(tn,J.ree/J.j0,0,0,'','','',NaN,xlim,ylim,'-','none',[0.5,0,0.5],2,siz,gca);
graph1D_jd(tn,J.tot/J.j0,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','k',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'ytick',ytick)
%
print_jd(p_opt,['fig_',id_simul,'_J'],'./figures',3)
%
if f_opt,
    nit_disp = length(graph.it_disp);
    colors = {'r','b',[0,0.5,0],'m','c','y'};
    %
    if c_opt,% cylindrical display
        %
        dp_cyl = 0.1;
        %
        % spherical to cylindrical transformation
        %
        [logXf00_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(savedata.f(:,:,1)),savedata.pn,savedata.mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
        Xf00_cyl_ref = exp(logXf00_cyl_ref);%For accurate representation in figures 
        %
        logXf0M_cyl_ref = s2c_dke_yp(log(savedata.fM),savedata.pn,savedata.mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
        Xf0M_cyl_ref = exp(logXf0M_cyl_ref);%For accurate representation in figures 
        %
        Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';%Grid for the distribution functions only
        Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
        Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
        %
        Xf00_cyl_ref = Xf00_cyl_ref.*(Xf00_cyl_ref>0);%Remove negative values
        Xf00_cyl_ref = Xf00_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
        Xf00_cyl_ref(isnan(Xf00_cyl_ref)) = 0;%Remove NaN values
        %
        Xf0M_cyl_ref = Xf0M_cyl_ref.*(Xf0M_cyl_ref>0);%Remove negative values
        Xf0M_cyl_ref = Xf0M_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
        Xf0M_cyl_ref(isnan(Xf0M_cyl_ref)) = 0;%Remove NaN values
        %
        % Remove values less than computer accuracy
        %
        pnmax_0 = min(min(Xp_cyl_ref(abs(Xf00_cyl_ref) < eps)));
        pnmax = min([pnmax_0,max(savedata.pn)]);
        %
        Xmask = Xp_cyl_ref >= pnmax;    
        %
        Xf00_cyl_ref(Xmask) = 0;
        Xf0M_cyl_ref(Xmask) = 0;
        %
        Fpar00_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf00_cyl_ref,1);
        Fpar0M_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0M_cyl_ref,1);
        %
        Fpar0_cyl_ref = cell(1,nit_disp);
        FparM_cyl_ref = cell(1,nit_disp);
        leg = cell(1,nit_disp);
        %
        for iit = 1:nit_disp,
            %
            it = it_disp(iit);
            %
            logXf0_cyl_ref = s2c_dke_yp(log(savedata.f(:,:,it+1)),savedata.pn,savedata.mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
            Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
            %
            logXfM_cyl_ref = s2c_dke_yp(log(savedata.fM(:,:,it+1)),savedata.pn,savedata.mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
            XfM_cyl_ref = exp(logXfM_cyl_ref);%For accurate representation in figures 
            %
            Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
            Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
            Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
            %
            XfM_cyl_ref = XfM_cyl_ref.*(XfM_cyl_ref>0);%Remove negative values
            XfM_cyl_ref = XfM_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
            XfM_cyl_ref(isnan(XfM_cyl_ref)) = 0;%Remove NaN values
            %
            % Remove values less than computer accuracy
            %
            Xf0_cyl_ref(Xmask) = 0;
            XfM_cyl_ref(Xmask) = 0;
            %
            Fpar0_cyl_ref{iit} = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_cyl_ref,1);
            FparM_cyl_ref{iit} = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*XfM_cyl_ref,1);
            %
            leg{iit} = ['t/\tau_c = ',num2str(tn(it))];
        end
        %
        leg = ['t/\tau_c = 0',leg];
        %
        figure(10),clf
        %
        xlab = 'p_{||}/p_{Te}';
        xlim = [-pnmax,pnmax];
        ylab = 'F_{||}';
        ylim = [eps,1];
        %
        graph1D_jd(ppar_cyl_ref,Fpar00_cyl_ref,0,1,'','','',NaN,xlim,ylim,'-','none','k',2,siz,gca);
        %
        for iit = 1:nit_disp-1,
            graph1D_jd(ppar_cyl_ref,Fpar0_cyl_ref{iit},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iit},2,siz,gca);
        end
        %
        graph1D_jd(ppar_cyl_ref,Fpar0_cyl_ref{nit_disp},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{nit_disp},2,siz,gca,0.9,0.7,0.7);
        %
        graph1D_jd(ppar_cyl_ref,Fpar0M_cyl_ref,0,1,'','','',NaN,xlim,ylim,'-','none','k',0.5,siz,gca);
        %
        for iit = 1:nit_disp,
            graph1D_jd(ppar_cyl_ref,FparM_cyl_ref{iit},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iit},0.5,siz,gca);
        end
        %
        print_jd(p_opt,['fig_',id_simul,'_f1D'],'./figures',10)
        %
    else% mhu-averaged distribution
        %
        % Ignore values less than computer accuracy
        %
        pnmax_0 = min(min(savedata.pn(pf0{1} < eps)));
        pnmax = min([pnmax_0,max(savedata.pn)]);
        %
        leg = cell(1,nit_disp);
        for iit = 1:nit_disp,
            leg{iit} = ['t/\tau_c = ',num2str(tn(it_disp(iit)))];
        end
        leg = ['t/\tau_c = 0',leg];
        %
        figure(10),clf
        %
        xlab = 'p/p_{Te}';
        xlim = [0,pnmax];
        ylab = 'F_p';
        ylim = [eps,max(pfM{end})];
        %
        graph1D_jd(pn,pf0{1},0,1,'','','',NaN,xlim,ylim,'-','none','k',2,siz,gca);
        %
        for iit = 1:nit_disp-1,
            graph1D_jd(pn,pf0{1+it_disp(iit)},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iit},2,siz,gca);
        end
        %
        graph1D_jd(pn,pf0{1+it_disp(nit_disp)},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{nit_disp},2,siz,gca,0.9,0.7,0.7);
        %
        graph1D_jd(pn,pfM{1},0,1,'','','',NaN,xlim,ylim,'-','none','k',0.5,siz,gca);
        %
        for iit = 1:nit_disp,
            graph1D_jd(pn,pfM{1+it_disp(iit)},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iit},0.5,siz,gca);
            graph1D_jd(pn,pfbM{1+it_disp(iit)},0,1,'','','',NaN,xlim,ylim,'--','none',colors{iit},0.5,siz,gca);
        end
        %
        print_jd(p_opt,['fig_',id_simul,'_f1Dp'],'./figures',10)
        %
    end
    %    
end
