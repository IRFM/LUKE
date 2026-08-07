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
%
% Build atomic electron density by DFT with GAUSSIAN-09 code.
%
% This script may be run on any machine, but the GAUSSIAN code, that is
% precompiled (binaries only) must run on a linux 64 bits machine. The version of GAUSSIAN
% used here is 09. For version 16, some modifications must be considered in
% the script. Note that the csh shell environment and openmotif must be
% installed on the linux machine to run GAUSSIAN. Note that with proper
% environment installation, GAUSSIAN code crashes (core dump). In particular, the rights
% of the folders lust be carefully setup. 
%
% The distributed computing is performed with htcondor scheduler on the remote
% machine, which must be setup first. Check that condor_status and
% condor_q work well through a ssh connection. If not, modify the file
% /etc/environment (root, linux) to define CONDOR_CONFIG and CONDOR
% environment variables, and add ~/condor/bin and ~/condor/sbin to PATH. 
%
% The calculations require an accurate analysis of the spin multiplicity (see the corresponding matlab script),
% especially for high-Z atoms. Above Z = 36 (Krypton), relativistic corrections must be considered. 
%
% Post-processing 'Multiwfn' tool is used to extract data useful for LUKE
% calculations.
%
% NOTE : GAUSSIAN must be installed at the user session level on the remote machine. 
%
%By Y. Savoye-Peysson CEA-IRFM <yves.savoye-peysson@cea.fr>
%
%close all
clear all
clc
%
% ---------------------- INPUT PARAMETERS ---------------------
%
user = 'yves';
%
%[ip,id,codename] = connections_params('GAUSSIAN','','home-aix.yvespeysson.fr');%Create a file in the LUKE path (or local) : id -> hostname, ip -> ethernet address, code type -> GAUSSIAN or GRASP2018
[ip,id,codename] = connections_params('GAUSSIAN','','');%Create a file in the LUKE path (or local) : id -> hostname, ip -> ethernet address, code type -> GAUSSIAN or GRASP2018
%
Z = 9;%Helium (2), Lithium (3), Argon (18), Copper (29), Xenon (54), Tungsten (74), Gold (79). Z may be a vector.  
Z0 = [];%if empty, all ionization states are calculated, otherwise only the selected ones are calculated [1:n]. If Z is a vector, Z0 = [];
%
mode = 0;%(0): the script wait until all calculations are done, (1): the script is terminated while calculations are still running on the remote machine. It must be launched again to check if calculations are terminated. 
cancel = 0;%enforce cancel calculations
%
% ----------------------- CODE SETTINGS ----------------------
%
code.codepath = 'g09';%relative path
%
code.codetype = lower(codename);%GAUSSIAN code version 09
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
% ------------------------------------------------------------
%
disp('-------------------')
disp(['GAUSSIAN-09 atomic code distributed (remote) calculations : ',elements('atomic_number', Z, 'name'),' (',int2str(Z),')'])
%
if isempty(Z0)
    %
    disp('All ionization states will be calculated.')
    %
else
    %
    disp(['Calculated ionization state(s) : ',int2str(Z0),'.'])
    %
end
%
disp('-------------------')
%
% ----------------------- REMOTE SETUP ----------------------
%
if length(Z) > 1
    Z0 = [];%all ionization states are calculated
end
%
job_status = ones(1,length(Z));%
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
        %
        ik = 1;
        %
    else
        %
        ik = ik + 1;
        %
    end
    %
end
%
if sum(job_status) == 0
    %
    disp('---> All jobs are done and results are saved in corresponding files')
    delete dft_job_status.mat
    %
else
    %
    save dft_job_status.mat job_status
    disp(['---> ',int2str(sum(job_status)),'/',int2str(length(job_status)),' jobs are active.'])
    disp('-----------')
    disp('Relaunch test_dft_gaussian.m script to get back all dft results if done.')
    %
end
%