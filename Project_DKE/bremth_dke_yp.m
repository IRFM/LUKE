function [brem_th_out] = bremth_dke_yp(HXR,vschords,xrho,xne_norm,ne_ref,xTe_norm,Te_ref,xZeff_norm,Zeff_ref)
%
%	Calculation of the thermal x-ray contribution: dN(k)/dt.dk.domega (s-1.keV-1.str-1)
%
%	Input:
%
%		- kphot: photon energy (keV) [1,n]
%		- Zeff: effective plasma charge [1,p]
%		- Te: bulk electron temperature [1,p]
%		- ne: bulk electron density [1,p]
%		- ner: fast electron density [1,p]
%
%	Output:
%
%		- SXR: line integrated soft x-ray emission (s-1.keV-1.str-1) [n,m]
%
%
%by Y.PEYSSON CEA-DRFC 11/10/1991 <peysson@fedv09.cad.cea.fr>
%revised for MatLab 4.1 (31/08/1994) 
%
%
%[brem_th_out] = bremth_dke_yp(HXR,vschords,xrho,xne_norm,ne_ref,xTe_norm,Te_ref,xZeff_norm,Zeff_ref)
%
%
if nargin < 0,
	infoyp(2,'Wrong number of input arguments for bremth_dke_yp');
	return;
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
cbremth = 16*sqrt(2*pi*mc2)*alpha*clum*(re^2)/(12*pi*sqrt(3));%Thermal bremsstrahlung constant
%
kphot = [20:10:180];%Photon energy in keV
%
ZZkphot = ones(length(xrho),1)*kphot;
ZZne = xne_norm(:)*ones(1,length(kphot));
ZZTe = xTe_norm(:)*ones(1,length(kphot));
ZZZeff = xZeff_norm(:)*ones(1,length(kphot));
ZZbremth = ne_ref*ne_ref*Zeff_ref*cbremth*ZZZeff.*ZZne.^2.*exp(-ZZkphot./ZZTe/Te_ref)./(ZZkphot.*sqrt(ZZTe*Te_ref));	
%
for ic = 1:size(vschords,3),%loop on each chord  
	s_mask = ~isnan(vschords(7,:,ic));%Location where chord is inside the plasma
	s_length = sum(s_mask);%Number of points along the chord inside the plasma
	ir_spsi = vschords(8,s_mask,ic);
	it_st = vschords(9,s_mask,ic);
%
	brem_bd = ZZbremth(ir_spsi,:);%Local thermal bremsstrahlung emission in the direction of the detector
%	
	s = vschords(1,s_mask,ic);
	s = s - s(1);%s=0 where the chord enter the plasma towards the detector
	s1 = repmat(s',[1,length(kphot)]);
%
	brem_th_out(ic,:) = sum(s1.*brem_bd,1)*HXR{1,5}(ic);%Integration along the chord and multiplication by the geometrical factor
%
	info_dke_yp(2,['Line integration for chord #',int2str(ic),'/',int2str(size(vschords,3)),' done']);
end	







