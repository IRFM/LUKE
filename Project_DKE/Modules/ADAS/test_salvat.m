%
% Test Salvat (Moliere) method for any atomic electron density whatever the ionization state. thomas
% Modify the initial dft structure and save it. Two examples are considered : Gaussian DFT and Thomas-Fermi model.
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
close all 
clear all
clc
%
print_opt = 2;%-1: no print, 2:save files (eps,png,fig)
%
Z = [1,2,3,4,5,6,7,8,10,13,14,17,18,24,26,28,29,32,36,54,74,79];%Atomic number (If multiple Z values, dft change only, no display)
Z = [79];%change dft subfield salvat, and display results
%
atomic_models = [0];%[0 -> Gaussian DFT,1 -> Thomas-Fermi]
%
Zindex = [1:10:Z];%Zs for a global display (< Z)
%
for iZ = 1:length(Z)
    %
    filename = ['DFT/dft_',int2str(Z(iZ)),'_',elements('atomic_number', Z(iZ), 'symbol'),'_',elements('atomic_number', Z(iZ), 'name'),'.mat'];
    %
    if exist(filename)
        %
        load(filename);
        %
        if isfield(dft,'salvat')
            %
            disp(['WARNING : a salvat substructure already exists in the dft structure for ',elements('atomic_number', Z(iZ), 'name'),', ',elements('atomic_number', Z(iZ), 'symbol'),' (Z = ',int2str(Z(iZ)),').'])
            flag_salvat = 1;
            dft = rmfield(dft,'salvat');
            %
        else
            %
            flag_salvat = 0;
            %
        end
        %
        [dft] = salvat(dft,atomic_models);%add results of Salvat method to dft structure for model [0 -> Gaussian DFT,1 -> Thomas-Fermi]
        %
        if length(Z) > 1
            %
            save(filename,'dft');
            %
        else
            %
            models = fieldnames(dft.salvat);
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
            xlab = 'Ion radius [a_0]';
            ylab1 = '\rho [{a^{-3}_0}]';
            ylab2 = '4\pir^2\rho [{a^{-1}_0}]';
            %
            i = 1;%neutral atom
            %
            B1 = 0.1;%Universal Moliere's value for the Thomas-Fermi model
            B2 = 0.55;%Universal Moliere's value for the Thomas-Fermi model
            B3 = 0.35;%Universal Moliere's value for the Thomas-Fermi model
            %
            beta1 = 6.0;%Universal Moliere's value for the Thomas-Fermi model
            beta2 = 1.2;%Universal Moliere's value for the Thomas-Fermi model
            beta3 = 0.3;%Universal Moliere's value for the Thomas-Fermi model
            %
            A1 = B1;
            A2 = B2;
            A3 = B3;
            %
            lambda1 = beta1*Z^(1/3)/0.885;
            lambda2 = beta2*Z^(1/3)/0.885;
            lambda3 = beta3*Z^(1/3)/0.885;
            %
            xdens_thomas_fermi_moliere_4pir = Z*(A1*lambda1*lambda1*exp(-lambda1.*dft.r) + A2*lambda2*lambda2*exp(-lambda2.*dft.r) + A3*lambda3*lambda3*exp(-lambda3.*dft.r));
            xdens_thomas_fermi_moliere = xdens_thomas_fermi_moliere_4pir./dft.r/4/pi;
            xdens_thomas_fermi_moliere(1) = xdens_thomas_fermi_moliere(2);%avoid Inf value
            neR2_thomas_fermi_moliere = sum((xdens_thomas_fermi_moliere(:) - dft.ne(:,i)).^2)/length(dft.ne(:,i));
            %
            imodel = 1;%Gaussian
            %
            leg = {'DHFS (Gaussian code)',...
                ['Salvat et al. (1 exp), [\chi^2/N = ',num2str(dft.salvat.(models{imodel}){1}.neR2(i)),']'],...
                ['Salvat et al. (2 exp), [\chi^2/N = ',num2str(dft.salvat.(models{imodel}){2}.neR2(i)),']'],...
                ['Salvat et al. (3 exp), [\chi^2/N = ',num2str(dft.salvat.(models{imodel}){3}.neR2(i)),']'],...
                ['Moliere (Thomas-Fermi), [\chi^2/N = ',num2str(neR2_thomas_fermi_moliere),']']};
            %
            tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{s,0} = ',int2str(dft.Z0(i)),'), Salvat-Moliere DHFS (Gaussian)'];
            tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{s,0} = ',int2str(dft.Z0(i)),'), Salvat-Moliere DHFS (Gaussian)'];
            %
            figure('Name',tit1);
            graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
            graph1D_jd(dft.salvat.(models{imodel}){1}.r,dft.salvat.(models{imodel}){1}.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
            graph1D_jd(dft.salvat.(models{imodel}){2}.r,dft.salvat.(models{imodel}){2}.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{3},'none',linecolor{3},2,siz,gca); 
            graph1D_jd(dft.salvat.(models{imodel}){3}.r,dft.salvat.(models{imodel}){3}.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{4},'none',linecolor{4},2,siz,gca); 
            graph1D_jd(dft.r,xdens_thomas_fermi_moliere,0,1,xlab,ylab1,tit1,leg,'','',linestyle{5},'none',linecolor{5},2,siz,gca); 
            axis([0,dft.ionradius{1}.r0n(i),1e-5,1e5])
            drawnow
            print_jd(print_opt,['Density_MoliereSalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
            %
            figure('Name',tit2);
            graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
            graph1D_jd(dft.salvat.(models{imodel}){1}.r,4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
            graph1D_jd(dft.salvat.(models{imodel}){2}.r,4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{3},'none',linecolor{3},2,siz,gca); 
            graph1D_jd(dft.salvat.(models{imodel}){3}.r,4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{4},'none',linecolor{4},2,siz,gca); 
            graph1D_jd(dft.r,4*pi.*dft.r.*dft.r.*xdens_thomas_fermi_moliere,0,0,xlab,ylab2,tit1,leg,'','',linestyle{5},'none',linecolor{5},2,siz,gca); 
            xlim([0,dft.ionradius{1}.r0n(i)])
            drawnow
            print_jd(print_opt,['Lineicdensity_MoliereSalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
            %
            i = dft.Z;%partially ionized atom 
            %
            imodel = 1;%Gaussian
            %
            leg = {'DHFS (Gaussian code)',...
                ['Salvat et al. (1 exp), [\chi^2/N = ',num2str(dft.salvat.(models{imodel}){1}.neR2(i)),']'],...
                ['Salvat et al. (2 exp), [\chi^2/N = ',num2str(dft.salvat.(models{imodel}){2}.neR2(i)),']'],...
                ['Salvat et al. (3 exp), [\chi^2/N = ',num2str(dft.salvat.(models{imodel}){3}.neR2(i)),']']};
            %
            tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{0,s} = ',int2str(dft.Z0(i)),'), Salvat-Moliere DHFS (Gaussian)'];
            tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{0,s} = ',int2str(dft.Z0(i)),'), Salvat-Moliere DHFS (Gaussian)'];
            %
            figure('Name',tit1);
            graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
            graph1D_jd(dft.salvat.(models{imodel}){1}.r,dft.salvat.(models{imodel}){1}.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
            graph1D_jd(dft.salvat.(models{imodel}){2}.r,dft.salvat.(models{imodel}){2}.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{3},'none',linecolor{3},2,siz,gca); 
            graph1D_jd(dft.salvat.(models{imodel}){3}.r,dft.salvat.(models{imodel}){3}.ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca); 
            axis([0,dft.ionradius{1}.r0n(1)/4,1e-7,1e5])
            drawnow
            print_jd(print_opt,['Density_MoliereSalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
            %
            figure('Name',tit2);
            graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
            graph1D_jd(dft.salvat.(models{imodel}){1}.r,4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
            graph1D_jd(dft.salvat.(models{imodel}){2}.r,4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{3},'none',linecolor{3},2,siz,gca); 
            graph1D_jd(dft.salvat.(models{imodel}){3}.r,4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i),0,0,xlab,ylab2,tit2,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca); 
            xlim([0,dft.ionradius{1}.r0n(i)*3])
            drawnow
            print_jd(print_opt,['Lineicdensity_MoliereSalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
            %
            kk = 1;
            imodel = 1;%Gaussian
            %
            disp('Salvat et al. moments values')
            disp('-----------------------------------------------------------------------------------')
            disp('-----------------------------------------------------------------------------------')
            disp('   Z0s_{fit}  checksum     A1     lambda1 lambda1(N_s)/lambda1(0)^2')
            disp('-----------------------------------------------------------------------------------')
            disp('-----------------------------------------------------------------------------------')
            %
            disp([dft.Z-dft.salvat.(models{imodel}){kk}.Nfit',dft.salvat.(models{imodel}){kk}.checksum',dft.salvat.(models{imodel}){kk}.A,dft.salvat.(models{imodel}){kk}.alpha,(dft.salvat.(models{imodel}){kk}.alpha./dft.salvat.(models{imodel}){kk}.alpha(1,:)).^2])
            %
            figure('Name',['Salvat - DHFS (Gaussian)']);
            %
            ns = dft.Z*(1/3-0.002*dft.Z);
            x = dft.Z0/dft.Z;
            y_kir = (1./(1 - x)).^(4/3);
            y_al = (1 - x.^(ns+1))./(1-x);
            y_al_mod = (1 - x.^(ns+1))./(1-x).^1.5;
            %
            xlab3 = 'Z_{0,s}/Z_s';
            ylab3 = '\lambda^2_{Z_{0,s}}/\lambda^2_{0,s}';
            tit3 = [[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),')'];
            leg3 = {'DHFS-Salvat (Gaussian code) (1 exp.)','Kirillov et al. model (1975)','Avdonina - Pratt model (1989)','Avdonina - Pratt - Peysson model (2019)'};
            %
            graph1D_jd((dft.Z-dft.salvat.(models{imodel}){1}.Nfit')/dft.Z,(dft.salvat.(models{imodel}){1}.alpha./dft.salvat.(models{imodel}){1}.alpha(1,:)).^2,0,1,xlab3,ylab3,tit3,'','','','none',marker{1},linecolor{1},2,siz,gca);hold on
            graph1D_jd(x,y_kir,0,1,xlab3,ylab3,tit3,'','','',linestyle{2},'none',linecolor{2},2,siz,gca);hold on
            graph1D_jd(x,y_al,0,1,xlab3,ylab3,tit3,'','','',linestyle{3},'none',linecolor{3},2,siz,gca);hold on
            graph1D_jd(x,y_al_mod,0,1,xlab3,ylab3,tit3,leg3,'','',linestyle{4},'none',linecolor{4},2,siz,gca);  
            %
            drawnow
            print_jd(print_opt,['Salvat - models for ions ',[upper(dft.name(1)), lower(dft.name(2:end))]],'./Figs',get(gcf,'Number'))
            %
            disp('-----------------------------------------------------------------------------------')
            disp('-----------------------------------------------------------------------------------')
            disp('   Z0s_{fit}  checksum      A1       A2     lambda1   lambda2  ')
            disp('-----------------------------------------------------------------------------------')
            disp('-----------------------------------------------------------------------------------')
            %
            imodel = 1;%Gaussian
            disp([dft.Z-dft.salvat.(models{imodel}){2}.Nfit',dft.salvat.(models{imodel}){2}.checksum',dft.salvat.(models{imodel}){2}.A,dft.salvat.(models{imodel}){2}.alpha])
            %
            disp('-----------------------------------------------------------------------------------')
            disp('-----------------------------------------------------------------------------------')
            disp('   Z0s_{fit}  checksum      A1       A2        A3     lambda1   lambda2   lambda3')
            disp('-----------------------------------------------------------------------------------')
            disp('-----------------------------------------------------------------------------------')
            %
            imodel = 1;%Gaussian
            disp([dft.Z-dft.salvat.(models{imodel}){3}.Nfit',dft.salvat.(models{1}){3}.checksum',dft.salvat.(models{1}){3}.A,dft.salvat.(models{1}){3}.alpha])
            %
            % Data saving
            %
            if flag_salvat == 1
                %
                answer_replace_salvat = input_dke_yp('Would you like to replace and save the existing salvat substructure in the dft structure ? (0 : no, 1 : yes)',0);
                %
                if answer_replace_salvat == 1
                    %
                    save(['DFT/dft_',int2str(Z),'_',elements('atomic_number', Z, 'symbol'),'_',elements('atomic_number', Z, 'name'),'.mat'],'dft');
                    %
                end
                %
            else
                %
                answer_save_salvat = input_dke_yp('Would you save the existing salvat substructure in the dft structure ? (0 : no, 1 : yes)',0);
                %
                if answer_save_salvat == 1
                    %
                    save(['DFT/dft_',int2str(Z),'_',elements('atomic_number', Z, 'symbol'),'_',elements('atomic_number', Z, 'name'),'.mat'],'dft');
                    %
                end
                %
            end
            %
        end
        %
    else
        %
        disp(['WARNING : Input file : ',filename,' does not exist.'])
        %
    end  
    %
end





