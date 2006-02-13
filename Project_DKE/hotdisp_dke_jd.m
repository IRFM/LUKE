function [Nperp,e_xyz,e_pmz,e_pyk,D,X,X_s,X_sn,alphaphi_lin,phiT_xyz,phiP_xyz,phiT_pmz,phiP_pmz,phiT_pyk,phiP_pyk]...
    = hotdisp_dke_jd(Npar,omega_rf,Te,ne,zTi,zni,zZi,zmi,Bfield,Nperp_in,herm_mode,display_mode,nmax,NZ,tol,method_type);
% This function solves the dispersion relation and the wave equation
% in the linear kinetic plasma model. It calculates the perpendicular index of
% refraction and the polarization as a function of the wave
% frequency and the parallel index of refraction. 
%
% - (x,y,z): We assume that the magnetic field is in the z direction and the 
%           perpendicular index of refraction in the x direction. 
% - (p,m,z): p and m refer to the left hand and right hand rotating fields 
%           respectively.
% - (p,y,k): p and y are the transverse components of the polarization, with 
%           respect to the wave vector. k is the longitudinal component.
%
%   INPUTS: 
%
%       - Npar: parallel index of refraction [1,1]       
%       - omega_rf: wave frequency (rad/s) [1,1] 
%       - Te: electron temperature (keV) [1,1]
%       - ne: electron density (m-3) [1,1]
%       - zTi: ion temperature (keV) [1,i]
%       - zni: ion density (m-3) [1,i]
%       - zZi: ion charges [1,i] 
%       - zmi: ion masses (mp) [1,i]  
%       - Bfield: magnetic field amplitude [1,1]
%       - Nperp_in: perpendicular index of refraction (initial guess) [1,1] (default:1)    
%       - herm_mode: mode for the calculation (0) full dielectric tensor, (1) hermitian part (default:0) 
%           >>> In the case herm_mode = 1, the power flow and linear absorption
%               are also calculated
%       - display_mode: (0,1) none (2) convergence figures (default:0)  
%       - nmax: maximum harmonic number (default:10) 
%       - NZ: number of grid points in Z function integration calculation (default:100) 
%       - tol: tolerance on the value of the dispersion relation (default:1e-6) 
%       - method_type: 'newton', 'segments' (default:'newton') 
%
%   OUTPUTS:
%
%       - Nperp: perpendicular index of refraction [1,1]
%       - e_xyz: polarization vector in the (x,y,z) coordinates [3,1]
%       - e_pmz: polarization vector in the (p,m,z) coordinates [3,1] 
%       - e_pyk: polarization vector in the (p,y,k) coordinates [3,1]  
%       - X: kinetic plasma susceptibility tensor elements [3,3]
%       - X_s: kinetic plasma susceptibility tensor elements for species s [3,3,1+i]
%       - X_sn: kinetic plasma susceptibility tensor elements for species s and harmonic n [3,3,1+i,N]
%
% created 05/02/2003
% by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
% 
if nargin < 16,
   method.type = 'newton';
else
   method.type = method_type;
end
if nargin < 15,
   tol = 1e-5;
end
if nargin < 14,
   NZ = 100;
end
if nargin < 13,
   nmax = 10;
end
if nargin < 12,
   display_mode = 0;
end
if nargin < 11,
   herm_mode = 0;
end
if nargin < 10,
   Nperp_in = 1.0;
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
n = (-nmax:nmax);
Nn = 2*nmax+1;
n0 = nmax+1;
%
nit_disp = 50;
NZ = 100;
proxcoef = 1e-4;
varfac = 100;
%
Nperp(1) = Nperp_in;
%
Ns = 1 + length(zZi);
%
ns = [ne;zni(:)];
qs = qe*[-1;zZi(:)];
ms = [me;mp*zmi(:)];
%
wps = sqrt(ns.*qs.^2/e0./ms);
wcs = qs*Bfield./ms;
%
ps = wps/omega_rf;
ys = wcs/omega_rf;
%
ys(ys.^2 == 1) = ys(ys.^2 == 1) + eps;
%
bTs = sqrt([Te*1e3*qe/me/clum^2;zTi(:)*1e3*qe./(mp*zmi(:))/clum^2]);
%
zeta_sn = (1 - abs(ys)*n)/abs(Npar)/sqrt(2)./(bTs*ones(1,Nn));
%
%wb = waitbar(0);
%for in = 1:Nn,
    %[Z_sn(:,in),Zp_sn(:,in),Zpp_sn(:,in)] = Zplasma(zeta_sn(:,in),NZ);
    %waitbar(in/Nn,wb);
%end
%close(wb)
[Z_sn,Zp_sn,Zpp_sn] = Zplasma(zeta_sn,NZ);
%
spar = sign(Npar);
ss = sign(qs);
%
%   Dielectric tensor elements
%
X_sn = zeros(3,3,Ns,Nn);
Y_sn = zeros(3,3,Ns,Nn);
%
Mps = shiftdim(repmat(ps,[1,Nn,3,3]),2);
Mss = reshape(repmat(ss,[1,Nn]),[1,1,Ns,Nn]);
Mn = reshape(repmat(n,[Ns,1]),[1,1,Ns,Nn]);
%
Mzeta_sn = reshape(zeta_sn,[1,1,Ns,Nn]);
Mzeta_sn0 = repmat(Mzeta_sn(:,:,:,n0),[3,3,1,Nn]);
MZ_sn = reshape(Z_sn,[1,1,Ns,Nn]);
MZp_sn = reshape(Zp_sn,[1,1,Ns,Nn]);
%
X_s = zeros(3,3,Ns);
%
X = zeros(3,3);
K = zeros(3,3);
D = zeros(3,3);
%
I = eye(3);
%
method.mode = 0;
%
for it_disp = 1:2*nit_disp+1,
    %
    N = [Nperp(it_disp),0,Npar].';
    %
    lambdas = (Nperp(it_disp)*bTs./ys).^2;
    Gamma_sn = besseli(n,lambdas,1).*(exp(-i*imag(lambdas))*ones(1,Nn));
    Gammap_sn = ((besseli(n+1,lambdas,1) + besseli(n-1,lambdas,1))/2 - besseli(n,lambdas,1)).*(exp(-i*imag(lambdas))*ones(1,Nn));
    %
    MGamma_sn = reshape(Gamma_sn,[1,1,Ns,Nn]);
    MGammap_sn = reshape(Gammap_sn,[1,1,Ns,Nn]);
    %
    Mlambdas = reshape(repmat(lambdas,[1,Nn]),[1,1,Ns,Nn]);
    %
    Y_sn(1,1,:,:) = Mn.^2.*MGamma_sn.*MZ_sn./Mlambdas;%Yxx
    Y_sn(1,2,:,:) = i*Mss.*Mn.*MGammap_sn.*MZ_sn;%Yxy
    Y_sn(1,3,:,:) = -spar.*Mn.*MGamma_sn.*MZp_sn./sqrt(2*Mlambdas);%Yxz
    Y_sn(2,1,:,:) = -Y_sn(1,2,:,:);%Yyx
    Y_sn(2,2,:,:) = (Mn.^2.*MGamma_sn./Mlambdas - 2*Mlambdas.*MGammap_sn).*MZ_sn;%Yyy
    Y_sn(2,3,:,:) = i*Mss*spar.*sqrt(Mlambdas/2).*MGammap_sn.*MZp_sn;%Yyz
    Y_sn(3,1,:,:) = Y_sn(1,3,:,:);%Yzx
    Y_sn(3,2,:,:) = -Y_sn(2,3,:,:);%Yzy
    Y_sn(3,3,:,:) = -MGamma_sn.*Mzeta_sn.*MZp_sn;%Yzz
    %
    X_sn = Mps.^2.*Mzeta_sn0.*Y_sn;%Xsn
    %  
    X_s = sum(X_sn,4);%Xs
    %
    X = sum(X_s,3);
    %
    K = I + X;
    %
    D = N*N.' - (N.'*N)*I + K;
    %
    if herm_mode == 1,
        D = (D + D')/2;
    end
    %
    Drel(it_disp) = det(D); 
    %
    if strcmp(method.type,'newton'),
        if rem(it_disp,2) == 1 & abs(Drel(it_disp)) <= tol,
            break
        elseif rem(it_disp,2) == 1,
            if it_disp == 1,
                Nperp(it_disp + 1) = (1 - proxcoef)*Nperp(it_disp);
            else
                Nperp(it_disp + 1) = (1 - proxcoef)*Nperp(it_disp) + proxcoef*Nperp(it_disp - 2);
            end
        else
            dDreldNperp = (Drel(it_disp) - Drel(it_disp - 1))/(Nperp(it_disp) - Nperp(it_disp - 1));
            if dDreldNperp == 0 | isnan(dDreldNperp)
                warning('The calculation did not converge')
                Nperp(it_disp + 1) = Nperp(it_disp - 1);
                tol = Inf;
            else
                Nperp(it_disp + 1) = Nperp(it_disp - 1) - Drel(it_disp - 1)/dDreldNperp; 
            end
        end
    elseif strcmp(method.type,'segments'),
        if abs(Drel(it_disp)) <= tol,
            break
        end
        if method.mode == 0,
            if it_disp > 1 & Drel(it_disp)*Drel(it_disp - 1) < 0,
                method.mode = 1;
            elseif rem(it_disp,2) == 1,
                Nperp(it_disp + 1) = Nperp(1)*exp((it_disp + 1)/2/varfac);
            else
                Nperp(it_disp + 1) = Nperp(1)*exp(-it_disp/2/varfac);
            end
        end
        if method.mode == 1,
            if Drel(it_disp)*Drel(it_disp - 1) < 0,
                it_ref = it_disp - 1;
            end
            Nperp(it_disp + 1) = (Nperp(it_ref) + Nperp(it_disp))/2;
        end
    else
        error('root finding method not recognized')
    end
end
%
if display_mode >= 2,
%
    figure(1),
    plot(1:(it_disp + 1)/2,real(Nperp(1:2:it_disp)),'b+',1:(it_disp + 1)/2,imag(Nperp(1:2:it_disp)),'r+')
%
    figure(2),
    plot(1:(it_disp + 1)/2,real(Drel(1:2:it_disp)),'b+',1:(it_disp + 1)/2,imag(Drel(1:2:it_disp)),'r+')
%
    figure(3),
    plot(1:(it_disp + 1)/2,abs(Drel(1:2:it_disp)),'b+')
    set(gca,'yscale','log')
end
%
if it_disp == 2*nit_disp+1,    
    warning('The root was not found');
%    
    Nperp = NaN;
    e_xyz = NaN*ones(3,1);
    e_pmz = NaN*ones(3,1);
    e_pyk = NaN*ones(3,1);
    D = NaN*ones(3,3);
    X = NaN*ones(3,3);
    X_s = NaN*ones(3,3,Ns);
    X_sn = NaN*ones(3,3,Ns,Nn);
    alphaphi_lin = NaN;
    phiT_xyz = NaN*ones(3,1);
    phiP_xyz = NaN*ones(3,1);
    phiT_pmz = NaN*ones(3,1);
    phiP_pmz = NaN*ones(3,1);
    phiT_pyk = NaN*ones(3,1);
    phiP_pyk = NaN*ones(3,1);
%    
    return
end
%
Nperp = Nperp(it_disp);
%
%   Eigenvector
%
[Evec,Eval] = eig(D);
%
Eval0 = diag(Eval); %eigenvalues
%
iEval = find(abs(Eval0) == min(abs(Eval0))); %select eigenvalue lambda=0 
%
Evec0 = Evec(:,max(iEval)); %eigenvector
%
%   Polarization vectors
%
e_xyz = Evec0./norm(Evec0); %xyz
%
M_xypm = [1,i,0;1,-i,0;0,0,sqrt(2)]/sqrt(2);
%
e_pmz = M_xypm*e_xyz; %pmz
%
c = Npar/norm(N);
s = Nperp/norm(N); 
%
M_xzpk = [c,0,-s;0,1,0;s,0,c];
%
e_pyk = M_xzpk*e_xyz; %pyk
%
if herm_mode == 1,
    %
    % linear absorption coefficient
    %
    XA = (X - X')/2;
    alphaphi_lin = -i*omega_rf/clum*e_xyz'*XA*e_xyz;
    %
    % energy flow density
    %
    dYdNperp_sn = zeros(3,3,Ns,Nn);
    %
    Mlambdap_s = 2*Mlambdas/Nperp;
    Gammapp_sn = ((besseli(n+2,lambdas,1) + besseli(n-2,lambdas,1))/4 + 3*besseli(n,lambdas,1)/2 - besseli(n+1,lambdas,1) - besseli(n-1,lambdas,1)).*(exp(-i*imag(lambdas))*ones(1,Nn));
    MGammapp_sn = reshape(Gammapp_sn,[1,1,Ns,Nn]);
    %
    dYdNperp_sn(1,1,:,:) = Mn.^2.*Mlambdap_s.*(MGammap_sn - MGamma_sn./Mlambdas).*MZ_sn./Mlambdas;
    dYdNperp_sn(1,2,:,:) = i*Mss.*Mn.*Mlambdap_s.*MGammapp_sn.*MZ_sn;
    dYdNperp_sn(1,3,:,:) = -spar.*Mn.*Mlambdap_s.*(MGammap_sn - MGamma_sn/2./Mlambdas).*MZp_sn./sqrt(2*Mlambdas);
    dYdNperp_sn(2,1,:,:) = -dYdNperp_sn(1,2,:,:);
    dYdNperp_sn(2,2,:,:) = Mlambdap_s.*((Mn.^2./Mlambdas - 2).*MGammap_sn - Mn.^2.*MGamma_sn./Mlambdas.^2 - 2*Mlambdas.*MGammapp_sn).*MZ_sn;
    dYdNperp_sn(2,3,:,:) = i*Mss*spar.*Mlambdap_s.*sqrt(Mlambdas/2).*(MGammap_sn/2./Mlambdas + MGammapp_sn).*MZp_sn;
    dYdNperp_sn(3,1,:,:) = dYdNperp_sn(1,3,:,:);
    dYdNperp_sn(3,2,:,:) = -dYdNperp_sn(2,3,:,:);
    dYdNperp_sn(3,3,:,:) = -Mlambdap_s.*MGammap_sn.*Mzeta_sn.*MZp_sn;
    %
    dXdNperp_sn = Mps.^2.*Mzeta_sn0.*dYdNperp_sn;
    %  
    dXdNperp_s = sum(dXdNperp_sn,4);
    %
    dXdNperp = sum(dXdNperp_s,3);
    %
    dXdNperp = (dXdNperp + dXdNperp')/2;%hermitian part only
    %  
    dYdNpar_sn = zeros(3,3,Ns,Nn);
    %
    Mzetap_sn = -Mzeta_sn/Npar;
    Mzetap_sn0 = -Mzeta_sn0/Npar;
    MZpp_sn = reshape(Zpp_sn,[1,1,Ns,Nn]);
    %
    dYdNpar_sn(1,1,:,:) = Mn.^2.*MGamma_sn.*Mzetap_sn.*MZp_sn./Mlambdas;
    dYdNpar_sn(1,2,:,:) = i*Mss.*Mn.*MGammap_sn.*Mzetap_sn.*MZp_sn;
    dYdNpar_sn(1,3,:,:) = -spar.*Mn.*MGamma_sn.*Mzetap_sn.*MZpp_sn./sqrt(2*Mlambdas);
    dYdNpar_sn(2,1,:,:) = -dYdNpar_sn(1,2,:,:);
    dYdNpar_sn(2,2,:,:) = (Mn.^2.*MGamma_sn./Mlambdas - 2*Mlambdas.*MGammap_sn).*Mzetap_sn.*MZp_sn;
    dYdNpar_sn(2,3,:,:) = i*Mss*spar.*sqrt(Mlambdas/2).*MGammap_sn.*Mzetap_sn.*MZpp_sn;
    dYdNpar_sn(3,1,:,:) = dYdNpar_sn(1,3,:,:);
    dYdNpar_sn(3,2,:,:) = -dYdNpar_sn(2,3,:,:);
    dYdNpar_sn(3,3,:,:) = -MGamma_sn.*Mzetap_sn.*(MZp_sn + Mzeta_sn.*MZpp_sn);
    %
    dXdNpar_sn = Mps.^2.*Mzetap_sn0.*Y_sn + Mps.^2.*Mzeta_sn0.*dYdNpar_sn;
    %  
    dXdNpar_s = sum(dXdNpar_sn,4);
    %
    dXdNpar = sum(dXdNpar_s,3);
    %
    dXdNpar  = (dXdNpar + dXdNpar')/2;
    %
    phiT_xyz(1,1) = -e_xyz'*dXdNperp*e_xyz/2;
    phiT_xyz(2,1) = 0;
    phiT_xyz(3,1) = -e_xyz'*dXdNpar*e_xyz/2;
    phiP_xyz = N - real((e_xyz'*N)*e_xyz);
    %
    phiT_pmz = M_xypm*phiT_xyz; %pmz
    phiP_pmz = M_xypm*phiP_xyz; %pmz
    %
    phiT_pyk = M_xzpk*phiT_xyz; %pyk
    phiP_pyk = M_xzpk*phiP_xyz; %pyk
else
    alphaphi_lin = NaN;
    phiT_xyz = NaN;
    phiP_xyz = NaN;
    phiT_pmz = NaN;
    phiP_pmz = NaN;
    phiT_pyk = NaN;
    phiP_pyk = NaN;
end









