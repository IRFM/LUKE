function  [brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi] = bremsstrahlung_dke_yp(tokamak,HXR,vschords,xpsin,xpsin_S,XXheaviside,zZi,xzni_norm,xne_norm,ne_ref,xrho,dmhu,mhu,dpn,pn,pn2,gamma,Ec,XXf0,XXf0_tp,XXf0_g,display_mode,ir)
%
% Calculates the bremsstrahlung emission. Call first the function bremchord_dke_yp.m for calculating "vschords" used in line integration
%
%   INPUTS:
%
%
%   OUTPUTS:
%   
%      - brem_bd_out : photon density per unit energy and solid angle [ntilt,nr,nk]
%      - brem_forward : photon density per unit energy and solid angle forward emission with respect to the electron direction [nr,nk]
%      - brem_backward : photon density per unit energy and solid angle backward emission with respect to the electron direction [nr,nk]
%      - brem_perp : photon density per unit energy and solid angle perpendicular emission with respect to the electron direction [nr,nk]
%      - brem_4pibrem :  photon density per unit energy and solid angle mean 4*pi emission [nr,nk]
%      
% by Joan Decker <jodecker@mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
    
%%%%%%[brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi] = bremsstrahlung_dke_yp('TS',HXR,vschords,xpsin_dke,xpsin_S_dke,XXheaviside,zZi,xzni_norm,xne_norm,ne_ref,xrho,dmhu,mhu,dpn_ref,pn_ref,pn2_ref,gamma_ref,Ec_ref,XXf0_ref,XXf0_tp_ref,XXf0_g_ref,display_mode,ir_display_dke)   
% 
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
n_gauleg = 35;
n_pol = n_gauleg;%Necessary for accurate reconstruction at ksi = -1
epsi_gauleg = 1e-14;
kphot = [20:10:160];%Photon energy in keV
%   
[x,w] = gauleg_dke_yp(n_gauleg,epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
[Pm,cL] = leg_dke_yp(x(:)',n_pol);%Legendre polynomial calculation
%
%Bremsstrahlung cross-section calculations
%
for i = 1:length(zZi),
	seBHE(:,:,:,i) = bhe_dke_yp(Ec,kphot,x,zZi(i));%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert)
end
seHC = haug_dke_yp(Ec,kphot,x);%Electron-electron bremsstrahlung (Haug-Coulomb)
%
%Gauss-Legendre projection for the bremsstrahlung cross-sections
%
seBHE_c=(reshape(seBHE,n_gauleg,size(seBHE,2)*size(seBHE,3)*size(seBHE,4))'.*(w*ones(1,size(seBHE,2)*size(seBHE,3)*size(seBHE,4)))')*Pm';
seHC_c=(reshape(seHC,n_gauleg,size(seBHE,2)*size(seBHE,3))'.*(w*ones(1,size(seHC,2)*size(seHC,3)))')*Pm';
%
%For test only, remove comments
%seBHE1 = reshape((Pm'*(seBHE_c.*(ones(size(seBHE,2)*size(seBHE,3)*size(seBHE,4),1)*cL'))'),size(seBHE,1),size(seBHE,2),size(seBHE,3),size(seBHE,4));
%seHC1 = reshape((Pm'*(seHC_c.*(ones(size(seHC,2)*size(seHC,3),1)*cL'))'),size(seHC,1),size(seHC,2),size(seHC,3));
%epsiBHE = (seBHE-seBHE1)./seBHE;epsiBHE(isnan(epsiBHE)==1)=0;
%epsiHC = (seHC-seHC1)./seHC;epsiHC(isnan(epsiHC)==1)=0;
%
%Interpolation of the distribution functions on the Gauss-Legendre pitch-angle grid 
%
XXf0_i = reshape(interp1(mhu(:),reshape(permute(XXf0,[2,1,3]),size(XXf0,2),size(XXf0,1)*size(XXf0,3)),x,'spline'),n_gauleg,size(XXf0,1),size(XXf0,3));
XXf0_tp_i = reshape(interp1(mhu(:),reshape(permute(XXf0_tp,[2,1,3]),size(XXf0_tp,2),size(XXf0_tp,1)*size(XXf0_tp,3)),x,'spline'),n_gauleg,size(XXf0_tp,1),size(XXf0_tp,3));
XXf0_g_i = reshape(interp1(mhu(:),reshape(permute(XXf0_g,[2,1,3]),size(XXf0_g,2),size(XXf0_g,1)*size(XXf0_g,3)),x,'spline'),n_gauleg,size(XXf0_g,1),size(XXf0_g,3));
%
%Gauss-Legendre projection for the distributions
%
XXf0_c = (reshape(XXf0_i,n_gauleg,size(XXf0_i,2)*size(XXf0_i,3))'.*(w*ones(1,size(XXf0_i,2)*size(XXf0_i,3)))')*Pm';
XXf0_tp_c = (reshape(XXf0_tp_i,n_gauleg,size(XXf0_tp_i,2)*size(XXf0_tp_i,3))'.*(w*ones(1,size(XXf0_tp_i,2)*size(XXf0_tp_i,3)))')*Pm';
XXf0_g_c = (reshape(XXf0_g_i,n_gauleg,size(XXf0_g_i,2)*size(XXf0_g_i,3))'.*(w*ones(1,size(XXf0_g_i,2)*size(XXf0_g_i,3)))')*Pm';
%For test only, remove comments
%XXf0_i1 = reshape((Pm'*(XXf0_c.*(ones(size(XXf0_i,2)*size(XXf0_i,3),1)*cL'))'),size(XXf0_i,1),size(XXf0_i,2),size(XXf0_i,3));
%epsif0 = (XXf0_i-XXf0_i1)./XXf0_i;epsif0(isnan(epsif0)==1)=0;
%semilogy(pn,XXf0_i1(1,:,1),'r+',pn,XXf0_i(1,:,1),'b',pn,XXf0_i1(size(XXf0_i1,1),:,1),'rx',pn,XXf0_i(size(XXf0_i,1),:,1),'b')
%2*pi*integral_dke_jd(dpn',pn2'.*integral_dke_jd(dmhu,XXf0,2),1)
%2*pi*integral_dke_jd(dpn',pn2'.*trapz_dke_yp([mhu',XXf0'])',1)
%2*pi*integral_dke_jd(dpn',pn2'.*trapz_dke_yp([x,XXf0_i])',1) 
%
%Gauss-Legendre projection for the trapped/passing condition
%
XXf_c = XXf0_c;
XXf_tp_c = XXf0_tp_c;
XXf_g_c = XXf0_g_c;
%
%Local bremsstrahlung calculation
%
seBHE_c1 = repmat(reshape(seBHE_c',n_gauleg+1,size(seBHE,2),size(seBHE,3),size(seBHE,4)),[1,1,1,1,size(XXf0,3)]);
ni_c1 = shiftdim(repmat(xzni_norm,[1,1,n_gauleg+1,size(seBHE,2),size(seBHE,3)]),2);
BHE_c1 = permute(sum(seBHE_c1.*ni_c1,4),[1,2,3,5,4]);%Sum over different species
%
seHC_c1 = repmat(reshape(seHC_c',n_gauleg+1,size(seBHE,2),size(seBHE,3)),[1,1,1,size(XXf0,3)]);
ne_c1 = shiftdim(repmat(xne_norm',[1,n_gauleg+1,size(seBHE,2),size(seBHE,3)]),1);
dbstop 81
HC_c1 = seHC_c1.*ne_c1;
%
BREM_c1 = BHE_c1 + HC_c1;
%
pn_c1 = permute(repmat(pn(:),[1,n_gauleg+1,length(kphot),size(XXf0,3)]),[2,1,3,4]);
gamma_c1 = permute(repmat(gamma(:),[1,n_gauleg+1,length(kphot),size(XXf0,3)]),[2,1,3,4]);
%
XXf0_c1 = permute(repmat(reshape(XXf0_c',n_gauleg+1,size(XXf0,1),size(XXf0,3)),[1,1,1,length(kphot)]),[1,2,4,3]);
XXf0_tp_c1 = permute(repmat(reshape(XXf0_tp_c',n_gauleg+1,size(XXf0_tp,1),size(XXf0_tp,3)),[1,1,1,length(kphot)]),[1,2,4,3]);
XXf0_g_c1 = permute(repmat(reshape(XXf0_g_c',n_gauleg+1,size(XXf0_g,1),size(XXf0_g,3)),[1,1,1,length(kphot)]),[1,2,4,3]);
%
dIB_c1 = 2*pi*pn_c1.*pn_c1.*pn_c1.*BREM_c1.*(XXf0_c1 + XXf0_tp_c1 + XXf0_g_c1)./gamma_c1;
IB_c1 = 2*pi*integral_dke_jd(dpn,dIB_c1,2);%Momentum integration
IB_c2 = reshape(IB_c1,n_gauleg+1,size(IB_c1,2)*size(IB_c1,3))*ne_ref^2/mc2;%Units(s-1*m-3*kev-1*str-1)
%
x_forward = 1;%Forward emission
[Pm_forward] = leg_dke_yp(x_forward(:)',n_pol);%Legendre polynomial for the forward emission
x_backward = -1;%Backward emission
[Pm_backward] = leg_dke_yp(x_backward(:)',n_pol);%Legendre polynomial for the backward emission
x_perp = 0;%Perpendicular emission
[Pm_perp] = leg_dke_yp(x_perp(:)',n_pol);%Legendre polynomial for the perpendicular emission
%
brem_forward = permute(reshape(Pm_forward'*(IB_c2'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))',1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Forward emission
brem_backward = permute(reshape(Pm_backward'*(IB_c2'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))',1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Backward emission
brem_perp = permute(reshape(Pm_perp'*(IB_c2'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))',1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Perpendicular emission
brem_4pi = permute(reshape(IB_c2(1,:)/2,1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Mean 4pi emission per steradian
%
if display_mode >= 1,
	stairs(kphot-gradient(kphot)/2,log10(brem_forward(:,ir)),'r'),hold on
	stairs(kphot-gradient(kphot)/2,log10(brem_backward(:,ir)),'b')
	stairs(kphot-gradient(kphot)/2,log10(brem_4pi(:,ir)),'g')
	stairs(kphot-gradient(kphot)/2,log10(brem_perp(:,ir)),'c'),hold off
	legend('Forward','Backward','Mean 4*pi','Perp')
	grid on
	xlabel('Photon energy (keV)');
	ylabel('log10(nphot) (s-1*m-3*keV-1*str-1)');
	title(['Bremsstrahlung emission at psin = ',num2str(xrho(ir))]);
end
%
dbstop 124
x_bd = zeros(size(xne_norm(:)'));%Cosine of the angle between magnetic field line and line of sight 
[Pm_bd] = leg_dke_yp(x_bd(:)',n_pol);%Legendre polynomial for the cosine of the angle between magnetic field line and line of sight
brem_bd = Pm_bd'*(IB_c2'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))';%Forward emission
brem_bd_out = permute(reshape(brem_bd,length(x_bd),size(IB_c1,2),size(IB_c1,3)),[2,3,1]);
