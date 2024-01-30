%
% Build atomic electron density by solving the MCDHF (Multi-Configuration Dirac-Hartree-Fock) equation as done
% by the GRASP2018 code. Test form factor and g screening function with simple models.
%
% GRASP Manual for Users. Atoms 11 (2023) 68 by Jönsson, P. et al. (https://doi.org/10.3390/atoms11040068)
%
% NOTE : GRASP2018 must be installed and compiled at the user session level on the
% remote machine. The binaries must be on the $PATH global enbvironment.
% General installation of Intel OneAPI compiler environment must be also
% performed prior running the script. 
%
% The distributed computing is performed with htcondor scheduler on the remote
% machine, which must be setup first. Check that condor_status and
% condor_q work well through a ssh connection. If not, modify the file
% /etc/environment (root, linux) to define CONDOR_CONFIG and CONDOR
% environment variables, and add ~/condor/bin and ~/condor/sbin to PATH. 
% 
close all
clear all
clc
%
% ---------------------- INPUT PARAMETERS ---------------------
%
% direct remote scheduler is enforced (htcondor is not always working well)
remote_mode = 0;%(0): the script wait until all calculations are done, (1): the script is terminated while calculations are still running on the remote machine. It must be launched again to check if calculations are terminated. 
remote_cancel = 0;%enforce cancel calculations
%
Z = [74];%Helium (2), Lithium (3), Neon [10], Argon (18), Copper (29), Xenon (54), Tungsten (74), Gold (79)
Z0 = [0:10];%if empty, all ionization states are calculated, otherwise only the selected ones are calculated [1:n]. If Z is a vector, Z0 = [];
%
%[ip,id,codename] = connections_params('GRASP2018','yves','home-aix.yvespeysson.fr');%Create a file in the LUKE path (or local) : id -> hostname, ip -> ethernet address, code type -> GAUSSIAN or GRASP2018
[ip,id,codename] = connections_params('GRASP2018','','');%Create a file in the LUKE path (or local) : id -> hostname, ip -> ethernet address, code type -> GAUSSIAN or GRASP2018
%
% ----------------------- CODE SETTINGS ----------------------
%
code.codetype = lower(codename);%GRASP code version 2018
%
% rnucleus grasp function (generation of nuclear data for electron-nucleus interaction in the electronic Hamiltonian)
%
code.rnucleus.nuclear.spin = 1;%Nuclear spin (I) (in units of h / 2 pi)
code.rnucleus.nuclear.dipole = 1;%Nuclear dipole moment (in nuclear magnetons)
code.rnucleus.nuclear.quadrupole = 1;%Nuclear quadrupole moment (in barns)
%
% rcsfgenerate (generation of the list of CSFs --> see the script grasp_rcsfgenerate_yp.m and atomic_groundstates.m)
%
code.rcsfgenerate.order = '*';
code.rcsfgenerate.excitation = 0;
%
% rangular grasp function (angular integration)
%
code.rangular.fullinteraction = 'y';%y : yes, n : no
%
% rwfnestimate grasp function (estimatation of the radial wave functions for orbitals)
%
code.rwfnestimate.default_settings = 'y';% default settings : y -> yes, n -> no
code.rwfnestimate.subshell_radial_wavefunctions = 2;%1 : GRASP92 File,2 : Thomas-Fermi, 3 : Screened Hydrogenic, 4 : Screened Hydrogenic [custom Z]
code.rwfnestimate.list_of_relativistic_subshells = '*';% all : *
%
% rmcdhf grasp function (determination of the radial orbitals and the expansion coefficients of the CSFs in a self-onsistent field procedure)
%
code.rmcdhf.default_settings = 'y';% default settings : y -> yes, n -> no
code.rmcdhf.ASF_serial_numbers_for_each_block = 1; 
code.rmcdhf.orbitals_to_be_varied = '*'; 
code.rmcdhf.spectroscopic_orbitals = '*'; 
code.rmcdhf.maximum_number_of_SCF_cycles = 100;
%
% rci grasp function (configuration interaction program)
%
code.rci.default_settings = 'y';% default settings : y -> yes, n -> no
code.rci.contribution_of_H = 'y';
code.rci.modify_all_transverse_photon_frequencies = 'y';
code.rci.scale_factor = 1.E-6;
code.rci.include_H_vacuum_polarisation = 'y';
code.rci.include_H_normal_mass_shift = 'n';
code.rci.include_H_specific_mass_shift = 'n';
code.rci.estimate_self_energy = 'y';
code.rci.largest_n_quantum_number_for_including_self_energy = 5;% max 8
%
% rdensity grasp function (atomic density calculation)
%
code.rdensity.default_settings = 'y';% default settings : y -> yes, n -> no
code.rdensity.mixing_coefficients_from_CI_calc = 'y';
code.rdensity.egvc_order = 2;% By looking at (1) : the dominant component, (2) : the decreasing order of the egv(nblocs)
%
% ------------------------------------------------------------
%
disp('-------------------')
disp(['GRASP2018 atomic code distributed (remote) calculations : ',elements('atomic_number', Z, 'name'),' (',int2str(Z),')'])%
%
if isempty(Z0)
    %
    disp('All ionization states will be calculated.')
    %
else
    %
    disp(['Calculated ionization state(s) : ',int2str(Z0)])
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
job_status = ones(1,length(Z));
%
if ~exist('mcdhf_job_status.mat')
    %
    save mcdhf_job_status.mat job_status
    %
else
    %
    load mcdhf_job_status.mat job_status
    %
end
%
ik = 1;%computer index
%
for iZ = 1:length(Z)
    %
    if job_status(iZ) == 1
        %
        code.rootpath = ['/home/',id{ik},'/GRASP2018/'];%absolute path of MCDHF code on remote machine
        code.fortran = ['. /opt/intel/oneapi/2024.0/oneapi-vars.sh'];%Intel Fortran should be installed on the remote machine
        %
        remote.id = id{ik};
        remote.ip = ip{ik};
        remote.remotedir = ['/home/',id{ik},'/mcdhf_shell_scripts_',code.codetype,'_',int2str(Z(iZ))];
        remote.mode = remote_mode;
        remote.scheduler = 'none';%enforced
        %
        mcdhf = mcdhf_electron_density_yp(Z(iZ),Z0,code,remote,remote_cancel);%remote calculation
        %
        if isfield(mcdhf,'datesave')
            %
            job_status(iZ) = 0;%job done
            %
        end
        %
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
    delete mcdhf_job_status.mat
    %
else
    %
    save mcdhf_job_status.mat job_status
    disp(['---> ',int2str(sum(job_status)),'/',int2str(length(job_status)),' jobs are active.'])
    disp('-----------')
    disp('Relaunch test_mcdhf_grasp.m script to get back all mcdhfresults if done.')
    %
end
