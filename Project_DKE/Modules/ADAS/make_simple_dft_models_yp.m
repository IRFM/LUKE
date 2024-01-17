function dft = make_simple_dft_models_yp(Z_in,display,print_opt)
%
% Build DFT structure from simple models only DFT calculation post-processing. Reorganize the structure to make fields
% clear, and add necessary coefficients for further calculations (Fokker-Planck or bremsstrahlung)
%
%   INPUTS:
%
%       - Z_in : atomic charge of the considered element
%       - display : display mode
%       - print_opt :  (opt = 0) and (opt = 1) / or (opt = 2, default) saves to file the current figure under the name savename 
%
%   OUTPUTS:
%
%       - dft : new dft structure 
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>, A. Jardin IJF/PAN <axel.jardin@ifj.edu.pl>, Krzysztof Krol IFJ/PAN <krzysztof.krol@ifj.edu.pl>
%
if nargin < 1
    %
    Z_in = 18;    
    disp('WARNING : default value Z = 18, Argon');
    %
    display = 1; %no display
    print_opt = -1; %no saving/printing
    %
end
%
if nargin < 2
    %
    display = 1; %no display
    print_opt = -1; %no saving/printing
    %
end
%
if nargin < 3
    %
    print_opt = -1; %no saving but printing
    %
end
%
if display > 0
    %
    close all
    %
end
%
symbol = elements('atomic_number',Z_in, 'symbol');
name = elements('atomic_number',Z_in, 'name');
%
filename = ['DFT/dft_',int2str(Z_in),'_',symbol,'_',name];
%
if exist(filename,'file')
    disp(['WARNING: file dft_',int2str(Z_in),'_',symbol,'_',name,'.mat already exists. Use dft_postproc_yp.m to update it'])
    return;
end
%
dft.name = name;
dft.symbol = symbol;
%
dft.Z = Z_in;
dft.Z0 = [0:1:Z_in-1];%
dft.N = dft.Z-dft.Z0;%number of bound electrons
%
[dft.I_meanexcitationenergy,dft.I_meanexcitationenergy_s] = meanexcitationenergy_yp(dft.Z);% Mean ion excitation energy for inelastic scattering
%
dft.models = {'Thomas-Fermi','Thomas-Fermi-Kirillov','Tseng-Pratt-Avdonina-Lamoureux','Tseng-Pratt-Botto','Tseng-Pratt-Thomas-Fermi'};
%
for imodel = 1:length(dft.models)
    %
    ionradius = ionradius_yp(dft.Z,dft.models{imodel});
    dft.ionradius{imodel} = ionradius;
    %
end
%
save(['DFT/dft_',int2str(dft.Z),'_',dft.symbol,'_',dft.name,'.mat'],'dft');
disp(['New dft structure saved in ','DFT/dft_',int2str(dft.Z),'_',dft.symbol,'_',dft.name,'.mat'])
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
ylab = '2*a/\alpha [a_0]';
tit = ['Normalized ion radius (DFT, Thomas-Fermi) for Z = ',int2str(dft.Z)];
leg = {};
%
figure('Name',['Normalized ion radius (DFT, Thomas-Fermi) for Z = ',int2str(dft.Z)]);
%
iref = find(ismember(dft.models,{'Thomas-Fermi-Kirillov'})==1);
leg = [leg,'Thomas-Fermi-Kirillov'];
graph1D_jd(dft.Z0,dft.ionradius{iref}.a(1:end-1),0,0,xlab,ylab,tit,leg,'','','none',marker{1},linecolor{1},2,siz,gca); 
iref = find(ismember(dft.models,{'Thomas-Fermi'})==1);
leg = [leg,'Thomas-Fermi'];
graph1D_jd(dft.Z0,dft.ionradius{iref}.a(1:end-1),0,0,xlab,ylab,tit,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
%
figure('Name',['Normalized ion radius (DFT, Tseng-Pratt) for Z = ',int2str(dft.Z)]);
%
leg = {};
tit = ['Normalized ion radius (DFT, Tseng-Pratt) for Z = ',int2str(dft.Z)];
%
iref = find(ismember(dft.models,{'Tseng-Pratt-Botto'})==1);
leg = [leg,'Tseng-Pratt-Botto'];
graph1D_jd(dft.Z0,dft.ionradius{iref}.a(1:end-1),0,0,xlab,ylab,tit,leg,'','','none',marker{1},linecolor{1},2,siz,gca); 
iref = find(ismember(dft.models,{'Tseng-Pratt-Thomas-Fermi'})==1);
leg = [leg,'Tseng-Pratt-Thomas-Fermi'];
graph1D_jd(dft.Z0,dft.ionradius{iref}.a(1:end-1),0,0,xlab,ylab,tit,leg,'','',linestyle{2},'none',linecolor{2},2,siz,gca); 
%
drawnow
%
print_jd(print_opt,['ion_radius_',int2str(dft.Z)],'./Figs',get(gcf,'Number'))
%

