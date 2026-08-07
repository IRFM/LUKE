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
% Test relative ion fractions from ADAS impurity ionization data at a given
% temperature
%
clear all
close all
clc
%
element = 'W';%Hydrogen (H), Carbon (C), Oxygen (O), Tungsten (W)...
%
Te = [0.01,0.1,1,3,10];%keV
%
print_opt = 2;%-1: no print, 2:save files (eps,png,fig)
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
marker(1) = {'.'};
marker(2) = {'x'};
marker(3) = {'+'};
marker(4) = {'*'};
marker(5) = {'s'};
marker(6) = {'d'};
%
%
[dkepath] = load_structures_yp('dkepath','','');
adasfile = 'ADAS.mat';%Atomic Data and Analysis Structure (ADAS). 
%
load(adasfile);%structure is named tabmat
%
adas = tabmat;
%
[Zi,mi] = element2ZA_yp(adas,{element});
%
element_name = elements('Symbol', element, 'name');
%
[elements] = Z2element_yp(adas,Zi);
%
Zelement = size(adas.(elements{1}).rep,2)-1;
%
leg = '';
%
for j = 1:size(adas.(elements{1}).rep,2)
    %
    Zs0(j) = j-1;  
    %
    for i = 1:length(Te)
        %
        frac_ij(i,j) = interp1(adas.(elements{1}).Te,adas.(elements{1}).rep(:,j),Te(i));%keV
        %
        Zs0mean(i) = round(sum(frac_ij(i,:).*Zs0));%mean charge
        %
        leg{i} = ['T_e = ',num2str(Te(i)),' keV, mean Z_{0,s} = ',num2str(Zs0mean(i))];
        %
    end
    %
end
%
figure('Name',['OPEN-ADAS, element : ',element_name])
%
xlab = 'Screened ion charge, Z_{0,s}';
ylab = 'Relative fraction [%]';
tit =  ['OPEN-ADAS, ',element_name,' (Z_s = ',int2str(Zelement),')'];
siz = 20+14i;
%
xlim = [0,Zelement];
ylim = [0,max(max(frac_ij*100))];
%
for i = 1:length(Te)
    %
    graph1D_jd(Zs0,frac_ij(i,:)*100,0,0,xlab,ylab,tit,'',xlim,ylim,linestyle{i},marker{1},linecolor{i},2,siz,gca)
    %
end
%
legend(leg,'Location','NorthEast');
%
print_jd(print_opt,['mean_Z0s_Te_',element_name],'./Figs',get(gcf,'Number'))






