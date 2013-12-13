function data_pedestal = calc_pedestal_jd(equil,diary_mode)
%
if nargin < 2,
    diary_mode = false;
end
if nargin < 1,
    error('not enough arguments')
elseif ischar(equil),
    load(equil);
end
%
% This function calculates and prints pedestal,central and max values from
% equilibrium profiles
%
prho_G = equil.ptx(:,1)/equil.ptx(end,1);
prho_P = sqrt(equil.psi_apRp/equil.psi_apRp(end));
%
Temax = max(equil.pTe);
nemax = max(equil.pne);
%
pTe = equil.pTe/Temax;
pne = equil.pne/nemax;
%
np = length(prho_G);
%
i_LFS = 1;
i_HFS = (length(equil.theta) + 1)/2;
%
pB_LFS = sqrt(equil.ptBx(:,i_LFS).^2 + equil.ptBy(:,i_LFS).^2 + equil.ptBPHI(:,i_LFS).^2);
pB_HFS = sqrt(equil.ptBx(:,i_HFS).^2 + equil.ptBy(:,i_HFS).^2 + equil.ptBPHI(:,i_HFS).^2);
%
pdnedrho = NaN(1,np);
pdTedrho = NaN(1,np);
%
drhop = prho_P(3:end) - prho_P(2:end-1);
drhom = prho_P(2:end-1) - prho_P(1:end-2);
%
dnep = pne(3:end) - pne(2:end-1);
dnem = pne(2:end-1) - pne(1:end-2);
%
dTep = pTe(3:end) - pTe(2:end-1);
dTem = pTe(2:end-1) - pTe(1:end-2);
%
pdnedrho(2:end - 1) = (drhop.^2.*dnem + drhom.^2.*dnep)./drhom./drhop./(drhop + drhom);
pdnedrho(1) = 0;% pseudo-polar system
pdnedrho(end) = dnep(end)/drhop(end);
%
pdTedrho(2:end - 1) = (drhop.^2.*dTem + drhom.^2.*dTep)./drhom./drhop./(drhop + drhom);
pdTedrho(1) = 0;% pseudo-polar system
pdTedrho(end) = dTep(end)/drhop(end);
%
figure(1),clf
set(1,'name','profiles')
%
xlab = 'r/a';
ylab = '';
xlim1 = [0,1];
ylim1 = [0,ceil(max([nemax/1e19,Temax]))+1];
tit = '';
leg = {'ne19','Te (keV)'};
%
graph1D_jd(prho_P,pne*nemax/1e19,0,0,'','','',NaN,xlim1,ylim1,'-','+','b',2,20+14i);
graph1D_jd(prho_P,pTe*Temax,0,0,xlab,ylab,tit,leg,xlim1,ylim1,'-','s','r',2,20+14i,gca,0.9,0.7,0.7);
%
figure(2),clf
set(2,'name','profiles and derivatives')
%
xlim2 = [0.75,1];
ylim2 = [-0.1,1];
tit = 'Select Pedestal location';
leg = {'ne','Te','-dne/drho (x 0.1)','-dTe/drho (x 0.1)'};
%
graph1D_jd(prho_P,pne,0,0,'','','',NaN,xlim2,ylim2,'-','+','b',2,20+14i);
graph1D_jd(prho_P,pTe,0,0,'','','',NaN,xlim2,ylim2,'-','+','r',2,20+14i);
graph1D_jd(prho_P,-pdnedrho/10,0,0,'','','',NaN,xlim2,ylim2,'-','+',[0,0.5,0],2,20+14i);
graph1D_jd(prho_P,-pdTedrho/10,0,0,xlab,ylab,tit,leg,xlim2,ylim2,'-','+','m',2,20+14i,gca,0.9,0.7,0.5);
%
rho = ginput(2);
%
irho = find(abs(prho_P - rho(1)) == min(abs(prho_P - rho(1))),1,'first');
%
figure(1),
graph1D_jd(prho_P(irho)*[1,1],ylim1,0,0,'','','',NaN,xlim1,ylim1,'-','none','k',2,20+14i);
%
figure(2),
graph1D_jd(prho_P(irho)*[1,1],ylim2,0,0,'','','',NaN,xlim2,ylim2,'-','none','k',2,20+14i);
%
if diary_mode
    print_jd(2,['Fig_',equil.id,'_pedestal_1'],NaN,1)
    print_jd(2,['Fig_',equil.id,'_pedestal_2'],NaN,2)
    %
    filename = ['PROFILES_EQUIL_',equil.id];
    %
    if exist([filename,'.txt'],'file'),
        delete([filename,'.txt'])
    end
    diary([filename,'.txt']);
end
%
data_pedestal.position.rho_G = prho_G(irho);
data_pedestal.position.rho_P = prho_P(irho);
%
data_pedestal.bhoriz.edge_HFS = pB_HFS(end);
data_pedestal.bhoriz.ped_HFS = pB_HFS(irho);
data_pedestal.bhoriz.core = pB_LFS(1);
data_pedestal.bhoriz.ped_LFS = pB_LFS(irho);
data_pedestal.bhoriz.edge_LFS = pB_LFS(end);
%
data_pedestal.ne20.max = nemax/1e20;
data_pedestal.ne20.core = pne(1)*nemax/1e20;
data_pedestal.ne20.ped = pne(irho)*nemax/1e20;
data_pedestal.ne20.edge = pne(end)*nemax/1e20;
%
data_pedestal.tekeV.max = Temax;
data_pedestal.tekeV.core = pTe(1)*Temax;
data_pedestal.tekeV.ped = pTe(irho)*Temax;
data_pedestal.tekeV.edge = pTe(end)*Temax;
%
disp('-------------------------')
disp('   PROFILES PARAMETERS   ')
disp('-------------------------')
disp(' ');
disp('Pedestal : ');
disp(['  - rho G : ',num2str(data_pedestal.position.rho_G)]);
disp(['  - rho P : ',num2str(data_pedestal.position.rho_P)]);
disp(' ');
disp('Density (ne20) : ')
disp(['  - Maximum  : ',num2str(data_pedestal.ne20.max)]);
disp(['  - Central  : ',num2str(data_pedestal.ne20.core)]);
disp(['  - Pedestal : ',num2str(data_pedestal.ne20.ped)]);
disp(['  - Edge     : ',num2str(data_pedestal.ne20.edge)]);
disp(' ');
disp('Temperature (keV) : ')
disp(['  - Maximum  : ',num2str(data_pedestal.tekeV.max)]);
disp(['  - Central  : ',num2str(data_pedestal.tekeV.core)]);
disp(['  - Pedestal : ',num2str(data_pedestal.tekeV.ped)]);
disp(['  - Edge     : ',num2str(data_pedestal.tekeV.edge)]);
disp(' ');
disp('Magnetic field (T) : ')
disp(['  - Edge     (HFS) : ',num2str(data_pedestal.bhoriz.edge_HFS)]);
disp(['  - Pedestal (HFS) : ',num2str(data_pedestal.bhoriz.ped_HFS)]);
disp(['  - Central        : ',num2str(data_pedestal.bhoriz.core)]);
disp(['  - Pedestal (LFS) : ',num2str(data_pedestal.bhoriz.ped_LFS)]);
disp(['  - Edge     (LFS) : ',num2str(data_pedestal.bhoriz.edge_LFS)]);
%
disp(' ');
disp('-------------------------')
%
if diary_mode
    diary off
    %
    save([filename,'.mat'],'data_pedestal');
end









