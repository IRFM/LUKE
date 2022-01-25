function flag_display = display_aloha_powerspectrum(flag_display,data,antennas,display_mode,rfwaves_folder)
%
visiblemode = 'Off';%default value
savemode = 0;%default value
%
%TODO: update this functions correctly
%
if ~exist([rfwaves_folder,'ALOHA/Simulations/Figures'])
    %
    mkdir([rfwaves_folder,'ALOHA/Simulations/Figures'])
    %
end
%
if exist([rfwaves_folder,'ALOHA/Simulations/Figures/LH_spectrum_',antennas(1).aloha.optim.id,'_a.eps'])
    %
    cprintf([1,0.5,0],[' --> Figures LH_spectrum_',antennas(1).aloha.optim.id,' and LH_RC_',antennas(1).aloha.optim.id,' already exists in folder ',rfwaves_folder,'ALOHA/Simulations/Figures/']);disp(' ')
    return
    %
end
%
if flag_display == 1 && display_mode >= 0% power spectra are independent of the density in front of the grill. Just the first is plotted
    %
    if display_mode == 0
        %
        visiblemode = 'Off';
        savemode = 1;
        %
    elseif display_mode == 1
        %
        visiblemode = 'On';
        savemode = 0;
        %
    else
        %
        visiblemode = 'On';
        savemode = 1;
        %
    end
    %
    if length(data) >= 1
        %
        h1 = figure('Visible',visiblemode);
        %
        h1.Name = ['Spectrum - ALOHA/Simulations/sim_aloha_simul_params(ii).',antennas(1).aloha.optim.id];
        %
        tt = strrep(['Spectrum (',antennas(1).aloha.optim.id,')'],'_','-');
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
        legend(['Upper modules (',data(1).port,'), n_{z0} = ',num2str(nz_max1)],['Lower modules (',data(1).port,'), n_{z0} = ',num2str(nz_max2)],'Location','NorthWest');
        %
        drawnow;
        %
        if savemode == 1
            %
            print(h1,'-depsc2','-loose','-r600',[rfwaves_folder,'ALOHA/Simulations/Figures/LH_spectrum_',antennas(1).aloha.optim.id,'_a.eps']);
            print(h1,'-dpng','-r72',[rfwaves_folder,'ALOHA/Simulations/Figures/LH_spectrum_',antennas(1).aloha.optim.id,'_a.png']);
            %
        end
        %
    end
    %
    if length(data) == 2
        %
        h2 = figure('Visible',visiblemode);
        %
        h2.Name = ['Spectrum - ALOHA/Simulations/sim_aloha_',antennas(1).aloha.optim.id];
        %
        tt = strrep(['Spectrum (',antennas(1).aloha.optim.id,')'],'_','-');                         
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
        legend(['Upper modules (',data(2).port,') , n_{z0} = ',num2str(nz_max3)],['Lower modules (',data(2).port,'), n_{z0} = ',num2str(nz_max4)],'Location','NorthWest');
        %
        drawnow;
        %
        if savemode == 1
            %
            print(h2,'-depsc2','-loose','-r600',[rfwaves_folder,'ALOHA/Simulations/Figures/LH_spectrum_',antennas(1).aloha.optim.id,'_b.eps']);
            print(h2,'-dpng','-r72',[rfwaves_folder,'ALOHA/Simulations/Figures/LH_spectrum_',antennas(1).aloha.optim.id,'_b.png']);
            %
        end
    end
    %
    flag_display = 0; 
    %
end
%


h3 = figure('Visible',visiblemode);
%
h3.Name = ['RC - ALOHA/Simulations/sim_aloha_',antennas(1).aloha.optim.id];
%
tt = strrep(['RC - ALOHA (',antennas(1).aloha.optim.id,')'],'_','-');   
%
if length(antennas) == 2
    %
    if isfield(antennas(1).aloha,'results')
        %
        subplot(121),plot(data(1).mask.aloha(data(1).mask.upper),data(1).mean.rc_mean_aloha_upper,'bo-','LineWidth',2),hold on
        xlim([min(data(1).mask.aloha(data(1).mask.upper)),max(data(1).mask.aloha(data(1).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
        subplot(121),plot(data(1).mask.aloha(data(1).mask.upper),antennas(1).aloha.results.RC,'rx--','LineWidth',2)
        xlim([min(data(1).mask.aloha(data(1).mask.upper)),max(data(1).mask.aloha(data(1).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
        legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(1).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
        title(['Upper module (',data(1).port,')'])
        if antennas(1).aloha.optim.method == 0
            disp(['- Port : ',data(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (enforced) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data(1).mean.rc_mean_aloha_upper))])
        else
            disp(['- Port : ',data(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(1).aloha.plasma.ne0/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data(1).mean.rc_mean_aloha_upper))])
        end    
        %
    end
    %
    if isfield(antennas(2).aloha,'results')
        %
        subplot(122),plot(data(1).mask.aloha(data(1).mask.lower),data(1).mean.rc_mean_aloha_lower,'bo-','LineWidth',2),hold on
        xlim([min(data(1).mask.aloha(data(1).mask.lower)),max(data(1).mask.aloha(data(1).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
        subplot(122),plot(data(1).mask.aloha(data(1).mask.lower),antennas(1).aloha.results.RC,'rx--','LineWidth',2)
        xlim([min(data(1).mask.aloha(data(1).mask.lower)),max(data(1).mask.aloha(data(1).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
        legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(2).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
        title(['Lower module (',data(1).port,')'])
        if antennas(1).aloha.optim.method == 0
            disp(['- Port : ',data(1).port,', Pin = ',num2str(sum(antennas(2).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(2).aloha.results.Ptr_plasma_RC)/1e6),' MW,  ne (enforced) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(2).aloha.results.RC - data(1).mean.rc_mean_aloha_lower))])
        else
            disp(['- Port : ',data(1).port,', Pin = ',num2str(sum(antennas(2).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(2).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(2).aloha.plasma.ne0/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(2).aloha.results.RC - data(1).mean.rc_mean_aloha_lower))])
        end
        %
    end
    %
    drawnow
    %
elseif length(antennas) == 4
    %
    if isfield(antennas(1).aloha,'results')
        subplot(221),plot(data(1).mask.aloha(data(1).mask.upper),data(1).mean.rc_mean_aloha_upper,'bo-','LineWidth',2),hold on
        xlim([min(data(1).mask.aloha(data(1).mask.upper)),max(data(1).mask.aloha(data(1).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
        subplot(221),plot(data(1).mask.aloha(data(1).mask.upper),antennas(1).aloha.results.RC,'rx--','LineWidth',2)
        xlim([min(data(1).mask.aloha(data(1).mask.upper)),max(data(1).mask.aloha(data(1).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
        legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(1).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
        title(['Upper module (',data(1).port,')'])
        if antennas(1).aloha.optim.method == 0
            disp(['- Port : ',data(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (enforced) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data(1).mean.rc_mean_aloha_upper))])
        else
            disp(['- Port : ',data(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(1).aloha.plasma.ne0/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data(1).mean.rc_mean_aloha_upper))])
        end
    end
    %
    if isfield(antennas(2).aloha,'results')
        subplot(222),plot(data(1).mask.aloha(data(1).mask.lower),data(1).mean.rc_mean_aloha_lower,'bo-','LineWidth',2),hold on
        xlim([min(data(1).mask.aloha(data(1).mask.lower)),max(data(1).mask.aloha(data(1).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
        subplot(222),plot(data(1).mask.aloha(data(1).mask.lower),antennas(2).aloha.results.RC,'rx--','LineWidth',2)
        xlim([min(data(1).mask.aloha(data(1).mask.lower)),max(data(1).mask.aloha(data(1).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
        legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(2).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
        title(['Lower module (',data(1).port,')'])
        if antennas(1).aloha.optim.method == 0
            disp(['- Port : ',data(1).port,', Pin = ',num2str(sum(antennas(1).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(1).aloha.results.Ptr_plasma_RC)/1e6),' MW,  ne (enforced) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(1).aloha.results.RC - data(1).mean.rc_mean_aloha_lower))])
        else
            disp(['- Port : ',data(1).port,', Pin = ',num2str(sum(antennas(2).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(2).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(2).aloha.plasma.ne0/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(2).aloha.results.RC - data(1).mean.rc_mean_aloha_lower))])
        end
    end
    %
    if isfield(antennas(3).aloha,'results')
        subplot(223),plot(data(2).mask.aloha(data(2).mask.upper),data(2).mean.rc_mean_aloha_upper,'bo-','LineWidth',2),hold on
        xlim([min(data(2).mask.aloha(data(2).mask.upper)),max(data(2).mask.aloha(data(2).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');
        subplot(223),plot(data(2).mask.aloha(data(2).mask.upper),antennas(3).aloha.results.RC,'rx--','LineWidth',2)
        xlim([min(data(2).mask.aloha(data(2).mask.upper)),max(data(2).mask.aloha(data(2).mask.upper))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
        legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(3).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
        title(['Upper module (',data(2).port,')'])
        if antennas(1).aloha.optim.method == 0
            disp(['- Port : ',data(2).port,', Pin = ',num2str(sum(antennas(3).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(3).aloha.results.Ptr_plasma_RC)/1e6),' MW,  ne (enforced) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(3).aloha.results.RC - data(2).mean.rc_mean_aloha_upper))])
        else
            disp(['- Port : ',data(2).port,', Pin = ',num2str(sum(antennas(3).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(3).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(3).aloha.plasma.ne0/1e17),'x10+17 m-3, upper module, delta = ',num2str(norm(antennas(3).aloha.results.RC - data(2).mean.rc_mean_aloha_upper))])
        end
    end
    %
    if isfield(antennas(4).aloha,'results')
        subplot(224),plot(data(2).mask.aloha(data(2).mask.lower),data(2).mean.rc_mean_aloha_lower,'bo-','LineWidth',2),hold on
        xlim([min(data(2).mask.aloha(data(2).mask.lower)),max(data(2).mask.aloha(data(2).mask.lower))]);ylim([0,30]);xlabel('Module inde');ylabel('RC (%)');
        subplot(224),plot(data(2).mask.aloha(data(2).mask.lower),antennas(4).aloha.results.RC,'rx--','LineWidth',2)
        xlim([min(data(2).mask.aloha(data(2).mask.lower)),max(data(2).mask.aloha(data(2).mask.lower))]);ylim([0,30]);xlabel('Module index');ylabel('RC (%)');grid minor
        legend('Exp.',['ALOHA, n_{e} = ',num2str(round(100*antennas(4).aloha.plasma.ne0/1e17)/100),'x10^{+17} m^{-3}'],'Location','NorthWest');
        title(['Lower module (',data(2).port,')'])
        if antennas(1).aloha.optim.method == 0
            disp(['- Port : ',data(2).port,', Pin = ',num2str(sum(antennas(4).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(4).aloha.results.Ptr_plasma_RC)/1e6),' MW,  ne (enforced)= ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(4).aloha.results.RC - data(2).mean.rc_mean_aloha_lower))])
        else
            disp(['- Port : ',data(2).port,', Pin = ',num2str(sum(antennas(4).aloha.results.Pin)/1e6),' MW, Ptr = ',num2str(sum(antennas(4).aloha.results.Ptr_plasma_RC)/1e6),' MW, ne (guess) = ',num2str(antennas(1).aloha.optim.ne_guess/1e17),'x10+17 m-3, , ne (optimized) = ',num2str(antennas(4).aloha.plasma.ne0/1e17),'x10+17 m-3, lower module, delta = ',num2str(norm(antennas(4).aloha.results.RC - data(2).mean.rc_mean_aloha_lower))])
        end
    end
end
%
supertitle(tt,'Color','Red');
%
if savemode == 1
    %
    print(h3,'-depsc2','-loose','-r600',[rfwaves_folder,'ALOHA/Simulations/Figures/LH_RC_',antennas(1).aloha.optim.id,'.eps']);
    print(h3,'-dpng','-r72',[rfwaves_folder,'ALOHA/Simulations/Figures/LH_RC_',antennas(1).aloha.optim.id,'.png']);
    %
end

















return


% 
kk = 1;
%
for ii = 1:length(simul_params)
    %
    id = [int2str(shot),'_',num2str(tmin),'_',num2str(tmax),'_',port,'_',simul_params(ii).id];
    %
    if simul_params(ii).optim.method == 0
        mask_optim(ii) = 0;
    else
        mask_optim(ii) = 1;
    end
    %
    if sum(flag_job(ii,:)) == 0
        %
        load(['ALOHA/Simulations/sim_aloha_',id,'.mat'],'antennas')
        %
        if length(antennas) == 2 
            %
            if isfield(antennas(1).aloha,'results') && isfield(antennas(2).aloha,'results')
                %
                err_RC(1,ii) = norm(antennas(1).aloha.results.RC - data(1).mean.rc_mean_aloha_upper);
                err_RC(2,ii) = norm(antennas(2).aloha.results.RC - data(1).mean.rc_mean_aloha_lower);
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
                err_RC(1,ii) = norm(antennas(1).aloha.results.RC - data(1).mean.rc_mean_aloha_upper);
                err_RC(2,ii) = norm(antennas(2).aloha.results.RC - data(1).mean.rc_mean_aloha_lower);
                err_RC(3,ii) = norm(antennas(3).aloha.results.RC - data(2).mean.rc_mean_aloha_upper);
                err_RC(4,ii) = norm(antennas(4).aloha.results.RC - data(2).mean.rc_mean_aloha_lower);
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
    h1.Name = ['RC scan - ALOHA/Simulations/sim_aloha_',int2str(shot),'_',data(1).port,'_',num2str(tmin),'_',num2str(tmax)];
    %
    tt = strrep(['RC scan - ALOHA : #',int2str(shot),', ',data(1).port,', dt = [',num2str(tmin),':',num2str(tmax),']'],'_','-');
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
    if length(data) == 2
        %
        h1 = figure;
        %
        h1.Name = ['RC scan - ALOHA/Simulations/sim_aloha_',int2str(shot),'_',data(2).port,'_',num2str(tmin),'_',num2str(tmax)];
        %
        tt = strrep(['RC scan - ALOHA : #',int2str(shot),', ',data(2).port,', dt = [',num2str(tmin),':',num2str(tmax),']'],'_','-');
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