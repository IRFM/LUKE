function [xJrf0_fsav_mksa,xJboot_e_fsav_mksa,xJboot_i_fsav_mksa,xJtot_fsav_mksa,...
xPabs0_fsav_mksa,xPabs_tot_fsav_mksa,...
xeta0_fsav_mksa,xepsi_fsav_mksa,xia,xft_fsav] = display_dke_1yp(filename,auto_mode_in,igor_mode)
%
% Display results of the Electron Drift Kinetic solver (test_dke_1yp.m)
%
%by Y.Peysson CEA-DRFC 02/08/2003 <yves.peysson@cea.fr>
%
%
if nargin == 0,
	[s,dossier,machine] = comput_dke_yp;
	eval(['dir ',dossier,s,'dke_*.mat']);
	filename = [];
	filename = input_dke_yp('Filename ',filename);
	auto_mode_in = input_dke_yp('Automatic display mode (yes: 1, no: 0) ',0);
	igor_mode = input_dke_yp('Igor software output (yes: 1, no: 0) ',0);%For figure by figure data output (Easy data transfer to Igor software for final output)
elseif nargin == 1,
	auto_mode_in = input_dke_yp('Automatic display mode (yes: 1, no: 0) ',0);
	igor_mode = input_dke_yp('Igor software output (yes: 1, no: 0) ',0);%For figure by figure data output (Easy data transfer to Igor software for final output)
elseif nargin == 2,
	igor_mode = 0;%Automatic mode when test_dke_1yp.m is running
end
%
[s,dossier,machine] = comput_dke_yp;
eval(['load ',dossier,s,filename]);%Load DKE data
%
if nargin >= 2,
	auto_mode = auto_mode_in;
end
%
display_mode = 2,
%
filenameroot = filename(1:findstr(filename,'_out.mat')-1);
%  
disp('-------------------------------------------------------------------------------------------------------------------');
disp('Display results of Drift Kinetic Equation solver (see test_dke_1yp.m)');
disp('-------------------------------------------------------------------------------------------------------------------');
%
[xq,xqtilde,xqbar,xqhat] = qfactors_dke_yp(Rp,Zp,XR(r_dke,:),XZ(r_dke,:),XBR(r_dke,:),XBZ(r_dke,:),XBphi(r_dke,:));%q factors calculations at radial positions at which bootstrap current is calculated are used
%
xnormf_ref = Znorm_ref{1,1};
xnormf_ref_fsav = Znorm_ref_fsav{1,1};
%
xepsi_ref_fsav = xepsi_ref_fsav_in(r_dke);%Only radial positions at which bootstrap current is calculated are used
xrho_dke = xrho(r_dke);%Only radial positions at which bootstrap current is calculated are used
xia = xrho_dke*ap/Rp;%Pseudo inverse aspect ratio (has a meaning only for circular plasma equilibrium)
xft_out = xft_fsav;
%
xRR_KB_fsav = 0.35*abs(xepsi_ref_fsav).^(-3/8).*exp(-(sqrt(2./abs(xepsi_ref_fsav))+1./4./abs(xepsi_ref_fsav)));%Kulsrud fit of the theoretical Kruskal-Bernstein runaway rate (PRL 31,11 (1973) 690)
%
P_ref = me*(clum*betath_ref)^2*nhu_ref*ne_ref/1e6;%MKSA power unit
j_ref = qe*clum*betath_ref*ne_ref/1e6;%MKSA current unit
Edreicer_ref = me*clum*betath_ref*nhu_ref/qe;%MKSA Dreicer field unit

if bounce_mode > 0,
	xcollisionnality = 0.012*(xne/1e20).*xZeff.*xq*Rp./xia.^1.5./xTe.^2;%From O. Sauter et al., Phys. Plasma 6 (1999) 2834
%	[xft_llm] = ft_llm_dke_yp(xia,1000);%From Y.R. Lin-Liu and R.L. Miller, Phys. Plasma 2 (1995) 1666
else
	xcollisionnality = NaN*ones(size(xia));
%	xft_llm = zeros(size(xia));
end
%
%Calculation of the flux averaged Maxwellian bootstrap current from Hirshman, Sauter, Hinton & Hazeltine models (bulk contribution)
%
[prho,pcurr_hir_mksa_fsav,pcurr_sau_mksa_fsav,pcurr_hin_mksa_fsav,pcurr_i_mksa_fsav] = hsneomodels_dke_jd(tokname);
%
xcurr_hir_mksa_fsav = interp1(prho,pcurr_hir_mksa_fsav,xrho_dke);
xcurr_sau_mksa_fsav = interp1(prho,pcurr_sau_mksa_fsav,xrho_dke);
xcurr_hin_mksa_fsav = interp1(prho,pcurr_hin_mksa_fsav,xrho_dke);
xcurr_i_mksa_fsav = interp1(prho,pcurr_i_mksa_fsav,xrho_dke);
%
while 1,
	ir_display_dke = find(r_dke == ir_display);
	if auto_mode_in == 0,
		disp(' ')
		disp('**************************************************************************')
		ir_display_dke = input_dke_yp(['*********************************** Radial index value (1-',int2str(nr_dke),') (exit: <=0)'],ir_display_dke);
		disp('**************************************************************************')
		disp(' ')
		if ir_display_dke < 1,
			break
		end
	end
%
	ir_display = r_dke(ir_display_dke);
%
	if display_mode >=1,
%
		Xf0_ref = XXf0_ref(:,:,ir_display);%Display results at the required radial value
		Xf0_tp_ref = XXf0_tp_ref(:,:,ir_display);%Display results at the required radial value
		Xf0_g_ref = XXf0_g_ref(:,:,ir_display);%Display results at the required radial value
		Xfinit_ref = XXfinit_ref(:,:,ir_display);%Display results at the required radial value
		if nb > 0
			YXDrf_ref = squeeze(YXXDrf_ref(:,:,ir_display,:));%Display results at the required radial value
		end
		[XAstr_ipjp_ref] = stream_dke_jd(ZSp0_ref,XxRR_ref_fsav,dmhu,pnp,ir_display_dke,nb);
%
		disp('-------------------------------------------------------------------------------------------------------------------');
		disp('-------------------------------------------------------------------------------------------------------------------');
		disp('-------------------------------------------- Calculation output ---------------------------------------------------')
		disp('-------------------------------------------------------------------------------------------------------------------');
		info_dke_yp(2,['Reference electron temperature (keV): ',num2str(Ten_ref*mc2)])
		info_dke_yp(2,['Reference electron density (10+19 m-3): ',num2str(ne_ref/1e19)])
		info_dke_yp(2,['Reference Coulomb logarithm: ',num2str(lnc_ref)])
		info_dke_yp(2,['Reference electron collision frequency (kHz): ',num2str(nhu_ref/1000)])
		info_dke_yp(2,['MKSA power unit (P_ref): ',num2str(P_ref),' (MW/m3)'])

		info_dke_yp(2,['MKSA current unit (j_ref): ',num2str(j_ref),' (MA/m2)'])
		info_dke_yp(2,['MKSA Dreicer field unit (Edreicer_ref): ',num2str(Edreicer_ref),' (V/m)'])
%
		disp('-------------------------------------------------------------------------------------------------------------------');
		info_dke_yp(2,['Integration time step: ',num2str(dtn/nhu_ref),' (s)'])
		disp('-------------------------------------------------------------------------------------------------------------------');
		info_dke_yp(2,['Major plasma radius on the LFS midplane (Rp) : ',num2str(Rp)])
		info_dke_yp(2,['Major plasma radius on the LFS midplane (ap) : ',num2str(ap)])
		disp('-------------------------------------------------------------------------------------------------------------------');
		info_dke_yp(2,['Normalized radius on the LFS midplane where results are displayed (rho) : ',num2str(xrho_dke(ir_display_dke))])
		info_dke_yp(2,['Normalized poloidal magnetic flux where results are displayed (psin) : ',num2str(xpsin(ir_display))])
		info_dke_yp(2,['Pseudo inverse aspect ratio (rho*ap/Rp) : ',num2str(xia(ir_display_dke))])
		disp('-------------------------------------------------------------------------------------------------------------------');
		info_dke_yp(2,['Flux-surface averaged electron temperature (keV): ',num2str(xTe(ir_display))])
		info_dke_yp(2,['Flux-surface averaged electron temperature increment (keV): ',num2str((xTe_norm_out(ir_display_dke) - xTe_norm(ir_display))*Ten_ref*mc2)])
		info_dke_yp(2,['Flux-surface averaged electron density (10+19 m-3): ',num2str(xne(ir_display)/1e19)])
%
		disp('-------------------------------------------------------------------------------------------------------------------');
		info_dke_yp(2,['Normalized Coulomb logarithm: ',num2str(xlnc(ir_display)/lnc_ref)])
		info_dke_yp(2,['Normalized electron collision frequency: ',num2str(xnhu(ir_display)/nhu_ref)])
		if bounce_mode > 0,
			info_dke_yp(2,['Exact trapped fraction: ',num2str(xft_fsav(ir_display_dke))])
			info_dke_yp(2,['Collisionality parameter: ',num2str(xcollisionnality(ir_display_dke))])
		end
		disp('-------------------------------------------------------------------------------------------------------------------');
%
%   Magnetic ripple losses
%
if 0,
%    	if bounce_mode >= 1 & isnan(xnhuloss_ref(r_dke(ir_display))) == 0,     
			Gripmhu_ref = 2*pi*integral_dke_yp([dpn_ref',Xmaskrip_ref.*XSmhu0_ref.*Xpn_ref])*sqrt(1-min(mhu(find(abs(mhu)<xmhusupertrap(rdke(ir_display)))))^2);        
			Grippn_ref = 2*pi*pn(max(find(pn_ref<xpndetrap_ref(rdke(ir_display)))))^2*integral_dke_yp([dmhu',Xmaskrip_ref'.*XSp0_ref']);    
			Gripflux_ref = Gripmhu_ref(max(find(abs(mhu)<xmhusupertrap(rdke(ir_display))))) - Gripmhu_ref(min(find(abs(mhu)<xmhusupertrap(rdke(ir_display))))) + Grippn_ref(max(find(pn_ref<xpndetrap_ref(rdke(ir_display))))+1);
        	Griptau0_ref = integral_dke_yp([dpn_ref',Xnhuloss_ref.*Xf0_ref.*Xpn_ref.*Xpn_ref]);
        	Griptau_ref = 2*pi*integral_dke_yp([dmhu',Griptau0_ref']);%Flux of electrons leaving the plasma through the loss cone
        	info_dke_yp(2,['Ripple loss (s-1.m-3): ',num2str(Griptau_ref*nhu_ref*xne(rdke(ir_display)))]);
			info_dke_yp(2,['Ripple loss (flux calculations) (s-1.m-3): ',num2str(Gripflux_ref*nhu_ref*xne(rdke(ir_display)))]);
        	disp('-------------------------------------------------------------------------------------------------------------------');
    	end
%
		[logXfinit_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xfinit_ref),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
		Xfinit_cyl_ref = exp(logXfinit_cyl_ref);%For accurate representation in figures 
		[logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xf0_ref),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
		Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
%
		for ib = 1:nb
			[YXDrf_cyl_ref(:,:,ib),ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(YXDrf_ref(:,:,ib),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
		end
%
		[XAstr_cyl_ref,ppar_cyl_S_ref,dppar_cyl_S_ref,pperp_cyl_S_ref,dpperp_S_cyl_ref] = s2c_dke_yp(XAstr_ipjp_ref,pnp_ref,mhup,dp_cyl);%Spherical to cylindrical coordinate transformation
%
		Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';%Grid for the distribution functions only
		Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
		Xmhu_cyl_ref = Xppar_cyl_ref./sqrt(Xppar_cyl_ref.^2+Xpperp_cyl_ref.^2);
		Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
		Xgamma_cyl_ref = sqrt(1 + Xp_cyl_ref.*Xp_cyl_ref*betath_ref*betath_ref);
		Xvpar_cyl_ref = Xppar_cyl_ref./Xgamma_cyl_ref;
%
		Xppar_cyl_S_ref = ones(length(pperp_cyl_S_ref),1)*ppar_cyl_S_ref(:)';%Grid for the stream or flux functions only
		Xpperp_cyl_S_ref = pperp_cyl_S_ref(:)*ones(1,length(ppar_cyl_S_ref));
		Xmhu_cyl_S_ref = Xppar_cyl_S_ref./sqrt(Xppar_cyl_S_ref.^2+Xpperp_cyl_S_ref.^2);
		Xp_cyl_S_ref = sqrt(Xppar_cyl_S_ref.*Xppar_cyl_S_ref + Xpperp_cyl_S_ref.*Xpperp_cyl_S_ref);
%
		Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
		Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
		Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
		Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xfinit_cyl_ref>0);%Remove negative values
		Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
		Xfinit_cyl_ref(isnan(Xfinit_cyl_ref)) = 0;%Remove NaN values
		if nb > 0
			YXp_cyl_ref = repmat(Xp_cyl_ref,[1,1,nb]);
			YXDrf_cyl_ref = YXDrf_cyl_ref.*(YXDrf_cyl_ref>0);
			YXDrf_cyl_ref = YXDrf_cyl_ref.*(YXp_cyl_ref<max(ppar_cyl_ref));
			YXDrf_cyl_ref = YXDrf_cyl_ref.*(YXDrf_cyl_ref<=max(max(max(YXDrf_ref))));

			YXDrf_cyl_ref(isnan(YXDrf_cyl_ref))=0;
%
			XDlh_cyl_ref = integral_dke_jd(ones(1,nb_lh),YXDrf_cyl_ref(:,:,blist_lh),3);
			XDec_cyl_ref = integral_dke_jd(ones(1,nb_ec),YXDrf_cyl_ref(:,:,blist_ec),3);
		end        
		XAstr_cyl_ref = XAstr_cyl_ref.*(Xp_cyl_S_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
		XAstr_cyl_ref = XAstr_cyl_ref.*(XAstr_cyl_ref>0);%Remove negative values
		XAstr_cyl_ref(isnan(XAstr_cyl_ref)) = 0;%Remove NaN values
%
%Calculations in cylindrical coordinates
%
		xnormf_cyl_ref(ir_display_dke) = 2*pi*integral_dke_jd(dpperp_cyl_ref(:),pperp_cyl_ref(:).*integral_dke_jd(dppar_cyl_ref,Xf0_cyl_ref,2),1);
		xcurr0_cyl_ref(ir_display_dke) = 2*pi*integral_dke_jd(dpperp_cyl_ref(:),pperp_cyl_ref(:).*integral_dke_jd(dppar_cyl_ref,Xvpar_cyl_ref.*Xf0_cyl_ref,2),1);
%
		if display_mode >=2 
			Fpar0_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_cyl_ref,1);
			zFpar0_cyl_ref = find(Fpar0_cyl_ref==0);Fpar0_cyl_ref(zFpar0_cyl_ref) = Fpar0_cyl_ref(zFpar0_cyl_ref)+1e-60;%zero removal		
			Fparinit_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xfinit_cyl_ref,1);		
			zFparinit_cyl_ref = find(Fparinit_cyl_ref==0);Fparinit_cyl_ref(zFparinit_cyl_ref) = Fparinit_cyl_ref(zFparinit_cyl_ref)+1e-60;%zero removal		
			Fparinit3_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xpperp_cyl_ref.*Xpperp_cyl_ref.*Xfinit_cyl_ref,1);
			Fpar3_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xpperp_cyl_ref.*Xpperp_cyl_ref.*Xf0_cyl_ref,1);
			Tperp_cyl_ref = Fpar3_cyl_ref./Fpar0_cyl_ref/2;
			Tperpinit_cyl_ref = Fparinit3_cyl_ref./Fparinit_cyl_ref/2;
			Tperpn_cyl_ref = betath_ref*betath_ref*Tperp_cyl_ref*mc2/Te_ref;
			Tperpinitn_cyl_ref = betath_ref*betath_ref*Tperpinit_cyl_ref*mc2/Te_ref;
%
			Fperp0_cyl_ref = 2*pi*integral_dke_jd(dppar_cyl_ref,Xf0_cyl_ref,2);
			zFperp0_cyl_ref = find(Fperp0_cyl_ref==0);Fperp0_cyl_ref(zFperp0_cyl_ref) = Fperp0_cyl_ref(zFperp0_cyl_ref)+1e-60;%zero removal				
			Fperpinit_cyl_ref = 2*pi*integral_dke_jd(dppar_cyl_ref,Xfinit_cyl_ref,2);
			zFperpinit_cyl_ref = find(Fperpinit_cyl_ref==0);Fperpinit_cyl_ref(zFperpinit_cyl_ref) = Fperpinit_cyl_ref(zFperpinit_cyl_ref)+1e-60;%zero removal				
			Fperp2_cyl_ref = 2*pi*integral_dke_jd(dppar_cyl_ref,Xppar_cyl_ref.*Xppar_cyl_ref.*Xf0_cyl_ref,2);
			Fperpinit2_cyl_ref = 2*pi*integral_dke_jd(dppar_cyl_ref,Xppar_cyl_ref.*Xppar_cyl_ref.*Xfinit_cyl_ref,2);
			Tpar_cyl_ref = Fperp2_cyl_ref./Fperp0_cyl_ref;
			Tparinit_cyl_ref = Fperpinit2_cyl_ref./Fperpinit_cyl_ref;
			Tparn_cyl_ref = betath_ref*betath_ref*Tpar_cyl_ref*mc2/Te_ref;
			Tparinitn_cyl_ref = betath_ref*betath_ref*Tparinit_cyl_ref*mc2/Te_ref;
%
			figure(3);clf
			subplot(131),semilogy(ppar_cyl_ref,Fparinit_cyl_ref,'b--',ppar_cyl_ref,Fpar0_cyl_ref,'r.');grid on;
			axis([-max(pn_ref),max(pn_ref),1e-20,10]);zoom on
			ylabel('F0//');xlabel('ppar/pth-ref');title(['(rho = ',num2str(xrho_dke(ir_display_dke)),')']);
			legend('finit','f0'); 
			subplot(132),plot(ppar_cyl_ref,Tperpinitn_cyl_ref,'b--',ppar_cyl_ref,Tperpn_cyl_ref,'r.');grid on;zoom on
			axis([-max(pn_ref),max(pn_ref),min(Tperpn_cyl_ref),max(Tperpn_cyl_ref)]);zoom on
			ylabel('Tperp/Te-ref');xlabel('ppar/pth-ref');title(['(rho = ',num2str(xrho_dke(ir_display_dke)),')']);
			legend('finit','f0'); 
			subplot(133),plot(pperp_cyl_ref,Tparinitn_cyl_ref,'b--',pperp_cyl_ref,Tparn_cyl_ref,'r.');grid on;zoom on
			axis([0,max(pn_ref),min(Tparn_cyl_ref),max(Tparn_cyl_ref)*1.1]);zoom on
			ylabel('Tpar/Te-ref');xlabel('pperp/pth-ref');title(['(rho = ',num2str(xrho_dke(ir_display_dke)),')']);
			legend('finit','f0'); 
			pause(time_pause);
%
			figure(4);clf
			subplot(121),
			C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xfinit_cyl_ref),[-20:20/nlevel:0]);grid on;zoom on;%Distribution function and wave quasilinear diffusion coefficient contour plot
			axis('equal')
			title('2-D initial electron distribution function finit');
			xlabel('ppar/pth-ref');
			ylabel('pperp/pth-ref');
			if bounce_mode >= 1,%Draw bounce domain boundaries
				line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
				line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
				if isnan(nhuloss) == 0,%Draw the loss cone
					line([0,pnmax_S*sqrt(1-cos(xthetaloss(ir_display)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display)*pi/180)],'LineStyle','-','color','r');
					line([0,-pnmax_S*sqrt(1-cos(xthetaloss(ir_display)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display)*pi/180)],'LineStyle','-','color','r');
				end
			end
%
			faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
			text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
			pause(time_pause);
%
			subplot(122),
			C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xf0_cyl_ref),[-20:20/nlevel:0]);grid on;zoom on;%Distribution function and wave quasilinear diffusion coefficient contour plot
			axis('equal')
			title('2-D steady state 1st order electron distribution function f0');
			xlabel('ppar/pth-ref');
			ylabel('pperp/pth-ref');
			if bounce_mode >= 1,%Draw bounce domain boundaries
				line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
				line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
				if isnan(nhuloss) == 0,%Draw the loss cone
					line([0,pnmax_S*sqrt(1-cos(xthetaloss(ir_display)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display)*pi/180)],'LineStyle','-','color','r');
					line([0,-pnmax_S*sqrt(1-cos(xthetaloss(ir_display)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display)*pi/180)],'LineStyle','-','color','r');
				end
			end
%
			if igor_mode == 1,
				eval(['save ',filenameroot,'_data_fig4_',int2str(ir_display_dke),'.mat xrho_dke xia r_dke ir_display_dke ppar_cyl_ref pperp_cyl_ref Xfinit_cyl_ref Xf0_cyl_ref xmhubounce2 pnmax_S'])
			end
%	
			if nb_lh > 0,
				figure(4),
				if initguess == 1 & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,
					subplot(121)
					if xvparmax_lh_ref(ir_display) - xvparmin_lh_ref(ir_display) ~= 0  & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,,
						pparresmin_lh_cyl_ref = xvparmin_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmin_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
						pparresmax_lh_cyl_ref = xvparmax_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmax_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
						hold on;
						plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
						plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
						hold off;
					end
				end
%
				if xvparmax_lh_ref(ir_display) - xvparmin_lh_ref(ir_display) ~= 0  & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,,
					subplot(122)
					pparresmin_lh_cyl_ref = xvparmin_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmin_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
					pparresmax_lh_cyl_ref = xvparmax_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmax_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
					hold on;
					plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
					plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
					hold off;
				end
%
				if igor_mode == 1,
					eval(['save ',filenameroot,'_data_fig_',int2str(ir_display_dke),'lh.mat xrho_dke xia r_dke ir_display_dke pparresmin_lh_cyl_ref pparresmax_lh_cyl_ref pperp_cyl_ref'])
				end
%
				figure(7);clf
				C = contour(ppar_cyl_ref,pperp_cyl_ref,XDlh_cyl_ref,nlevel);grid on;zoom on;%LH diffusion coefficient
				axis('equal')
				title('Lower Hybrid diffusion coefficient (nhu-ref*pth-ref^2)');
				xlabel('ppar/pth-ref');
				ylabel('pperp/pth-ref');
				if xvparmax_lh_ref(ir_display) - xvparmin_lh_ref(ir_display) ~= 0 & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,,
					hold on,
					pparresmin_lh_cyl_ref = xvparmin_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmin_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
					pparresmax_lh_cyl_ref = xvparmax_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmax_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
					plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
					plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
					hold off,
				end
				if bounce_mode >= 1,%Draw bounce domain boundaries
					line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
					line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
					if isnan(nhuloss) == 0,%Draw the toroidal ripple loss cone
						line([0,pnmax_S*sqrt(1-cos(xthetaloss(ir_display)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display)*pi/180)],'LineStyle','-','color','r');
						line([0,-pnmax_S*sqrt(1-cos(xthetaloss(ir_display)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display)*pi/180)],'LineStyle','-','color','r');
					end
				end
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
				pause(time_pause);
%
				if igor_mode == 1,
					eval(['save ',filenameroot,'_data_fig7_',int2str(ir_display_dke),'.mat xrho_dke xia r_dke ir_display_dke ppar_cyl_ref pperp_cyl_ref XDlh_cyl_ref xmhubounce2 pnmax_S'])
				end
%
			end
%
			if nb_ec > 0,
				figure(8);clf
				C = contour(ppar_cyl_ref,pperp_cyl_ref,XDec_cyl_ref,nlevel);grid on;zoom on;%EC diffusion coefficient
				axis('equal')
				title('Electron cyclotron diffusion coefficient (nhu-ref*pth-ref^2)');
				xlabel('ppar/pth-ref');
				ylabel('pperp/pth-ref');
				if bounce_mode >= 1,%Draw bounce domain boundaries
					line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
					line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
					if isnan(nhuloss) == 0,%Draw the toroidal ripple loss cone
						line([0,pnmax_S*sqrt(1-cos(xthetaloss(ir_display)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display)*pi/180)],'LineStyle','-','color','r');
						line([0,-pnmax_S*sqrt(1-cos(xthetaloss(ir_display)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display)*pi/180)],'LineStyle','-','color','r');
					end
				end
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
				pause(time_pause);
			end
%
			if igor_mode == 1,
				eval(['save ',filenameroot,'_data_fig8_',int2str(ir_display_dke),'.mat xrho_dke xia r_dke ir_display_dke ppar_cyl_ref pperp_cyl_ref xmhubounce2 pnmax_S'])
			end
%
		    figure(5),clf
    		maxXAstr_cyl_ref = max(max(XAstr_cyl_ref));
    		minXAstr_cyl_ref = min(min(XAstr_cyl_ref)) + eps;
    		C = contour(ppar_cyl_S_ref,pperp_cyl_S_ref,XAstr_cyl_ref,minXAstr_cyl_ref*exp(-[0:1:4*nlevel]/(-4*nlevel/log(maxXAstr_cyl_ref/minXAstr_cyl_ref))));colorbar;grid on;zoom on;%Stream function
    		axis('equal')
    		title('Stream Function');
    		xlabel('ppar/pth-ref');
    		ylabel('pperp/pth-ref');
    		if bounce_mode >= 1,%Draw bounce domain boundaries
    			line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
    			line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
    		end
%
    		if nb_lh > 0 & xvparmax_lh_ref(ir_display) - xvparmin_lh_ref(ir_display) ~= 0 & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,
    			pparresmin_lh_cyl_ref = xvparmin_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmin_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
    			pparresmax_lh_cyl_ref = xvparmax_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmax_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
    			hold on;
    			plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
    
    			plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
    			hold off;
		end
		faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
		text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
		pause(time_pause);
%        
		end
%
% Current
%
		xcurr0_ref = Zcurr_ref{1,1};    
		xcurr_tp_ref = Zcurr_ref{1,2};    
		xcurr_g_ref = Zcurr_ref{1,3};  
		xcurr_tot_ref = xcurr0_ref + xcurr_tp_ref + xcurr_g_ref;
		xcurr_boot_ref = xcurr_tot_ref - xcurr0_ref;
%
		xcurr0_ref_fsav = Zcurr_ref_fsav{1,1};    
		xcurr_tp_ref_fsav = Zcurr_ref_fsav{1,2};    
		xcurr_g_ref_fsav = Zcurr_ref_fsav{1,3};  
		xcurrB_ref_fsav = Zcurr_ref_fsav{2,1};%Bulk current in case of run-away electrons leaving the domain of integration
		xcurr_tot_ref_fsav = xcurr0_ref_fsav + xcurr_tp_ref_fsav + xcurr_g_ref_fsav;
		xcurr_boot_ref_fsav = xcurr_tot_ref_fsav - xcurr0_ref_fsav;
%    
		xJrf0_fsav_mksa = xcurr0_ref_fsav*j_ref;
		xJrf_tot_fsav_mksa = xcurr_tot_ref_fsav*j_ref;
		xJrfB_fsav_mksa = xcurrB_ref_fsav*j_ref;
		xJboot_e_fsav_mksa = xcurr_boot_ref_fsav*j_ref;
		xJboot_i_fsav_mksa = xcurr_i_mksa_fsav;
        xJboot_tot_fsav_mksa = xJboot_e_fsav_mksa + xJboot_i_fsav_mksa;
		xJtot_fsav_mksa = xcurr_tot_ref_fsav*j_ref + xJboot_i_fsav_mksa;
%
% Power
%
		xPcoll0_ref_fsav = ZP0_ref_fsav{1,1};
		xPcoll_tp_ref_fsav = ZP0_ref_fsav{1,2};
		xPcoll_g_ref_fsav = ZP0_ref_fsav{1,3};
		xPcoll_tot_ref_fsav = xPcoll0_ref_fsav + xPcoll_tp_ref_fsav + xPcoll_g_ref_fsav;
% 
		xPelec0_ref_fsav = ZP0_ref_fsav{2,1};
		xPelec_tp_ref_fsav = ZP0_ref_fsav{2,2};
		xPelec_g_ref_fsav = ZP0_ref_fsav{2,3};
		xPelec_tot_ref_fsav = xPelec0_ref_fsav + xPelec_tp_ref_fsav + xPelec_g_ref_fsav;
%
		if nb > 0,
			xyPabs0_ref_fsav = ZP0_ref_fsav{3,1};
			xyPabs_tp_ref_fsav = ZP0_ref_fsav{3,2};
			xyPabs_g_ref_fsav = ZP0_ref_fsav{3,3};    
			xyPabs_tot_ref_fsav = xyPabs0_ref_fsav + xyPabs_tp_ref_fsav + xyPabs_g_ref_fsav;
% 
			xyPabs0_lh_ref_fsav = xyPabs0_ref_fsav(:,blist_lh);
			xyPabs0_ec_ref_fsav = xyPabs0_ref_fsav(:,blist_ec);
			xyPabs_tot_lh_ref_fsav = xyPabs_tot_ref_fsav(:,blist_lh);
			xyPabs_tot_ec_ref_fsav = xyPabs_tot_ref_fsav(:,blist_ec);
%
			xPabs0_ref_fsav = integral_dke_jd(ones(1,nb),xyPabs0_ref_fsav,2)';
			xPabs_tot_ref_fsav = integral_dke_jd(ones(1,nb),xyPabs_tot_ref_fsav,2)';
		else
			xyPabs0_lh_ref_fsav = zeros(1,nr_dke);
			xyPabs0_ec_ref_fsav = zeros(1,nr_dke);
			xyPabs_tot_lh_ref_fsav = zeros(1,nr_dke);
			xyPabs_tot_ec_ref_fsav = zeros(1,nr_dke);
%
			xPabs0_ref_fsav = zeros(1,nr_dke);
			xPabs_tot_ref_fsav = zeros(1,nr_dke);
		end      
%
		xPcoll0_fsav_mksa = xPcoll0_ref_fsav*P_ref;
		xPcoll_tot_fsav_mksa = xPcoll_tot_ref_fsav*P_ref;
%
		xPelec0_fsav_mksa = xPelec0_ref_fsav*P_ref;
		xPelec_tot_fsav_mksa = xPelec_tot_ref_fsav*P_ref;
%
		xyPabs0_lh_fsav_mksa = xyPabs0_lh_ref_fsav*P_ref;
		xyPabs_tot_lh_fsav_mksa = xyPabs_tot_lh_ref_fsav*P_ref;
		xyPabs0_ec_fsav_mksa = xyPabs0_ec_ref_fsav*P_ref;
		xyPabs_tot_ec_fsav_mksa = xyPabs_tot_ec_ref_fsav*P_ref;
%
		xPabs0_fsav_mksa = xPabs0_ref_fsav*P_ref;
		xPabs_tot_fsav_mksa = xPabs_tot_ref_fsav*P_ref;
%
% Efficiency (j/p)
%
		xeta0_ref_fsav = xcurr0_ref_fsav./(xPabs0_ref_fsav + eps);
%
		xeta0_fsav_mksa = xeta0_ref_fsav*j_ref/P_ref;	
%
		xepsi_fsav_mksa = xepsi_ref_fsav*Edreicer_ref;	
%
%		xPabs0_mksa_out = xPabs0_mksa;
%		xPabs_tot_mksa_out = xPabs_tot_mksa;
%		xeta0_mksa_out = xeta0_mksa(r_dke);
%		xepsi_mksa_out = xepsi_mksa(r_dke);
%
		if dke_mode == 0,
%
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global results (normalized to reference units) at Bmin [theta_pol = 0 (deg)]:');
			disp(['   - Density [spherical]: ',num2str(xnormf_ref(ir_display_dke)),', [cylindrical]: ',num2str(xnormf_cyl_ref(ir_display_dke))])
			disp(['   - RF current density [spherical]: ',num2str(xcurr0_ref(ir_display_dke)),', [cylindrical]: ',num2str(xcurr0_cyl_ref(ir_display_dke))])
			disp(['   - Ohmic eletric field: ',num2str(xepsi_ref(ir_display_dke))])
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global results (normalized to MKSA units) at Bmin [theta_pol = 0 (deg)]:');
			disp(['   - Density (10+19 m-3) [spherical]: ',num2str(xnormf_ref(ir_display_dke)*ne_ref/1e19),', [cylindrical]: ',num2str(xnormf_cyl_ref(ir_display_dke)*ne_ref/1e19)])
			disp(['   - RF current density (MA/m2) [spherical]: ',num2str(j_ref*xcurr0_ref(ir_display_dke)),', [cylindrical]: ',num2str(j_ref*xcurr0_cyl_ref(ir_display_dke))])
			disp(['   - Ohmic eletric field (V/m): ',num2str(xepsi_ref(ir_display_dke)*Edreicer_ref)])
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global flux surface averaged results (normalized to reference units):');
			disp(['   - Density: [spherical]: ',num2str(xnormf_ref_fsav(ir_display_dke))])
			disp(['   - RF current density: [spherical]: ',num2str(xcurr0_ref_fsav(ir_display_dke))])
			disp(['   - RF power density lost on collisions (coll) [spherical]: ',num2str(-xPcoll0_ref_fsav(ir_display_dke))])
			for ib=1:nb_lh
					disp(['   - LH beam #',num2str(ib),': v1 = ',num2str(1/waveparam_lh(ir_display_dke,ib,7)/betath_ref),', v2 = ',num2str(1/waveparam_lh(ir_display_dke,ib,6)/betath_ref),',D0lh = ',num2str(waveparam_lh(ir_display_dke,ib,5))])
					disp(['        LH Power absorbed [spherical]: ',num2str(xyPabs0_lh_ref_fsav(ir_display_dke,ib))]) 
				end
%
			for ib=1:nb_ec
					disp(['   - EC beam #',num2str(ib),': n// = ',num2str(waveparam_ec(ir_display_dke,ib,8)),...
				', Y = ',num2str(waveparam_ec(ir_display_dke,ib,1)*waveparam_ec(ir_display_dke,ib,3)/waveparam_ec(ir_display_dke,ib,2)),',D0ec = ',num2str(waveparam_ec(ir_display_dke,ib,5))])
					disp(['        EC Power absorbed [spherical]: ',num2str(xyPabs0_ec_ref_fsav(ir_display_dke,ib))]) 
			end
%
			if nb > 0,
					disp(['   - RF current drive efficiency [spherical]: ',num2str(xeta0_ref_fsav(ir_display_dke))])
			end
			disp(['   - Ohmic eletric field: ',num2str(xepsi_ref_fsav(ir_display_dke))])
			disp(['   - Runaway rate [spherical]: ',num2str(XxRR_ref_fsav(np-1,ir_display_dke))])
			  disp(['   - Kruskal-Berstein runaway rate (Z = 1) [spherical]: ',num2str(xRR_KB_fsav(ir_display_dke))])
			disp(['   - Bulk current [spherical]: ',num2str(xcurrB_ref_fsav(ir_display_dke))])
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global flux surface averaged results (normalized to MKSA units):');
			disp(['   - Density (10+19 m-3) [spherical]: ',num2str(xnormf_ref_fsav(ir_display_dke)*ne_ref/1e19)])
			disp(['   - RF current density (MA/m2) [spherical]: ',num2str(xJrf0_fsav_mksa(ir_display_dke))])
			disp(['   - RF power density lost on collisions (MW/m3) (coll) [spherical]: ',num2str(-xPcoll0_fsav_mksa(ir_display_dke))])
			for ib = 1:nb_lh
					disp(['   - LH beam #',num2str(ib),': v1 = ',num2str(1/waveparam_lh(ir_display_dke,ib,7)/betath_ref),', v2 = ',num2str(1/waveparam_lh(ir_display_dke,ib,6)/betath_ref),',D0lh = ',num2str(waveparam_lh(ir_display_dke,ib,5))])
					disp(['        LH Power absorbed (MW/m3) [spherical]: ',num2str(xyPabs0_lh_fsav_mksa(ir_display_dke,ib))]) 
				end
%
			for ib = 1:nb_ec
					disp(['   - EC beam #',num2str(ib),': n// = ',num2str(waveparam_ec(ir_display_dke,ib,8)),...
					', Y = ',num2str(waveparam_ec(ir_display_dke,ib,1)*waveparam_ec(ir_display_dke,ib,3)/waveparam_ec(ir_display_dke,ib,2)),',D0ec = ',num2str(waveparam_ec(ir_display_dke,ib,5))])
					disp(['        EC Power absorbed (MW/m3) [spherical]: ',num2str(xyPabs0_ec_fsav_mksa(ir_display_dke,ib))]) 
			end
%
			if nb > 0,
					disp(['   - RF current drive efficiency (A.m/W) [spherical]: ',num2str(xeta0_fsav_mksa(ir_display_dke))])
			end
			disp(['   - Ohmic eletric field (V/m): ',num2str(xepsi_fsav_mksa(ir_display_dke))])
			disp(['   - Runaway rate [spherical]: ',num2str(XxRR_ref_fsav(np-1,ir_display_dke)*nhu_ref*ne_ref*me)])
			disp(['   - Kruskal-Berstein runaway rate (Z = 1) [spherical]: ',num2str(xRR_KB_fsav(ir_display_dke)*nhu_ref*ne_ref*me)])
			disp(['   - Bulk current (MA/m2) [spherical]: ',num2str(xJrfB_fsav_mksa(ir_display_dke))])
		else
			[Xf0_g_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(Xf0_g_ref,pn_ref,mhu,dp_cyl);
			[Xf0_tp_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(Xf0_tp_ref,pn_ref,mhu,dp_cyl);
%
			Xf0_tp_cyl_ref = Xf0_tp_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
%        	Xf0_tp_cyl_ref = Xf0_tp_cyl_ref.*(Xmhu_cyl_ref<1-dmhu/2);%Remove values outside from the domain of calculation

			Xf0_g_cyl_ref = Xf0_g_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
%        	Xf0_g_cyl_ref = Xf0_g_cyl_ref.*(Xmhu_cyl_ref<1-dmhu/2);%Remove values outside from the domain of calculation
			Xf0_tpg_cyl_ref = Xf0_g_cyl_ref + Xf0_tp_cyl_ref;
			F1bootstrap_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_tpg_cyl_ref,1);
			Xf0_tot_cyl_ref = Xf0_cyl_ref + Xf0_g_cyl_ref + Xf0_tp_cyl_ref;
			xcurr_tot_cyl_ref(ir_display_dke) = 2*pi*integral_dke_jd(dpperp_cyl_ref,pperp_cyl_ref'.*integral_dke_jd(ppar_cyl_ref,Xvpar_cyl_ref.*Xf0_tot_cyl_ref,2),1);  
%   
			if display_mode >= 2 
				figure(9),plot(ppar_cyl_ref,F1bootstrap_cyl_ref),ylabel('F1(bootstrap)'),xlabel('ppar');zoom on
				pnplot_ref = min(find(pn_ref>=4));
				figure(10),plot(mhu,Xf0_tp_ref(pnplot_ref,:)','b--',mhu,Xf0_g_ref(pnplot_ref,:)','r-.')
				ylabel('ftp (b--) and g (r-.)');xlabel('mhu')
				title('pn-ref = 4')
				pause(time_pause);
%
				figure(11),clf
				C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xf0_tp_cyl_ref),[-20:20/nlevel:0]);grid on;zoom on;%Distribution function ftp and wave quasilinear diffusion coefficient contour plot
				axis('equal')
				title('2-D steady state electron distribution function ftp');
				xlabel('ppar/pth-ref');
				ylabel('pperp/pth-ref');
				if bounce_mode >= 1,%Draw bounce domain boundaries
					line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
					line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
					if isnan(nhuloss) == 0,%Draw the loss cone
						line([0,pnmax_S*sqrt(1-cos(xthetaloss(ir_display_dke)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display_dke)*pi/180)],'LineStyle','-','color','r');
						line([0,-pnmax_S*sqrt(1-cos(xthetaloss(ir_display_dke)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display_dke)*pi/180)],'LineStyle','-','color','r');
					end
				end
				if nb_lh > 0,
					hold on,plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--'),plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--'),hold off    
				end
				if nb_ec > 0,
					hold on;plot(pparres_cy_cyl_ref,pperpres_cy_cyl_ref,'k-.');hold off
					hold on,plot(pparres_cy_cyl0_ref,0,'k*'),hold off;  
				end
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
				pause(time_pause);
%
				figure(12),clf
				C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xf0_g_cyl_ref),[-20:20/nlevel:0]);grid on;zoom on;%Distribution function g and wave quasilinear diffusion coefficient contour plot
				axis('equal')
				title('2-D steady state electron distribution function g');
				xlabel('ppar/pth-ref');
				ylabel('pperp/pth-ref');
				if bounce_mode >= 1,%Draw bounce domain boundaries
					line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
					line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);

					if isnan(nhuloss) == 0,%Draw the loss cone
						line([0,pnmax_S*sqrt(1-cos(xthetaloss(ir_display_dke)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display_dke)*pi/180)],'LineStyle','-','color','r');
						line([0,-pnmax_S*sqrt(1-cos(xthetaloss(ir_display_dke)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display_dke)*pi/180)],'LineStyle','-','color','r');
					end
				end
%
				if nb_lh > 0,
					hold on
					Dlhmax = max(max(XDlh_cyl_ref));
					contour(ppar_cyl_ref,pperp_cyl_ref,XDlh_cyl_ref',[0,eps],'r--')
					hold off
				end
%
				if nb_ec > 0,
					hold on
					Decmax = max(max(XDec_cyl_ref));
					contour(ppar_cyl_ref,pperp_cyl_ref,XDec_cyl_ref',[Decmax/5:Decmax/5:Decmax],'b--')
					hold off
				end
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
				pause(time_pause);
%
				figure(13),clf
				C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xf0_cyl_ref+Xf0_tp_cyl_ref+Xf0_g_cyl_ref),[-20:20/nlevel:0]);grid on;zoom on;%Distribution function f and wave quasilinear diffusion coefficient contour plot
				axis('equal')
				title('2-D steady state total electron distribution function f');
				xlabel('ppar/pth-ref');
				ylabel('pperp/pth-ref');
				if bounce_mode >= 1,%Draw bounce domain boundaries
					line([0,pnmax_S*sqrt(xmhubounce2(ir_display_dke))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display_dke))]);
					line([0,-pnmax_S*sqrt(xmhubounce2(ir_display_dke))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display_dke))]);
					if isnan(nhuloss) == 0,%Draw the loss cone
						line([0,pnmax_S*sqrt(1-cos(xthetaloss(ir_display_dke)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display_dke)*pi/180)],'LineStyle','-','color','r');
						line([0,-pnmax_S*sqrt(1-cos(xthetaloss(ir_display_dke)*pi/180)^2)],[0,pnmax_S*cos(xthetaloss(ir_display_dke)*pi/180)],'LineStyle','-','color','r');
					end
				end
%
				if nb_lh > 0
					hold on
					Dlhmax = max(max(XDlh_cyl_ref));
					contour(ppar_cyl_ref,pperp_cyl_ref,XDlh_cyl_ref',[0,eps],'r--')
					hold off
				end
%
				 if nb_ec > 0
					hold on
					Decmax = max(max(XDec_cyl_ref));
					contour(ppar_cyl_ref,pperp_cyl_ref,XDec_cyl_ref',[Decmax/5:Decmax/5:Decmax],'b--')
					hold off
				end
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
				pause(time_pause);
			end
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global results (normalized to reference units) at Bmin [theta_pol = 0 (deg)]:');
			disp(['   - Density [spherical]: ',num2str(xnormf_ref(ir_display_dke)),', [cylindrical]: ',num2str(xnormf_cyl_ref(ir_display_dke))])
			disp(['   - RF only current density [spherical]: ',num2str(xcurr0_ref(ir_display_dke)),', [cylindrical]: ',num2str(xcurr0_cyl_ref(ir_display_dke))])
			disp(['   - Electron bootstrap current density [spherical]: ',num2str(xcurr_boot_ref(ir_display_dke)),', [cylindrical]: ',num2str(xcurr_tot_cyl_ref(ir_display_dke) - xcurr0_cyl_ref(ir_display_dke))])
			disp(['   - RF + electron bootstrap current density [spherical]: ',num2str(xcurr_tot_ref(ir_display_dke)),', [cylindrical]: ',num2str(xcurr_tot_cyl_ref(ir_display_dke))])
			disp(['   - Ohmic eletric field: ',num2str(xepsi_ref(ir_display_dke))])
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global results (normalized to MKSA units) at Bmin [theta_pol = 0 (deg)]:');
			disp(['   - Density (10+19 m-3) [spherical]: ',num2str(xnormf_ref(ir_display_dke)*ne_ref/1e19),', [cylindrical]: ',num2str(xnormf_cyl_ref(ir_display_dke)*ne_ref/1e19)])
			disp(['   - RF only current density (MA/m2) [spherical]: ',num2str(j_ref*xcurr0_ref(ir_display_dke)),', [cylindrical]: ',num2str(j_ref*xcurr0_cyl_ref(ir_display_dke))])
			disp(['   - Electron bootstrap current density (MA/m2) [spherical]: ',...
			num2str(j_ref*(xcurr_tot_ref(ir_display_dke) - xcurr0_ref(ir_display_dke))),', [cylindrical]: ',num2str(j_ref*(xcurr_tot_cyl_ref(ir_display_dke) - xcurr0_cyl_ref(ir_display_dke)))])
			disp(['   - RF + electron bootstrap current density (MA/m2) [spherical]: ',num2str(j_ref*xcurr_tot_ref(ir_display_dke)),', [cylindrical]: ',num2str(j_ref*xcurr_tot_cyl_ref(ir_display_dke))])
			disp(['   - Ohmic eletric field (V/m): ',num2str(xepsi_ref(ir_display_dke)*Edreicer_ref)])
%

			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global flux surface averaged results (normalized to reference units):');
			disp(['   - Density: [spherical]: ',num2str(xnormf_ref_fsav(ir_display_dke))])
			disp(['   - RF only current density: [spherical]: ',num2str(xcurr0_ref_fsav(ir_display_dke))])
			disp(['   - Electron Bootstrap current density: [spherical]: ',num2str(xcurr_boot_ref_fsav(ir_display_dke))])
			disp(['   - RF + electron bootstrap current density: [spherical]: ',num2str(xcurr_tot_ref_fsav(ir_display_dke))])
			disp(['   - Ion bootstrap current density: ',num2str(xcurr_i_mksa_fsav(ir_display_dke)/j_ref)])
			disp(['   - Total bootstrap current density [spherical]: ',num2str(xcurr_boot_ref(ir_display_dke) + xcurr_i_mksa_fsav(ir_display_dke)/j_ref)]);
			disp(['   - Hinton & Hazeltine model for bootstrap: ',num2str(xcurr_hin_mksa_fsav(ir_display_dke)/j_ref)])  
			disp(['   - Hirshman model for bootstrap: ',num2str(xcurr_hir_mksa_fsav(ir_display_dke)/j_ref)])        
			disp(['   - Sauter model for bootstrap: ',num2str(xcurr_sau_mksa_fsav(ir_display_dke)/j_ref)])        
			disp(['   - RF + total bootstrap current density [spherical]: ',num2str(xcurr_tot_ref_fsav(ir_display_dke) + xcurr_i_mksa_fsav(ir_display_dke)/j_ref)]);
			disp(['   - RF power density lost on collisions (coll) [spherical]: ',num2str(-xPcoll0_ref_fsav(ir_display_dke))])
%
			for ib=1:nb_lh,
				disp(['   - LH beam #',num2str(ib),': v1 = ',num2str(1/waveparam_lh(ir_display_dke,ib,7)/betath_ref),', v2 = ',num2str(1/waveparam_lh(ir_display_dke,ib,6)/betath_ref),',D0lh = ',num2str(waveparam_lh(ir_display_dke,ib,5))])
				disp(['        LH Power absorbed [spherical]: ',num2str(xyPabs0_lh_ref_fsav(ir_display_dke,ib))]) 
			end
%	
			for ib=1:nb_ec,
				disp(['   - EC beam #',num2str(ib),': n// = ',num2str(waveparam_ec(ir_display_dke,ib,8)),...
				', Y = ',num2str(waveparam_ec(ir_display_dke,ib,1)*waveparam_ec(ir_display_dke,ib,3)/waveparam_ec(ir_display_dke,ib,2)),',D0ec = ',num2str(waveparam_ec(ir_display_dke,ib,5))])
					disp(['        EC Power absorbed [spherical]: ',num2str(xyPabs0_ec_ref_fsav(ir_display_dke,ib))]) 
			end
%
			if nb > 0,
					disp(['   - RF only current drive efficiency [spherical]: ',num2str(xeta0_ref_fsav(ir_display_dke))])
			end
			disp(['   - Ohmic eletric field: ',num2str(xepsi_ref_fsav(ir_display_dke))])
			disp(['   - Runaway rate [spherical]: ',num2str(XxRR_ref_fsav(np-1,ir_display_dke))])
			disp(['   - Bulk current [spherical]: ',num2str(xcurrB_ref_fsav(ir_display_dke))])
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global flux surface averaged results (normalized to MKSA units):');
			disp(['   - Density (10+19 m-3) [spherical]: ',num2str(xnormf_ref_fsav(ir_display_dke)*ne_ref/1e19)])
			disp(['   - RF only current density (MA/m2) [spherical]: ',num2str(xJrf0_fsav_mksa(ir_display_dke))])
			disp(['   - Electron bootstrap current density (MA/m2) [spherical]: ',num2str(xJboot_e_fsav_mksa(ir_display_dke))])
			disp(['   - RF + electron bootstrap current density (MA/m2) [spherical]: ',num2str(xJrf_tot_fsav_mksa(ir_display_dke))])
			disp(['   - Ion bootstrap current density (MA/m2): ',num2str(xJboot_i_fsav_mksa(ir_display_dke))])
			disp(['   - Total bootstrap current density (MA/m2) [spherical]: ',num2str(xJboot_tot_fsav_mksa(ir_display_dke))])        
			disp(['   - Hinton & Hazeltine model for bootstrap (MA/m2): ',num2str(xcurr_hin_mksa_fsav(ir_display_dke))])        
			disp(['   - Hirshman model for bootstrap (MA/m2): ',num2str(xcurr_hir_mksa_fsav(ir_display_dke))])        
			disp(['   - Sauter model for bootstrap (MA/m2): ',num2str(xcurr_sau_mksa_fsav(ir_display_dke))])  
			disp(['   - RF + total bootstrap current density (MA/m2) [spherical]: ',num2str(xJtot_fsav_mksa(ir_display_dke))])
			disp(['   - RF power density lost on collisions (MW/m3) (coll) [spherical]: ',num2str(-xPcoll0_fsav_mksa(ir_display_dke))])
%
			for ib=1:nb_lh,
					disp(['   - LH beam #',num2str(ib),': v1 = ',num2str(1/waveparam_lh(ir_display_dke,ib,7)/betath_ref),', v2 = ',num2str(1/waveparam_lh(ir_display_dke,ib,6)/betath_ref),',D0lh = ',num2str(waveparam_lh(ir_display_dke,ib,5))])
					disp(['        LH Power absorbed (MW/m3) [spherical]: ',num2str(xyPabs0_lh_mksa(ir_display_dke,ib))]) 
			end
%
			for ib=1:nb_ec,
					disp(['   - EC beam #',num2str(ib),': n// = ',num2str(waveparam_ec(ir_display_dke,ib,8)),...
					', Y = ',num2str(waveparam_ec(ir_display_dke,ib,1)*waveparam_ec(ir_display_dke,ib,3)/waveparam_ec(ir_display_dke,ib,2)),',D0ec = ',num2str(waveparam_ec(ir_display_dke,ib,5))])
					disp(['        EC Power absorbed (MW/m3) [spherical]: ',num2str(xyPabs0_ec_mksa(ir_display_dke,ib))]) 
			end
%
			if nb > 0,
					disp(['   - RF current drive efficiency (A.m/W) [spherical]: ',num2str(xeta0_mksa(ir_display_dke))])
			end
			disp(['   - Ohmic eletric field (V/m): ',num2str(xepsi_fsav_mksa(ir_display_dke))])
			disp(['   - Runaway rate (Kg.m-3.s-1) [spherical]: ',num2str(XxRR_ref_fsav(np-1,ir_display_dke)*nhu_ref*ne_ref*me)])
			disp(['   - Bulk current (MA/m2) [spherical]: ',num2str(xJrfB_fsav_mksa(ir_display_dke))])
%
		end
	end
%
	if display_mode == 2,
%
        figure(200),clf
        [ax] = graph1D_jd(xrho_dke,xJrf0_fsav_mksa,'\rho','<J_{RF}> (MA/m^2)','RF + Ohmic Current Density',NaN,[0,1],NaN,'none','+','r',2,14,gca,0.8,0.7,0.6);
%
        figure(203),clf
        [ax] = graph1D_jd(xrho_dke,-xPcoll_tot_fsav_mksa,'','','',NaN,[0,1],NaN,'none','+','r',2,14,gca,0.8,0.7,0.6);
        hold on
        [ax] = graph1D_jd(xrho_dke,xPelec_tot_fsav_mksa,'','','',NaN,[0,1],NaN,'none','+','b',2,14);
        [ax] = graph1D_jd(xrho_dke,xPabs_tot_fsav_mksa,'\rho','<P_{abs}> (MW/m^3)','Density of Absorbed Power',['Collisions';'Ohmic     ';'RF Waves  '],[0,1],0,'none','+','m',2,14);
%
		if dke_mode == 1,  
%
            figure(201),clf
            [ax] = graph1D_jd(xrho_dke,xJboot_tot_fsav_mksa,'','','',NaN,[0,1],NaN,'none','+','r',2,14,gca,0.8,0.7,0.6);
            hold on
            [ax] = graph1D_jd(prho,pcurr_hin_mksa_fsav,'','','',NaN,[0,1],NaN,'-','none','g',2,14);
            [ax] = graph1D_jd(prho,pcurr_hir_mksa_fsav,'','','',NaN,[0,1],NaN,'-','none','b',2,14);
            [ax] = graph1D_jd(prho,pcurr_sau_mksa_fsav,'\rho','<J_B> (MA/m^2)',['Bootstrap current in ',tokname],['DKE code';'Hinton  ';'Hirchman';'Sauter  '],[0,1],0,'-','none','m',2,14);
%
            figure(202),clf
            [ax] = graph1D_jd(xrho_dke,xJtot_fsav_mksa,'\rho','<J_{tot}> (MA/m^2)','Total Current Density',NaN,[0,1],0,'none','+','r',2,14,gca,0.8,0.7,0.6);
%
		end
		if igor_mode == 1,
			eval(['save ',filenameroot,'_data_fig200.mat xrho_dke xia r_dke j_ref xcurr_tot_ref_fsav P_ref xPabs_tot_ref_fsav xTe xTi xne xnhyd xft xft_llm'])
		end
%        
	end
%
	if diary_mode == 1,
		  diary off, 
		  disp('-------------------------------------------------------------------------------------------------------------------');
		 info_dke_yp(2,['The diary file  : ',dossier,s,'diary_dke_s','_',int2str(snumber),'_',int2str(iloop),' has been successfully saved !']);
	 end
%
	if auto_mode == 1, break, end	
end
%
if auto_mode == 0 & nr > 1,
	 disp('  ');
	ie_display = 1;
	Ec_r_ref_in = xEc_r_ref_threshold(1);
	info_dke_yp(1,'Radial profile plot of F//');
	h_figure = 499;
	while 1,
		h_figure = h_figure + 1;
		disp('**************************************************************************')
		Ec_r_ref_in = input_dke_yp('Reference energy (keV) (exit: <=0)',Ec_r_ref_in);
		disp('**************************************************************************')
		disp(' ')
		if Ec_r_ref_in <= 0,break;end
		ppar_r_cyl_ref_in = sqrt(((Ec_r_ref_in/mc2 + 1)^2 - 1))/betath_ref;
		for ir1 = 1:length(r_dke),		
			eval(['Xf0_r_ref = squeeze(XXf0_ref(:,:,',int2str(ir1),'));']);%Display results at the required radial value
			[Xf0_r_cyl_ref,ppar_r_cyl_ref,dppar_r_cyl_ref,pperp_r_cyl_ref,dpperp_r_cyl_ref] = s2c_dke_yp(Xf0_r_ref,pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
			Xf0_r_cyl_ref(isnan(Xf0_r_cyl_ref)) = 0;%Remove NaN values
			Xpperp_r_cyl_ref = pperp_r_cyl_ref(:)*ones(1,length(ppar_r_cyl_ref));
			Fpar0_r_cyl_ref = 2*pi*integral_dke_jd(dpperp_r_cyl_ref,Xpperp_r_cyl_ref.*Xf0_r_cyl_ref,1);
			zFpar0_r_cyl_ref = find(Fpar0_r_cyl_ref==0);Fpar0_r_cyl_ref(zFpar0_r_cyl_ref) = Fpar0_r_cyl_ref(zFpar0_r_cyl_ref)+1e-60;%zero removal		
			ippar_r_cyl_ref_in = max(find(ppar_r_cyl_ref < ppar_r_cyl_ref_in));
			Ec_r_ref_out = mc2*(sqrt(1 + ppar_r_cyl_ref(ippar_r_cyl_ref_in).*ppar_r_cyl_ref(ippar_r_cyl_ref_in)*betath_ref^2) - 1);%Fast electron kinetic energy in keV    
			prof_r_Fpar_ref(ir1) = Fpar0_r_cyl_ref(ippar_r_cyl_ref_in);
		end
		figure(h_figure),plot(xrho_dke,prof_r_Fpar_ref,'r+',xrho_dke,prof_r_Fpar_ref,'b-');
		grid on, zoom on
		xlabel('rho'),ylabel('F//')
		title(['Electron kinetic energy: ',num2str(Ec_r_ref_out),' (keV), threshold: ',num2str(xEc_r_ref_threshold(1)),' (keV)']);
%
		if igor_mode == 1,
			if exist([filenameroot,'_Fparprof_',int2str(ie_display),'_out.mat']) == 2,
				delete([filenameroot,'_Fparprof_',int2str(ie_display),'_out.mat']);
			end
			eval(['save ',filenameroot,'_Fparprof_',int2str(ie_display),'_out.mat  Ec_r_ref_out xEc_r_ref_threshold xrho_dke r_dke prof_r_Fpar_ref']);
			if exist([filenameroot,'_Fparprof_',int2str(ie_display),'_out.mat']) == 2,
				disp('-------------------------------------------------------------------------------------------------------------------');
				info_dke_yp(2,['The profile file : ',filenameroot,'_Fparprof_',int2str(ie_display),'_out.mat has been successfully saved !']);
			end
		end
%
		ie_display = ie_display + 1;
	end
end
%
