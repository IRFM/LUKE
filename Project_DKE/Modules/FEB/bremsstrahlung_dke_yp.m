function  [brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi] = bremsstrahlung_dke_yp(tokamak,HXR,vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr,XXheaviside,zZi,xzni_norm,xne_norm,ne_ref,xrho,dmhu,mhu,dpn,pn,pn2,gamma,Ec,XXf0,XXf0_tp,XXf0_g,display_mode,ir)
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
    
%%%%%%[brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi] = bremsstrahlung_dke_yp('TS',HXR,vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr,XXheaviside,zZi,xzni_norm,xne_norm,ne_ref,xrho,dmhu,mhu,dpn_ref,pn_ref,pn2_ref,gamma_ref,Ec_ref,XXf0_ref,XXf0_tp_ref,XXf0_g_ref,2,3)   
% 
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
method = 'spline';
n_gauleg = 35;
n_pol = n_gauleg;%Necessary for accurate reconstruction at ksi = -1
epsi_gauleg = 1e-14;
kphot = [20:10:160];%Photon energy in keV
%   
[x_leg,w_leg] = gauleg_dke_yp(n_gauleg,epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
[Pm,cL] = leg_dke_yp(x_leg(:)',n_pol);%Legendre polynomial calculation
%
%Bremsstrahlung cross-section calculations
%
for i = 1:length(zZi),
	seBHE(:,:,:,i) = bhe_dke_yp(Ec,kphot,x_leg,zZi(i));%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert)
end
seHC = haug_dke_yp(Ec,kphot,x_leg);%Electron-electron bremsstrahlung (Haug-Coulomb)
%
%Gauss-Legendre projection for the bremsstrahlung cross-sections
%
seBHE_c=(reshape(seBHE,n_gauleg,size(seBHE,2)*size(seBHE,3)*size(seBHE,4))'.*(w_leg*ones(1,size(seBHE,2)*size(seBHE,3)*size(seBHE,4)))')*Pm';
seHC_c=(reshape(seHC,n_gauleg,size(seBHE,2)*size(seBHE,3))'.*(w_leg*ones(1,size(seHC,2)*size(seHC,3)))')*Pm';
%
%For test only, remove comments
%seBHE1 = reshape((Pm'*(seBHE_c.*(ones(size(seBHE,2)*size(seBHE,3)*size(seBHE,4),1)*cL'))'),size(seBHE,1),size(seBHE,2),size(seBHE,3),size(seBHE,4));
%seHC1 = reshape((Pm'*(seHC_c.*(ones(size(seHC,2)*size(seHC,3),1)*cL'))'),size(seHC,1),size(seHC,2),size(seHC,3));
%epsiBHE = (seBHE-seBHE1)./seBHE;epsiBHE(isnan(epsiBHE)==1)=0;
%epsiHC = (seHC-seHC1)./seHC;epsiHC(isnan(epsiHC)==1)=0;
%
%Interpolation of the distribution functions on the Gauss-Legendre pitch-angle grid 
%
%
ZZIB = zeros(size(psin_hxr,1),size(psin_hxr,2),n_pol+1,length(kphot));%Legendre coefficients for the bremsstrahlung at all radii at poloidal positions
%
i_test = 5;%For test only
j_test = 30;
%
%
%
seBHE_c1 = repmat(reshape(seBHE_c',n_gauleg+1,size(seBHE,2),size(seBHE,3),size(seBHE,4)),[1,1,1,1,size(XXf0,3)]);
ni_c1 = shiftdim(repmat(xzni_norm,[1,1,n_gauleg+1,size(seBHE,2),size(seBHE,3)]),2);
BHE_c1 = permute(sum(seBHE_c1.*ni_c1,4),[1,2,3,5,4]);%Sum over different species
%
seHC_c1 = repmat(reshape(seHC_c',n_gauleg+1,size(seBHE,2),size(seBHE,3)),[1,1,1,size(XXf0,3)]);
ne_c1 = shiftdim(repmat(xne_norm',[1,n_gauleg+1,size(seBHE,2),size(seBHE,3)]),1);
HC_c1 = seHC_c1.*ne_c1;
%
BREM_c1 = BHE_c1 + HC_c1;
%
pn_c1 = permute(repmat(pn(:),[1,n_gauleg+1,length(kphot),1]),[2,1,3,4]);
gamma_c1 = permute(repmat(gamma(:),[1,n_gauleg+1,length(kphot),1]),[2,1,3,4]);
%
for i = 1:size(psin_hxr,1),%radial position
	for j = 1:size(psin_hxr,2),%Poloidal position
%for i = 5,%radial position
%	for j = 30,%Poloidal position

		if mask_hxr(i,j),%A chord is going through the elementary plasma volume. So the distribution function is calculated
			mhu_hxr = sign(mhu(:)).*sqrt(1-PSI_hxr(i,j)*(1 - mhu(:).^2));%mhu at a poloidal position that is different from Bmin
			mhu_hxr = mhu_hxr(imag(mhu_hxr) == 0);
			Xf0_hxr = interp1(mhu(:),XXf0(:,:,i)',mhu_hxr,method)';%Distribution function at poloidal location
%		 Xf0_tp_hxr = interp1(mhu(:),XXf0_tp(:,:,i)',mhu_hxr,method)';
%		 Xf0_g_hxr = interp1(mhu(:),XXf0_g(:,:,i)',mhu_hxr,method)';
%
			Xf0_i = interp1(mhu_hxr(:),Xf0_hxr',x_leg(:),method)';
%		 Xf0_tp_i = interp1(mhu_hxr(:),Xf0_tp_hxr',x_leg(:),method)';
%		 Xf0_g_i = interp1(mhu_hxr(:),Xf0_g_hxr',x_leg(:),method)';
%
			Xf0_c = (Xf0_i.*(w_leg*ones(1,size(Xf0_i,1)))')*Pm';
%		 ZZf0_tp_c(i,j,:,:) = (Xf0_tp_i.*(w_leg*ones(1,size(Xf0_tp_i,1)))')*Pm';
%		 ZZf0_g_c(i,j,:,:) = (Xf0_g_i.*(w_leg*ones(1,size(Xf0_g_i,1)))')*Pm';
%
			Xf0_c1 = permute(repmat(reshape(Xf0_c',n_gauleg+1,size(XXf0,1),1),[1,1,1,length(kphot)]),[1,2,4,3]);
			dIB_c1 = 2*pi*pn_c1.*pn_c1.*pn_c1.*BREM_c1(:,:,:,i).*(Xf0_c1)./gamma_c1;
%			dIB_c1 = 2*pi*pn_c1.*pn_c1.*pn_c1.*BREM_c1.*(Xf0_c1 + Xf0_tp_c1 + Xf0_g_c1)./gamma_c1;
			IB_c1 = 2*pi*integral_dke_jd(dpn,dIB_c1,2);%Momentum integration
			ZZIB(i,j,:,:) = reshape(IB_c1,n_gauleg+1,size(IB_c1,2)*size(IB_c1,3))*ne_ref^2/mc2;%Units(s-1*m-3*kev-1*str-1)
%
			
			info_dke_yp(2,['Iteration ',int2str((i-1)*size(psin_hxr,2) + j),'/',int2str(size(psin_hxr,1)*size(psin_hxr,2)),' done']);
%
			if i_test == i & j_test == j,
%
% Test of the reconstruction of the distribution function on the Legendre polynomail basis
%
				Xf0_i1 = (Pm'*(Xf0_c.*(ones(size(Xf0_i,1),1)*cL'))')';
				epsif0 = (Xf0_i-Xf0_i1)./Xf0_i;epsif0(isnan(epsif0)==1)=0;
				norm0_hxr = 2*pi*integral_dke_jd(dpn',pn2'.*trapz_dke_yp([mhu_hxr,Xf0_hxr'])',1)
				normi_hxr = 2*pi*integral_dke_jd(dpn',pn2'.*trapz_dke_yp([x_leg,Xf0_i'])',1) 
%
				figure,semilogy(pn,Xf0_i1(:,1),'r+',pn,Xf0_i(:,1),'b',pn,Xf0_i1(:,size(Xf0_i1,2)),'cx',pn,Xf0_i(:,size(Xf0_i,2)),'k')
				grid on
				zoom on
				title(['Distribution function at rho = ',num2str(xrho(i)),' and theta = ',num2str(theta_hxr(i,j)*180/pi),' (Deg)'])
				xlabel('p/pth-ref')
				ylabel(['f(norm initial: ',num2str(norm0_hxr),', norm recontructed: ',num2str(normi_hxr),')'])
				legend('Forward reconstructed (Legendre)','Forward initial','Backward reconstructed (Legendre)','Backward initial')
%
% Local bremsstrahlung properties
%
%
				x_forward = 1;%Forward emission
				[Pm_forward] = leg_dke_yp(x_forward(:)',n_pol);%Legendre polynomial for the forward emission
				x_backward = -1;%Backward emission
				[Pm_backward] = leg_dke_yp(x_backward(:)',n_pol);%Legendre polynomial for the backward emission
				x_perp = 0;%Perpendicular emission
				[Pm_perp] = leg_dke_yp(x_perp(:)',n_pol);%Legendre polynomial for the perpendicular emission
%
				brem_forward = permute(reshape(Pm_forward'*(squeeze(ZZIB(i,j,:,:))'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))',1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Forward emission
				brem_backward = permute(reshape(Pm_backward'*(squeeze(ZZIB(i,j,:,:))'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))',1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Backward emission
				brem_perp = permute(reshape(Pm_perp'*(squeeze(ZZIB(i,j,:,:))'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))',1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Perpendicular emission
				brem_4pi = permute(reshape(squeeze(ZZIB(i,j,1,:))/2,1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Mean 4pi emission per steradian
%
				if display_mode >= 1,
					figure
					stairs(kphot-gradient(kphot)/2,log10(brem_forward),'r'),hold on
					stairs(kphot-gradient(kphot)/2,log10(brem_backward),'b')
					stairs(kphot-gradient(kphot)/2,log10(brem_4pi),'g')
					stairs(kphot-gradient(kphot)/2,log10(brem_perp),'c'),hold off
					legend('Forward','Backward','Mean 4*pi','Perp')
					grid on
					xlabel('Photon energy (keV)');
					ylabel('log10(nphot) (s-1*m-3*keV-1*str-1)');
					title(['Bremsstrahlung emission at Bmin and psin = ',num2str(xrho(i)),' and theta = ',num2str(theta_hxr(i,j)*180/pi),' (Deg)']);
				end
			end
		end
	end
end
%
dbstop 152
for ic = 1:nchords,




end	

x_bd = zeros(size(xne_norm(:)'));%Cosine of the angle between magnetic field line and line of sight 
[Pm_bd] = leg_dke_yp(x_bd(:)',n_pol);%Legendre polynomial for the cosine of the angle between magnetic field line and line of sight
brem_bd = Pm_bd'*(IB_c2'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))';%Forward emission
brem_bd_out = permute(reshape(brem_bd,length(x_bd),size(IB_c1,2),size(IB_c1,3)),[2,3,1]);
