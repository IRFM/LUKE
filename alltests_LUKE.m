%LUKE - Script that runs all tests in one pass
%
%Script that runs all tests in one pass. May take few hours. Prior to
%run this script, all the *.mat files in the ~/Project_DKE/Database
%directory must be created.
%
% by Yves Peysson (CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/IRFM, joan.decker@cea.fr)
%
% ---------------------- Benchmarks -----------------------
%
cd(['Simulations',filesep,'Benchmarks']);
run_all_benchmarks;
cd('../..')
%
% ---------------------- Examples -----------------------
%
cd(['Simulations',filesep,'Examples']);
run_all_examples;
cd('../..')
%
% ---------------------- C3PO -----------------------
%
cd(['Project_DKE',filesep,'Modules',filesep,'C3PO',filesep,'Examples']);
run_all;
cd('../../../..')
%
% ---------------------- Packages -----------------------
%
cd(['Project_DKE',filesep,'Packages']);
test_packages_dke_yp
cd('../..')
%
% ---------------------- Distributed computing -----------------------
%
cd([dkepath.luke_root,'Project_DKE',filesep,'Packages',filesep,'MDCE']);
run_mdce
cd('../../..')
%
disp('*********** ALL TESTS DONE **************');