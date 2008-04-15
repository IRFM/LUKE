function [] = bremdiagdisplay_dke_yp(hxr,Zbremchord,Zbremplasma,Zbremdiag,chord_display,kphot_display,p_opt,filename,hxrexp);
%
% This function draws local properties of the plasma bremsstrahlung
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 5,
   chord_display = 1;
   kphot_display = hxr.kphot(round(length(hxr.kphot)/2));%keV
   p_opt = 2;
   filename = '';
end
if nargin < 6,
    kphot_display = hxr.kphot(round(length(hxr.kphot)/2));%keV
    p_opt = 2;
    filename = '';
end
if nargin < 7,
    p_opt = 2;
    filename = '';
end
if nargin < 8,
    filename = '';
end
nchords = length(hxr.alpha_hxr);
%
ikphot_display = max(find(Zbremdiag.kfit <= kphot_display));
ikphot_display_2 = max(find(hxr.kphot <= kphot_display));
nkphot = length(hxr.kphot);
dkphot_display = Zbremdiag.dkfit(1);
%
figure('Name','Plasma bremsstrahlung spectrum');
graph1D_jd(Zbremdiag.kfit,Zbremdiag.brem_bd_plasma(chord_display,:)./Zbremdiag.dkfit(1),0,1,'Photon energy k (keV)','dN_{phot}/dk.dt [keV^{-1}.s^{-1}]',['Non-thermal Bremsstrahlung, chord #',num2str(chord_display),', \Deltak = ',num2str(dkphot_display),'keV'],NaN,'','','-','non','b',2);
print_jd(p_opt,[filename,'_PlasmaSpectrum']);
%	
figure('Name','Pulse bremsstrahlung spectrum');
graph1D_jd(Zbremdiag.kfit,Zbremdiag.brem_bd_diag(chord_display,:)./Zbremdiag.dkfit(1),0,1,'Pulse energy channel E (keV)','dN_{pulse}/dE.dt [keV^{-1}.s^{-1}]',['HXR diagnostic count rate, chord #',num2str(chord_display),', \DeltaE = ',num2str(dkphot_display),'keV'],NaN,'','','-','non','b',2);
print_jd(p_opt,[filename,'_PulseSpectrum']);
%
figure('Name','Plasma bremsstrahlung profile');
graph1D_jd([1:length(Zbremdiag.tphot_plasma)],Zbremdiag.brem_bd_plasma(:,ikphot_display),0,0,'Chord number','dN_{phot}/dt [s^{-1}]',['Plasma count rate, k=',num2str(Zbremdiag.kfit(ikphot_display)),'�',num2str(dkphot_display/2),'keV'],NaN,'','','-','non','b',2);
print_jd(p_opt,[filename,'_PlasmaHXRProfile']);
%
if all(Zbremchord.mask_hxr(:)),%bremmstrahlung calculated at all positions
	for i=1:size(Zbremchord.mask_hxr,1),
		for j=1:size(Zbremchord.mask_hxr,2),
			%if ~isempty(Zbremplasma.brem_perp{i,j}),
				brem_forward(i,j,:) = reshape(Zbremplasma.brem_forward{i,j},[1,1,nkphot]);
				brem_backward(i,j,:) = reshape(Zbremplasma.brem_backward{i,j},[1,1,nkphot]);
				brem_perp(i,j,:) = reshape(Zbremplasma.brem_perp{i,j},[1,1,nkphot]);
				brem_4pi(i,j,:) = reshape(Zbremplasma.brem_4pi{i,j},[1,1,nkphot]);
			%end
		end
	end
%
	figure('Name',['Plasma forward bremsstrahlung at energy ',num2str(kphot_display)]);
	graph2D_jd(Zbremchord.r_hxr.*cos(Zbremchord.theta_hxr),Zbremchord.r_hxr.*sin(Zbremchord.theta_hxr),brem_forward(:,:,ikphot_display_2).','x','y',['Plasma forward bremsstrahlung at energy ',num2str(kphot_display)],NaN,NaN,1);
	print_jd(p_opt,[filename,'_PlasmaHXRbrem_forward']);axis('equal')
%
	figure('Name',['Plasma backward bremsstrahlung at energy ',num2str(kphot_display)]);
	graph2D_jd(Zbremchord.r_hxr.*cos(Zbremchord.theta_hxr),Zbremchord.r_hxr.*sin(Zbremchord.theta_hxr),brem_backward(:,:,ikphot_display_2).','x','y',['Plasma backward bremsstrahlung at energy ',num2str(kphot_display)],NaN,NaN,1);
	print_jd(p_opt,[filename,'_PlasmaHXRbrem_backward']);axis('equal')
%
	figure('Name',['Plasma perp bremsstrahlung at energy ',num2str(kphot_display)]);
	graph2D_jd(Zbremchord.r_hxr.*cos(Zbremchord.theta_hxr),Zbremchord.r_hxr.*sin(Zbremchord.theta_hxr),brem_perp(:,:,ikphot_display_2).','x','y',['Plasma perp bremsstrahlung at energy ',num2str(kphot_display)],NaN,NaN,1);
	print_jd(p_opt,[filename,'_PlasmaHXRbrem_perp']);axis('equal')
%
	figure('Name',['Plasma 4pi bremsstrahlung at energy ',num2str(kphot_display)]);
	graph2D_jd(Zbremchord.r_hxr.*cos(Zbremchord.theta_hxr),Zbremchord.r_hxr.*sin(Zbremchord.theta_hxr),brem_4pi(:,:,ikphot_display_2).','x','y',['Plasma 4pi bremsstrahlung at energy ',num2str(kphot_display)],NaN,NaN,1);
	print_jd(p_opt,[filename,'_PlasmaHXRbrem_4pi']);axis('equal')
end
%
figure('Name','Pulse bremsstrahlung profile');
graph1D_jd([1:length(Zbremdiag.tphot_plasma)],Zbremdiag.brem_bd_diag(:,ikphot_display),0,0,'Chord number','dN_{pulse}/dt [s^{-1}]',['Pulse count rate, E=',num2str(Zbremdiag.kfit(ikphot_display)),'�',num2str(dkphot_display/2),'keV'],NaN,'','','-','non','b',2);
if exist('hxrexp'),
    leg = {'simulations','experimental'};
    graph1D_jd([1:length(Zbremdiag.tphot_plasma)],hxrexp,0,0,'','','',leg,'','','-','non','r',2);
end   
print_jd(p_opt,[filename,'_PulseHXRProfile']);
%
figure('Name','Measured plasma bremsstrahlung profile');
graph1D_jd([1:length(Zbremdiag.tphot_plasma)],Zbremdiag.brem_bd_diag(:,ikphot_display)./Zbremdiag.meanabsx(:,ikphot_display),0,0,'Chord number','dN_{pulse}/meanabs(E).dt [s^{-1}]',['Measured plasma count rate, E=',num2str(Zbremdiag.kfit(ikphot_display)),'�',num2str(dkphot_display/2),'keV'],NaN,'','','-','non','b',2);
print_jd(p_opt,[filename,'_MeasuredPlasmaHXRProfile']);
%
figure('Name','Plasma photon temperature');
graph1D_jd([1:length(Zbremdiag.tphot_plasma)],Zbremdiag.tphot_plasma,0,0,'Chord number','T_{phot} [keV]','k.dN_{phot}/dk.dt = A.exp(-k/T_{phot}) [50-110 keV]',NaN,'',[0,100],'-','non','b',2,20,gca,1,NaN,NaN,Zbremdiag.etphot_plasma,Zbremdiag.etphot_plasma);
xxlimit = xlim;yylimit = ylim;
ht = text(xxlimit(2)*0.8,yylimit(2)*0.9,['\Deltat = ',num2str(Zbremdiag.dt),' (s)']);set(ht,'fontsize',20);
print_jd(p_opt,[filename,'_PlasmaTph']);
%	
figure('Name','Measured photon temperature');
graph1D_jd([1:length(Zbremdiag.tphot_plasma)],Zbremdiag.tphot_plasma_exp,0,0,'Chord number','T_{phot}^{*} [keV]','E.dN_{pulse}/dE.dt.{\eta}_{E} = A.exp(-E/T_{phot}^{*}) [50-110 keV]',NaN,'',[0,100],'-','non','r',2,20,gca,1,NaN,NaN,Zbremdiag.etphot_plasma_exp,Zbremdiag.etphot_plasma_exp);
xxlimit = xlim;yylimit = ylim;
ht = text(xxlimit(2)*0.8,yylimit(2)*0.9,['\Deltat = ',num2str(Zbremdiag.dt),' (s)']);set(ht,'fontsize',20);
print_jd(p_opt,[filename,'_PulseTph']);
%
%	figure(10015),
%	graph1D_jd([1:length(tphot_plasma)],afit_plasma,0,0,'Chord number','A(k=0) [s^{-1}]','k.dN_{phot}/dk.dt = A.exp(-k/T_{phot})@k=0 [50-110 keV]',NaN,'','','-','non','b',2);
%
%	figure(10016),
%	graph1D_jd([1:length(tphot_plasma)],afit_plasma_exp,0,0,'Chord number','A^{*}(E=0) [s^{-1}]','E.dN_{pulse}/dE.dt.{\eta}_{E} = A.exp(-E/T_{phot}^{*})@E=0 [50-110 keV]',NaN,'','','-','non','r',2);
%
figure('Name','Mean HXR absorption efficiency');
graph1D_jd(Zbremdiag.kfit,Zbremdiag.meanabsx,0,0,'Photon energy channel (keV)','{\eta}_{E}','Mean stopping efficiency {\eta}_{E}',NaN,'','','-','none','r',2);
print_jd(p_opt,[filename,'_MeanAbsorptionEfficiency']);
%
figure('Name','Detector HXR response');
ikinterp_display = max(find(Zbremdiag.kinterp <= kphot_display));
graph1D_jd(Zbremdiag.kinterp,Zbremdiag.gkEinterp_out{chord_display}(ikinterp_display,:),0,0,'Photon energy k','G_{kE}',['Detector response function @k=',num2str(Zbremdiag.kinterp(ikinterp_display)),' (keV), chord#',int2str(chord_display)],NaN,'','','-','non','r',2);
xxlimit = xlim;yylimit = ylim;
ht = text(xxlimit(2)*0.8,yylimit(2)*0.9,['Norm. = ',num2str(trapz(Zbremdiag.kinterp,Zbremdiag.gkEinterp_out{chord_display}(ikinterp_display,:)))]);set(ht,'fontsize',20);
print_jd(p_opt,[filename,'_ResponseFunction']);	
