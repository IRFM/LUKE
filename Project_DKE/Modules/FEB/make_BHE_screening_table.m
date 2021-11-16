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
kphot_max = 240;%keV
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
    element = elements('atomic_number', zZi(iZ), 'name');
    %
    Z0 = [0:1:zZi(iZ)];%all ionization states
    %    
    seBHE = zeros(n_gauleg,nEc,length(kphot),length(Z0));
    %
    tstart = tic;
    %
    for ik = 1:length(kphot)
        seBHE(:,:,ik,:) = bhe_dke_yp(Ec,kphot(ik),x_leg,zZi(iZ),screening_hxr_params,screening_model);%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert) with screening effect (mec2 -> keV units)
    end
    %
    elapsed_time = toc(tstart);
    %
    seBHE_table.comment = 'Bethe-Heitler-Elwert bremsstrahlung cross-section with screening effects';
    seBHE_table.element = element;
    seBHE_table.Z0 = Z0;
    seBHE_table.screening_hxr_params = screening_hxr_params;
    seBHE_table.screening_model = screening_model;
    seBHE_table.Ec = Ec;
    seBHE_table.kphot = kphot;
    seBHE_table.n_gauleg = n_gauleg;
    seBHE_table.epsi_gauleg = epsi_gauleg;
    seBHE_table.x_leg = x_leg;
    seBHE_table.w_leg = w_leg;
    seBHE_table.seBHE = seBHE;
    %
    clc
    %
    disp(['Z = ',int2str(zZi(iZ)),' done in ',num2str(elapsed_time),' (s)']);
    %
    save(['seBHE_',int2str(zZi(iZ)),'_',screening_model.screening_model,'.mat'],'seBHE_table');
    %
end