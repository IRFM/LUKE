function 	 [Xdeltap_imj,Xdeltap_ipj,...
              Xdeltam_ijm,Xdeltam_ijp,...
              Xdeltap_imjmm,Xdeltap_imjpp,Xdeltap_ipjmm,Xdeltap_ipjpp,...
              Xdeltam_immjm,Xdeltam_ippjm,Xdeltam_immjp,Xdeltam_ippjp,...
              xdeltap_npj,xdeltap_npjmm,xdeltap_npjpp] = ...
				  fppgridweights_dke_yp(Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
				  Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
				  XDpp_ipj,XDpp_imj,XFp_ipj,XFp_imj,...
                  XDpp_ij,XFp_ij);
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
if nargin < 16,
	error('Wrong number of input arguments in fppgridweights_dke_yp')
end
%
[np,nmhu] = size(Xdpnmm);
%
%Momentum grid interpolation
%
Xdeltap_ipj = g_dke_yp(-Xdpnp.*XFp_ipj./XDpp_ipj); 		
Xdeltap_imj = g_dke_yp(-Xdpnm.*XFp_imj./XDpp_imj);	
%
Xdeltap_imjmm = zeros(np,nmhu);Xdeltap_imjmm(:,2:nmhu) = Xdeltap_imj(:,1:nmhu-1);
Xdeltap_imjmm(:,1) = Xdeltap_imj(:,1);%Symmetry around the pperp = 0 axis
Xdeltap_imjpp = zeros(np,nmhu);Xdeltap_imjpp(:,1:nmhu-1) = Xdeltap_imj(:,2:nmhu);
Xdeltap_imjpp(:,nmhu) = Xdeltap_imj(:,nmhu);%Symmetry around the pperp = 0 axis
%
Xdeltap_ipjmm = zeros(np,nmhu);Xdeltap_ipjmm(:,2:nmhu) = Xdeltap_ipj(:,1:nmhu-1);
Xdeltap_ipjmm(:,1) = Xdeltap_ipj(:,1);%Symmetry around the pperp = 0 axis
Xdeltap_ipjpp = zeros(np,nmhu);Xdeltap_ipjpp(:,1:nmhu-1) = Xdeltap_ipj(:,2:nmhu);
Xdeltap_ipjpp(:,nmhu) = Xdeltap_ipj(:,nmhu);%Symmetry around the pperp = 0 axis
%
%Momentum grid interpolation in p=pmax
%
xdeltap_npj = g_dke_yp(-(Xdpnm(np,:) + Xdpnp(np,:)).*XFp_ij(np,:)./XDpp_ij(np,:)); 	
xdeltap_npjmm = zeros(1,nmhu);xdeltap_npjmm(2:nmhu) = xdeltap_npj(1:nmhu-1);
xdeltap_npjmm(1) = xdeltap_npj(1);%Symmetry around the pperp = 0 axis
xdeltap_npjpp = zeros(1,nmhu);xdeltap_npjpp(1:nmhu-1) = xdeltap_npj(2:nmhu);
xdeltap_npjpp(nmhu) = xdeltap_npj(nmhu);%Symmetry around the pperp = 0 axis
%
%Pitch-angle grid interpolation
%
Xdeltam_ijp = Xdmhupp./(Xdmhu + Xdmhupp);
Xdeltam_ijm = Xdmhu./(Xdmhu + Xdmhumm);
%
Xdeltam_immjm = zeros(np,nmhu);Xdeltam_immjm(2:np,:) = Xdeltam_ijm(1:np-1,:);
Xdeltam_immjm(1,:) = Xdeltam_ijm(1,:);%Symmetry p -> -p at p =0
Xdeltam_ippjm = zeros(np,nmhu);Xdeltam_ippjm(1:np-1,:) = Xdeltam_ijm(2:np,:);
Xdeltam_ippjm(np,:) = Xdeltam_ijm(np,:);%Symmetry p -> -p at p =0
%
Xdeltam_immjp = zeros(np,nmhu);Xdeltam_immjp(2:np,:) = Xdeltam_ijp(1:np-1,:);
Xdeltam_immjp(1,:) = Xdeltam_ijp(1,:);%Symmetry p -> -p at p =0
Xdeltam_ippjp = zeros(np,nmhu);Xdeltam_ippjp(1:np-1,:) = Xdeltam_ijp(2:np,:);
Xdeltam_ippjp(np,:) = Xdeltam_ijp(np,:);%Symmetry p -> -p at p =0
%