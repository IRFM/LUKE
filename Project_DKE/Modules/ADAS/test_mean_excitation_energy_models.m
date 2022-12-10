%
% test model for the mean excitation energies 
%
% by Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
clear all
clc
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB,amu,h,hbar,lambadC,a0] = pc_dke_yp;
%
Eref = mc2*alpha*alpha*1e3;%eV units
%
print_opt = 2;%-1: no print, 2:save files (eps,png,fig)
save_data = 1;%save calculations in dft structure
visible_figs = 'off';
%
% load Gaussian DFT data
%
Z = [1,2,3,4,5,6,7,8,10,13,14,17,18,24,26,28,29,32,36,54,74,79];%Atomic number (If multiple Z values, dft change only, no display)
%Z = [18];%[18];%change dft substructure field salvat, and display results
%
I0_NIST = [19.2;41.8;40.0;63.7;76.0;78.0;82.0;95.0;115.0;137.0;149.0;156.0;166.0;173.0;173.0;180.0;174.0;188.0;190.0;191.0;216.0;233.0;245.0;257.0;272.0;286.0;297.0;311.0;322.0;330.0;334.0;350.0;347.0;348.0;343.0;352.0;363.0;366.0;379.0;393.0;417.0;424.0;428.0;441.0;449.0;470.0;470.0;469.0;...
488.0;488.0;487.0;485.0;491.0;482.0;488.0;491.0;501.0;523.0;535.0;546.0;560.0;574.0;580.0;591.0;614.0;628.0;650.0;658.0;674.0;684.0;694.0;705.0;718.0;727.0;736.0;746.0;757.0;790.0;790.0;800.0;810.0;823.0;823.0;830.0;825.0;794.0;827.0;826.0;841.0;847.0;878.0;890.0];%neutral atom: https://physics.nist.gov/PhysRefData/XrayMassCoef/tab1.html
%
% LPA model
%
gamma = sqrt(2);%LPA model (may be 1 in H. O. Wyckoff et al., "Stopping Powers for electrons and positrons.", International Commission on Radiation Units and Measurements (ICRU) REPORT 37 (1984).
%
% Salvat or multi-Yukawa model
%
nexp = 1;%number of exponentials
%
for iZ = 1:length(Z)
    %
    close all
    %
    filename = ['DFT/dft_',int2str(Z(iZ)),'_',elements('atomic_number', Z(iZ), 'symbol'),'_',elements('atomic_number', Z(iZ), 'name'),'.mat'];
    %
    if exist(filename)
        %
        load(filename);
        %
        [I0,I0_s,Z0,symbol] = meanexcitationenergy_yp(dft.Z,0);
        %
        % GSK model free parameters : x(1) -> H;x(2) -> d;
        % Alex E. S. Green and D. L. Sellin and A. S. Zachor, Analytic Independent-Particle Model for Atoms, Phys. Rev., 1969, 184, 1, pp. 1
        % Xavier Garbet and Claude Deutsch and Gilles Maynard, Mean excitation energies for ions in gases and plasmas, Journal of Applied Physics, 1987, 61, pp. 907
        %
        fun_dens = @(x,r)x(1)*r.*exp(r/x(2)).*(x(1)*(exp(r/x(2))+1)-1)./(x(1)*(exp(r/x(2))-1)+1).^3/x(2)/x(2);%GSK charge density
        %
        x0 = [1 0.3];%initial values
        n = 1000;
        %
        for i = 1:length(dft.Z0)
            %   
            i = dft.Z0(i)+1;
            %
            y = 4*pi*dft.ne(:,i).*dft.r(:).*dft.r(:)/dft.N(i);
            trapz(dft.r(:),y);
            %
           % options = optimoptions('lsqcurvefit','FunctionTolerance',eps,'FiniteDifferenceType','central','StepTolerance',eps);
           % [x,resnorm,~,exitflag,output] = lsqcurvefit(fun_dens,x0,dft.r,y,[],[],options);%fit of DFT (GAUSSIAN) data
            [x,resnorm,~,exitflag,output] = lsqcurvefit(fun_dens,x0,dft.r,y);%fit of DFT (GAUSSIAN) data
            %
            % LPA model - DFT 
            %
            ine0_gaussian = min(find(dft.ne(:,i) == 0)) - 1;%remove zero density to avoid NaN
            %
            if isempty(ine0_gaussian), 
                ine0_gaussian = length(dft.ne(:,i));
            end
            %
            hbar_omega_gaussian = alpha^2*mc2*1e3*sqrt(4*pi*dft.ne(1:ine0_gaussian,i));%in eV units
            meanI_LPA_gaussian(i) = exp(trapz(dft.r(1:ine0_gaussian),4*pi*dft.ne(1:ine0_gaussian,i).*dft.r(1:ine0_gaussian).*dft.r(1:ine0_gaussian).*log(gamma*hbar_omega_gaussian))/dft.N(i));
            %
            % LPA - Salvat model (multi-Yukawa)
            %
            ine0_salvat = min(find(dft.salvat.gaussian{nexp}.ne(:,i) == 0)) - 1;%remove zero density to avoid NaN
            %
            if isempty(ine0_salvat), 
                ine0_salvat = length(dft.salvat.gaussian{nexp}.ne(:,i));
            end
            %
            hbar_omega_salvat = alpha*alpha*mc2*1e3*sqrt(4*pi*dft.salvat.gaussian{nexp}.ne(1:ine0_salvat,i));%in eV units
            meanI_LPA_salvat(i) = exp(trapz(dft.salvat.gaussian{nexp}.r(1:ine0_salvat),4*pi*dft.salvat.gaussian{nexp}.ne(1:ine0_salvat,i).*dft.salvat.gaussian{nexp}.r(1:ine0_salvat).*dft.salvat.gaussian{nexp}.r(1:ine0_salvat).*log(gamma*hbar_omega_salvat))/dft.N(i));
            %
            % Xavier Garbet and Claude Deutsch and Gilles Maynard, Mean excitation energies for ions in gases and plasmas, Journal of Applied Physics, 1987, 61, pp. 907
            %
            alphaH = 1 - 1/x(1);
            b = [0:1:n];
            F = sum(alphaH.^b./(1+b).^2);
            %
            % Calculation of K0 using virial theorem
            %
            r02 = 6*x(2)*x(2)*F/x(1);
            K0 = x(1)*(dft.Z - dft.N(i)*(1/6 + 1/12/x(1)))/x(2)/2;
            %
            disp([num2str(x0(1)),',',num2str(x(1))]);
            disp([num2str(x0(2)),',',num2str(x(2))]);
            x(1)/x(2);
            sqrt(13);
            %
            % Salvat or multi-Yukawa model
            %
            index0 = [1:nexp];
            %
            I0_salvat = 0;
            I1_salvat = 0;
            I2_salvat = 0;
            %
            for ii = index0
                %
                if dft.salvat.gaussian{nexp}.alpha(i,ii) > 0
                    %
                    I0_salvat = I0_salvat + dft.salvat.gaussian{nexp}.A(i,ii)*dft.salvat.gaussian{nexp}.alpha(i,ii);
                    I1_salvat = I1_salvat + dft.salvat.gaussian{nexp}.A(i,ii)^2*dft.salvat.gaussian{nexp}.alpha(i,ii)/2;
                    I2_salvat = I2_salvat + 6*dft.salvat.gaussian{nexp}.A(i,ii)/(dft.salvat.gaussian{nexp}.alpha(i,ii))^2;
                    %
                end
                %
                if length(index0) > 1
                    %
                    index1 = index0(index0~=ii);
                    %
                    for jj = index1
                        %
                        if dft.salvat.gaussian{nexp}.alpha(i,ii) > 0 && dft.salvat.gaussian{nexp}.alpha(i,jj) > 0
                            I1_salvat = I1_salvat + dft.salvat.gaussian{nexp}.A(i,ii)*dft.salvat.gaussian{nexp}.A(i,jj)*dft.salvat.gaussian{nexp}.alpha(i,ii)^2/(dft.salvat.gaussian{nexp}.alpha(i,ii)+dft.salvat.gaussian{nexp}.alpha(i,jj));
                        end
                        %
                    end
                    %
                end
                %
            end
            %
            r2_salvat(i) = I2_salvat;
            r2_DFT(i) = simps(dft.r,dft.r.^4.*dft.ne(:,i))/simps(dft.r,dft.r.^2.*dft.ne(:,i));
            %
            if i == 1,%
                figure('visible',visible_figs)
                semilogy(dft.r,y/4/pi./dft.r(:)./dft.r(:)*dft.N(i),'r',dft.r,fun_dens(x,dft.r)/4/pi./dft.r(:)./dft.r(:)*dft.N(i),'b',dft.ionradius{1}.rn{i},dft.ionradius{1}.dens{i},'g',dft.salvat.gaussian{nexp}.r,dft.salvat.gaussian{nexp}.ne(:,i),'k--','MarkerSize',14,'LineWidth',2);
                legend('DFT','GSK','TF','MY')
                xlabel('r/a_0')
                ylabel('\rho')
                title(([dft.name,', Z_{0s} = ',int2str(dft.Z0(i))]))
                trapz(dft.r(:),fun_dens(x,dft.r));
                %
                figure('visible',visible_figs)
                plot(dft.r,y*dft.N(i),'r',dft.r,fun_dens(x,dft.r)*dft.N(i),'b',dft.ionradius{1}.rn{i},dft.ionradius{1}.dens{i}.*dft.ionradius{1}.rn{i}.*dft.ionradius{1}.rn{i}*4*pi,'g',dft.salvat.gaussian{nexp}.r,dft.salvat.gaussian{nexp}.ne(:,i)*4*pi.*dft.salvat.gaussian{nexp}.r.*dft.salvat.gaussian{nexp}.r,'k--','MarkerSize',14,'LineWidth',2);
                legend('DFT','GSK','TF','MY')
                xlabel('r/a_0')
                ylabel('\rho')
                title(([dft.name,', Z_{0s} = ',int2str(dft.Z0(i))]))
                trapz(dft.r(:),fun_dens(x,dft.r));
            end
            %
            if i == dft.Z,%
                figure('visible',visible_figs)
                semilogy(dft.r,y/4/pi./dft.r(:)./dft.r(:)*dft.N(i),'r',dft.r,fun_dens(x,dft.r)/4/pi./dft.r(:)./dft.r(:)*dft.N(i),'b',dft.ionradius{1}.rn{i},dft.ionradius{1}.dens{i},'g',dft.salvat.gaussian{nexp}.r,dft.salvat.gaussian{nexp}.ne(:,i),'k--','MarkerSize',14,'LineWidth',2);
                legend('DFT','GSK','TF','MY')
                xlabel('r/a_0')
                ylabel('\rho')
                title(([dft.name,', Z_{0s} = ',int2str(dft.Z0(i))]))
                trapz(dft.r(:),fun_dens(x,dft.r));
                %
                figure('visible',visible_figs)
                plot(dft.r,y*dft.N(i),'r',dft.r,fun_dens(x,dft.r)*dft.N(i),'b',dft.ionradius{1}.rn{i},dft.ionradius{1}.dens{i}.*dft.ionradius{1}.rn{i}.*dft.ionradius{1}.rn{i}*4*pi,'g',dft.salvat.gaussian{nexp}.r,dft.salvat.gaussian{nexp}.ne(:,i)*4*pi.*dft.salvat.gaussian{nexp}.r.*dft.salvat.gaussian{nexp}.r,'k--','MarkerSize',14,'LineWidth',2);
                legend('DFT','GSK','TF','MY')
                xlabel('r/a_0')
                ylabel('\rho')
                title(([dft.name,', Z_{0s} = ',int2str(dft.Z0(i))]))
                trapz(dft.r(:),fun_dens(x,dft.r));
                xlim([0 1])
            end
            %
            meanI0(i) = Eref*sqrt(2*K0/r02);%Variational quantum calculations,,GSK atomic model, Eq.29, Garbet, et al. (1987) 
            meanI1(i) = Eref*sqrt(dft.Z*(x(1)/x(2))^2*(1 - (dft.N(i)/6/dft.Z)*(1 + 1/2/x(1)))/F/x(2)/6);%Variational quantum calculations, GSK atomic model, Eq.34, Garbet, et al. (1987)
            meanI2(i) = I0(i);%MCSCF code Sauer, et al. (2015)
            meanI3(i) = I0_s(i);%Exponential interpolation
            meanI4(i) = Eref*sqrt(((dft.Z-dft.N(i))*I0_salvat + dft.N(i)*I1_salvat)/I2_salvat);%Variational quantum calculations,Multi-Yukawa atomic model 
            %
        end
        %
        figure('visible',visible_figs)
        plot(dft.Z0,log(meanI0),'ro',dft.Z0,log(meanI1),'rx',dft.Z0,log(meanI2),'k*',dft.Z0,log(meanI_LPA_gaussian),'ms',dft.Z0,log(meanI_LPA_salvat),'cs',dft.Z0,log(meanI3),'k-',dft.Z0,log(meanI4),'g--','MarkerSize',14,'LineWidth',2)
        ylabel('ln(<I>)')
        xlabel('Ion charge Z')
        title([dft.name,', Z_s = ',int2str(dft.Z)])
        legend('Eq.29, Garbet, et al. (1987)','Eq.34, Garbet, et al. (1987)','Sauer, et al. (2015)','LPA-Gaussian','LPA-Salvat','LUKE code','Salvat','Location','NorthWest')
        grid minor
        %
        figure('visible',visible_figs)
        %
        if isnan(I0) == 0
            plot(0,log(I0_NIST(Z(iZ))),'k*',dft.Z0,log(meanI2),'go',dft.Z0,log(meanI4),'r-',dft.Z0,log(meanI_LPA_salvat),'b--',dft.Z0,log(meanI3),'k-.','MarkerSize',14,'LineWidth',2)
            ylabel('ln(<I> [eV])')
            xlabel('Ion charge Z_{0,s}')
            title(['Atom : ',dft.name,', Z_s = ',int2str(dft.Z),''])
            legend('NIST database (neutral atom)','Multi-Configurational Self-Consistent Field code','Variational quantum calculations','Local Plasma Approximation (\gamma = \surd2)','Exponential interpolation','Location','NorthWest')
            grid minor
            xlim([0,dft.Z])
        else
            plot(0,log(I0_NIST(Z(iZ))),'k*',dft.Z0,log(meanI4),'r-',dft.Z0,log(meanI_LPA_salvat),'b--',dft.Z0,log(meanI3),'k-.','MarkerSize',14,'LineWidth',2)
            ylabel('ln(<I> [eV])')
            xlabel('Ion charge Z_{0,s}')
            title([dft.name,', Z_s = ',int2str(dft.Z),''])
            legend('NIST database (neutral atom)','Variational quantum calculations','Local Plasma Approximation (\gamma = \surd2)','Exponential interpolation','Location','NorthWest')
            grid minor
            xlim([0,dft.Z])
        end
        %
        drawnow
        %
        print_jd(print_opt,['MeanExcitationEnergy_',dft.name,'_',int2str(dft.Z),'_nexp_',int2str(nexp)],'./Figs',get(gcf,'Number'))
        %
        %disp('                   Z0        <r2>_salvat          <r2>_DFT')
        %[dft.Z0(:),r2_salvat(:),r2_DFT(:)]
        %
        if save_data == 1
            %
            % Save data mean excitation energy in dft structure
            %
            dft.I_meanexcitationenergy_lpa = meanI_LPA_gaussian;
            dft.I_meanexcitationenergy_gsk = meanI1;
            dft.I_meanexcitationenergy_nist = I0_NIST(Z);
            %
            if isfield(dft,'salvat')
                %
                dft.salvat.gaussian{nexp}.I_meanexcitationenergy = meanI4;
                dft.salvat.gaussian{nexp}.I_meanexcitationenergy_lpa = meanI_LPA_salvat;
                %
            end
            %
            save(filename,'dft');
            %
        end
        %
    end
    %
end