function [xJrf0_mksa_out,xJboot_e_mksa_out,xJboot_i_mksa_out,xJtot_mksa_out,...
xPabs0_mksa_out,xPabs_tot_mksa_out,...
xeta0_mksa_out,xepsi_mksa_out,xia_out,xft_out,...
time_out,memoryLU_f_out,memoryLU_g_out] =...
test_dke_1yp(tokname,snumber,...
grid_uniformity,grid_power,nmhu_S,np_S,pnmax_S,sfac,spfac,snmhu,snp,psin_S,psin_display,dpsin_dke,...
ref_mode,norm_ref,...
epsi0_fsav,epsia_fsav,eepsi_fsav,...
rf_list,nit_rf,prec_rf,...
coll_mode,bounce_mode,dke_mode,equil_mode,...
vparmin_r,Dr0,pDr,Dr_model,Vr0,pVr,Vr_model,...
nhuloss,...
norm_mode,boundary_mode,prec0_f,nit_f,dtn,prec0_g,nit_g,initguess,invproc,param_inv,...
dp_cyl,display_mode,nlevel,store_mode,diary_mode,auto_mode,iloop)
%
%  Test function of the 3-D relativistic bounce-averaged electron drift kinetic equation solver 
%  for the LH and EC absorption problem in presence of an Ohmic electric field.
%  Arbitrary axisymmetric plasma equilibrium
%  See dke_1_4yp.m, ptok_dke_1yp.m
%
%by Y.PEYSSON CEA-DRFC 30/07/1997 <yves.peysson@cea.fr>
%Drift kinetic calculations done by J. Decker and Y. Peysson
%
%
format long e;
global nfig;
version_dke = 2.0;
time_pause = 1;%Pause delay for figure display (s)
%
[s,dossier,machine] = comput_dke_yp;
%
%Physical constants
%
qe = 1.60217733e-19;%Absolute value of the electron charge (C)
me = 9.1093897e-31;%Electron rest mass (Kg)
e0 = 8.854187818e-12;%Free space permeability (F/m)
re = 2.82e-15;%Classical electron radius (m)
mc2 = 510.99905;%Electron energy rest mass (keV)
clum = 299792458;%Speed of light (m/s)
%
if bounce_mode == 0,dke_mode = 0;end
if dke_mode == 1,bounce_mode = 1;end
if bounce_mode > 1,bounce_mode = 1;end
if diary_mode == 1,auto_mode = 1;end
if dke_mode > 1,dke_mode = 1;end
%		
bounce = [bounce_mode,dke_mode,equil_mode];
%
prec0 = [prec0_f,prec0_g];
nit = [nit_f,nit_g];
%
% Spatial grid
%
[xpsin,xpsin_dke,xdpsin_dke,xpsinm_dke,xdpsinm_dke,xpsinp_dke,xdpsinp_dke,xpsin_S_dke,r_dke,ir_display] = radialgrid_dke_jd(dke_mode,psin_S,dpsin_dke,psin_display);
%
% Plasma equilibrium
%
[theta,XR,XZ,XBR,XBZ,XBphi,xB0,xR0,xBT0,xBp0,xrho,xTe,xne,xzTi,xzni,zZi,zmi,xZeff,Rp,Zp,ap,Ip,Ncoils,BeLi,psia,xmhu0T2] = equilibrium_jd(tokname,xpsin,display_mode);
%
if diary_mode == 1, 
	diaryfile = ['diary_dke_',int2str(iloop)];
	eval(['delete ',diaryfile]);
	diary(diaryfile);
	diary on;
%
    disp('-------------------------------------------------------------------------------------------------------------------');
    disp(['- Scenario name = ',tokname]);
    disp('-------------------------------------------------------------------------------------------------------------------');
%
	disp(['----------------------------------------------- Plasma parameters ------------------------------------------------']);
	disp(['- Plasma minor radius on LFS midplane (m) ap = ',num2str(ap)]);
	disp(['- Plasma major radius on axis (m) Rp = ',num2str(Rp)]);
	disp(['- Plasma elevation on axis (m) Zp = ',num2str(Zp)]);
	disp(['- Toroidal magnetic field coil number Ncoils = ',num2str(Ncoils)]);
	disp(['- Beta+li factor = ',num2str(BeLi)]);
	disp(['- Edge poloidal flux (Wb) = ',num2str(psia)]);
	disp(' ');
end
%
% Momentum Grid 
%
[pn,dpn,pnm,dpnm,pnp,dpnp,pn_S,mhu,dmhu,mhum,dmhum,mhup,dmhup,mhu_S] = momentumgrid_dke_jd(grid_uniformity,grid_power,dke_mode,r_dke,xmhu0T2,nmhu_S,np_S,pnmax_S,sfac,snmhu,snp);
%
nmhu = length(mhu);
np = length(pn);
nr = length(xpsin);
nr_dke = length(r_dke);%number of points for dke calculations
display = [display_mode,ir_display,time_pause];%Display parameters
%
if (Dr0 ~= 0 | Vr0 ~= 0) & nr > 1,
	dke_mode = 0;
	radial_mode = 1;
	norm_ref = 1;
else
	radial_mode = 0;
end
%
if display_mode == 2, 
	h1000 = figure(1000);tilefigs_dke_yp(h1000);
	plot(1:nmhu,mhu,'bo',1:nmhu,mhum,'g*',1:nmhu,mhup,'r+');grid on;zoom on;
	axis([1,nmhu+1,-1,1])
	title('Pitch-angle mesh');
	xlabel('Index');
	ylabel('mhu');
%
	h1001 = figure(1001);tilefigs_dke_yp(h1001);
	plot(1:np,pn,'bo',1:np,pnm,'g*',1:np,pnp,'r+');grid on;zoom on; 
	axis([1,np+1,0,max(pnp)])
	title('Momentum mesh');
	xlabel('Index');
	ylabel('pn');
%	
	h1002 = figure(1002);tilefigs_dke_yp(h1002);
	plot(1:nr,xpsin,'bo',r_dke,xpsin(r_dke),'r+',r_dke,xrho(r_dke),'bx');grid on;zoom on; 
	axis([0,nr+1,0,1])
	title('Radial mesh');
	xlabel('Index');
	ylabel('(psin: +,rho: x)');
end
%
%Reference plasma parameters (for the normalization: pth_ref, nhuth_ref)
%
if nr_dke > 1 | ref_mode == 0,
    Te_ref = max(xTe);%Core temperature
    ne_ref = max(xne);%Core density
    if display_mode >= 1
        info_dke_yp(2,'Core reference temperature and density');
        disp('-------------------------------------------------------------------------------------------------------------------');
    end 
    ref_mode = 0;%ref_mode enforced in case of length(rho_S) > 1 and ref_mode == 1
else
    if dke_mode == 0,
        Te_ref = xTe(1);%Local temperature
        ne_ref = xne(1);%Local density
        if display_mode >= 1
            info_dke_yp(2,'Local reference temperature and density');
            disp('-------------------------------------------------------------------------------------------------------------------');
        end     
    else
        Te_ref = xTe(2);%Local temperature
        ne_ref = xne(2);%Local density
        if display_mode >= 1
            info_dke_yp(2,'Local reference temperature and density');
            disp('-------------------------------------------------------------------------------------------------------------------');
        end     
    end
end
%
if diary_mode == 1,
	disp(['--------------------------------------------- Simulation parameters ----------------------------------------------']);
	disp(['- Code version = ',num2str(version_dke)]);
	disp(['- Simulation number = ',num2str(snumber)]);
   disp(['- Pitch-angle and momentum grids uniformity: (0) no, (1) yes = ',num2str(grid_uniformity)]);
   disp(['- Pitch-angle grid calculation method: (0): old method, (1) new method = ',num2str(grid_power ~= 0)]);
   if grid_power ~= 0
        disp(['- Pitch-angle grid step variation power: ',num2str(grid_power)]);
   end
	disp(['- Effective number of pitch-angle values for the distribution function grid (half grid) nmhu = ',num2str(nmhu)]);
	disp(['- Effective number of momentum values for the distribution function grid (half grid) np = ',num2str(np)]);
	disp(['- Maximum value of the momentum grid (pth_ref) pnmax =  ',num2str(pn(np))]);
	disp(['- Number of radial values for the distribution function grid (half grid) nr = ',num2str(nr)]);
	for ir = 1:nr,
		disp(['      - Normalized poloidal magnetic flux at which the distribution is calculated, point ',int2str(ir),' -> psin = ',num2str(xpsin(ir))]);
		disp(['      - Normalized radius on the LFS midplane at which the distribution is calculated, point ',int2str(ir),' ->  rho = ',num2str(xrho(ir))]);
	end
	disp(['- Normalized poloidal magnetic flux at which the distribution is displayed psin_display = ',num2str(xpsin(ir_display))]);
	disp(['- Normalized radius on the LFS midplane at which the distribution is displayed rho_display = ',num2str(xrho(ir_display))]);
	disp(' ');	
	disp(['- Reference values: (0) from core Te and ne, (1) from Te and ne at the normalized poloidal flux (parameter only active for a single radial value, otherwise ref_mode = 0)',num2str(ref_mode)]);
	disp(['- Normalization procedure for the ohmic electric field, RF quasilinear diffusion: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref norm_ref = ',num2str(norm_ref)]);
	disp(' ');
	disp(['- Flux surface averaged core Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e) epsi0_fsav = ',num2str(epsi0_fsav)]);
	disp(['- Flux surface averaged edge Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e) epsia_fsav = ',num2str(epsia_fsav)]);
	disp(['- Flux surface averaged Ohmic electric field profile peaking factor eepsi_fsav = ',num2str(eepsi_fsav)]);
	disp(' ');
	disp(['- RF waves: too be implemented']);
	disp(' ');
	disp(['- Electron-electron collision operator: (0) Maxwellian, (1) High velicity limit, (2) Linearized Belaiev Budker coll_mode = ',num2str(coll_mode)]);
	disp(['- Bounce averaging option: (0) no bounce averaging, (1) bounce averaging bounce_mode = ',num2str(bounce_mode)]);
	disp(['- Fokker-Planck equation (0), Drift Kinetic equation (1) dke_mode = ',num2str(dke_mode)]);
	disp(' ');
	disp(['- Lower velocity limit of the fast electron radial transport vparmin (vth_ref or vth) = ',num2str(vparmin_r)]);
	disp(['- Fast electron radial diffusion model: (0) No dependence, (1) Parallel velocity dependence Dr_model = ',num2str(Dr_model)]);
	disp(['- Fast electron radial pinch model: (0) No dependence, (1) Parallel velocity dependence Vr_model = ',num2str(Vr_model)]);
	disp(['- Reference fast electron radial diffusion coefficient (m2/s) Dr0 = ',num2str(Dr0)]);
	disp(['- Fast electron radial diffusion profile peaking factor pDr = ',num2str(pDr)]);
	disp(['- Reference fast electron radial pinch coefficient (m2/s) Vr0 (m/s) = ',num2str(Vr0)]);
	disp(['- Fast electron radial pinch profile peaking factor pVr = ',num2str(pVr)]);
	disp(' ');
	disp('- Ripple parameter to be reimplemented ');
	disp(' ');
	disp(['- Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes norm_mode = ',num2str(norm_mode)]);
	disp(['- Convergence level of the residu prec0_f = ',num2str(prec0_f)]);
	disp(['- Maximum number of iterations for f nit_f = ',num2str(nit_f)]);
	disp(['- integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) dtn = ',num2str(dtn)]);
	disp(['- Convergence level of the residu (if NaN, iterations stop with nit_g) nit_g = ',num2str(nit_g)]);
	disp(['- Maximum /number of iterations for g nit_g = ',num2str(nit_g)]);
	disp(['- Initial guess for the distribution function: (0) Maxwellian, (1) Fuchs model with Tperp for LH current drive only, (2) from a file initguess = ',num2str(initguess)]);
	disp(['- Matrix inversion method: (1) Full LU factorization, (2) qmr iterative method, (3) bicgstab iterative method, (4) cgs iterative method invproc = ',num2str(invproc)]);
	disp(['- Cylindrical momentum step (pth_ref) = ',num2str(dp_cyl)]);
	disp(['- Display mode: (0): no, (1): partial, (2): full display_mode = ',num2str(display_mode)]);
	disp(['- Number of level for contour plots nlevel = ',num2str(nlevel)]);
	disp(['- Temporary storing option for sparse matrices calculations (in RAM: 0, in disk file 1) store_mode = ',num2str(store_mode)]);
	disp(['- Write in a file named "diary_dke_xx" the output of the code in the MatLab command window: (0) no save, (1) save diary_mode = ',num2str(diary_mode)]);
end
disp('-------------------------------------------------------------------------------------------------------------------');
%
%
Xmhu = ones(np,1)*mhu;%Half pitch-angle grid for the distribution function
mhu2p = mhup.^2;
%
Ten_ref = Te_ref/mc2;
betath_ref = sqrt(Ten_ref);%Normalized pth_ref/mc as prescribed by Karney
pn_ref = pn;
pnp_ref = pnp;
dpn_ref = dpn;
pn2_ref = pn_ref.*pn_ref;
Xpn_ref = pn_ref'*ones(1,nmhu);
Xpn2_ref = pn2_ref'*ones(1,nmhu);
Ec_ref = mc2*(sqrt(1+pn_ref.*pn_ref*betath_ref^2) - 1);%Fast electron kinetic energy in keV
%
Xpnpar_ref = Xpn_ref.*Xmhu;
Xpnperp2_ref = Xpn2_ref - Xpnpar_ref.*Xpnpar_ref;
%
lnc_ref = 15.2 - 0.5*log(ne_ref/1e20) + log(Te_ref);%Reference Coulomb logarithm (in "Tokamaks" textbook by Wesson)
nhu_ref = qe^4*ne_ref*lnc_ref/(4*pi*e0^2*me^2*(clum*betath_ref)^3);%Reference electron collision frequency (s-1)
xftp_norm_ref = me*clum*betath_ref*xR0.*xBT0./xB0/qe/psia;%Normalization factor for drift kinetic equation (ftilde)
%
z_ref = betath_ref*pn_ref;
z2_ref = z_ref.*z_ref;
gamma_ref = sqrt(1 + z2_ref);
Xgamma_ref = gamma_ref'*ones(1,nmhu);
v_ref = pn_ref./gamma_ref;
Xvpar_ref = (v_ref'*ones(1,nmhu)).*(ones(length(v_ref),1)*mhu);
%
xTe_norm = xTe/Te_ref;
xzTi_norm = xzTi/Te_ref;
xne_norm = xne/ne_ref;
xzni_norm = xzni/ne_ref;
%
xTen = xTe/mc2;
xzTin = xzTi/mc2;
%
xbetath = sqrt(xTen);%Normalized pth/mc as prescribed by Karney
xlnc = 15.2 - 0.5*log(xne/1e20) + log(xTe);%Coulomb logarithm (in Tokamaks by Wesson)
xnhu = qe^4*xne.*xlnc./(4*pi*e0^2*me^2.*(clum*xbetath).^3);%Electron collision frequency (s-1)
%
XXfinit_ref = zeros(np,nmhu,nr);%Defined on the distribution function grid (half grid)
XXnhuloss_ref = zeros(np,nmhu,nr);%Defined on the distribution function grid (half grid)
XXDr_ref = zeros(np,nmhu,nr);%Defined on the distribution function grid (half grid)
XXVr_ref = zeros(np,nmhu,nr);%Defined on the distribution function grid (half grid)
%
if norm_ref == 0,
    xrbetath = xbetath/betath_ref;
    xrnhuth = xnhu/nhu_ref;
else
    xrbetath = ones(1,nr);
    xrnhuth = ones(1,nr);
end
xepsi0_ref_fsav = epsi0_fsav*xrbetath.*xrnhuth;
xepsia_ref_fsav = epsia_fsav*xrbetath.*xrnhuth;
xvparmin_r_ref = vparmin_r*xrbetath;
xnhuloss_ref = nhuloss*xrnhuth;
%    
for ir = 1:nr,	
%
%   Ohmic electric field
%
   xepsi_ref_fsav_in(ir) = (xepsi0_ref_fsav(ir) - xepsia_ref_fsav(ir))*(1.0-xpsin(ir)).^eepsi_fsav + xepsia_ref_fsav(ir);
%
%	Anomalous fast electron radial diffusion and pinch
%
	ivpar_r_ref_threshold = min(find(abs(Xvpar_ref) >= xvparmin_r_ref(ir)));
   xEc_r_ref_threshold(ir) = mc2*(sqrt(1+pn_ref(ivpar_r_ref_threshold).*pn_ref(ivpar_r_ref_threshold)*betath_ref^2) - 1);%in keV
%
   if Dr_model==0,%Standard model : Dr(r) = Dr0(r)
		XDrv_ref = Dr0*ones(size(np,nmhu)).*(abs(Xvpar_ref) >= xvparmin_r_ref(ir))/nhu_ref/ap/ap;%Normalized to the central collision frequency
	elseif Dr_model==1,%Magnetic turbulence model: Dr(r) = Dr0(r)*vpar_ref/vth_ref
		XDrv_ref = Dr0*(abs(Xvpar_ref) - xvparmin_r_ref(ir)).*(abs(Xvpar_ref) >= xvparmin_r_ref(ir))/xvparmin_r_ref(ir)/nhu_ref/ap/ap;%Normalized to the central collision frequency
	end
	XXDr_ref(:,:,ir) = XDrv_ref;%*(1 + pDr*xrho(ir)^2);%3-D radial diffusion matrix (radial profile dependence)
	xmaxDr_ref(ir) = max(max(XXDr_ref(:,:,ir)));%Maximum value of the radial diffusion coefficient
%
	if Vr_model==0,%Standard model : Vr(r) = Vr0(r)
		XVrv_ref = Vr0*ones(size(np,nmhu)).*(abs(Xvpar_ref) >= xvparmin_r_ref(ir))/nhu_ref/ap;%Normalized to the central collision frequency
	elseif Vr_model==1,%Magnetic turbulence model: Vr(r) = Vr0(r)*vpar_ref/vth_ref
		XVrv_ref = Vr0*(abs(Xvpar_ref) - xvparmin_r_ref(ir)).*(abs(Xvpar_ref) >= xvparmin_r_ref(ir))/xvparmin_r_ref(ir)/nhu_ref/ap;%Normalized to the central collision frequency
	end
	XVrv_ref = XVrv_ref.*(abs(Xvpar_ref) >= xvparmin_r_ref(ir));
	XXVr_ref(:,:,ir) = XVrv_ref;%*(1 + pVr*xrho(ir)^2);%3-D radial pinch matrix (radial profile dependence)
	xmaxVr_ref(ir) = max(max(XXVr_ref(:,:,ir)));%Maximum value of the radial convection coefficient
%
%Loss term for the electrons trapped in the toroidal magnetic ripple 
%
	if bounce_mode == 1 & isnan(xnhuloss_ref(ir)) == 0 & strcmp(tokname,'TS')==1,%WARNING: only valid for the TORE SUPRA tokamak with large magnetic ripple
		info_dke_yp(2,'WARNING: Ripple losses calculations only valid for Tore Supra tokamak');
		disp('-------------------------------------------------------------------------------------------------------------------');
%		Ncoils = 1;%Ncoils is here forced to 1, as prescribed in Ref. M. Ju et al., Phys. Plasmas, 9 (2002) 493. Upper bound of ripple losses is then calculated
%		xNq(ir) = Ncoils*xq(ir);%Exact N may be used but large values may lead to numerical instabilities due to round-off errors
		[xthetabanana(ir),xthetaloss(ir),xpndetrap(ir),xEseuil(ir),xdeltaripple(ir)] = detrapmj3(xZeff(ir),ap,xBT0(ir),Rp,BeLi,Ip,xne(ir),xrho(ir));%WARNING: Only valid for the TORE SUPRA tokamak
		xpndetrap_ref(ir) = xpndetrap(ir)/betath_ref;
%
		xmhusupertrap(ir) = sin(pi*xthetaloss(ir)/180);
		Xmaskrip_ref = (Xpn_ref > xpndetrap_ref(ir)).*(abs(Xmhu) < xmhusupertrap(ir));
		Xnhuloss_ref = Xmaskrip_ref*xnhuloss_ref(ir);
	else
		if strcmp(tokname,'TS') == 0, 
			info_dke_yp(2,'WARNING: Ripple losses calculations only valid for Tore Supra tokamak. Wrong tokamak name');
			disp('-------------------------------------------------------------------------------------------------------------------');
		end
		xdeltaripple(ir) = 0;
		xNq(ir) = Ncoils;%*xq(ir);
		Xnhuloss_ref = zeros(length(pn_ref),length(mhu));
	end
	XXnhuloss_ref(:,:,ir) = Xnhuloss_ref;
%
   if initguess == 1  & (isnan(xvparmin_lh_ref(ir_display)) == 1 | isnan(xvparmax_lh_ref(ir_display)) == 1 | nb_lh ~= 1 ),initguess = 0 ;end
	if initguess == 0,
		fM_ref = exp(-pn_ref.*pn_ref./(1 + gamma_ref)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));%Maxwellian distribution normalized to normalized density ne_norm (1st order gamma corrections)
		XfM_ref = fM_ref'*ones(1,nmhu);
		normfM_ref = 2*pi*integral_dke_jd(dpn_ref(:),pn_ref(:).*pn_ref(:).*integral_dke_jd(dmhu,XfM_ref,2),1);
		XfM_ref = xne_norm(ir)*XfM_ref/normfM_ref;
		Xf0_ref = XfM_ref;
		title_initguess = 'Relativistic Maxwellian';        
	elseif initguess == 1,
%
%   Initial guess for the distribution function from ref. V.Fuchs et al.,Phys. Fluids 28 (1985) 3619. 
%   (Only for the old method for calculating the quasilinear diffusion coefficient of the LH operator)
%
		alpha = 2 - 2/(2+Zi(1));
		beta = 2 - alpha;
		Tp1nr_ref = (xvparmax_lh_ref(ir)^(alpha+1) - xvparmin_lh_ref(ir)^(alpha+1))*(alpha-1)/(alpha+1) - (alpha-1)*(xvparmax_lh_ref(ir) - xvparmin_lh_ref(ir))*xvparmin_lh_ref(ir)^alpha + xvparmax_lh_ref(ir)^(alpha-1) - xvparmin_lh_ref(ir)^(alpha-1);
		Tp2nr_ref = 2*(alpha-1)*(xvparmax_lh_ref(ir) - xvparmin_lh_ref(ir))*xvparmin_lh_ref(ir)^(alpha-2) - (xvparmax_lh_ref(ir)^(alpha-1) - xvparmin_lh_ref(ir)^(alpha-1));
		Tpnr_ref = Tp1nr_ref/Tp2nr_ref;
		Tpr_ref = 1.0*Tpnr_ref;%Relativistic correction (if necessary)
		Xpperp2_ref = Xpn_ref.*Xpn_ref.*(1 - Xmhu.*Xmhu);
		Xppar_ref = Xpn_ref.*Xmhu;
		Xppar2_ref = Xppar_ref.*Xppar_ref;
		Xgamma_ref = gamma_ref'*ones(1,length(mhu));
		Xpparmin_ref = xvparmin_lh_ref(ir)*sqrt((1+Xpperp2_ref*betath_ref^2)/(1-betath_ref^2*xvparmin_lh_ref(ir)^2));
		Xpparmax_ref = xvparmax_lh_ref(ir)*sqrt((1+Xpperp2_ref*betath_ref^2)/(1-betath_ref^2*xvparmax_lh_ref(ir)^2));
		Xmaskplat_ref = (Xppar_ref >= Xpparmin_ref).*(Xppar_ref <= Xpparmax_ref);
		Xfsth0_ref = Xmaskplat_ref.*exp(-Xpperp2_ref/2/Tpr_ref)/2/pi/Tpr_ref;
		Xmaskback_ref = (Xppar_ref <= Xpparmin_ref);
		Xfsth1_ref = Xmaskback_ref.*exp(-Xpn_ref.*Xpn_ref/2/Tpr_ref).*exp(Xpparmin_ref.*Xpparmin_ref/2/Tpr_ref)/2/pi/Tpr_ref;
		Xmaskup_ref = (Xppar_ref > Xpparmax_ref);
		Xfsth2_ref = Xmaskup_ref.*exp(-(Xpn_ref.*Xpn_ref.*(Xppar_ref./Xpparmax_ref).^(2/Zi(1)) - Xpparmax_ref.*Xpparmax_ref)/Tpr_ref/2)/2/pi/Tpr_ref;%See thesis of R.Arslanbekov
		Xfsth_ref = Xfsth0_ref+Xfsth1_ref+Xfsth2_ref;
		fM_ref = xne_norm(ir)*exp(-pn_ref.*pn_ref./(1+gamma_ref)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
		XfM_ref = fM_ref'*ones(1,nmhu);
      normfM_ref = 2*pi*integral_dke_jd(dpn_ref(:),pn2_ref(:).*integral_dke_jd(dmhu,XfM_ref,2),1);
		normfsth_ref = 2*pi*integral_dke_jd(dpn_ref(:),pn2_ref(:).*integral_dke_jd(dmhu,Xfsth_ref,2),1);
		XfM_ref = XfM_ref/normfM_ref;
		Xfsth_ref = Xfsth_ref/normfsth_ref;
		lambda_ref = 1/(1 + Xfsth_ref(min(find(Xmaskplat_ref(:,nmhu-1)==1)),nmhu-1)/XfM_ref(min(find(Xmaskplat_ref(:,nmhu-1)==1)),nmhu-1));
		if (nb_lh == 0),lambda_ref = 0;end
		Xf0_ref = XfM_ref + Xfsth_ref*lambda_ref;   
      normf0_ref = 2*pi*integral_dke_jd(dpn_ref(:),pn2_ref(:).*integral_dke_jd(dmhu,Xf0_ref,2),1);
		Xf0_ref = xne_norm(ir)*Xf0_ref/normf0_ref;
		title_initguess = 'Fuchs et al. LH model';
	elseif initguess == 2,
		eval(['load ',dossier,s,'XXfinit.mat'])
		Xf0_ref = squeeze(XXfinit(:,:,ir));
		title_initguess = 'Initial distribution from data file';
	end
	XXfinit_ref(:,:,ir) = Xf0_ref;
%
%Display initial distribution function
%
	if display_mode == 2,
		if dke_mode == 1,
%
			view = 0;
%
			if ir == ir_display-1,
				figure(1),subplot(131);zoom on
				view = 1;
			elseif ir == ir_display,
				figure(1),subplot(132);zoom on
				view = 1;
			elseif ir == ir_display+1,
				figure(1),subplot(133);zoom on
				view = 1;
			end	
%		
			if view == 1,		
				normf0_ref = 2*pi*integral_dke_jd(dpn_ref(:),pn2_ref(:).*integral_dke_jd(dmhu,Xf0_ref,2),1);
				[logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xf0_ref),pn_ref,mhu,dp_cyl);
				Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
%
				Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';
				Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
				Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
				Xmhu_cyl_ref = Xppar_cyl_ref./sqrt(Xppar_cyl_ref.^2+Xpperp_cyl_ref.^2);
				Xgamma_cyl_ref = sqrt(1 + Xp_cyl_ref.*Xp_cyl_ref*betath_ref*betath_ref);
				Xvpar_cyl_ref = Xppar_cyl_ref./Xgamma_cyl_ref;
%
        		Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
        		Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
                Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
%
        		curr0_ref = 2*pi*integral_dke_jd(dpn_ref(:),pn2_ref(:).*(pn_ref(:)./gamma_ref(:)).*integral_dke_jd(dmhu,Xmhu.*Xf0_ref,2),1);
        		curr0_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref(:),pperp_cyl_ref(:).*integral_dke_jd(dppar_cyl_ref,Xvpar_cyl_ref.*Xf0_cyl_ref,2),1);
%
				C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xf0_cyl_ref),[-20:20/nlevel:0]);axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['Te(norm) = ',num2str(xTe_norm(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['ne(norm) = ',num2str(xne_norm(ir))]);
				xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title(title_initguess);
				pause(time_pause);
%
			end
%
			view = 0;
			if ir == ir_display-1,
				figure(2),subplot(231);zoom on
				view = 1;
			elseif ir == ir_display,
				figure(2),subplot(232);zoom on
				view = 1;
			elseif ir == ir_display+1,
				figure(2),subplot(233);zoom on
				view = 1;
			end
%
			if view == 1,
				semilogy(-v_ref,XfM_ref(:,1),'g--',v_ref,XfM_ref(:,nmhu),'g--',-v_ref,Xf0_ref(:,1),'c-',v_ref,Xf0_ref(:,nmhu),'c-');%Forward and backward directions only
				axis([-max(v_ref),max(v_ref),1e-20,10]);grid on;zoom on
				xlabel('vpar/vth-ref');ylabel('f(pperp = 0)');title(['Norm.(rho=',num2str(xrho(ir)),') = ',num2str(normf0_ref)]);
				pause(time_pause);
			end
%           
			view = 0;
			if ir == ir_display-1,
				figure(2),subplot(234);zoom on
				view = 1;
			elseif ir == ir_display,
				figure(2),subplot(235);zoom on
				view = 1;
			elseif ir == ir_display+1,
				figure(2),subplot(236);zoom on
				view = 1;
			end  
%
			if view == 1,
				plot(pn_ref,pn_ref,'r-.',pn_ref,v_ref,'b:');grid on;zoom on
				xlabel('p/pth-ref');ylabel('v/vth-ref');title(['j = ',num2str(curr0_ref)]);
				pause(time_pause);
			end
		else
			view = 0;
			if ir == ir_display,
				figure(1),subplot(132);zoom on
				view = 1;
			end
%
			if view == 1,
				normf0_ref = 2*pi*integral_dke_jd(dpn_ref(:),pn2_ref(:).*integral_dke_jd(dmhu,Xf0_ref,2),1);
        		[logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(Xf0_ref),pn_ref,mhu,dp_cyl);
        		Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
%
        		Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';
        		Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
        		Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
        		Xmhu_cyl_ref = Xppar_cyl_ref./sqrt(Xppar_cyl_ref.^2 + Xpperp_cyl_ref.^2);
        		Xgamma_cyl_ref = sqrt(1 + Xp_cyl_ref.*Xp_cyl_ref*betath_ref*betath_ref);
        		Xvpar_cyl_ref = Xppar_cyl_ref./Xgamma_cyl_ref;
%
        		Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
        		Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
%
        		curr0_ref = 2*pi*integral_dke_jd(dpn_ref(:),pn2_ref(:).*(pn_ref(:)./gamma_ref(:)).*integral_dke_jd(dmhu,Xmhu.*Xf0_ref,2),1);
        		curr0_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref(:),pperp_cyl_ref(:).*integral_dke_jd(dppar_cyl_ref,Xvpar_cyl_ref.*Xf0_cyl_ref,2),1);
%
				C = contour(ppar_cyl_ref,pperp_cyl_ref,log(Xf0_cyl_ref),[-20:20/nlevel:0]);axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['Te(norm) = ',num2str(xTe_norm(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['ne(norm) = ',num2str(xne_norm(ir))]);
				xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title(title_initguess);
				pause(time_pause);
%
			end
%
			view = 0;
			if ir == ir_display,
				figure(2),subplot(232);zoom on
				view = 1;
			end
%
			if view == 1,
				semilogy(-v_ref,XfM_ref(:,1),'g--',v_ref,XfM_ref(:,nmhu),'g--',-v_ref,Xf0_ref(:,1),'c-',v_ref,Xf0_ref(:,nmhu),'c-');%Forward and backward directions only
				axis([-max(v_ref),max(v_ref),1e-20,10]);grid on;zoom on
				xlabel('vpar/vth-ref');ylabel('f(pperp = 0)');title(['Norm.(rho=',num2str(xrho(ir)),') = ',num2str(normf0_ref)]);
				pause(time_pause);
			end
%           
			view = 0;
			if ir == ir_display,
				figure(2),subplot(235);zoom on;pause(time_pause)
				view = 1;
			end    
%
			if view == 1,
				plot(pn_ref,pn_ref,'r-.',pn_ref,v_ref,'b:');grid on;zoom on
				xlabel('p/pth-ref');ylabel('v/vth-ref');title(['j = ',num2str(curr0_ref)]);
				pause(time_pause);
			end
%						
		end
%
		if radial_mode == 1,
			view = 0;
			if ir == ir_display,
				figure(1007),subplot(121);zoom on
				view = 1;
			end
%
			if view == 1,
				[XDrv_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(XXDr_ref(:,:,ir),pn_ref,mhu,dp_cyl);
%
				Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';
				Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
				Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
%
				XDrv_cyl_ref = XDrv_cyl_ref.*(XDrv_cyl_ref>0);%Remove negative values
				XDrv_cyl_ref = XDrv_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
 %
 				C = contourf(ppar_cyl_ref,pperp_cyl_ref,XDrv_cyl_ref,nlevel);colorbar;
 				axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['v//-threshold(norm) = ',num2str(xvparmin_r_ref(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['Ec-threshold = ',num2str(xEc_r_ref_threshold(ir)),' (keV)']);
				xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title('Radial diffusion coefficient (nhu-ref*ap*ap)');
				pause(time_pause);
%
				subplot(122),plot(pn_ref./gamma_ref,XXDr_ref(:,nmhu,ir),'b');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['mhu = 1']);
				xlabel('v/vth-ref');ylabel('Dr (nhu-ref*ap*ap)');title('Radial diffusion coefficient ');
				pause(time_pause);
			end
%
			view = 0;
			if ir == ir_display,
				figure(1008),subplot(121);zoom on
				view = 1;
			end
%
			if view == 1,
				[XVrv_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(XXVr_ref(:,:,ir),pn_ref,mhu,dp_cyl);
%
				Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';
				Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
				Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
%
				XVrv_cyl_ref = XVrv_cyl_ref.*(XVrv_cyl_ref>0);%Remove negative values
				XVrv_cyl_ref = XVrv_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
%
 				C = contourf(ppar_cyl_ref,pperp_cyl_ref,XVrv_cyl_ref,nlevel);colorbar;
 				axis('equal');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['rho = ',num2str(xrho(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*10,['v//-threshold(norm) = ',num2str(xvparmin_r_ref(ir))]);
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*15,['Ec-threshold = ',num2str(xEc_r_ref_threshold(ir)),' (keV)']);
				xlabel('ppar/pth-ref');ylabel('pperp/pth-ref');title('Radial convection coefficient (nhu-ref*ap)');
				pause(time_pause);
%
				subplot(122),plot(pn_ref./gamma_ref,XXVr_ref(:,nmhu,ir),'r');
				faxis = axis;dfaxis_x = (faxis(2) - faxis(1))/100;dfaxis_y = (faxis(4) - faxis(3))/100; 
				text(faxis(1) + dfaxis_x*5,faxis(4) - dfaxis_y*5,['mhu = 1']);
				xlabel('v/vth-ref');ylabel('Vr (nhu-ref*ap)');title('Radial convection coefficient ');
				pause(time_pause);
			end
		end
	end
end
%
if display_mode == 2,
	figure(2000),subplot(121),plot(xpsin,xrho,'r-.',xpsin,xrho,'b+');grid on;zoom on
	xlabel('psi/psia');ylabel('rho');title('Metric relation');
	axis('square');axis([0,1,0,1]);
	figure(2000),subplot(122),plot(xrho,xpsin,'r-.',xrho,xpsin,'b+');grid on;zoom on
	xlabel('rho');ylabel('psi/psia');title('Metric relation');
	axis('square');axis([0,1,0,1]);
	pause(time_pause);
end	
%
if radial_mode == 1 & display_mode == 2,
	h1005 = figure(1005);tilefigs_dke_yp(h1005);
	subplot(121),plot(xrho,xvparmin_r_ref,'g-x');grid on;zoom on;
	axis([0,1,0,1.1*max(xvparmin_r_ref)]);
	xlabel('rho');
	ylabel('v// threshold (vth-ref)');
	title('Radial transport');
	subplot(122),plot(xrho,xEc_r_ref_threshold,'c-x');grid on;zoom on;
	axis([0,1,0,1.1*max(xEc_r_ref_threshold)]);
	xlabel('xrho');
	ylabel('Kinetic energy threshold (keV)');
	title('Radial transport');
	pause(time_pause);
%
	h1006 = figure(1006);tilefigs_dke_yp(h1006);
	subplot(121),plot(xrho,xmaxDr_ref,'b-o');grid on;zoom on;
	if sum(xmaxDr_ref) ~= 0,axis([0,1,0,1.1*max(xmaxDr_ref)]);end
	xlabel('rho');
	ylabel('Maximum value (nhu-ref*ap*ap)');
	title('Radial diffusion');
	subplot(122),plot(xrho,xmaxVr_ref,'r-o');grid on;zoom on;
	if sum(xmaxVr_ref) ~= 0,axis([0,1,0,1.1*max(xmaxVr_ref)]);end
	xlabel('rho');
	ylabel('Maximum value (nhu-ref*ap)');
	title('Radial convection');
	pause(time_pause);
end
%
%   Drift Kinetic calculations
%
time0 = clock;
%
xyPabs_tot_rf_fsav_in = 0;
%
for it_rf=1:nit_rf % convergence in the ray-tracing mode

    [waveparam,nb_list] = rfwave_dke_jd(tokname,xrho,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,xrbetath,xrnhuth,xTe_norm,xne_norm,xzni_norm,zZi,zmi,Rp,ap,bounce_mode,rf_list);%Look at the function for the RF wave input parameters
    
    [XXheaviside,...
        XXf0_ref,XXf0_tp_ref,XXf0_g_ref,...
        YXXDrf_ref,...
        Znorm_ref,Znorm_ref_fsav,...
        Zcurr_ref,Zcurr_ref_fsav,...
        ZP0_ref_fsav,...
        ZSp0_ref,...
        XxRR_ref_fsav,xMRR_flux_ref,xMRR_tau_ref,...
        xTe_norm_out,xft_fsav,xmhubounce2,xepsi_ref,...
        memoryLU_f,memoryLU_g]...
    = dke_1_4yp(tokname,theta,...
        XR,XZ,XBR,XBZ,XBphi,...
        xB0,xR0,xBT0,xBp0,Rp,Zp,ap,...
        mhu,dmhu,mhum,dmhum,mhup,dmhup,mhu_S,...
        xmhu0T2,xrho,xpsin,xdpsin_dke,xpsinm_dke,xdpsinm_dke,xpsinp_dke,xdpsinp_dke,r_dke,xpsin_S_dke,...
        pn,dpn,pnm,dpnm,pnp,dpnp,pn_S,spfac,...
        xTe_norm,xne_norm,zZi,zmi,xzni_norm,xzTi_norm,...
        betath_ref,xepsi_ref_fsav_in,waveparam,...
        XXDr_ref,XXVr_ref,...
        XXnhuloss_ref,xdeltaripple,...
        xftp_norm_ref,bounce,coll_mode,...
        norm_mode,boundary_mode,dtn,prec0,nit,invproc,param_inv,display,store_mode,XXfinit_ref);
%
    if sum(rf_list) > 0
        xyPabs_rf_dke_fsav_out = ZP0_ref_fsav{3,1} + ZP0_ref_fsav{3,2} + ZP0_ref_fsav{3,3}; % flux-surface averaged density of absorbed power.
        residue_rf = max(max(abs(xyPabs_rf_dke_fsav_out - xyPabs_tot_rf_fsav_in)./(abs(xyPabs_rf_dke_fsav_out) + eps)));
        xyPabs_tot_rf_fsav_in = xyPabs_rf_dke_fsav_out;
        if residue_rf <= prec_rf
            info_dke_yp(2,['Successfull convergence achieved for ray-tracing coupling after ',int2str(it_rf),' iterations !']);
            break
        end
    end
end
%
%
%   RF wave quasilinear diffusion
%
nb = size(waveparam,2);
if nb > 0
    blist_lh = find(waveparam(1,:,1)==0);
    nb_lh = length(blist_lh);
    waveparam_lh = waveparam(:,blist_lh,:);
    blist_ec = find(waveparam(1,:,1) > 0);
    nb_ec = length(blist_ec);
    waveparam_ec = waveparam(:,blist_ec,:);
else 
    nb_lh = 0;
    nb_ec = 0;
end
%
%For displaying RF quasilinear domain only
%
if nb_ec > 0,
    xDperp_cy_ref = waveparam_ec(:,1,6);
end
if nb_lh > 0,
    xD0_lh_ref = waveparam_lh(:,1,5);
    xvparmin_lh_ref = 1./waveparam_lh(:,1,7)/betath_ref;
    xvparmax_lh_ref = 1./waveparam_lh(:,1,6)/betath_ref;
end
%
time_out = etime(clock,time0);
memoryLU_f_out = memoryLU_f;
memoryLU_g_out = memoryLU_g;
%
if display_mode >= 1,
    if dke_mode == 0,
        info_dke_yp(2,['Full elapsed time for solving the electron Fokker-Planck equation: ',num2str(time_out),' (s)']) 
    else
        info_dke_yp(2,['Full elapsed time for solving the electron Drift Kinetic equation: ',num2str(time_out),' (s)']) 
    end
    disp('-------------------------------------------------------------------------------------------------------------------');
end
%
[s,dossier,machine] = comput_dke_yp;
if exist([dossier,s,'dke_',int2str(ir_display),'_s',int2str(snumber),'_out.mat']) == 2,
	delete([dossier,s,'dke_',int2str(ir_display),'_s',int2str(snumber),'_out.mat']);
end
eval(['save ',dossier,s,'dke_',int2str(ir_display),'_s',int2str(snumber),'_out.mat']);
if exist([dossier,s,'dke_',int2str(ir_display),'_s',int2str(snumber),'_out.mat']) == 2,
	disp('-------------------------------------------------------------------------------------------------------------------');
	info_dke_yp(2,['The data file : dke_',int2str(ir_display),'_s',int2str(snumber),'_out.mat has been successfully saved !']);
end
%
[xJrf0_mksa_out,xJboot_e_mksa_out,xJboot_i_mksa_out,xJtot_mksa_out,...
xPabs0_mksa_out,xPabs_tot_mksa_out,...
 xeta0_mksa_out,xepsi_mksa_out,xia_out,xft_out] = display_dke_1yp(['dke_',int2str(ir_display),'_s',int2str(snumber),'_out.mat']);



