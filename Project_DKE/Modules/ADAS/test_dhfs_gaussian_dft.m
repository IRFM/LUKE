%
% Build atomic electron density from resolution of the relativistic Dirac-Hartree-Fock-Slater equation and test form factor
% and g screening function with simple models. Use Gaussian atomic code. 
%
% WARNING : the csh shell environment must be installed for Gaussian code
%
%close all
clear all
clc
%
% ---------------------- INPUT PARAMETERS ---------------------
%
[ip,id] = connections_params('yves');%Create a file in the LUKE path (or local) : id -> hostname, ip: ethernet address. Must be customized according to the machine where calculations are done.
%
Z = 78;%Helium (2), Lithium (3), Argon (18), Copper (29), Xenon (54), Tungsten (74), Gold (79)
Z0 = [];%if empty, all ionization states are calculated, otherwise only the selected ones are calculated [1:n]. If Z is a vector, Z0 = [];
%
mode = 0;%(0): the script wait until all calculations are done, (1): the script is terminated while calculations are still running on the remote machine. It must be launched again to check if calculations are terminated. 
cancel = 0;%enforce cancel calculations
%
disp('-------------------')
disp(['GAUSSIAN atomic code remote calculations : ',elements('atomic_number', Z, 'name'),' (',int2str(Z),')'])
%
if isempty(Z0)
    %
    disp('All ionization states are calculated.')
    %
else
    %
    disp(['Ionization states that are calculated : ',inst2str(Z0),'.'])
    %
end
disp('-------------------')
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
job_status = ones(1,length(Z));
%
if ~exist('dft_job_status.mat')
    %
    save dft_job_status.mat job_status
    %
else
    %
    load dft_job_status.mat job_status
    %
end
%
ik = 1;%computer index
%
for iZ = 1:length(Z)
    %
    if job_status(iZ) == 1
        %
        code.rootpath = ['/home/',id{ik},'/GAUSSIAN/'];%absolute path of DFT code on remote machine
        %
        remote.id = id{ik};
        remote.ip = ip{ik};
        remote.remotedir = ['/home/',id{ik},'/dft_shell_scripts_',code.codetype,'_',int2str(Z(iZ))];
        remote.mode = mode;
        %
        dft = dft_electron_density_yp(Z(iZ),Z0,code,remote,cancel);%remote calculation
        %
        if isfield(dft,'datesave')
            %
            job_status(iZ) = 0;%job done
            %
        end
    end
    %
    if ik == length(id)
        ik = 1;
    else
        ik = ik + 1;
    end
    %
end
%
if sum(job_status) == 0
    disp('---> All jobs are done and results are saved in corresponding files')
    delete dft_job_status.mat
else
    save dft_job_status.mat job_status
    disp(['---> ',int2str(sum(job_status)),'/',int2str(length(job_status)),' jobs are active.'])
    disp('-----------')
    disp('Relaunch test_dft.m script to get back all dft results.')
end
%