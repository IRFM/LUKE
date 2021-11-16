function  [Zbremplasma] = bremsstrahlung_dke_yp(equilHXR,mksa,momentumDKE,Zmomcoef,XXf0,hxrparam,dkedisplay,fieldside)
%
% R5-X2 - Calculation of  the plasma bremsstrahlung emissivity
%
% Calculates the plasma bremsstrahlung emissivity. 
%
%   INPUTS:
%   
%       - equilHXR: LUKE magnetic equilibrium structure for HXR
%       - mksa: MKSA structure   
%       - momentumDKE: LUKE momentum structure
%       - Zmomcoef: additional LUKE momentum structure
%       - XXf0: LUKE distribution function
%       - hxrparam : Bremsstrahlung calculation and display parameter structure
%       - dkedisplay: DKE display structure
%       - fieldside: HFS or LFS limit
%       
%   OUTPUTS:
%   
%      - Zbremplasma: Plasma bremsstrahlung data structure
%         * Zbremplasma.kphot : photon energies (keV) [1,nk]
%         * Zbremplasma.brem_bd_out : photon number per unit energy (keV) and time (s) for each chord [nchord,nk]
%         * Zbremplasma.lchord : chord length (m) [1,nchord]
%
% by Joan Decker (CEA/IRFM,joan.decker@cea.fr) and Yves Peysson(CEA/IRFM,yves.peysson@cea.fr)
%
if ~ismember('mute_bremsstrahlung_dke_yp', who('global'))
    mute_bremsstrahlung_dke_yp = 0;
else
    global mute_bremsstrahlung_dke_yp
end
%
if nargin < 8,
    fieldside = '';
end
if nargin < 7,
    dkedisplay.display_mode = 0;
end
if nargin < 6,
   error('Not enough input arguments in bremshtrahlung_dke_yp')
end
%
if ~isfield(Zmomcoef,'Ec_ref'),% for older LUKE simulations
    if isfield(mksa,'Ec_ref'),
        Zmomcoef.Ec_ref = mksa.Ec_ref;
    else
        error('Kinetic energy data missing. Please correct manually.')
    end
end    
%
ne_ref = mksa.ne_ref;
betath_ref = mksa.betath_ref;
%
mhu = momentumDKE.mhu;
dpn = momentumDKE.dpn;
pn = momentumDKE.pn;
%
pn2 = pn.*pn;
np = length(pn);
%
Ec = Zmomcoef.Ec_ref;
gamma = Zmomcoef.gamma;
%
xpsin = equilHXR.xpsin;
theta = equilHXR.mtheta;
xrho = equilHXR.xrho;
XB = sqrt(equilHXR.XBx.^2 + equilHXR.XBy.^2 + equilHXR.XBphi.^2);
xB0 = equilHXR.xB0;%XB(:,1).';% old value, true only for circular FS 
xne = equilHXR.xne;
xzni = equilHXR.xzni;
zZi = equilHXR.zZi;
nZ = length(zZi);
%
nr = length(xpsin);
%
xzni_norm = xzni/ne_ref;
xne_norm = xne/ne_ref;
%
[~,~,~,~,~,~,~,mc2,clum] = pc_dke_yp;%Physics constant
%
method = 'spline';
n_gauleg = hxrparam.n_gauleg;
n_pol = n_gauleg;%Necessary for accurate reconstruction at ksi = -1
epsi_gauleg = hxrparam.epsi_gauleg;
kphot = hxrparam.kphot;
nk = length(kphot);
%
theta_hxr = ones(nr,1)*(theta(1:end-1) + theta(2:end))/2;% poloidal location for bremsstrahlung calculation
nt = size(theta_hxr,2);
psin_hxr = xpsin.'*ones(1,nt);% radial location for bremsstrahlung calculation
%
Xr = sqrt(equilHXR.Xx.^2 + equilHXR.Xy.^2);
r_hxr = interp1(theta,Xr.',theta_hxr(1,:)).';
% %
PSI_hxr = griddata(xpsin.',theta,XB.',psin_hxr,theta_hxr)./(xB0.'*ones(1,nt));%B/Bmin
%   
ZZIB = zeros(nr,nt,n_pol+1,nk);%Legendre coefficients for the bremsstrahlung at all radii at poloidal positions (NaN if not used)
%
% Legendre polynomials and related coefficients
%
[x_leg,w_leg] = gauleg_dke_yp(n_gauleg,epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
[Pm,cL] = leg_dke_yp(x_leg(:).',n_pol);%Legendre polynomial calculation
%
x_forward = 1;%Forward emission
[Pm_forward] = leg_dke_yp(x_forward(:).',n_pol);%Legendre polynomial for the forward emission
x_backward = -1;%Backward emission
[Pm_backward] = leg_dke_yp(x_backward(:).',n_pol);%Legendre polynomial for the backward emission
x_perp = 0;%Perpendicular emission
[Pm_perp] = leg_dke_yp(x_perp(:).',n_pol);%Legendre polynomial for the perpendicular emission
%
Zbremplasma.xrho = xrho;
Zbremplasma.r_hxr = r_hxr;
Zbremplasma.theta_hxr = theta_hxr;
Zbremplasma.x_leg = x_leg;
Zbremplasma.w_leg = w_leg;
Zbremplasma.Pm = Pm;
Zbremplasma.cL = cL;
%
%Bremsstrahlung cross-section calculations
%
seBHE = zeros(n_gauleg,np,nk,nZ);
%
if isfield(equilHXR,'screening') && ~isempty(equilHXR.screening)
    %
    if isfield(equilHXR.screening,'params') && ~isempty(equilHXR.screening.params)
        screening_hxr_params = equilHXR.screening.params;
    else
        screening_hxr_params = '';
    end
    %
    if isfield(equilHXR.screening,'smodel') && ~isempty(equilHXR.screening.smodel)
        screening_model = equilHXR.screening.smodel;
    else
        screening_model = '';
    end  
    %
else
    %
    screening_hxr_params = '';    
    screening_model = ''; 
    %
end
%
%
seBHE(:,:,:,1) = bhe_dke_yp(Ec,kphot,x_leg,zZi(1));%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert) with screening effect (mec2 -> keV units). No screening effect considered for hydrogen
%
seBHE(:,:,:,2) = seBHE(:,:,:,1);% Deuterium
seBHE(:,:,:,3) = seBHE(:,:,:,1);% Tritium
%
if isfield(equilHXR,'Znucleus') %ADAS
    %
    jZ = 4;
    %
    for iZ = length(equilHXR.Znucleus)-3:length(equilHXR.Znucleus)
        %
        Z0 = [0:1:equilHXR.Znucleus(iZ)];%all ionization states
        %
        if isstruct(screening_hxr_params) && isstruct(screening_model) % screening effect
            %
            eval(['load seBHE_',int2str(equilHXR.Znucleus(iZ)),'_',screening_model.screening_model,'.mat']);%load table of precalculated cross-sections
            %
            if isequal(seBHE_table.kphot,kphot) && isequal(seBHE_table.x_leg,x_leg) && isequal(seBHE_table.Z0,Z0) && isequal(seBHE_table.screening_model.screening_model,screening_model.screening_model)
                %
                seBHE(:,:,:,jZ:jZ+length(Z0)-1) = interp_seBHE_yp(seBHE_table,Ec);
                %
            else
                %
                error('seBHE table is inconsistent with required calculations by R5-X2. Check kphot, x_leg and screening model.');
                %
            end
            %
            jZ = jZ+length(Z0);
            %
            if mute_bremsstrahlung_dke_yp == 0
                disp(['Bremsstrahlung for Z = ',int2str(equilHXR.Znucleus(iZ)),' with partial screening is calculated.']);
            end
            %
        else
            %
            for iZ0 = 1:length(Z0)
                %
                seBHE(:,:,:,jZ) = bhe_dke_yp(Ec,kphot,x_leg,Z0(iZ0),screening_hxr_params,screening_model);%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert) with screening effect (mec2 -> keV units)
                jZ = jZ + 1;
                %
            end
            %
            if mute_bremsstrahlung_dke_yp == 0
                disp(['Bremsstrahlung for Z = ',int2str(equilHXR.Znucleus(iZ)),' with full screening is calculated.']);
            end
            %
        end
        %
    end
else
    %
    if nZ > 3
        for iZ = 4:nZ
            seBHE(:,:,:,iZ) = bhe_dke_yp(Ec,kphot,x_leg,zZi(iZ),screening_hxr_params,screening_model);%Electron-ion bremsstrahlung (Bethe-Heitler-Elwert) with screening effect (mec2 -> keV units)
        end
    end
    %
end
%
seHC = haug_dke_yp(Ec,kphot,x_leg);%Electron-electron bremsstrahlung (Haug-Coulomb) (mec2 -> keV units)
%
Zbremplasma.seBHE = seBHE;
Zbremplasma.seHC = seHC;
%
%Gauss-Legendre projection for the bremsstrahlung cross-sections
%
seBHE_c=(reshape(seBHE,n_gauleg,np*nk*nZ).'.*(w_leg*ones(1,np*nk*nZ)).')*Pm.';
seHC_c=(reshape(seHC,n_gauleg,np*nk).'.*(w_leg*ones(1,np*nk)).')*Pm.';
%
%%%%%%%%%% For test only (beginning section) %%%%%%%%%%%%%%
%
Zbremplasma.seBHE1 = reshape((Pm.'*(seBHE_c.*(ones(np*nk*nZ,1)*cL.')).'),n_gauleg,np,nk,nZ);
Zbremplasma.seHC1 = reshape((Pm.'*(seHC_c.*(ones(np*nk,1)*cL.')).'),n_gauleg,np,nk);
Zbremplasma.epsiBHE = (seBHE-Zbremplasma.seBHE1)./seBHE;
Zbremplasma.epsiBHE(isnan(Zbremplasma.epsiBHE)) = 0;
Zbremplasma.epsiHC = (seHC-Zbremplasma.seHC1)./seHC;
Zbremplasma.epsiHC(isnan(Zbremplasma.epsiHC)) = 0;
%
%%%%%%%%%% For test only (end section) %%%%%%%%%%%%%%
%
seBHE_c1 = repmat(reshape(seBHE_c.',n_pol+1,np,nk,nZ),[1,1,1,1,nr]);
ni_c1 = shiftdim(repmat(xzni_norm,[1,1,n_pol+1,np,nk]),2);
BHE_c1 = permute(sum(seBHE_c1.*ni_c1,4),[1,2,3,5,4]);%Sum over different species
%
seHC_c1 = repmat(reshape(seHC_c.',n_pol+1,np,nk),[1,1,1,nr]);
%
if ~isempty(screening_hxr_params) && ~isempty(screening_model)
    %
    xne_norm_mod = xne_norm' + sum(xzni_norm'.*(ones(length(xne),1)*equilHXR.zNbound),2);%bound electrons are considered as free for e-e bremstrahlung
    %
else
    %
    xne_norm_mod = xne_norm';
    %
end
%
ne_c1 = shiftdim(repmat(xne_norm_mod,[1,n_pol+1,np,nk]),1); 
%
HC_c1 = seHC_c1.*ne_c1;
%
BREM_c1 = BHE_c1 + HC_c1;
%
pn_c1 = permute(repmat(pn(:),[1,n_pol+1,length(kphot),1]),[2,1,3,4]);
gamma_c1 = permute(repmat(gamma(:),[1,n_pol+1,length(kphot),1]),[2,1,3,4]);
%
for ir = 1:nr,%radial position
	for it = 1:nt,%poloidal position
        if strcmp(fieldside,'HFS')
            PSI_hxr(ir,it) = max(PSI_hxr(ir,:));%high field side only
        elseif strcmp(fieldside,'LFS')
            PSI_hxr(ir,it) = 1;%low field side only
        end
        mhu_hxr = sign(mhu.').*sqrt(1-PSI_hxr(ir,it)*(1 - mhu.^2).');%mhu at a poloidal position that is different from Bmin
        mhu_hxr = mhu_hxr(1-PSI_hxr(ir,it)*(1 - mhu.^2) > 0);
        Zbremplasma.mhu_hxr{ir,it} = mhu_hxr;
        Zbremplasma.mhubounce2_hxr(ir,it) = 1 - PSI_hxr(ir,it)/max(PSI_hxr(ir,:));
        Xf0_hxr = XXf0(:,1-PSI_hxr(ir,it)*(1 - mhu.^2) > 0,ir);%Non-thermal distribution function at poloidal location
        %
        Xf0_i = interp1(mhu_hxr,Xf0_hxr.',x_leg,method).';%Interpolation of the distribution function on the Legendre polynomial pitch-angle grid
        %
        Xf0_c = (Xf0_i.*(w_leg*ones(1,np)).')*Pm.';%Calculation of the Legendre coefficients for local values of the distribution function
        %
        Xf0_c1 = permute(repmat(reshape(Xf0_c.',n_pol+1,np,1),[1,1,1,nk]),[1,2,4,3]);%Same as Xf0_c but expanded for all photon energies 
        %
        dIB_c1 = pn_c1.*pn_c1.*pn_c1.*BREM_c1(:,:,:,ir).*Xf0_c1./gamma_c1;
        IB_c1 = 2*pi*integral_dke_jd(dpn,dIB_c1,2);%Momentum integration 
        ZZIB(ir,it,:,:) = reshape(IB_c1,n_pol+1,nk)*ne_ref^2*betath_ref*clum/mc2;%MKSA units(s-1*m-3*kev-1*str-1)
        %
        if ~isfield(dkedisplay,'fhxr') || dkedisplay.fhxr,% calculate and save HXR distribution
            %
            Xf0_i1 = (Pm.'*(Xf0_c.*(ones(np,1)*cL.')).').';%Distribution function on the Legendre polynomials pitch-angle grid back calculated
            norm0_hxr = 2*pi*integral_dke_jd(dpn.',pn2.'.*trapz_dke_yp([mhu_hxr,Xf0_hxr.']).',1);
            normi_hxr = 2*pi*integral_dke_jd(dpn.',pn2.'.*trapz_dke_yp([x_leg,Xf0_i.']).',1);
            %
            Zbremplasma.Znorm0_hxr{ir,it} = norm0_hxr;
            Zbremplasma.Znormi_hxr{ir,it} = normi_hxr;
            Zbremplasma.ZXf0_hxr{ir,it} = Xf0_hxr;
            Zbremplasma.ZXf0_i{ir,it} = Xf0_i;
            Zbremplasma.ZXf0_i1{ir,it} = Xf0_i1;
        end
        %
        % Local bremsstrahlung properties (forward and backward with respect to B direction or p// since p// is taken positive)
        %
        Zbremplasma.brem_forward{ir,it} = permute(reshape(Pm_forward.'*(squeeze(ZZIB(ir,it,:,:)).*(cL*ones(1,nk))),1,nk),[2,3,1]);%Forward emission
        Zbremplasma.brem_backward{ir,it} = permute(reshape(Pm_backward.'*(squeeze(ZZIB(ir,it,:,:)).*(cL*ones(1,nk))),1,nk),[2,3,1]);%Backward emission
        Zbremplasma.brem_perp{ir,it} = permute(reshape(Pm_perp.'*(squeeze(ZZIB(ir,it,:,:)).*(cL*ones(1,nk))),1,nk),[2,3,1]);%Perpendicular emission
        Zbremplasma.brem_4pi{ir,it} = permute(reshape(squeeze(ZZIB(ir,it,1,:))/2,1,nk),[2,3,1]);%Mean 4pi emission per steradian				
        %
		if dkedisplay.display_mode,
            if mute_bremsstrahlung_dke_yp == 0
                info_dke_yp(2,['Bremsstrahlung integral #',int2str((ir-1)*nt + it),'/',int2str(nr*nt),' done']);
            end
        end
	end
end
%
Zbremplasma.ZZIB = ZZIB;
Zbremplasma.kphot = kphot;
%