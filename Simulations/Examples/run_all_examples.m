%Script that runs all benchmarks in one pass. May take few hours. Prior to
%run this script, all the *.mat files in the ~/Project_DKE/Database
%directory must be created.
%
% by Yves Peysson (CEA/DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
% ---------------------- ITER Scen 4 LHCD ------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['ITER',filesep,'Scen4',filesep,'EQUIL']);
if exist('EQUIL_ITER_Scen4.mat','file') == 0 || forcerun,
    make_equil_ITER_Scen4
else
    info_dke_yp(2,'Magnetic equilibrium calculations for ITER/Scen4 skipped because already done !')      
end
cd ../../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['ITER',filesep,'Scen4']);
if exist('LUKE_RESULTS_ITER_Scen4_C3PO_f5_N2_dN0.2.mat','file') == 0 || forcerun,
    rundke_ITER_Scen4_C3PO_f5_N2_dN0p2
else
    info_dke_yp(2,'LUKE calculations for ITER/Scen4 skipped because already done !')      
end
cd ../..
%
% ---------------------- ITER Scen 2 ECCD ------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['ITER',filesep,'Scen2']);
if exist('LUKE_RESULTS_ITER_Scen2_200103121816_430_129_C3PO_NTM_32.mat','file') == 0 || forcerun,
    rundke_ITER_Scen4_C3PO_EC
else
    info_dke_yp(2,'LUKE calculations for ITER/Scen2 skipped because already done !')      
end
cd ../..
%
% ---------------------- TS 32299 -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TS',filesep,'32299']);
if exist('WAVE/C3PO/WAVE_TS_32299_100.0117_TS_Coupleur_C1.mat','file') == 0 ||...
        exist('WAVE/C3PO/WAVE_TS_32299_100.0117_TS_Coupleur_C2.mat','file') == 0 || forcerun,
    run_cronos_C3PO;
else
    info_dke_yp(2,'C3PO calculations for TS/32299 skipped because already done !')      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TS',filesep,'32299']);
if exist('DKE_RESULTS_TS_32299_100.0117_alpha_0_Dr0_0.mat','file') == 0 || forcerun,
	run_cronos_starwars;
else
    info_dke_yp(2,'LUKE calculations for TS/32299 skipped because already done !')      
end
cd ../..
%
