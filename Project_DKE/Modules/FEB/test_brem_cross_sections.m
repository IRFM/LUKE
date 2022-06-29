%
% test cross-sections and compare with publications
%
close all
clear all
clear mex
%
clc
%
markersize = 12;
markertype(1) = 'o';
markertype(2) = 'o';
markertype(3) = 'o';
linewidth = 2;
fontsize = 14;
colorchoice(1) = 'r';
colorchoice(2) = 'b';
colorchoice(3) = 'g';
colorchoice(4) = 'c';
colorchoice(5) = 'm';
colorchoice(6) = 'k';
%
mb = 1e-31;%millibarns (10^-31 m2)
%
Ec = 50;%Incoming electron kinetic energy (keV)
k = 45;%Emitted photon energy (keV)
theta = linspace(0,pi,100);%angle between incoming electron and emitted photon (rad)
Znucleus = 13;%charge of the nucleus (Al)
%
exp = [0.035,1.263;14.949,1.977;25.031,3.067;40.072,3.914;55.392,3.902;70.326,2.975;89.986,1.893;149.961,0.367];%Exp for Al (Ref : Elwert-Haug, Phys. Rev., 1969, 183, 1, pp. 90-105)
%
[seBHE,seBH,Elwert] = bhe_dke_yp(Ec,k,cos(theta),Znucleus);%Bethe-Heitler (1st Born approx.) + Elwert Coulomb correction (m2)
%
[seEH] = eh_dke_yp(Ec,k,theta,Znucleus);%Elwert Haug formula (m2)
%
[seRDP,seRDP_1,seRDP_2] = rdp_dke_yp(Ec,k,cos(theta),Znucleus);%Roche Ducos and Proriol formula (m2). seRDP_1 and seEH should be identical
%
figure('Name','Ec = 50 keV, k = 45 keV, Z = 13 (Al), no screening, angular scan')
%
plot(theta*180/pi,squeeze(seBH)*k/mb/Znucleus/Znucleus/511,[colorchoice(3),':'],'LineWidth',2);hold on
plot(theta*180/pi,squeeze(seBHE)*k/mb/Znucleus/Znucleus/511,[colorchoice(1),'-'],'LineWidth',2);hold on
plot(theta*180/pi,squeeze(seEH)*k/mb/Znucleus/Znucleus/511,[colorchoice(2),'--'],'LineWidth',2);hold on
plot(theta*180/pi,squeeze(seRDP)*k/mb/Znucleus/Znucleus/511,[colorchoice(4),'-.'],'LineWidth',2);hold on
plot(exp(:,1),exp(:,2),'ko','MarkerSize',12)
legend('Bethe-Heitler','Bethe-Heitler+Elwert','Elwert-Haug','Roche-Ducos-Proriol','Exp. (Z = 13, Al)')
title('Ec = 50 keV, k = 45 keV, Z = 13 (Al)')
xlabel('Photon emission angle \theta (deg.)')
ylabel('(k/Z^2)*d\sigma/dk/d\Omega_k [mb/sterad]')
%
grid minor
drawnow
%
nEc = 45;%Incoming electron kinetic energy (keV)
k = linspace(Ec*1/100,Ec*99/100,100);%Emitted photon energy (keV)
theta = 55*pi/180;%angle between incoming electron and emitted photon (rad)
Znucleus = 13;%charge of the nucleus
%
exp = [13.551,5.756;17.996,5.375;22.504,5.063;26.986,4.749;31.504,4.436;36.061,4.149;40.597,3.831];%Exp for Al  (Ref : Elwert-Haug, Phys. Rev., 1969, 183, 1, pp. 90-105)
%
[seBHE,seBH,Elwert] = bhe_dke_yp(Ec,k,cos(theta),Znucleus);%Bethe-Heitler (1st Born approx.) + Elwert Coulomb correction (m2)
%
[seEH] = eh_dke_yp(Ec,k,theta,Znucleus);%Elwert Haug formula (m2)
%
[seRDP,seRDP_1,seRDP_2] = rdp_dke_yp(Ec,k,cos(theta),Znucleus);%Roche Ducos and Proriol formula (m2)
%
figure('Name','Ec = 45 keV, theta = 55 deg, Z = 13 (Al2O3), no screening, photon energy scan')
plot(k,squeeze(seBH).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(3),':'],'LineWidth',2);hold on
plot(k,squeeze(seBHE).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(1),'-'],'LineWidth',2);hold on
plot(k,squeeze(seEH).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(2),'--'],'LineWidth',2);hold on
plot(k,squeeze(seRDP).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(4),'-.'],'LineWidth',2);hold on
plot(exp(:,1),exp(:,2),'ko','MarkerSize',markersize)
legend('Bethe-Heitler','Bethe-Heitler+Elwert','Elwert-Haug','Roche-Ducos-Proriol','Exp. (Z = 13, Al_2O_3)')
title('Ec = 45 keV, theta = 55 deg, Z = 13 (Al_2O_3)')
xlabel('Photon energy (keV)')
ylabel('(k/Z^2)*d\sigma/dk/d\Omega_k [mb/sterad]')
%
grid minor
drawnow
%
Ec = 180;%Incoming electron kinetic energy (keV)
k = linspace(Ec*30/100,Ec*99/100,100);%Emitted photon energy (keV)
theta = [12.5,27.5,37.5,57.5,77.5,115]*pi/180;%angle between incoming electron and emitted photon (rad)
Znucleus = 13;%charge of the nucleus
%
[seBHE,seBH,Elwert] = bhe_dke_yp(Ec,k,cos(theta),Znucleus);%Bethe-Heitler (1st Born approx.) + Elwert Coulomb correction (m2)
%
[seEH] = eh_dke_yp(Ec,k,theta,Znucleus);%Elwert Haug formula (m2)
%
[seRDP,seRDP_1,seRDP_2] = rdp_dke_yp(Ec,k,cos(theta),Znucleus);%Roche Ducos and Proriol formula (m2)
%
exp = [71.90031152647975, 3.8517441860465116;
90.65420560747663, 3.1017441860465116;
102.42990654205606, 2.5872093023255816;
121.18380062305296, 1.9069767441860468;
141.68224299065417, 1.4011627906976747;
162.6168224299065, 0.8517441860465116;
162.1806853582554, 1.5930232558139537;
125.98130841121495, 2.2645348837209305;
108.53582554517133, 2.5436046511627906;
89.34579439252336, 2.875;
72.33644859813083, 3.1802325581395348;
55.76323987538942, 3.563953488372093;
54.454828660436135, 2.866279069767442;
72.33644859813083, 2.613372093023256;
89.78193146417443, 2.3517441860465116;
108.53582554517133, 2.1424418604651163;
126.41744548286603, 1.8895348837209305;
143.86292834890963, 1.6453488372093026;
162.1806853582554, 1.4011627906976747;
161.30841121495325, 0.7470930232558142;
142.99065420560748, 0.8691860465116283;
125.10903426791275, 0.9912790697674421;
107.22741433021805, 1.0872093023255816;
89.34579439252336, 1.2005813953488373;
73.20872274143302, 1.3401162790697678;
54.454828660436135, 1.4622093023255816;
53.58255451713396, 0.8081395348837215;
71.90031152647975, 0.6947674418604652;
89.78193146417443, 0.5988372093023253;
107.22741433021805, 0.5203488372093021;
126.41744548286603, 0.44186046511627985;
144.29906542056074, 0.38081395348837255;
161.30841121495325, 0.3023255813953494;
179.19003115264792, 0.25872093023255793;
179.19003115264792, 0.6337209302325579;
54.018691588785046, 0.35465116279069786;
71.02803738317756, 0.2761627906976747;
90.65420560747663, 0.19767441860465151;
106.79127725856695, 0.1627906976744189;
126.41744548286603, 0.11918604651162834;
143.4267912772586, 0.10174418604651159;
161.30841121495325, 0.07558139534883779;
179.62616822429902, 0.05813953488372192];%Exp for Al  (Ref : Elwert-Haug, Phys. Rev., 1969, 183, 1, pp. 90-105)
%
figure('Name','Ec = 180 keV, theta = [12.5,27.5,37.5,57.5,77.5,115] deg, Z = 13 (Al), no screening, photon scan')
%
for ii = 1:length(theta)
    %
    plot(k,squeeze(seBHE(ii,:,:)).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(1),'-'],'LineWidth',2);hold on
    plot(k,seEH(:,ii).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(2),'--'],'LineWidth',2);hold on
    plot(k,squeeze(seRDP(ii,:,:)).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(4),'-.'],'LineWidth',2);hold on
    plot(exp(:,1),exp(:,2),'ko','MarkerSize',markersize)
    %
end
%
axis([0,Ec,0,6]);
%
for jj = 1:length(theta)
    %
    text(20,seRDP(jj,1,1).*k(1)/mb/Znucleus/Znucleus/511,[num2str(theta(jj)*180/pi),' deg. \rightarrow'])
    %
end
%
legend('Bethe-Heitler+Elwert','Elwert-Haug','Roche-Ducos-Proriol','Exp. (Z = 13, Al)')
title('Ec = 180 keV, theta = [12.5,27.5,37.5,57.5,77.5,115] deg, Z = 13 (Al)')
xlabel('Photon energy (keV)')
ylabel('(k/Z^2)*d\sigma/dk/d\Omega_k [mb/sterad]')
%
grid minor
drawnow
%
Ec = 180;%Incoming electron kinetic energy (keV)
k = linspace(Ec*18/100,Ec*99/100,100);%Emitted photon energy (keV)
theta = [17.5,37.5,57.5,77.5,115]*pi/180;%angle between incoming electron and emitted photon (rad)
Znucleus = 79;%charge of the nucleus
%
[seBHE,seBH,Elwert] = bhe_dke_yp(Ec,k,cos(theta),Znucleus);%Bethe-Heitler (1st Born approx.) + Elwert Coulomb correction (m2)
%
[seEH] = eh_dke_yp(Ec,k,theta,Znucleus);%Elwert Haug formula (m2)
%
[seRDP,seRDP_1,seRDP_2] = rdp_dke_yp(Ec,k,cos(theta),Znucleus);%Roche Ducos and Proriol formula (m2)
%
exp = [36.470588235294116, 3.9951690821256047;
56.332179930795846, 3.6086956521739135;
74.25605536332179, 3.270531400966184;
92.17993079584775, 2.9323671497584547;
109.13494809688581, 2.6425120772946866;
126.57439446366783, 2.362318840579711;
144.98269896193773, 2.149758454106281;
163.39100346020763, 1.9275362318840585;
180.34602076124565, 1.7826086956521743;
37.43944636678201, 2.8743961352657013;
55.84775086505189, 2.7198067632850247;
72.80276816608998, 2.584541062801933;
91.69550173010381, 2.48792270531401;
109.13494809688581, 2.40096618357488;
133.35640138408306, 2.2946859903381647;
145.46712802768167, 2.2367149758454112;
163.87543252595157, 2.1594202898550727;
180.34602076124565, 2.1014492753623193;
37.43944636678201, 1.772946859903382;
53.42560553633217, 1.6956521739130443;
72.80276816608998, 1.6183574879227058;
91.21107266435985, 1.5797101449275366;
108.65051903114187, 1.5217391304347831;
126.08996539792386, 1.502415458937199;
144.98269896193773, 1.4637681159420293;
162.42214532871975, 1.4347826086956528;
36.470588235294116, 1.0772946859903385;
54.39446366782006, 0.9903381642512086;
71.83391003460207, 0.9227053140096624;
90.24221453287197, 0.8743961352657008;
108.16608996539793, 0.8454106280193248;
126.57439446366783, 0.8067632850241546;
144.01384083044982, 0.7777777777777786;
161.93771626297575, 0.7584541062801939;
35.98615916955016, 0.4685990338164254;
54.878892733564015, 0.41062801932367243;
72.31833910034601, 0.35265700483091855;
90.72664359861591, 0.304347826086957;
107.68166089965399, 0.27536231884058004;
125.60553633217992, 0.26570048309178773;
143.52941176470588, 0.2367149758454108;
162.42214532871975, 0.21739130434782705;
179.37716262975778, 0.20772946859903474;
179.86159169550172, 0.7391304347826093;
179.86159169550172, 1.4154589371980686];%Exp for Au  (Ref : Elwert-Haug, Phys. Rev., 1969, 183, 1, pp. 90-105)
%
figure('Name','Ec = 180 keV, theta = [17.5,37.5,57.5,77.5,115] deg, Z = 79 (Au), no screening, photon scan')
%
for ii = 1:length(theta)
    %
    plot(k,squeeze(seBHE(ii,:,:)).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(1),'-'],'LineWidth',2);hold on
    plot(k,seEH(:,ii).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(2),'--'],'LineWidth',2);hold on
    plot(k,squeeze(seRDP(ii,:,:)).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(4),'-.'],'LineWidth',2);hold on
    plot(exp(:,1),exp(:,2),'ko','MarkerSize',markersize)
    %
end
%
axis([0,Ec,0,7]);
%
for jj = 1:length(theta)
    %
    text(5,seRDP(jj,1,1).*k(1)/mb/Znucleus/Znucleus/511,[num2str(theta(jj)*180/pi),' deg. \rightarrow'])
    %
end
%
%
legend('Bethe-Heitler+Elwert','Elwert-Haug','Roche-Ducos-Proriol','Exp. (Z = 79, Au)')
title('Ec = 180 keV, theta = [17.5,37.5,57.5,77.5,115] deg, Z = 79 (Au)')
xlabel('Photon energy (keV)')
ylabel('(k/Z^2)*d\sigma/dk/d\Omega_k [mb/sterad]')
%
grid minor
drawnow
%
Ec = 9660;%Incoming electron kinetic energy (keV)
k = linspace(Ec*18/100,Ec*99/100,20);%Emitted photon energy (keV)
theta = [0,3,5.9]*pi/180;%angle between incoming electron and emitted photon (rad)
Znucleus = 79;%charge of the nucleus
%
[seBHE,seBH,Elwert] = bhe_dke_yp(Ec,k,cos(theta),Znucleus);%Bethe-Heitler (1st Born approx.) + Elwert Coulomb correction (m2)
%
[seEH] = eh_dke_yp(Ec,k,theta,Znucleus);%Elwert Haug formula (m2)
%
[seRDP,seRDP_1,seRDP_2] = rdp_dke_yp(Ec,k,cos(theta),Znucleus,100,151,3001);%Roche Ducos and Proriol formula (m2)
%
exp = [0.930434782608696, 1472.2222222222222;
1.9739130434782615, 1277.7777777777774;
3.9217391304347835, 944.4444444444439;
5.939130434782609, 694.4444444444439;
7.747826086956522, 499.99999999999955;
9.13913043478261, 236.11111111111086;
1, 307.5966850828729;
1.9122807017543835, 262.01657458563534;
3.8771929824561404, 203.3149171270718;
6.05263157894737, 148.06629834254142;
7.7368421052631575, 113.53591160220992;
9.210526315789473, 57.59668508287291;
1.1403508771929793, 72.63157894736842;
2.052631578947363, 59.736842105263165;
3.6666666666666643, 41.31578947368422;
6.122807017543856, 25.657894736842124;
7.526315789473685, 19.21052631578948;
9.280701754385966, 8.848684210526315;];%Exp for Au  (Ref :Roche-Ducos-Proriol, Phys. Rev. A, 1972, 5, 6, pp. 2403-2408)
%
figure('Name','Ec = 9.66 MeV, theta = [0,3,5.9] deg, Z = 79 (Au), no screening, photon scan')
%
for ii = 1:length(theta)
    %
    semilogy(k/1000,squeeze(seBHE(ii,:,:)).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(1),'-'],'LineWidth',2);hold on
    semilogy(k/1000,seEH(:,ii).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(2),'--'],'LineWidth',2);hold on
    semilogy(k/1000,squeeze(seRDP(ii,:,:)).*k(:)/mb/Znucleus/Znucleus/511,[colorchoice(4),'-.'],'LineWidth',2);hold on
    semilogy(exp(:,1),exp(:,2),'ko','MarkerSize',markersize)
    %
end
%
axis([0,10,0,5000]);
%
for jj = 1:length(theta)
    %
    text(0.4,seRDP(jj,1,1).*k(1)/mb/Znucleus/Znucleus/511,[num2str(theta(jj)*180/pi),' deg. \rightarrow'])
    %
end
%
legend('Bethe-Heitler+Elwert','Elwert-Haug','Roche-Ducos-Proriol','Exp. (Z = 79, Au)')
title('Ec = 9.66 MeV, theta = [0,3,5.9] deg, Z = 79 (Au)')
xlabel('Photon energy (MeV)')
ylabel('(k/Z^2)*d\sigma/dk/d\Omega_k [mb/sterad]')
%
grid minor
drawnow
%







