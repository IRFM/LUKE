close all
clear all 
%
print_opt = 2;%-1: no print, 2:save files (eps,png,fig)
flag_calcul = 1;%1: calculation is done (even data have been saved), 0: data are reload if they have been saved
%
models = {'Thomas-Fermi','Thomas-Fermi-Kirillov'};%'Thomas-Fermi','Thomas-Fermi-Kirillov','Tseng-Pratt-Avdonina-Lamoureux','Tseng-Pratt-Botto','Tseng-Pratt-Thomas-Fermi'
%atoms = {'Tungsten','Xenon','Copper','Iron','Argon','Neon','Oxygen','Nitrogen','Carbon','Beryllium','Helium'};
atoms = {'Tungsten','Argon'};
%
if exist('data_ionradius.mat') && ~flag_calcul
    load data_ionradius.mat;
else
    %
    for iatom = 1:length(atoms)
        %
        for imodel = 1:length(models)
            ionradius(iatom,imodel) = ionradius_yp(atoms{iatom},models{imodel});
        end
        %
    end
    %
    save data_screening.mat ionradius
end
%
linestyle(1) = {'-'};
linestyle(2) = {'--'};
linestyle(3) = {'-.'};
linestyle(4) = {':'};
%
linecolor(1) = {'r'};
linecolor(2) = {'b'};
linecolor(3) = {'g'};
linecolor(4) = {'m'};
%
for iatom = 1:length(atoms)
%    
    imodel = 1;%Thomas-Fermi model
    %
    xlab = 'q/(m_{e}c)';
    ylab = 'Thomas-Fermi form factor';
    tit = ['Thomas-Fermi form factor for ',atoms{iatom},' (Z = ',int2str(ionradius(iatom,imodel).Z),')'];
    siz = 20+14i;
    figure('Name',['Atomic form factor ',atoms{iatom}])
    %
    [q,ff,ff_tf] = form_factor_yp(ionradius(iatom,imodel).rn,ionradius(iatom,imodel).dens,ionradius(iatom,imodel).Z,ionradius(iatom,imodel).N);
    %
    xlim = [0.01,10000];%normalized transfered momentum q/(mec)
    ylim = [0,ionradius(iatom,imodel).Z];
    %
    iZ0 = 1;
    %
    graph1D_jd(q,ff(iZ0,:),1,0,xlab,ylab,tit,'',xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca);
    graph1D_jd(q,ff_tf(iZ0,:),1,0,xlab,ylab,tit,'',xlim,ylim,'--','none','b',2,siz,gca); 
    legend(['Exact caculation (Z_0=',int2str(ionradius(iatom,imodel).Z0(iZ0)),')'],'Approximate calculation [Kirillov et al. (1975)]');
    %
    a_tf_kirillov = (3*sqrt(pi))^(2/3)*ionradius(iatom,imodel).N(iZ0).^(2/3)/ionradius(iatom,imodel).Z/4;
    %ffk_out1 = ffk(a_tf,q,ionradius(iatom,imodel).N(iZ0));
    %graph1D_jd(q(1:10:end),ffk_out1(1:10:end),1,0,xlab,ylab,tit,'',xlim,ylim,'none','+','k',2,siz,gca); 
    %
    fun_ff = @(a,q) formfactor_yp(a,q,ionradius(iatom,imodel).N(iZ0),ionradius(iatom,imodel).nff(iZ0));%a is the free parameter
    %ffk_out2 = fun_ff(a_tf,q);
    %graph1D_jd(q(1:10:end),ff_out2(1:10:end),1,0,xlab,ylab,tit,'',xlim,ylim,'none','x','g',2,siz,gca);
    %
    norm_ff = @(a) norm(ff(iZ0,:) - fun_ff(a,q)); 
    %options = optimset('TolFun',1e-8);
    [a_optim] = fminsearch(norm_ff, a_tf_kirillov); 
    ffk_out3 = fun_ff(a_optim,q);
    %
    graph1D_jd(q(1:10:end),ffk_out3(1:10:end),1,0,xlab,ylab,tit,'',xlim,ylim,'-.','none','g',2,siz,gca);
    legend('Exact Thomas-Fermi model','Approximate Kirillov expression','Best fit of the exact form factor');
    drawnow;
    %
    print_jd(print_opt,['Form_factor_best_fit_',atoms{iatom}],'./Figs',get(gcf,'Number'))
    %
    clear a_tf_kirillov_bar a_tf_optim_bar a_optim resnorm
    %
    for iZ0 = 1:ionradius(iatom,imodel).Z
        a_tf_kirillov = (3*sqrt(pi))^(2/3)*ionradius(iatom,imodel).N(iZ0).^(2/3)/ionradius(iatom,imodel).Z/4;
        fun_ffk = @(a,q) formfactor_yp(a,q,ionradius(iatom,imodel).N(iZ0),ionradius(iatom,imodel).nff(iZ0));%a is the free parameter
        norm_ffk = @(a) norm(ff(iZ0,:) - fun_ffk(a,q)); 
        [a_optim] = fminsearch(norm_ffk, a_tf_kirillov);
        a_tf_kirillov_bar(iZ0) = 2*137*a_tf_kirillov;
        a_tf_optim_bar(iZ0) = 2*137*a_optim;
    end
    %
    if iatom == 1
        Z_hesslow = [0,30,40,50,60];%tungsten
        a_hesslow = [59,33,25,18,13];
    elseif iatom == 2
        Z_hesslow = [0:1:17];%Argon
        a_hesslow = [96,90,84,78,72,65,59,53,47,44,41,38,35,32,27,21,13,13];
    elseif iatom == 5
        Z_hesslow = [1,2,3];%xenon
        a_hesslow = [65,63,61];
    elseif iatom == 6
        Z_hesslow = [0:1:9];%Neon
        a_hesslow = [111,100,90,80,71,62,52,50,24,23];
    elseif iatom == 8
        Z_hesslow = [0:1:6];%Nitrogen
        a_hesslow = [135,115,97,79,59,35,33];
    elseif iatom == 9
        Z_hesslow = [0:1:5];%Carbon
        a_hesslow = [144,118,95,70,42,39];
    elseif iatom == 10    
        Z_hesslow = [0,1,2,3];%beryllium
        a_hesslow = [159,114,67,59];
    elseif iatom == 11
        Z_hesslow = [0,1];%Helium
        a_hesslow = [173,123];
    end
    %
    figure('Name',['Ion radius ',atoms{iatom}])
    %
    xlab = 'Ion charge Z_0';
    ylab = '2*a_Z_0/\alpha [a_0]';
    tit = ['Ion radius for ',atoms{iatom},' (Z = ',int2str(ionradius(iatom,imodel).Z),')'];
    siz = 20+14i;
    %
    xlim = [0,ionradius(iatom,imodel).Z];
    %
    if exist('Z_hesslow')
        maxionradius = [a_hesslow];
    else
        maxionradius = [];
    end
    %
    for imodel = 1:length(models)
         if imodel == 1,
             leg = {[models{imodel}, ' model']};
         else
              leg = [leg,{[models{imodel}, ' model']}];
         end
         %
         maxionradius = [maxionradius,ionradius(iatom,imodel).a];
         ylim = [0,max(maxionradius)];
         %
         graph1D_jd(ionradius(iatom,imodel).Z0,ionradius(iatom,imodel).a,0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca); 
    end
    %
    if exist('Z_hesslow')
        leg = [leg,{'L. Hesslow et al. (2018)'}];
        graph1D_jd(Z_hesslow,a_hesslow,0,0,xlab,ylab,tit,leg,xlim,ylim,':','o','k',2,siz,gca);
    end
    %
    set(gca,'ytick',[1:10:ylim(2)]);
    %
    leg = [leg,{'From exact fit using the approximate Kirillov form factor'}];
    %graph1D_jd(ionradius(iatom,imodel).Z0,a_tf_kirillov_bar,0,0,xlab,ylab,tit,leg,xlim,ylim,'-.','none','g',2,siz,gca);
    graph1D_jd(ionradius(iatom,imodel).Z0(1:end-1),a_tf_optim_bar,0,0,xlab,ylab,tit,leg,xlim,ylim,'-.','none','g',2,siz,gca);
    %
    drawnow;
    print_jd(print_opt,['Ion_radius_from_form_factor_fit_',atoms{iatom}],'./Figs',get(gcf,'Number'))
    %
end