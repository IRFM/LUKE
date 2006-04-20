function  [Zbremplasma] = bremsstrahlung_dke_yp(dkeparam,display,equilDKE,radialDKE,mksa,momentumDKE,dke_out,Zbremchord,hxr,hxrparam)
%
% Calculates the plasma bremsstrahlung emission. Call first the function bremchord_dke_yp.m
%
%   INPUTS:
%   
%       - Zbremchord: HXR diagnostic chord arrangement data structure
%       - equilDKE: DKE magnetic equilibrium structure
%       - hxr: Bremsstrahlung structure
%       - hxrparam : Bremsstrahlung calculation and display parameter structure
%       - dkeparam: DKE data structure
%       - radialDKE: DKE radial grid structure   
%       - mksa: MKSA structure   
%       - momentumDKE: DKE momentum structure
%       - dke_out: DKE data output structure (distributions)
%       
%   OUTPUTS:
%   
%      - Zbremplasma: Plasma bremsstrahlung data structure
%         * Zbremplasma.kphot : photon energies (keV) [1,nk]
%         * Zbremplasma.brem_bd_out : photon number per unit energy (keV) and time (s) for each chord [nchord,nk]
%         * Zbremplasma.lchord : chord length (m) [1,nchord]
%
% by Joan Decker <jodecker@mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
if nargin < 10,
   error('Not enough input arguments in bremshtrahlung_dke_yp')
end
%	
vschords = Zbremchord.vschords;
psin_hxr = Zbremchord.psin_hxr;
theta_hxr = Zbremchord.theta_hxr;
PSI_hxr = Zbremchord.PSI_hxr;
mask_hxr = Zbremchord.mask_hxr;
Ipdir_mfl_lcs = Zbremchord.Ipdir_mfl_lcs;
%
ne_ref = mksa.ne_ref;
betath_ref = mksa.betath_ref;
Ec = mksa.Ec_ref;
%
dmhu = momentumDKE.dmhu;
mhu = momentumDKE.mhu;
dpn = momentumDKE.dpn;
pn = momentumDKE.pn;
%
r_dke = radialDKE.r_dke;
%
pnmax_S = dkeparam.pnmax_S;
bounce_mode = dkeparam.bounce_mode;
%
theta = equilDKE.mtheta;
xpsin = equilDKE.xpsin;
psia = equilDKE.psia;
XR = equilDKE.XR;
XZ = equilDKE.XZ;
XBR = equilDKE.XBR;
XBZ = equilDKE.XBZ;
XBphi = equilDKE.XBphi;
xB0 = equilDKE.xB0;
xR0 = equilDKE.xR0;
xBT0 = equilDKE.xBT0;
xBp0 = equilDKE.xBp0;
xrho = equilDKE.xrho;
xTe = equilDKE.xTe;
xne = equilDKE.xne;
xzTi = equilDKE.xzTi;
xzni = equilDKE.xzni;
zZi = equilDKE.zZi;
zmi = equilDKE.zmi;
xZeff = equilDKE.xZeff;
Rp = equilDKE.Rp;
Zp = equilDKE.Zp;
ap = equilDKE.ap;
xmhu0T2 = equilDKE.xmhu0T2;
xdV_dke = equilDKE.xdV_dke;
xdA_dke = equilDKE.xdA_dke;
%
xzni_norm = xzni(:,r_dke)/ne_ref;
xne_norm = xne(r_dke)/ne_ref;
xrho = xrho(r_dke);
%
XXfinit = dke_out.XXfinit(:,:,r_dke);
XXf0 = dke_out.XXf0(:,:,r_dke);
XXf0_tp = dke_out.XXf0_tp(:,:,r_dke);
XXf0_g = dke_out.XXf0_g(:,:,r_dke);
%
pn2 = pn.*pn;
gamma = sqrt(1 + pn2*betath_ref^2);
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
method = 'spline';
n_gauleg = hxrparam.n_gauleg;
n_pol = n_gauleg;%Necessary for accurate reconstruction at ksi = -1
epsi_gauleg = hxrparam.epsi_gauleg;
kphot = hxr.kphot;
%   
ZZIB = zeros(size(psin_hxr,1),size(psin_hxr,2),n_pol+1,length(kphot));%Legendre coefficients for the bremsstrahlung at all radii at poloidal positions (NaN if not used)
norm0_hxr = zeros(size(psin_hxr,1),size(psin_hxr,2)) + NaN;%Norm of the initial distribution function (NaN if not used)
normi_hxr = zeros(size(psin_hxr,1),size(psin_hxr,2)) + NaN;%Norm of the reconstructed distribution function (NaN if not used)
%
% Legendre polynomials and related coefficients
%
[x_leg,w_leg] = gauleg_dke_yp(n_gauleg,epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
[Pm,cL] = leg_dke_yp(x_leg(:)',n_pol);%Legendre polynomial calculation
%
x_forward = 1;%Forward emission
[Pm_forward] = leg_dke_yp(x_forward(:)',n_pol);%Legendre polynomial for the forward emission
x_backward = -1;%Backward emission
[Pm_backward] = leg_dke_yp(x_backward(:)',n_pol);%Legendre polynomial for the backward emission
x_perp = 0;%Perpendicular emission
[Pm_perp] = leg_dke_yp(x_perp(:)',n_pol);%Legendre polynomial for the perpendicular emission
%
Zbremplasma.xrho = xrho;
Zbremplasma.theta_hxr = theta_hxr;
Zbremplasma.x_leg = x_leg;
Zbremplasma.w_leg = w_leg;
Zbremplasma.Pm = Pm;
Zbremplasma.cL = cL;
%
%Bremsstrahlung cross-section calculations
%
for i = 1:length(zZi),
	seBHE(:,:,:,i) = bhe_dke_yp(Ec,kphot,x_leg,zZi(i));%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert) (mec2 -> keV units)
end
seHC = haug_dke_yp(Ec,kphot,x_leg);%Electron-electron bremsstrahlung (Haug-Coulomb) (mec2 -> keV units)
%
Zbremplasma.seBHE = seBHE;
Zbremplasma.seHC = seHC;
%
%Gauss-Legendre projection for the bremsstrahlung cross-sections
%
seBHE_c=(reshape(seBHE,n_gauleg,size(seBHE,2)*size(seBHE,3)*size(seBHE,4))'.*(w_leg*ones(1,size(seBHE,2)*size(seBHE,3)*size(seBHE,4)))')*Pm';
seHC_c=(reshape(seHC,n_gauleg,size(seBHE,2)*size(seBHE,3))'.*(w_leg*ones(1,size(seHC,2)*size(seHC,3)))')*Pm';
%
%For test only
Zbremplasma.seBHE1 = reshape((Pm'*(seBHE_c.*(ones(size(seBHE,2)*size(seBHE,3)*size(seBHE,4),1)*cL'))'),size(seBHE,1),size(seBHE,2),size(seBHE,3),size(seBHE,4));
Zbremplasma.seHC1 = reshape((Pm'*(seHC_c.*(ones(size(seHC,2)*size(seHC,3),1)*cL'))'),size(seHC,1),size(seHC,2),size(seHC,3));
Zbremplasma.epsiBHE = (seBHE-Zbremplasma.seBHE1)./seBHE;Zbremplasma.epsiBHE(isnan(Zbremplasma.epsiBHE)==1)=0;
Zbremplasma.epsiHC = (seHC-Zbremplasma.seHC1)./seHC;Zbremplasma.epsiHC(isnan(Zbremplasma.epsiHC)==1)=0;
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
            Zbremplasma.mhu_hxr{i,j} = mhu_hxr;
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
			Zbremplasma.Znorm0_hxr{i,j} = norm0_hxr(i,j);
			Zbremplasma.Znormi_hxr{i,j} = normi_hxr(i,j);
			Zbremplasma.ZXf0_hxr{i,j} = Xf0_hxr;
			Zbremplasma.ZXf0_i{i,j} = Xf0_i;
			Zbremplasma.ZXf0_i1{i,j} = Xf0_i1;
%
% Local bremsstrahlung properties (forward and backward with respect to B direction or p// since p// is taken positive)
%
			Zbremplasma.brem_forward{i,j} = permute(reshape(Pm_forward'*(squeeze(ZZIB(i,j,:,:))'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))',1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Forward emission
			Zbremplasma.brem_backward{i,j} = permute(reshape(Pm_backward'*(squeeze(ZZIB(i,j,:,:))'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))',1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Backward emission
			Zbremplasma.brem_perp{i,j} = permute(reshape(Pm_perp'*(squeeze(ZZIB(i,j,:,:))'.*(ones(size(IB_c1,2)*size(IB_c1,3),1)*cL'))',1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Perpendicular emission
			Zbremplasma.brem_4pi{i,j} = permute(reshape(squeeze(ZZIB(i,j,1,:))/2,1,size(IB_c1,2),size(IB_c1,3)),[2,3,1]);%Mean 4pi emission per steradian				
		end
%
		info_dke_yp(2,['Bremsstrahlung integral #',int2str((i-1)*size(psin_hxr,2) + j),'/',int2str(size(psin_hxr,1)*size(psin_hxr,2)),' done']);
	end
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
	[Pm_bd] = leg_dke_yp(sksid,n_pol);%Legendre polynomial for the cosine of the angle between magnetic field line and line of sight (negative sign because electrons are flowing in the opposite direction to the plasma current)
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
    if display.display_mode >= 1,
	   info_dke_yp(2,['Line integration for chord #',int2str(ic),'/',int2str(size(vschords,3)),' done']);
    end
end	
%
Zbremplasma.kphot = kphot;
Zbremplasma.brem_bd_out = brem_bd_out;
Zbremplasma.lchord = lchord;
