function  [kphot,brem_bd_plasma,brem_bd_diag,tphot_plasma,afit_plasma,tphot_plasma_exp,afit_plasma_exp,meanabsx] = bremdiag_dke_yp(tokamak,HXR,kphot,brem_bd_in,display_mode,c_display)
%
% Calculates the bremsstrahlung emission as merasured by the HXR diagnostic
%taking inot account of the detector's response function. 
%Call first the function bremchord_dke_yp.m for calculating "vschords" used in line integration
%Then call bremsstrahlung_dke_yp.m for calculating "brem_bd_out" used in the convolution
%
%   INPUTS:
%
%
%   OUTPUTS:
%
%
%
%
%      
% by Joan Decker <jodecker@mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
    
%%%%%% [kphot,brem_bd_plasma,brem_bd_diag,tphot_plasma,afit_plasma,tphot_plasma_exp,afit_plasma_exp,meanabsx] = bremdiag_dke_yp('TS',HXR,kphot,brem_bd_out,2,1);
%
method = 'cubic';
%
kphotmin = HXR{17}(1,1);
kphotmax = HXR{17}(2,end-1);
%
kfit = (HXR{17}(1,1:end-1) + HXR{17}(2,1:end-1))/2;%Measured photon energy spectrum (keV) [1,k]
ikfitmin = find(kfit == HXR{17}(1,end));
ikfitmax = find(kfit == HXR{17}(2,end));
kfitmin = kfit(ikfitmin);
kfitmax = kfit(ikfitmax);
dkfit = HXR{17}(2,1:end-1) - HXR{17}(1,1:end-1);%Channel width of the measured photon energy spectrum (keV) [1,k]
%
kinterp = linspace(kphotmin,kphotmax,1000);%Uniform grid only 
dkinterp = kinterp(2) - kinterp(1);
brem_bd_interp = interp1(kphot,brem_bd_in',kinterp,method)';
%
for ik = 1:size(HXR{17},2)-1,
	brem_bd_plasma(:,ik) = sum(brem_bd_interp(:,min(find(kinterp >= HXR{17}(1,ik))):max(find(kinterp < HXR{17}(2,ik))))')'*dkinterp;
end
%
wbrem_bd_plasma = brem_bd_plasma.*repmat(kfit,[size(brem_bd_plasma,1),1])./repmat(dkfit,[size(brem_bd_plasma,1),1]);% per keV but taking into account of the channel energy width
for ic = 1:size(brem_bd_plasma,1),	
	pfit = polyfit(kfit(ikfitmin:ikfitmax),log(wbrem_bd_plasma(ic,ikfitmin:ikfitmax)),1);
	tphot_plasma(ic) = -1/pfit(1);
	afit_plasma(ic) = exp(pfit(2));
end
%
% Convolution with detector response
%
kd = HXR{1,6};%reference energies for the photofraction [m,p]
phf = HXR{1,7};%photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
res = HXR{1,8};%fit parameters of the energy resolution of the detectors [m,2]
ef = HXR{1,9};%thickness of the vacuum window (mm) [1,m]
tf = HXR{1,10};%type of material for the vacuum window (Al ou Be) [1,m]
ea = HXR{1,11};%thickness of the absorber (mm) [1,m]
ta = HXR{1,12};%type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
ec = HXR{1,13};%thickness of the detector shield (mm) [1,m]
tc = HXR{1,14};%type of material for the detector shield (Al ou Be) [1,m]
ed = HXR{1,15};%thickness of the detector (mm) [1,m]
td = HXR{1,16};%type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]
%
meanabsx = zeros(size(wbrem_bd_plasma));%Mean attenuation per channel
brem_bd_diag_interp = zeros(size(brem_bd_interp));
brem_bd_diag = zeros(size(brem_bd_plasma));
%
dbstop 68
for ic = 1:size(brem_bd_interp,1)*0+1,
	if ic == 1,
		gkEinterp = dresp_dke_yp(res(ic,:),phf(ic,:),kd(ic,:),ic,kinterp);
		absxinterp = absx_dke_yp(kinterp,0,0,ef(ic),tf(ic,:),ea(ic),ta(ic,:),ec(ic),tc(ic,:),ed(ic),td(ic,:));%Air contribution is neglected (k > 10 keV only)
		Tabsxinterp = repmat(absxinterp(:),[1,size(brem_bd_interp,2)]);
	else
		if (kd(ic-1) ~= kd(ic)) | (res(ic-1) ~= res(ic)) | (phf(ic-1) ~= phf(ic))
			gkEinterp = dresp_dke_yp(res(ic,:),phf(ic,:),kd(ic,:),ic,kinterp);%Recalculated only when detector type has changed concerning the response function
		end
%
		if (ef(ic-1) ~= ef(ic)) | (tf(ic-1) ~= tf(ic)) | (ea(ic-1) ~= ea(ic)) | (ta(ic-1) ~= ta(ic)) | (ec(ic-1) ~= ec(ic)) | (tc(ic-1) ~= tc(ic)) | (ed(ic-1) ~= ed(ic)) | (td(ic-1) ~= td(ic))
			absxinterp = absx_dke_yp(kinterp,0,0,ef(ic),tf(ic,:),ea(ic),ta(ic,:),ec(ic),tc(ic,:),ed(ic),td(ic,:));%Air contribution is neglected (k > 10 keV only)
			Tabsxinterp = repmat(absxinterp(:),[1,size(brem_bd_interp,2)]);
		end		
	end
%
%	brem_bd_diag_interp(ic,:) = (fix(((gkEinterp'.*Tabsxinterp)*dkinterp*(brem_bd_interp(ic,:))')))'; 
%	brem_bd_diag_interp(ic,:) = (fix(((eye(size(gkEinterp')).*Tabsxinterp)*(brem_bd_interp(ic,:))')))';%detector response neglected
%	
	for ik = 1:size(HXR{17},2)-1,
		meanabsx(ic,ik) = sum(absxinterp(min(find(kinterp >= HXR{17}(1,ik))):max(find(kinterp < HXR{17}(2,ik))))')'/length(absxinterp(min(find(kinterp >= HXR{17}(1,ik))):max(find(kinterp < HXR{17}(2,ik))))');
	end
end
%
for ik = 1:size(HXR{17},2)-1,
	brem_bd_diag(:,ik) = sum(brem_bd_diag_interp(:,min(find(kinterp >= HXR{17}(1,ik))):max(find(kinterp < HXR{17}(2,ik))))')'*dkinterp;
end
%
wbrem_bd_plasma_exp = brem_bd_diag.*repmat(kfit,[size(brem_bd_diag,1),1])./repmat(dkfit,[size(brem_bd_plasma,1),1])./meanabsx;% per keV but taking into account of the channel energy width and mean attenuation per channel
for ic = 1:size(wbrem_bd_plasma_exp,1),	
	pfit = polyfit(kfit(ikfitmin:ikfitmax),log(wbrem_bd_plasma_exp(ic,ikfitmin:ikfitmax)),1);
	tphot_plasma_exp(ic) = -1/pfit(1);
	afit_plasma_exp(ic) = exp(pfit(2));
%	if tphot_plasma_exp(ic) <=0, %Remove negative or null values
%		tphot_plasma_exp(ic) = NaN;
%		afit_plasma_exp(ic) = NaN;
%	end
end
%

