function [norm,curr,Tph,Tph_star] = loop_scan_vmin_vmax_Dlh(iD0,vmin,vmax,D0,epsi,Te,rho_S,dkepath,equil,dkeparam,dkedisplay,hxr,hxrparam,fieldside,chordview)
%R5-X2 - Loop function for running the LUKE solver in scan mode for Tph parametric dependences with vmin, vmax, Dlh, epsi and Te (flat profiles)
%
% Loop function for running the LUKE solver in scan mode for Tph parametric dependences with vmin, vmax, Dlh, epsi and Te (flat profiles)
%
%by Y.Peysson CEA/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/IRFM (joan.decker@cea.fr)
%
norm = zeros(length(vmin),length(vmax),length(epsi),length(Te));
curr = zeros(length(vmin),length(vmax),length(epsi),length(Te));
Tph = zeros(length(vmin),length(vmax),length(epsi),length(Te));
Tph_star = zeros(length(vmin),length(vmax),length(epsi),length(Te));
%
for iTe = 1:lengtht(Te),
	for iepsi = 1:lengtht(epsi),
		for ivmin = 1:length(vmin),
    		for ivmax = 1:length(vmax),
				wavestruct.omega_lh = [4]*2*pi*1e9; %(GHz -> rad/s). Wave frequency [1,1] Indicative, no effect in small FLR limit opt_lh > 0
				%Option parameter for cross-comparison between old LH code: 
				%	- (1): 1/vpar dependence
				%	- (2): no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
				wavestruct.opt_lh = 2; % [1,1]
				%
				% Choose (vparmin_lh,vparmax_lh) or (Nparmin_lh,Nparmax_lh) for square n// LH wave power spectrum,
				% or (Npar_lh,dNpar_lh) for Gaussian shape
				%
				wavestruct.norm_ref = 1;%Normalization procedure for the LH quasilinear diffusion coefficient and spectrum boundaries
				%
				wavestruct.yvparmin_lh = [vmin(ivmin)];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
				wavestruct.yvparmax_lh = [vmax(ivmax)];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
				%
				wavestruct.yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
				wavestruct.yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
				wavestruct.yNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
				wavestruct.ydNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
				%
				%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
				wavestruct.yD0_in_c_lh = [D0(iD0)];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
				%     
				wavestruct.yD0_in_lh_prof = [0];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
				wavestruct.ypeak_lh = [0.4];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
				wavestruct.ywidth_lh = [0.2];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
				%
				wavestruct.ythetab_lh = [0]*pi/180;%(deg -> rad). Poloidal location of LH beam [0..2pi] [1,n_scenario_lh]
				%               (0) from local values Te and ne, (1) from central values Te0 and ne0 
				%
				%************************************************************************************************************************************
				%
				equil.pTe = equil.pTe*0 + Te(iTe);
				equil.pzTi = equil.pzTi*0 + Te(iTe);
				%
				waves{1} = make_idealLHwave_jd(equil,wavestruct);
				%
				ohm = ohm_profile_yp(equil,epsi(iepsi));
				%
				[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp('test',[],rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,[],[],[]);
				%
				dt = 1;%integration time step (s)
				%
				[Zbremchord,equilHXR] = bremchord_dke_yp(dkeparam,dkedisplay,equil,radialDKE,Zcurr,hxr,hxrparam);
				[Zbremplasma] = bremsstrahlung_dke_yp(dkeparam,dkedisplay,equilHXR,radialDKE,mksa,momentumDKE,dke_out,Zbremchord,hxr,hxrparam,fieldside,chordview);%No magnetic field line effect (perp view)
				[Zbremdiag] = bremdiag_dke_yp(Zbremplasma,hxr,hxrparam,dt);
				%
				norm(ivmin,ivmax,iepsi,iTe) = Znorm.x_0(1);
				curr(ivmin,ivmax,iepsi,iTe) = Zcurr.x_0(1);
				Tph(ivmin,ivmax,iepsi,iTe) = Zbremdiag.tphot_plasma;
				Tph_star(ivmin,ivmax,iepsi,iTe) = Zbremdiag.tphot_plasma_exp;
			end
		end
	end
end

