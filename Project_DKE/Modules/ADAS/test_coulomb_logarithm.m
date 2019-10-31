%
%
% Test Zeff calculations from ADAS impurity ionization data
%
clear all
close all
clc
%
[dkepath] = load_structures_yp('dkepath','','');
adasfile = [dkepath.luke_root,'Project_DKE/Modules/ADAS/ADAS.mat'];%Atomic Data and Analysis Structure (ADAS). 
%
load(adasfile);%structure is named tabmat
%
elements = {'H','C','O','Cu','W'};%Hydrogen, Carbon, Oxygen and Tungsten
%elements = {'H','Ne','Ar'};%Hydrogen, Carbon, Oxygen and Tungsten
%
Znucleus = [6,8,29,74];%impurity atomic number
%Znucleus = [10,18];%impurity atomic number
%
Te0 = 3;%keV
Ec = logspace(-1,3,100);%keV
%
model = 3;%see models in coulomb_logarithm_yp.m
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
prel = sqrt((Ec/511 + 1).^2 - 1);%relativistic momentum
%
prho = [0:0.05:1];%normalized minor radius
%
pTe = Te0*0.9*(1-prho.^2).^2+Te0*0.1;%keV
pne = 2.4e19*(1-prho.^6).^2+0.1e19;%m-3
%
fi = [0.1,0.9,0];
%
frac = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,1e-4,1e-5];%relative fractions
%frac = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2];%relative fractions
%
[zZi,zmi] = element2ZA_yp(tabmat,elements);
%
zZi = [1,1,1,zZi(2:end)];
zmi = [1,1,3,zmi(2:end)];
%
pzni = frac(:)*pne;
%
pzTi = ones(size(frac(:)))*pTe/2;
%
[pZeff] = zeff_adas_yp(tabmat,zZi,zmi,pzni,pzTi,pne,pTe);
[zZi,~,zmi,pzni,pzTi] = ionisation_adas_yp(tabmat,zZi,zmi,pzni,pzTi,pne,pTe);
%
gfp = [];
%
for ii = 1:length(Znucleus)
    gfp = [gfp, gfp_yp(prel,Znucleus(ii),'Tseng-Pratt-Botto','/Users/yves/Travail/Projets/LUKE_LHCD/Project_DKE/Modules/ADAS')]; 
end
%
gfp = [zeros(length(prel),3),gfp];%add three hydrogen isotope fully ionized
%
if 1
    figure('Name',['Cu (Z=29) ionization'])
    %
    xlab = 'Z_0';
    ylab = 'Relative fraction (%)';
    tit =  ['Cu (Z=29) ionization (ADAS)'];
    siz = 20+14i;
    %
    iindex = [20:49];
    leg = {['T_{e} = ',num2str(pTe(1)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,1)')/sum(pzni(iindex,1)))],...
           ['T_{e} = ',num2str(pTe(10)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,10)')/sum(pzni(iindex,10)))],...
           ['T_{e} = ',num2str(pTe(end)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,end)')/sum(pzni(iindex,end)))]};
    graph1D_jd(zZi(iindex),100*pzni(iindex,1)/sum(pzni(iindex,1),1),0,0,xlab,ylab,tit,leg,[0,29],[0,100],linestyle{1},'none',linecolor{1},2,siz,gca);
    graph1D_jd(zZi(iindex),100*pzni(iindex,10)/sum(pzni(iindex,10),1),0,0,xlab,ylab,tit,leg,[0,29],[0,100],linestyle{2},'none',linecolor{2},2,siz,gca);
    graph1D_jd(zZi(iindex),100*pzni(iindex,end)/sum(pzni(iindex,end),1),0,0,xlab,ylab,tit,leg,[0,29],[0,100],linestyle{3},'none',linecolor{3},2,siz,gca);
    %
    drawnow
    %
    figure('Name',['W (Z=74) ionization'])
    %
    xlab = 'Z_0';
    ylab = 'Relative fraction (%)';
    tit =  ['W (Z=74) ionization (ADAS)'];
    siz = 20+14i;
    %
    iindex = [50:length(zZi)];
    leg = {['T_{e} = ',num2str(pTe(1)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,1)')/sum(pzni(iindex,1)))],...
           ['T_{e} = ',num2str(pTe(10)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,10)')/sum(pzni(iindex,10)))],...
           ['T_{e} = ',num2str(pTe(end)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,end)')/sum(pzni(iindex,end)))]};
    graph1D_jd(zZi(iindex),100*pzni(iindex,1)/sum(pzni(iindex,1),1),0,0,xlab,ylab,tit,leg,[0,74],[0,100],linestyle{1},'none',linecolor{1},2,siz,gca);
    graph1D_jd(zZi(iindex),100*pzni(iindex,10)/sum(pzni(iindex,10),1),0,0,xlab,ylab,tit,leg,[0,74],[0,100],linestyle{2},'none',linecolor{2},2,siz,gca);
    graph1D_jd(zZi(iindex),100*pzni(iindex,end)/sum(pzni(iindex,end),1),0,0,xlab,ylab,tit,leg,[0,74],[0,100],linestyle{3},'none',linecolor{3},2,siz,gca);
    %
    drawnow
    %
else
    figure('Name',['Ne (Z=10) ionization'])
    %
    xlab = 'Z_0';
    ylab = 'Relative fraction (%)';
    tit =  ['Ne (Z=10) ionization (ADAS)'];
    siz = 20+14i;
    %
    iindex = [4:14];
    leg = {['T_{e} = ',num2str(pTe(1)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,1)')/sum(pzni(iindex,1)))],...
           ['T_{e} = ',num2str(pTe(10)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,10)')/sum(pzni(iindex,10)))],...
           ['T_{e} = ',num2str(pTe(end)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,end)')/sum(pzni(iindex,end)))]};
    graph1D_jd(zZi(iindex),100*pzni(iindex,1)/sum(pzni(iindex,1),1),0,0,xlab,ylab,tit,leg,[0,10],[0,100],linestyle{1},'none',linecolor{1},2,siz,gca);
    graph1D_jd(zZi(iindex),100*pzni(iindex,10)/sum(pzni(iindex,10),1),0,0,xlab,ylab,tit,leg,[0,10],[0,100],linestyle{2},'none',linecolor{2},2,siz,gca);
    graph1D_jd(zZi(iindex),100*pzni(iindex,end)/sum(pzni(iindex,end),1),0,0,xlab,ylab,tit,leg,[0,10],[0,100],linestyle{3},'none',linecolor{3},2,siz,gca);
    %
    drawnow
    %

    figure('Name',['Ar (Z=18) ionization'])
    %
    xlab = 'Z_0';
    ylab = 'Relative fraction (%)';
    tit =  ['Ar (Z=18) ionization (ADAS)'];
    siz = 20+14i;
    %
    iindex = [15:length(zZi)];
    leg = {['T_{e} = ',num2str(pTe(1)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,1)')/sum(pzni(iindex,1)))],...
           ['T_{e} = ',num2str(pTe(10)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,10)')/sum(pzni(iindex,10)))],...
           ['T_{e} = ',num2str(pTe(end)),' keV, <Z_0> = ',num2str(sum(zZi(iindex).*pzni(iindex,end)')/sum(pzni(iindex,end)))]};
    graph1D_jd(zZi(iindex),100*pzni(iindex,1)/sum(pzni(iindex,1),1),0,0,xlab,ylab,tit,leg,[0,18],[0,100],linestyle{1},'none',linecolor{1},2,siz,gca);
    graph1D_jd(zZi(iindex),100*pzni(iindex,10)/sum(pzni(iindex,10),1),0,0,xlab,ylab,tit,leg,[0,18],[0,100],linestyle{2},'none',linecolor{2},2,siz,gca);
    graph1D_jd(zZi(iindex),100*pzni(iindex,end)/sum(pzni(iindex,end),1),0,0,xlab,ylab,tit,leg,[0,18],[0,100],linestyle{3},'none',linecolor{3},2,siz,gca);
    %
    drawnow
    %
end
%
for imodel = 1:2
    [pcleeth{imodel},pcleith{imodel},cleerel{imodel},cleirel{imodel}] = coulomb_logarithm_yp(imodel,pne,pTe,prel);
 %   [pcleeth1{imodel},pcleith0{imodel},cleerel1{imodel},cleirel0{imodel}] = coulomb_logarithm_yp(imodel,pne,pTe,prel);
end
%
%
figure('Name',['T_{e0} = ',num2str(Te0*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%), W (0.001%)'])
%
xlab = 'Normalized minor radius \rho';
ylab = 'Thermal Coulomb logarithm log(\Lambda_{th})';
tit =  ['T_{e0} = ',num2str(Te0*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%), W (0.001%)'];
%leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
siz = 20+14i;
%
xlim = [0,1];
ylim = [floor(min(min(pcleeth{imodel}))),ceil(max(max(pcleeth{imodel})))];
%
%(1) Sauter, (2) Wesson (e-e)
%
leg = {'Sauter et al. (1999)','Wesson e-e (2004)'};
for imodel = [1,2]
    graph1D_jd(prho,pcleeth{imodel},0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{imodel},marker{imodel},linecolor{imodel},2,siz,gca);
end
%
drawnow
%
figure('Name',['T_{e0} = ',num2str(Te0*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%), W (0.001%)'])
%
xlab = 'Kinetic energy E_c (keV)';
ylab = 'Relativistic Coulomb logarithm log(\Lambda_{rel})';
tit =  ['T_{e0} = ',num2str(Te0*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%), W (0.001%)'];
%leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
siz = 20+14i;
%
%xlim = [min,1];
%ylim = [floor(min(min(pclth0{imodel}))),ceil(max(max(pclth0{imodel})))];
ylim = [13,17];
%
%(1) Sauter, (2) Wesson (e-e)
%
leg = {'Sauter et al. (1999)','Wesson e-e (2004)',};
for imodel = [1,2]
    graph1D_jd(Ec,cleerel{imodel}(1,:),1,0,xlab,ylab,tit,leg,'','',linestyle{imodel},'none',linecolor{imodel},2,siz,gca);
end
%
drawnow
%
figure('Name','Profiles (T_i/T_e = 0.5)')
%
xlab = 'Normalized minor radius \rho';
ylab1 = 'Electron temperature (keV)';
ylab2 = 'Electron density (10^{+19} m^{-3})';
xlim = [0,1];
leg = '';
tit = 'Profiles (T_i/T_e = 0.5)';
%
graph1D2jd(prho,pTe,prho,pne/1e19,xlab,ylab1,ylab2,tit,xlim,'','',linestyle{1},'none',linecolor{1},2,linestyle{2},'none',linecolor{2},2,siz);
%
drawnow
%
pcleerel= ones(size(zZi))'*cleerel{imodel}(1,:);
pzZi = zZi(:)*ones(size(prel));
z2coulog = pcleerel'.*pzZi'.*pzZi';
z2couloggfp = pcleerel'.*pzZi'.*pzZi' + gfp;
%
iiz = 20;
%
figure('Name',['Z_i = ',int2str(iiz)])
%
xlab = 'Kinetic energy E_c (keV)';
ylab = 'log(\Lambda_{rel})Z_i^2';
leg = '';
tit =  ['T_{e0} = ',num2str(Te0*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%), W (0.001%)'];
%
leg = {['Z_i = ',int2str(iiz),', log(\Lambda_{rel})Z_i^2'],['Z_i = ',int2str(iiz),', screening factor']};
graph1D_jd(Ec,z2coulog(:,iiz),1,0,xlab,ylab,tit,leg,'','',linestyle{1},'none',linecolor{1},2,siz,gca);
graph1D_jd(Ec,gfp(:,iiz),1,0,xlab,ylab,tit,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca);
%
iiz = 30;
%
figure('Name',['Z_i = ',int2str(iiz)])
%
xlab = 'Kinetic energy E_c (keV)';
ylab = 'log(\Lambda_{rel})Z_i^2';
leg = '';
tit =  ['T_{e0} = ',num2str(Te0*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%), W (0.001%)'];
%
leg = {['Z_i = ',int2str(iiz),', log(\Lambda_{rel})Z_i^2'],['Z_i = ',int2str(iiz),', screening factor']};
graph1D_jd(Ec,z2coulog(:,iiz),1,0,xlab,ylab,tit,leg,'','',linestyle{1},'none',linecolor{1},2,siz,gca);
graph1D_jd(Ec,gfp(:,iiz),1,0,xlab,ylab,tit,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca);
%
iiz = 40;
%
figure('Name',['Z_i = ',int2str(iiz)])
%
xlab = 'Kinetic energy E_c (keV)';
ylab = 'log(\Lambda_{rel})Z_i^2';
leg = '';
tit =  ['T_{e0} = ',num2str(Te0*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%), W (0.001%)'];
%
leg = {['Z_i = ',int2str(iiz),', log(\Lambda_{rel})Z_i^2'],['Z_i = ',int2str(iiz),', screening factor']};
graph1D_jd(Ec,z2coulog(:,iiz),1,0,xlab,ylab,tit,leg,'','',linestyle{1},'none',linecolor{1},2,siz,gca);
graph1D_jd(Ec,gfp(:,iiz),1,0,xlab,ylab,tit,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca);
%