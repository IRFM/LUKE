%
%Test form factors for simple models (Thomas-Fermi,Thomas-Fermi-Kirillov,Tseng-Pratt-Botto) against DFT calculations (Gaussian)
%
close all
clear all
clc
%
[~,~,~,~,~,~,~,~,~,alpha,~,~] = pc_dke_yp;%Universal physics constants
%
print_opt = -1;%-1: no print, 2:save files (eps,png,fig)
%
load('FDFT_Linnea.mat');
%
models = {'Thomas-Fermi-Kirillov','Tseng-Pratt-Botto'};%'Thomas-Fermi-Kirillov','Tseng-Pratt-Avdonina-Lamoureux','Tseng-Pratt-Botto','Tseng-Pratt-Thomas-Fermi'
%
q_hat = FDFT.p;%q/mec/alpha
%
exact_FF = rmfield(FDFT,'p');
%
names_FF = fieldnames(exact_FF);
%
for imodel = 1:length(models)
    %
    for ii = 1:length(names_FF)
        %
        FF_ref{ii} = exact_FF.(names_FF{ii});
        Z0_ref(ii) = str2num(char(regexp(names_FF{ii},'\d+\.?\d*|-\d+\.?\d*|\.?\d+|-\.?\d+','match')));
        atom_ref{ii} = names_FF{ii}(isstrprop(names_FF{ii},'alpha'));
        %
        ionradius{imodel,ii} = ionradius_yp(atom_ref{ii},models{imodel});
        %
        iZ0 = Z0_ref(ii)+1;
        %
        fun_ff = @(a,q) formfactor_yp(a,q,ionradius{imodel,ii}.Z-ionradius{imodel,ii}.Z0(iZ0),ionradius{imodel,ii}.nff(iZ0));%a is the free parameter
        %
        a_model(imodel,ii) = ionradius{imodel,ii}.a(iZ0);
        %
        norm_ff = @(a) norm(FF_ref{ii}(:) - fun_ff(a,q_hat)); 
        %
        a_optim(imodel,ii) = fminsearch(norm_ff, ionradius{imodel,ii}.a(iZ0))/2; 
        ff_optim{imodel,ii} = fun_ff(a_optim(imodel,ii),q_hat);
        %
        chi2_optim(imodel,ii) = sum((ff_optim{imodel,ii}(:) - FF_ref{ii}(:)).^2)/length(q_hat)./(ionradius{imodel,ii}.Z-ionradius{imodel,ii}.Z0(iZ0))^2; 
        %
        if strcmp('He',atom_ref{ii})
            %
            atom_index_ref(ii) = 1;
            atom_hesslow_ref{atom_index_ref(ii)} = atom_ref{ii};
            atom_maxindex_ref(atom_index_ref(ii)) = ii;
            Z_hesslow{atom_index_ref(ii)} = 2;%Helium
            Z0_hesslow{atom_index_ref(ii)} = [0,1];
            a_hesslow{atom_index_ref(ii)} = [173,123];
            nff_hesslow{atom_index_ref(ii)} = [2,1.5];
            %
        elseif strcmp('Be',atom_ref{ii})
            %
            atom_index_ref(ii) = 2;
            atom_hesslow_ref{atom_index_ref(ii)} = atom_ref{ii};
            atom_maxindex_ref(atom_index_ref(ii)) = ii;
            Z_hesslow{atom_index_ref(ii)} = 4;%Beryllium
            Z0_hesslow{atom_index_ref(ii)} = [0,1,2,3];
            a_hesslow{atom_index_ref(ii)} = [159,114,67,59];
            nff_hesslow{atom_index_ref(ii)} = [2,1.5,1.5,1.5];
            %
        elseif strcmp('C',atom_ref{ii})
            %
            atom_index_ref(ii) = 3;
            atom_hesslow_ref{atom_index_ref(ii)} = atom_ref{ii};
            atom_maxindex_ref(atom_index_ref(ii)) = ii;
            Z_hesslow{atom_index_ref(ii)} = 6;%Carbon
            Z0_hesslow{atom_index_ref(ii)} = [0:1:5];
            a_hesslow{atom_index_ref(ii)} = [144,118,95,70,42,39];
            nff_hesslow{atom_index_ref(ii)} = [2,1.5,1.5,1.5,1.5,1.5];
            %
        elseif strcmp('N',atom_ref{ii})
            %
            atom_index_ref(ii) = 4;
            atom_hesslow_ref{atom_index_ref(ii)} = atom_ref{ii};
            atom_maxindex_ref(atom_index_ref(ii)) = ii;
            Z_hesslow{atom_index_ref(ii)} = 7;%Nitrogen
            Z0_hesslow{atom_index_ref(ii)} = [0:1:6];
            a_hesslow{atom_index_ref(ii)} = [135,115,97,79,59,35,33];
            nff_hesslow{atom_index_ref(ii)} = [2,1.5,1.5,1.5,1.5,1.5,1.5];
            %
        elseif strcmp('Ne',atom_ref{ii})
            %
            atom_index_ref(ii) = 5;
            atom_hesslow_ref{atom_index_ref(ii)} = atom_ref{ii};
            atom_maxindex_ref(atom_index_ref(ii)) = ii;
            Z_hesslow{atom_index_ref(ii)} = 10;%Neon
            Z0_hesslow{atom_index_ref(ii)} = [0:1:9];%Neon
            a_hesslow{atom_index_ref(ii)} = [111,100,90,80,71,62,52,50,24,23];
            nff_hesslow{atom_index_ref(ii)} = [2,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5];
            %
        elseif strcmp('Ar',atom_ref{ii})
            %
            atom_index_ref(ii) = 6;
            atom_hesslow_ref{atom_index_ref(ii)} = atom_ref{ii};
            atom_maxindex_ref(atom_index_ref(ii)) = ii;
            Z_hesslow{atom_index_ref(ii)} = 18;%Argon
            Z0_hesslow{atom_index_ref(ii)} = [0:1:17];
            a_hesslow{atom_index_ref(ii)} = [96,90,84,78,72,65,59,53,47,44,41,38,35,32,27,21,13,13];
            nff_hesslow{atom_index_ref(ii)} = [2,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5,1.5];
       % elseif strcmp('Xe',atom_ref)
             %
       %     atom_index_ref(ii) = 7;
       %     atom_hesslow_ref{atom_index_ref(ii)} = atom_ref{ii};
       %     atom_maxindex_ref(atom_index_ref(ii)) = ii;
       %     Z_hesslow{atom_index_ref(ii)} = 4;%Xenon
       %     Z0_hesslow{atom_index_ref(ii)} = [1,2,3];
       %     a_hesslow{atom_index_ref(ii)} = [65,63,61];
             %
        elseif strcmp('W',atom_ref{ii})
            %
            atom_index_ref(ii) = 7;
            atom_hesslow_ref{atom_index_ref(ii)} = atom_ref{ii};
            atom_maxindex_ref(atom_index_ref(ii)) = ii;
            Z_hesslow{atom_index_ref(ii)} = 74;%%Tungsten
            Z0_hesslow{atom_index_ref(ii)} = [0,30,40,50,60];
            a_hesslow{atom_index_ref(ii)} = [59,33,25,18,13];
            nff_hesslow{atom_index_ref(ii)} = [2,1.5,1.5,1.5,1.5];
            %
        end        
        %
    end
    %
end
%
for imodel = 1:length(models)
    %
    for ii = 1:length(Z0_hesslow)
        %
        if ii == 1
            Z0{imodel,ii} = Z0_ref(1:atom_maxindex_ref(ii));
            a{imodel,ii} = a_optim(imodel,1:atom_maxindex_ref(ii));
            chi2{imodel,ii} = chi2_optim(imodel,1:atom_maxindex_ref(ii));
            a_mod{imodel,ii} = a_model(imodel,1:atom_maxindex_ref(ii));
        else
            Z0{imodel,ii} = Z0_ref(atom_maxindex_ref(ii-1)+1:atom_maxindex_ref(ii));
            a{imodel,ii} = a_optim(imodel,atom_maxindex_ref(ii-1)+1:atom_maxindex_ref(ii));
            chi2{imodel,ii} = chi2_optim(imodel,atom_maxindex_ref(ii-1)+1:atom_maxindex_ref(ii));
            a_mod{imodel,ii} = a_model(imodel,atom_maxindex_ref(ii-1)+1:atom_maxindex_ref(ii));
        end
        %
    end
    %
end
%
aa_hesslow = [];
for iatom = 1:length(a_hesslow)
    %
    aa_hesslow = [aa_hesslow,a_hesslow{iatom}];
    %
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
marker(1) = {'o'};
marker(2) = {'x'};
marker(3) = {'+'};
marker(4) = {'*'};
marker(5) = {'s'};
marker(6) = {'d'};
%
siz = 20+14i;
%
xlab = 'Z_0';
ylab = '(\chi^2/N)/(Z-Z_0)^2';
tit = ['Fit accuracy of the exact DFT form factor for Z = ',int2str(Z_hesslow{ii})];
leg = {};
%
for ii = 1:length(Z0_hesslow)
    %
    figure('Name',['\chi2, Z = ',int2str(Z_hesslow{ii})])
    %       
    tit = ['Fit accuracy of the DFT form factor for Z = ',int2str(Z_hesslow{ii})];
    %
    for jj = 1:length(models)
        %
        leg = [leg,models{jj}];
        graph1D_jd(Z0{jj,ii},chi2{jj,ii},0,0,xlab,ylab,tit,leg,'','','none',marker{jj},linecolor{jj},2,siz,gca); 
        %
    end
    %
    drawnow
    print_jd(print_opt,['fit_chi2_',atom_hesslow_ref{ii}],'./Figs',get(gcf,'Number'))
    %
end
%
leg = {};
ylab = 'a_{Z_{0,s}} [a_0]';
%
for ii = 1:length(Z0_hesslow)
    %
    figure('Name',['a_Z_0,s, Z = ',int2str(Z_hesslow{ii})])
    tit = ['a_{Z_{0,s}}, Z = ',int2str(Z_hesslow{ii})];
    %       
    kk = 1;
    %
    for jj = 1:length(models)
        %
        leg = [leg,['Fit, ',models{jj}]];
        graph1D_jd(Z0{jj,ii},a{jj,ii},0,0,xlab,ylab,tit,leg,'','','none',marker{kk},linecolor{kk},2,siz,gca); 
        %
        kk = kk + 1;
        %
        leg = [leg,models{jj}];
        graph1D_jd(Z0{jj,ii},a_mod{jj,ii},0,0,xlab,ylab,tit,leg,'','','none',marker{kk},linecolor{kk},2,siz,gca); 
        %
        kk = kk + 1;
        %
    end
    %
    leg = [leg,'TF-DFT, L. Hesslow et al. (2018)'];
    graph1D_jd(Z0_hesslow{ii},a_hesslow{ii},0,0,xlab,ylab,tit,leg,'','','--',marker{kk},linecolor{kk},2,siz,gca);  
    %
    drawnow
    print_jd(print_opt,['fit_ionradius_',atom_hesslow_ref{ii}],'./Figs',get(gcf,'Number'))
    %
end
%
while 1
    %
    disp(' ')
    disp('-------------------------------------------------------------')
    disp('1-2:He, 3-6:Be, 7-12:C, 13-19:N, 20-29:Ne, 30-47:Ar, 48-52: W')
    disp('-------------------------------------------------------------')
    disp(' ')
    %
    ii = input_dke_yp(['Display DFT form factor and fits. Enter ion index [1:52] or 0 exit: '],45,[-1;52],'Warning, the value must be between -1 (quit) and 52');
    %
    if ii <= 0
        break
    end
    %
    figure('Name',['Form factor for ',atom_ref{ii},int2str(Z0_ref(ii)),'+'])
    xlab = 'q/(m_ec)';
    ylab = 'Atomic form factor F(q)';
    tit = ['Atomic form factor for ',atom_ref{ii},'^{',int2str(Z0_ref(ii)),'+}'];
    leg = {};
    xlim = [0.0001,10];
    ylim = [0,ionradius{imodel,ii}.Z - Z0_ref(ii)];
    %
    for imodel = 1:length(models)
        %
        leg = [leg,['Fit with ',models{imodel},' model, 2*a_s/\alpha [a_0] = ',num2str(a_optim(imodel,ii))]];
        graph1D_jd(q_hat,ff_optim{imodel,ii},1,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{imodel},'none',linecolor{imodel},2,siz,gca);  
        %
    end
    %
    leg = [leg,['Form factor from DFT, Hesslow et al. (2018), 2*a_s/\alpha [a_0] = ',num2str(aa_hesslow(ii))]];%
    graph1D_jd(q_hat*2,FF_ref{ii},1,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{imodel+1},'none',linecolor{imodel+1},2,siz,gca); 
    %
    drawnow
    print_jd(print_opt,['fit_formfactor_',atom_ref{ii},int2str(Z0_ref(ii))],'./Figs',get(gcf,'Number'))
    %
end
%
nE = 30;
Ec_ref = input_dke_yp(['Max. electron kinetic energy (keV)'],1000);
pmax = sqrt((Ec_ref/511 + 1).^2 - 1);%relativistic units
p = logspace(-2,log10(round(pmax)),nE);
%
compacted_atom_index_ref = unique(atom_index_ref.','rows').';%remove duplicates
%
for imodel = 1:length(models)
    %
    for iatom = 1:length(compacted_atom_index_ref)
        %
        iatom_ref = find(atom_index_ref==iatom);
        %
        ionradius_model{imodel,iatom}.Z = ionradius{imodel,iatom_ref(1)}.Z;
        ionradius_model{imodel,iatom}.Z0 = ionradius{imodel,iatom_ref(1)}.Z0;
        ionradius_model{imodel,iatom}.a = ionradius{imodel,iatom_ref(1)}.a;
        ionradius_model{imodel,iatom}.nff = ionradius{imodel,iatom_ref(1)}.nff;
        %
        ionradius_optim{imodel,iatom}.Z = ionradius_model{imodel,iatom}.Z;
        ionradius_optim{imodel,iatom}.Z0 = [Z0_ref(iatom_ref),ionradius_model{imodel,iatom}.Z];
        ionradius_optim{imodel,iatom}.a = [a_optim(imodel,iatom_ref),0];
        ionradius_optim{imodel,iatom}.nff = [ionradius_model{imodel,iatom}.nff(1:length(a_optim(imodel,iatom_ref))),2];
        %
        ionradius_hesslow{imodel,iatom}.Z = ionradius_model{imodel,iatom}.Z;
        ionradius_hesslow{imodel,iatom}.Z0 = Z0_ref(iatom_ref);
        ionradius_hesslow{imodel,iatom}.a = a_hesslow{iatom};
        ionradius_hesslow{imodel,iatom}.nff = nff_hesslow{iatom};
        %
        [gfp_model{imodel,iatom},gfpn_model{imodel,iatom}] = gfp_yp(p,ionradius_model{imodel,iatom}.Z,models{imodel});
        [gfp_optim{imodel,iatom},gfpn_optim{imodel,iatom}] = gfp_yp(p,ionradius_model{imodel,iatom}.Z,models{imodel});
        [gfp_hesslow{imodel,iatom},gfpn_hesslow{imodel,iatom}] = gfp_yp(p,ionradius_model{imodel,iatom}.Z,models{imodel});
        %
    end
    %
end
%
while 1
    %
    disp(' ')
    disp('--------------------------------------')
    disp('1:He, 2:Be, 3:C, 4:N, 5:Ne, 6:Ar, 7: W')
    disp('--------------------------------------')
    disp(' ')
    %
    iatom_ref = input_dke_yp(['Display Fokker-Planck screening function ''g''. Enter atom index [1:7] or 0 exit : '],6,[-1;7],'Warning, the value must be between -1 (quit) and 7');
    %
    if iatom_ref <= 0
        %
        break
        %
    end
    %
    Z0_ref1 = Z0_ref(atom_index_ref==iatom_ref);
    Z0_ref2 = input_dke_yp(['Display Fokker-Planck screening function ''g''. Enter ionization value : '],Z0_ref(1),[-1,Z0_ref1],'Warning, the value must be between -1 (quit) and 7');
    iZ0_ref = find(Z0_ref1==Z0_ref2) + min(find(atom_index_ref==iatom_ref)) - 1;
    %
    if Z0_ref2 == 0
        %
        figure('Name',['Fokker-Planck screening function for ',atom_ref{min(find(atom_index_ref==iatom_ref))},int2str(Z0_ref2)]);
        %
    else
        %
        figure('Name',['Fokker-Planck screening function for ',atom_ref{min(find(atom_index_ref==iatom_ref))},int2str(Z0_ref2),'+']);
        %
    end
    %
    xlab = 'p/(m_ec)';
    ylab = 'g_{Z_0}/(Z^2-Z_0^2)';
    %
    if Z0_ref2 == 0 
        %
        tit = ['Normalized Fokker-Planck screening function for ',atom_ref{min(find(atom_index_ref==iatom_ref))},'^{',int2str(Z0_ref2),'}, E_c = [0:',num2str(Ec_ref),'] (keV)'];
        %
    else
        %
        tit = ['Normalized Fokker-Planck screening function for ',atom_ref{min(find(atom_index_ref==iatom_ref))},'^{',int2str(Z0_ref2),'+}, E_c = [0:',num2str(Ec_ref),'] (keV)'];
        %
    end
    %
    leg = {};
    xlim = [0,max(p)];
    ylim = [0,max(max(gfpn_optim{imodel,iatom_ref}(:,find(Z0_ref1==Z0_ref2))))];
    kk = 1;
    %
    for imodel = 1:length(models)
        %
        if Z0_ref2 == 0
            %
            leg = [leg,['Best fit, ',models{imodel},', a_s(',atom_ref{min(find(atom_index_ref==iatom_ref))},'^{',int2str(Z0_ref2),'}) = ',num2str(ionradius_optim{imodel,iatom_ref}.a(find(Z0_ref1==Z0_ref2)))]];
            %
        else
            %
            leg = [leg,['Best fit, ',models{imodel},', a_s(',atom_ref{min(find(atom_index_ref==iatom_ref))},'^{',int2str(Z0_ref2),'+}) = ',num2str(ionradius_optim{imodel,iatom_ref}.a(find(Z0_ref1==Z0_ref2)))]];
            %
        end
        %
        graph1D_jd(p,gfpn_optim{imodel,iatom_ref}(:,find(Z0_ref1==Z0_ref2)),0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{kk},'none',linecolor{kk},2,siz,gca);
        kk = kk + 1;
        %
        if Z0_ref2 == 0 
            %
            leg = [leg,['Atomic model ',models{imodel},', a_s(',atom_ref{min(find(atom_index_ref==iatom_ref))},'^{',int2str(Z0_ref2),'}) = ',num2str(ionradius_model{imodel,iatom_ref}.a(find(Z0_ref1==Z0_ref2)))]];
            %
        else 
            %
            leg = [leg,['Atomic model, ',models{imodel},', a_s(',atom_ref{min(find(atom_index_ref==iatom_ref))},'^{',int2str(Z0_ref2),'+}) = ',num2str(ionradius_model{imodel,iatom_ref}.a(find(Z0_ref1==Z0_ref2)))]];
            %
        end
        %
        graph1D_jd(p,gfpn_model{imodel,iatom_ref}(:,find(Z0_ref1==Z0_ref2)),0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{kk},'none',linecolor{kk},2,siz,gca);
        kk = kk + 1;
        %
    end
    %
    if Z0_ref2 == 0 
        %
        leg = [leg,['TF-DFT, Hesslow et al. (2018), ',models{imodel},', a_s(',atom_ref{min(find(atom_index_ref==iatom_ref))},'^{',int2str(Z0_ref2),'}) = ',num2str(ionradius_hesslow{imodel,iatom_ref}.a(find(Z0_ref1==Z0_ref2)))]];
        %
    else
        %
        leg = [leg,['TF-DFT, Hesslow et al. (2018), ',models{imodel},', a_s(',atom_ref{min(find(atom_index_ref==iatom_ref))},'^{',int2str(Z0_ref2),'+}) = ',num2str(ionradius_hesslow{imodel,iatom_ref}.a(find(Z0_ref1==Z0_ref2)))]];
        %
    end
    %
    graph1D_jd(p,gfpn_hesslow{imodel,iatom_ref}(:,find(Z0_ref1==Z0_ref2)),0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{kk},'none',linecolor{kk},2,siz,gca);
    %
    drawnow
    %
    if Z0_ref2 == 0
        %
        print_jd(print_opt,['fit_g_fokker-planck_',atom_ref{min(find(atom_index_ref==iatom_ref))},int2str(Z0_ref2)],'./Figs',get(gcf,'Number'))
        %
    else
        %
        print_jd(print_opt,['fit_g_fokker-planck_',atom_ref{min(find(atom_index_ref==iatom_ref))},int2str(Z0_ref2)],'+./Figs',get(gcf,'Number'))
        %
    end
    
end


