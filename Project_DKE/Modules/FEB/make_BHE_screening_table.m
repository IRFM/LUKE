%
clear all
close all
clc
%
zZi = [2,3,4,5,6,7,8,26,29,74];
%
nEc = 300;
Ecmax = 1000;%keV
%
kphot_min = 20;%keV
kphot_max = 40;%240keV
dkphot = 10;%keV
%
Ec = linspace(0,Ecmax,nEc);
kphot = [kphot_min:dkphot:kphot_max];
%
n_gauleg = 35;
epsi_gauleg = 1e-14;
%
screening_hxr_params.nphi = NaN;
screening_hxr_params.flag_mem = 1;
screening_hxr_params.ntheta = 2006;
screening_hxr_params.integral = 'simps';
%
screening_model.screening_model = 'Tseng-Pratt-Botto';
%
[x_leg,w_leg] = gauleg_dke_yp(n_gauleg,epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
%
for iZ = 1:length(zZi)
    %
    Z0 = [0:1:zZi(iZ)];%all ionization states
    %    
    seBHE = zeros(n_gauleg,nEc,length(kphot),length(Z0));
    %
    tstart = tic;
    %
    for ik = 1:length(kphot)
        seBHE(:,:,ik,:) = bhe_dke_yp(Ec,kphot(ik),x_leg,zZi(iZ),screening_hxr_params,screening_model);%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert) with screening effect (mec2 -> keV units)
        ik
    end
    %
    elapsed_time = toc;
    %
    disp(['Z = ',int2str(zZi(iZ)),' done in ',num2str(elapsed_time),' (s)']);
    %
    save(['seBHE_',int2str(zZi(iZ)),'.mat'],'seBHE');
    %
end