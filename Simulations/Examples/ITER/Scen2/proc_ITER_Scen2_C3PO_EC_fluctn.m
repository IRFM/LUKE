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
% script proc_ITER_Scan2_C3PO_EC_fluctn_Nscan
%
clear
close all
%
p_opt = -1;
%
fluct_display.mode = 2;
fluct_display.evol = 0;
fluct_display.stat = 0;
%
id_equil = 'ITER_Scen2_200103121816_430_129';% For plasma equilibrium
id_fluct = 'fluctn';% Fluctuation model
id_wave = 'C3PO_NTM_32';
locid_simul = '_24rays';%Simulation ID
locid_wave_ref = '_24rays';%NaN;%'_20MW_24rays';%'_20MW_1ray';%
%
sigmar_max = [0.7];%[0.5];% Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
sigmar_hwhm = [0.02];% Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
Nfluct = [1];% Ratio of the LUKE evolution time (phase refresh) to the fluctuation time - also equal to the number of duplicated rays
%
tn = 100i;%50;% Final simulation time (normalized to the central thermal collision time) 
dtn = 1i;%1;% internal LUKE time step. As an imaginary number, dkeparam.dtn prescribes the number of internal time steps
%
% *************************************************************************
%
id_simul0 = [id_equil,'_',id_wave,locid_simul,'_',id_fluct];
%
id_simul = [id_simul0,'_sigma',num2str(sigmar_max),'_delta',num2str(sigmar_hwhm),'_dtn',num2str(dtn),'_Nfluct',num2str(Nfluct)];
id_simul(id_simul == '.') = 'p';
id_simul(id_simul == '+') = 'p';
%
filename = ['backup_',id_simul,'.mat'];
%
if ~isnan(locid_wave_ref),
    %    
    id_simul_ref = [id_equil,'_',id_wave,locid_wave_ref];
    %
    filename_ref = ['LUKE_RESULTS_',id_simul_ref,'.mat'];
    Zfluct_ref = fproc_fluctn_jd(filename_ref);
    %
else
    %
    Zfluct_ref = '';
    %
end
%
Zfluct = fproc_fluctn_jd(filename,fluct_display,Zfluct_ref);
%
    
    
    
    
    