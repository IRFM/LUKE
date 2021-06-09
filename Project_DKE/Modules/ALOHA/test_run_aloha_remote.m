% test script for remote ALOHA calculations
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
close all
clear all
clc
%{
shot = 27503;%shot number (Tore Supra or WEST)
port = 'Q6A';%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
tmin = 4.5;%time interval for data averaging (s)
tmax = 5.0;%time interval for data averaging (s)
%
shot = 55539;%shot number (Tore Supra or WEST)
port = 'Q6A';%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
tmin = 4.3;%time interval for data averaging (s)
tmax = 4.4;%time interval for data averaging (s)
%}
shot = 28014;%55539;28014;27503;%shot number (Tore Supra or WEST)
port = 'Q6A+Q6B';%'Q6A';'Q6A+Q6B';'Q6A';%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
tmin = 5.5;%4.3;5.5;4.5;%time interval for data averaging (s)
tmax = 6.5;%4.4;6.5;5.0;%time interval for data averaging (s)
%
display_mode = 1;%display and save figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)
%
% ALOHA simulations
%
ii = 0;
%{
iimax = 40;%for density scan
%
ne = linspace(1,2,iimax);%1e17 density units
%
for ii = 1:40
    %
    simul_params(ii).id = ['ne_enforced_',num2str(ne(ii))];
    simul_params(ii).remote.profile = 5;%remote profile number (list available by typing dispremoteprofiles in command window. Choose a profile with a scheduler) 
    %
    simul_params(ii).optim.method = 0;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
    simul_params(ii).optim.ne_guess = ne(ii)*1e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
    simul_params(ii).optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
    simul_params(ii).optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
    simul_params(ii).optim.nitmax = 2;%Maximum number of iterations (if optim.method = 1)
    %
end
%
ii = ii + 1;
%
simul_params(ii).id = 'ne_optimized';
simul_params(ii).remote.profile = 5;%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
%
simul_params(ii).optim.method = 1;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
simul_params(ii).optim.ne_guess = [1.0,10.0]*1e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
simul_params(ii).optim.tolfun = 1e-2;%Relative tolerance on targets (if optim.method = 1)
simul_params(ii).optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
simul_params(ii).optim.nitmax = 10;%Maximum number of iterations (if optim.method = 1)
%}
ii = ii + 1;
%
simul_params(ii).id = 'ne_2';
simul_params(ii).remote.profile = 17;%5;%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
%
simul_params(ii).optim.method = 1;%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
simul_params(ii).optim.ne_guess = [2.0]*1e17;%Edge density in front of the grill (initial guess or enforced value) (m-3)
simul_params(ii).optim.tolfun = 1e-1;%Relative tolerance on targets (if optim.method = 1)
simul_params(ii).optim.tolx = 1e-2;%Relative tolerance on inputs (if optim.method = 1)
simul_params(ii).optim.nitmax = 5;%Maximum number of iterations (if optim.method = 1)
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
        for jj = 1:length(antennas)
            %
            flag_job(ii,jj) = 1;
            %
        end
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
        for jj = 1:length(antennas)
            %
            if isfield(antennas(jj).aloha,'job')
                disp([' - job #',int2str(jj),' is still running.'])
                flag_job(ii,jj) = 1;
            elseif isfield(antennas(jj).aloha,'err')
                 disp([' - job #',int2str(jj),' failed. Load ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id,'.mat file and type antennas{',int2str(ii),'}.aloha.err(:) in the command to see the error log.'])
                 flag_job(ii,jj) = -1;
            else
                disp([' - job #',int2str(jj),' is completed.'])
                flag_job(ii,jj) = 0;
            end
            %
        end
        %
        if ii == 1 && sum(flag_job(ii,:)) == 0 % power spectra are independent of the density in front of the grill. Just the first is plotted
            %
            load(['ALOHA/Data/data_lh_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'.mat'],'data_lh') 
            %
            if length(data_lh) >= 1
                %
                h1 = figure;
                %
                h1.Name = ['Spectrum - ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',data_lh(1).port,'_',simul_params(ii).id];
                %
                tt = strrep(['Spectrum - ALOHA : #',int2str(shot),', dt = [',num2str(tmin),':',num2str(tmax),'], ',data_lh(1).port,', ',simul_params(ii).id],'_','-');
                %
                plot(antennas(1).aloha.results.nz,real(antennas(1).aloha.results.dP_nz)/max(real(antennas(1).aloha.results.dP_nz)),'b-','LineWidth',2),hold on
                plot(antennas(2).aloha.results.nz,real(antennas(2).aloha.results.dP_nz)/max(real(antennas(2).aloha.results.dP_nz)),'r-','LineWidth',2),hold on
                %
                xlim([-8,8]);ylim([0,1])
                %
                title(tt);
                xlabel('n_z')
                ylabel('dP_{LH}/n_z/max(dP_{LH}/n_z)')
                %
                grid minor
                %
                nz_max1 = antennas(1).aloha.results.nz(find(real(antennas(1).aloha.results.dP_nz) == max(real(antennas(1).aloha.results.dP_nz))));
                nz_max2 = antennas(2).aloha.results.nz(find(real(antennas(2).aloha.results.dP_nz) == max(real(antennas(2).aloha.results.dP_nz))));
                %
                legend(['Upper modules (',data_lh(1).port,'), n_{z0} = ',num2str(nz_max1)],['Lower modules (',data_lh(1).port,'), n_{z0} = ',num2str(nz_max2)],'Location','NorthWest');
                %
                drawnow;
                %
            end
            %
            if length(data_lh) == 2
                %
                h1 = figure;
                %
                h1.Name = ['Spectrum - ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',data_lh(2).port,'_',simul_params(ii).id];
                %
                tt = strrep(['Spectrum - ALOHA : #',int2str(shot),', dt = [',num2str(tmin),':',num2str(tmax),'], ',data_lh(2).port,', ',simul_params(ii).id],'_','-');
                %
                plot(antennas(3).aloha.results.nz,real(antennas(3).aloha.results.dP_nz)/max(real(antennas(3).aloha.results.dP_nz)),'b-','LineWidth',2),hold on
                plot(antennas(4).aloha.results.nz,real(antennas(4).aloha.results.dP_nz)/max(real(antennas(4).aloha.results.dP_nz)),'r-','LineWidth',2),hold on
                %
                xlim([-8,8]);ylim([0,1])
                %
                title(tt);
                xlabel('n_z')
                ylabel('(dP_{LH}/n_z)/max(dP_{LH}/n_z)')
                %
                grid minor
                %
                nz_max3 = antennas(3).aloha.results.nz(find(real(antennas(3).aloha.results.dP_nz) == max(real(antennas(3).aloha.results.dP_nz))));
                nz_max4 = antennas(4).aloha.results.nz(find(real(antennas(4).aloha.results.dP_nz) == max(real(antennas(4).aloha.results.dP_nz))));
                %
                legend(['Upper modules (',data_lh(2).port,') , n_{z0} = ',num2str(nz_max3)],['Lower modules (',data_lh(2).port,'), n_{z0} = ',num2str(nz_max4)],'Location','NorthWest');
                %
                drawnow;
                %
            end
        end
    end
end
%
for ii = 1:length(simul_params)
    %
    if sum(flag_job(ii,:)) == 0
        %
        if exist(['ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id,'.mat'])
            %
            load(['ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id,'.mat'],'antennas')
            load(['ALOHA/Data/data_lh_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'.mat'],'data_lh') 
            %
            h1 = figure;
            %
            h1.Name = ['RC - ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id];
            %
            tt = strrep(['RC - ALOHA : #',int2str(shot),', dt = [',num2str(tmin),':',num2str(tmax),'], ',port,', ',simul_params(ii).id],'_','-');
            %
            sgtitle(tt,'Color','Red');
            %
            if length(antennas) == 2
                %
                if isfield(antennas(1).aloha,'results')
                    %
                    subplot(121),plot(data_lh(1).mask.aloha(data_lh(1).mask.upper),data_lh(1).mean.rc_mean_aloha_upper,'bo-','LineWidth',2),hold on
                    xlim([min(data_lh(1).mask.aloha(data_lh(1).mask.upper)),max(data_lh(1).mask.aloha(data_lh(1).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
                    subplot(121),plot(data_lh(1).mask.aloha(data_lh(1).mask.upper),antennas(1).aloha.results.RC,'rx--','LineWidth',2)
                    xlim([min(data_lh(1).mask.aloha(data_lh(1).mask.upper)),max(data_lh(1).mask.aloha(data_lh(1).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
                    legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(1).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
                    title(['Upper module (',data_lh(1).port,')'])
                    if simul_params(ii).optim.method == 0
                        disp(['- Port : ',data_lh(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (enforced) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_upper))])
                    else
                        disp(['- Port : ',data_lh(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(1).aloha.plasma.ne0/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_upper))])
                    end    
                    %
                end
                %
                if isfield(antennas(2).aloha,'results')
                    %
                    subplot(122),plot(data_lh(1).mask.aloha(data_lh(1).mask.lower),data_lh(1).mean.rc_mean_aloha_lower,'bo-','LineWidth',2),hold on
                    xlim([min(data_lh(1).mask.aloha(data_lh(1).mask.lower)),max(data_lh(1).mask.aloha(data_lh(1).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
                    subplot(122),plot(data_lh(1).mask.aloha(data_lh(1).mask.lower),antennas(1).aloha.results.RC,'rx--','LineWidth',2)
                    xlim([min(data_lh(1).mask.aloha(data_lh(1).mask.lower)),max(data_lh(1).mask.aloha(data_lh(1).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
                    legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(2).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
                    title(['Lower module (',data_lh(1).port,')'])
                    if simul_params(ii).optim.method == 0
                        disp(['- Port : ',data_lh(1).port,', Pin = ',num2str(sum(antennas(2).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(2).aloha.results.Ptr_plasma_RC)/1e6),' MW,  ne (enforced) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(2).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_lower))])
                    else
                        disp(['- Port : ',data_lh(1).port,', Pin = ',num2str(sum(antennas(2).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(2).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(2).aloha.plasma.ne0/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(2).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_lower))])
                    end
                    %
                end
                %
                drawnow
                %
            elseif length(antennas) == 4
                %
                if isfield(antennas(1).aloha,'results')
                    subplot(221),plot(data_lh(1).mask.aloha(data_lh(1).mask.upper),data_lh(1).mean.rc_mean_aloha_upper,'bo-','LineWidth',2),hold on
                    xlim([min(data_lh(1).mask.aloha(data_lh(1).mask.upper)),max(data_lh(1).mask.aloha(data_lh(1).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
                    subplot(221),plot(data_lh(1).mask.aloha(data_lh(1).mask.upper),antennas(1).aloha.results.RC,'rx--','LineWidth',2)
                    xlim([min(data_lh(1).mask.aloha(data_lh(1).mask.upper)),max(data_lh(1).mask.aloha(data_lh(1).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
                    legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(1).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
                    title(['Upper module (',data_lh(1).port,')'])
                    if simul_params(ii).optim.method == 0
                        disp(['- Port : ',data_lh(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (enforced) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_upper))])
                    else
                        disp(['- Port : ',data_lh(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(1).aloha.plasma.ne0/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_upper))])
                    end
                end
                %
                if isfield(antennas(2).aloha,'results')
                    subplot(222),plot(data_lh(1).mask.aloha(data_lh(1).mask.lower),data_lh(1).mean.rc_mean_aloha_lower,'bo-','LineWidth',2),hold on
                    xlim([min(data_lh(1).mask.aloha(data_lh(1).mask.lower)),max(data_lh(1).mask.aloha(data_lh(1).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
                    subplot(222),plot(data_lh(1).mask.aloha(data_lh(1).mask.lower),antennas(2).aloha.results.RC,'rx--','LineWidth',2)
                    xlim([min(data_lh(1).mask.aloha(data_lh(1).mask.lower)),max(data_lh(1).mask.aloha(data_lh(1).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
                    legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(2).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
                    title(['Lower module (',data_lh(1).port,')'])
                    if simul_params(ii).optim.method == 0
                        disp(['- Port : ',data_lh(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW,  ne (enforced) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_lower))])
                    else
                        disp(['- Port : ',data_lh(1).port,', Pin = ',num2str(sum(antennas(2).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(2).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(2).aloha.plasma.ne0/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(2).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_lower))])
                    end
                end
                %
                if isfield(antennas(3).aloha,'results')
                    subplot(223),plot(data_lh(2).mask.aloha(data_lh(2).mask.upper),data_lh(2).mean.rc_mean_aloha_upper,'bo-','LineWidth',2),hold on
                    xlim([min(data_lh(2).mask.aloha(data_lh(2).mask.upper)),max(data_lh(2).mask.aloha(data_lh(2).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
                    subplot(223),plot(data_lh(2).mask.aloha(data_lh(2).mask.upper),antennas(3).aloha.results.RC,'rx--','LineWidth',2)
                    xlim([min(data_lh(2).mask.aloha(data_lh(2).mask.upper)),max(data_lh(2).mask.aloha(data_lh(2).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
                    legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(3).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
                    title(['Upper module (',data_lh(2).port,')'])
                    if simul_params(ii).optim.method == 0
                        disp(['- Port : ',data_lh(2).port,', Pin = ',num2str(sum(antennas(3).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(3).aloha.results.Ptr_plasma_RC)/1e6),' MW,  ne (enforced) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(3).aloha.results.RC - data_lh(2).mean.rc_mean_aloha_upper))])
                    else
                        disp(['- Port : ',data_lh(2).port,', Pin = ',num2str(sum(antennas(3).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(3).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(3).aloha.plasma.ne0/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(3).aloha.results.RC - data_lh(2).mean.rc_mean_aloha_upper))])
                    end
                end
                %
                if isfield(antennas(4).aloha,'results')
                    subplot(224),plot(data_lh(2).mask.aloha(data_lh(2).mask.lower),data_lh(2).mean.rc_mean_aloha_lower,'bo-','LineWidth',2),hold on
                    xlim([min(data_lh(2).mask.aloha(data_lh(2).mask.lower)),max(data_lh(2).mask.aloha(data_lh(2).mask.lower))]);ylim([0,30]);xlabel('Module inde');ylabel('RC (%)');
                    subplot(224),plot(data_lh(2).mask.aloha(data_lh(2).mask.lower),antennas(4).aloha.results.RC,'rx--','LineWidth',2)
                    xlim([min(data_lh(2).mask.aloha(data_lh(2).mask.lower)),max(data_lh(2).mask.aloha(data_lh(2).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
                    legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(4).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
                    title(['Lower module (',data_lh(2).port,')'])
                    if simul_params(ii).optim.method == 0
                        disp(['- Port : ',data_lh(2).port,', Pin = ',num2str(sum(antennas(4).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(4).aloha.results.Ptr_plasma_RC)/1e6),' MW,  ne (enforced)= ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(4).aloha.results.RC - data_lh(2).mean.rc_mean_aloha_lower))])
                    else
                        disp(['- Port : ',data_lh(2).port,', Pin = ',num2str(sum(antennas(4).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(4).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(simul_params(ii).optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(4).aloha.plasma.ne0/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(4).aloha.results.RC - data_lh(2).mean.rc_mean_aloha_lower))])
                    end
                end
                %
            end
        end
    end
end
% 
kk = 1;
%
for ii = 1:length(simul_params)
    %
    if simul_params(ii).optim.method == 0
        mask_optim(ii) = 0;
    else
        mask_optim(ii) = 1;
    end
    %
    if sum(flag_job(ii,:)) == 0
        %
        load(['ALOHA/Simulations/sim_aloha_',int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id,'.mat'],'antennas')
        %
        if length(antennas) == 2 
            %
            if isfield(antennas(1).aloha,'results') && isfield(antennas(2).aloha,'results')
                %
                err_RC(1,ii) = norm(antennas(1).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_upper);
                err_RC(2,ii) = norm(antennas(2).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_lower);
                %
            else
                err_RC(1,ii) = NaN;
                err_RC(2,ii) = NaN;
            end
        end
        %
        if length(antennas) == 4
            %
            if isfield(antennas(1).aloha,'results') && isfield(antennas(2).aloha,'results')  && isfield(antennas(3).aloha,'results') && isfield(antennas(4).aloha,'results')
                %
                err_RC(1,ii) = norm(antennas(1).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_upper);
                err_RC(2,ii) = norm(antennas(2).aloha.results.RC - data_lh(1).mean.rc_mean_aloha_lower);
                err_RC(3,ii) = norm(antennas(3).aloha.results.RC - data_lh(2).mean.rc_mean_aloha_upper);
                err_RC(4,ii) = norm(antennas(4).aloha.results.RC - data_lh(2).mean.rc_mean_aloha_lower);
                %
            else
                err_RC(1,ii) = NaN;
                err_RC(2,ii) = NaN;
                err_RC(3,ii) = NaN;
                err_RC(4,ii) = NaN;            
            end
        end
        %
        if mask_optim(ii) == 1
            %
            if length(antennas) == 2
                %
                if isfield(antennas(1).aloha,'results') && isfield(antennas(2).aloha,'results')
                    %
                    ne_optim(1,kk) = antennas(1).aloha.plasma.ne0/1e17;
                    ne_optim(2,kk) = antennas(2).aloha.plasma.ne0/1e17;
                    kk = kk + 1;
                    %
                else
                    ne_optim(1,kk) = NaN;
                    ne_optim(2,kk) = NaN;
                    kk = kk + 1;
                end
                %
            end
            %
            if length(antennas) == 4
                %
                if isfield(antennas(1).aloha,'results') && isfield(antennas(2).aloha,'results')  && isfield(antennas(3).aloha,'results') && isfield(antennas(4).aloha,'results')
                    %
                    ne_optim(1,kk) = antennas(1).aloha.plasma.ne0/1e17;
                    ne_optim(2,kk) = antennas(2).aloha.plasma.ne0/1e17;
                    ne_optim(3,kk) = antennas(3).aloha.plasma.ne0/1e17;
                    ne_optim(4,kk) = antennas(4).aloha.plasma.ne0/1e17;
                    kk = kk + 1;
                    %
                else
                    ne_optim(1,kk) = NaN;
                    ne_optim(2,kk) = NaN;
                    ne_optim(3,kk) = NaN;
                    ne_optim(4,kk) = NaN;
                    kk = kk + 1; 
                end
            end
        end
    end
end
%
if length(mask_optim) > 1 && sum(mask_optim)> 1
    %
    h1 = figure;
    %
    h1.Name = ['RC scan - ALOHA/Simulations/sim_aloha_',int2str(shot),'_',data_lh(1).port,'_',num2str(tmin),'_',num2str(tmax)];
    %
    tt = strrep(['RC scan - ALOHA : #',int2str(shot),', ',data_lh(1).port,', dt = [',num2str(tmin),':',num2str(tmax),']'],'_','-');
    %
    plot(ne(~mask_optim),err_RC(1,~mask_optim),'b-','LineWidth',2),hold on
    plot(ne(~mask_optim),err_RC(2,~mask_optim),'r-','LineWidth',2),hold on
    %
    legend('Upper module','Lower module','Location','NorthWest');
    %
    ylim([0,1.1*max(max(err_RC(1,~mask_optim),err_RC(2,~mask_optim)))]);
    %
    xlabel('Edge density (10+17 m-3)')
    ylabel('\Delta')
    title(tt)
    %
    grid minor
    %
    if exist('ne_optim')
        %
        plot(ne_optim(1,:),err_RC(1,find(mask_optim==1)),'bo','LineWidth',2),hold on
        plot(ne_optim(2,:),err_RC(2,find(mask_optim==1)),'ro','LineWidth',2),hold on
        legend('Upper module','Lower module',['Upper module (optimum), n_e = ',num2str(round(100*ne_optim(1,1))/100),'x10^{+17} m^{-3}'],['Lower module (optimum), n_e = ',num2str(round(100*ne_optim(2,1))/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
        %
    end
    %
    if length(data_lh) == 2
        %
        h1 = figure;
        %
        h1.Name = ['RC scan - ALOHA/Simulations/sim_aloha_',int2str(shot),'_',data_lh(2).port,'_',num2str(tmin),'_',num2str(tmax)];
        %
        tt = strrep(['RC scan - ALOHA : #',int2str(shot),', ',data_lh(2).port,', dt = [',num2str(tmin),':',num2str(tmax),']'],'_','-');
        %
        plot(ne(~mask_optim),err_RC(3,~mask_optim),'b-','LineWidth',2),hold on
        plot(ne(~mask_optim),err_RC(4,~mask_optim),'r-','LineWidth',2),hold on
        %
        %
        ylim([0,1.1*max(max(err_RC(3,~mask_optim),err_RC(4,~mask_optim)))]);
        %
        xlabel('Edge density (10^{+17} m^{-3})')
        ylabel('\Delta')
        title(tt)
        %
        legend('Upper module','Lower module','Location','NorthWest');
        %
        grid minor    
        %
        if exist('ne_optim')  
            %
            plot(ne_optim(3,:),err_RC(3,find(mask_optim==1)),'bo','LineWidth',2),hold on
            plot(ne_optim(4,:),err_RC(4,find(mask_optim==1)),'ro','LineWidth',2),hold on
            %
            legend('Upper module','Lower module',['Upper module (optimum), n_e = ',num2str(round(100*ne_optim(3,1))/100),'x10^{+17} m^{-3}'],['Lower module (optimum), n_e = ',num2str(round(100*ne_optim(4,1))/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
            %
        end
    end
end
