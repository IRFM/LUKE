function [Znorm_ref,Zcurr_ref,ZP0_ref,dke_out,radial,momentum,mksa] = main_dke_yp(psin_S,rho_S,equil,dkeparam,display,ohm,waves,transpfaste,ripple,XXf0_in,xnloss,XXsource);
%
%  Main function of the 3-D relativistic bounce-averaged electron drift kinetic equation solver 
%  for the RF wave absorption problem in presence of an Ohmic electric field (electron bootstrap current consistent with non-Maxwellian distribution)
%  Small banana width approximation
%  Arbitrary axisymmetric plasma equilibrium (linked arbitrary tokamak magnetic equilibrium code, via mexfile)
%  Plasma current, RF power absorption, runaway rate, magnetic ripple loss and fast electron bremsstrahlung calculations
%  See dke_1_4yp.m
%
%by Y.Peysson (CEA-DRFC) <yves.peysson@cea.fr> and J. Decker (MIT/RLE) <joan.decker@cea.fr>
%
if nargin < 12,
    error('Wrong number of input arguments in main_dke_yp')
end
%   
format long e;
global nfig;
[s,dossier,machine] = comput_dke_yp;
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
%
% Extraction of structures 
%
tokname = equil.id;
%-------------------------------------------
grid_uniformity = dkeparam.grid_uniformity;
grid_method = dkeparam.grid_method;
nmhu_S = dkeparam.nmhu_S;
np_S = dkeparam.np_S;
pnmax_S = dkeparam.pnmax_S;
sfac0 = dkeparam.sfac0;
sfac1 = dkeparam.sfac1;
sfact = dkeparam.sfact;
snmhu0 = dkeparam.snmhu0;
snmhu1 = dkeparam.snmhu1;
snmhut = dkeparam.snmhut;
grid_power = dkeparam.grid_power;
np_S_ref = dkeparam.np_S_ref;
snp = dkeparam.snp; 
spfac = dkeparam.spfac;
dpsin_dke = dkeparam.dpsin_dke;
ref_mode = dkeparam.ref_mode;
coll_mode = dkeparam.coll_mode;
bounce_mode = dkeparam.bounce_mode;
dke_mode = dkeparam.dke_mode;
equil_mode = dkeparam.equil_mode;
syn_mode = dkeparam.syn_mode;
norm_mode_f = dkeparam.norm_mode_f;
boundary_mode_f = dkeparam.boundary_mode_f;
prec0_f = dkeparam.prec0_f;
nit_f = dkeparam.nit_f;
initguess_f = dkeparam.initguess_f;
initfile_f = dkeparam.initfile_f;
boundary_mode_g = dkeparam.boundary_mode_g;
prec0_g = dkeparam.prec0_g;
nit_g = dkeparam.nit_g;
dtn = dkeparam.dtn;
invparam.luproc = dkeparam.luproc;
invparam.ludroptol = dkeparam.ludroptol;
invparam.invproc = dkeparam.invproc;
invparam.mlprecinv = dkeparam.mlprecinv;
invparam.mlmaxitinv = dkeparam.mlmaxitinv;
invparam.MUMPSparam = dkeparam.MUMPSparam;
store_mode = dkeparam.store_mode;
rt_mode = dkeparam.rt_mode;
nit_rf = dkeparam.nit_rf;
prec_rf = dkeparam.prec_rf;
nmax_rf = dkeparam.nmax_rf;
%-------------------------------------------
psin_display = display.psin_display;
rho_display = display.rho_display;
dp_cyl = display.dp_cyl;
nlevel = display.nlevel;
display_mode = display.display_mode;
time_pause = display.time_pause;
auto_mode = display.auto_mode;
%
if display_mode >=1,
	disp('-------------------------------------------------------------------------------------------------------------------');
	disp('-------------------------------------------------------------------------------------------------------------------');
	disp(['Drift Kinetic calculations for the electron population during current drive in tokamaks']);
	disp(['for arbitrary plasma equilibrium and type of RF waves. Thin banana width approximation.']);
	disp(['Authors:  - Yves Peysson (CEA-DSM-DRFC, France, yves.peysson@cea.fr)']);
	disp(['          - Joan Decker (CEA-DSM-DRFC, France,joan.decker@cea.fr)']);
	disp('-------------------------------------------------------------------------------------------------------------------');
end
%
if bounce_mode == 0,dke_mode = 0;end
if dke_mode == 1,bounce_mode = 1;end
if bounce_mode > 1,bounce_mode = 1;end
if dke_mode > 1,dke_mode = 1;end
if dke_mode == 0, syn_mode =0;end
if rt_mode == 0,nit_rf = 1;end
%	
sfac = [sfac0,sfac1,sfact];
snmhu = [snmhu0,snmhu1,snmhut];
bounce = [bounce_mode,dke_mode,equil_mode];
boundary_mode = [boundary_mode_f,boundary_mode_g];
%
prec0 = [prec0_f,prec0_g];
nit = [nit_f,nit_g];
%
% ---------- Spatial grid ---------
%
psin_S = sort([psin_S,rho2psi_jd(equil,rho_S)]);
if isnan(psin_display), 
    psin_display=rho2psi_jd(equil,rho_display);
end
%
if length(psin_S) == 1,%No iteration if one radial point
	rt_mode = 0;
	nit_rf = 1;
end
%
[xpsin,xpsin_dke,xdpsin_dke,xpsinm_dke,xdpsinm_dke,xpsinp_dke,xdpsinp_dke,xpsin_S_dke,r_dke,ir_display] = radialgrid_dke_jd(dke_mode,psin_S,dpsin_dke,psin_display);
%
% ----------- Plasma equilibrium of the radial grid ---------------
%
[theta,xpsin,psia,XR,XZ,XBR,XBZ,XBphi,xB0,xR0,xBT0,xBp0,xrho,xTe,xne,xzTi,xzni,zZi,zmi,xZeff,Rp,Zp,ap,xmhu0T2,xdV_dke,xdA_dke] = equilibrium_jd(equil,xpsin,xpsin_S_dke,display_mode,'spline',10);
%
if isempty(xnloss),
	xnloss = zeros(size(xne));
end
xne = xne - xnloss;%The lossed electrons (runaway or magnetic ripple) do not participate to collisions and thus must be removed
%
if display_mode >=1,
   disp('-------------------------------------------------------------------------------------------------------------------');
   disp(['- Scenario name = ',tokname]);
   disp('-------------------------------------------------------------------------------------------------------------------');
	disp(['----------------------------------------------- Plasma parameters ------------------------------------------------']);
	disp(['- Plasma minor radius on LFS midplane (m) ap = ',num2str(ap)]);
	disp(['- Plasma major radius on axis (m) Rp = ',num2str(Rp)]);
	disp(['- Plasma elevation on axis (m) Zp = ',num2str(Zp)]);
	disp(['- Edge poloidal flux (Wb) = ',num2str(psia)]);
	disp(' ');
end
%
% ------------ Momentum Grid ----------- 
%
[pn,dpn,pnm,dpnm,pnp,dpnp,pn_S,mhu,dmhu,mhum,dmhum,mhup,dmhup,mhu_S] = momentumgrid_dke_jd(grid_uniformity,grid_power,dke_mode,r_dke,xmhu0T2,nmhu_S,np_S,pnmax_S,sfac,snmhu,snp,np_S_ref);
%
nmhu = length(mhu);
np = length(pn);
nr = length(xpsin);
nr_dke = length(r_dke);%number of points for dke calculations
display = [display_mode,ir_display,time_pause];%Display parameters
%
radial_mode = 0;
if ~isempty(transpfaste),%Radial transport without DKE calculations
	if  (transpfaste.Dr0~=0 | transpfaste.Vr0~=0) & nr > 1,
		dke_mode = 0;
		radial_mode = 1;
		norm_ref = 1;	
	end
end
%
if display_mode == 2, 
	h1000 = figure('Name','Pitch-angle grid');tilefigs_dke_yp(h1000);
	plot(1:nmhu,mhu,'bo',1:nmhu,mhum,'g*',1:nmhu,mhup,'r+');grid on;zoom on;
	axis([1,nmhu+1,-1,1])
	title('Pitch-angle grid');
	xlabel('Index');
	ylabel('mhu');
%
	h1001 = figure('Name','Momentum grid');tilefigs_dke_yp(h1001);
	plot(1:np,pn,'bo',1:np,pnm,'g*',1:np,pnp,'r+');grid on;zoom on; 
	axis([1,np+1,0,max(pnp)])
	title('Momentum grid');
	xlabel('Index');
	ylabel('pn');
%
	h1002 = figure('Name','Momentum step grid');tilefigs_dke_yp(h1002);
	semilogx(pn,dpn,'bo',pnm,dpnm,'g*',pnp,dpnp,'r+');grid on;zoom on; 
	title('Momentum mesh (grid step)');
	xlabel('pn');
	ylabel('dpn');

%	
	h1003 = figure('Name','Radial grid');tilefigs_dke_yp(h1003);
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
if syn_mode == 1
    info_dke_yp(2,'Synergy Mode = 1: Synergistic effects with bootstrap current calculated');
    disp('-------------------------------------------------------------------------------------------------------------------');
end
%
if display_mode >=1,
	disp(['--------------------------------------------- Simulation parameters ----------------------------------------------']);
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
	disp(' ');
	disp(' ');
	disp(['- Electron-electron collision operator: (0) Relativistic Maxwellian background, (1) High velicity limit, (2) Linearized Belaiev Budker (3) Lorentz model (4) Non-relativistic Maxwellian background coll_mode = ',num2str(coll_mode)]);
	disp(['- Bounce averaging option: (0) no bounce averaging, (1) bounce averaging bounce_mode = ',num2str(bounce_mode)]);
	disp(['- Fokker-Planck equation (0), Drift Kinetic equation (1) dke_mode = ',num2str(dke_mode)]);
	disp(' ');
	disp(['- Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes norm_mode_f = ',num2str(norm_mode_f)]);
	disp(['- Convergence level of the residu prec0_f = ',num2str(prec0_f)]);
	disp(['- Maximum number of iterations for f nit_f = ',num2str(nit_f)]);
	disp(['- Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) dtn = ',num2str(dtn)]);
	disp(['- Convergence level of the residu (if NaN, iterations stop with nit_g) nit_g = ',num2str(nit_g)]);
	disp(['- Maximum /number of iterations for g nit_g = ',num2str(nit_g)]);
	disp(['- Initial guess for the distribution function: (0) Maxwellian, (1) Fuchs model with Tperp for LH current drive only, (2) from a file initguess_f = ',num2str(initguess_f)]);
	disp(['- Temporary storing option for sparse matrices calculations (in RAM: 0, in disk file 1) store_mode = ',num2str(store_mode)]);
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
lnc_e_ref = 31.3 - 0.5*log(ne_ref) + log(Te_ref*1000);%Reference Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
nhu_ref = qe^4*ne_ref*lnc_e_ref/(4*pi*e0^2*me^2*(clum*betath_ref)^3);%Reference electron collision frequency (s-1)
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
xnloss_norm = xnloss/ne_ref;
%
xTen = xTe/mc2;
xzTin = xzTi/mc2;
%
xbetath = sqrt(xTen);%Normalized pth/mc as prescribed by Karney
xlnc_e = 31.3 - 0.5*log(xne) + log(xTe*1000);%Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
xnhu = qe^4*xne.*xlnc_e./(4*pi*e0^2*me^2.*(clum*xbetath).^3);%Electron collision frequency (s-1)
xrnhuth = xnhu./nhu_ref;
%
%***************************************** Ohmic electric field **********************************************
%
xepsi_ref_fsav_in = zeros(size(xrho));
Edreicer_ref = me*clum*betath_ref*nhu_ref/qe;%MKSA Dreicer field unit (V/m)
if ~isempty(ohm)
	xepsi_ref_fsav_in = interp1(rho2psi_jd(equil,ohm.rho),ohm.epsi,xrho,'spline')/Edreicer_ref;%Normalized to the Dreicer value
end
%
%****************************** Anomalous fast electron radial diffusion and pinch ***************************
%
XXDr_ref = zeros(np,nmhu,nr);%Defined on the distribution function grid (half grid)
XXVr_ref = zeros(np,nmhu,nr);%Defined on the distribution function grid (half grid)
%
if ~isempty(transpfaste),
	alphaD = ap*ap/psia/psia;%For radial diffusion normalization
	alphaV = ap/psia;%For radial convection normalization
%
    xvparmin_r_ref = transpfaste.vparmin*ones(size(xrho)).*xbetath/betath_ref;%Normalized to vth_ref
	xDr = transpfaste.Dr0*(1 + transpfaste.pDr*xrho.^2);
    xVr = transpfaste.Vr0*(1 + transpfaste.pVr*xrho.^2);
    %
	for ir = 1:nr,	
		ivpar_r_ref_threshold = min(find(abs(Xvpar_ref) >= xvparmin_r_ref(ir)));
   		xEc_r_ref_threshold(ir) = mc2*(sqrt(1+pn_ref(ivpar_r_ref_threshold).*pn_ref(ivpar_r_ref_threshold)*betath_ref^2) - 1);%in keV
%
   		if transpfaste.Dr_model==0,%No vpar dependence
			XDrv_ref = alphaD*xDr(ir)*ones(size(np,nmhu)).*(abs(Xvpar_ref) >= xvparmin_r_ref(ir))/nhu_ref/ap/ap;%Normalized to the central collision frequency
		elseif transpfaste.Dr_model==1,%Magnetic turbulence model: Dr(r)*vpar_ref/vth_ref
			XDrv_ref = alphaD*xDr(ir)*(abs(Xvpar_ref) - xvparmin_r_ref(ir)).*(abs(Xvpar_ref) >= xvparmin_r_ref(ir))/xvparmin_r_ref(ir)/nhu_ref/ap/ap;%Normalized to the central collision frequency
		end
		XXDr_ref(:,:,ir) = XDrv_ref;%3-D radial diffusion matrix (radial profile dependence)
		xmaxDr_ref(ir) = max(max(XXDr_ref(:,:,ir)));%Maximum value of the radial diffusion coefficient
%
		if transpfaste.Vr_model==0,%No vpar dependence
			XVrv_ref = alphaV*xVr(ir)*ones(size(np,nmhu)).*(abs(Xvpar_ref) >= xvparmin_r_ref(ir))/nhu_ref/ap;%Normalized to the central collision frequency
		elseif transpfaste.Vr_model==1,%Magnetic turbulence model: Vr(r) = Vr0(r)*vpar_ref/vth_ref
			XVrv_ref = alphaV*xVr(ir)*(abs(Xvpar_ref) - xvparmin_r_ref(ir)).*(abs(Xvpar_ref) >= xvparmin_r_ref(ir))/xvparmin_r_ref(ir)/nhu_ref/ap;%Normalized to the central collision frequency
		end
		XVrv_ref = XVrv_ref.*(abs(Xvpar_ref) >= xvparmin_r_ref(ir));
		XXVr_ref(:,:,ir) = XVrv_ref;%3-D radial pinch matrix (radial profile dependence)
		xmaxVr_ref(ir) = max(max(XXVr_ref(:,:,ir)));%Maximum value of the radial convection coefficient
    end
end
%
%********************* Loss term for the electrons trapped in the toroidal magnetic ripple ************************
%
XXlossripple_ref = zeros(np,nmhu,nr);%Defined on the distribution function grid (half grid)
xdeltaripple = zeros(size(xrho));
%
if ~isempty(ripple),
	xnhuloss_ref = ones(size(xrho))*1000/nhu_ref;%Normalized to the reference frequency(forced to very large loss frequency)
	for ir = 1:nr,
		if isnan(xnhuloss_ref(ir)) == 0 & bounce_mode == 1 & ~isempty(findstr(tokname,'TS')) == 1,%WARNING: only valid for the TORE SUPRA tokamak with large magnetic ripple
			if ir == 1, 
				info_dke_yp(2,'WARNING: Ripple losses calculations only valid for Tore Supra tokamak, see main_dke_1yp.m for BeLi, Ip and Ncoils values');
				disp('-------------------------------------------------------------------------------------------------------------------');
				Ip = 0.61;%MA (For magnetic equilibrium in the magnetic ripple routine)
				BeLi = 1.0;%For magnetic equilibrium in the magnetic ripple routine
			end
%			Ncoils = 1;%Ncoils is here forced to 1, as prescribed in Ref. M. Ju et al., Phys. Plasmas, 9 (2002) 493. Upper bound of ripple losses is then calculated
%			xNq(ir) = Ncoils*xq(ir);%Exact N may be used but large values may lead to numerical instabilities due to round-off errors
			[xthetabanana(ir),xthetaloss(ir),xpndetrap(ir),xEseuil(ir),xdeltaripple(ir)] = detrapmj3(xZeff(ir),ap,xBT0(ir),Rp,BeLi,Ip,xne(ir),xrho(ir));%WARNING: Only valid for the TORE SUPRA tokamak
			xpndetrap_ref(ir) = xpndetrap(ir)/betath_ref;
%
			xmhusupertrap(ir) = sin(pi*xthetaloss(ir)/180);
			Xmaskrip_ref = (Xpn_ref > xpndetrap_ref(ir)).*(abs(Xmhu) < xmhusupertrap(ir));
			Xnhuloss_ref = Xmaskrip_ref*xnhuloss_ref(ir);
		else
			if isnan(xnhuloss_ref(ir)) == 0 & bounce_mode == 1 & isempty(findstr(tokname,'TS')) == 1
				if ir == 1, 
					info_dke_yp(2,'WARNING: Ripple losses calculations only valid for Tore Supra tokamak. Wrong tokamak name');
					disp('-------------------------------------------------------------------------------------------------------------------');
				end
			elseif isnan(xnhuloss_ref(ir)) == 0 & bounce_mode == 0 & isempty(findstr(tokname,'TS')) == 0
				if ir == 1, 
					info_dke_yp(2,'WARNING: Ripple losses calculations only valid for bounce averaged calculations');
					disp('-------------------------------------------------------------------------------------------------------------------');
				end
			end	
%	
			xdeltaripple(ir) = 0;
			xNq(ir) = 0;
			Xnhuloss_ref = zeros(length(pn_ref),length(mhu));
            xthetabanana(ir) = 0;
            xthetaloss(ir) = 0;
            xpndetrap_ref(ir) = 0;
            xEseuil(ir) = 0;
		end
		XXlossripple_ref(:,:,ir) = Xnhuloss_ref;%Magnetic ripple loss term is expressed in a Krook term
	end
end
%
if isempty(XXsource),XXsource = zeros(np,nmhu,nr);end
XXsource_ref = XXsource/ne_ref/nhu_ref;%Source or sink terms
%
%***************************** RF Wave parameters calculations *************************************
%
[waveparam,xyprop_dke,xyPinc_in,yb] = ...
    rfwave_dke_jd(equil,waves,xpsin,xpsin_dke,xdpsin_dke,xpsin_S_dke,r_dke,...
    XR,XZ,XBR,XBZ,XBphi,ne_ref,lnc_e_ref,nmax_rf,dke_mode,display_mode);
%
%waveparam = [];
%yprop_dke = [];
%xyPinc_in = [];
%nb_list = [];
%yb = [];
%
%***************************** Initial distribution function **************************
%
XXfinit_ref = zeros(np,nmhu,nr);%Defined on the distribution function grid (half grid)
for ir = 1:nr,	
	if initguess_f == 1  & (isnan(xvparmin_lh_ref(ir_display)) == 1 | isnan(xvparmax_lh_ref(ir_display)) == 1 | nb_lh ~= 1 ),initguess_f = 0 ;end
%
	if initguess_f == 0 & isempty(XXf0_in) == 1,
		fM_ref = exp(-pn_ref.*pn_ref./(1 + gamma_ref)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));%Maxwellian distribution normalized to normalized density ne_norm (1st order gamma corrections)
		XfM_ref = fM_ref'*ones(1,nmhu);
		normfM_ref = 2*pi*integral_dke_jd(dpn_ref(:),pn_ref(:).*pn_ref(:).*integral_dke_jd(dmhu,XfM_ref,2),1);
		XfM_ref = xne_norm(ir)*XfM_ref/normfM_ref;
		Xf0_ref = XfM_ref;
		title_initguess = 'Relativistic Maxwellian';        
	elseif initguess_f == 1 & isempty(XXf0_in) == 1,
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
	else
		Xf0_ref = XXf0_in(:,:,ir);
		title_initguess = 'Initial distribution from input arguments';
	end
	XXfinit_ref(:,:,ir) = Xf0_ref;
end
%
% *************************** Display initial distribution function ***************************
%
if display_mode == 2,
	Fig_InitDistr = figure('Name','Initial distribution');	
	Fig_InitDistrp0 = figure('Name','Initial distribution at pperp=0');
	Fig_ElecVeloc = figure('Name','Electron velocity');
	Fig_MetRel = figure('Name','Metric relation');
    if radial_mode == 1,
       Fig_radialdiff = figure('Name','Fast electron radial diffusion'),
       Fig_radialpinch = figure('Name','Fast electron radial pinch')
       Fig_radialtranspvthreshold = figure('Name','Fast electron radial transport velocity threshold');
       Fig_fastetransp = figure('Name','Fast electron radial transport');
    end
end
%
for ir = 1:nr,	
	if display_mode == 2,
		if dke_mode == 1,
%
			view = 0;
%
			if ir == ir_display-1,
				figure(Fig_InitDistr),subplot(131);zoom on
				view = 1;
			elseif ir == ir_display,
				figure(Fig_InitDistr),subplot(132);zoom on
				view = 1;
			elseif ir == ir_display+1,
				figure(Fig_InitDistr),subplot(133);zoom on
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
				figure(Fig_InitDistrp0),subplot(231);zoom on
				view = 1;
			elseif ir == ir_display,
				figure(Fig_InitDistrp0),subplot(232);zoom on
				view = 1;
			elseif ir == ir_display+1,
				figure(Fig_InitDistrp0),subplot(233);zoom on
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
				figure(Fig_ElecVeloc),subplot(234);zoom on
				view = 1;
			elseif ir == ir_display,
				figure(Fig_ElecVeloc),subplot(235);zoom on
				view = 1;
			elseif ir == ir_display+1,
				figure(Fig_ElecVeloc),subplot(236);zoom on
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
				figure(Fig_InitDistr),subplot(132);zoom on
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
				figure(Fig_InitDistrp0),zoom on;;pause(time_pause)
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
				figure(Fig_ElecVeloc);zoom on;pause(time_pause)
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
				figure(Fig_radialdiff),subplot(121);zoom on;pause(time_pause)
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
				figure(Fig_radialpinch),subplot(121);zoom on,pause(time_pause)
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
	figure(Fig_MetRel),subplot(121),plot(xpsin,xrho,'r-.',xpsin,xrho,'b+');grid on;zoom on
	xlabel('psi/psia');ylabel('rho');title('Metric relation');
	axis('square');axis([0,1,0,1]);
	figure(Fig_MetRel),subplot(122),plot(xrho,xpsin,'r-.',xrho,xpsin,'b+');grid on;zoom on
	xlabel('rho');ylabel('psi/psia');title('Metric relation');
	axis('square');axis([0,1,0,1]);
	pause(time_pause);
end	
%
if radial_mode == 1 & display_mode == 2,
    figure(Fig_radialtranspvthreshold);%tilefigs_dke_yp(h1005);
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
    figure(Fig_fastetransp);%tilefigs_dke_yp(h1006);
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
%*********************************** Drift Kinetic calculations *********************************
%
nb = size(waveparam,2);
%
time0 = clock;
P_ref = me*(clum*betath_ref)^2*nhu_ref*ne_ref; %power normalization constant (W)
%
if ~isempty(waveparam), %initial value of the constant diffusion coefficient 
    xyD0_rf_in = waveparam(:,:,4);
    delta_rt = 0.5;
    wpe_ref = sqrt(ne_ref*qe^2/me/e0);
%
    if sum(sum(isnan(waveparam(:,:,13)))),
       xyPabs_rf_dke_fsav_mksa = 0;%initial absorbed power density estimate (Note, future work: could use linear theory)
    else
       xyPabs_rf_dke_fsav_mksa = waveparam(:,:,13).*waveparam(:,:,4).*waveparam(:,:,1)*me*lnc_e_ref*wpe_ref^2/(4*pi^2);
    end
%
    xyPinc_mod = xyPinc_in;
    xymask = (xyPinc_in == 0);
    xyPinc_in(xymask) = eps; %to avoid singularities
    if nit_rf > 1 & display_mode >= 1,
	   Fig_QLIter = figure('Name','Quasilinear iteration');
    end
else
    nit_rf = 1;
    xyPinc_mod = '';
end  
residue_rf = '';
%
%Local directory for temp saving
%
save_id = timeid_jd(clock);
if isempty(dkeparam.temppath),%Local saving
   mkdir(['tempdir_DKE_',save_id])
   temppath = ['tempdir_DKE_',save_id,filesep];
else
   mkdir([dkeparam.temppath,filesep,'tempdir_DKE_',save_id])
   temppath = [dkeparam.temppath,filesep,'tempdir_DKE_',save_id,filesep];
end
save([fullfile(temppath,'temp_DKE_'),save_id,'.mat'],'save_id')
%
if nit_rf > 1,%No radial transport for initial quasilinear iterations
    XXDr_ref_in = zeros(size(XXDr_ref));
    XXVr_ref_in = zeros(size(XXVr_ref));
else
    XXDr_ref_in = XXDr_ref;
    XXVr_ref_in = XXVr_ref;    
end
%
for it_rf=1:nit_rf % convergence in the ray-tracing mode

    if ~isempty(waveparam),%in the case of RF waves only
       xyPinc_mod_old = xyPinc_mod;
       [xyPinc_out,xyPinc_mod_new] = rfprop_dke_jd(yb,xyprop_dke,xyPinc_mod,xyPabs_rf_dke_fsav_mksa,xdV_dke,xpsin,xpsin_dke,r_dke,dke_mode);
%
       if 1,%it_rf > 1
          xyPinc_mod = delta_rt*xyPinc_mod + (1 - delta_rt)*xyPinc_mod_new;
       else
          xyPinc_mod = xyPinc_mod_new;
       end
%    
% The diffusion coefficient is proportional to the incident power
%
        xyD0_rf_mod = xyD0_rf_in.*xyPinc_mod./xyPinc_in;
        %
        if 0,%nit_rf > 1,
            if it_rf == 1,
                redfac = max(sum(xyPinc_mod.'))/sum(max(xyPinc_in(:,yb)));
            else
                redfac = redfac - 1;
            end
            %
            redfac = max([redfac,1]);
            %
        else
            redfac = 1;
        end
        waveparam(:,:,4) = xyD0_rf_mod./redfac;
    end     
%   
[XXheaviside,...
        XXf0_ref,XXf0_tp_ref,XXf0_g_ref,XXf0_L_tp_ref,XXf0_L_g_ref,...
        Znorm_ref,Zcurr_ref,ZP0_ref,...
        ZXXS_ref,ZYXXD_rf,...
        XxRR_ref_fsav,xMRR_flux_ref,xMRR_tau_ref,xRR_fsav,xnsource_ref,...
        xTe_norm_out,xft_fsav,xfteff_fsav,xmhubounce2,xepsi_ref,...
        memoryLU_f,memoryLU_g]...
    = dke_1_4yp(tokname,save_id,theta,...
        XR,XZ,XBR,XBZ,XBphi,...
        xB0,xR0,xBT0,xBp0,Rp,Zp,ap,...
        mhu,dmhu,mhum,dmhum,mhup,dmhup,mhu_S,...
        xmhu0T2,xrho,xpsin,xdpsin_dke,xpsinm_dke,xdpsinm_dke,xpsinp_dke,xdpsinp_dke,r_dke,xpsin_S_dke,...
        pn,dpn,pnm,dpnm,pnp,dpnp,pn_S,spfac,...
        xTe_norm,xne_norm,zZi,zmi,xzni_norm,xzTi_norm,xZeff,xlnc_e,xrnhuth,...
        betath_ref,xepsi_ref_fsav_in,waveparam,nmax_rf,...
        XXDr_ref_in,XXVr_ref_in,...
		XXsource_ref,XXlossripple_ref,...
        xftp_norm_ref,bounce,it_rf,xnloss_norm,coll_mode,...
        norm_mode_f,boundary_mode,dtn,prec0,nit,invparam,display,store_mode,temppath,XXfinit_ref);
%
    if ~isempty(waveparam),%In the case of RF waves and quasilinear iteration
       if nit_rf > 1,
    	  if dke_mode >= 1,
	         xyPabs_rf_dke_fsav_out = ZP0_ref.xy_rf_fsav + ZP0_ref.xy_rf_tp_fsav + ZP0_ref.xy_rf_g_fsav; % flux-surface averaged density of absorbed power.
	      else
	         xyPabs_rf_dke_fsav_out = ZP0_ref.xy_rf_fsav; % flux-surface averaged density of absorbed power.
	      end	    
          xyPabs_rf_dke_fsav_mksa = xyPabs_rf_dke_fsav_out*P_ref;
          if nit_rf > 1,
             xyPabs_rf_dke_fsav_mksa = xyPabs_rf_dke_fsav_mksa*redfac;
          end
%
          residue_rf(it_rf) = max(max(abs(xyPinc_mod - xyPinc_mod_old)./xyPinc_in));
		  if display_mode >= 1,
             figure(Fig_QLIter)        
             plot(1:it_rf,residue_rf,'r+')
             set(gca,'yscale','log')
             axis([0,nit_rf,1e-5,1])
             pause(0.5)
         end
 %
		 info_dke_yp(2,'---------------------------------------------------------');
         info_dke_yp(2,['Quasilinear iteration : ',int2str(it_rf),', Residu = ',num2str(residue_rf(it_rf)),', delta_rt = ',num2str(delta_rt)]);
		 info_dke_yp(2,'---------------------------------------------------------');
 %
         if 0,it_rf > 2 & residue_rf(it_rf-1) < prec_rf*10,
            delta_rt = 0;s
         end
 %      
         if residue_rf(it_rf) < 0.01,          
%           delta_rt = delta_rt/1.1;%For increasing the quasilinear rate of convergence
            if ~isempty(XXDr_ref) == 1 | ~isempty(XXVr_ref) == 1,%If radial transport is no zero, it is turned on when quasilinear convergence is robust enough
               param_inv(1) = 1e-4;
               XXDr_ref_in = XXDr_ref;
               XXVr_ref_in = XXVr_ref;
            end
         end     
  %      
         if residue_rf(it_rf) <= prec_rf & it_rf > 10 & redfac == 1,
            info_dke_yp(2,['Successfull convergence achieved for ray-tracing coupling after ',int2str(it_rf),' iterations !']);
            break
         else
           info_dke_yp(2,['Iteration ',int2str(it_rf),', residue = ',num2str(residue_rf(it_rf))]);            
         end
      end
   end
end
%
%   RF wave quasilinear diffusion
%
if ~isempty(waveparam),%In the case of RF waves and quasilinear iteration
    blist_lh = find(round(waveparam(1,:,1)./(qe*min(xB0)/me)) == 0);
    nb_lh = length(blist_lh);
    waveparam_lh = waveparam(:,blist_lh,:);
    blist_ec = find(round(waveparam(1,:,1)./(qe*min(xB0)/me)) > 0);
    nb_ec = length(blist_ec);
    waveparam_ec = waveparam(:,blist_ec,:);
%
%For displaying RF quasilinear domain only
%
   if nb_ec > 0,
      xDperp_cy_ref = waveparam_ec(:,1,4);
   end
   if nb_lh > 0,
      xD0_lh_ref = waveparam_lh(:,1,4);
      xvparmin_lh_ref = 1./waveparam_lh(:,1,6)/betath_ref;
      xvparmax_lh_ref = 1./waveparam_lh(:,1,5)/betath_ref;
   end
else 
    nb_lh = 0;
    nb_ec = 0;
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
%   Bootstrap Current Calculations (for synergy calculations)
%
if syn_mode == 1,
    time0_bc = clock;
    %
    waveparam_bc = [];
    xepsi_bc_ref_fsav_in = zeros(1,nr);
    %
    [XXheaviside_bc,...
        XXf0_bc_ref,XXf0_bc_tp_ref,XXf0_bc_g_ref,XXf0_bc_L_tp_ref,XXf0_bc_L_g_ref,...
        Znorm_bc_ref,Zcurr_bc_ref,ZP0_bc_ref,...
        ZXXS_bc_ref,ZYXXD_bc_rf,...
        XxRR_bc_ref_fsav,xMRR_flux_bc_ref,xMRR_tau_bc_ref,xRR_bc_fsav,xnsource_bc_ref,...
        xTe_norm_bc_out,xft_bc_fsav,xfteff_bc_fsav,xmhubounce2_bc,xepsi_bc_ref,...
        memoryLU_bc_f,memoryLU_bc_g]...
    = dke_1_4yp(tokname,save_id,theta,...
        XR,XZ,XBR,XBZ,XBphi,...
        xB0,xR0,xBT0,xBp0,Rp,Zp,ap,...
        mhu,dmhu,mhum,dmhum,mhup,dmhup,mhu_S,...
        xmhu0T2,xrho,xpsin,xdpsin_dke,xpsinm_dke,xdpsinm_dke,xpsinp_dke,xdpsinp_dke,r_dke,xpsin_S_dke,...
        pn,dpn,pnm,dpnm,pnp,dpnp,pn_S,spfac,...
        xTe_norm,xne_norm,zZi,zmi,xzni_norm,xzTi_norm,xZeff,xlnc_e,xrnhuth,...
        betath_ref,xepsi_bc_ref_fsav_in,waveparam_bc,nmax_rf,...
        XXDr_ref,XXVr_ref,...
		XXsource_ref,XXlossripple_ref,...
        xftp_norm_ref,bounce,1,xnloss_norm,coll_mode,...
        norm_mode_f,boundary_mode,dtn,prec0,nit,invparam,display,store_mode,temppath,XXfinit_ref);
%
    time_bc_out = etime(clock,time0_bc);
    memoryLU_bc_f_out = memoryLU_bc_f;
    memoryLU_bc_g_out = memoryLU_bc_g;
%
    if display_mode >= 1,
        if dke_mode == 0,
            info_dke_yp(2,['Full elapsed time for solving the electron Fokker-Planck equation (Bootstrap Calc. Only): ',num2str(time_bc_out),' (s)']) 
        else
            info_dke_yp(2,['Full elapsed time for solving the electron Drift Kinetic equation (Bootstrap Calc. Only): ',num2str(time_bc_out),' (s)']) 
        end
        disp('-------------------------------------------------------------------------------------------------------------------');
    end
%
end
%
delete([fullfile(temppath,'temp_DKE_'),save_id,'.mat']);%Delete large temporary data file on disk
for iy = 1:nb,
    ynum = num2str(iy);
    eval(['delete ',fullfile(temppath,'temp_DQL_'),save_id,'_',ynum,'.mat']);
end
%
%Build the radial structure for output
%
radial.xrho = xrho;
radial.ap = ap;
radial.Rp = Rp;
radial.Zp = Zp;
radial.xdV_dke = xdV_dke;
radial.xdA_dke = xdA_dke;
radial.xpsin = xpsin;
radial.xpsin_dke = xpsin_dke;
radial.psia = psia;
radial.xdpsin_dke = xdpsin_dke;
radial.xpsin_S_dke = xpsin_S_dke;
radial.xmhu0T2 = xmhu0T2;
radial.r_dke = r_dke;
radial.ir_display = ir_display;
%
%Build the momentum structure for output
%
momentum.pn = pn;
momentum.dpn = dpn;
momentum.pnm = pnm;
momentum.dpnm = dpnm;
momentum.pnp = pnp;
momentum.dpnp = dpnp; 
momentum.pn_S = pn_S;
momentum.mhu = mhu;
momentum.dmhu = dmhu;
momentum.mhum = mhum;
momentum.dmhum = dmhum;
momentum.mhup = mhup;
momentum.dmhup = dmhup;
momentum.mhu_S = mhu_S;
%
%Build the mksa and reference structure for output
%
mksa.betath_ref = betath_ref;
mksa.Te_ref = Te_ref;%Temperature (keV)
mksa.ne_ref = ne_ref;%Density (m-3)
mksa.nhu_ref = nhu_ref;%Reference electron collision frequency (s-1)
mksa.lnc_e_ref = lnc_e_ref;%Reference Coulomb logarithm
mksa.xftp_norm_ref = xftp_norm_ref;%Normalization factor for drift kinetic equation (ftilde)
mksa.P_ref = P_ref/1e6;%MKSA power unit (MW)
mksa.j_ref = qe*clum*betath_ref*ne_ref/1e6;%MKSA current unit (MA)
mksa.Edreicer_ref = me*clum*betath_ref*nhu_ref/qe;%MKSA Dreicer field unit
mksa.Ec_ref = Ec_ref;%Fast electron kinetic energy in keV
%
% DKE data output structure
%
dke_out.XXheaviside = XXheaviside;
dke_out.XXfinit_ref = XXfinit_ref;
dke_out.XXf0_ref = XXf0_ref;
dke_out.XXf0_tp_ref = XXf0_tp_ref;
dke_out.XXf0_g_ref = XXf0_g_ref;
dke_out.XXf0_L_tp_ref = XXf0_L_tp_ref;
dke_out.XXf0_L_g_ref = XXf0_L_g_ref;
dke_out.Znorm_ref = Znorm_ref;
dke_out.Zcurr_ref = Zcurr_ref;
dke_out.ZP0_ref = ZP0_ref;
dke_out.ZXXS_ref = ZXXS_ref;
dke_out.ZYXXD_rf = ZYXXD_rf;
dke_out.XxRR_ref_fsav = XxRR_ref_fsav;
dke_out.xMRR_flux_ref = xMRR_flux_ref;
dke_out.xMRR_tau_ref = xMRR_tau_ref;
dke_out.xTe_norm_out = xTe_norm_out;
dke_out.xft_fsav = xft_fsav;
dke_out.xfteff_fsav = xfteff_fsav;
dke_out.xmhubounce2 = xmhubounce2;
dke_out.xepsi_ref = xepsi_ref;
dke_out.memoryLU_f_out = memoryLU_f_out;
dke_out.memoryLU_g_out = memoryLU_g_out;
dke_out.time_out = time_out;
dke_out.XXDr_ref = XXDr_ref;
dke_out.XXVr_ref = XXVr_ref;  
dke_out.xTe_norm = xTe_norm;
dke_out.xzTi_norm = xzTi_norm;
dke_out.xne_norm = xne_norm;
dke_out.xzni_norm = xzni_norm;
if ~isempty(ripple),
    dke_out.xthetabanana = xthetabanana;
    dke_out.xthetaloss = xthetaloss;
    dke_out.xpndetrap_ref = xpndetrap_ref;
    dke_out.xEseuil = xEseuil;
    dke_out.XXlossripple_ref = XXlossripple_ref;
    dke_out.xdeltaripple = xdeltaripple;
end
dke_out.waveparam = waveparam;
dke_out.xyprop_dke = xyprop_dke;
dke_out.xyPinc_mod = xyPinc_mod;
dke_out.residue_rf = residue_rf;
dke_out.yb = yb;
dke_out.XXsource_ref = XXsource_ref;
dke_out.xRR_fsav = xRR_fsav;
dke_out.xnsource_ref = xnsource_ref;
%
if syn_mode == 1,
    dke_out.XXheaviside_bc = XXheaviside_bc;
    dke_out.XXf0_bc_ref = XXf0_bc_ref;
    dke_out.XXf0_bc_tp_ref = XXf0_bc_tp_ref;
    dke_out.XXf0_bc_g_ref = XXf0_bc_g_ref;
    dke_out.XXf0_bc_L_tp_ref = XXf0_bc_L_tp_ref;
    dke_out.XXf0_bc_L_g_ref = XXf0_bc_L_g_ref;
    dke_out.Znorm_bc_ref = Znorm_bc_ref;
    dke_out.Zcurr_bc_ref = Zcurr_bc_ref;
    dke_out.ZP0_bc_ref = ZP0_bc_ref;
    dke_out.ZXXS_bc_ref = ZXXS_bc_ref;
    dke_out.ZYXXD_bc_rf = ZYXXD_bc_rf;
    dke_out.XxRR_bc_ref_fsav = XxRR_bc_ref_fsav;
    dke_out.xMRR_flux_bc_ref = xMRR_flux_bc_ref;
    dke_out.xMRR_tau_bc_ref = xMRR_tau_bc_ref;
    dke_out.xTe_norm_bc_out = xTe_norm_bc_out;
    dke_out.xft_bc_fsav = xft_bc_fsav;
    dke_out.xfteff_bc_fsav = xfteff_bc_fsav;
    dke_out.xmhubounce2_bc = xmhubounce2_bc;
    dke_out.xepsi_bc_ref = xepsi_bc_ref;
    dke_out.memoryLU_bc_g_out = memoryLU_bc_g_out;
    dke_out.memoryLU_bc_f_out = memoryLU_bc_f_out;
    dke_out.time_bc_out = time_bc_out;
    dke_out.xnsource_bc_ref = xnsource_bc_ref;
    dke_out.xRR_bc_fsav = xRR_bc_fsav;
else
    dke_out.XXheaviside_bc = [];
    dke_out.XXf0_bc_ref = [];
    dke_out.XXf0_bc_tp_ref = [];
    dke_out.XXf0_bc_g_ref = [];
    dke_out.XXf0_bc_L_tp_ref = [];
    dke_out.XXf0_bc_L_g_ref = [];
    dke_out.Znorm_bc_ref = [];
    dke_out.Zcurr_bc_ref = [];
    dke_out.ZP0_bc_ref = [];
    dke_out.ZXXS_bc_ref = [];
    dke_out.ZYXXD_bc_rf = [];
    dke_out.XxRR_bc_ref_fsav = [];
    dke_out.xMRR_flux_bc_ref = [];
    dke_out.xMRR_tau_bc_ref = [];
    dke_out.xTe_norm_bc_out = [];
    dke_out.xft_bc_fsav = [];
    dke_out.xfteff_bc_fsav = [];
    dke_out.xmhubounce2_bc = [];
    dke_out.xepsi_bc_ref = [];
    dke_out.memoryLU_bc_g_out = [];
    dke_out.memoryLU_bc_f_out = [];
    dke_out.time_bc_out = [];
    dke_out.xnsource_bc_ref = [];
    dke_out.xRR_b_fsav = [];
end
%
if isempty(dkeparam.temppath),%Remove temporary file on the disk
   rmdir(['tempdir_DKE_',save_id],'s')
else
   rmdir([dkeparam.temppath,filesep,'tempdir_DKE_',save_id],'s')
end

