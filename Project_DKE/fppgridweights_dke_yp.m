function 	 [Xdeltap_imj,Xdeltap_ipj,...
              Xdeltam_ijm,Xdeltam_ijp] = ...
				  fppgridweights_dke_yp(Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
				  Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
				  XDpp_ippj,XDpp_ipj,XDpp_ij,XDpp_imj,XDpp_immj,...
				  XFp_ippj,XFp_ipj,XFp_ij,XFp_imj,XFp_immj);
%
%Extended Chang & Cooper weights: link between full grid (flux mesh) and half grid (distribution mesh) in the momentum direction
%Linear weighting in pitch-angle direction
%
%	- Xdeltap: Extended Chang & Cooper coefficients for momentum grid that are reused for fluxes calculations at the end of the code
%	- Xdeltam: Extended Chang & Cooper coefficients for pitch-angle grid that are reused for fluxes calculations at the end of the code
%	  (Notations: _imjp -> (i,j+1);_imjm -> (i,j);_ijp -> (i+1/2,j+1);_ijm -> (i+1/2,j);_immjp -> (i-1/2,j+1);_immjm -> (i-1/2,j)
%
%	Input:
%
%	Output:
%
%  - Xdeltap_imj
%  - Xdeltap_ipj
%  - Xdeltam_ijm
%  - Xdeltam_ijp
%
%By Joan Decker (MIT-RLE) and Yves Peysson (CEA-DRFC,yves.peysson@cea.fr)
%	
if nargin < 20,
	error('Wrong number of input arguments in fppgridweights_dke_yp')
end
%Momentum grid interpolation			  
Xdeltap_ipj = g_dke_yp(-Xdpnp.*XFp_ipj./XDpp_ipj,-(Xdpnpp - Xdpn).*(XFp_ippj./XDpp_ippj - XFp_ij./XDpp_ij)/4); 		
Xdeltap_imj = g_dke_yp(-Xdpnm.*XFp_imj./XDpp_imj,-(Xdpn - Xdpnmm).*(XFp_ij./XDpp_ij - XFp_immj./XDpp_immj)/4);	
%Test if the interpolation is valid
testp = isempty(find(abs(Xdeltap_ipj)>1));
testm = isempty(find(abs(Xdeltap_imj)>1));
if (testp+testm ~= 2),error('Interpolation coefficient on momentum flux grid larger than 1 ! Adjust snp and np_S_ref parameters');end
%Pitch-angle grid interpolation
Xdeltam_ijp = Xdmhupp./(Xdmhu + Xdmhupp);
Xdeltam_ijm = Xdmhu./(Xdmhu + Xdmhumm);
