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
%nkphot = 23;%number of photon energies
%
Ec = linspace(0,Ecmax,nEc);
if exist('dkphot','var')
    kphot = [kphot_min:dkphot:kphot_max];
    nkphot = length(kphot);
elseif exist('nkphot','var')
    kphot = linspace([kphot_min,dkphot,nkphot];
else
    error('dkphot or nkphot must be defined')
end
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
disp('------------------------------------------------------------------------------')
disp('Build table for fast bremsstrahlung calculations with partial screening effect')
disp('------------------------------------------------------------------------------')
%
[x_leg,w_leg] = gauleg_dke_yp(n_gauleg,epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
%
disp('Gauss Legendre calculation done.')
%
for iZ = 1:length(zZi)
    %
    element = elements('atomic_number', zZi(iZ), 'name');
    disp(['Element = ',element])
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
    save(['Tables/seBHE_',int2str(zZi(iZ)),'_',screening_model.screening_model,'_',int2str(nEc),'_',int2str(Ecmax),'_',int2str(kphot_min),'_',int2str(kphot_max),'_',int2str(nkphot),'_',int2str(n_gauleg),'.mat'],'seBHE_table');
    %
end