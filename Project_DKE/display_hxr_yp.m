function [xJrf0_fsav_mksa,xJbc_e_fsav_mksa,xJbc_i_fsav_mksa,xJtot_fsav_mksa,...
xPabs0_fsav_mksa,xPabs_tot_fsav_mksa,...
xeta0_fsav_mksa,xepsi_fsav_mksa,xia,xft_fsav] = display_dke_1yp(filename,id_hxr,path_hxr,auto_mode_in,igor_mode)
%
% Display results of the Electron Drift Kinetic solver (test_dke_1yp.m)
%
%by Y.Peysson CEA-DRFC 02/08/2003 <yves.peysson@cea.fr>
%
%
warning off;
[s,dossier,machine] = comput_dke_yp;
if nargin == 0,	
	eval(['dir RESULTS_*.mat']);
	filename = [];
	filename = input_dke_yp('Filename ',filename);
%
	eval(['dir HXR_*.mat']);
	filenamehxr = [];
	filenamehxr = input_dke_yp('Filename ',filenamehxr);
%
	auto_mode_in = input_dke_yp('Automatic display mode (yes: 1, no: 0) ',0);
	igor_mode = input_dke_yp('Igor software output (yes: 1, no: 0) ',0);%For figure by figure data output (Easy data transfer to Igor software for final output)
elseif nargin == 1,
	auto_mode_in = input_dke_yp('Automatic display mode (yes: 1, no: 0) ',0);
	igor_mode = input_dke_yp('Igor software output (yes: 1, no: 0) ',0);%For figure by figure data output (Easy data transfer to Igor software for final output)
elseif nargin == 2,
	igor_mode = 0;%Automatic mode when test_dke_1yp.m is running
end
%
eval(['load ',filename]);%Load DKE output data
eval(['load ',filenamehxr]);%Load HXR structure
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
nchords = length(hxr.alpha_hxr);
theta_display = 180;
chord_display = 1;
while 1,
	ir_display_dke = find(r_dke == ir_display);
	if auto_mode_in == 0,
		disp(' ')
		disp('**************************************************************************')
		ir_display_dke = input_dke_yp(['*********************************** Radial index value (1-',int2str(nr_dke),') (exit: <=0)'],ir_display_dke);
		theta_display = input_dke_yp(['*********************************** Poloidal angle value (0-180 deg) (exit: <=0)'],theta_display);
		chord_display = input_dke_yp(['*********************************** Chord index value (0-',int2str(nchords),') (exit: <=0)'],chord_display);

		disp('**************************************************************************')
		disp(' ')
		if ir_display_dke < 1,
			break
		end
	end
%
	[vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr] = bremchord_dke_yp(equil,hxr,xpsin_dke,xpsin_S_dke,1,'spline',display_mode);
%
	[kphot,brem_bd_out,brem_forward,brem_backward,brem_perp,brem_4pi,lchord,rho_out,theta_out] = bremsstrahlung_dke_yp(equil,hxr,vschords,psin_hxr,theta_hxr,PSI_hxr,mask_hxr,XXheaviside,zZi,xzni_norm,xne_norm,ne_ref,xrho,dmhu,mhu,dpn_ref,pn_ref,pn2_ref,gamma_ref,Ec_ref,dp_cyl,pnmax_S,XXf0_ref,XXf0_tp_ref,XXf0_g_ref,nlevel,bounce_mode,display_mode,xrho(ir_display_dke),theta_display);
% 
	[kphot,brem_bd_plasma,brem_bd_diag,tphot_plasma,afit_plasma,tphot_plasma_exp,afit_plasma_exp,meanabsx] = bremdiag_dke_yp(equil,hxr,kphot,brem_bd_out,display_mode,chord_display);
%
end
