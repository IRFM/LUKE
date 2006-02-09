function [vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr,...
kphot,brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi,lchord,rho_out,theta_out,...
brem_bd_plasma,brem_bd_diag,tphot_plasma,afit_plasma,tphot_plasma_exp,afit_plasma_exp,meanabsx] = display_dke_1yp(filename,id_hxr,path_hxr,auto_mode_in,igor_mode)
%
% Display results of the Electron Drift Kinetic solver (test_dke_1yp.m)
%
%by Y.Peysson CEA-DRFC 02/08/2003 <yves.peysson@cea.fr>
%
%
close all
warning off;
[s,dossier,machine] = comput_dke_yp;
if nargin == 0,	
	dir('RESULTS_*.mat');
	filename = [];
	filename = input_dke_yp('Kinetic calculations filename ',filename);
%
	dir('HXR_*.mat');
	filenamehxr = [];
	filenamehxr = input_dke_yp('HXR tomographic system filename ',filenamehxr);
%
	auto_mode_in = input_dke_yp('Automatic display mode (yes: 1, no: 0) ',0);
	igor_mode = input_dke_yp('Igor software output (yes: 1, no: 0) ',0);%For figure by figure data output (Easy data transfer to Igor software for final output)
elseif nargin == 1,
	auto_mode_in = input_dke_yp('Automatic display mode (yes: 1, no: 0) ',0);
	igor_mode = input_dke_yp('Igor software output (yes: 1, no: 0) ',0);%For figure by figure data output (Easy data transfer to Igor software for final output)
elseif nargin == 2,
	igor_mode = 0;%Automatic mode when test_dke_1yp.m is running
end
%
load(filename);%Load DKE output data
load(filenamehxr);%Load HXR structure
%
display_mode = input_dke_yp('Display graphics (yes: 1, no: 0)',1) + 1;
%
if nargin >= 2,
	auto_mode = auto_mode_in;
end
%
filenameroot = filename(1:findstr(filename,'_out.mat')-1);
%  
disp('-------------------------------------------------------------------------------------------------------------------');
disp('Display results of Drift Kinetic Equation solver (see test_dke_1yp.m)');
disp('-------------------------------------------------------------------------------------------------------------------');
%
nchords = length(hxr.alpha_hxr);
theta_display = 180;
chord_display = 1;
kphot_display = 70;%keV
IPBT = 1;%Cosine between the plasma current and the toroidal B-field directions
while 1,
	ir_display_dke = find(r_dke == ir_display);
	if auto_mode_in == 0,
		disp(' ')
		disp('*****************************************************************************************************************************')
		disp('*************************************WARNING: from tokamak topview, BT is clockwise !****************************************')
		IPBT = input_dke_yp(['*********************************** Sign of the scalar product BT.Ip (-1 or +1) (exit: <=0)'],IPBT);
		disp('************************************************************************** For local output only ****************************')
		ir_display_dke = input_dke_yp(['*********************************** Radial index value (1-',int2str(nr_dke),') (exit: <=0)'],ir_display_dke);
		theta_display = input_dke_yp(['*********************************** Poloidal angle value (0-180 deg) (exit: <=0)'],theta_display);
		chord_display = input_dke_yp(['*********************************** Chord index value (0-',int2str(nchords),') (exit: <=0)'],chord_display);
		kphot_display = input_dke_yp(['*********************************** Photon energy (20-200 keV) (exit: <=0)'],kphot_display);
		disp('*****************************************************************************************************************************')
		disp(' ')
		if ir_display_dke < 1,
			break
		end
	end
%
	[vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr] = bremchord_dke_yp(equil,IPBT,hxr,xpsin_dke,xpsin_S_dke,1,'spline',display_mode);%Calculation of the chord length and angle between magnetic field line and line-of-sight
%
	[kphot,brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi,lchord,rho_out,theta_out] = bremsstrahlung_dke_yp(equil,hxr,vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr,XXheaviside,zZi,xzni_norm(:,r_dke),xne_norm(r_dke),ne_ref,betath_ref,xrho(r_dke),dmhu,mhu,dpn_ref,pn_ref,pn2_ref,gamma_ref,Ec_ref,dp_cyl,pnmax_S,XXfinit_ref(:,:,r_dke),XXf0_ref(:,:,r_dke),XXf0_tp_ref(:,:,r_dke),XXf0_g_ref(:,:,r_dke),nlevel,bounce_mode,display_mode,xrho(ir_display_dke),theta_display);%Local and line-integrated bremsstrahlung calculation
%
	[kinterp,gkEinterp,kfit,dkfit,brem_bd_plasma,brem_bd_diag,tphot_plasma,afit_plasma,tphot_plasma_exp,afit_plasma_exp,meanabsx] = bremdiag_dke_yp(equil,hxr,kphot,brem_bd_out,display_mode,chord_display);%Convolution with the diagnostic system response function for each chord
%
%  Display results
%
	figure('tag','Plasma bremsstrahlung spectrum'),
	graph1D_jd(kfit,brem_bd_plasma(chord_display,:),0,1,'Photon energy k (keV)','dN_{phot}/dk.dt [keV^{-1}.s^{-1}]',['Non-thermal Bremsstrahlung, chord #',num2str(chord_display)],NaN,'','','-','non','b',2);

%	
	figure('tag','Pulse bremsstrahlung spectrum'),
	graph1D_jd(kfit,brem_bd_diag(chord_display,:),0,1,'Pulse energy channel E (keV)','dN_{pulse}/dE.dt [keV^{-1}.s^{-1}]',['HXR diagnostic count rate, chord #',num2str(chord_display)],NaN,'','','-','non','b',2);
	
%	
	ikphot_display = max(find(kfit <= kphot_display));
%
	figure('tag','Plasma bremsstrahlung profile'),
	graph1D_jd([1:length(tphot_plasma)],brem_bd_plasma(:,ikphot_display),0,0,'Chord number','dN_{phot}/dk.dt [keV^{-1}.s^{-1}]',['HXR diagnostic count rate, k=',num2str(kfit(ikphot_display)),' (keV)'],NaN,'','','-','non','b',2);

%	
	figure('tag',''Pulse bremsstrahlung profile'),
	graph1D_jd([1:length(tphot_plasma)],brem_bd_diag(:,ikphot_display),0,0,'Chord number','dN_{pulse}/dE.dt [keV^{-1}.s^{-1}]',['HXR diagnostic count rate, E=',num2str(kfit(ikphot_display)),' (keV)'],NaN,'','','-','non','b',2);
%
	figure('tag','Plasma photon temperature'),
	graph1D_jd([1:length(tphot_plasma)],tphot_plasma,0,0,'Chord number','T_{phot} [keV]','k.dN_{phot}/dk.dt = A.exp(-k/T_{phot}) [50-110 keV]',NaN,'','','-','non','b',2);
%	
	figure('tag','Measured photon temperature'),
	graph1D_jd([1:length(tphot_plasma)],tphot_plasma_exp,0,0,'Chord number','T_{phot}^{*} [keV]','E.dN_{pulse}/dE.dt.{\eta}_{E} = A.exp(-E/T_{phot}^{*}) [50-110 keV]',NaN,'','','-','non','r',2);
%
%	figure(10015),
%	graph1D_jd([1:length(tphot_plasma)],afit_plasma,0,0,'Chord number','A(k=0) [s^{-1}]','k.dN_{phot}/dk.dt = A.exp(-k/T_{phot})@k=0 [50-110 keV]',NaN,'','','-','non','b',2);
%
%	figure(10016),
%	graph1D_jd([1:length(tphot_plasma)],afit_plasma_exp,0,0,'Chord number','A^{*}(E=0) [s^{-1}]','E.dN_{pulse}/dE.dt.{\eta}_{E} = A.exp(-E/T_{phot}^{*})@E=0 [50-110 keV]',NaN,'','','-','non','r',2);
%
	figure('tag','Mean HXR absorption efficiency'),
	graph1D_jd(kfit,meanabsx,0,0,'Photon energy channel (keV)','{\eta}_{E}','Mean stopping efficiency {\eta}_{E}',NaN,'','','-','non','r',2);
%
	figure('tag','Detector HXR response'),
	ikinterp_display = max(find(kinterp <= kphot_display));
	graph1D_jd(kinterp,gkEinterp(ikinterp_display,:),0,0,'Photon energy k','G_{kE}',['Detector response function @k=',num2str(kinterp(ikinterp_display)),' (keV), chord#',int2str(chord_display)],NaN,'','','-','non','r',2);
	faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
	text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['Norm. = ',num2str(trapz(kinterp,gkEinterp(ikinterp_display,:)))]);
	
%
%*********************************** Saving results ***************************************
%
	filename = ['HXR_',tokname,'_S',int2str(snumber),'.mat'];
	if diary_mode == 1,%Automatic data saving when diary mode is called
		filename = ['HXR_',tokname,'_S',int2str(snumber),'.mat'];		
		snumber=snumber+1;
		del = 1;
	else,%Manual data saving
		while 1,
			if exist(filename) == 2 & auto_mode == 0,%Only in manual mode
				del = input_dke_yp(['File ',filename,' already exists ! Do you want to overwrite it (yes:1, no:0)'],0);
				if del == 1,
					break;
				else
					snumber = input_dke_yp('New simulation number',snumber+1);
					filename = ['HXR_',tokname,'_S',int2str(snumber),'.mat'];	
				end
			else
				del = 1;
				break;
			end
		end
	end
	%
	if del == 1	,
		delete(filename);
		save(filename);
		if exist(filename) == 2,
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,['The HXR data file : ',filename,' has been successfully saved !']);
		else
			info_dke_yp(2,['The HXR data file : ',filename,' has not been saved, an unknown error occurs on the disk !']);	
		end
	end

end
