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
%
% Calculation of the ion radius for various atomic models and comparison with Hesslow's paper
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>, A. Jardin IJF/PAN <axel.jardin@ifj.edu.pl>, K. Krol IFJ/PAN <krzysztof.krol@ifj.edu.pl>
%
close all
clc
clear all
%
print_opt = -1;%-1: no print, 2:save files (eps,png,fig)
flag_calcul = 1;%1: calculation is enforced (even data have been saved), 0: data are reload if they have been saved
%
%atoms = {'Tungsten','Xenon','Copper','Iron','Argon','Neon','Oxygen','Nitrogen','Carbon','Beryllium','Helium'};
%models = {'Tseng-Pratt-Botto','Thomas-Fermi','Thomas-Fermi-Kirillov','Tseng-Pratt-Avdonina-Lamoureux','Tseng-Pratt-Botto','Tseng-Pratt-Thomas-Fermi','Full-screening'};
atoms = {'Argon'};
models = {'Tseng-Pratt-Botto','Thomas-Fermi'};
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
    save data_ionradius.mat ionradius
end
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
%---------------------- Ion radius ----------------------
%
for iatom = 1:length(atoms)
        %
    if strcmp(atoms{iatom},'Tungsten') == 1
        Z_hesslow = [0,30,40,50,60];%tungsten
        a_hesslow = [59,33,25,18,13];
    elseif strcmp(atoms{iatom},'Xenon') == 1
        Z_hesslow = [1,2,3];%xenon
        a_hesslow = [65,63,61];
    elseif strcmp(atoms{iatom},'Argon') == 1
        Z_hesslow = [0:1:17];%Argon
        a_hesslow = [96,90,84,78,72,65,59,53,47,44,41,38,35,32,27,21,13,13];
    elseif strcmp(atoms{iatom},'Neon') == 1
        Z_hesslow = [0:1:9];%Neon
        a_hesslow = [111,100,90,80,71,62,52,50,24,23];
    elseif strcmp(atoms{iatom},'Nitrogen') == 1
        Z_hesslow = [0:1:6];%Nitrogen
        a_hesslow = [135,115,97,79,59,35,33];
    elseif strcmp(atoms{iatom},'Carbon') == 1
        Z_hesslow = [0:1:5];%Carbon
        a_hesslow = [144,118,95,70,42,39];
    elseif strcmp(atoms{iatom},'Beryllium') == 1    
        Z_hesslow = [0,1,2,3];%beryllium
        a_hesslow = [159,114,67,59];
    elseif strcmp(atoms{iatom},'Helium') == 1
        Z_hesslow = [0,1];%Helium
        a_hesslow = [173,123];
    end
    %
    figure('Name',['Ion radius ',atoms{iatom}])
    %
    xlab = 'Z_0';
    ylab = '2a_{Z_{0,s}}/\alpha [a_0]';
    %tit = ['Ion radius scale for ',atoms{iatom},' (Z = ',int2str(ionradius(iatom,imodel).Z),')'];
    siz = 20+14i;
    %
    %xlim = [0,ionradius(iatom,imodel).Z];
    %
    if exist('Z_hesslow')
        maxionradius = [a_hesslow];
    else
        maxionradius = [];
    end
    %
    for imodel = 1:length(models)
        tit = ['Ion radius for ',atoms{iatom},' (Z = ',int2str(ionradius(iatom,imodel).Z),')'];
        xlim = [0,ionradius(iatom,imodel).Z];
         if imodel == 1,
             leg = {[models{imodel}, ' model']};
         else
             leg = [leg,{[models{imodel}, ' model']}];
         end
         %
         maxionradius = [maxionradius,ionradius(iatom,imodel).a];
         ylim = [0,max(maxionradius)];
         %
         graph1D_jd(ionradius(iatom,imodel).Z0(1:end-1),ionradius(iatom,imodel).a(1:end-1),0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca); 
    end
    %
    if exist('Z_hesslow')
        leg = [leg,{'L. Hesslow et al. '}];
        graph1D_jd(Z_hesslow,a_hesslow,0,0,xlab,ylab,tit,leg,xlim,ylim,':','o','k',2,siz,gca);
    end
    %
    set(gca,'ytick',[1:10:ylim(2)]);
    drawnow;
    print_jd(print_opt,['Ion radius ',atoms{iatom}],'./Figs',get(gcf,'Number'))
    %
    clear Z_hesslow a_hesslow
    %
end           
%
%---------------------- Electron density ----------------------
%
dens_ref(1) = 1.5e-3;%Tungsten
dens_ref(2) = 1e-3;%Xenon
dens_ref(3) = 1e-3;%Copper
dens_ref(4) = 1e-3;%Iron
dens_ref(5) = 1e-3;%Argon

dens_ref(1) = 1e-3;%Argon


dens_ref(6) = 1e-3;%Neon
dens_ref(7) = 2e-3;%Oxygen
dens_ref(8) = 2e-3;%Nitrogen
dens_ref(9) = 2e-3;%Carbon
dens_ref(10) = 3e-3;%Beryllium
dens_ref(11) = 1.5e-2;%Helium
for iatom = 1:length(atoms)
    %
    for imodel = 1:length(models)
        %
        if ~isnan(ionradius(1,imodel).dens{1})
            %
            figure('Name',['Density ',atoms{iatom},', model ',models{imodel}]);
            %
            xlab = 'Ion radius [a_0]';
            ylab = '\rho_e [a_0^{-3}]';
            tit = [atoms{iatom},' (Z = ',int2str(ionradius(iatom,imodel).Z),'), model : ',models{imodel}];
            siz = 20+14i;
            %
            leg = NaN;
            %
            %
            xlim = [0,max(ionradius(iatom,imodel).r0n)];
            ylim = [1e-4,1e4];
            %
            for j = 1:length(ionradius(iatom,imodel).rn)       
                graph1D_jd(ionradius(iatom,imodel).rn{j},ionradius(iatom,imodel).dens{j},0,1,xlab,ylab,tit,NaN,xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca); 
            end
        %
        end
        %
        itext = find(ionradius(iatom,imodel).dens{1} > dens_ref(iatom), 1, 'last' );
        text(ionradius(iatom,imodel).rn{1}(itext),ionradius(iatom,imodel).dens{1}(itext),[ionradius(iatom,imodel).symbol,'^0'],'BackgroundColor','White');
        %
        drawnow;
        print_jd(print_opt,['Density ',atoms{iatom}],'./Figs',get(gcf,'Number'))
    end
    %
end
%
%---------------------- Ion radius ----------------------
%
for iatom = 1:length(atoms)
    %
    xlab = 'Ion net charge Z_0';
    ylab = 'Ion radius r_0 [a_0]';
    tit = ['Radius of ',atoms{iatom},' (Z = ',int2str(ionradius(iatom,imodel).Z),')'];
    siz = 20+14i;
    %
    figure('Name',['Radius ',atoms{iatom}])
    %
    xlim = [0,ionradius(iatom,imodel).Z];
    ylim = [0,max(ionradius(iatom,imodel).r0n)];
    %
    leg = {};
    %
    for imodel = 1:length(models)
        if imodel == 1,
            leg{imodel} = [models{imodel}, ' model'];
        else
           if ~isnan(ionradius(iatom,imodel).r0n(end))
                leg{imodel} = [models{imodel}, ' model'];
           end
        end
        %
        if ~isnan(ionradius(iatom,imodel).r0n(end))
            graph1D_jd(ionradius(iatom,imodel).Z0,ionradius(iatom,imodel).r0n,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca); 
        end
        %
    end
    %
    legend(leg);
    %
    drawnow;
    print_jd(print_opt,['Radius ',atoms{iatom}],'./Figs',get(gcf,'Number'))
    %
end
%
%---------------------- Calculation time ----------------------
%
for iatom = 1:length(atoms)
    %
    xlab = 'Ion net charge Z_0';
    ylab = 'Calculation time [s]';
    tit = ['Calculation time for ',atoms{iatom},' (Z = ',int2str(ionradius(iatom,imodel).Z),')'];
    siz = 20+14i;
    %
    figure('Name',['Calculation time ',atoms{iatom}])
    %
    xlim = [0,ionradius(iatom,imodel).Z];
    ylim = [0,10];%10 s max
    %
    leg = {};
    %
    for imodel = 1:length(models)
        if imodel == 1,
            leg{imodel} = [models{imodel}, ' model'];
        else
           if ~isnan(ionradius(iatom,imodel).B(end))
                leg{imodel} = [models{imodel}, ' model'];
           end
        end
        %
        telasped = zeros(size(ionradius(iatom,imodel).Z0));
        %
        for j = 1:length(ionradius(iatom,imodel).Z0)
            if ~isnan(ionradius(iatom,imodel).B(end))
                telasped(j) = ionradius(iatom,imodel).output{j}.telapsed;
            end
        end
        %
        if ~isnan(ionradius(iatom,imodel).B(end))
            graph1D_jd(ionradius(iatom,imodel).Z0,telasped,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca); 
        end
        %
    end
    %
    legend(leg);
    %
    drawnow;
    print_jd(print_opt,['Calculation time ',atoms{iatom}],'./Figs',get(gcf,'Number'))
    %
end
%
%---------------------- Form factor ----------------------
%
for iatom = 1:length(atoms)
    %
    xlab = 'q/(m_{e}c)';
    ylab = 'Screening form factor';
    tit = ['Screening form factor for ',atoms{iatom},' (Z = ',int2str(ionradius(iatom,imodel).Z),')'];
    siz = 20+14i;
    %
    figure('Name',['Screening form factor ',atoms{iatom}])
    %
    xlim = [0.01,10000];%normalized transfered momentum q/(mec)
    ylim = [0,ionradius(iatom,imodel).Z];
    %
    leg = {};
    %
    for imodel = 1:length(models)
        %
        if imodel == 1,
            leg{imodel} = [models{imodel}, ' model'];
        else
           if ~isnan(ionradius(iatom,imodel).B(end))
                leg{imodel} = [models{imodel}, ' model'];
           end
        end
        %
        if ~isnan(ionradius(iatom,imodel).B(end))
            [q,ff,ff_tf] = form_factor_yp(ionradius(iatom,imodel).rn,ionradius(iatom,imodel).dens,ionradius(iatom,imodel).Z,ionradius(iatom,imodel).N);
            graph1D_jd(q,ff,1,0,xlab,ylab,tit,'',xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca);
            % 
            leg{length(leg)+1} = ['Kirillov et al. (1975)'];
            graph1D_jd(q,ff_tf,1,0,xlab,ylab,tit,'',xlim,ylim,'--','none','b',2,siz,gca); 
            %
        end
        %
        hLegend(iatom) = legend(leg);
        %
        %hLegend(iatom).EntryContainer.NodeChildren(1).Object.Color = [0 0 1];
        %hLegend(iatom).EntryContainer.NodeChildren(1).Object.LineStyle = '--';
        %
    end
    %
    drawnow;
    print_jd(print_opt,['Calculation time ',atoms{iatom}],'./Figs',get(gcf,'Number'))
    %
end
%
