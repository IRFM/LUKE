%
% Test Moliere's fit of any atomic electron density whatever the ionization state. 
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
Z = 74;%Atomic number 
%
Nexp = 3;%number of exponentials to fit the charge density
atomic_models = [0,1];%[0 -> Gaussian DFT,1 -> Thomas-Fermi]
Zindex = [1,8,25,45,56];%Zs for a global display (< Z)
%
load(['DFT/dft_',int2str(Z),'_',elements('atomic_number', Z, 'symbol'),'_',elements('atomic_number', Z, 'name'),'.mat'])
%
if isfield(dft,'moliere')
    %
    disp('WARNING : a moliere substructure already exists in the dft structure.')
    flag_moliere = 1;
    %
else
    %
    flag_moliere = 0;
    %
end
%
[dft] = moliere(dft,atomic_models,Nexp);%add Moliere's results to dft structure for model [0 -> Gaussian DFT,1 -> Thomas-Fermi]
%
models = fieldnames(dft.moliere);
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
leg = {'HFS (Gaussian code)','Moliere'};
%leg = {'HFS (Gaussian code)','Moliere','Thomas-Fermi'};
%
i = 1;%neutral atom
%
tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moments - HFS (Gaussian)'];
tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moments - HFS (Gaussian)'];
%
figure('Name',tit1);
graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.(models{1}).r,dft.moliere.(models{1}).ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
%graph1D_jd(dft.moliere.(models{2}).r,dft.moliere.(models{2}).ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
axis([0,dft.ionradius{1}.r0n(i),1e-5,1e5])
drawnow
print_jd(print_opt,['Density_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure('Name',tit2);
graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.(models{1}).r,4*pi*dft.moliere.(models{1}).r.*dft.moliere.(models{1}).r.*dft.moliere.(models{1}).ne(:,i),0,0,xlab,ylab2,tit2,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
%graph1D_jd(dft.moliere.(models{2}).r,4*pi*dft.moliere.(models{2}).r.*dft.moliere.(models{2}).r.*dft.moliere.(models{2}).ne(:,i),0,0,xlab,ylab2,tit2,leg,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
xlim([0,dft.ionradius{1}.r0n(i)])
drawnow
print_jd(print_opt,['Lineicdensity_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moments - Thomas-Fermi'];
tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moments - Thomas-Fermi'];
leg1 = {'Thomas-Fermi','Moments','Moliere'};
%
B1 = 0.1;%Moliere's value for the Thomas-Fermi model
B2 = 0.55;%Moliere's value for the Thomas-Fermi model
B3 = 0.35;%Moliere's value for the Thomas-Fermi model
beta1 = 6.0;%Moliere's value for the Thomas-Fermi model
beta2 = 1.2;%Moliere's value for the Thomas-Fermi model
beta3 = 0.3;%Moliere's value for the Thomas-Fermi model
%
A1 = B1*Z*0.885^3;%Argon
A2 = B2*Z*0.885^3;%Argon
A3 = B3*Z*0.885^3;%Argon
lambda1 = beta1*Z^(1/3)/0.885;%Argon
lambda2 = beta2*Z^(1/3)/0.885;%Argon
lambda3 = beta3*Z^(1/3)/0.885;%Argon
%
xdens_thomas_fermi_moliere_4pir = A1*lambda1*lambda1*exp(-lambda1.*dft.r) + A2*lambda2*lambda2*exp(-lambda2.*dft.r) + A3*lambda3*lambda3*exp(-lambda3.*dft.r);
xdens_thomas_fermi_moliere = xdens_thomas_fermi_moliere_4pir./dft.r/4/pi;
%
figure('Name',tit1);
graph1D_jd(dft.ionradius{1}.rn{1},dft.ionradius{1}.dens{1},0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.(models{2}).r,dft.moliere.(models{2}).ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
graph1D_jd(dft.r,xdens_thomas_fermi_moliere,0,1,xlab,ylab1,tit1,leg1,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
axis([0,dft.ionradius{1}.r0n(i),1e-5,1e5])
drawnow
print_jd(print_opt,['TF_Density_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure('Name',tit2);
graph1D_jd(dft.ionradius{1}.rn{1},4*pi*dft.ionradius{1}.rn{1}.*dft.ionradius{1}.rn{1}.*dft.ionradius{1}.dens{1},0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.(models{2}).r,4*pi*dft.moliere.(models{2}).r.*dft.moliere.(models{2}).r.*dft.moliere.(models{2}).ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{2},'none',linecolor{2},2,siz,gca); 
graph1D_jd(dft.r,4*pi.*dft.r.*dft.r.*xdens_thomas_fermi_moliere,0,0,xlab,ylab1,tit1,leg1,'','',linestyle{3},'none',linecolor{3},2,siz,gca); 
xlim([0,dft.ionradius{1}.r0n(i)])
drawnow
print_jd(print_opt,['TF_Lineicdensity_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
i = round(dft.Z/2)-1;%partially ionized atom 
%
tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moments - HFS (Gaussian)'];
tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moments - HFS (Gaussian)'];
%
figure('Name',tit1);
graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.(models{1}).r,dft.moliere.(models{1}).ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
axis([0,dft.ionradius{1}.r0n(i),1e-5,1e5])
drawnow
print_jd(print_opt,['Density_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure('Name',tit2);
graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.(models{1}).r,4*pi*dft.moliere.(models{1}).r.*dft.moliere.(models{1}).r.*dft.moliere.(models{1}).ne(:,i),0,0,xlab,ylab2,tit2,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
xlim([0,dft.ionradius{1}.r0n(i)])
drawnow
print_jd(print_opt,['Lineicdensity_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
print_jd(print_opt,['MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
i = dft.Z;%partially ionized atom 
%
tit1 = ['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moments - HFS (Gaussian)'];
tit2 = ['Lineic density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),', Z_0 = ',int2str(dft.Z0(i)),'), Moments - HFS (Gaussian)'];
%
figure('Name',tit1);
graph1D_jd(dft.r,dft.ne(:,i),0,1,xlab,ylab1,tit1,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.(models{1}).r,dft.moliere.(models{1}).ne(:,i),0,1,xlab,ylab1,tit1,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
axis([0,dft.ionradius{1}.r0n(1),1e-7,1e5])
drawnow
print_jd(print_opt,['Density_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure('Name',tit2);
graph1D_jd(dft.r,4*pi*dft.r.*dft.r.*dft.ne(:,i),0,0,xlab,ylab2,tit2,'','','',linestyle{1},'none',linecolor{1},2,siz,gca);hold on
graph1D_jd(dft.moliere.(models{1}).r,4*pi*dft.moliere.(models{1}).r.*dft.moliere.(models{1}).r.*dft.moliere.(models{1}).ne(:,i),0,0,xlab,ylab2,tit2,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
xlim([0,dft.ionradius{1}.r0n(i)*3])
drawnow
print_jd(print_opt,['Lineicdensity_MoliereGaussian_',int2str(dft.Z),'_',int2str(dft.Z0(i))],'./Figs',get(gcf,'Number'))
%
figure('Name',['Atomic densities for all ionization states (',int2str(Z),')'])
semilogy(dft.r,dft.ne(:,Zindex),'r-',dft.moliere.(models{1}).r,dft.moliere.(models{1}).ne(:,Zindex),'b--','LineWidth',2)
xlabel(xlab);
ylabel(ylab1);
title(['Density, ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z = ',int2str(dft.Z),'), Moments - HFS (Gaussian)']);
axis([0,dft.ionradius{1}.r0n(1),1e-7,1e5])
grid minor
%
for jj = 1:length(Zindex)
    %
    leg{jj} = ['Zs = ',int2str(Zindex(jj)-1),', Gaussian HFS'];
    %
end
%
for jj = 1:length(Zindex)
    %
    leg{jj+length(Zindex)} = ['Zs = ',int2str(Zindex(jj)-1),', Moliere''s method (',int2str(Nexp),' exp. fit)'];
    %
end
%
legend(leg);
%
drawnow
%
if size(dft.moliere.(models{1}).A,2) == 1
    %
    disp('----------------------------------------------------------------')
    disp('   Ns_{fit}  checksum     A1     lambda1 lambda1(N_s)/lambda1(0)^2')
    disp('----------------------------------------------------------------')
    %
    disp([dft.Z-dft.moliere.(models{1}).Nfit',dft.moliere.(models{1}).checksum',dft.moliere.(models{1}).A,dft.moliere.(models{1}).alpha,(dft.moliere.(models{1}).alpha./dft.moliere.(models{1}).alpha(1,:)).^2])
    %
    figure('Name',['Moliere - HFS (Gaussian)']);
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
    leg3 = {'HFS-Moliere (Gaussian)','Kirillov et al. model (1975)','Avdonina - Pratt model (1989)','Avdonina - Pratt - Peysson model (2019)'};
    %
    graph1D_jd((dft.Z-dft.moliere.(models{1}).Nfit')/dft.Z,(dft.moliere.(models{1}).alpha./dft.moliere.(models{1}).alpha(1,:)).^2,0,1,xlab3,ylab3,tit3,'','','','none',marker{1},linecolor{1},2,siz,gca);hold on
    graph1D_jd(x,y_kir,0,1,xlab3,ylab3,tit3,'','','',linestyle{2},'none',linecolor{2},2,siz,gca);hold on
    graph1D_jd(x,y_al,0,1,xlab3,ylab3,tit3,'','','',linestyle{3},'none',linecolor{3},2,siz,gca);hold on
    graph1D_jd(x,y_al_mod,0,1,xlab3,ylab3,tit3,leg3,'','',linestyle{4},'none',linecolor{4},2,siz,gca);  
    %
    drawnow
    print_jd(print_opt,['Moliere - models for ions ',[upper(dft.name(1)), lower(dft.name(2:end))]],'./Figs',get(gcf,'Number'))
    %
else
    %
    disp('-----------------------------------------------------------------------------------')
    disp('   Ns_{fit}  checksum      A1       A2        A3     lambda1   lambda2   lambda3')
    disp('-----------------------------------------------------------------------------------')
    %
    disp([dft.Z-dft.moliere.(models{1}).Nfit',dft.moliere.(models{1}).checksum',dft.moliere.(models{1}).A,dft.moliere.(models{1}).alpha])
    disp([dft.Z-dft.moliere.(models{2}).Nfit',dft.moliere.(models{2}).checksum',dft.moliere.(models{2}).A,dft.moliere.(models{2}).alpha])
    %
end
%
if flag_moliere == 1
    %
    answer_replace_moliere = input_dke_yp('Would you like to replace and save the existing moliere substructure in the dft structure ? (0 : no, 1 : yes)',0);
    %
    if answer_replace_moliere == 1
        %
        save(['DFT/dft_',int2str(Z),'_',elements('atomic_number', Z, 'symbol'),'_',elements('atomic_number', Z, 'name'),'.mat'],'dft');
        %
    end
    %
else
    %
    answer_save_moliere = input_dke_yp('Would you save the existing moliere substructure in the dft structure ? (0 : no, 1 : yes)',0);
    %
    if answer_save_moliere == 1
        %
        save(['DFT/dft_',int2str(Z),'_',elements('atomic_number', Z, 'symbol'),'_',elements('atomic_number', Z, 'name'),'.mat'],'dft');
        %
    end
    %
end




