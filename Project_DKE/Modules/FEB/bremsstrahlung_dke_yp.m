function  [kphot,brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi,lchord,rho_out,theta_out] = bremsstrahlung_dke_yp(equil,hxr,vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr,XXheaviside,zZi,xzni_norm,xne_norm,ne_ref,betath_ref,xrho,dmhu,mhu,dpn,pn,pn2,gamma,Ec,dp_cyl,pnmax_S,XXfinit,XXf0,XXf0_tp,XXf0_g,nlevel,bounce_mode,display_mode,r_display,t_display)
%
% Calculates the bremsstrahlung emission. Call first the function bremchord_dke_yp.m for calculating "vschords" used in line integration
%
%   INPUTS:
%
%
%   OUTPUTS:
%   
%      - kphot : photon energies (keV) [1,nk]
%      - brem_bd_out : photon number per unit energy (keV) and time (s) for each chord [nchord,nk]
%      - brem_forward : photon density (m-3) per unit energy (keV), time (s) and solid angle forward emission with respect to the electron direction [nr,nk]
%      - brem_backward : photon density (m-3) per unit energy (keV), time (s) and solid angle backward emission with respect to the electron direction [nr,nk]
%      - brem_perp : photon density (m-3) per unit energy (keV), time (s) and solid angle perpendicular emission with respect to the electron direction [nr,nk]
%      - brem_4pibrem :  mean photon density (m-3) per unit energy, time (s) and solid angle [nr,nk]
%      - lchord : chord length (m) [1,nchord]
%      - rho_out: Normalized minor radius for the display of the electron distribution function [1,1]
%      - theta_out: Poloidal angle for the display of the electron distribution function  [1,1]
%
% by Joan Decker <jodecker@mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
% 
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
method = 'spline';
n_gauleg = hxr.n_gauleg;
n_pol = n_gauleg;%Necessary for accurate reconstruction at ksi = -1
epsi_gauleg = hxr.epsi_gauleg;
kphot = hxr.kphot;
%   
ZZIB = zeros(size(psin_hxr,1),size(psin_hxr,2),n_pol+1,length(kphot));%Legendre coefficients for the bremsstrahlung at all radii at poloidal positions (NaN if not used)
norm0_hxr = zeros(size(psin_hxr,1),size(psin_hxr,2)) + NaN;%Norm of the initial distribution function (NaN if not used)
normi_hxr = zeros(size(psin_hxr,1),size(psin_hxr,2)) + NaN;%Norm of the reconstructed distribution function (NaN if not used)
%
i_test = max(find(xrho <= r_display));%Normalized radius index for output and display
j_test = max(find(theta_hxr(1,:) <= t_display*pi/180));%Poloidal angle index for output and display
%
if ~mask_hxr(i_test,j_test),
	info_dke_yp(2,'WARNING: no chord is going through the plasma volume at the chosen radial and poloidal positions !');
   [i_test1,j_test1]=find(mask_hxr==1);
	disp('Choose one of these index values (i,j) for which one chord crosses the plasma volume')
   for ii=1:length(i_test1),
      disp([int2str(ii),' - (i,j) : ',int2str(i_test1(ii)),'/',int2str(j_test1(ii)),' - (rho,theta[deg.]) : ',num2str(xrho(i_test1(ii))),'/',num2str(180*theta_hxr(1,j_test1(ii))/pi)]);
   end
	ii1 = input_dke_yp(['Give the index (between 1 and ',int2str(max(ii)),')'],1);
	i_test = i_test1(ii1);
	j_test = j_test1(ii1);
end
%
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
	seBHE(:,:,:,i) = bhe_dke_yp(Ec,kphot,x_leg,zZi(i));%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert) (mec2 -> keV units)
end
seHC = haug_dke_yp(Ec,kphot,x_leg);%Electron-electron bremsstrahlung (Haug-Coulomb) (mec2 -> keV units)
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
%%%%%%		PSI_hxr(i,j) = max(PSI_hxr(i,:));%high field side only
%%%%%%		PSI_hxr(i,j) = 1;%low field side only
			mhu_hxr = sign(mhu(:)).*sqrt(1-PSI_hxr(i,j)*(1 - mhu(:).^2));%mhu at a poloidal position that is different from Bmin
			mhu_hxr = mhu_hxr(1-PSI_hxr(i,j)*(1 - mhu(:).^2) > 0);
			Xf0_hxr = XXf0(:,1-PSI_hxr(i,j)*(1 - mhu(:).^2) > 0,i);%Non-thermal distribution function at poloidal location
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
			ZZIB(i,j,:,:) = reshape(IB_c1,n_gauleg+1,size(IB_c1,2)*size(IB_c1,3))*ne_ref^2*betath_ref*clum/mc2;%MKSA units(s-1*m-3*kev-1*str-1)
%
			Xf0_i1 = (Pm'*(Xf0_c.*(ones(size(Xf0_i,1),1)*cL'))')';
			epsif0 = (Xf0_i-Xf0_i1)./Xf0_i;epsif0(isnan(epsif0)==1)=0;
			norm0_hxr(i,j) = 2*pi*integral_dke_jd(dpn',pn2'.*trapz_dke_yp([mhu_hxr,Xf0_hxr'])',1);
			normi_hxr(i,j) = 2*pi*integral_dke_jd(dpn',pn2'.*trapz_dke_yp([x_leg,Xf0_i'])',1);
%			
			if i_test == i & j_test == j,
%
% Test of the reconstruction of the distribution function on the Legendre polynomial basis
%
				figure('tag','Distribution function'),
				ylab = ['f(norm initial: ',num2str(norm0_hxr(i_test,j_test)),', norm recontructed: ',num2str(normi_hxr(i_test,j_test)),')'];
				tit = ['Distribution function at {\rho} = ',num2str(rho_out),' and {\theta}_{pol} = ',num2str(theta_out*180/pi),' (Deg)'];
%				
				graph1D_jd(pn,Xf0_i(:,1),0,1,'','','',NaN,'','','-','non','b',2);
				hold on			
				graph1D_jd(pn,Xf0_i1(:,1),0,1,'','','',NaN,'','','--','non','r',2);
				graph1D_jd(pn,Xf0_i(:,size(Xf0_i1,2)),0,1,'','','',NaN,'','','-','non','c',2);
				graph1D_jd(pn,Xf0_i1(:,size(Xf0_i,2)),0,1,'p_{||}/p_{Te}^{ref}',ylab,tit,NaN,'','','--','non','k',2);
				grid on,zoom on
				legend('Forward initial','Forward reconstructed (Legendre)','Backward initial','Backward reconstructed (Legendre)')
%
% Contour plot of the electron distribution function
%
				[logXfinit_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(XXfinit(:,:,i_test)),pn,mhu,dp_cyl);
				[logXf0_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(XXf0(:,:,i_test) + XXf0_tp(:,:,i_test) + XXf0_g(:,:,i_test)),pn,mhu,dp_cyl);
				[logXf_hxr_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(Xf0_hxr),pn,mhu_hxr,dp_cyl);
%
				Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
				Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
				Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
%
				Xf0_cyl = exp(logXf0_cyl);%For accurate representation in figures 
				Xf0_cyl = Xf0_cyl.*(Xf0_cyl>0);%Remove negative values
				Xf0_cyl = Xf0_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
				Xf0_cyl(isnan(Xf0_cyl)) = 0;%Remove NaN values
				Xfinit_cyl = exp(logXfinit_cyl);%For accurate representation in figures 
				Xfinit_cyl = Xfinit_cyl.*(Xfinit_cyl>0);%Remove negative values
				Xfinit_cyl = Xfinit_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
				Xfinit_cyl(isnan(Xfinit_cyl)) = 0;%Remove NaN values
				Xf_hxr_cyl = exp(logXf_hxr_cyl);%For accurate representation in figures 
				Xf_hxr_cyl = Xf_hxr_cyl.*(Xf_hxr_cyl>0);%Remove negative values
				Xf_hxr_cyl = Xf_hxr_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
				Xf_hxr_cyl(isnan(Xf_hxr_cyl)) = 0;%Remove NaN values

				Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
				Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
%
				xlim1 = [-pnmax_S,pnmax_S];xlim2 = [0,pnmax_S];
				siz = 20;red = 0.95;
%
				figure('tag','Distribution function contour 1')				
				graph2D_jd(ppar_cyl,pperp_cyl,Xfinit_cyl','','','',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','b',0.5,siz,red,max(max(Xf0_cyl)));
				graph2D_jd(ppar_cyl,pperp_cyl,Xf0_cyl','p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','r',2,siz,red,max(max(Xfinit_cyl)));
				axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['{\rho} = ',num2str(rho_out),', {\theta}_{pol} = 0']);
%
				if bounce_mode >= 1,%Draw bounce domain boundaries
				    mhubounce2_0 = 1 - 1/max(PSI_hxr(i_test,:));
					 line([0,pnmax_S*sqrt(mhubounce2_0)],[0,pnmax_S*sqrt(1 - mhubounce2_0)],'color','k');
					 line([0,-pnmax_S*sqrt(mhubounce2_0)],[0,pnmax_S*sqrt(1 - mhubounce2_0)],'color','k');
			   end				
%
				figure('tag','Distribution function contour 2'),
				graph2D_jd(ppar_cyl,pperp_cyl,Xfinit_cyl','','','',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','b',0.5,siz,red,max(max(Xf_hxr_cyl)));
				graph2D_jd(ppar_cyl,pperp_cyl,Xf_hxr_cyl','p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','r',2,siz,red,max(max(Xfinit_cyl)));
				axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['{\rho} = ',num2str(rho_out),', {\theta}_{pol} = ',num2str(theta_out*180/pi),' (Deg)']);
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
				   figure('tag','Bremshrahlung forward - perp - backward'),
					graph1D_jd(kphot,brem_forward,0,1,'','','',NaN,'','','-','non','r',2);
					graph1D_jd(kphot,brem_backward,0,1,'','','',NaN,'','','-','non','b',2);
					graph1D_jd(kphot,brem_4pi,0,1,'','','',NaN,'','','-.','non','g',2);
					graph1D_jd(kphot,brem_perp,0,1,'Photon energy (keV)','Photon density (s-1*m-3*keV-1*str-1)',['Bremsstrahlung emission at {\rho} = ',num2str(rho_out),' and {\theta}_{pol} = ',num2str(theta_out*180/pi),' (Deg)'],NaN,'','','-','non','k',2);
					legend('Forward','Backward','Mean 4{\pi}','Perp.')
					grid on
				end
			else
				info_dke_yp(2,'WARNING: no chord is going through the plasma volume at the chosen radial and poloidal positions ! Local emission values are not displayed.');		
			   brem_forward = NaN;%Forward emission
			   brem_backward = NaN;%Backward emission
			   brem_perp = NaN;%Perpendicular emission
			   brem_4pi = NaN;%Mean 4pi emission per steradian				
			end
		end
%
		info_dke_yp(2,['Bremsstrahlung integral #',int2str((i-1)*size(psin_hxr,2) + j),'/',int2str(size(psin_hxr,1)*size(psin_hxr,2)),' done']);
	end
end
%
disp('-------------------------------------------------------------------------------------------------------------------');
if display_mode >= 1,%Display the quality of the reconstruction of the electron distribution function
	figure('tag','Distribution normalization'),
	graph1D_jd(xrho,xne_norm,0,0,'','','',NaN,'','','-','non','b',2);
	graph1D_jd(xrho,norm0_hxr,0,0,'','','',NaN,'','','--','non','r',2);
	graph1D_jd(xrho,normi_hxr,0,0,'Normalized radius {\rho}','Normalization (local density)','Normalization of the electron distribution function',NaN,'','','-.','non','g',2);
	legend('Density','Norm f','Norm reconstructed f');
	hold off
end
%
brem_bd_out = zeros(size(vschords,3),length(kphot));
lchord = zeros(size(vschords,3));
for ic = 1:size(vschords,3),%loop on each chord  
	s_mask = ~isnan(vschords(7,:,ic));%Location where chord is inside the plasma
   s_length = sum(s_mask);%Number of points along the chord inside the plasma
	ir_spsi = vschords(8,s_mask,ic);
	it_st = vschords(9,s_mask,ic);
%
	IB1 = zeros(size(ZZIB,3),s_length,size(ZZIB,4));
%
	nstep = 199;%In order to avoid use of too large multidimensional tables (limitation of MatLab)
	jmax = floor(s_length/nstep)+1;
%
	index_test = [(jmax-1)*nstep+1:jmax*nstep];
	index_test = index_test(index_test<=s_length);
	if length(index_test) == 1,%In order to avoid this case which generates an error for the line  "IB1(:,index,:) = permute(squeeze(IB(:,1,:,:)),[2,1,3]);"
	    nstep = nstep - 1;
		 jmax = floor(s_length/nstep)+1;
	end
%	
	for j = 1:jmax,
		index = [(j-1)*nstep+1:j*nstep];
		index = index(index<=s_length);
		if isempty(index) ~= 1
			IB = ZZIB(ir_spsi(index),it_st(index),:,:);
			IB1(:,index,:) = permute(squeeze(IB(:,1,:,:)),[2,1,3]);
		end
   end
%
	sksid = vschords(10,s_mask,ic);%Zero for exact perpendicular observation or +1 forward, -1 backward, nothing when taking the exact magnetic topology
	[Pm_bd] = leg_dke_yp(sksid,n_pol);%Legendre polynomial for the cosine of the angle between magnetic field line and line of sight
	Pm_bd1 = repmat(Pm_bd,[1,1,length(kphot)]);
%	
	cL1 = repmat(cL,[1,length(ir_spsi),length(kphot)]);
%
	brem_bd = squeeze(sum(Pm_bd1.*IB1.*cL1,1));%Local bremsstrahlung emission in the direction of the detector
%	
	s = vschords(1,s_mask,ic);
   if size(s,2) > 0
       s = s - s(1);%s=0 where the chord enter the plasma towards the detector
       ds = [diff(s),0];%Elementary chord length for integration
       ds1 = repmat(ds',[1,length(kphot)]);
%
	    brem_bd_out(ic,:) = sum(ds1.*brem_bd,1)*hxr.EG_hxr(ic);%Integration along the chord and multiplication by the geometrical factor
	    lchord(ic) = sum(ds);%Chord length calculation
	else
		brem_bd_out(ic,:) = 0;%Integration along the chord and multiplication by the geometrical factor
		lchord(ic) = 0;%Chord length calculation	   	
	end
	    %
	info_dke_yp(2,['Line integration for chord #',int2str(ic),'/',int2str(size(vschords,3)),' done']);
end	
