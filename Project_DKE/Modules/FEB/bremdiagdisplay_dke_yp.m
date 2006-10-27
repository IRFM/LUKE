function [] = bremdiagdisplay_dke_yp(hxr,Zbremchord,Zbremplasma,Zbremdiag,chord_display,kphot_display);
%
% This function draws local properties of the plasma bremsstrahlung
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 5,
   chord_display = 1;
   kphot_display = hxr.kphot(round(length(hxr.kphot)/2));%keV
elseif nargin < 6,
    kphot_display = hxr.kphot(round(length(hxr.kphot)/2));%keV
end
nchords = length(hxr.alpha_hxr);
%
Fig_bremplasma = figure('Name','Plasma bremsstrahlung spectrum');
figure(Fig_bremplasma);
graph1D_jd(Zbremdiag.kfit,Zbremdiag.brem_bd_plasma(chord_display,:),0,1,'Photon energy k (keV)','dN_{phot}/dk.dt [keV^{-1}.s^{-1}]',['Non-thermal Bremsstrahlung, chord #',num2str(chord_display)],NaN,'','','-','non','b',2);
%	
Fig_brempulse = figure('Name','Pulse bremsstrahlung spectrum');
figure(Fig_brempulse);
graph1D_jd(Zbremdiag.kfit,Zbremdiag.brem_bd_diag(chord_display,:),0,1,'Pulse energy channel E (keV)','dN_{pulse}/dE.dt [keV^{-1}.s^{-1}]',['HXR diagnostic count rate, chord #',num2str(chord_display)],NaN,'','','-','non','b',2);
%	
ikphot_display = max(find(Zbremdiag.kfit <= kphot_display));
%
Fig_bremplasmaprof = figure('Name','Plasma bremsstrahlung profile');
figure(Fig_bremplasmaprof);
graph1D_jd([1:length(Zbremdiag.tphot_plasma)],Zbremdiag.brem_bd_plasma(:,ikphot_display),0,0,'Chord number','dN_{phot}/dk.dt [keV^{-1}.s^{-1}]',['HXR diagnostic count rate, k=',num2str(Zbremdiag.kfit(ikphot_display)),' (keV)'],NaN,'','','-','non','b',2);
%	
Fig_brempulseprof = figure('Name','Pulse bremsstrahlung profile');
figure(Fig_brempulseprof);
graph1D_jd([1:length(Zbremdiag.tphot_plasma)],Zbremdiag.brem_bd_diag(:,ikphot_display),0,0,'Chord number','dN_{pulse}/dE.dt [keV^{-1}.s^{-1}]',['HXR diagnostic count rate, E=',num2str(Zbremdiag.kfit(ikphot_display)),' (keV)'],NaN,'','','-','non','b',2);
%
Fig_tphotplasma = figure('Name','Plasma photon temperature');
figure(Fig_tphotplasma);
graph1D_jd([1:length(Zbremdiag.tphot_plasma)],Zbremdiag.tphot_plasma,0,0,'Chord number','T_{phot} [keV]','k.dN_{phot}/dk.dt = A.exp(-k/T_{phot}) [50-110 keV]',NaN,'','','-','non','b',2);
%	
Fig_tphotpulse = figure('Name','Measured photon temperature');
figure(Fig_tphotpulse);
graph1D_jd([1:length(Zbremdiag.tphot_plasma)],Zbremdiag.tphot_plasma_exp,0,0,'Chord number','T_{phot}^{*} [keV]','E.dN_{pulse}/dE.dt.{\eta}_{E} = A.exp(-E/T_{phot}^{*}) [50-110 keV]',NaN,'','','-','non','r',2);
%
%	figure(10015),
%	graph1D_jd([1:length(tphot_plasma)],afit_plasma,0,0,'Chord number','A(k=0) [s^{-1}]','k.dN_{phot}/dk.dt = A.exp(-k/T_{phot})@k=0 [50-110 keV]',NaN,'','','-','non','b',2);
%
%	figure(10016),
%	graph1D_jd([1:length(tphot_plasma)],afit_plasma_exp,0,0,'Chord number','A^{*}(E=0) [s^{-1}]','E.dN_{pulse}/dE.dt.{\eta}_{E} = A.exp(-E/T_{phot}^{*})@E=0 [50-110 keV]',NaN,'','','-','non','r',2);
%
Fig_meanabs = figure('Name','Mean HXR absorption efficiency');
figure(Fig_meanabs);
graph1D_jd(Zbremdiag.kfit,Zbremdiag.meanabsx,0,0,'Photon energy channel (keV)','{\eta}_{E}','Mean stopping efficiency {\eta}_{E}',NaN,'','','-','non','r',2);
%
Fig_response = figure('Name','Detector HXR response');
figure(Fig_response);
ikinterp_display = max(find(Zbremdiag.kinterp <= kphot_display));
graph1D_jd(Zbremdiag.kinterp,Zbremdiag.gkEinterp_out{chord_display}(ikinterp_display,:),0,0,'Photon energy k','G_{kE}',['Detector response function @k=',num2str(Zbremdiag.kinterp(ikinterp_display)),' (keV), chord#',int2str(chord_display)],NaN,'','','-','non','r',2);
faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['Norm. = ',num2str(trapz(Zbremdiag.kinterp,Zbremdiag.gkEinterp_out{chord_display}(ikinterp_display,:)))]);
	
