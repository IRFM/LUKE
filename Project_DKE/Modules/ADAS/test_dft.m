%
% Build atomic electron density from DFT calculations and test form factor
% and g screening function with simple models 
%
%close all
clear all
clc
%
code.rootpath = '/home/ypeysson/GAUSSIAN/';%aboslute path
code.codepath = 'g09';%relative path
%
code.codetype = 'gaussian';
%
code.functional = 'PBE1PBE';%hybrid-exchange correlation functional
%code.basis.mode = '6-311G';%Non relativistic calculations, valid up to Krypton (Z = 36) approx. (see Gaussian documentation)
%code.basis.mode = 'AUG-cc-pVDZ';%Non relativistic calculations, valid up to Krypton (Z = 36) approx. (see Gaussian documentation)
%code.basis.mode = 'cc-pVDZ';%Non relativistic calculations, valid up to Krypton (Z = 36) approx. (see Gaussian documentation)
code.basis.mode = 'gen/Auto';%Relativistic case calculations. To be used with ANO-RCC basis set exchange basis (download from www.basissetexchange.org)
code.basis.external = 'ANO-RCC';%Relativistic case calculations. To be used with ANO-RCC basis set exchange basis (download from www.basissetexchange.org)
code.equation = 'Integral=DKH2';%Relativistic case calculations. Douglas-Kroll-Hess second order scalar relativistic Hamiltonian. (Z > 36)
%code.grid = 'Grid=SuperFineGrid';%FineGrid, UltraFine, SuperFineGrid types of grids for Gaussian (leave empty for automatic grid size)
%
code.mem = '5GB';%allocated memory (use 64bits Gaussian, 2GB max for 32bits Gaussian code only)
code.procs = '4';%number of shared cores (use 64bits Gaussian, A proc max for 32bits Gaussian code only)
%
code.postprocpath = 'Multiwfn';%Post-processing path, absolute or relative path to rootpath
code.postproccode = 'Multiwfn';%Post-processing tool
code.postprocgrid = 3000;%Post-processing grid size (default = 800)
%
remote.id = 'ypeysson';
remote.ip = 'home-lyon.yvespeysson.fr';
remote.remotedir = ['/home/ypeysson/dft_shell_scripts_',code.codetype];
remote.mode = 0;%(0): the script wait until all calculations are done, (1): the script is terminated while calculations are still running on the remote machine. It must be launched again to check if calculations are terminated. 
%
Z = 29;
Z0 = [];%if empty, all ionization states are calculated, otherwise only the selected ones are calculated [1:n]
%
cancel = 0;
%
dft = dft_electron_density_yp(Z,Z0,code,remote,cancel);%remote calculation
%