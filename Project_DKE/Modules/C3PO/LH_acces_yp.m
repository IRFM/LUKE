function [na,open_upperboundaries_propagationdomain,intersection] = LH_acces_yp(equil,omega_rf,ray,npar0,nparmax,resolution) 
%
%   Spectral domain of propagation with Stix-Golant accessibility criterion
%    
%    Input:
%
%	  - equil: equilibrium structure
%     - omega_rf: Lower Hybrid wave angular frequency (2*pi*fLH) (rad/s)
%	  - ray: ray structure
%     - npar0: initial npar value at the plasma edge
%     - nparmax: 
%     - nnpar: 
%     - ntheta:
%     - nrho:
%
%    Output:
%
%         - na: accessible refractive index on the (psi,theta) grid [npsi,mtheta]
%
%by Y.PEYSSON (yves.peysson@cea.fr) and J. Decker (joan.decker@epfl.ch)
%
if nargin < 3, error('Not enough input arguments in LH_acces_yp');end
if nargin < 4
    npar0 = 2.0;%n||0 taken at the plasma edge in the equatorial mid-plane with m=0
    nparmax = 8;%max N|| is 8
    resolution = 0;%low resolution, fast calculations
end
if nargin < 5
    nparmax = 8;%max N|| is 8
    resolution = 0;%low resolution, fast calculations
end
%
if nargin < 6
    resolution = 0;%low resolution, fast calculations
end
%
if resolution == 0
    nnpar = 251;
    ntheta = 131;
    nrho = 112;
else
    nnpar = 501;
    ntheta = 301;
    nrho = 212;
end
%
if ~isfield(equil,'consistency') || ~isfield(equil,'equil_fit')
    equil = equilconsistency_yp(equil,'',0);
end
%
[qe,me,mp,~,e0] = pc_dke_yp;
%
if isstruct(ray)
    npar0 = abs(real(ray.sNpar(1)));%launched N||0
end
%
[equil_val] = equilval_yp(equil.equil_fit,linspace(0,1,nrho),linspace(0,2*pi,ntheta));
%
intersection = 0;
%
gamma1 = equil_val.BP./equil_val.B.*abs(equil_val.calpha).*sqrt(equil_val.ne(:)*ones(1,ntheta)*qe^2/me/e0)/omega_rf;%
gamma_KAM_approximate = 5.68*sqrt(equil.pne(1,1)/1e19)*abs(equil.ip)/(omega_rf/1e9/2/pi)/equil.ptx(end,1)/abs(equil.ptBPHI(1,1));
gamma_KAM_exact = max(max(gamma1));
%
[na,E] = stixgolant_yp(equil_val,omega_rf);
%
ns = [equil_val.ne';equil_val.zni'];
qs = qe*[-1;equil.zZi(:)];    
ms = [me;mp*equil.zmi(:)];
%
wps = repmat(sqrt(ns.*(qs*ones(1,nrho)).^2/e0./ms),[1,1,ntheta]);
wcs = repmat(qs,[1,nrho,ntheta]).*shiftdim(repmat(equil_val.B,[1,1,length(qs)]),2)./repmat(ms,[1,nrho,ntheta]);
%
ps = wps/omega_rf;
ys = wcs/omega_rf;
%
ys(ys.^2 == 1) = ys(ys.^2 == 1) + eps;
%
%   Dielectric tensor elements
%
Kpar = squeeze(1.0 - sum(ps.^2));%Stix notation P
Kperp = squeeze(1.0 - sum(ps.^2./(1 - ys.^2)));%Stix notation S
Kx = squeeze(sum(ps.^2.*ys./(1.0 - ys.^2)));
%
%rho = equil_val.r(:,1)/equil.equil_fit.ap;
%q = interp1(equil.consistency.rho,equil.consistency.q(:),rho);
%inverseaspectratio = equil_val.r(:,1)/equil.Rp;
%gamma2 = (1+equil.elongation^2)*sqrt(-Kpar(:,1))./q(:).*inverseaspectratio/2;
%plot(rho, gamma1,'b',rho, gamma2,'r')
%
P = equil_val.BP./equil_val.B;
T = equil_val.Bz./equil_val.B;
G = 1 + equil_val.x/equil_val.Rp;
R = equil_val.x + equil_val.Rp;
Z = equil_val.y + equil_val.Zp;
psin = equil_val.psin(:)*ones(1,ntheta);
r = equil_val.x*equil.ptx(end,1);%ap
c = equil_val.calpha;
s = equil_val.salpha;
%
npar = linspace(1,nparmax,nnpar);
%
Xnpar = shiftdim(repmat(ones(ntheta,1)*npar,1,1,nrho),2);
%
XKpar = repmat(Kpar,[1,1,nnpar]);%Stix notation P
XKperp = repmat(Kperp,[1,1,nnpar]);%Stix notation S
XKx = repmat(Kx,[1,1,nnpar]);
%
XP4 = XKperp;
XP2 = (XKpar + XKperp).*(Xnpar.*Xnpar - XKperp) + XKx.*XKx;
XP0 = XKpar.*((Xnpar.*Xnpar - XKperp).^2 - XKx.*XKx);
%
XNperp2d_s = (-XP2 + sqrt(XP2.*XP2 - 4*XP0.*XP4))./(2*XP4);%slow wave branch from dispersion relation
XNperp2d_s(imag(XNperp2d_s)~= 0)= NaN;%non propagative modes are set to NaN
%
XNperp2d_f = (-XP2 - sqrt(XP2.*XP2 - 4*XP0.*XP4))./(2*XP4);%fast wave branch from dispersion relation
XNperp2d_f(imag(XNperp2d_f)~= 0)= NaN;%non propagative modes are set to NaN
%
XP = repmat(P,[1,1,nnpar]); 
XT = repmat(T,[1,1,nnpar]);
XG = repmat(G,[1,1,nnpar]);
XR = repmat(R,[1,1,nnpar]);
Xr = repmat(r,[1,1,nnpar]);
Xc = repmat(c,[1,1,nnpar]);
Xs = repmat(s,[1,1,nnpar]);
%
if isstruct(ray)
    G0 = (ray.sx(1)+equil.Rp)/equil.Rp;%initial ray conditions
    T0 = ray.sBphi(1)/ray.sB(1);%initial ray conditions
else
    G0 = (equil_val.x(end,1)+equil_val.Rp)/equil_val.Rp;%initial ray conditions
    T0 = equil_val.Bz(end,1)/equil_val.B(end,1);%initial ray conditions
end
%
Xna = repmat(na,[1,1,nnpar]);
%
Xmsr2 = ((Xnpar - (XT./T0).*(G0./XG).*npar0)./XP./Xc).^2;
%
XX_s = XNperp2d_s - Xmsr2 - (npar0/T0.*(G0./XG)).^2 + Xnpar.^2;%slow wave
XX_s(XX_s < 0) = NaN;% find domain where the LH wave cannot propagate
mask_s = ~isnan(XX_s);
%
XX_f = XNperp2d_f - Xmsr2 - (npar0/T0.*(G0./XG)).^2 + Xnpar.^2;%fast wave
XX_f(XX_f < 0) = NaN;% find domain where the LH wave cannot propagate
mask_f = ~isnan(XX_f);
%
Xnpar_mask_s = Xnpar;
Xnpar_mask_s(~mask_s) = NaN;% N|| for which the LH wave can propagate (slow wave)
%
Xnpar_mask_f = Xnpar;
Xnpar_mask_f(~mask_f) = NaN;% N|| for which the LH wave can propagate (fast wave)
%
% Cross-section of the wave domain in the (N||,R) plane evaluated at Z-Zp = 0 (theta = 0)
%
i_thetamin = 1;% theta = 0
i_thetamax = (ntheta-1)/2 + 1;% theta = pi
%
xR = [flipud(XR(:,i_thetamax,1));XR(:,i_thetamin,1)]';%[HFS:LFS] @ Bmin
xTe = [flipud(equil_val.Te(:,1));equil_val.Te(:,1)]';%[HFS:LFS] @ Bmin
%
xna = [flipud(na(:,i_thetamax));na(:,i_thetamin)]';%[HFS:LFS] @ Bmin
%
figure('Name','Npar propagation domain @ Z = Zp');
%
graph1D_jd(xR,xna,0,0,'R (m)','N_{||}','',NaN,NaN,[1,nparmax],'--','none','b',2);
%for i=1:nnpar
%    xnpar0 = [flipud(Xnpar_mask(:,i_thetamax,i));Xnpar_mask(:,i_thetamin,i)]';
%    xnpar1 = [flipud(Xnpar_mask(:,i_thetamax,i));Xnpar_mask(:,i_thetamin,i)]';
%    graph1D_jd(xR,xnpar0,0,0,'R (m)','N_{||}','Z = Z_{p}',NaN,NaN,[1:10],'none','.','r',1);
%    graph1D_jd(xR,xnpar1,0,0,'R (m)','N_{||}','Z = Z_{p}',NaN,NaN,[1:10],'none','.','r',1);
%end
graph1D_jd(xR,6.5./sqrt(xTe),0,0,'R (m)','N_{||}','',NaN,NaN,[1,nparmax],'-.','none','g',2);
%
% Plot boundaries 
%
bR_min_s = squeeze(XR(:,i_thetamin,:));% slow wave
bnpar_mask_min_s = squeeze(Xnpar_mask_s(:,i_thetamin,:));
ibnpar_mask_min_s = find(~isnan(bnpar_mask_min_s));
bbR_min_s = bR_min_s(ibnpar_mask_min_s);
bbnpar_mask_min_s = bnpar_mask_min_s(ibnpar_mask_min_s);
bk_min_s = boundary(bbR_min_s,bbnpar_mask_min_s);
graph1D_jd(bbR_min_s(bk_min_s),bbnpar_mask_min_s(bk_min_s),0,0,'R (m)','N_{||}','',NaN,NaN,[1,nparmax],'-','none','r',2);
%
bR_min_f = squeeze(XR(:,i_thetamin,:));% fast wave
bnpar_mask_min_f = squeeze(Xnpar_mask_f(:,i_thetamin,:));
ibnpar_mask_min_f = find(~isnan(bnpar_mask_min_f));
bbR_min_f = bR_min_f(ibnpar_mask_min_f);
bbnpar_mask_min_f = bnpar_mask_min_f(ibnpar_mask_min_f);
bk_min_f = boundary(bbR_min_f,bbnpar_mask_min_f);
graph1D_jd(bbR_min_f(bk_min_f),bbnpar_mask_min_f(bk_min_f),0,0,'R (m)','N_{||}','',NaN,NaN,[1,nparmax],'--','none','k',2);
%
bR_max_s = squeeze(flipud(XR(:,i_thetamax,:)));% slow wave
bnpar_mask_max_s = squeeze(flipud(Xnpar_mask_s(:,i_thetamax,:)));
ibnpar_mask_max_s = find(~isnan(bnpar_mask_max_s));
bbR_max_s = bR_max_s(ibnpar_mask_max_s);
bbnpar_mask_max_s = bnpar_mask_max_s(ibnpar_mask_max_s);
bk_max_s = boundary(bbR_max_s,bbnpar_mask_max_s);
graph1D_jd(bbR_max_s(bk_max_s),bbnpar_mask_max_s(bk_max_s),0,0,'R (m)','N_{||}','',NaN,NaN,[1,nparmax],'-','none','r',2);
%
bR_max_f = squeeze(flipud(XR(:,i_thetamax,:)));% fast wave
bnpar_mask_max_f = squeeze(flipud(Xnpar_mask_f(:,i_thetamax,:)));
ibnpar_mask_max_f = find(~isnan(bnpar_mask_max_f));
bbR_max_f = bR_max_f(ibnpar_mask_max_f);
bbnpar_mask_max_f = bnpar_mask_max_f(ibnpar_mask_max_f);
bk_max_f = boundary(bbR_max_f,bbnpar_mask_max_f);
graph1D_jd(bbR_max_f(bk_max_f),bbnpar_mask_max_f(bk_max_f),0,0,'R (m)','N_{||}','',NaN,NaN,[1,nparmax],'--','none','k',2);
%
legend('N_{||Landau} = 6.5*{T_e[keV]}^{-1/2}','N_{||acc.} (Stix-Golant)','Slow wave @ Z = Z_{p}','Fast wave @ Z = Z_{p}')
%
bnpar_mask_s = Xnpar_mask_s(:);
bR = XR(:);
bna = Xna(:);
ibnpar_mask_s = find(~isnan(bnpar_mask_s));
bbnpar_mask_s = bnpar_mask_s(ibnpar_mask_s);
bbR_mask_s = bR(ibnpar_mask_s);
bbna_mask_s = bna(ibnpar_mask_s);
bk_min_s = boundary(bbR_mask_s,bbnpar_mask_s);
%
% Electrostatic limit propagation boundaries
%
gamma = equil_val.BP./equil_val.B.*abs(equil_val.calpha).*sqrt(equil_val.ne(:)*ones(1,ntheta)*qe^2/me/e0)/omega_rf;
Npar_p = npar0*(T/T0).*(G0./G).*(1 + gamma)./(1 - gamma.^2);
Npar_m = npar0*(T/T0).*(G0./G).*(1 - gamma)./(1 - gamma.^2);
Npar_mp = [Npar_m,Npar_p];
R_mp = [R,R];
bbmp = boundary(R_mp(:),Npar_mp(:));
%
figure('Name','Projected Npar propagation domain');
graph1D_jd(xR,6.5./sqrt(xTe),0,0,'R (m)','N_{||}','',NaN,NaN,[1,nparmax],'-.','none','g',2);
graph1D_jd(bbR_mask_s(bk_min_s),bbnpar_mask_s(bk_min_s),0,0,'R (m)','N_{||}','',NaN,NaN,[1,nparmax],'-','none','r',2);hold on
%
open_upperboundaries_propagationdomain = ~isempty(find(gamma1>1));
%
R_kinematic = bbR_mask_s(bk_min_s);
npar_kinematic = bbnpar_mask_s(bk_min_s);
R_kinetic = xR;
npar_kinetic = 6.5./sqrt(xTe);
iimin = find(npar_kinetic==min(npar_kinetic));
R_kinetic(iimin(1)) = [];%clean double value for interp1
npar_kinetic(iimin(1)) = [];%clean double value for interp1
%
intersect = npar_kinetic < npar_kinematic;
%
if sum(sum(intersect))
    intersection = 1;   
else
    intersection = 0;
    %
    npar_kinetic_ref = interp1(R_kinetic,npar_kinetic,R_kinematic);
    distance = abs(npar_kinetic_ref-npar_kinematic);
    iR_min = find(distance == min(distance));
    Npar_gap_min = distance(iR_min);
    R_kinematic_gap_min = R_kinematic(iR_min);
    npar_kinematic_gap_min = npar_kinematic(iR_min);
    npar_kinetic_gap_min = interp1(R_kinetic,npar_kinetic,R_kinematic_gap_min);
end
%
% for TRIAM-1M only since the electrostatic approximation holds
%
%sps = squeeze(sum(wps));
%sys = squeeze(sum(wcs));
%graph1D_jd(R_mp(bbmp(1:10:end)),Npar_mp(bbmp(1:10:end)),0,0,'R(m)','N_{||}','',NaN,NaN,[1,nparmax],'none','.','b',2);%Electrostatic limit propagation boundaries
%
%graph1D_jd(bbR_mask_s(bk_min_s),bbna_mask_s(bk_min_s),0,0,'R (m)','N_{||}','Z = Z_{p}',NaN,NaN,[1,nparmax],'--','none','b',2);
%graph1D_jd(bR,bna,0,0,'R (m)','N_{||}','Z = Z_{p}',NaN,NaN,[1,nparmax],'none','.','b',1);
%graph1D_jd(bR,bnpar_mask_s,0,0,'R (m)','N_{||}','Z = Z_{p}',NaN,NaN,[1,nparmax],'none','.','r',1);
%
if isstruct(ray)
    graph1D_jd(ray.sx+equil.Rp,abs(real(ray.sNpar)),0,0,'R (m)','N_{||}','',NaN,NaN,NaN,'none','.','k',1);hold on
    graph1D_jd(ray.sx(1)+equil.Rp,abs(real(ray.sNpar(1))),0,0,'R (m)','N_{||}','',NaN,NaN,[1,nparmax],'none','o','r',2);hold on
end
%
if intersection == 0 & ~isempty(iR_min)
    plot([R_kinematic_gap_min,R_kinematic_gap_min],[npar_kinematic_gap_min,npar_kinetic_gap_min],'bo:');
end
%  
legend('N_{||Landau} = 6.5*{T_e[keV]}^{-1/2}','Projection of (N_{||},R,Z) space on (N_{||},Z_{p})',['C3PO ray-tracing N_{||0} = ',num2str(npar0)])
%
figure('Name','Stix-Golant accessibility');
graph2D_jd(R,Z,na','R (m)','Z (m)',strrep(equil.id,'_','-'),NaN,NaN,1,NaN,NaN,0);colorbar;hold on;
graph2D_jd(R,Z,psin','R (m)','Z (m)','',NaN,NaN,0,NaN,NaN,0,'--','k');
axis('equal')
set(gca, 'CLim', [1, max(max(na))]);
c = colorbar;
c.Label.String = 'N_{||acc.}';
if isstruct(ray)
	hold on;
    graph1D_jd(ray.sx+equil.Rp,ray.sy+equil.Zp,0,0,'','','',NaN,NaN,NaN,'-','none','r',2);
    hold off
end
%
disp(' ');
disp(['---------------------------------------------------------------------------------'])
disp(['---------------------------------------------------------------------------------'])
if resolution == 0
    disp('Low resolution mode, fast calculations')
else
    disp('High resolution mode, slow calculations')
end
disp(['---------------------------------------------------------------------------------'])
disp(['---------------------------------------------------------------------------------'])
%
disp(['-----> Exact criterion for existence of an upper boundary limit : ',num2str(gamma_KAM_exact)])
disp(['-----> Approximate criterion for existence of an upper boundary limit : ',num2str(gamma_KAM_approximate)])
%
if open_upperboundaries_propagationdomain==0
    disp('-----> Finite upper boundary for the LH propagation domain')
else
    disp('-----> Infinite upper boundary for the LH propagation domain')
end
%
if intersection == 1
    disp('-----> LH propagation domain intersects kinetic linear absorption domain')
else
    disp('-----> LH propagation domain does not intersect kinetic linear absorption domain')
    disp(['-----> Minimal spectral gap Dnpar : ',num2str(Npar_gap_min),' @ R = ',num2str(R_kinematic_gap_min),' m'])
end
disp(['---------------------------------------------------------------------------------'])
disp(['---------------------------------------------------------------------------------'])
%


%
end

 