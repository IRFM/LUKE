function [] = display_time_dke_1yp(filename,auto_mode_in,igor_mode)
%
% Display time evolution of the distribution function calculated by the Electron Drift Kinetic solver (test_dke_1yp.m)
%
%by Yves Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker RLE/MIT <jodecker@mit.edu>
%
%
warning off;
[s,dossier,machine] = comput_dke_yp;
if nargin == 0,	
	eval(['dir TIME_*.mat']);
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
eval(['load ',dossier,s,filename]);%Load time dependent DKE output data
eval(['load ',dossier,s,'RESULTS',filename(5:end)]);%Load DKE output data
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
disp('Display time evolution of the electron distribution function (see test_dke_1yp.m)');
disp('-------------------------------------------------------------------------------------------------------------------');
%
[xq,xqtilde,xqbar,xqhat] = qfactors_dke_yp(Rp,Zp,XR(r_dke,:),XZ(r_dke,:),XBR(r_dke,:),XBZ(r_dke,:),XBphi(r_dke,:));%q factors calculations at radial positions at which bootstrap current is calculated are used
%
xnormf_ref = Znorm_ref{1,1};
xnormf_ref_fsav = Znorm_ref_fsav{1,1};
%
xrho_dke = xrho(r_dke);%Only radial positions at which bootstrap current is calculated are used
xia = xrho_dke*ap/Rp;%Pseudo inverse aspect ratio (has a meaning only for circular plasma equilibrium)
%
j_ref = qe*clum*betath_ref*ne_ref/1e6;%MKSA current unit
%
if bounce_mode > 0,
	xnhu_e_star = 0.012*(xne(r_dke)/1e20).*xZeff(r_dke).*xq*Rp./xia.^1.5./xTe(r_dke).^2;%From O. Sauter et al., Phys. Plasma 6 (1999) 2834
else
	xnhu_e_star = NaN*ones(size(xia));
end
%
nt_dke = length(ZXXf0);
%
ir_display_dke = find(r_dke == ir_display);
ir_display_mov = -1;
%
while 1,
	if auto_mode_in == 0,
		disp(' ')
		disp('**************************************************************************')
		ir_display_dke = input_dke_yp(['*********************************** Radial index value (1-',int2str(nr_dke),') (exit: <=0)'],ir_display_dke);
		it_display_dke = input_dke_yp(['*********************************** Time index value (1-',int2str(nt_dke),') (exit: <=0)'],1);
		makemovie = input_dke_yp('*********************************** Make movie of the distribution build-up (yes : 1, no: 0)',0);
		disp('**************************************************************************')
		disp(' ')
		if ir_display_dke < 1 | it_display_dke < 1,break;end
		if ir_display_dke > nr_dke,ir_display_dke = nr_dke;end
		if it_display_dke > nt_dke,it_display_dke = nt_dke;end
	end
%
	ir_display = r_dke(ir_display_dke);
%
	if display_mode >=1,
%
		
		Xf0_ref = ZXXf0{it_display_dke}(:,:,ir_display);%Display results at the required radial  and time values
		Xfinit_ref = XXfinit_ref(:,:,ir_display);%Display results at the required radial value
%
		disp('-------------------------------------------------------------------------------------------------------------------');
		disp('-------------------------------------------------------------------------------------------------------------------');
		disp('-------------------------------------------- Calculation output ---------------------------------------------------')
		disp('-------------------------------------------------------------------------------------------------------------------');
		info_dke_yp(2,['Reference electron temperature (keV): ',num2str(Ten_ref*mc2)])
		info_dke_yp(2,['Reference electron density (10+19 m-3): ',num2str(ne_ref/1e19)])
		info_dke_yp(2,['Reference Coulomb logarithm: ',num2str(lnc_e_ref)])
		info_dke_yp(2,['Reference electron collision frequency (kHz): ',num2str(nhu_ref/1000)])
%
		info_dke_yp(2,['MKSA current unit (j_ref): ',num2str(j_ref),' (MA/m2)'])
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
			info_dke_yp(2,['Collisionality parameter: ',num2str(xnhu_e_star(ir_display_dke))])
		end
		disp('-------------------------------------------------------------------------------------------------------------------');
%
		figure(8000),subplot(121),plot([0:nt_dke-1]*abs(dtn),curr0(ir_display_dke,1:nt_dke)*j_ref,'rx',(it_display_dke-1)*abs(dtn),curr0(ir_display_dke,it_display_dke)*j_ref,'ro');
		xlabel('Time (a.u.)')
		ylabel('J at B=Bmin (MA/m2)')
		title('Plasma current')
		axis([0 nt_dke*abs(dtn) 0 1.1*max(curr0(ir_display_dke,:))*j_ref]);
		faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
		text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
		text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*12,['t = ',num2str((it_display_dke-1)*abs(dtn))]);
%
		axis('square')
		figure(8000),subplot(122),plot([0:nt_dke-1]*abs(dtn),normf0(ir_display_dke,1:nt_dke),'bx',(it_display_dke-1)*abs(dtn),normf0(ir_display_dke,it_display_dke),'bo');
		axis('square')
		xlabel('Time (a.u.)')
		ylabel('ne (ne/ne0)')
		title('Electron density')
		axis([0 nt_dke*abs(dtn) 0 1.1*max(normf0(ir_display_dke,:))]);
		faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
		text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
		text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*12,['t = ',num2str((it_display_dke-1)*abs(dtn))]);		
		pause(0.5)
%
%Spherical to cylindrical coordinate transformation
%
		[logXfinit_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xfinit_ref),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
		Xfinit_cyl_ref = exp(logXfinit_cyl_ref);%For accurate representation in figures 
		[logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xf0_ref),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
		Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
%
		Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';%Grid for the distribution functions only
		Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
		Xmhu_cyl_ref = Xppar_cyl_ref./sqrt(Xppar_cyl_ref.^2+Xpperp_cyl_ref.^2);
		Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
		Xgamma_cyl_ref = sqrt(1 + Xp_cyl_ref.*Xp_cyl_ref*betath_ref*betath_ref);
		Xvpar_cyl_ref = Xppar_cyl_ref./Xgamma_cyl_ref;
%
		Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
		Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
		Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
		Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xfinit_cyl_ref>0);%Remove negative values
		Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
		Xfinit_cyl_ref(isnan(Xfinit_cyl_ref)) = 0;%Remove NaN values

		if makemovie == 1 & ir_display_dke ~= ir_display_mov,
			disp('-------------------------------------------------------------------------------------------------------------------');
			disp('-------------------------------------------- Movie construction ---------------------------------------------------')
			disp('-------------------------------------------------------------------------------------------------------------------');
%
			ir_display_mov = ir_display_dke;%Don't recalculate the movie if the radius is the same
			h8003 = figure(8003);%Give handle to the figure for building the movie
			h8004 = figure(8004);%Give handle to the figure for building the movie				
			clf
			for it = 1:nt_dke,
				Xf0_ref = ZXXf0{it}(:,:,ir_display);
				[logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xf0_ref),pn_ref,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
				Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
				Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
				Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
				Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
%			
				figure(h8003)
				subplot(121),C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xf0_cyl_ref),[-20:20/nlevel:0]);%Distribution function and wave quasilinear diffusion coefficient contour plot
				axis('equal')
				title(['f0 (t = 0 - ',num2str((nt_dke-1)*abs(dtn)),')']);
				xlabel('ppar/pth-ref');
				ylabel('pperp/pth-ref');
				if bounce_mode >= 1,%Draw bounce domain boundaries
					line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
					line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
				end
				colorbar('vert')
%
				subplot(122),plot([0:it-1]*abs(dtn),curr0(ir_display_dke,1:it)*j_ref,'r');
				xlabel('Time (a.u.)')
				ylabel('J at B=Bmin (MA/m2)')
				title('Plasma current')
				axis('square')
				axis([0 nt_dke*abs(dtn) 0 1.1*max(curr0(ir_display_dke,:))*j_ref]);			
				pause(time_pause)
%
				movf0(it) = getframe(h8003);
				clf
%
				Fpar0_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_cyl_ref,1);
				zFpar0_cyl_ref = find(Fpar0_cyl_ref==0);Fpar0_cyl_ref(zFpar0_cyl_ref) = Fpar0_cyl_ref(zFpar0_cyl_ref)+1e-60;%zero removal		
				Fpar3_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xpperp_cyl_ref.*Xpperp_cyl_ref.*Xf0_cyl_ref,1);
				Tperp_cyl_ref = Fpar3_cyl_ref./Fpar0_cyl_ref/2;
				Tperpn_cyl_ref = betath_ref*betath_ref*Tperp_cyl_ref*mc2/Te_ref;
%
				Fperp0_cyl_ref = 2*pi*integral_dke_jd(dppar_cyl_ref,Xf0_cyl_ref,2);
				zFperp0_cyl_ref = find(Fperp0_cyl_ref==0);Fperp0_cyl_ref(zFperp0_cyl_ref) = Fperp0_cyl_ref(zFperp0_cyl_ref)+1e-60;%zero removal				
				Fperp2_cyl_ref = 2*pi*integral_dke_jd(dppar_cyl_ref,Xppar_cyl_ref.*Xppar_cyl_ref.*Xf0_cyl_ref,2);
				Tpar_cyl_ref = Fperp2_cyl_ref./Fperp0_cyl_ref;
				Tparn_cyl_ref = betath_ref*betath_ref*Tpar_cyl_ref*mc2/Te_ref;
%
				figure(8004)
				subplot(121),plot(ppar_cyl_ref,Tperpn_cyl_ref);grid on;zoom on
				axis([-max(pn_ref),max(pn_ref),0,20]);axis('square');zoom on
				ylabel('Tperp/Te-ref');xlabel('ppar/pth-ref');title(['(rho = ',num2str(xrho_dke(ir_display_dke)),')']);hold on
%
				subplot(122),plot(pperp_cyl_ref,Tparn_cyl_ref);grid on;zoom on
				axis([0,max(pn_ref),0,20]);axis('square');zoom on
				ylabel('Tpar/Te-ref');xlabel('pperp/pth-ref');title(['(rho = ',num2str(xrho_dke(ir_display_dke)),')']);hold on
				pause(time_pause);
%
				movf1(it) = getframe(h8004);
				clf
%
				disp(['Movie frames at t = ',num2str((it-1)*abs(dtn)),' done.'])
			end
		end
%
%Calculations in cylindrical coordinates
%
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
%Display results
%
			figure(8001);clf
			subplot(131),semilogy(ppar_cyl_ref,Fparinit_cyl_ref,'b--',ppar_cyl_ref,Fpar0_cyl_ref,'r.');grid on;
			axis([-max(pn_ref),max(pn_ref),1e-20,10]);zoom on
			ylabel('F0//');xlabel('ppar/pth-ref');title(['(rho = ',num2str(xrho_dke(ir_display_dke)),')']);
			legend('t = 0',['t = ',num2str((it_display_dke-1)*abs(dtn))],3); 
			subplot(132),plot(ppar_cyl_ref,Tperpinitn_cyl_ref,'b--',ppar_cyl_ref,Tperpn_cyl_ref,'r.');grid on;zoom on
			axis([-max(pn_ref),max(pn_ref),min(Tperpn_cyl_ref),max(Tperpn_cyl_ref)]);zoom on
			ylabel('Tperp/Te-ref');xlabel('ppar/pth-ref');title(['(rho = ',num2str(xrho_dke(ir_display_dke)),')']);
			legend('t = 0',['t = ',num2str((it_display_dke-1)*abs(dtn))],3); 
			subplot(133),plot(pperp_cyl_ref,Tparinitn_cyl_ref,'b--',pperp_cyl_ref,Tparn_cyl_ref,'r.');grid on;zoom on
			axis([0,max(pn_ref),min(Tparn_cyl_ref),max(Tparn_cyl_ref)*1.1]);zoom on
			ylabel('Tpar/Te-ref');xlabel('pperp/pth-ref');title(['(rho = ',num2str(xrho_dke(ir_display_dke)),')']);
			legend('t = 0',['t = ',num2str((it_display_dke-1)*abs(dtn))],3); 
			pause(time_pause);
%
			figure(8002);clf
			subplot(121),
			C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xfinit_cyl_ref),[-20:20/nlevel:0]);grid on;zoom on;%Distribution function and wave quasilinear diffusion coefficient contour plot
			axis('equal')
			title('f0 (t = 0 s)');
			xlabel('ppar/pth-ref');
			ylabel('pperp/pth-ref');
			if bounce_mode >= 1,%Draw bounce domain boundaries
				line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
				line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
			end
			colorbar('vert')
%
			faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
			text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho_dke(ir_display_dke))]);
			pause(time_pause);
%
			subplot(122),
			C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xf0_cyl_ref),[-20:20/nlevel:0]);grid on;zoom on;%Distribution function and wave quasilinear diffusion coefficient contour plot
			axis('equal')
			title(['f0 (t = ',num2str((it_display_dke-1)*abs(dtn)),')']);
			xlabel('ppar/pth-ref');
			ylabel('pperp/pth-ref');
			if bounce_mode >= 1,%Draw bounce domain boundaries
				line([0,pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
				line([0,-pnmax_S*sqrt(xmhubounce2(ir_display))],[0,pnmax_S*sqrt(1 - xmhubounce2(ir_display))]);
			end
			colorbar('vert')
%
			if igor_mode == 1,
				eval(['save ',filenameroot,'_data_fig4_',int2str(ir_display_dke),'.mat xrho_dke xia r_dke ir_display_dke ppar_cyl_ref pperp_cyl_ref Xfinit_cyl_ref Xf0_cyl_ref xmhubounce2 pnmax_S'])
			end
%
			if makemovie == 1,
				while 1,
					h = figure(8003);%Give handle to the figure for building the movie			
					clf
					playmovie = input_dke_yp('*********************************** Play movie of the distribution build-up (yes : 1(f) or 2(T), no: 0)',1);
					if playmovie == 1,
						movie(h,movf0)
					elseif playmovie == 2,
						movie(h,movf1)
					else
						break
					end
				end
			end
		end
	end
end

