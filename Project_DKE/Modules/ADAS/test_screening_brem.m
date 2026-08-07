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
%test screening bremsstrahlung
%
close all
clear all
clc
%
disp('Choose test number (1,2,3,4) in the script')
%
%test = 1;%Fig.17, ref. Koch-Motz 1959 & Elwert-Haug 1969, Fig. 16
%test = 2;%Fig.16, ref. Koch-Motz 1959 
%test = 3;%Fig.12, Elwert-Haug 1969
test = 4;%multidimensional comparison with computational time evaluation
%test = NaN;%no test
%
if test == 1
    %
    theta = [0,1.45,3.01,6.03];%Photon observation angle (deg)
    E0 = 4540;%Incoming electron kinetic energy keV
    kmin = 1;
    k = linspace(kmin,E0-kmin,1000);%photon energy keV
    Z = 79;
    ndisp = input_dke_yp('Choose the photo angle theta, (1 : 0 deg., 2 : 1.45 deg., 3 : 3.01 deg., 4 : 6.03 deg.)',1);%theta angle
    %
    [seBHE,seBH,Elwert,ec,k_out,c] = bhe_dke_yp(E0,k,cos(theta*pi/180),Z);
    [seEH,ec,e] = eh_dke_yp(E0,k,theta*pi/180,Z);
    [seBHE_num,seBH_num, Elwert_num,ec_num,k_num,c_num] = bhe_dke_kk(E0,k,cos(theta*pi/180),Z);
    %
    seBHE = squeeze(seBHE)*10000/0.511;%cm2/MeV/str units
    seBH = squeeze(seBH)*10000/0.511;%cm2/MeV/str units
    Elwert = squeeze(Elwert);
    ec = squeeze(ec);
    k_out = squeeze(k_out);
    c = squeeze(c);
    %
    seEH = squeeze(seEH)/0.511;%cm2/MeV/str units
    %
    siz = 20+14i;
    xlim = [0,max(k)];%normalized transfered momentum q/(mec)
    ylim = [1e-24,1e-16];
    xlab = 'k (keV)';
    ylab = '10^n.d^2\sigma/(dk.d\Omega_k) (cm^2/str/MeV)';
    tit = ['Fig.17 (Kock&Motz 1959), e-i brem., E_0=',num2str(E0),'keV, Z=',int2str(Z),', \theta_k=',num2str(theta(ndisp)),'deg., n=',int2str(4-ndisp)];
    leg = {'Bethe-Heitler (2BN formula) + Elwert','Bethe-Heitler','Elwert-Haug'};
    %
    figure('Name',['Fig.17 (Kock&Motz 1959), e-i brem., E_0=',num2str(E0),'keV, Z=',int2str(Z),', \theta_k=',num2str(theta(ndisp)),'deg., n=',int2str(4-ndisp)])
    graph1D_jd(k,10^(4-ndisp)*seBHE(ndisp,:),0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca);
    graph1D_jd(k,10^(4-ndisp)*seBH(ndisp,:),0,1,xlab,ylab,tit,leg,xlim,ylim,'--','none','b',2,siz,gca);
    graph1D_jd(k,10^(4-ndisp)*seEH(:,ndisp),0,1,xlab,ylab,tit,leg,xlim,ylim,'-.','none','k',2,siz,gca);
    %
elseif test == 2
    %
    theta = [0,30,60,90,180];%Photon observation angle (deg)
    E0 = 500;%Incoming electron kinetic energy keV
    kmin = 1;
    k = linspace(kmin,E0-kmin,1000);%photon energy keV
    Z = 79;
    ndisp = input_dke_yp('Choose the photo angle theta, (1 : 0 deg., 2 : 30 deg., 3 : 60 deg., 4 : 90 deg., 5 : 180 deg)',1);%theta angle
    %
    [seBHE,seBH,Elwert,ec,k_out,c] = bhe_dke_yp(E0,k,cos(theta*pi/180),Z);
    [seEH,ec,e] = eh_dke_yp(E0,k,theta*pi/180,Z);
    %
    seBHE = squeeze(seBHE)*10000/511/1e-27;%mb/str/keV units
    seBH = squeeze(seBH)*10000/511/1e-27;%mb/str/keV units
    Elwert = squeeze(Elwert);
    ec = squeeze(ec);
    k_out = squeeze(k_out);
    c = squeeze(c);
    %
    seEH = squeeze(seEH)/511/1e-27;%mb/str/keV units
    %
    siz = 20+14i;
    xlim = [0,max(k)];%normalized transfered momentum q/(mec)
    ylim = [0.001,100];
    xlab = 'k (keV)';
    ylab = '(k/Z^2).d^2\sigma/(dk.d\Omega_k) (mb/str)';
    tit = ['Fig.16 (Kock&Motz 1959), e-i brem., E_0=',num2str(E0),'keV, Z=',int2str(Z),', \theta_k=',num2str(theta(ndisp)),'deg.'];
    leg = {'Bethe-Heitler (2BN formula) + Elwert','Bethe-Heitler','Elwert-Haug'};
    %
    figure('Name',['Fig.16 (Kock&Motz 1959), e-i brem., E_0=',num2str(E0),'keV, Z=',int2str(Z),', \theta_k=',num2str(theta(ndisp)),'deg.'])
    graph1D_jd(k,k.*seBHE(ndisp,:)/Z^2,0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca);
    graph1D_jd(k,k.*seBH(ndisp,:)/Z^2,0,1,xlab,ylab,tit,leg,xlim,ylim,'--','none','b',2,siz,gca);
    graph1D_jd(k,k(:).*seEH(:,ndisp)/Z^2,0,1,xlab,ylab,tit,leg,xlim,ylim,'-.','none','k',2,siz,gca);
    %
elseif test == 3
    %
    theta = linspace(0,180,100);%Photon observation angle (deg)
    E0 = 45;%Incoming electron kinetic energy keV
    k = 40;%photon energy keV
    Z = 13;
    %
    [seBHE,seBH,Elwert,ec,k_out,c] = bhe_dke_yp(E0,k,cos(theta*pi/180),Z);
    [seEH,ec,e] = eh_dke_yp(E0,k,theta*pi/180,Z);
    %
    seBHE = squeeze(seBHE)*10000/511/1e-27;%mb/str/keV units
    seBH = squeeze(seBH)*10000/511/1e-27;%mb/str/keV units
    Elwert = squeeze(Elwert);
    ec = squeeze(ec);
    k_out = squeeze(k_out);
    c = squeeze(c);
    %
    seEH = squeeze(seEH)/511/1e-27;%mb/str/keV units
    %
    siz = 20+14i;
    xlim = [0,180];%normalized transfered momentum q/(mec)
    ylim = [0,5];
    xlab = '\theta (deg.)';
    ylab = '(k/Z^2).d^2\sigma/(dk.d\Omega_k) (mb/str)';
    tit = ['Fig.12 (Elwert&Haug 1969), e-i brem., E_0=',num2str(E0),'keV, Z=',int2str(Z),', k=',num2str(k),'keV'];
    leg = {'Bethe-Heitler (2BN formula) + Elwert','Bethe-Heitler','Elwert-Haug'};
    %
    figure('Name',['Fig.12 (Elwert&Haug 1969), e-i brem., E_0=',num2str(E0),'keV, Z=',int2str(Z),', k=',num2str(k),'keV'])
    graph1D_jd(theta,k.*seBHE/Z^2,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca);
    graph1D_jd(theta,k.*seBH/Z^2,0,0,xlab,ylab,tit,leg,xlim,ylim,'--','none','b',2,siz,gca);
    graph1D_jd(theta,k.*seEH/Z^2,0,0,xlab,ylab,tit,leg,xlim,ylim,'-.','none','k',2,siz,gca);
    %
    %plot(theta,k.*seBHE/Z^2,'r-',theta,k.*seBH/Z^2,'b--',theta,k(:).*seEH/Z^2,'k-.');grid on
    %
else
    %
    E0 = linspace(10,1000,11);%Incoming electron kinetic energy (keV)
    k = linspace(10,1000,100);%photon energy keV
    theta = [0,30,60,90,120,150,180];%Photon observation angle (deg)
    Z = [1,6,18,29,74];%hydrogen, carbon, argon, copper, tungsten
    %
    seBHE = zeros(length(Z),length(theta),length(E0),length(k));
    seBH = zeros(length(Z),length(theta),length(E0),length(k));
    seEH = zeros(length(Z),length(theta),length(E0),length(k));    
    %
    for iZ = 1:length(Z)
        tstart = tic;
            [seBHE(iZ,:,:,:),seBH(iZ,:,:,:)] = bhe_dke_yp(E0,k,cos(theta*pi/180),Z(iZ));
        telapsed_BHE(iZ) = toc(tstart);
        %
        tstart = tic;
            for itheta = 1:length(theta)
                seEH(iZ,itheta,:,:) = eh_dke_yp(E0,k,theta(itheta)*pi/180,Z(iZ))';
            end
        telapsed_EH(iZ) = toc(tstart);
        %
    end
    %
    seBHE = seBHE*10000/511/1e-27;%mb/MeV/str units
    seBH = seBH*10000/511/1e-27;%mb/MeV/str units
    seEH = seEH/511/1e-27;%mb/str/keV units
    %
    siz = 20+14i;
    xlim = [0,max(k)];%normalized transfered momentum q/(mec)
    ylim = [0.001,1000];
    xlab = 'k (keV)';
    ylab = '(k/Z^2).d^2\sigma/(dk.d\Omega_k) (mb/str)';
    leg = {'Bethe-Heitler (2BN formula) + Elwert','Elwert-Haug'};
    %
    for iZ = 1:length(Z)
        for itheta = 1:length(theta)
            figure('Name',['Relativistic e-i bremsstrahlung, Z = ',int2str(Z(iZ)),' photon angle = ',num2str(theta(itheta)),' deg.'])
            tit = ['Relativistic e-i bremsstrahlung, Z = ',int2str(Z(iZ)),' photon angle = ',num2str(theta(itheta)),' deg.'];
            graph1D_jd(k,k.*squeeze(seBHE(iZ,itheta,:,:))/Z(iZ)^2,0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca);
            graph1D_jd(k,k.*squeeze(seEH(iZ,itheta,:,:))/Z(iZ)^2,0,1,xlab,ylab,tit,leg,xlim,ylim,'--','none','b',2,siz,gca);
            drawnow
        end
    end
    %
    xlim = [min(Z),max(Z)];
    ylim = [10^round(log10(min(min(telapsed_BHE)))),10^round(log10(max(max(telapsed_EH))))];
    figure('Name',['Relativistic e-i bremsstrahlung, (np = ',int2str(length(E0)),', nk = ',int2str(length(k)),', ntheta = ',int2str(length(theta)),')'])
    tit = ['Relativistic e-i bremsstrahlung, (n_p = ',int2str(length(E0)),', n_k = ',int2str(length(k)),', n_{\theta} = ',int2str(length(theta)),')'];
    xlab = 'Z';
    ylab = 'Elapsed time (s)';
    graph1D_jd(Z,telapsed_BHE,0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca);
    graph1D_jd(Z,telapsed_EH,0,1,xlab,ylab,tit,leg,xlim,ylim,'--','none','b',2,siz,gca);
    %
end




