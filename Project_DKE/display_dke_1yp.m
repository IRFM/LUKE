function [xJrf0_fsav_mksa,xJboot_e_fsav_mksa,xJboot_i_fsav_mksa,xJtot_fsav_mksa,...
xPabs0_fsav_mksa,xPabs_tot_fsav_mksa,...
xeta0_fsav_mksa,xepsi_fsav_mksa,xia,xft_fsav] = display_dke_1yp(filename,auto_mode_in,igor_mode)
%
% Display results of the Electron Drift Kinetic solver (test_dke_1yp.m)
%
%by Y.Peysson CEA-DRFC 02/08/2003 <yves.peysson@cea.fr>
%
%
warning off;
[s,dossier,machine] = comput_dke_yp;
if nargin == 0,	
	eval(['dir ',dossier,s,'RESULTS_*.mat']);
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
eval(['load ',dossier,s,filename]);%Load DKE output data
%
display_mode = input_dke_yp('Display graphics (yes: 1, no: 0)',1) + 1;
%
if nargin >= 2,
	auto_mode = auto_mode_in;
end
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
%
xRR_KB_fsav = 0.35*abs(xepsi_ref_fsav).^(-3/8).*exp(-(sqrt(2./abs(xepsi_ref_fsav))+1./4./abs(xepsi_ref_fsav)));%Kulsrud fit of the theoretical Kruskal-Bernstein runaway rate (PRL 31,11 (1973) 690)
%
P_ref = me*(clum*betath_ref)^2*nhu_ref*ne_ref/1e6;%MKSA power unit
j_ref = qe*clum*betath_ref*ne_ref/1e6;%MKSA current unit
Edreicer_ref = me*clum*betath_ref*nhu_ref/qe;%MKSA Dreicer field unit
%
XxRR_mksa_fsav = XxRR_ref_fsav*nhu_ref*ne_ref;%Runaway loss rate in mksa units
%
if bounce_mode > 0,
	xnhu_e_star = 0.012*(xne(r_dke)/1e20).*xZeff(r_dke).*xq*Rp./xia.^1.5./xTe(r_dke).^2;%From O. Sauter et al., Phys. Plasma 6 (1999) 2834
	[xfteff_llm] = ft_llm_dke_yp(xia,1000);%From Y.R. Lin-Liu and R.L. Miller, Phys. Plasma 2 (1995) 1666
%
	[s,dossier,machine] = comput_dke_yp;
	filename = ['EQUIL_',tokname,'.mat'];
	eval(['load ',dossier,s,filename,' ppsi ftra']);%Load effective trapped fraction given by HELENA
	if exist('ftra') == 1 && (length(ppsi)==length(ftra)),
		xftra = interp1(ppsi,ftra,xpsin(r_dke));
	else 
		xftra=NaN*xpsin(r_dke);
	end
else
	xnhu_e_star = NaN*ones(size(xia));
	xfteff_llm = zeros(size(xia));
end
%
%Calculation of the flux averaged Maxwellian bootstrap current from Hirshman, Sauter, Hinton & Hazeltine models (bulk contribution)
%
[prho,pcurr_hir_mksa_fsav,pcurr_sau_mksa_fsav,pcurr_hin_mksa_fsav,pcurr_i_mksa_fsav,L31] = hsneomodels_dke_jd(tokname);
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
        if syn_mode == 1,
            Xf0_bc_ref = XXf0_bc_ref(:,:,ir_display);%Display results at the required radial value
		    Xf0_bc_tp_ref = XXf0_bc_tp_ref(:,:,ir_display);%Display results at the required radial value
		    Xf0_bc_g_ref = XXf0_bc_g_ref(:,:,ir_display);%Display results at the required radial value
        end
		if coll_mode == 3,
			Xf0_L_tp_ref = XXf0_L_tp_ref(:,:,ir_display);%Display results at the required radial value
			Xf0_L_g_ref = XXf0_L_g_ref(:,:,ir_display);%Display results at the required radial value
		end
		Xfinit_ref = XXfinit_ref(:,:,ir_display);%Display results at the required radial value
		if nb > 0
			YXDrf_ref = squeeze(YXXDrf_ref(:,:,ir_display,:));%Display results at the required radial value
		end
		[XAstr_S_Pm_ref,XAstr_S_Pp_ref,XAstr_S_T_ref] = stream_dke_jd(ZSp0_ref,XxRR_ref_fsav,mhu,xmhubounce2,dmhu,pnp,ir_display_dke,nb);
%
		disp('-------------------------------------------------------------------------------------------------------------------');
		disp('-------------------------------------------------------------------------------------------------------------------');
		disp('-------------------------------------------- Calculation output ---------------------------------------------------')
		disp('-------------------------------------------------------------------------------------------------------------------');
		info_dke_yp(2,['Reference electron temperature (keV): ',num2str(Ten_ref*mc2)])
		info_dke_yp(2,['Betath_ref: ',num2str(betath_ref)])
		info_dke_yp(2,['Reference electron density (10+19 m-3): ',num2str(ne_ref/1e19)])
		info_dke_yp(2,['Reference Coulomb logarithm: ',num2str(lnc_e_ref)])
		info_dke_yp(2,['Reference electron collision frequency (kHz): ',num2str(nhu_ref/1000)])
		info_dke_yp(2,['MKSA power unit (P_ref): ',num2str(P_ref),' (MW/m3)'])
		info_dke_yp(2,['MKSA current unit (j_ref): ',num2str(j_ref),' (MA/m2)'])
		info_dke_yp(2,['MKSA Dreicer field unit (Edreicer_ref): ',num2str(Edreicer_ref),' (V/m)'])
%
		disp('-------------------------------------------------------------------------------------------------------------------');
		info_dke_yp(2,['Integration time step: ',num2str(abs(dtn)/nhu_ref),' (s)'])
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
		info_dke_yp(2,['Normalized Coulomb logarithm: ',num2str(xlnc_e(ir_display)/lnc_e_ref)])
		info_dke_yp(2,['Normalized electron collision frequency: ',num2str(xnhu(ir_display)/nhu_ref)])
		if bounce_mode > 0,
			info_dke_yp(2,['Exact trapped fraction from DKE: ',num2str(xft_fsav(ir_display_dke))])
			info_dke_yp(2,['Effective trapped fraction from DKE: ',num2str(xfteff_fsav(ir_display_dke))])
			info_dke_yp(2,['Approximate effective trapped fraction from from DKE (Lin-Liu-Miller): ',num2str(xfteff_llm(ir_display_dke))])
			if exist('ftra') == 1,
				info_dke_yp(2,['Effective trapped fraction from HELENA: ',num2str(xftra(ir_display_dke))])
			end
			info_dke_yp(2,['Collisionality parameter: ',num2str(xnhu_e_star(ir_display_dke))])
		end
		disp('-------------------------------------------------------------------------------------------------------------------');
%
%Magnetic ripple losses
%
    	if bounce_mode >= 1 & isnan(xnhuloss_ref(ir_display)) == 0 & strcmp(tokname,'TS')==1,
    		pparsupertrap_ref = xpndetrap_ref(ir_display)*mhu(abs(mhu)<=xmhusupertrap(ir_display));%For contour plot of the supertrapped domain
    		pperpsupertrap_ref = xpndetrap_ref(ir_display)*sqrt(1-mhu(abs(mhu)<=xmhusupertrap(ir_display)).^2);%For contour plot of the supertrapped domain
%
			xMRR_tau_mksa = xMRR_tau_ref*nhu_ref*ne_ref;
			xMRR_flux_mksa = xMRR_flux_ref*nhu_ref*ne_ref;
%
    		disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global results (normalized to reference units) at Bmin [theta_pol = 0 (deg)]:');
			info_dke_yp(2,['Magnetic ripple loss rate: ',num2str(xMRR_tau_ref(ir_display))]);
			info_dke_yp(2,['Magnetic ripple loss rate (flux calculations) : ',num2str(xMRR_flux_ref(ir_display))]);
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global results (normalized to MKSA units) at Bmin [theta_pol = 0 (deg)]:');
    		info_dke_yp(2,['Magnetic ripple loss rate (s-1.m-3): ',num2str(xMRR_tau_mksa(ir_display))]);
			info_dke_yp(2,['Magnetic ripple loss rate (flux calculations) (s-1.m-3): ',num2str(xMRR_flux_mksa(ir_display))]);
			disp('-------------------------------------------------------------------------------------------------------------------');
%
            figure(207),clf
            [ax] = graph1D_jd(xrho_dke,xMRR_tau_mksa,'','','',NaN,[0,1],NaN,'none','+','r',2,14,gca,0.8,0.7,0.6);
			hold on
            [ax] = graph1D_jd(xrho_dke,xMRR_flux_mksa,'\rho','\Gamma_{ST} (m^-3.s^-1)','Magnetic ripple loss rate at Bmin',NaN,[0,1],NaN,'none','x','b',2,14,gca,0.8,0.7,0.6);
			hold off
			axis([0,1,0,1.1*max([xMRR_tau_mksa,xMRR_flux_mksa])]);
	    else
            xpndetrap_ref = NaN;
            xmhusupertrap = NaN;
    	    pparsupertrap_ref = NaN;
            pperpsupertrap_ref = NaN;
			info_dke_yp(2,'No magnetic ripple loss calculations');
			disp('-------------------------------------------------------------------------------------------------------------------');
	    end
%
%Spherical to cylindrical coordinate transformation
%
		[logXfinit_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xfinit_ref),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
		Xfinit_cyl_ref = exp(logXfinit_cyl_ref);%For accurate representation in figures 
		[logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xf0_ref),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
		Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
		if syn_mode == 1,
            [logXf0_bc_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xf0_bc_ref),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    		Xf0_bc_cyl_ref = exp(logXf0_bc_cyl_ref);%For accurate representation in figures 
        end
%
%Points added at mhu = +/-1 for better plot (particularly effective for EBW)
%
        mhu_X = [-1,mhu,1];
		for ib = 1:nb
            n_rf = waveparam(ir_display,ib,1);
            if n_rf >= 2,
                XDrf_X_ref = [zeros(np,1),YXDrf_ref(:,:,ib),zeros(np,1)];
			    [YXDrf_cyl_ref(:,:,ib),ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_S_dke_yp(XDrf_X_ref,pn_ref,mhu_X,dp_cyl);%Spherical to cylindrical coordinate transformation
            else
			    [YXDrf_cyl_ref(:,:,ib),ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(YXDrf_ref(:,:,ib),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
            end
		end
%
		[XAstr_Pp_cyl_ref,ppar_cyl_S_ref,dppar_cyl_S_ref,pperp_cyl_S_ref,dpperp_S_cyl_ref] = s2c_dke_yp(XAstr_S_Pp_ref,pn_S,mhu_S,dp_cyl);%Spherical to cylindrical coordinate transformation
		[XAstr_Pm_cyl_ref,ppar_cyl_S_ref,dppar_cyl_S_ref,pperp_cyl_S_ref,dpperp_S_cyl_ref] = s2c_dke_yp(XAstr_S_Pm_ref,pn_S,mhu_S,dp_cyl);%Spherical to cylindrical coordinate transformation
		[XAstr_T_cyl_ref,ppar_cyl_S_ref,dppar_cyl_S_ref,pperp_cyl_S_ref,dpperp_S_cyl_ref] = s2c_dke_yp(XAstr_S_T_ref,pn_S,mhu_S,dp_cyl);%Spherical to cylindrical coordinate transformation
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
        if syn_mode == 1,
		    Xf0_bc_cyl_ref = Xf0_bc_cyl_ref.*(Xf0_bc_cyl_ref>0);%Remove negative values
		    Xf0_bc_cyl_ref = Xf0_bc_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
		    Xf0_bc_cyl_ref(isnan(Xf0_bc_cyl_ref)) = 0;%Remove NaN values
        end
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
		XAstr_cyl_Pp_ref = XAstr_Pp_cyl_ref.*(Xp_cyl_S_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
		XAstr_cyl_Pm_ref = XAstr_Pm_cyl_ref.*(Xp_cyl_S_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
		XAstr_cyl_T_ref = XAstr_T_cyl_ref.*(Xp_cyl_S_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
		%XAstr_cyl_ref = XAstr_cyl_ref.*(XAstr_cyl_ref>0);%Remove negative values
		XAstr_Pp_cyl_ref(isnan(XAstr_Pp_cyl_ref)) = 0;%Remove NaN values
		XAstr_Pm_cyl_ref(isnan(XAstr_Pm_cyl_ref)) = 0;%Remove NaN values
		XAstr_T_cyl_ref(isnan(XAstr_T_cyl_ref)) = 0;%Remove NaN values
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
%   Display results
%
%
%   General graph properties
%
            x1 = ppar_cyl_ref;
            xlab1 = 'p_{//}/p_{Te}^{ref}';
            xlim1 = [-pnmax_S,pnmax_S];
            x2 = pperp_cyl_ref;
            xlab2 = 'p_{\perp}/p_{Te}^{ref}';
            xlim2 = [0,pnmax_S];
            leg = ['f_{init}';'f_0     '];
            style1 = '--';
            style2 = '-';
            style3 = 'none';
            marker = 'none';
            marker1 = 'x';
            marker2 = '+';
            color1 = 'b';
            color2 = 'r';
            color3 = 'g';
            color4 = 'm';
            color5 = 'k';
            width1 = 0.5;
            width2 = 2;
            siz = 20;
            red = 0.95;
            lspace = 0.7;
            bspace1 = 0.7;
            bspace2 = 0.5;
%
            x9 = x1;
            y9 = sqrt(pnmax_S^2 - x9.^2);
%            
            rhostr = num2str(xrho_dke(ir_display_dke));
            rhostr = rhostr(1:min([5,length(rhostr)]));
%
% ---------- parallel distribution -----------
%
            figure(301),clf
            %
            y1 = Fparinit_cyl_ref;
            y2 = Fpar0_cyl_ref;
            ylab = 'F_{0//}';
            ylim = [1e-20,1];
            %
            graph1D_jd(x1,y1,0,1,'','','',NaN,xlim1,ylim,style1,marker,color1,width1,siz,gca,red,lspace,bspace1);
            graph1D_jd(x1,y2,0,1,xlab1,ylab,'',leg,xlim1,ylim,style2,marker,color2,width2,siz);
            text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
%
			pause(time_pause);
%
% ---------- perpendicular temperature -----------
%
            figure(302),clf
            %
            y1 = Tperpinitn_cyl_ref;
            y2 = Tperpn_cyl_ref;
            ylab = 'T_{\perp}/T_e^{ref}';
            ylim = NaN;
            %
            graph1D_jd(x1,y1,0,0,'','','',NaN,xlim1,ylim,style1,marker,color1,width1,siz,gca,red,lspace,bspace1);
            graph1D_jd(x1,y2,0,0,xlab1,ylab,'',leg,xlim1,ylim,style2,marker,color2,width2,siz);
            text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
%
			pause(time_pause);
%
% ---------- parallel temperature -----------
%
            figure(303),clf
            %
            y1 = Tparinitn_cyl_ref;
            y2 = Tparn_cyl_ref;
            ylab = 'T_{//}/T_e^{ref}';
            ylim = NaN;
            %
            graph1D_jd(x2,y1,0,0,'','','',NaN,xlim2,ylim,style1,marker,color1,width1,siz,gca,red,lspace,bspace1);
            graph1D_jd(x2,y2,0,0,xlab2,ylab,'',leg,xlim2,ylim,style2,marker,color2,width2,siz);
            legend('f_{init}','f_0')
            text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
%
			pause(time_pause);
%
% ---------- 2D distribution f0 -----------
%
            figure(4),clf
            %
            y1 = Xfinit_cyl_ref;
            y2 = Xf0_cyl_ref;
            %
            graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,style2,color1,width1,siz,red,max(max(y1)));
            graph2D_jd(x1,x2,y2','','','',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,style2,color2,width2,siz,1,max(max(y1)));
            graph1D_jd(x9,y9,0,0,xlab1,xlab2,'2D Distribution function f_0',NaN,xlim1,xlim2,style2,marker,color5,width1,siz);
            text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
            axis('equal');axis([xlim1,xlim2])
            bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,nhuloss,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap);
%
			pause(time_pause);
%
			if igor_mode == 1,
				eval(['save ',filenameroot,'_data_fig4_',int2str(ir_display_dke),'.mat xrho_dke xia r_dke ir_display_dke ppar_cyl_ref pperp_cyl_ref Xfinit_cyl_ref Xf0_cyl_ref xmhubounce2 pnmax_S'])
			end
%
% ---------- Stream function -----------
%
            figure(5),clf
            %
            y1 = XAstr_S_Pm_ref';
            y2 = XAstr_S_T_ref';
            y3 = XAstr_S_Pp_ref';
            mhu0T = sqrt(xmhubounce2(ir_display));
            %
            ymin = min(min([y1,y2,y3]));
            ymax = max(max([y1,y2,y3]));
            dy = (ymax - ymin)/(2*nlevel);
            if ymin*ymax < 0
                cont = sort([-dy/2:-dy:ymin-dy/2,dy/2:dy:ymax+dy/2]);
            else
                cont = ymin:dy:ymax;
            end
            %
            graph_cyl_jd(pn_S,mhu_S,y1,'',xlim1,xlim2,NaN,cont,style2,NaN,width1,red,NaN,[0,pnmax_S,-1,-mhu0T+eps]);
            graph_cyl_jd(pn_S,mhu_S,y2,'',xlim1,xlim2,NaN,cont,style2,NaN,width1,1,NaN,[0,pnmax_S,-mhu0T-eps,mhu0T+eps]);
            graph_cyl_jd(pn_S,mhu_S,y3,'',xlim1,xlim2,NaN,cont,style2,NaN,width1,1,NaN,[0,pnmax_S,mhu0T-eps,1]);
            graph1D_jd(x9,y9,0,0,xlab1,xlab2,'Stream function',NaN,xlim1,xlim2,style2,marker,color5,width1,siz);
            text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
            axis('equal');axis([xlim1,xlim2])
            bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,nhuloss,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap);
%            
			pause(time_pause);
%
% ----------- Ohmic electric field
%
			if max(abs(xepsi_ref_fsav_in)) > 0,
         		figure(304)
 	        	y1 = xepsi_ref_fsav_in;
				ylab = '<E_{//}> (E_{Dreicer-ref})';
	         	graph1D_jd(xrho_dke,y1,0,0,'\rho',ylab,'Normalized Ohmic electric field',NaN,[0,1],[min(y1)-eps,max(y1)+eps],style1,marker,color1,width1,siz,gca,red,lspace,bspace1);
				text(0.05,0.95,['E_{Dreicer-ref} = ',num2str(Edreicer_ref),' (V/m)'],'units','normalized');
         %
	         	figure(305)
				y1 = xepsi_ref_fsav_in.*Edreicer_ref;
				ylab = '<E_{//}> (V/m)';
				graph1D_jd(xrho_dke,y1,0,0,'\rho',ylab,'Ohmic electric field',NaN,[0,1],[min(y1)-eps,max(y1)+eps],style1,marker,color1,width1,siz,gca,red,lspace,bspace1);
			end
%
% ----------- LH domain if applicable
%
			if nb_lh > 0 & xvparmax_lh_ref(ir_display) - xvparmin_lh_ref(ir_display) ~= 0  & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,
				pparresmin_lh_cyl_ref = xvparmin_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmin_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
				pparresmax_lh_cyl_ref = xvparmax_lh_ref(ir_display)*sqrt(1 + betath_ref^2.*pperp_cyl_ref.^2)/sqrt(1 - xvparmax_lh_ref(ir_display)^2*betath_ref^2);%LH resonance condition
                %
				if igor_mode == 1,
					eval(['save ',filenameroot,'_data_fig_',int2str(ir_display_dke),'lh.mat xrho_dke xia r_dke ir_display_dke pparresmin_lh_cyl_ref pparresmax_lh_cyl_ref pperp_cyl_ref'])
				end
                %
            	figure(4),
				hold on;
				plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
				plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
				hold off;
                %
            	figure(5),
				hold on;
				plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
				plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
				hold off;
%
% ---------- LH coefficient if applicable -----------
%
                figure(7),clf
                %
                y1 = log10(XDlh_cyl_ref/max(max(XDlh_cyl_ref)));
                cont = [-10.5:-0.5];
                %
                graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,NaN,cont,0,style2,NaN,width1,siz,red);
                graph1D_jd(x9,y9,0,0,xlab1,xlab2,'LH dif. coef. [\nu^{ref}(p_{Te}^{ref})^2]',NaN,xlim1,xlim2,style2,marker,color5,width1,siz);
                text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
                axis('equal');axis([xlim1,xlim2])
                bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,nhuloss,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap);
				hold on;
				plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
				plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
				hold off;
                %            
			    pause(time_pause);
                %
				if igor_mode == 1,
					eval(['save ',filenameroot,'_data_fig7_',int2str(ir_display_dke),'.mat xrho_dke xia r_dke ir_display_dke ppar_cyl_ref pperp_cyl_ref XDlh_cyl_ref xmhubounce2 pnmax_S'])
				end
			end
%
% ----------- EC coefficient if applicable -----------
%
			if nb_ec > 0 
                y3 = log10(XDec_cyl_ref/max(max(XDec_cyl_ref)));
                cont = [-2.2:0.4:-0.2];
                %
                figure(4),
                graph2D_jd(x1,x2,y3',xlab1,xlab2,'2D Distribution function f_0',xlim1,xlim2,0,NaN,cont,0,style1,color3,width2,siz);
                
                %
                figure(5),
                graph2D_jd(x1,x2,y3',xlab1,xlab2,'Stream function',xlim1,xlim2,0,NaN,cont,0,style1,color3,width2,siz);
                %
                figure(8),clf
                %
                cont = [-2.2:0.2:-0.2];
                graph2D_jd(x1,x2,y3','','','',xlim1,xlim2,0,NaN,cont,0,style2,NaN,width1,siz,red);
                graph1D_jd(x9,y9,0,0,xlab1,xlab2,'EC dif. coef. [\nu^{ref}(p_{Te}^{ref})^2]',NaN,xlim1,xlim2,style2,marker,color5,width1,siz);
                %y3 = log10(XDrf_X_ref/max(max(XDrf_X_ref)));
                %graph_cyl_jd(pn,mhu_X,y3','EC dif. coef. [\nu^{ref}(p_{Te}^{ref})^2]',xlim1,xlim2,NaN,cont,style2,NaN,width1,red);
                text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
                axis('equal');axis([xlim1,xlim2])
                bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,nhuloss,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap);
                %            
			    pause(time_pause);
                %
			    if igor_mode == 1,
				    eval(['save ',filenameroot,'_data_fig8_',int2str(ir_display_dke),'.mat xrho_dke xia r_dke ir_display_dke ppar_cyl_ref pperp_cyl_ref xmhubounce2 pnmax_S'])
			    end
			end
%
		end
%
% Current
%
		xcurr0_ref = Zcurr_ref{1,1};    
		xcurr_tp_ref = Zcurr_ref{1,2};    
		xcurr_g_ref = Zcurr_ref{1,3};  
		xcurr_bc_tp_ref = Zcurr_bc_ref{1,2};    
		xcurr_bc_g_ref = Zcurr_bc_ref{1,3};  
		xcurr_tot_ref = xcurr0_ref + xcurr_tp_ref + xcurr_g_ref;
        if syn_mode == 1,
    		xcurr_bc_ref = xcurr_bc_tp_ref + xcurr_bc_g_ref;
            xcurr_syn_ref = xcurr_tot_ref - xcurr0_ref - xcurr_bc_ref;
        else
    		xcurr_bc_ref = xcurr_tot_ref - xcurr0_ref;
        end
		if coll_mode == 3,
			xcurr_L_tp_ref = Zcurr_ref{1,4};    
			xcurr_L_g_ref = Zcurr_ref{1,5};  
			xcurr_L_tot_ref = xcurr0_ref + xcurr_L_tp_ref + xcurr_L_g_ref;
			xcurr_L_bc_ref = xcurr_L_tot_ref - xcurr0_ref;
		end		
%
% FSAV current
%
		xcurr0_ref_fsav = Zcurr_ref_fsav{1,1};    
		xcurr_tp_ref_fsav = Zcurr_ref_fsav{1,2};    
		xcurr_g_ref_fsav = Zcurr_ref_fsav{1,3};  
		xcurrB_ref_fsav = Zcurr_ref_fsav{2,1};%Bulk current in case of run-away electrons leaving the domain of integration
		xcurr_tot_ref_fsav = xcurr0_ref_fsav + xcurr_tp_ref_fsav + xcurr_g_ref_fsav;
        if syn_mode == 1,
    		xcurr_bc_ref_fsav = xcurr_bc_tp_ref_fsav + xcurr_bc_g_ref_fsav;
            xcurr_syn_ref_fsav = xcurr_tot_ref_fsav - xcurr0_ref_fsav - xcurr_bc_ref_fsav;
        else
    		xcurr_bc_ref_fsav = xcurr_tot_ref_fsav - xcurr0_ref_fsav;
        end
		if coll_mode == 3,
			xcurr_L_tp_ref_fsav = Zcurr_ref_fsav{1,4};    
			xcurr_L_g_ref_fsav = Zcurr_ref_fsav{1,5};  
			xcurr_L_tot_ref_fsav = xcurr0_ref_fsav + xcurr_L_tp_ref_fsav + xcurr_L_g_ref_fsav;
			xcurr_L_bc_ref_fsav = xcurr_L_tot_ref_fsav - xcurr0_ref_fsav;
		end
%    
% MKSA units
%
		xJrf0_mksa = xcurr0_ref*j_ref;
		xJrf_tot_mksa = xcurr_tot_ref*j_ref;
		xJbc_e_mksa = xcurr_bc_ref*j_ref;
        if syn_mode == 1,
            xJsyn_mksa = xcurr_syn_ref*j_ref;
        end
		if coll_mode == 3,
			xJbc_L_e_mksa = xcurr_L_bc_ref*j_ref;
		end
%    
		xJrf0_cyl_mksa = xcurr0_cyl_ref*j_ref;
%
% FSAV current
%
		xJrf0_fsav_mksa = xcurr0_ref_fsav*j_ref;
		xJrf_tot_fsav_mksa = xcurr_tot_ref_fsav*j_ref;
		xJrfB_fsav_mksa = xcurrB_ref_fsav*j_ref;
		xJbc_e_fsav_mksa = xcurr_bc_ref_fsav*j_ref;
		xJbc_i_fsav_mksa = xcurr_i_mksa_fsav;
        xJbc_tot_fsav_mksa = xJbc_e_fsav_mksa + xJbc_i_fsav_mksa;
		xJtot_fsav_mksa = xcurr_tot_ref_fsav*j_ref + xJbc_i_fsav_mksa;
        if syn_mode == 1,
            xJsyn_fsav_mksa = xcurr_syn_ref_fsav*j_ref;
        end
		if coll_mode == 3,
			xJbc_L_e_fsav_mksa = xcurr_L_bc_ref_fsav*j_ref;
			xJbc_L_tot_fsav_mksa = xJbc_L_e_fsav_mksa + xJbc_i_fsav_mksa;
			xJtot_L_fsav_mksa = xcurr_L_tot_ref_fsav*j_ref + xJbc_i_fsav_mksa;
		end
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
        if syn_mode == 1,
            xPelec_syn_ref_fsav = xPelec_tp_ref_fsav + xPelec_g_ref_fsav;
        end
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
            if syn_mode == 1,
                xyPabs_syn_ref_fsav = xyPabs_tp_ref_fsav + xyPabs_g_ref_fsav;
                xyPabs_syn_lh_ref_fsav = xyPabs_syn_ref_fsav(:,blist_lh);
                xyPabs_syn_ec_ref_fsav = xyPabs_syn_ref_fsav(:,blist_ec);
        		xPabs_syn_ref_fsav = integral_dke_jd(ones(1,nb),xyPabs_syn_ref_fsav,2)';
            end
		else
			xyPabs0_lh_ref_fsav = zeros(1,nr_dke);
			xyPabs0_ec_ref_fsav = zeros(1,nr_dke);
			xyPabs_tot_lh_ref_fsav = zeros(1,nr_dke);
			xyPabs_tot_ec_ref_fsav = zeros(1,nr_dke);
%
			xPabs0_ref_fsav = zeros(1,nr_dke);
			xPabs_tot_ref_fsav = zeros(1,nr_dke);
            if syn_mode == 1,
                xyPabs_syn_ref_fsav = zeros(1,nr_dke);
                xyPabs_syn_lh_ref_fsav = zeros(1,nr_dke);
                xyPabs_syn_ec_ref_fsav = zeros(1,nr_dke);
                xPabs_syn_ref_fsav = zeros(1,nr_dke);
            end
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
        if syn_mode == 1,
            xPelec_syn_fsav_mksa = xPelec_syn_ref_fsav*P_ref;
            xyPabs_syn_fsav_mksa = xyPabs_syn_ref_fsav*P_ref;
            xyPabs_syn_lh_fsav_mksa = xyPabs_syn_lh_ref_fsav*P_ref;
            xyPabs_syn_ec_fsav_mksa = xyPabs_syn_ec_ref_fsav*P_ref;
            xPabs_syn_fsav_mksa = xPabs_syn_ref_fsav*P_ref;
        end
%
% Efficiency (j/p)
%
		xeta0_ref_fsav = xcurr0_ref_fsav./(xPabs0_ref_fsav + eps);
%
		xeta0_fsav_mksa = xeta0_ref_fsav*j_ref/P_ref;	
        if syn_mode == 1,
            xeta_tot_ref_fsav = (xcurr0_ref_fsav + xcurr_syn_ref_fsav)./(xPabs0_ref_fsav + xPabs_syn_ref_fsav + eps);
		    xeta_tot_fsav_mksa = xeta_tot_ref_fsav*j_ref/P_ref;	
        end
%
		xepsi_fsav_mksa = xepsi_ref_fsav*Edreicer_ref;	
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
			disp(['   - RF current density (MA/m2) [spherical]: ',num2str(xJrf0_mksa(ir_display_dke)),', [cylindrical]: ',num2str(jxJrf0_cyl_mksa(ir_display_dke))])
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
			disp(['   - Runaway loss rate [spherical]: ',num2str(XxRR_ref_fsav(np-1,ir_display_dke))])
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
			disp(['   - Runaway loss rate [spherical] (m-3.s-1): ',num2str(XxRR_mksa_fsav(np-1,ir_display_dke))])
			disp(['   - Kruskal-Berstein runaway rate (Z = 1) [spherical] (m-3.s-1): ',num2str(xRR_KB_fsav(ir_display_dke)*nhu_ref*ne_ref)])
			disp(['   - Bulk current (MA/m2) [spherical]: ',num2str(xJrfB_fsav_mksa(ir_display_dke))])
		else
			[Xf0_g_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(Xf0_g_ref,pn_ref,mhu,dp_cyl);
			Xf0_g_cyl_ref = Xf0_g_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
			Xf0_g_cyl_ref(isnan(Xf0_g_cyl_ref)) = 0;%Remove NaN values
%			                                                              
			[Xf0_tp_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(Xf0_tp_ref,pn_ref,mhu,dp_cyl);
			Xf0_tp_cyl_ref = Xf0_tp_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
			Xf0_tp_cyl_ref(isnan(Xf0_tp_cyl_ref)) = 0;%Remove NaN values
%
			Xf0_tpg_cyl_ref = Xf0_g_cyl_ref + Xf0_tp_cyl_ref;
			Fpar1_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_tpg_cyl_ref,1);
			Xf0_tot_cyl_ref = Xf0_cyl_ref + Xf0_g_cyl_ref + Xf0_tp_cyl_ref;
			xcurr_tot_cyl_ref(ir_display_dke) = 2*pi*integral_dke_jd(dpperp_cyl_ref,pperp_cyl_ref'.*integral_dke_jd(ppar_cyl_ref,Xvpar_cyl_ref.*Xf0_tot_cyl_ref,2),1);  
%	
            if syn_mode == 1,
    			[Xf0_bc_g_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(Xf0_bc_g_ref,pn_ref,mhu,dp_cyl);
    			Xf0_bc_g_cyl_ref = Xf0_bc_g_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
    			Xf0_bc_g_cyl_ref(isnan(Xf0_bc_g_cyl_ref)) = 0;%Remove NaN values
%			                                                              
    			[Xf0_bc_tp_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(Xf0_bc_tp_ref,pn_ref,mhu,dp_cyl);
    			Xf0_bc_tp_cyl_ref = Xf0_bc_tp_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
    			Xf0_bc_tp_cyl_ref(isnan(Xf0_bc_tp_cyl_ref)) = 0;%Remove NaN values
%
    			Xf0_bc_tpg_cyl_ref = Xf0_bc_g_cyl_ref + Xf0_bc_tp_cyl_ref;
    			Fpar1_bc_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_bc_tpg_cyl_ref,1);
%
                Xf0_syn_cyl_ref = Xf0_bc_tpg_cyl_ref - Xf0_tpg_cyl_ref;
    			Fpar1_syn_cyl_ref = Fpar1_cyl_ref - Fpar1_bc_cyl_ref;
    			xcurr_bc_cyl_ref(ir_display_dke) = 2*pi*integral_dke_jd(dpperp_cyl_ref,pperp_cyl_ref'.*integral_dke_jd(ppar_cyl_ref,Xvpar_cyl_ref.*Xf0_bc_tpg_cyl_ref,2),1);  
			    xcurr_syn_cyl_ref = xcurr_tot_cyl_ref - xcurr0_cyl_ref - xcurr_bc_cyl_ref;
            else
			    xcurr_bc_cyl_ref = xcurr_tot_cyl_ref - xcurr0_cyl_ref;
            end                
			if coll_mode == 3,%Lorentz model
				[Xf0_L_g_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(Xf0_L_g_ref,pn_ref,mhu,dp_cyl);
				Xf0_L_g_cyl_ref = Xf0_L_g_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
				Xf0_L_g_cyl_ref(isnan(Xf0_L_g_cyl_ref)) = 0;%Remove NaN values
%
				[Xf0_L_tp_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(Xf0_L_tp_ref,pn_ref,mhu,dp_cyl);
				Xf0_L_tp_cyl_ref = Xf0_L_tp_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
				Xf0_L_tp_cyl_ref(isnan(Xf0_L_tp_cyl_ref)) = 0;%Remove NaN values
%
				Xf0_L_tpg_cyl_ref = Xf0_L_g_cyl_ref + Xf0_L_tp_cyl_ref;	
				Fpar1_L_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_L_tpg_cyl_ref,1);
				Xf0_tot_L_cyl_ref = Xf0_cyl_ref + Xf0_L_g_cyl_ref + Xf0_L_tp_cyl_ref;
				xcurr_tot_L_cyl_ref(ir_display_dke) = 2*pi*integral_dke_jd(dpperp_cyl_ref,pperp_cyl_ref'.*integral_dke_jd(ppar_cyl_ref,Xvpar_cyl_ref.*Xf0_tot_L_cyl_ref,2),1);  
			end	
%
% MKSA units
%
		    xJrf_tot_cyl_mksa = xcurr_tot_cyl_ref*j_ref;
    		xJbc_e_cyl_mksa = xcurr_bc_cyl_ref*j_ref;
            if syn_mode == 1,
                xJsyn_cyl_mksa = xcurr_syn_cyl_ref*j_ref;
            end
%   
			if display_mode >= 2, 
%
% ---------- DKE parallel distribution -----------
%
				figure(9);clf
                %
                y1 = Fpar1_cyl_ref;
                ylab = 'F_{1//}';
                ylim = NaN;
                %
                graph1D_jd(x1,y1,0,0,xlab1,ylab,'',NaN,xlim1,ylim,style3,marker1,color2,width2,siz,gca,red,lspace,bspace1);
                %
				if coll_mode == 3,%Lorentz model
                    y2 = Fpar1_L_cyl_ref;
                    leg = ['code  ';'theory'];
                    graph1D_jd(x1,y2,0,0,xlab1,ylab,'',leg,xlim1,ylim,style2,marker,color1,width1,siz);
				end
                if syn_mode == 1,
                    y2 = Fpar1_bc_cyl_ref;
                    leg = ['BC+RF+E';'BC Only'];
                    graph1D_jd(x1,y2,0,0,xlab1,ylab,'',leg,xlim1,ylim,style2,marker,color1,width1,siz);
                end                    
                text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
                %
				pause(time_pause);
%
% ---------- Synergistic parallel distribution -----------
%
                if syn_mode == 1,
    				figure(15);clf
                %
                    y1 = Fpar1_syn_cyl_ref;
                    ylab = 'F_{1//}';
                    ylim = NaN;
                %
                    graph1D_jd(x1,y1,0,0,xlab1,ylab,'Synergistic Parallel Distribution',NaN,xlim1,ylim,style3,marker1,color2,width2,siz,gca,red,lspace,bspace1);
                    text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
                %
		    		pause(time_pause);
                end
%
% ---------- DKE distribution at p=4  -----------
%
				ipnplot_ref = min(find(pn_ref>=4));
				figure(10);clf
                %
                y1 = Xf0_tp_ref(ipnplot_ref,:);
                y2 = Xf0_g_ref(ipnplot_ref,:);
                ylab = 'f_1';
                ylim = NaN;
                %
                graph1D_jd(mhu,y1,0,0,'','','',NaN,[-1,1],ylim,style3,marker1,color1,width2,siz,gca,red,lspace,bspace1);
                graph1D_jd(mhu,y2,0,0,xlab1,ylab,'',NaN,[-1,1],ylim,style3,marker2,color2,width2,siz);
                %
				if coll_mode == 3,%Lorentz model
                    y3 = Xf0_L_tp_ref(ipnplot_ref,:);
                    y4 = Xf0_L_g_ref(ipnplot_ref,:);
                    leg = ['f_{tp} (code)  ';'g (code)       ';'f_{tp} (theory)';'g (theory)     '];
                    graph1D_jd(mhu,y3,0,0,'','','',NaN,[-1,1],ylim,style1,marker,color1,width1,siz);
                    graph1D_jd(mhu,y4,0,0,xlab1,ylab,'',leg,[-1,1],ylim,style2,marker,color2,width1,siz);
                elseif syn_mode == 1,
                    y3 = Xf0_bc_tp_ref(ipnplot_ref,:);
                    y4 = Xf0_bc_g_ref(ipnplot_ref,:);
                    leg = ['f_{tp} (BC+RF+E)  ';'g (BC+RF+E)       ';'f_{tp} (BC Only)';'g (BC Only)     '];
                    graph1D_jd(mhu,y3,0,0,'','','',NaN,[-1,1],ylim,style1,marker,color1,width1,siz);
                    graph1D_jd(mhu,y4,0,0,xlab1,ylab,'',leg,[-1,1],ylim,style2,marker,color2,width1,siz);
                else
                    leg = ['f_{tp}';'g     '];
                    legend(leg,'fontsize',14)
				end
                ylim = get(gca,'ylim');
				line([mhu0T,mhu0T],ylim,'color','k');
				line([-mhu0T,-mhu0T],ylim,'color','k');
                text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
                ipnstr = num2str(pn_ref(ipnplot_ref));
                ipnstr = ipnstr(1:min([5,length(ipnstr)]));
                text(0.05,0.85,['p^{ref}/p_{te} = ',ipnstr],'units','normalized');
                %
				pause(time_pause);
%
% ---------- 2D distribution ftp -----------
%
                figure(11),clf
                %
                y1 = log10(abs(Xf0_tp_cyl_ref));
                cont = [-14.5:14.5];
                %
                graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,NaN,cont,0,style2,NaN,width1,siz,red);
                graph1D_jd(x9,y9,0,0,xlab1,xlab2,'2D Distribution function f_{tp}',NaN,xlim1,xlim2,style2,marker,color5,width1,siz);
                text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
                axis('equal');axis([xlim1,xlim2])
                bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,nhuloss,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap);
%                
			    if nb_lh > 0 & xvparmax_lh_ref(ir_display) - xvparmin_lh_ref(ir_display) ~= 0  & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,
    				hold on;
    				plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
    				plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
    				hold off;
                end
			    if nb_ec > 0 
                    y3 = XDec_cyl_ref;
                    graph2D_jd(x1,x2,y3',xlab1,xlab2,'2D Distribution function f_{tp}',xlim1,xlim2,0,NaN,4,0,style1,color3,width2,siz);
                end
%
                pause(time_pause);
%
% ---------- 2D distribution g -----------
%
                figure(12),clf
                %
                y1 = log10(abs(Xf0_g_cyl_ref));
                cont = [-14.5:14.5];
                %
                graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,NaN,cont,0,style2,NaN,width1,siz,red);
                graph1D_jd(x9,y9,0,0,xlab1,xlab2,'2D Distribution function g',NaN,xlim1,xlim2,style2,marker,color5,width1,siz);
                text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
                axis('equal');axis([xlim1,xlim2])
                bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,nhuloss,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap);
%                
			    if nb_lh > 0 & xvparmax_lh_ref(ir_display) - xvparmin_lh_ref(ir_display) ~= 0  & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,
    				hold on;
    				plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
    				plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
    				hold off;
                end
			    if nb_ec > 0 
                    y3 = XDec_cyl_ref;
                    graph2D_jd(x1,x2,y3',xlab1,xlab2,'2D Distribution function g',xlim1,xlim2,0,NaN,4,0,style1,color3,width2,siz);
                end
%
                pause(time_pause);
%
% ---------- 2D distribution f1 -----------
%
                figure(13),clf
                %
                y1 = log10(abs(Xf0_tpg_cyl_ref/max(max(abs(Xf0_tpg_cyl_ref)))));
                cont = [-10.5:-0.5];
                %
                graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,NaN,cont,0,style2,color2,width2,siz,red);
                if syn_mode == 1,
                    y2 = log10(abs(Xf0_bc_tpg_cyl_ref/max(max(abs(Xf0_tpg_cyl_ref)))));
                    graph2D_jd(x1,x2,y2','','','',xlim1,xlim2,0,NaN,cont,0,style2,color1,width1,siz,red);
                end
                %    
                graph1D_jd(x9,y9,0,0,xlab1,xlab2,'2D Distribution function f_1',NaN,xlim1,xlim2,style2,marker,color5,width1,siz);
                text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
                axis('equal');axis([xlim1,xlim2])
                bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,nhuloss,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap);
%                
			    if nb_lh > 0 & xvparmax_lh_ref(ir_display) - xvparmin_lh_ref(ir_display) ~= 0  & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,
    				hold on;
    				plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
    				plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
    				hold off;
                end
			    if nb_ec > 0 
                    y3 = XDec_cyl_ref;
                    graph2D_jd(x1,x2,y3',xlab1,xlab2,'2D Distribution function g',xlim1,xlim2,0,NaN,4,0,style1,color3,width2,siz);
                end
%
                pause(time_pause);
%
% ---------- 2D total distribution f0 + ftp + g -----------
%
                figure(14),clf
                %
                y1 = Xf0_cyl_ref + Xf0_tp_cyl_ref + Xf0_g_cyl_ref;
                %
                graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,style2,NaN,width1,siz,red,max(max(y1)));
                graph1D_jd(x9,y9,0,0,xlab1,xlab2,'2D total distribution function f_0 + f_1',NaN,xlim1,xlim2,style2,marker,color5,width1,siz);
                text(0.05,0.95,['\rho = ',rhostr],'units','normalized');
                axis('equal');axis([xlim1,xlim2])
                bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,nhuloss,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap);
%                
			    if nb_lh > 0 & xvparmax_lh_ref(ir_display) - xvparmin_lh_ref(ir_display) ~= 0  & isnan(xvparmin_lh_ref(ir_display)) == 0 & isnan(xvparmax_lh_ref(ir_display)) == 0,
    				hold on;
    				plot(pparresmin_lh_cyl_ref,pperp_cyl_ref,'k--');
    				plot(pparresmax_lh_cyl_ref,pperp_cyl_ref,'k--');
    				hold off;
                end
			    if nb_ec > 0 
                    y3 = XDec_cyl_ref;
                    graph2D_jd(x1,x2,y3',xlab1,xlab2,'2D total distribution function f_0 + f_1',xlim1,xlim2,0,NaN,4,0,style1,color3,width2,siz);
                end
%
                pause(time_pause);
%
			end
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global results (normalized to reference units) at Bmin [theta_pol = 0 (deg)]:');
			disp(['   - Density [spherical]: ',num2str(xnormf_ref(ir_display_dke)),', [cylindrical]: ',num2str(xnormf_cyl_ref(ir_display_dke))])
			disp(['   - RF only current density [spherical]: ',num2str(xcurr0_ref(ir_display_dke)),', [cylindrical]: ',num2str(xcurr0_cyl_ref(ir_display_dke))])
			disp(['   - Electron bootstrap current density [spherical]: ',num2str(xcurr_bc_ref(ir_display_dke)),', [cylindrical]: ',num2str(xxcurr_bc_cyl_ref(ir_display_dke))])
			disp(['   - Total electron current density [spherical]: ',num2str(xcurr_tot_ref(ir_display_dke)),', [cylindrical]: ',num2str(xcurr_tot_cyl_ref(ir_display_dke))])
            if syn_mode == 1,
                disp(['   - Synergistic electron current density [spherical]: ',num2str(xcurr_syn_ref(ir_display_dke)),', [cylindrical]: ',num2str(xcurr_syn_cyl_ref(ir_display_dke))])
            end
			disp(['   - Ohmic eletric field: ',num2str(xepsi_ref(ir_display_dke))])
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global results (normalized to MKSA units) at Bmin [theta_pol = 0 (deg)]:');
			disp(['   - Density (10+19 m-3) [spherical]: ',num2str(xnormf_ref(ir_display_dke)*ne_ref/1e19),', [cylindrical]: ',num2str(xnormf_cyl_ref(ir_display_dke)*ne_ref/1e19)])
			disp(['   - RF only current density (MA/m2) [spherical]: ',num2str(xJrf0_mksa(ir_display_dke)),', [cylindrical]: ',num2str(xJrf0_cyl_mksa(ir_display_dke))])
			disp(['   - Electron bootstrap current density (MA/m2) [spherical]: ',...
			num2str(xJbc_e_mksa(ir_display_dke)),', [cylindrical]: ',num2str(xJbc_e_cyl_mksa(ir_display_dke))])
			disp(['   - Total electron current density (MA/m2) [spherical]: ',num2str(xJrf_tot_mksa(ir_display_dke)),', [cylindrical]: ',num2str(xJrf_tot_cyl_mksa(ir_display_dke))])
            if syn_mode == 1,
                disp(['   - Synergistic electron current density (MA/m2) [spherical]: ',num2str(xJsyn_mksa(ir_display_dke)),', [cylindrical]: ',num2str(xJsyn_cyl_mksa(ir_display_dke))])
            end
			disp(['   - Ohmic eletric field (V/m): ',num2str(xepsi_ref(ir_display_dke)*Edreicer_ref)])
%

			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global flux surface averaged results (normalized to reference units):');
			disp(['   - Density: [spherical]: ',num2str(xnormf_ref_fsav(ir_display_dke))])
			disp(['   - RF only current density: [spherical]: ',num2str(xcurr0_ref_fsav(ir_display_dke))])
			disp(['   - Electron Bootstrap current density: [spherical]: ',num2str(xcurr_bc_ref_fsav(ir_display_dke))])
			if coll_mode == 3,
				disp(['   - Lorentz model for electron bootstrap: ',num2str(xcurr_L_bc_ref_fsav(ir_display_dke))]);
			end
			disp(['   - Total electron current density: [spherical]: ',num2str(xcurr_tot_ref_fsav(ir_display_dke))])
			disp(['   - Ion bootstrap current density: ',num2str(xcurr_i_mksa_fsav(ir_display_dke)/j_ref)])
			disp(['   - Total bootstrap current density [spherical]: ',num2str(xcurr_bc_ref(ir_display_dke) + xcurr_i_mksa_fsav(ir_display_dke)/j_ref)]);
			disp(['   - Hirshman model for bootstrap: ',num2str(xcurr_hir_mksa_fsav(ir_display_dke)/j_ref)])        
			disp(['   - Sauter model for bootstrap: ',num2str(xcurr_sau_mksa_fsav(ir_display_dke)/j_ref)])        
			disp(['   - Hinton & Hazeltine model for bootstrap: ',num2str(xcurr_hin_mksa_fsav(ir_display_dke)/j_ref)])  				
			disp(['   - Total current density [spherical]: ',num2str(xcurr_tot_ref_fsav(ir_display_dke) + xcurr_i_mksa_fsav(ir_display_dke)/j_ref)]);
            if syn_mode == 1,
                disp(['   - Synergistic electron current density [spherical]: ',num2str(xcurr_syn_ref_fsav(ir_display_dke))])
            end
			disp(['   - RF power density lost on collisions (coll) [spherical]: ',num2str(-xPcoll0_ref_fsav(ir_display_dke))])
%
			for ib=1:nb_lh,
				disp(['   - LH beam #',num2str(ib),': v1 = ',num2str(1/waveparam_lh(ir_display_dke,ib,7)/betath_ref),', v2 = ',num2str(1/waveparam_lh(ir_display_dke,ib,6)/betath_ref),',D0lh = ',num2str(waveparam_lh(ir_display_dke,ib,5))])
				disp(['        LH Power absorbed [spherical]: ',num2str(xyPabs0_lh_ref_fsav(ir_display_dke,ib))]) 
                if syn_mode == 1,
    				disp(['        Synergistic LH Power absorbed [spherical]: ',num2str(xyPabs_syn_lh_ref_fsav(ir_display_dke,ib))]) 
                end    
			end
%	
			for ib=1:nb_ec,
				disp(['   - EC beam #',num2str(ib),': n// = ',num2str(waveparam_ec(ir_display_dke,ib,8)),...
				', Y = ',num2str(waveparam_ec(ir_display_dke,ib,1)*waveparam_ec(ir_display_dke,ib,3)/waveparam_ec(ir_display_dke,ib,2)),',D0ec = ',num2str(waveparam_ec(ir_display_dke,ib,5))])
					disp(['        EC Power absorbed [spherical]: ',num2str(xyPabs0_ec_ref_fsav(ir_display_dke,ib))]) 
                if syn_mode == 1,
    				disp(['        Synergistic EC Power absorbed [spherical]: ',num2str(xyPabs_syn_ec_ref_fsav(ir_display_dke,ib))]) 
                end    
			end
%
			if nb > 0,
				disp(['   - RF only current drive efficiency [spherical]: ',num2str(xeta0_ref_fsav(ir_display_dke))])
                if syn_mode == 1,
				    disp(['   - RF + Synergistic current drive efficiency [spherical]: ',num2str(xeta_tot_ref_fsav(ir_display_dke))])
                end    
			end
			disp(['   - Ohmic eletric field: ',num2str(xepsi_ref_fsav(ir_display_dke))])
			disp(['   - Runaway loss rate [spherical]: ',num2str(XxRR_ref_fsav(np-1,ir_display_dke))])
			disp(['   - Bulk current [spherical]: ',num2str(xcurrB_ref_fsav(ir_display_dke))])
%
			disp('-------------------------------------------------------------------------------------------------------------------');
			info_dke_yp(2,'Global flux surface averaged results (normalized to MKSA units):');
			disp(['   - Density (10+19 m-3) [spherical]: ',num2str(xnormf_ref_fsav(ir_display_dke)*ne_ref/1e19)])
			disp(['   - RF only current density (MA/m2) [spherical]: ',num2str(xJrf0_fsav_mksa(ir_display_dke))])
			disp(['   - Electron bootstrap current density (MA/m2) [spherical]: ',num2str(xJbc_e_fsav_mksa(ir_display_dke))])
			if coll_mode == 3,
				disp(['   - Lorentz model for electron bootstrap: ',num2str(xJbc_L_e_fsav_mksa(ir_display_dke))]);
			end
			disp(['   - Total electron current density (MA/m2) [spherical]: ',num2str(xJrf_tot_fsav_mksa(ir_display_dke))])
			disp(['   - Ion bootstrap current density (MA/m2): ',num2str(xJbc_i_fsav_mksa(ir_display_dke))])
			disp(['   - Total bootstrap current density (MA/m2) [spherical]: ',num2str(xJbc_tot_fsav_mksa(ir_display_dke))])        
			disp(['   - Hirshman model for bootstrap (MA/m2): ',num2str(xcurr_hir_mksa_fsav(ir_display_dke))])        
			disp(['   - Sauter model for bootstrap (MA/m2): ',num2str(xcurr_sau_mksa_fsav(ir_display_dke))])  
			disp(['   - Hinton & Hazeltine model for bootstrap (MA/m2): ',num2str(xcurr_hin_mksa_fsav(ir_display_dke))])        
			disp(['   - Total current density (MA/m2) [spherical]: ',num2str(xJtot_fsav_mksa(ir_display_dke))])
            if syn_mode == 1,
                disp(['   - Synergistic electron current density (MA/m2) [spherical]: ',num2str(xcurr_syn_fsav_mksa(ir_display_dke))])
            end
			disp(['   - RF power density lost on collisions (MW/m3) (coll) [spherical]: ',num2str(-xPcoll0_fsav_mksa(ir_display_dke))])
%
			for ib=1:nb_lh,
				disp(['   - LH beam #',num2str(ib),': v1 = ',num2str(1/waveparam_lh(ir_display_dke,ib,7)/betath_ref),', v2 = ',num2str(1/waveparam_lh(ir_display_dke,ib,6)/betath_ref),',D0lh = ',num2str(waveparam_lh(ir_display_dke,ib,5))])
				disp(['        LH Power absorbed (MW/m3) [spherical]: ',num2str(xyPabs0_lh_fsav_mksa(ir_display_dke,ib))]) 
                if syn_mode == 1,
    				disp(['        Synergistic LH Power absorbed (MW/m3) [spherical]: ',num2str(xyPabs_syn_lh_fsav_mksa(ir_display_dke,ib))]) 
                end    
			end
%
			for ib=1:nb_ec,
				disp(['   - EC beam #',num2str(ib),': n// = ',num2str(waveparam_ec(ir_display_dke,ib,8)),...
					', Y = ',num2str(waveparam_ec(ir_display_dke,ib,1)*waveparam_ec(ir_display_dke,ib,3)/waveparam_ec(ir_display_dke,ib,2)),',D0ec = ',num2str(waveparam_ec(ir_display_dke,ib,5))])
				disp(['        EC Power absorbed (MW/m3) [spherical]: ',num2str(xyPabs0_ec_fsav_mksa(ir_display_dke,ib))]) 
                if syn_mode == 1,
    				disp(['        Synergistic EC Power absorbed (MW/m3) [spherical]: ',num2str(xyPabs_syn_ec_fsav_mksa(ir_display_dke,ib))]) 
                end    
			end
%
			if nb > 0,
				disp(['   - RF current drive efficiency (A.m/W) [spherical]: ',num2str(xeta0_fsav_mksa(ir_display_dke))])
                if syn_mode == 1,
				    disp(['   - RF + Synergistic current drive efficiency (A.m/W) [spherical]: ',num2str(xeta_tot_fsav_mksa(ir_display_dke))])
                end    
			end
			disp(['   - Ohmic eletric field (V/m): ',num2str(xepsi_fsav_mksa(ir_display_dke))])
			disp(['   - Runaway loss rate [spherical] (m-3.s-1): ',num2str(XxRR_mksa_fsav(np-1,ir_display_dke))])
			disp(['   - Bulk current (MA/m2) [spherical]: ',num2str(xJrfB_fsav_mksa(ir_display_dke))])
%
		end
	end
%
	if display_mode == 2,
%
        xlim = [0,1];
        xlab = '\rho';
        style4 = '-.';
        marker3 = '*';
        marker4 = 'o';
%        
	    figure(253),clf
		[ax] = graph1D_jd(xrho_dke,xne(r_dke)./(xnormf_ref_fsav*ne_ref),0,0,xlab,'<ne>_{in}/<ne>_{out}','Electron density conservation',NaN,xlim,[0.5,1.5],style3,marker1,color2,width2,siz,gca,red,lspace,bspace2);		 
% 
        figure(200),clf
        [ax] = graph1D_jd(xrho_dke,xJrf0_fsav_mksa,0,0,xlab,'<J_{RF}> (MA/m^2)','RF + Ohmic Current Density',NaN,xlim,NaN,style3,marker2,color2,width2,siz,gca,red,lspace,bspace2);
%
        figure(203),clf
        [ax] = graph1D_jd(xrho_dke,-xPcoll_tot_fsav_mksa,0,0,'','','',NaN,xlim,NaN,style3,marker3,color2,width2,siz,gca,red,lspace,bspace2);
        [ax] = graph1D_jd(xrho_dke,xPelec_tot_fsav_mksa,0,0,'','','',NaN,xlim,NaN,style3,marker2,color3,width2,siz);
        [ax] = graph1D_jd(xrho_dke,xPabs_tot_fsav_mksa,0,0,xlab,'<P_{abs}> (MW/m^3)','Density of Absorbed Power',['Collisions';'Ohmic     ';'RF Waves  '],xlim,0,style3,marker1,color1,width2,siz);
%
        figure(204),clf
        [ax] = graph1D_jd(xrho_dke,XxRR_mksa_fsav(np-1,ir_display_dke),0,0,xlab,'<\Gamma_{R}> (m^-3.s^-1)','Runaway loss rate',NaN,xlim,0,style3,marker2,color2,width2,siz,gca,red,lspace,bspace2);
%
		if dke_mode == 1,  
%
            figure(201),clf
            [ax] = graph1D_jd(xrho_dke,xJbc_tot_fsav_mksa,0,0,'','','',NaN,xlim,NaN,style3,marker2,color2,width2,siz,gca,red,lspace,bspace2);
            [ax] = graph1D_jd(prho,pcurr_hin_mksa_fsav,0,0,'','','',NaN,xlim,NaN,style1,marker,color3,width2,siz);
            [ax] = graph1D_jd(prho,pcurr_hir_mksa_fsav,0,0,'','','',NaN,xlim,NaN,style4,marker,color1,width2,siz);
            [ax] = graph1D_jd(prho,pcurr_sau_mksa_fsav,0,0,xlab,'<J_B> (MA/m^2)',['Bootstrap current in ',tokname],['DKE code';'Hinton  ';'Hirshman';'Sauter  '],xlim,0,style2,marker,color4,width2,siz);
%
            figure(202),clf
            [ax] = graph1D_jd(xrho_dke,xJrf0_fsav_mksa,0,0,xlab,'','',NaN,xlim,0,style3,marker1,color1,width2,siz,gca,red,lspace,bspace2);
            [ax] = graph1D_jd(xrho_dke,xJbc_tot_fsav_mksa,0,0,xlab,'','',NaN,xlim,0,style3,marker2,color2,width2,siz);
            if syn_mode == 1,
                leg = ['RF + Ohmic ';'Bootstrap  ';'Synergistic';'Total      '];
                [ax] = graph1D_jd(xrho_dke,xJsyn_fsav_mksa,0,0,xlab,'','',NaN,xlim,0,style3,marker3,color3,width2,siz);
            else
                leg = ['RF + Ohmic';'Bootstrap ';'Total     '];
            end
            [ax] = graph1D_jd(xrho_dke,xJtot_fsav_mksa,0,0,xlab,'<J> (MA/m^2)','Total Current Density',leg,xlim,0,style3,marker4,color4,width2,siz);
%
			figure(205),clf
			[ax] = graph1D_jd(xrho_dke,xfteff_fsav,0,0,'','','',NaN,xlim,[0,1],style3,marker4,color2,width2,siz,gca,red,lspace,bspace2);
			hold on
            if ~isnan(xftra)
                leg = ['DKE code';'HELENA  '];
%				[ax] = graph1D_jd(xrho_dke,xfteff_llm,0,0,xlab,'','Effective trapped fraction',NaN,xlim,[0,1],'none','x','g',2,14);
				[ax] = graph1D_jd(xrho_dke,xftra,0,0,xlab,'f_t','Effective trapped fraction',leg,xlim,[0,1],style3,marker2,color1,width2,siz);				
            else,%In case of ideal magnetic equilibrium only
                leg = ['DKE code';'Lin-Liu '];
				[ax] = graph1D_jd(xrho_dke,xfteff_llm,0,0,xlab,'f_t','Effective trapped fraction',leg,xlim,[0,1],style3,marker2,color1,width2,siz);
			end
			if coll_mode== 3
                leg = [leg;'L31     '];
				[ax] = graph1D_jd(prho,L31,0,0,xlab,'ft-eff (DKE: o, L31: .)','Effective trapped fraction',leg,xlim,[0,1],style3,marker1,color3,width2,siz);
			end
%
			figure(206),clf
			[ax] = graph1D_jd(xrho_dke,xft_fsav,0,0,xlab,'ft-exact','Exact trapped fraction (DKE)',NaN,xlim,[0,1],style3,marker4,color2,width2,siz,gca,red,lspace,bspace2);    
        end
%      
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
	if auto_mode_in == 1, break, end	
end
%
if auto_mode_in == 0 & nr > 1,
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
		figure(h_figure),clf
        
		tit = ['Electron kinetic energy: ',num2str(Ec_r_ref_out),' (keV), threshold: ',num2str(xEc_r_ref_threshold(1)),' (keV)'];
        graph1D_jd(xrho_dke,prof_r_Fpar_ref,0,0,xlab,'F_{//}',tit,NaN,xlim,NaN,style2,marker1,color1,width1,siz,gca,red,lspace,bspace2);
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
%--------------------------------------------------------------------------
%
function bounce_ripple_jd(bounce_mode,pnmax_S,xmhubounce2,ir_display,nhuloss,pparsupertrap_ref,pperpsupertrap_ref,xpndetrap_ref,xmhusupertrap)
%
% Draws the bounce and ripple loss domains
%
if bounce_mode >= 1,%Draw bounce domain boundaries
    line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))],'color','k');
    line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))],'color','k');
    if isnan(nhuloss) == 0,%Draw the magnetic ripple loss cone
    	hold on,plot(pparsupertrap_ref,pperpsupertrap_ref,'r'),hold off
    	line([xpndetrap_ref(ir_display)*xmhusupertrap(ir_display),pnmax_S*xmhusupertrap(ir_display)],[xpndetrap_ref(ir_display)*sqrt(1-xmhusupertrap(ir_display)^2),pnmax_S*sqrt(1-xmhusupertrap(ir_display)^2)],'LineStyle','-','color','r');
    	line([-xpndetrap_ref(ir_display)*xmhusupertrap(ir_display),-pnmax_S*xmhusupertrap(ir_display)],[xpndetrap_ref(ir_display)*sqrt(1-xmhusupertrap(ir_display)^2),pnmax_S*sqrt(1-xmhusupertrap(ir_display)^2)],'LineStyle','-','color','r');					
    end
end
%
%--------------------------------------------------------------------------
%


