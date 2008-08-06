%Script that runs all benchmarks in one pass. May take few hours. Prior to
%run this script, all the *.mat files in the ~/Project_DKE/Database
%directory must be created.
%
% by Yves Peysson (CEA/DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
% ---------------------- ITER -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['ITER',filesep,'Scen4',filesep,'EQUIL']);
w = what;
if size(w.mat,1) ~= 2 | forcerun,
   make_equil_ITER;
   make_equil_ITER_IAEA06;
else
   info_dke_yp(2,['Magnetic equilibrium calculations for ITER/Scen4 skipped because already done !'])      
end
cd ../../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['ITER',filesep,'Scen4',filesep,'WAVE',filesep,'C3PO']);
w = what;
if size(w.mat,1) ~= 28 | forcerun,
   make_rayinit_ITER_Scen4_all;
   make_rayinit_ITER_Scen4_Alpha_all;
   %
   make_wave_ITER_Scen4_all;
   make_wave_ITER_Scen4_Alpha_all;
else
   info_dke_yp(2,['C3PO calculations for ITER/Scen4 skipped because already done !'])      
end
cd ../../../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['ITER',filesep,'Scen4']);
w = what;
if size(w.mat,1) ~= 9 | forcerun,
   rundke_ITER_Scen4_IAEA06_all;
   rundke_ITER_Scen4_IAEA06_Alpha_all;
   proc_ITER
else
   info_dke_yp(2,['LUKE calculations for ITER/Scen4 skipped because already done !'])      
end
cd ../..
%
% ---------------------- TS -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TS',filesep,'32299']);
w = what;
if size(w.mat,1) ~= 29 | forcerun,
   run_cronos_C3PO;
   run_cronos_starwars;
   run_cronos_starwars_Alpha_scan;
   run_cronos_starwars_Dr0_scan;
else
   info_dke_yp(2,['C3PO/LUKE calculations for TS/32299 skipped because already done !'])      
end
cd ../..
%
