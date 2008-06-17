%LUKE - Script that runs all tests in one pass
%
%Script that runs all tests in one pass. May take few hours. Prior to
%run this script, all the *.mat files in the ~/Project_DKE/Database
%directory must be created.
%
% by Yves Peysson (CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/IRFM, joan.decker@cea.fr)
%
dkepath = path_LUKE_LOCAL;
%
% ---------------------- Benchmarks -----------------------
%
cd([dkepath.luke_root,'Simulations',filesep,'Benchmarks']);
run_all_benchmarks;
%
% ---------------------- Examples -----------------------
%
cd([dkepath.luke_root,'Simulations',filesep,'Examples']);
run_all_examples;
%
% ---------------------- C3PO -----------------------
%
cd([dkepath.luke_root,'Project_DKE',filesep,'Modules',filesep,'RT',filesep,'Examples']);
run_all;
%
% ---------------------- Packages -----------------------
%
cd([dkepath.luke_root,'Project_DKE',filesep,'Packages']);
test_packages_dke_yp
%
% ---------------------- Distributed computing -----------------------
%
cd([dkepath.luke_root,'Project_DKE',filesep,'Packages',filesep,'MDCE']);
run_mdce
%
disp('*********** ALL TESTS DONE **************');