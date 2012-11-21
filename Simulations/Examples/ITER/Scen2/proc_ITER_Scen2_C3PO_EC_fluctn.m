% script proc_ITER_Scan2_C3PO_EC_fluctn_Nscan
%
clear
close all
%
p_opt = -1;
display_mode = 2;
%
id_equil = 'ITER_Scen2_200103121816_430_129';% For plasma equilibrium
id_fluct = 'fluctn';% Fluctuation model
id_wave = 'C3PO_NTM_32';
locid_simul = '_24rays';%Simulation ID
locid_wave_ref = '_20MW_24rays';%'_20MW_1ray';%NaN;%
%
sigmar_max = [0.4];%[0.5];% Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
sigmar_hwhm = [0.02];% Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
Nfluct = [1];% Ratio of the LUKE evolution time (phase refresh) to the fluctuation time - also equal to the number of duplicated rays
%
tn = 100i;%50;% Final simulation time (normalized to the central thermal collision time) 
dtn = 1i;%1;% internal LUKE time step. As an imaginary number, dkeparam.dtn prescribes the number of internal time steps
%
% *************************************************************************
%
id_simul0 = [id_equil,'_',id_wave,'_',id_fluct,locid_simul];
%
id_simul = [id_simul0,'_sigma',num2str(sigmar_max),'_delta',num2str(sigmar_hwhm),'_dtn',num2str(dtn),'_tn',num2str(tn),'_Nfluct',num2str(Nfluct)];
id_simul(id_simul == '.') = 'p';
id_simul(id_simul == '+') = 'p';
%
filename = ['backup_',id_simul,'.mat'];
%
if ~isnan(locid_wave_ref),
    %    
    id_simul_ref = [id_equil,'_',id_wave,locid_wave_ref];
    %
    filename_ref = ['ZFLUCT_',id_simul_ref,'.mat'];
    %
    data_ref = load(filename_ref,'Zfluct');
    Zfluct_ref = data_ref.Zfluct;
    %
else
    %
    Zfluct_ref = '';
    %
end
%
Zfluct = fproc_fluctn_jd(filename,display_mode,Zfluct_ref);
%
    
    
    
    
    