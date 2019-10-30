close all
clear all
clc
%
Z = 74;%Atomic number
%
nfig = 10;%figure reduction factor. 
%
Ecmin = 200;%Electron kinetic energy min keV
Ecmax = 1000;%Electron kinetic energy max keV
nEc = 2;%number of electron energies
energy_display = [1];%display index for electron energy
%
kmin = 10;%Photon energy min keV
nk = 100;%number of photon energies
%
theta_display = [1,2];%display index for photon angle
%
% Screening effect
%
screening_models = {'Tseng-Pratt-Botto'};%{'Tseng-Pratt-Botto'};%Screening models : '' or full-screening, 'No-screening','Thomas-Fermi','Thomas-Fermi-Kirillov','Tseng-Pratt-Avdonina-Lamoureux','Tseng-Pratt-Botto','Tseng-Pratt-Thomas-Fermi'
%nphi = 101;%for numerical integration 1BS -> 2BN. If nphi = NaN, formula deduced from analytical integration in phi is used (4-D). Otherwise (5-D)
ntheta = 2006;%for numerical integration 1BS -> 2BN
integration_method = 'simps';%Numerical integration : trapz (trapeze) or simps (Simpson)
flag_mem = 1;%Memory management enforcement : 0 -> 5-D block numerical calculations, 1 -> 4-D block numerical calculations
%
Ec0 = linspace(Ecmin,Ecmax,nEc);%Incoming electron kinetic energy (keV)
k = linspace(kmin,Ecmax,nk);%photon energy (keV)
theta = [0,30];%[0,30,60,90,120,150,180]%Photon observation angle (deg)
%
factor = 10000/511/1e-27;%relativistic to mb/MeV/str units
%
%----------------------------------------------------------------------------------------------
%
Z0 = [0:1:Z];%ionization states
%
tic
%
seBH1 = zeros(length(theta),nEc,nk,length(Z0));
seBHE1 = seBH1;
%
for iZ = 1:length(Z0)
    %
    [seBHE1(:,:,:,iZ),seBH1(:,:,:,iZ)] = bhe_dke_yp(Ec0,k,cos(theta*pi/180),Z0(iZ));%Analytic cross-section 2BN (from full screening when partially ionized to fully stripped atom)
    %
end
%
BH1(1).screening_model = '';
BH1(1).seBH1 = seBH1*factor;%mb/MeV/str units
BH1(1).seBHE1 = seBHE1*factor;%mb/MeV/str units
BH1(1).Z0 = Z0;
BH1(1).legend = ['2BN - full-screening'];
%
elapsed_time = toc;
disp(['Analytic 2BN Bethe-Heitler-Elwert e-i calculation time : ',num2str(elapsed_time), ' (s)']);
%
tic
for iZ = 1:length(Z0)
    %
    for itheta = 1:length(theta)
        %seEH(itheta,:,:) = eh_dke_yp(Ec0,k,theta(itheta)*pi/180,Z0(iZ))';
    end
    %
    %seEH = seEH/511/1e-27;%mb/MeV/str units
    %
    %EH(iZ).seEH = seEH;
    %EH(iZ).Z0 = Z0(iZ);
    %
end
elapsed_time = toc;
disp(['Elwert-Haug e-i calculation time : ',num2str(elapsed_time), ' (s)']);
%
for im = 1:length(screening_models)
    %
    smodel.screening_model = screening_models{im};
    %
    if exist('nphi')
        params.nphi = nphi;
    end
    %
    if exist('flag_mem')
        params.flag_mem = flag_mem;
    end
    %
    params.ntheta = ntheta;
    params.integral = integration_method;
    %
    tic
    [seBHE2,seBH2] = bhe_dke_yp(Ec0,k,cos(theta*pi/180),Z,params,smodel);%numeric cross-section 2BN from integration of 1BS
    elapsed_time = toc;
    %
    if isfield(params,'integral') && strcmp(params.integral,'simps') && exist('simps')
        disp(['Numeric 2BN Bethe-Heitler-Elwert e-i calculation time (Simpson integration, screening model : ',smodel.screening_model,') : ',num2str(elapsed_time), ' (s)']);
    else
        disp(['Numeric 2BN Bethe-Heitler-Elwert e-i calculation time (Trapeze integration, screening model : ',smodel.screening_model,') : ',num2str(elapsed_time), ' (s)']);
    end
    %
    BH2(im).screening_model = screening_models{im};
    BH2(im).seBH2 = seBH2*factor;%mb/MeV/str units
    BH2(im).seBHE2 = seBHE2*factor;%mb/MeV/str units
    BH2(im).Z0 = [0:1:Z];
    if isempty(screening_models{im})
        BH2(im).legend = ['1BS -> 2BN - full-screening'];
    else
        BH2(im).legend = ['1BS -> 2BN - ',screening_models{im}];
    end
    %  
end
%
linestyle(1) = {'-'};
linestyle(2) = {'--'};
linestyle(3) = {'-.'};
linestyle(4) = {':'};
linestyle(5) = {'-'};
%
linecolor(1) = {'r'};
linecolor(2) = {'b'};
linecolor(3) = {'g'};
linecolor(4) = {'m'};
linecolor(5) = {'c'};
%
siz = 20+14i;
%
xlab = 'Photon energy k (keV)';
ylab = 'd^2\sigma/d\Omega/dk (mb/MeV/str)';
%
for it = 1:length(theta_display)%theta0 photon angle
    %
    for iE = 1:nEc
        %
        for iZ = 1:nfig:length(BH2(1).Z0)%Z0 value (screened value)
            %
            if BH2(1).Z0(iZ) == 0
                figure('Name',['Electron energy = ',num2str(Ec0(iE)),' (keV), photon angle ',num2str(theta(theta_display(it))),' (deg.), Z = ',int2str(Z),', Z0 = ',int2str(BH2(1).Z0(iZ)),' : Neutral atom'])
            elseif BH2(1).Z0(iZ) == Z 
                figure('Name',['Electron energy = ',num2str(Ec0(iE)),' (keV), photon angle ',num2str(theta(theta_display(it))),' (deg.), Z = ',int2str(Z),', Z0 = ',int2str(BH2(1).Z0(iZ)),' : Fully stripped atom'])
            else
                figure('Name',['Electron energy = ',num2str(Ec0(iE)),' (keV), photon angle ',num2str(theta(theta_display(it))),' (deg.), Z = ',int2str(Z),', Z0 = ',int2str(BH2(1).Z0(iZ))])
            end
            %
            leg = '';
            %
            for im = 1:length(BH2)%Screening model
                %
                if BH2(1).Z0(iZ) == 0
                    tit = ['Electron energy = ',num2str(Ec0(iE)),' (keV), photon angle ',num2str(theta(theta_display(it))),' (deg.), Z = ',int2str(Z),', Z_0 = ',int2str(BH2(im).Z0(iZ)),' : Neutral atom'];
                elseif BH2(1).Z0(iZ) == Z
                    tit = ['Electron energy = ',num2str(Ec0(iE)),' (keV), photon angle ',num2str(theta(theta_display(it))),' (deg.), Z = ',int2str(Z),', Z_0 = ',int2str(BH2(im).Z0(iZ)),' : Fully stripped atom'];
                else
                    tit = ['Electron energy = ',num2str(Ec0(iE)),' (keV), photon angle ',num2str(theta(theta_display(it))),' (deg.), Z = ',int2str(Z),', Z_0 = ',int2str(BH2(im).Z0(iZ))];
                end
                %
                leg = {BH2(1:im).legend,BH1(1).legend};
                %
                xlim = [0,Ec0(iE)];%normalized transfered momentum q/(mec)
                ylim = [1e-4,1e5];
                %
                graph1D_jd(k,squeeze(BH2(im).seBH2(theta_display(it),iE,:,iZ)),0,1,xlab,ylab,tit,leg,xlim,ylim,linestyle{im},'none',linecolor{im},2,siz,gca);
                graph1D_jd(k,squeeze(BH1(1).seBH1(theta_display(it),iE,:,iZ)),0,1,xlab,ylab,tit,leg,NaN,NaN,linestyle{im+1},'none',linecolor{im+1},2,siz,gca);
                %
                drawnow
                %
            end
            %
            leg = {BH2(1:im).legend,BH1(1).legend,'2BN - fully-stripped atom'};
            graph1D_jd(k,squeeze(BH1(1).seBH1(theta_display(it),iE,:,end)),0,1,xlab,ylab,tit,leg,NaN,NaN,linestyle{length(BH2)+2},'none',linecolor{length(BH2)+2},2,siz,gca);
            %
            %leg = {BH2(1:im).legend,'2BN - full-screening','Elwert-Haug - full-screening'
            %graph1D_jd(k,squeeze(EH(iZ).seEH(theta_display(it),end,:)),0,1,xlab,ylab,tit,leg,NaN,NaN,linestyle{length(BH2)+2},'none',linecolor{length(BH2)+2},2,siz,gca);
            %
            drawnow
            %
            grid on
            %
        end
    end
end
%
xlab = 'Photon energy k (keV)';
ylab = 'Screening reduction factor';
%
for im = 1:length(BH2)%Screening model
    for it = 1:length(theta_display)%theta0 photon angle
        %
        for iE = 1:nEc
            %
            figure('Name',['Electron energy = ',num2str(Ec0(iE)),' (keV), photon angle ',num2str(theta(theta_display(it))),' (deg.), Z = ',int2str(Z),', ',BH2(im).legend])
            tit = ['Electron energy = ',num2str(Ec0(iE)),' (keV), photon angle ',num2str(theta(theta_display(it))),' (deg.), Z = ',int2str(Z),', ',BH2(im).legend];
            %
            xlim = [0,Ec0(iE)];%normalized transfered momentum q/(mec)
            ylim = [0,2.5];
            %
            leg = {};
            %
            jj = 1;
            ii = 1;
            %
            for iZ = 1:nfig:length(BH2(1).Z0)%Z0 value (screened value)
                %
                leg = [leg,{['Z_0 = ',int2str(BH2(1).Z0(iZ))]}];
                %
                if ~isempty(screening_models{im})
                    sf = squeeze(BH1(1).seBH1(theta_display(it),iE,:,end))./squeeze(BH2(im).seBH2(theta_display(it),iE,:,iZ));
                    graph1D_jd(k,sf,0,0,xlab,ylab,tit,leg,xlim,ylim,linestyle{ii},'none',linecolor{jj},2,siz,gca);     
                end
                %
                if jj == length(linecolor)
                    jj = 1;
                    ii = ii + 1;
                else
                    jj = jj + 1;
                end
                %
                drawnow
                %
                grid on
                %
            end
        end
    end
end
%