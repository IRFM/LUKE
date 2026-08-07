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
% Test Zeff calculations from ADAS impurity ionization data. Impact of Te
% on the sensistivity of Zeff to the tungsten content
%
clear all
close all
clc
%
[dkepath] = load_structures_yp('dkepath','','');
adasfile = ['ADAS.mat'];%Atomic Data and Analysis Structure (ADAS). 
%
load(adasfile);%structure is named tabmat
%
elements = {'H','C','O','Cu','W'};%Hydrogen, Carbon, Oxygen and Tungsten
%
Te0 = [1:6];%keV
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
for iTe0 = 1:length(Te0)
    %
    prho = [0:0.05:1];%normalized minor radius
    %
    pTe(iTe0,:) = Te0(iTe0)*0.9*(1-prho.^2).^2+Te0(iTe0)*0.1;%keV
    pne = 2.4e19*(1-prho.^6).^2+0.1e19;%m-3
    %
    fi = [0.1,0.9,0];
    %
    flag_Cu = 1;
    %
    frac0 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*0,0];%relative fractions
    frac1 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*1e-4,1e-6];%relative fractions
    frac2 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*1e-4,1e-5];%relative fractions
    frac3 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*1e-4,1e-4];%relative fractions
    frac4 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*1e-4,1e-3];%relative fractions
    %
    [zZi,zmi] = element2ZA_yp(tabmat,elements);
    %
    zZi = [1,1,1,zZi(2:end)];
    zmi = [1,1,3,zmi(2:end)];
    %
    pzni0 = frac0(:)*pne;
    pzni1 = frac1(:)*pne;
    pzni2 = frac2(:)*pne;
    pzni3 = frac3(:)*pne;
    pzni4 = frac4(:)*pne;
    %
    pzTi0 = ones(size(frac0(:)))*pTe(iTe0,:)/2;
    pzTi1 = ones(size(frac1(:)))*pTe(iTe0,:)/2;
    pzTi2 = ones(size(frac2(:)))*pTe(iTe0,:)/2;
    pzTi3 = ones(size(frac3(:)))*pTe(iTe0,:)/2;
    pzTi4 = ones(size(frac4(:)))*pTe(iTe0,:)/2;
    %
    [pZeff0] = zeff_adas_yp(tabmat,zZi,zmi,pzni0,pzTi0,pne,pTe(iTe0,:));
    [pZeff1] = zeff_adas_yp(tabmat,zZi,zmi,pzni1,pzTi1,pne,pTe(iTe0,:));
    [pZeff2] = zeff_adas_yp(tabmat,zZi,zmi,pzni2,pzTi2,pne,pTe(iTe0,:));
    [pZeff3] = zeff_adas_yp(tabmat,zZi,zmi,pzni3,pzTi3,pne,pTe(iTe0,:));
    [pZeff4] = zeff_adas_yp(tabmat,zZi,zmi,pzni4,pzTi4,pne,pTe(iTe0,:));
    %
    pZeff{iTe0} = [pZeff0;pZeff1;pZeff2;pZeff3;pZeff4];
    %
    figure('Name',['T_{e0} = ',num2str(Te0(iTe0)*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%)'])
    %
    xlab = 'Normalized minor radius \rho';
    ylab = 'Effective charge Z_{eff}';
    tit =  ['T_{e0} = ',num2str(Te0(iTe0)*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%)'];
    leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
    siz = 20+14i;
    %
    xlim = [0,1];
    ylim = [1,ceil(max(max(pZeff{iTe0})))];
    %
    graph1D_jd(prho,pZeff0,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{1},marker{1},linecolor{1},2,siz,gca);
    graph1D_jd(prho,pZeff1,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{2},marker{2},linecolor{2},2,siz,gca);
    graph1D_jd(prho,pZeff2,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{3},marker{3},linecolor{3},2,siz,gca);
    graph1D_jd(prho,pZeff3,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{4},marker{4},linecolor{4},2,siz,gca);
    graph1D_jd(prho,pZeff4,0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{5},marker{5},linecolor{5},2,siz,gca);
    %
    set(gca,'ytick',[1:0.2:ylim(2)]);
    %
    drawnow
    %
    flag_Cu = 0;
    %
    frac0 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*0,0];%relative fractions
    frac1 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*1e-4,1e-6];%relative fractions
    frac2 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*1e-4,1e-5];%relative fractions
    frac3 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*1e-4,1e-4];%relative fractions
    frac4 = [0.98*fi(1),0.98*fi(2),0.98*fi(3),1e-2,1e-2,flag_Cu*1e-4,1e-3];%relative fractions
    %
    pzni0 = frac0(:)*pne;
    pzni1 = frac1(:)*pne;
    pzni2 = frac2(:)*pne;
    pzni3 = frac3(:)*pne;
    pzni4 = frac4(:)*pne;
    %
    pzTi0 = ones(size(frac0(:)))*pTe(iTe0,:)/2;
    pzTi1 = ones(size(frac1(:)))*pTe(iTe0,:)/2;
    pzTi2 = ones(size(frac2(:)))*pTe(iTe0,:)/2;
    pzTi3 = ones(size(frac3(:)))*pTe(iTe0,:)/2;
    pzTi4 = ones(size(frac4(:)))*pTe(iTe0,:)/2;
    %
    [pZeff0_noCu] = zeff_adas_yp(tabmat,zZi,zmi,pzni0,pzTi0,pne,pTe(iTe0,:));
    [pZeff1_noCu] = zeff_adas_yp(tabmat,zZi,zmi,pzni1,pzTi1,pne,pTe(iTe0,:));
    [pZeff2_noCu] = zeff_adas_yp(tabmat,zZi,zmi,pzni2,pzTi2,pne,pTe(iTe0,:));
    [pZeff3_noCu] = zeff_adas_yp(tabmat,zZi,zmi,pzni3,pzTi3,pne,pTe(iTe0,:));
    [pZeff4_noCu] = zeff_adas_yp(tabmat,zZi,zmi,pzni4,pzTi4,pne,pTe(iTe0,:));
    %
    pZeff_noCu{iTe0} = [pZeff0_noCu;pZeff1_noCu;pZeff2_noCu;pZeff3_noCu;pZeff4_noCu];
    %
    figure('Name',['T_{e0} = ',num2str(Te0(iTe0)*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), no Cu '])
    %
    xlab = 'Normalized minor radius \rho';
    ylab = 'Effective charge Z_{eff}';
    tit = ['T_{e0} = ',num2str(Te0(iTe0)*0.9),' keV, H (9.8%), D (88.2%), C (1%), O (1%), no Cu'];
    leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
    siz = 20+14i;
    %
    xlim = [0,1];
    ylim = [1,ceil(max(max(pZeff_noCu{iTe0})))];
    %
    graph1D_jd(prho,pZeff0_noCu,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{1},marker{1},linecolor{1},2,siz,gca);
    graph1D_jd(prho,pZeff1_noCu,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{2},marker{2},linecolor{2},2,siz,gca);
    graph1D_jd(prho,pZeff2_noCu,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{3},marker{3},linecolor{3},2,siz,gca);
    graph1D_jd(prho,pZeff3_noCu,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{4},marker{4},linecolor{4},2,siz,gca);
    graph1D_jd(prho,pZeff4_noCu,0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{5},marker{5},linecolor{5},2,siz,gca);
    %
    set(gca,'ytick',[1:0.2:ylim(2)]);
    %
    drawnow
    %
end
%
figure('Name',['Zeff(Te0), H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%)'])
%
xlab = 'Core electron temperature (keV)';
ylab = 'Effective charge Z_{eff}';
tit = ['Z_{eff}, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%)'];
%leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
siz = 20+14i;
%
xlim = [0,max(Te0)];
%
Zeff = [];
for iTe0 = 1:length(Te0)
    Zeff(:,iTe0) = pZeff{iTe0}(:,1);
end
%
leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
%
for ii = 1:5
    %
    graph1D_jd(Te0,Zeff(ii,:),0,0,xlab,ylab,tit,'',xlim,'',linestyle{ii},marker{ii},linecolor{ii},2,siz,gca);
    %
end
%
legend(leg);
%
figure('Name',['Zeff(Te0), H (9.8%), D (88.2%), C (1%), O (1%), no Cu'])
%
xlab = 'Core electron temperature (keV)';
ylab = 'Core effective charge Z_{eff}';
tit = ['Z_{eff}, H (9.8%), D (88.2%), C (1%), O (1%), no Cu'];
%leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
siz = 20+14i;
%
xlim = [0,max(Te0)];
%
Zeff_noCu = [];
for iTe0 = 1:length(Te0)
    Zeff_noCu(:,iTe0) = pZeff_noCu{iTe0}(:,1);
end
%
leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
%
for ii = 1:5
    %
    graph1D_jd(Te0,Zeff_noCu(ii,:),0,0,xlab,ylab,tit,'',xlim,'',linestyle{ii},marker{ii},linecolor{ii},2,siz,gca);
    %
end
%
legend(leg)
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







