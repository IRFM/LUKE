close all
clear all 
%
print_opt = 2;%-1: no print, 2:save files (eps,png,fig)
flag_calcul = 1;%1: calculation is done (even data have been saved), 0: data are reload if they have been saved
%
models = {'Thomas-Fermi','Thomas-Fermi-Kirillov'};%'Tseng-Pratt-Botto','Tseng-Pratt-Thomas-Fermi'};%,'Tseng-Pratt-Avdonina-Lamoureux'
atoms = {'Argon'};%'Xenon','Copper','Iron','Argon','Neon','Oxygen','Nitrogen','Carbon','Beryllium','Helium'};
units = 'mec';%'mec' or 'MeV/c'
%
[~,~,~,~,~,~,~,~,~,alpha,~,~,~,~,~,a0] = pc_dke_yp;
%
if exist('data_ionradius.mat') && ~flag_calcul
    %
    load data_ionradius.mat;%load data
    %
else
    %
    for iatom = 1:length(atoms)
        %
        for imodel = 1:length(models)
            %
            ionradius(iatom,imodel) = ionradius_yp(atoms{iatom},models{imodel});
            %
        end
        %
    end
    %
    save data_screening.mat ionradius
    %
end
%
linestyle(1) = {'-'};
linestyle(2) = {'--'};
linestyle(3) = {'-.'};
linestyle(4) = {':'};
linestyle(5) = {'-'};
%
linecolor(1) = {'r'};
linecolor(2) = {'b'};
linecolor(3) = {'g'};
linecolor(4) = {'m'};
linecolor(5) = {'c'};
%
for iatom = 1:length(atoms) 
    %    
    if exist('Z_hesslow')
        %
        clear 'Z_hesslow' 'a_hesslow'
        %
    end
    %
    imodel = find(ismember(models,'Thomas-Fermi'));%Thomas-Fermi model
    %
    if strcmp(units,'mec')
        %
        xlab = 'q/(m_{e}c)';
        %
    elseif strcmp(units,'MeV/c')
        %
        xlab = 'q/(MeV/c)';
        %
    end
    %
    ylab = 'Atomic form factor';
    tit = ['Thomas-Fermi form factor for neutral ',atoms{iatom},' (Z = ',int2str(ionradius(iatom,imodel).Z),')'];
    siz = 20+14i;
    figure('Name',['Thomas-Fermi atomic form factor for neutral ',atoms{iatom}])
    %
    [q,ff_tf,ff_tfk,ff_mol] = tf_form_factor_yp(ionradius(iatom,imodel).rn,ionradius(iatom,imodel).dens,ionradius(iatom,imodel).Z,ionradius(iatom,imodel).N);
    %
    if exist(['DFT/dft_',int2str(ionradius(iatom,imodel).Z),'_',elements('atomic_number', ionradius(iatom,imodel).Z, 'symbol'),'_',elements('atomic_number', ionradius(iatom,imodel).Z, 'name'),'.mat'])
        %
        load(['DFT/dft_',int2str(ionradius(iatom,imodel).Z),'_',elements('atomic_number', ionradius(iatom,imodel).Z, 'symbol'),'_',elements('atomic_number', ionradius(iatom,imodel).Z, 'name'),'.mat'])
        %
    end
    %
    xlim = [0.0001,10];%normalized transfered momentum q/(mec)
    ylim = [0,ionradius(iatom,imodel).Z];
    %
    iZ0 = 1;%neutral atom
    %
    if strcmp(units,'mec')
        %
        unitfactor = 1;
        %
    elseif strcmp(units,'MeV/c')
        %
        unitfactor = 1.627;
        %
    end
    %
    graph1D_jd(q/unitfactor,ff_tf(iZ0,:),1,0,xlab,ylab,tit,'',xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca);
    graph1D_jd(q/unitfactor,ff_tfk(iZ0,:),1,0,xlab,ylab,tit,'',xlim,ylim,'--','none','b',2,siz,gca); 
    %
    if iZ0 == 1
        %
        graph1D_jd(q/unitfactor,ff_mol(iZ0,:),1,0,xlab,ylab,tit,'',xlim,ylim,':','none','g',2,siz,gca); 
        %
    end
    %
    a_tf_kirillov = (3*sqrt(pi))^(2/3)*ionradius(iatom,imodel).N(iZ0).^(2/3)/ionradius(iatom,imodel).Z/4;
    a_tf_kirillov_n = 2*a_tf_kirillov/alpha;
    %ffk_out1 = ffk(a_tf,q,ionradius(iatom,imodel).N(iZ0));
    %graph1D_jd(q(1:10:end),ffk_out1(1:10:end),1,0,xlab,ylab,tit,'',xlim,ylim,'none','+','k',2,siz,gca); 
    %
    fun_ff = @(a,q) formfactor_yp(a,q,ionradius(iatom,imodel).N(iZ0),ionradius(iatom,imodel).nff(iZ0));%a is the free parameter
    %ffk_out2 = fun_ff(a_tf,q);
    %graph1D_jd(q(1:10:end),ff_out2(1:10:end),1,0,xlab,ylab,tit,'',xlim,ylim,'none','x','g',2,siz,gca);
    %
    norm_ff = @(a) norm(ff_tf(iZ0,:) - fun_ff(a,q)); 
    %options = optimset('TolFun',1e-8);
    [a_optim] = fminsearch(norm_ff, a_tf_kirillov_n); 
    ffk_out3 = fun_ff(a_optim,q);
    %
    graph1D_jd(q(1:10:end)/unitfactor,ffk_out3(1:10:end),1,0,xlab,ylab,tit,'',xlim,ylim,'-.','none','c',2,siz,gca);
    %
    if iZ0 == 1
        %
        legend('Exact (Numerical)','Analytical (Kirillov model)','Moliere model','Best fit (using Kirillov function)');
        %
    else
        %
        legend('Exact (Numerical)','Analytical (Kirillov model)','Best fit (using Kirillov function)');
        %
    end
    %
    drawnow;
    %
    print_jd(print_opt,['Thomas_Fermi_form_factor_best_fit_',atoms{iatom}],'./Figs',get(gcf,'Number'))
    %
    clear a_tf_kirillov_bar a_tf_optim_bar a_optim resnorm
    %
    for iZ0 = 1:ionradius(iatom,imodel).Z
        a_tf_kirillov = (3*sqrt(pi))^(2/3)*ionradius(iatom,imodel).N(iZ0).^(2/3)/ionradius(iatom,imodel).Z/4;
        a_tf_kirillov_n = 2*a_tf_kirillov/alpha;
        fun_ffk = @(a,q) formfactor_yp(a,q,ionradius(iatom,imodel).N(iZ0),ionradius(iatom,imodel).nff(iZ0));%a is the free parameter
        norm_ffk = @(a) norm(ff_tf(iZ0,:) - fun_ffk(a,q)); 
        [a_optim_n] = fminsearch(norm_ffk, a_tf_kirillov_n);
        a_tf_kirillov_bar(iZ0) = a_tf_kirillov_n;
        a_tf_optim_bar(iZ0) = a_optim_n;
    end
    %
    if strcmp(atoms{iatom},'Tungsten')
        Z_hesslow = [0,30,40,50,60];%tungsten
        a_hesslow = [59,33,25,18,13];
    elseif strcmp(atoms{iatom},'Argon')
        Z_hesslow = [0:1:17];%Argon
        a_hesslow = [96,90,84,78,72,65,59,53,47,44,41,38,35,32,27,21,13,13];
    elseif strcmp(atoms{iatom},'Xenon')
        Z_hesslow = [1,2,3];%xenon
        a_hesslow = [65,63,61];
    elseif strcmp(atoms{iatom},'Neon')
        Z_hesslow = [0:1:9];%Neon
        a_hesslow = [111,100,90,80,71,62,52,50,24,23];
    elseif strcmp(atoms{iatom},'Nitrogen')
        Z_hesslow = [0:1:6];%Nitrogen
        a_hesslow = [135,115,97,79,59,35,33];
    elseif strcmp(atoms{iatom},'Carbon')
        Z_hesslow = [0:1:5];%Carbon
        a_hesslow = [144,118,95,70,42,39];
    elseif strcmp(atoms{iatom},'Beryllium')
        Z_hesslow = [0,1,2,3];%beryllium
        a_hesslow = [159,114,67,59];
    elseif strcmp(atoms{iatom},'Helium')
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
         if imodel == 1
             %
             leg = {[models{imodel}, ' model']};
             %
         else
             %
             leg = [leg,{[models{imodel}, ' model']}];
             %
         end
         %
         maxionradius = [maxionradius,ionradius(iatom,imodel).a];
         ylim = [0,max(maxionradius)];
         %
         graph1D_jd(ionradius(iatom,imodel).Z0,ionradius(iatom,imodel).a,0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca); 
         %
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
    graph1D_jd(ionradius(iatom,imodel).Z0(1:end-1),a_tf_optim_bar,0,0,xlab,ylab,tit,leg,xlim,ylim,'-.','none','c',2,siz,gca);
    %
    drawnow;
    print_jd(print_opt,['Ion_radius_from_form_factor_fit_',atoms{iatom}],'./Figs',get(gcf,'Number'))
    %
end