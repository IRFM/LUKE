function [khisto1,Tphi,eTphi,Qi,Tpho,eTpho,Qo,TphADC,eTphADC,QADC,Tphcode,eTphcode,Qcode] = pileup_dke_yp(pileupsim,diag)
%
% Study of of pile-up and dead-time for x-ray spectrometry at high counting rate
% Global study based on Poisson statistics. Monte-Carlo simulation.
%
% by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
%
if nargin < 2,
    error('Not enough input arguments for pileup_dke_yp');
end
%
pur = pileupsim.pur;
nreset = pileupsim.nreset;
typspec = pileupsim.typspec;
Ni0 = pileupsim.Ni0;
ech = pileupsim.ech;
k0 = pileupsim.k0;
modeMC = pileupsim.modeMC;
NiMC = pileupsim.NiMC;
seuil = pileupsim.seuil;
p_opt = pileupsim.p_opt;
filename = pileupsim.filename;
%
tok = diag.tok;
namediag = diag.namediag;
theta = diag.theta;
tc0 = diag.tc0;
tpeak = diag.tpeak;
tl0 = diag.tl0;
tp0 = diag.tp0;
beta = diag.beta;
kmin = diag.kmin;
kmin0 = diag.kmin0;
kmax = diag.kmax;
nhisto = diag.nhisto;
%
Ni = [1:500:10*Ni0+1];
%
tp = tp0*theta;
tl = tl0*theta;
tc = tc0;
if tc < tl-tp, tc1 = tl-tp;else tc1 = tc;end 
%
Ncc = Ni./(exp((tp+tl)*Ni*1e-6)+Ni*(tc1-(tl-tp))*1e-6);%if tc > (tl-tp),From pile-up theory
Nc = Ni./exp((tp+tl)*Ni*1e-6);%if tc < (tl-tp),From pile-up theory
% 
delta = (Ni-Ncc)./Ni;%Only valid for moderate count rate
index = find(delta<=seuil);
%
[ax] = graph1D_jd(Ni,Ncc,0,0,'Input count rate (photon/s)','Output count rate (cps/s)',['Pile-up effect ',tok,'-',namediag],NaN,[0,max(Ni)*1.01],[0,max(Nc)*1.5],'-','none','r',2);
[ax] = graph1D_jd(Ni,Nc,0,0,'Input count rate (photon/s)','Output count rate (cps/s)',['Pile-up effect ',tok,'-',namediag],NaN,[0,max(Ni)*1.01],[0,max(Nc)*1.5],'--','none','g',2);
[ax] = graph1D_jd(Ni,Ni,0,0,'Input count rate (photon/s)','Output count rate (cps/s)',['Pile-up effect ',tok,'-',namediag],NaN,[0,max(Ni)*1.01],[0,max(Nc)*1.5],'-.','none','k',2);
legend('Pile-up + ADC','Pile-up only','Ideal');
[ax] = graph1D_jd([Ni(max(index)),Ni(max(index))],[1,max(Nc)*1.5],0,0,'Input count rate (photon/s)','Output count rate (cps/s)',['Pile-up effect ',tok,'-',namediag],NaN,[0,max(Ni)*1.01],[0,max(Nc)*1.5],'--','none','b',1);
[ax] = graph1D_jd([1,max(Ni)],[Ncc(max(index)),Ncc(max(index))],0,0,'Input count rate (photon/s)','Output count rate (cps/s)',['Pile-up effect ',tok,'-',namediag],NaN,[0,max(Ni)*1.01],[0,max(Nc)*1.5],'--','none','b',1);
axis('square');
print_jd(p_opt,[filename,'_CountRate']);
%
disp('----------------------------------------------------------------------');
info_dke_yp(1,'Pile-up at high count rate');
disp('----------------------------------------------------------------------');
disp(['   - Shaping time (theta)   = ',num2str(theta),' 1e-6 (s)']);
disp(['   - tp (peak time, approx. 2*theta) = ',num2str(tp),' 1e-6 (s)']);
disp(['   - tl (pulse length, approx. 6*theta) = ',num2str(tl),' 1e-6 (s)']);
disp(['   - tc (coding dead-time) = ',num2str(tc),' 1e-6 (s)']);
disp(['   - Maximum theoretical output count rate without coding dead-time (Nc) = ',num2str(max(Nc)),' (cps/s)']);
disp(['   - Maximum theoretical output count rate with coding dead-time(Ncc) = ',num2str(max(Ncc)),' (cps/s)']);
disp(['   - For ',num2str(seuil*100),' (%) pile-up: ']);
disp(['      - Ni             = ',int2str(Ni(max(index))),' (cps/s)']);
disp(['      - No (Unpiled-up) = ',int2str(Ncc(max(index))),' (cps/s)']);
%
% Monte-Carlo calculations
%
disp('----------------------------------------------------------------------');
info_dke_yp(1,['Monte-Carlo study of pile-up and dead time for ',tok,'-',namediag])
disp('----------------------------------------------------------------------');
%
%	Pulse model
%
alpha = beta*tp/(tl-tp);
a = k0/((tp^(alpha+beta))*((beta/alpha)^beta));
t = [0:tl/100:tl];y = a*(t.^alpha).*((tl-t).^beta);
figure('Name','Amplifier pulse shape'),
[ax] = graph1D_jd(t,y,0,0,'Time (microsecond)','E (keV)',['Amplifier pulse shape ',tok,'-',namediag],NaN,'','','-','none','r',2);
print_jd(p_opt,[filename,'_PulseModel']);
%
% Monte-Carlo calculation
%
if modeMC == 1,
    Ni_in = Ni(max(index));
else   
    Ni_in = NiMC;
end   
%    
[ki,ko,kADC,kkADC,emp,kcode,khisto,khisto1,histoki,histoko,histokADC,histokcode] = fpilup_dke_yp(diag,nreset,Ni_in,kmin0,k0,ech,typspec,pur);
%
%  Display initial spectrum 
%   
maxfig = 10^(round(log(max(hist_dke_yp(ki,khisto)))/log(10))+1);
%
figure('Name','Pile-up effect/Spectrum IN'),   
hist_dke_yp(ki,khisto,'k (keV)','',['Spectrum IN, Ntot = ',int2str(length(ki)),' (cps/s)'],[0,kmax],[1,maxfig],'m','-',2);
if typspec==2,
   kint = (khisto1>=diag.khistotphmin & khisto1 <=diag.khistotphmax);
   [Tphi,eTphi,Ai,eAi,Qi] = tphfit_dke_yp(khisto1(kint)',histoki(kint)',sqrt(histoki(kint)'));
   pfit = polyfit(khisto1,log(histoki),1);
   krefi = -1/pfit(1);afiti = exp(pfit(2));
   hold on
   [ax] = graph1D_jd(khisto1,afiti*exp(-khisto1/krefi),0,1,'k (keV)','','Spectrum IN',NaN,[0,kmax],[1,maxfig],'--','none','m',1);
   hold off;
   legend('Monte-Carlo','Fit')
end
print_jd(p_opt,[filename,'_IN_PulseSpectrum']);
%
%	Display detected spectrum 
%
figure('Name','Pile-up effect/Spectrum OUT'),
hist_dke_yp(ko,khisto,'k (keV)','',['Spectrum OUT, Ntot = ',int2str(length(ko)),' (cps/s)'],[0,kmax],[1,maxfig],'m','-',2);
if typspec==2,
   [Tpho,eTpho,Ao,eAo,Qo] = tphfit_dke_yp(khisto1(kint)',histoko(kint)',sqrt(histoko(kint)'));
   pfit = polyfit(khisto1,log(histoko),1);
   krefo = -1/pfit(1);afito = exp(pfit(2));
   hold on
   [ax] = graph1D_jd(khisto1,afito*exp(-khisto1/krefo),0,1,'k (keV)','','Spectrum OUT',NaN,[0,kmax],[1,maxfig],'--','none','m',1);
   hold off;
   legend('Monte-Carlo','Fit')
end
print_jd(p_opt,[filename,'_OUT_PulseSpectrum']);
%
%	Display dead time spectrum
%
figure('Name','Pile-up effect/Spectrum OUT + coding dead-time'),
hist_dke_yp(kkADC,khisto,'k (keV)','',['Spectrum OUT + coding dead-time, Ntot = ',int2str(length(ki)),' (cps/s)'],[0,kmax],[1,maxfig],'m','-',2);
if typspec==2,
   [TphADC,eTphADC,AADC,eAADC,QADC] = tphfit_dke_yp(khisto1(kint)',histokADC(kint)',sqrt(histokADC(kint)'));
   pfit = polyfit(khisto1,log(histokADC),1);
   krefADC = -1/pfit(1);afitADC = exp(pfit(2));
   hold on
   [ax] = graph1D_jd(khisto1,afitADC*exp(-khisto1/krefADC),0,1,'k (keV)','','Spectrum OUT+ADC',NaN,[0,kmax],[1,maxfig],'--','none','m',1);
   hold off;
   legend('Monte-Carlo','Fit')
end
print_jd(p_opt,[filename,'_OUTWithDeadTime_PulseSpectrum']);
%
%	Display measured spectrum
%
if pur==0,
   titlemode = ['Measured spectrum (PUR OFF), Ntot = ',int2str(length(kcode)),' (cps/s)'];
elseif pur==1,
   titlemode = ['Measured spectrum (PUR ON), Ntot = ',int2str(length(kcode)),' (cps/s)'];
end
%
figure('Name','Pile-up effect/Measured spectrum'),
hist_dke_yp(kcode,khisto,'k (keV)','',titlemode,[0,kmax],[1,maxfig],'m','-',2);
if typspec==2,
   [Tphcode,eTphcode,Acode,eAcode,Qcode] = tphfit_dke_yp(khisto1(kint)',histokcode(kint)',sqrt(histokcode(kint)'));
   pfit = polyfit(khisto1,log(histokcode),1);
   krefcode = -1/pfit(1);afitcode = exp(pfit(2));
   hold on
   [ax] = graph1D_jd(khisto1,afitcode*exp(-khisto1/krefcode),0,1,'k (keV)','',titlemode,NaN,[0,kmax],[1,maxfig],'--','none','m',1);
   hold off;
   legend('Monte-Carlo','Fit')
end
print_jd(p_opt,[filename,'_MeasuredSpectrum']);
%
%	Summary
%
info_dke_yp(2,['Number of incoming pulses : ',int2str(Ni_in),' (photon/s)'])
info_dke_yp(2,['Fraction of piled pulses : ',num2str(100*(sum(emp==1)+sum((emp==2)/2))*ech/Ni_in),' (%)'])
info_dke_yp(2,['Fraction of lost pulses (coding dead-time)  : ',num2str(100*sum(kADC==-1)*ech/Ni_in),' (%)'])
skcode = size(kcode);
%
if pur==0,
 	info_dke_yp(2,['Fraction of encoded pulses (PUR OFF) : ',num2str(100*skcode(1)*ech/Ni_in),' (%)'])
elseif pur==1,
 	info_dke_yp(2,['Fraction of encoded pulses (PUR ON)  : ',num2str(100*skcode(1)*ech/Ni_in),' (%)'])
end
%
if typspec==2,
  	info_dke_yp(2,'Pile-up effect on the measured energy spectrum')
    disp(['   - Photon energy interval for Tph calculations: ',num2str(min(khisto1(kint))),' - ',num2str(max(khisto1(kint))),' (keV)']);
  	disp(['   - Reference energy k0 (exponential photon spectrum)  = ',num2str(k0),' (keV)']);
  	disp(['   - Tph (IN)   = ',num2str(Tphi),' +/- ',num2str(eTphi),' (keV), confidence level: ',num2str(Qi)]);
  	disp(['   - Tph (OUT)  = ',num2str(Tpho),' +/- ',num2str(eTpho),' (keV), confidence level: ',num2str(Qo)]);
  	disp(['   - Tph (OUT + coding dead-time)  = ',num2str(TphADC),' +/- ',num2str(eTphADC),' (keV), confidence level: ',num2str(QADC)]);
    if pur==1,
  	   disp(['   - Tph (CODED, PUR ON)= ',num2str(Tphcode),' +/- ',num2str(eTphcode),' (keV), confidence level: ',num2str(Qcode)]);
    elseif pur==0,
       disp(['   - Tph (CODED, PUR OFF)= ',num2str(Tphcode),' +/- ',num2str(eTphcode),' (keV), confidence level: ',num2str(Qcode)]);
    end
end
%

