function  [kphot,brem_diag,tphot_in,tphot_out] = bremdiag_dke_yp(tokamak,HXR,kphot,brem_bd_out,kphotmin,kphotmax,display_mode,c_display)
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
% by Joan Decker <jodecker@mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
    
%%%%%% [kphot,brem_diag,tphot_in,tphot_out ] = bremdiag_dke_yp('TS',HXR,kphot,brem_bd_out,50,110,2,1);
%
dbstop 19
method = 'cubic';
kfit = linspace(kphotmin,kphotmax,100);
brem_bd_fit = interp1(kphot,brem_bd_out',kfit,method)';
%
wbrem_bd_fit = brem_bd_fit.*repmat(kfit,[size(brem_bd_fit,1),1]);
for ic = 1:size(brem_bd_fit,1),
	pfit = polyfit(kfit,log(wbrem_bd_fit(ic,:)),1);
	tphot_in(ic) = -1/pfit(1);
	Ifit_in(ic) = exp(pfit(2));
end
