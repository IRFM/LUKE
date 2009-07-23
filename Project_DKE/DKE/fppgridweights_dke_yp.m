function [Zdelta] = fppgridweights_dke_yp(gridDKE,Zcoeffs)           
%LUKE - Interpolation coefficients for calculating values of the distribution function on the flux grid
%
%Interpolation coefficients for calculating values of the distribution function on the flux grid:
% 1) Xdeltar: Linear weighting in radial direction (psi)
% 2) Xdeltap: Generalized Chang & Cooper weights in momentum direction (p)
% 3) Xdeltam: Linear weighting in pitch-angle direction (mhu)
%
% Notation of indexes, k = {l:radial, p: momentum, j: pitch-angle}
% WARNING: km (LUKE) -> k (Publications), k (LUKE) -> k+ or k+1/2 (Publications), kp (LUKE) -> k++ or k+1 (Publications)
%
% Xdeltar coefficients
%
%   _lmippj    -> (l,i+3/2,j+1/2) or (l,i+++,j+)              (LUKE 2)
%   _lmimmj    -> (l,i-1/2,j+1/2) or (l,i-,j+)                (LUKE 2)
%   _lmijpp    -> (l,i+1/2,j+3/2) or (l,i+,j+++)              (LUKE 2)
%   _lmijmm    -> (l,i+1/2,j-1/2) or (l,i+,j-)                (LUKE 2)
%   _lmij      -> (l,i+1/2,j+1/2) or (l,i+,j+)                (LUKE 2)
%
%   _lpippj    -> (l+1,i+3/2,j+1/2) or (l++,i+++,j+)          (LUKE 2)
%   _lpimmj    -> (l+1,i-1/2,j+1/2) or (l++,i-,j+)            (LUKE 2)
%   _lpijpp    -> (l+1,i+1/2,j+3/2) or (l++,i+,j+++)          (LUKE 2)
%   _lpijmm    -> (l+1,i+1/2,j-1/2) or (l++,i+,j-)            (LUKE 2)
%   _lpij      -> (l+1,i+1/2,j+1/2) or (l++,i+,j+)            (LUKE 2)
%
% Xdeltap coefficients
%
%   _lppimj    -> (l+3/2,i,j+1/2) or (l+++,i,j+)              (LUKE 2)
%   _lmmimj    -> (l-1/2,i,j+1/2) or (l-,i,j+)                (LUKE 2)
%   _limjpp    -> (l+1/2,i,j+3/2) or (l+,i,j+++)              (LUKE 1+2)
%   _limjmm    -> (l+1/2,i,j-1/2) or (l+,i,j-)                (LUKE 1+2)
%   _limj      -> (l+1/2,i,j+1/2) or (l+,i,j+)                (LUKE 1+2)
%
%   _lppipj    -> (l+3/2,i+1,j+1/2) or (l+++,i++,j+)          (LUKE 2)
%   _lmmipj    -> (l-1/2,i+1,j+1/2) or (l-,i++,j+)            (LUKE 2)
%   _lipjpp    -> (l+1/2,i+1,j+3/2) or (l+,i++,j+++)          (LUKE 1+2)
%   _lipjmm    -> (l+1/2,i+1,j-1/2) or (l+,i++,j-)            (LUKE 1+2)
%   _lipj      -> (l+1/2,i+1,j+1/2) or (l+,i++,j+)            (LUKE 1+2)
%
% Xdeltam coefficients
%
%   _lppijm    -> (l+3/2,i+1/2,j) or (l+++,i+,j)              (LUKE 2)
%   _lmmijm    -> (l-1/2,i+1/2,j) or (l-,i+,j)                (LUKE 2)
%   _lippjm    -> (l+1/2,i+3/2,j) or (l+,i+++,j)              (LUKE 1+2)
%   _limmjm    -> (l+1/2,i-1/2,j) or (l+,i-,j)                (LUKE 1+2)
%   _lijm      -> (l+1/2,i+1/2,j) or (l+,i+,j)                (LUKE 1+2)
%
%   _lppijp    -> (l+3/2,i+1/2,j+1) or (l+++,i+,j++)          (LUKE 2)
%   _lmmijp    -> (l-1/2,i+1/2,j+1) or (l-,i+,j++)            (LUKE 2)
%   _lippjp    -> (l+1/2,i+3/2,j+1) or (l+,i+++,j++)          (LUKE 1+2)
%   _limmjp    -> (l+1/2,i-1/2,j+1) or (l+,i-,j++)            (LUKE 1+2)
%   _lijp      -> (l+1/2,i+1/2,j+1) or (l+,i+,j++)            (LUKE 1+2)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr)
%	
if nargin < 2,
	error('Wrong number of input arguments in fppgridweights_dke_yp')
end
%
[np,nmhu,nr] = size(gridDKE.XXdpnmm);
%
% Radial grid interpolation
%
Zdelta.XXdeltar_lmij = gridDKE.XXdpsin_dke./(gridDKE.XXdpsinmm_dke + gridDKE.XXdpsin_dke);
Zdelta.XXdeltar_lpij = gridDKE.XXdpsinpp_dke./(gridDKE.XXdpsinpp_dke + gridDKE.XXdpsin_dke);
%
Zdelta.XXdeltar_lmippj = Zdelta.XXdeltar_lmij;
Zdelta.XXdeltar_lmimmj = Zdelta.XXdeltar_lmij;
Zdelta.XXdeltar_lmijpp = Zdelta.XXdeltar_lmij;
Zdelta.XXdeltar_lmijmm = Zdelta.XXdeltar_lmij;
%
Zdelta.XXdeltar_lpippj = Zdelta.XXdeltar_lpij;
Zdelta.XXdeltar_lpimmj = Zdelta.XXdeltar_lpij;
Zdelta.XXdeltar_lpijpp = Zdelta.XXdeltar_lpij;
Zdelta.XXdeltar_lpijmm = Zdelta.XXdeltar_lpij;
%
%Momentum grid interpolation
%
Zdelta.XXdeltap_limj = g_dke_yp(-gridDKE.XXdpnm.*Zcoeffs.XXFp_imj./Zcoeffs.XXDpp_imj);	
Zdelta.XXdeltap_lipj = g_dke_yp(-gridDKE.XXdpnp.*Zcoeffs.XXFp_ipj./Zcoeffs.XXDpp_ipj); 		
%
Zdelta.XXdeltap_lppimj = zeros(np,nmhu,nr);Zdelta.XXdeltap_lppimj(:,:,1:nr-1) = Zdelta.XXdeltap_limj(:,:,2:nr);
Zdelta.XXdeltap_lppimj(:,:,nr) = Zdelta.XXdeltap_limj(:,:,nr);%Symmetry around psi = 0
Zdelta.XXdeltap_lmmimj = zeros(np,nmhu,nr);Zdelta.XXdeltap_lppimj(:,:,2:nr) = Zdelta.XXdeltap_limj(:,:,1:nr-1);
Zdelta.XXdeltap_lmmimj(:,:,1) = Zdelta.XXdeltap_limj(:,:,1);%Symmetry around psi = 0
Zdelta.XXdeltap_limjpp = zeros(np,nmhu,nr);Zdelta.XXdeltap_imjpp(:,1:nmhu-1,:) = Zdelta.XXdeltap_limj(:,2:nmhu,:);
Zdelta.XXdeltap_limjpp(:,nmhu,:) = Zdelta.XXdeltap_limj(:,nmhu,:);%Symmetry around the pperp = 0 axis
Zdelta.XXdeltap_limjmm = zeros(np,nmhu,nr);Zdelta.XXdeltap_imjmm(:,2:nmhu,:) = Zdelta.XXdeltap_limj(:,1:nmhu-1,:);
Zdelta.XXdeltap_limjmm(:,1,:) = Zdelta.XXdeltap_limj(:,1,:);%Symmetry around the pperp = 0 axis
%
Zdelta.XXdeltap_lppipj = zeros(np,nmhu,nr);XXdeltap_lppipj(:,:,1:nr-1) = Zdelta.XXdeltap_lipj(:,:,2:nr);
Zdelta.XXdeltap_lppipj(:,:,nr) = Zdelta.XXdeltap_lipj(:,:,nr);%Symmetry around psi = 0
Zdelta.XXdeltap_lmmipj = zeros(np,nmhu,nr);XXdeltap_lppipj(:,:,2:nr) = Zdelta.XXdeltap_lipj(:,:,1:nr-1);
Zdelta.XXdeltap_lmmipj(:,:,1) = Zdelta.XXdeltap_lipj(:,:,1);%Symmetry around psi = 0
Zdelta.XXdeltap_lipjpp = zeros(np,nmhu,nr);Zdelta.XXdeltap_ipjpp(:,1:nmhu-1,:) = Zdelta.XXdeltap_lipj(:,2:nmhu,:);
Zdelta.XXdeltap_lipjpp(:,nmhu,:) = Zdelta.XXdeltap_lipj(:,nmhu,:);%Symmetry around the pperp = 0 axis
Zdelta.XXdeltap_lipjmm = zeros(np,nmhu,nr);Zdelta.XXdeltap_ipjmm(:,2:nmhu,:) = Zdelta.XXdeltap_lipj(:,1:nmhu-1,:);
Zdelta.XXdeltap_lipjmm(:,1,:) = Zdelta.XXdeltap_lipj(:,1,:);%Symmetry around the pperp = 0 axis
%
% Pitch-angle grid interpolation
%
Zdelta.XXdeltam_lijm = gridDKE.XXdmhu./(gridDKE.XXdmhu + gridDKE.XXdmhumm);
Zdelta.XXdeltam_lijp = gridDKE.XXdmhupp./(gridDKE.XXdmhu + gridDKE.XXdmhupp);
%
Zdelta.XXdeltam_lppijm = Zdelta.XXdeltam_lijm;
Zdelta.XXdeltam_lmmijm = Zdelta.XXdeltam_lijm;
Zdelta.XXdeltam_lippjm = zeros(np,nmhu,nr);Zdelta.XXdeltam_lippjm(1:np-1,:,:) = Zdelta.XXdeltam_lijm(2:np,:,:);
Zdelta.XXdeltam_lippjm(np,:,:) = Zdelta.XXdeltam_lijm(np,:,:);%Symmetry p -> -p at p =0
Zdelta.XXdeltam_limmjm = zeros(np,nmhu,nr);Zdelta.XXdeltam_limmjm(2:np,:,:) = Zdelta.XXdeltam_lijm(1:np-1,:,:);
Zdelta.XXdeltam_limmjm(1,:,:) = Zdelta.XXdeltam_lijm(1,:,:);%Symmetry p -> -p at p =0
%
Zdelta.XXdeltam_lppijp = Zdelta.XXdeltam_lijp;
Zdelta.XXdeltam_lmmijp = Zdelta.XXdeltam_lijp;
Zdelta.XXdeltam_lippjp = zeros(np,nmhu,nr);Zdelta.XXdeltam_lippjp(1:np-1,:,:) = Zdelta.XXdeltam_lijp(2:np,:,:);
Zdelta.XXdeltam_lippjp(np,:,:) = Zdelta.XXdeltam_lijp(np,:,:);%Symmetry p -> -p at p =0
Zdelta.XXdeltam_limmjp = zeros(np,nmhu,nr);Zdelta.XXdeltam_limmjp(2:np,:) = Zdelta.XXdeltam_lijp(1:np-1,:);
Zdelta.XXdeltam_limmjp(1,:,:) = Zdelta.XXdeltam_lijp(1,:,:);%Symmetry p -> -p at p =0




