function [] = gaussian09_grasp2018_comparison(Z_in,print_opt)
%
% Comparison between GAUSSIAN and GRASP for different ionization of
% various elements. Cross-validation of the two methods for determining the ground-state 
% atomic density Tungsten
%
%   INPUTS:
%
%       - Z_in : list of atomic numbers [1,n]
%           (default = 18 for argon)
%       - print_opt : print option (2 : create figures in ./Figs folder)
%           (default = -1)
%
%   OUTPUTS: none
%
% by Yves Savoye-Peysson <yves.savoye-peysson@cea.fr> (IRFM/CEA)
%
if nargin < 1
    %
    Z_in = 18;
    print_opt = -1;
    %
end
%
if nargin < 2
    %
    print_opt = -1;
    %
end
%
close all
clc
%
for iZ = 1:length(Z_in)
    %
    name = elements('atomic_number',Z_in(iZ),'name');
    symbol = elements('atomic_number',Z_in(iZ),'symbol');
    %
    load(['DFT/dft_',int2str(Z_in(iZ)),'_',symbol,'_',name,'.mat']);
    load(['MCDHF/mcdhf_',int2str(Z_in(iZ)),'_',symbol,'_',name,'.mat']);
    %
    N_dft = 4*pi*trapz_dke_yp([dft.r,dft.ne(:,1).*dft.r.^2]);
    N_mcdhf = 4*pi*trapz_dke_yp([mcdhf.ne(:,2),mcdhf.ne(:,3).*mcdhf.ne(:,2).^2]);
    %
    tit1 = ['Ground-state ',[upper(dft.name(1)), lower(dft.name(2:end))],' (Z_s = ',int2str(dft.Z)];
    %
    h1 = figure('Name',[tit1,') DFT (GAUSSIAN09) + MCDHF (GRASP2018)']);
    %
    semilogy(dft.dft_data(:,2),dft.dft_data(:,3:end),'r-','LineWidth',2), hold on
    semilogy(mcdhf.ne(:,2),mcdhf.ne(:,3:end),'bo','MarkerSize',3)
    %
    axis([0,5,1e-4,1e4])
    %
    legend(['DFT ({\itGAUSSIAN09} code), N(Z_{0,s} = 0) = ',num2str(N_dft)],['MCDHF ({\itGRASP2018} code), N(Z_{0,s} = 0) = ',num2str(N_mcdhf)])
    %
    xlab = 'Ion radius [a_0]';
    ylab = 'Density of bound electrons [{a^{-3}_0}]';
    %
    itext = min(find(dft.dft_data(:,3:end) < 1e-2));
    text(dft.dft_data(itext,2),dft.dft_data(itext,3)*1.5,'Z_{0,s} = 0')
    %
    ylabel(ylab)
    xlabel(xlab)
    %
    title([tit1,')'])
    %
    grid minor
    %
    drawnow
    %
    print_jd(print_opt,['GaussianGrasp_comparison_',int2str(dft.Z)],'./Figs',get(h1,'Number'))
    %
end
