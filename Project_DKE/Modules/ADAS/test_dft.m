%
% Build atomic electron density from DFT calculations and test form factor
% and g screening function with simple models 
%
% WARNING : the csh shell environment must be installed for Gaussian code
%
%close all
clear all
clc
%
% ---------------------- INPUT PARAMETERS ---------------------
%
[ip,id] = connections_params;%Create a file in the LUKE path (or local) : id -> hostname, ip: ethernet address
%
Z = [2,3];%Helium (2),Lithium (3),Copper (29)
Z0 = [];%if empty, all ionization states are calculated, otherwise only the selected ones are calculated [1:n]. If Z is a vector, Z0 = [];
%
mode = 0;%(0): the script wait until all calculations are done, (1): the script is terminated while calculations are still running on the remote machine. It must be launched again to check if calculations are terminated. 
cancel = 0;%enforce cancel calculations
%
% ----------------------- CODE SETTINGS ----------------------
%
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
% ----------------------- REMOTE SETUP ----------------------
%
if length(Z) > 1
    Z0 = [];%all ionization states are calculated
end
%
ik = 1;%computer index
%
for iZ = 1:length(Z)
    %
    code.rootpath = ['/home/',id{ik},'/GAUSSIAN/'];%absolute path of DFT code on remote machine
    %
    remote.id = id{ik};
    remote.ip = ip{ik};
    remote.remotedir = ['/home/',id{ik},'/dft_shell_scripts_',code.codetype,'_',int2str(Z(iZ))];
    remote.mode = mode;
    %
    dft(iZ) = dft_electron_density_yp(Z(iZ),Z0,code,remote,cancel);%remote calculation
    %
    if ik == length(id)
        ik = 1;
    else
        ik = ik + 1;
    end
end
%
disp('Relaunch test_dft.m script to get back dft results if calculations are done.')
%