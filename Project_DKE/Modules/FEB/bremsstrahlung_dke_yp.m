function  [brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi,rho_out,theta_out] = bremsstrahlung_dke_yp(tokamak,HXR,vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr,XXheaviside,zZi,xzni_norm,xne_norm,ne_ref,xrho,dmhu,mhu,dpn,pn,pn2,gamma,Ec,dp_cyl,pnmax_S,XXf0,XXf0_tp,XXf0_g,nlevel,bounce_mode,display_mode,r_display,t_display)
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
    
%%%%%%[brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi,rho_out,theta_out] = bremsstrahlung_dke_yp('TS',HXR,vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr,XXheaviside,zZi,xzni_norm,xne_norm,ne_ref,xrho,dmhu,mhu,dpn_ref,pn_ref,pn2_ref,gamma_ref,Ec_ref,dp_cyl,pnmax_S,XXf0_ref,XXf0_tp_ref,XXf0_g_ref,nlevel,bounce_mode,2,0.7,120)   
% 
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
method = 'spline';
n_gauleg = 35;
n_pol = n_gauleg;%Necessary for accurate reconstruction at ksi = -1
epsi_gauleg = 1e-14;
kphot = [20:10:160];%Photon energy in keV
%   
ZZIB = zeros(size(psin_hxr,1),size(psin_hxr,2),n_pol+1,length(kphot)) + NaN;%Legendre coefficients for the bremsstrahlung at all radii at poloidal positions (NaN if not used)
norm0_hxr = zeros(size(psin_hxr,1),size(psin_hxr,2)) + NaN;%Norm of the initial distribution function (NaN if not used)
normi_hxr = zeros(size(psin_hxr,1),size(psin_hxr,2)) + NaN;%Norm of the reconstructed distribution function (NaN if not used)
%
i_test = max(find(xrho <= r_display));%Normalized radius index for output and display
j_test = max(find(theta_hxr(1,:) <= t_display*pi/180));%Poloidal angle index for output and display
rho_out = xrho(i_test);
theta_out = theta_hxr(1,j_test);
%
% Legendre polynomials and related coefficients
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
	for j = 1:size(psin_hxr,2),%poloidal position
%
		if mask_hxr(i,j),%A chord is going through the elementary plasma volume. So the distribution function is calculated
			mhu_hxr = sign(mhu(:)).*sqrt(1-PSI_hxr(i,j)*(1 - mhu(:).^2));%mhu at a poloidal position that is different from Bmin
			mhu_hxr = mhu_hxr(1-PSI_hxr(i,j)*(1 - mhu(:).^2) > 0);
			Xf0_hxr = XXf0(:,1-PSI_hxr(i,j)*(1 - mhu(:).^2) > 0,i);%Distribution function at poloidal location
			Xf0_tp_hxr = XXf0_tp(:,1-PSI_hxr(i,j)*(1 - mhu(:).^2) > 0,i);
			Xf0_g_hxr = XXf0_g(:,1-PSI_hxr(i,j)*(1 - mhu(:).^2) > 0,i);
%
			Xf0_i = interp1(mhu_hxr(:),Xf0_hxr',x_leg(:),method)';
			Xf0_tp_i = interp1(mhu_hxr(:),Xf0_tp_hxr',x_leg(:),method)';
			Xf0_g_i = interp1(mhu_hxr(:),Xf0_g_hxr',x_leg(:),method)';
%
			Xf0_c = (Xf0_i.*(w_leg*ones(1,size(Xf0_i,1)))')*Pm';
		   Xf0_tp_c = (Xf0_tp_i.*(w_leg*ones(1,size(Xf0_tp_i,1)))')*Pm';
		   Xf0_g_c = (Xf0_g_i.*(w_leg*ones(1,size(Xf0_g_i,1)))')*Pm';
%
			Xf0_c1 = permute(repmat(reshape(Xf0_c',n_gauleg+1,size(XXf0,1),1),[1,1,1,length(kphot)]),[1,2,4,3]);
			Xf0_tp_c1 = permute(repmat(reshape(Xf0_tp_c',n_gauleg+1,size(XXf0_tp,1),1),[1,1,1,length(kphot)]),[1,2,4,3]);
			Xf0_g_c1 = permute(repmat(reshape(Xf0_g_c',n_gauleg+1,size(XXf0_g,1),1),[1,1,1,length(kphot)]),[1,2,4,3]);
			dIB_c1 = 2*pi*pn_c1.*pn_c1.*pn_c1.*BREM_c1(:,:,:,i).*(Xf0_c1 + Xf0_tp_c1 + Xf0_g_c1)./gamma_c1;
			IB_c1 = 2*pi*integral_dke_jd(dpn,dIB_c1,2);%Momentum integration
			ZZIB(i,j,:,:) = reshape(IB_c1,n_gauleg+1,size(IB_c1,2)*size(IB_c1,3))*ne_ref^2/mc2;%Units(s-1*m-3*kev-1*str-1)
%
			Xf0_i1 = (Pm'*(Xf0_c.*(ones(size(Xf0_i,1),1)*cL'))')';
			epsif0 = (Xf0_i-Xf0_i1)./Xf0_i;epsif0(isnan(epsif0)==1)=0;
			norm0_hxr(i,j) = 2*pi*integral_dke_jd(dpn',pn2'.*trapz_dke_yp([mhu_hxr,Xf0_hxr'])',1);
			normi_hxr(i,j) = 2*pi*integral_dke_jd(dpn',pn2'.*trapz_dke_yp([x_leg,Xf0_i'])',1);
%			
			info_dke_yp(2,['Bremsstrahlung integral #',int2str((i-1)*size(psin_hxr,2) + j),'/',int2str(size(psin_hxr,1)*size(psin_hxr,2)),' done']);
%
			if i_test == i & j_test == j,
%
% Test of the reconstruction of the distribution function on the Legendre polynomail basis
%
				figure,semilogy(pn,Xf0_i1(:,1),'r+',pn,Xf0_i(:,1),'b',pn,Xf0_i1(:,size(Xf0_i1,2)),'cx',pn,Xf0_i(:,size(Xf0_i,2)),'k')
				grid on
				zoom on
				title(['Distribution function at rho = ',num2str(rho_out),' and theta = ',num2str(theta_out*180/pi),' (Deg)'])
				xlabel('p/pth-ref')
				ylabel(['f(norm initial: ',num2str(norm0_hxr(i_test,j_test)),', norm recontructed: ',num2str(normi_hxr(i_test,j_test)),')'])
				legend('Forward reconstructed (Legendre)','Forward initial','Backward reconstructed (Legendre)','Backward initial')
%
% Contour plot of the electron distribution function
%
				[logXf0_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(XXf0(:,:,i_test) + XXf0_tp(:,:,i_test) + XXf0_g(:,:,i_test)),pn,mhu,dp_cyl);
				Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
				Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
				Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
%
				Xf0_cyl = exp(logXf0_cyl);%For accurate representation in figures 
				Xf0_cyl = Xf0_cyl.*(Xf0_cyl>0);%Remove negative values
				Xf0_cyl = Xf0_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
				Xf0_cyl(isnan(Xf0_cyl)) = 0;%Remove NaN values
				Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
				Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
%
				figure,C = contour(ppar_cyl,pperp_cyl,log(Xf0_cyl),[-20:20/nlevel:0]);axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(rho_out),', theta = 0']);
				xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title('');
%
				if bounce_mode >= 1,%Draw bounce domain boundaries
				    mhubounce2_0 = 1 - 1/max(PSI_hxr(i_test,:));
					 line([0,pnmax_S*sqrt(mhubounce2_0)],[0,pnmax_S*sqrt(1 - mhubounce2_0)],'color','k');
					 line([0,-pnmax_S*sqrt(mhubounce2_0)],[0,pnmax_S*sqrt(1 - mhubounce2_0)],'color','k');
			   end				
%
				[logXf_hxr_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(Xf0_hxr),pn,mhu_hxr,dp_cyl);
				Xf_hxr_cyl = exp(logXf_hxr_cyl);%For accurate representation in figures 
				Xf_hxr_cyl = Xf_hxr_cyl.*(Xf_hxr_cyl>0);%Remove negative values
				Xf_hxr_cyl = Xf_hxr_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
				Xf_hxr_cyl(isnan(Xf_hxr_cyl)) = 0;%Remove NaN values
%
				figure,C = contour(ppar_cyl,pperp_cyl,log(Xf_hxr_cyl),[-20:20/nlevel:0]);axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(rho_out),', theta = ',num2str(theta_out*180/pi),' (Deg)']);
				xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title('');
%
				if bounce_mode >= 1,%Draw bounce domain boundaries
				    mhubounce2 = 1 - PSI_hxr(i_test,j_test)/max(PSI_hxr(i_test,:));
					 line([0,pnmax_S*sqrt(mhubounce2)],[0,pnmax_S*sqrt(1 - mhubounce2)],'color','k');
					 line([0,-pnmax_S*sqrt(mhubounce2)],[0,pnmax_S*sqrt(1 - mhubounce2)],'color','k');
				end					
%
% Local bremsstrahlung properties
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
					title(['Bremsstrahlung emission at Bmin and psin = ',num2str(rho_out),' and theta = ',num2str(theta_out*180/pi),' (Deg)']);
				end
			end
		end
	end
end
%
disp('-------------------------------------------------------------------------------------------------------------------');
if display_mode >= 1,%Display the quality of the reconstruction of the electron distribution function
	figure,
	plot(xrho,xne_norm,'g'),hold on,
	legend('Density profile')
	plot(xrho,norm0_hxr,'r+'),
	plot(xrho,normi_hxr,'bx'),
	xlabel('Normalized radius');
	ylabel('Distribution function normalization');
	title('Normalization of the electron distribution function (+: initial,x: reconstructed)');
	hold off
end
%
brem_bd_out = zeros(size(vschords,3),length(kphot));
for ic = 1:size(vschords,3),%loop on each chord  
	s_mask = ~isnan(vschords(7,:,ic));%Location where chord is inside the plasma
   s_length = sum(s_mask);%Number of points along the chord inside the plasma
	ir_spsi = vschords(8,s_mask,ic);
	it_st = vschords(9,s_mask,ic);
%
	IB1 = zeros(size(ZZIB,3),s_length,size(ZZIB,4));
%
	nstep = 300;%In order to avoid use of too large multidimensional tables (limitation of MatLab)
	jmax = floor(s_length/nstep)+1;
	for j = 1:jmax,
		index = [(j-1)*nstep+1:j*nstep];
		index = index(index<=s_length);
		IB = ZZIB(ir_spsi(index),it_st(index),:,:);
      IB1(:,index,:) = permute(squeeze(IB(:,1,:,:)),[2,1,3]);
   end
%
	sksid = vschords(10,s_mask,ic);
	[Pm_bd] = leg_dke_yp(sksid,n_pol);%Legendre polynomial for the cosine of the angle between magnetic field line and line of sight
	Pm_bd1 = repmat(Pm_bd,[1,1,length(kphot)]);
%	
	cL1 = repmat(cL,[1,length(ir_spsi),length(kphot)]);
%
	brem_bd = squeeze(sum(Pm_bd1.*IB1.*cL1,1));%Local bremsstrahlung emission in the direction of the detector
%	
	s = vschords(1,s_mask,ic);
   s = s - s(1);%s=0 where the chord enter the plasma towards the detector
   s1 = repmat(s',[1,length(kphot)]);
%
	brem_bd_out(ic,:) = sum(s1.*brem_bd,1);%Integration along the chord
%
	info_dke_yp(2,['Line integration for chord #',int2str(ic),'/',int2str(size(vschords,3)),' done']);
end	
