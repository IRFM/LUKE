function  [brem] = bremsstrahlung_dke_yp(XXheaviside,zZi,xzni_norm,xne_norm,mhu,dpn,pn,pn2,gamma,Ec,XXf0,XXf0_tp,XXf0_g,display)
%
% Calculates the bremsstrahlung emission 
%
%   INPUTS:
%
%
%   OUTPUTS:
%   
%      - brem :  photon density per unit energy and solid angle [nr,nk]
%      
% by Joan Decker <jodecker@mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
    
%%%%%%[brem] = bremsstrahlung_dke_yp(XXheaviside,zZi,xzni_norm,xne_norm,mhu,dpn_ref,pn_ref,pn2_ref,gamma_ref,Ec_ref,XXf0_ref,XXf0_tp_ref,XXf0_g_ref,display)   
%    
n_gauleg = 50;%At least equivalent
n_pol = 50;
epsi_gauleg = 1e-14;
kphot = [20:10:160];%Photon energy in keV
xbd = pi/2*ones(size(xne_norm));%Angular tilt of the magnetic field line (to be calculated correctly)
%   
[x,w] = gauleg_dke_yp(n_gauleg,epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
[Pm,cL] = leg_dke_yp(x(:)',n_pol);%Legendre polynomial calculation
[Pm_bd] = leg_dke_yp(xbd(:)',n_pol);%Legendre polynomial of the cosine between the magnetic field line direction and the direction of observation
%
%Interpolation of the distribution functions on the Gauss-Legendre pitch-angle grid 
%
XXf0_i = permute(reshape(interp1(mhu(:),reshape(permute(XXf0,[2,1,3]),size(XXf0,2),size(XXf0,1)*size(XXf0,3)),x),n_gauleg,size(XXf0,1),size(XXf0,3)),[2,1,3]);
XXf0_tp_i = permute(reshape(interp1(mhu(:),reshape(permute(XXf0_tp,[2,1,3]),size(XXf0_tp,2),size(XXf0_tp,1)*size(XXf0_tp,3)),x),n_gauleg,size(XXf0_tp,1),size(XXf0_tp,3)),[2,1,3]);
XXf0_g_i = permute(reshape(interp1(mhu(:),reshape(permute(XXf0_g,[2,1,3]),size(XXf0_g,2),size(XXf0_g,1)*size(XXf0_g,3)),x),n_gauleg,size(XXf0_g,1),size(XXf0_g,3)),[2,1,3]);
%
XXf0_i(isnan(XXf0_i)) = 0;
XXf0_tp_i(isnan(XXf0_tp_i)) = 0;
XXf0_g_i(isnan(XXf0_g_i)) = 0;
%
%Gauss-Legendre projection for the distributions
%
XXf0_c = permute(reshape(Pm*reshape(permute(XXf0_i,[2,1,3]),n_gauleg,size(XXf0_i,1)*size(XXf0_i,3)),n_pol+1,size(XXf0_i,1),size(XXf0_i,3)),[2,1,3]);
XXf0_tp_c = permute(reshape(Pm*reshape(permute(XXf0_tp_i,[2,1,3]),n_gauleg,size(XXf0_tp_i,1)*size(XXf0_tp_i,3)),n_pol+1,size(XXf0_tp_i,1),size(XXf0_tp_i,3)),[2,1,3]);
XXf0_g_c = permute(reshape(Pm*reshape(permute(XXf0_g_i,[2,1,3]),n_gauleg,size(XXf0_g_i,1)*size(XXf0_g_i,3)),n_pol+1,size(XXf0_g_i,1),size(XXf0_g_i,3)),[2,1,3]);
%
%Gauss-Legendre projection for the trapped/passing condition
%
XXf_c = XXf0_c;
XXf_tp_c = XXf0_tp_c;
XXf_g_c = XXf0_g_c;
%
%Bremsstrahlung cross-section calculations
%
seBHE = zeros(n_gauleg,length(Ec),length(kphot),length(zZi));
seH = zeros(n_gauleg,length(Ec),length(kphot));
%
for i = 1:length(zZi),
	seBHE(:,:,:,i) = bhe_dke_yp(Ec,kphot,x,zZi(i));%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert)
end
seHC = haug_dke_yp(Ec,kphot,x);%Electron-electron bremsstrahlung (Haug-Coulomb)
%
%Gauss-Legendre projection for the bremsstrahlung cross-sections
%
seBHE_c = reshape(Pm*reshape(seBHE,n_gauleg,size(seBHE,2)*size(seBHE,3)*size(seBHE,4)),n_pol+1,size(seBHE,2),size(seBHE,3),size(seBHE,4));
seHC_c = reshape(Pm*reshape(seHC,n_gauleg,size(seHC,2)*size(seHC,3)),n_pol+1,size(seHC,2),size(seHC,3));
%
BHE_c = reshape(xzni_norm'*reshape(shiftdim(seBHE_c,3),length(zZi),size(seBHE_c,1)*size(seBHE_c,2)*size(seBHE_c,3)),size(xzni_norm,2),size(seBHE_c,1),size(seBHE_c,2),size(seBHE_c,3));
HC_c = reshape(xne_norm(:)*reshape(shiftdim(seHC_c,2),1,size(seHC_c,1)*size(seHC_c,2)*size(seHC_c,3)),length(xne_norm),size(seHC_c,1),size(seHC_c,2),size(seHC_c,3));
%
pn_c = permute(repmat(pn(:),[1,n_pol+1,length(xne_norm),length(kphot)]),[3,2,1,4]);
gamma_c = permute(repmat(gamma(:),[1,n_pol+1,length(xne_norm),length(kphot)]),[3,2,1,4]);
%
dIB_c = repmat(permute(XXf_c + XXf_tp_c + XXf_g_c,[3,2,1]),[1,1,1,length(kphot)]).*(BHE_c + HC_c);
IB_c = 2*pi*integral_dke_jd(dpn,dIB_c.*pn_c.^3./gamma_c,3);
%
brem = reshape(sum((cL*ones(1,length(xne_norm)*length(kphot))).*reshape(permute(repmat(permute(Pm_bd,[2,1,3]),[1,1,length(kphot)]).*IB_c,[2,1,3]),n_pol+1,length(xne_norm)*length(kphot))),length(xne_norm),length(kphot));

