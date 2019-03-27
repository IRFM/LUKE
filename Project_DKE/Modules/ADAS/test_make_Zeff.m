e%
% Test Zeff calculations from ADAS impurity ionization data
%
clear all
%
[dkepath] = load_structures_yp('dkepath','','');
adasfile = [dkepath.luke_root,'project_DKE/Modules/ADAS/ADAS.mat'];%Atomic Data and Analysis Structure (ADAS). 
%
elements = {'H','C','O','Cu','W'};%Hydrogen, Carbon, Oxygen and Tungsten
%
prho = [0:0.01:1];%normalized minor radius
pTe = 2.9*(1-prho.^2).^2+0.1;%keV
pne = 2.4e19*(1-prho.^2).^2+0.1e19;%m-3
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
load(adasfile);%structure is named tabmat
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
pzTi0 = ones(size(frac0(:)))*pTe;
pzTi1 = ones(size(frac1(:)))*pTe;
pzTi2 = ones(size(frac2(:)))*pTe;
pzTi3 = ones(size(frac3(:)))*pTe;
pzTi4 = ones(size(frac4(:)))*pTe;
%
[pZeff0] = zeff_adas_yp(tabmat,zZi,zmi,pzni0,pzTi0,pne,pTe);
[pZeff1] = zeff_adas_yp(tabmat,zZi,zmi,pzni1,pzTi1,pne,pTe);
[pZeff2] = zeff_adas_yp(tabmat,zZi,zmi,pzni2,pzTi2,pne,pTe);
[pZeff3] = zeff_adas_yp(tabmat,zZi,zmi,pzni3,pzTi3,pne,pTe);
[pZeff4] = zeff_adas_yp(tabmat,zZi,zmi,pzni4,pzTi4,pne,pTe);
%
pZeff = [pZeff0,pZeff1,pZeff2,pZeff3,pZeff4];
%
figure,clf
%
xlab = '\rho';
ylab = 'Z_{eff}';
tit = 'T_{e0} = 3 keV, H (9.8%), D (88.2%), C (1%), O (1%), Cu (0.01%)';
leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
siz = 20+14i;
%
xlim = [0,1];
ylim = [1,round(max(max(pZeff)))];
%
graph1D_jd(prho,pZeff0,0,0,xlab,ylab,tit,'',xlim,ylim,'-','none','r',2,siz,gca);
graph1D_jd(prho,pZeff1,0,0,xlab,ylab,tit,'',xlim,ylim,'-','none','m',2,siz,gca);
graph1D_jd(prho,pZeff2,0,0,xlab,ylab,tit,'',xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(prho,pZeff3,0,0,xlab,ylab,tit,'',xlim,ylim,'-','none','g',2,siz,gca);
graph1D_jd(prho,pZeff4,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','k',2,siz,gca);
%
set(gca,'ytick',[1:0.2:ylim(2)]);
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
pzTi0 = ones(size(frac0(:)))*pTe;
pzTi1 = ones(size(frac1(:)))*pTe;
pzTi2 = ones(size(frac2(:)))*pTe;
pzTi3 = ones(size(frac3(:)))*pTe;
pzTi4 = ones(size(frac4(:)))*pTe;
%
[pZeff0] = zeff_adas_yp(tabmat,zZi,zmi,pzni0,pzTi0,pne,pTe);
[pZeff1] = zeff_adas_yp(tabmat,zZi,zmi,pzni1,pzTi1,pne,pTe);
[pZeff2] = zeff_adas_yp(tabmat,zZi,zmi,pzni2,pzTi2,pne,pTe);
[pZeff3] = zeff_adas_yp(tabmat,zZi,zmi,pzni3,pzTi3,pne,pTe);
[pZeff4] = zeff_adas_yp(tabmat,zZi,zmi,pzni4,pzTi4,pne,pTe);
%
pZeff = [pZeff0,pZeff1,pZeff2,pZeff3,pZeff4];
%
figure,clf
%
xlab = '\rho';
ylab = 'Z_{eff}';
tit = 'T_{e0} = 3 keV, H (9.8%), D (88.2%), C (1%), O (1%), no Cu';
leg = {'no W ','W fraction: 0.0001%','W fraction: 0.001%','W fraction: 0.01%','W fraction: 0.1%'};
siz = 20+14i;
%
xlim = [0,1];
ylim = [1,round(max(max(pZeff)))];
%
graph1D_jd(prho,pZeff0,0,0,xlab,ylab,tit,'',xlim,ylim,'-','none','r',2,siz,gca);
graph1D_jd(prho,pZeff1,0,0,xlab,ylab,tit,'',xlim,ylim,'-','none','m',2,siz,gca);
graph1D_jd(prho,pZeff2,0,0,xlab,ylab,tit,'',xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(prho,pZeff3,0,0,xlab,ylab,tit,'',xlim,ylim,'-','none','g',2,siz,gca);
graph1D_jd(prho,pZeff4,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','k',2,siz,gca);
%
set(gca,'ytick',[1:0.2:ylim(2)]);
%
