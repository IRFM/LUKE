function seBHE_table = BHE_screening_table(zZi,kphot,n_gauleg,epsi_gauleg,atomic_model,screening_hxr_params)
%
% Build BHE bremmsstrahlung cross-section table for calculations with partial screening
%
%	Input:
%
%		- zZi: kinetic energy of the incoming electron (keV) [1,m] 
%		- kphot: photon energy (keV)  [1,n] 
%		- n_gauleg : number of Gauss-legendre polynomials
%       - epsi_gauleg : accuracy of the Gauss-Legendre polynomials calculations
%       - atomic_model : may be 'Tseng-Pratt-Botto' or other DFT models (see the .m files)
%       - screening_hxr_params : structure of parameters for partial screening
%
%	Output: 
%
%		- seBHE_table: Bethe-Heitler + Elwert factor bremstrahlung cross-section (m^2) [p,m,n] in a table form
%
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
screening_model.screening_model = atomic_model;
Ec = linspace(0,screening_hxr_params.Ecmax,screening_hxr_params.nEc);
%
[x_leg,w_leg] = gauleg_dke_yp(n_gauleg,epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
%
disp('Gauss Legendre calculation done.')
%
element = elements('atomic_number', zZi, 'name');
disp(['Element = ',element])
%
Z0 = [0:1:zZi];%all ionization states
%    
seBHE = zeros(n_gauleg,screening_hxr_params.nEc,length(kphot),length(Z0));
%
tstart = tic;
%
for ik = 1:length(kphot)
    seBHE(:,:,ik,:) = bhe_dke_yp(Ec,kphot(ik),x_leg,zZi,screening_hxr_params,screening_model);%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert) with screening effect (mec2 -> keV units)
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
disp(['Z = ',int2str(zZi),' done in ',num2str(elapsed_time),' (s)']);
%
save(['Tables/seBHE_',int2str(zZi),'_',screening_model.screening_model,'_',int2str(screening_hxr_params.nEc),'_',int2str(screening_hxr_params.Ecmax),'_',int2str(min(kphot)),'_',int2str(max(kphot)),'_',int2str(length(kphot)),'_',int2str(n_gauleg),'.mat'],'seBHE_table');
%