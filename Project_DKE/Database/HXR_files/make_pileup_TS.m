%Simulations of the pile-up effect on HXR photon energy spectrum as
%function of the count rate
%
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker CEA-DRFC (joan.decker@cea.fr)
%
clear all
pileup_id = 'TS-DSPX';%Set here the name (identifier) of the HXR diagnostic electronic system
%
% Pulse shape parameters
%
diag.tok = 'TS';
diag.namediag = 'DSPX';
diag.theta = 0.25;%Shaping time (microsecond)
diag.tc0 = 3.0;%Coding time ADC (microsecond)
diag.tpeak = 0.5; 
diag.tl0 = 7.3;
diag.tp0 = 2.35;
diag.beta = 5;%For pulse shape
diag.kmin = 20;%Lower limit of the photon energy spectrum [kev]
diag.kmin0 = diag.kmin;
diag.kmax = 180;%Upper limit of the photon energy spectrum [kev]
diag.nhisto = 8;%Number of channels
diag.khistotphmin = 50;%Minimum photon energy of the interval for calculating the photon temperature [keV]
diag.khistotphmax = 110;%Maximum photon energy of the interval for calculating the photon temperature [keV]
%
% Pile-up simulation parameters
%
pileupsim.pur = 1;%Pile-up rejection system On (1) or OFF (0)
pileupsim.nreset = 3;%Random number generator reset number
pileupsim.typspec = 2;%Line photon energy spectrum (1) or exponential (2)
pileupsim.Ni0 = 50000;%Plasma photon count rate (photon/s)
pileupsim.ech = 1;%Scaling for the Monte-Carlo calculations (for reducing the computational effort, increasing ech)
pileupsim.k0 = 30;%Characteristic decay energy of the photon spectrum for exponential case or line energy for the line case  (keV) 
pileupsim.modeMC = 1;%(1) number of input photon for the Monte-Carlo is the pile-up level from theoretical calculations, (0) Monte-Carlo use NiMC
pileupsim.NiMC = 100000;%Plasma photon count rate for the Monte-Carlo (photon/s)
pileupsim.seuil = 0.6;%Fraction of pile-up
pileupsim.p_opt = 2;%Figure printing options
pileupsim.filename = pileup_id ;%Figure printing options
%
eval(['save PILEUP_',pileup_id,'.mat diag pileupsim']);

