%
% Test Salvat (Moliere) method for any atomic electron density whatever the ionization state. 
% Modify the initial dft structure and save it. Two examples are considered : Gaussian DFT and Thomas-Fermi model.
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
close all 
clear all
clc
%
print_opt = -1;%-1: no print, 2:save files (eps,png,fig)
%
maxnumberofexponentials = 4;%up to 4
%
Z = [1,2,3,4,5,6,7,8,10,13,14,17,18,24,26,28,29,32,36,54,74,79];%Atomic number (If multiple Z values, dft change only, no display)
Z = 18;%[18];%change dft substructure field salvat, and display results
Z0 = 0;%40;%[17];%fully (0) or partially ionized atom for display
%
atomic_models = [0];%[0 -> Gaussian DFT,1 -> Thomas-Fermi]
units = 'mec';%'mec' or 'MeV/c' for the form factor
%
if strcmp(units,'mec')
    %
    unitfactor = 1;
    xlabff = 'q/(m_{e}c)';
    %
elseif strcmp(units,'MeV/c')
    %
    unitfactor = 1.627;
    xlabff = 'q/(MeV/c)';
    %
end
%
[~,~,~,~,~,~,re,mc2,~,alpha] = pc_dke_yp;%Physics constant
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
            dft = rmfield(dft,'salvat');
            disp(['WARNING : a ''salvat'' substructure already exists in the ''dft'' structure for ',elements('atomic_number', Z(iZ), 'name'),', ',elements('atomic_number', Z(iZ), 'symbol'),' (Z = ',int2str(Z(iZ)),').'])
            %
            flag_salvat = 1;
            %
        else
            %
            flag_salvat = 0;
            %
        end
        %
        [dft] = salvat(dft,atomic_models,maxnumberofexponentials);%add results of Salvat method to dft structure for model [0 -> Gaussian DFT,1 -> Thomas-Fermi]
        %
        if length(Z) > 1
            %
            save(filename,'dft');
            disp(['---> the ''salvat'' substructure in the ''dft'' structure for ',elements('atomic_number', Z(iZ), 'name'),', ',elements('atomic_number', Z(iZ), 'symbol'),' (Z = ',int2str(Z(iZ)),') has been updated and saved.'])
            %
        else
            %
            [q,ff_dhfs,ff_sal] = form_factor_salvat(dft);%form factor calculations
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
            a_mol1_bar = 2/lambda1/alpha;
            a_mol2_bar = 2/lambda2/alpha;
            a_mol3_bar = 2/lambda3/alpha;
            %
            nq = 1000;
            q = logspace(-4,1,nq);%normalized momentum
            %
            ff_mol = A1*formfactor_yp(a_mol1_bar,q,Z,2) + A2*formfactor_yp(a_mol2_bar,q,Z,2) + A3*formfactor_yp(a_mol3_bar,q,Z,2);
            %
            xdens_thomas_fermi_moliere_4pir = Z*(A1*lambda1*lambda1*exp(-lambda1.*dft.r) + A2*lambda2*lambda2*exp(-lambda2.*dft.r) + A3*lambda3*lambda3*exp(-lambda3.*dft.r));
            xdens_thomas_fermi_moliere = xdens_thomas_fermi_moliere_4pir./dft.r/4/pi;
            xdens_thomas_fermi_moliere(1) = xdens_thomas_fermi_moliere(2);%avoid Inf value
            neR2_thomas_fermi_moliere = sum((xdens_thomas_fermi_moliere(:) - dft.ne(:,i)).^2)/length(dft.ne(:,i));
            %
            imodel = 1;%Gaussian
            %
            leg0 = {'DFT (Gaussian)',...
                ['Salvat-DFT-Gaussian (1 exp.)'],...
                ['Salvat-DFT-Gaussian (2 exp.)'],...
                ['Salvat-DFT-Gaussian (3 exp.)'],...
                ['Moliere-Thomas-Fermi (3 exp.)']};
            %
            tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{s,0} = ',int2str(dft.Z0(i)),'), Moliere-TF Salvat-DFT-Gaussian'];
            tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{s,0} = ',int2str(dft.Z0(i)),'), Moliere-TF Salvat-DFT-Gaussian'];
            %
            figure('Name',tit1);
            graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
            leg = leg0([1,2,5]);
            graph1D_jd(dft.salvat.(models{imodel}){1}.r,dft.salvat.(models{imodel}){1}.ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
            if maxnumberofexponentials >1
                leg = leg0([1,2,3,5]);
                graph1D_jd(dft.salvat.(models{imodel}){2}.r,dft.salvat.(models{imodel}){2}.ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
            end
            if maxnumberofexponentials >2
                leg = leg0([1,2,3,4,5]);
                graph1D_jd(dft.salvat.(models{imodel}){3}.r,dft.salvat.(models{imodel}){3}.ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca); 
            end
            graph1D_jd(dft.r,xdens_thomas_fermi_moliere,0,1,xlab,ylab1,tit1,leg,'','',linestyle{5},'none',linecolor{5},2,siz,gca); 
            axis([0,dft.ionradius{1}.r0n(i),1e-4,1e5])
            drawnow
            %
            print_jd(print_opt,['Density_MoliereSalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
            %
            figure('Name',tit2);
            graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
            leg = leg0([1,2,5]);
            graph1D_jd(dft.salvat.(models{imodel}){1}.r,4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
            if maxnumberofexponentials >1
                leg = leg0([1,2,3,5]);
                graph1D_jd(dft.salvat.(models{imodel}){2}.r,4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{3},'none',linecolor{3},2,siz,gca); 
            end
            if maxnumberofexponentials >2
                leg = leg0([1,2,3,4,5]);
                graph1D_jd(dft.salvat.(models{imodel}){3}.r,4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{4},'none',linecolor{4},2,siz,gca); 
            end
            graph1D_jd(dft.r,4*pi.*dft.r.*dft.r.*xdens_thomas_fermi_moliere,0,0,xlab,ylab2,tit1,leg,'','',linestyle{5},'none',linecolor{5},2,siz,gca); 
            %
            if maxnumberofexponentials == 1
                maxdens = max(max([4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i)]));
            elseif maxnumberofexponentials == 2
                maxdens = max(max([4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i)]));
            elseif maxnumberofexponentials == 3
                maxdens = max(max([4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i),4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i)]));
            elseif maxnumberofexponentials == 4
                maxdens = max(max([4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i),4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i),4*pi*dft.salvat.(models{imodel}){4}.r.*dft.salvat.(models{imodel}){4}.r.*dft.salvat.(models{imodel}){4}.ne(:,i)]));
            end
            %
            maxdens = max(maxdens,max(dft.ne(:,1)*4*pi.*dft.r.*dft.r));
            %
            ylim([0,maxdens]);
            xlim([0,dft.ionradius{1}.r0n(i)*0.7]);
            drawnow
            %
            print_jd(print_opt,['Lineicdensity_MoliereSalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
            %
            tit3 = ['Atomic form factor, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{s,0} = ',int2str(dft.Z0(i)),'), Moliere-TF Salvat-DFT-Gaussian'];
            figure('Name',tit3);
            ylab = 'Atomic form factor';
            siz = 20+14i;
            %
            leg0 = {'DFT-Gaussian',['Salvat-DFT-Gaussian (1 exp.)'],['Salvat-DFT-Gaussian (2 exp.)'],['Salvat-DFT-Gaussian (3 exp.)'],['Moliere-Thomas-Fermi (3 exp.)']};
            %
            graph1D_jd(q/unitfactor,ff_dhfs(i,:),1,0,xlabff,ylab,tit3,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);
            leg = leg0([1,2,5]);
            graph1D_jd(q/unitfactor,ff_sal{1}(i,:),1,0,xlabff,ylab,tit3,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
            if maxnumberofexponentials > 1
                leg = leg0([1,2,3,5]);
                graph1D_jd(q/unitfactor,ff_sal{2}(i,:),1,0,xlabff,ylab,tit3,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
            end
            if maxnumberofexponentials > 2
                leg = leg0([1,2,3,4,5]);
                graph1D_jd(q/unitfactor,ff_sal{3}(i,:),1,0,xlabff,ylab,tit3,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca);
            end
            graph1D_jd(q/unitfactor,ff_mol,1,0,xlabff,ylab,tit3,leg,'','',linestyle{5},'none',linecolor{5},2,siz,gca);
            xlim([1e-4,10])
            ylim([0,dft.N(i)])
            %
            drawnow
            %
            print_jd(print_opt,['Atomicformfactor_MoliereSalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
            %
            if Z == 74
                %
                % Salvat DHFS model for comparison with DFT (F. Salvat and J. D. Martinez and R. Mayol and J. Parellada, Analytical Dirac-Hartree-Fock-Slater screening function for atoms (Z = 1-92), Phys. Rev. A, 1987, 36, 2, pp. 467-474)
                %
                A_salvat_DHFS1 = 0.15;
                A_salvat_DHFS2 = 0.6871;
                A_salvat_DHFS3 = 0.1629;
                %
                lambda_salvat_DHFS1 = 28.6330;
                lambda_salvat_DHFS2 = 4.2426;
                lambda_salvat_DHFS3 = 1.2340;
                %
                a_salvat_DHFS1_bar = 2/lambda_salvat_DHFS1/alpha;
                a_salvat_DHFS2_bar = 2/lambda_salvat_DHFS2/alpha;
                a_salvat_DHFS3_bar = 2/lambda_salvat_DHFS3/alpha;
                %
                nq = 1000;
                q = logspace(-4,1,nq);%normalized momentum
                %
                ff_salvat_DHFS = A_salvat_DHFS1*formfactor_yp(a_salvat_DHFS1_bar,q,Z,2) + A_salvat_DHFS2*formfactor_yp(a_salvat_DHFS2_bar,q,Z,2) + A_salvat_DHFS3*formfactor_yp(a_salvat_DHFS3_bar,q,Z,2);
                %
                xdens_salvat_DHFS_4pir = Z*(A_salvat_DHFS1*lambda1*lambda_salvat_DHFS1*exp(-lambda_salvat_DHFS1.*dft.r) + A_salvat_DHFS2*lambda_salvat_DHFS2*lambda_salvat_DHFS2*exp(-lambda_salvat_DHFS2.*dft.r) + A_salvat_DHFS3*lambda_salvat_DHFS3*lambda_salvat_DHFS3*exp(-lambda_salvat_DHFS3.*dft.r));
                xdens_salvat_DHFS = xdens_salvat_DHFS_4pir./dft.r/4/pi;
                xdens_salvat_DHFS(1) = xdens_salvat_DHFS(2);%avoid Inf value
                neR2_salvat_DHFS = sum((xdens_salvat_DHFS(:) - dft.ne(:,i)).^2)/length(dft.ne(:,i));
                %
                tit4 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{s,0} = ',int2str(dft.Z0(i)),'), Salvat DHFS - DFT (Gaussian)'];
                tit5 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{s,0} = ',int2str(dft.Z0(i)),'), Salvat DHFS - DFT (Gaussian)'];
                %
                leg = {'DFT-Gaussian','Salvat-DFT-Gaussian (3 exp.)', 'Salvat-DHFS (3 exp.)'};
                %
                figure('Name',tit4);
                graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit4,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
                graph1D_jd(dft.salvat.(models{imodel}){3}.r,dft.salvat.(models{imodel}){3}.ne(:,i),0,1,xlab,ylab1,tit4,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
                graph1D_jd(dft.r,xdens_salvat_DHFS,0,1,xlab,ylab1,tit4,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
                axis([0,dft.ionradius{1}.r0n(i),1e-4,1e5])
                drawnow
                %
                print_jd(print_opt,['Density_DHFS_DFT_Gaussian_Salvat_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
                %
                figure('Name',tit5);
                graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit5,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
                graph1D_jd(dft.salvat.(models{imodel}){3}.r,4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i),0,0,xlab,ylab2,tit5,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
                graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*xdens_salvat_DHFS,0,0,xlab,ylab2,tit5,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
                %
                maxdens = max(max([4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i),4*pi*dft.r.*dft.r.*xdens_salvat_DHFS]));
                ylim([0,maxdens]);
                xlim([0,dft.ionradius{1}.r0n(i)*0.7]);
                drawnow
                %
                print_jd(print_opt,['Lineicdensity_DHFS_DFT_Gaussian_Salvat_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
                %
                tit6 = ['Atomic form factor, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{s,0} = ',int2str(dft.Z0(i)),')'];
                figure('Name',tit6);
                ylab = 'Atomic form factor';
                siz = 20+14i;
                %
                graph1D_jd(q/unitfactor,ff_dhfs(i,:),1,0,xlabff,ylab,tit6,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);
                graph1D_jd(q/unitfactor,ff_sal{3}(i,:),1,0,xlabff,ylab,tit6,'','','',linestyle{2},'none',linecolor{2},2,siz,gca);
                graph1D_jd(q/unitfactor,ff_salvat_DHFS(i,:),1,0,xlabff,ylab,tit6,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca);
                %
                %graph1D_jd(q/unitfactor,ff_sal{1}(i,:),1,0,xlabff,ylab,tit3,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
                %graph1D_jd(q/unitfactor,ff_sal{2}(i,:),1,0,xlabff,ylab,tit3,'','','',linestyle{3},'none',linecolor{3},2,siz,gca); 
                %graph1D_jd(q/unitfactor,ff_sal{3}(i,:),1,0,xlabff,ylab,tit3,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca);
                %
                xlim([1e-4,10])
                ylim([0,dft.N(i)])
                %
                drawnow
                print_jd(print_opt,['Atomicformfactor_DHFS_DFT_Gaussian_Salvat_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
                %
            end
            %
            %---------------------------------------------------------------------------------------------------
            %
            i = Z0+1;%partially ionized atom 
            %
            if i > 1
                %
                imodel = 1;%Gaussian
                %
                if length(dft.salvat.(models{imodel})) > 3 && dft.salvat.(models{imodel}){4}.alpha(i,4) > 0
                    %
                    leg0 = {'DFT-Gaussian',...
                        ['Salvat-DFT-Gaussian (1 exp.)'],...
                        ['Salvat-DFT-Gaussian (2 exp.)'],...
                        ['Salvat-DFT-Gaussian (3 exp.)'],...
                        ['Salvat-DFT-Gaussian (4 exp.)']};
                    %
                else
                    %
                    leg0 = {'DFT-Gaussian',...
                        ['Salvat-DFT-Gaussian (1 exp.)'],...
                        ['Salvat-DFT-Gaussian (2 exp.)'],...
                        ['Salvat-DFT-Gaussian (3 exp.)']};
                    %
                end
                %
                tit7 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{0,s} = ',int2str(dft.Z0(i)),'), Salvat-DFT (Gaussian)'];
                tit8 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{0,s} = ',int2str(dft.Z0(i)),'), Salvat-DFT (Gaussian)'];
                %
                figure('Name',tit7);
                graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
                leg = leg0([1,2]);
                graph1D_jd(dft.salvat.(models{imodel}){1}.r,dft.salvat.(models{imodel}){1}.ne(:,i),0,1,xlab,ylab1,tit7,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
                if maxnumberofexponentials > 1
                    leg = leg0([1,2,3]);
                    graph1D_jd(dft.salvat.(models{imodel}){2}.r,dft.salvat.(models{imodel}){2}.ne(:,i),0,1,xlab,ylab1,tit7,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
                end
                if maxnumberofexponentials > 2
                  leg = leg0([1,2,3,4]);
                  graph1D_jd(dft.salvat.(models{imodel}){3}.r,dft.salvat.(models{imodel}){3}.ne(:,i),0,1,xlab,ylab1,tit7,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca); 
                end
                %
                if maxnumberofexponentials > 3 && length(dft.salvat.(models{imodel})) > 3 && dft.salvat.(models{imodel}){4}.alpha(i,4) > 0
                    %
                    leg = leg0;
                    graph1D_jd(dft.salvat.(models{imodel}){4}.r,dft.salvat.(models{imodel}){4}.ne(:,i),0,1,xlab,ylab1,tit7,leg,'','',linestyle{5},'none',linecolor{5},2,siz,gca); 
                    %
                end
                %
                axis([0,dft.ionradius{1}.r0n(1)/4,1e-4,1e5])
                drawnow
                %
                print_jd(print_opt,['Density_SalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
                %
                figure('Name',tit8);
                %
                graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
                leg = leg0([1,2]);
                graph1D_jd(dft.salvat.(models{imodel}){1}.r,4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),0,0,xlab,ylab2,tit8,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
                if maxnumberofexponentials >1
                    leg = leg0([1,2,3]);
                    graph1D_jd(dft.salvat.(models{imodel}){2}.r,4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i),0,0,xlab,ylab2,tit8,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
                end
                if maxnumberofexponentials > 2
                    leg = leg0([1,2,3,4]);
                    graph1D_jd(dft.salvat.(models{imodel}){3}.r,4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i),0,0,xlab,ylab2,tit8,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca); 
                %
                end
                if maxnumberofexponentials > 3 && length(dft.salvat.(models{imodel})) > 3 && dft.salvat.(models{imodel}){4}.alpha(i,4) > 0
                    %
                    leg = leg0;
                    graph1D_jd(dft.salvat.(models{imodel}){4}.r,4*pi*dft.salvat.(models{imodel}){4}.r.*dft.salvat.(models{imodel}){4}.r.*dft.salvat.(models{imodel}){4}.ne(:,i),0,0,xlab,ylab2,tit8,leg,'','',linestyle{5},'none',linecolor{5},2,siz,gca); 
                    %
                end
                %
                if maxnumberofexponentials > 3 && length(dft.salvat.(models{imodel})) > 3 && dft.salvat.(models{imodel}){4}.alpha(i,4) > 0
                    %
                    maxdens = max(max([4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),...
                        4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i),...
                        4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i),...
                        4*pi*dft.salvat.(models{imodel}){4}.r.*dft.salvat.(models{imodel}){4}.r.*dft.salvat.(models{imodel}){4}.ne(:,i),...
                        ]));
                    %
                elseif maxnumberofexponentials > 2
                    %
                    maxdens = max(max([4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),...
                        4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i),...
                        4*pi*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.r.*dft.salvat.(models{imodel}){3}.ne(:,i),...
                        ]));
                elseif maxnumberofexponentials > 1
                    %
                    maxdens = max(max([4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),...
                        4*pi*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.r.*dft.salvat.(models{imodel}){2}.ne(:,i),...
                        ]));
                    %
                else
                    %
                    maxdens = max(max([4*pi*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.r.*dft.salvat.(models{imodel}){1}.ne(:,i),...
                        ]));
                    %
                    %
                end
                %
                maxdens = max(maxdens,max(dft.ne(:,i)*4*pi.*dft.r.*dft.r));
                %
                ylim([0,maxdens]);
                xlim([0,dft.ionradius{1}.r0n(i)*3])
                drawnow
                print_jd(print_opt,['Lineicdensity_SalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
                %
            end
            %
            kk = 1;
            imodel = 1;%Gaussian
            %
            disp('Salvat et al. moments values')
            disp('-------------------------------------------------------------------------------------------------')
            disp('-------------------------------------------------------------------------------------------------')
            disp('   Z0s_{fit}  checksum     A1     lambda1 lambda1(N_s)/lambda1(0)^2')
            disp('-------------------------------------------------------------------------------------------------')
            disp('-------------------------------------------------------------------------------------------------')
            %
            disp([dft.Z-dft.salvat.(models{imodel}){kk}.Nfit',dft.salvat.(models{imodel}){kk}.checksum',dft.salvat.(models{imodel}){kk}.A,dft.salvat.(models{imodel}){kk}.alpha,(dft.salvat.(models{imodel}){kk}.alpha./dft.salvat.(models{imodel}){kk}.alpha(1,:)).^2])
            %
            figure('Name','Salvat-DFT (Gaussian)');
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
            leg3 = {'Salvat-DFT-Gaussian (1 exp.)','Thomas-Fermi-Kirillov','Avdonina-Pratt','Avdonina-Pratt-Peysson'};
            %
            graph1D_jd((dft.Z-dft.salvat.(models{imodel}){1}.Nfit')/dft.Z,(dft.salvat.(models{imodel}){1}.alpha./dft.salvat.(models{imodel}){1}.alpha(1,:)).^2,0,1,xlab3,ylab3,tit3,'','','','none',marker{1},linecolor{1},2,siz,gca);hold on
            graph1D_jd(x,y_kir,0,1,xlab3,ylab3,tit3,'','','',linestyle{2},'none',linecolor{2},2,siz,gca);hold on
            graph1D_jd(x,y_al,0,1,xlab3,ylab3,tit3,'','','',linestyle{3},'none',linecolor{3},2,siz,gca);hold on
            graph1D_jd(x,y_al_mod,0,1,xlab3,ylab3,tit3,leg3,'','',linestyle{4},'none',linecolor{4},2,siz,gca);  
            %
            drawnow
            %
            print_jd(print_opt,['Salvat_models_for_ionization_state',[upper(dft.name(1)), lower(dft.name(2:end))]],'./Figs',get(gcf,'Number'))
            %
            tit9 = ['Atomic form factor, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z),', Z_{s,0} = ',int2str(dft.Z0(i)),'), Salvat-DFT (Gaussian)'];
            figure('Name',tit9);
            ylab = 'Atomic form factor';
            siz = 20+14i;
            %
            leg0 = {'DFT-Gaussian',['Salvat-DFT-Gaussian (1 exp.)'],['Salvat-DFT-Gaussian (2 exp.)'],['Salvat-DFT-Gaussian (3 exp.)'],['Salvat-DFT-Gaussian (4 exp.)']};
            %
            graph1D_jd(q/unitfactor,ff_dhfs(i,:),1,0,xlabff,ylab,tit9,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);
            leg = leg0([1,2]);
            graph1D_jd(q/unitfactor,ff_sal{1}(i,:),1,0,xlabff,ylab,tit9,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
            if maxnumberofexponentials > 1
                    leg = leg0([1,2,3]);
                    graph1D_jd(q/unitfactor,ff_sal{2}(i,:),1,0,xlabff,ylab,tit9,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca);
            end
            if maxnumberofexponentials > 2
                    leg = leg0([1,2,3,4]);
                    graph1D_jd(q/unitfactor,ff_sal{3}(i,:),1,0,xlabff,ylab,tit9,leg,'','',linestyle{4},'none',linecolor{4},2,siz,gca);
            end
            %
            if maxnumberofexponentials > 3 && length(dft.salvat.(models{imodel})) > 3 && dft.salvat.(models{imodel}){4}.alpha(i,4) > 0
                %
                leg = leg0;
                graph1D_jd(q/unitfactor,ff_sal{4}(i,:),1,0,xlabff,ylab,tit9,leg,'','',linestyle{5},'none',linecolor{5},2,siz,gca);
                %
            end
            %
            xlim([1e-4,10])
            ylim([0,dft.N(i)])
            %
            drawnow
            %
            print_jd(print_opt,['Atomicformfactor_SalvatGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
            %
            if maxnumberofexponentials > 1
                disp('-------------------------------------------------------------------------------------------------')
                disp('-------------------------------------------------------------------------------------------------')
                disp('   Z0s_{fit}  checksum      A1       A2     lambda1   lambda2  ')
                disp('-------------------------------------------------------------------------------------------------')
                disp('-------------------------------------------------------------------------------------------------')
                %
                imodel = 1;%Gaussian
                disp([dft.Z-dft.salvat.(models{imodel}){2}.Nfit',dft.salvat.(models{imodel}){2}.checksum',dft.salvat.(models{imodel}){2}.A,dft.salvat.(models{imodel}){2}.alpha])
            end
            %
            if maxnumberofexponentials > 2
                disp('-------------------------------------------------------------------------------------------------')
                disp('-------------------------------------------------------------------------------------------------')
                disp('   Z0s_{fit}  checksum      A1       A2        A3     lambda1   lambda2   lambda3')
                disp('-------------------------------------------------------------------------------------------------')
                disp('-------------------------------------------------------------------------------------------------')
                %
                imodel = 1;%Gaussian
                disp([dft.Z-dft.salvat.(models{imodel}){3}.Nfit',dft.salvat.(models{1}){3}.checksum',dft.salvat.(models{1}){3}.A,dft.salvat.(models{1}){3}.alpha])
            end
            %
            if length(dft.salvat.(models{imodel})) > 3
                %
                disp('-------------------------------------------------------------------------------------------------')
                disp('-------------------------------------------------------------------------------------------------')
                disp('   Z0s_{fit}  checksum      A1       A2        A3     A4    lambda1   lambda2   lambda3   lambda4')
                disp('-------------------------------------------------------------------------------------------------')
                disp('-------------------------------------------------------------------------------------------------')
                %
                imodel = 1;%Gaussian
                disp([dft.Z-dft.salvat.(models{imodel}){4}.Nfit',dft.salvat.(models{1}){4}.checksum',dft.salvat.(models{1}){4}.A,dft.salvat.(models{1}){4}.alpha])
                %
            end
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





