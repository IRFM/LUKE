% test script for remote ALOHA calculations
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
close all
clear all
clc
%
shot = 55539;%shot number (Tore Supra or WEST)
port = 'Q6A';%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
tmin = 4.3;%time interval for data averaging (s)
tmax = 4.5;%time interval for data averaging (s)

shot = 27503;%shot number (Tore Supra or WEST)
port = 'Q6A';%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
tmin = 4.5;%time interval for data averaging (s)
tmax = 5.0;%time interval for data averaging (s)
%
display_mode = 1;%display signal (1) or not (0)
%
% ALOHA simulations
%
ii = 1;
%
simul_params(ii).id = 'ne_enforced_1.0';
simul_params(ii).remote.profile = 17;%remote profile number (list available by typing dispremoteprofiles in command window. Choose a profile with a scheduler) 
%
simul_params(ii).optim.method = 0;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
simul_params(ii).optim.ne_guess = 1.0e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
simul_params(ii).optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
simul_params(ii).optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
simul_params(ii).optim.nitmax = 2;%Maximum number of iterations (if optim.method = 1)
%
simul_params(ii).module.upper = 1;%Power spectrum for upper module of each antenna (1), no calculations (0)
simul_params(ii).module.lower = 1;%Power spectrum for lower module of each antenna (1), no calculations (0)
%
ii = ii + 1;
%
simul_params(ii).id = 'ne_enforced_1.2';
simul_params(ii).remote.profile = 17;%remote profile number (list available by typing dispremoteprofiles in command window) 
%
simul_params(ii).optim.method = 0;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
simul_params(ii).optim.ne_guess = 1.2e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
simul_params(ii).optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
simul_params(ii).optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
simul_params(ii).optim.nitmax = 2;%Maximum number of iterations (if optim.method = 1)
%
simul_params(ii).module.upper = 1;%Power spectrum for upper module of each antenna (1), no calculations (0)
simul_params(ii).module.lower = 1;%Power spectrum for lower module of each antenna (1), no calculations (0)
%
ii = ii + 1;
%
simul_params(ii).id = 'ne_enforced_1.3';
simul_params(ii).remote.profile = 17;%remote profile number (list available by typing dispremoteprofiles in command window) 
%
simul_params(ii).optim.method = 0;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
simul_params(ii).optim.ne_guess = 1.3e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
simul_params(ii).optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
simul_params(ii).optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
simul_params(ii).optim.nitmax = 2;%Maximum number of iterations (if optim.method = 1)
%
simul_params(ii).module.upper = 1;%Power spectrum for upper module of each antenna (1), no calculations (0)
simul_params(ii).module.lower = 1;%Power spectrum for lower module of each antenna (1), no calculations (0)
ii = ii + 1;
%
simul_params(ii).id = 'ne_enforced_1.4';
simul_params(ii).remote.profile = 17;%remote profile number (list available by typing dispremoteprofiles in command window) 
%
simul_params(ii).optim.method = 0;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
simul_params(ii).optim.ne_guess = 1.4e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
simul_params(ii).optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
simul_params(ii).optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
simul_params(ii).optim.nitmax = 2;%Maximum number of iterations (if optim.method = 1)
%
simul_params(ii).module.upper = 1;%Power spectrum for upper module of each antenna (1), no calculations (0)
simul_params(ii).module.lower = 1;%Power spectrum for lower module of each antenna (1), no calculations (0)
%
ii = ii + 1;
%
simul_params(ii).id = 'ne_optimized_1.8';
simul_params(ii).remote.profile = 17;%5;%remote profile number (list available by typing dispremoteprofiles in command window) 
%
simul_params(ii).optim.method = 1;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
simul_params(ii).optim.ne_guess = 1e18;%Edge density in front of the grill (initial guess or enforced value) (m-3)
simul_params(ii).optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
simul_params(ii).optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
simul_params(ii).optim.nitmax = 10;%Maximum number of iterations (if optim.method = 1)
%
simul_params(ii).module.upper = 1;%%Power spectrum for upper module of each antenna (1), no calculations (0)
simul_params(ii).module.lower = 1;%Power spectrum for lower module of each antenna (1), no calculations (0)
%
ii = ii + 1;
%
simul_params(ii).id = 'ne_optimized_0.8';
simul_params(ii).remote.profile = 17;%5;%remote profile number (list available by typing dispremoteprofiles in command window) 
%
simul_params(ii).optim.method = 1;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
simul_params(ii).optim.ne_guess = 8e16;%Edge density in front of the grill (initial guess or enforced value) (m-3)
simul_params(ii).optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
simul_params(ii).optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
simul_params(ii).optim.nitmax = 10;%Maximum number of iterations (if optim.method = 1)
%
simul_params(ii).module.upper = 1;%%Power spectrum for upper module of each antenna (1), no calculations (0)
simul_params(ii).module.lower = 1;%Power spectrum for lower module of each antenna (1), no calculations (0)
%
if ~exist('ALOHA/Simulations/')
    mkdir('ALOHA/Simulations/')
end
%
for ii = 1:length(simul_params)
    %
    if ~exist(['ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id,'.mat'])
        %
        antennas = run_aloha_remote(port,shot,tmin,tmax,display_mode,simul_params(ii));
        %
        save(['ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id,'.mat'],'antennas')
        %
        disp(['---> simulation (',int2str(ii),'): is running.'])
        %
    else
        %
        disp(['---> ALOHA simulation #',int2str(ii),' status :'])
        %
        load(['ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id,'.mat'],'antennas')
        %
        antennas = run_aloha_remote(antennas);
        %
        save(['ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id,'.mat'],'antennas')
        %
        flag_job = 0;
        flag_err = 0;
        %
        for jj = 1:length(antennas)
            %
            if isfield(antennas(jj).aloha,'job')
                disp([' - job #',int2str(jj),' is still running.'])
            elseif isfield(antennas(jj).aloha,'err')
                 disp([' - job #',int2str(jj),' failed. Load ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id,'.mat file and type antennas{',int2str(ii),'}.aloha.err(:) in the command to see the error log.'])
            else
                disp([' - job #',int2str(jj),' is completed.'])
            end
        end
        %
    end
end
%

