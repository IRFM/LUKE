%
clear all
close all
clc
%
zZi = [29];
%
kphot_min = 20;%keV
kphot_max = 240;%keV
%dkphot = 5;%keV
nkphot = 23;%number of photon energies
%
if exist('dkphot','var')
    kphot = [kphot_min:dkphot:kphot_max];
    nkphot = length(kphot);
elseif exist('nkphot','var')
    kphot = linspace(kphot_min,kphot_max,nkphot);
else
    error('dkphot or nkphot must be defined')
end
%
n_gauleg = 35;
epsi_gauleg = 1e-14;
%
screening_model = 'Tseng-Pratt-Botto';
%
screening_hxr_params.nphi = NaN;%
screening_hxr_params.flag_mem = 1;
screening_hxr_params.ntheta = 2006;
screening_hxr_params.integral = 'simps';
screening_hxr_params.nEc = 300;
screening_hxr_params.Ecmax = 1300;%keV;
%
disp('------------------------------------------------------------------------------')
disp('Build tables for fast bremsstrahlung calculations with partial screening effect')
disp('------------------------------------------------------------------------------')
%
for iZ = 1:length(zZi)
    %
    seBHE_table = BHE_screening_table(zZi(iZ),kphot,n_gauleg,epsi_gauleg,screening_model,screening_hxr_params);
    %
end

