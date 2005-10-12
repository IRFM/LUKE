function [Nperp,e_xyz,e_pmz,e_pyk,X,X_s,X_sn]...
    = hotdisp_dke_jd(Npar,omega_rf,Te,ne,zTi,zni,zZi,zmi,Bfield,Nperp,nmax,tol);
%
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
%       - Nperp: perpendicular index of refraction (initial guess) [1,1] (default:1)    
%       - nmax: maximum harmonic number (default:10) 
%       - tol: tolerance on the value of the dispersion relation (default:1e-10) 
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
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
n = (-nmax:nmax);
Nn = 2*nmax+1;
n0 = nmax+1;
%
nit_disp = 50;
NZ = 10000;
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
Z_sn = Zplasma2(zeta_sn,NZ);
Zp_sn = -2*(1 + Z_sn.*zeta_sn);
%
spar = sign(Npar);
ss = sign(qs);
sperp = 1;
Drel = 0;
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
for it_disp = 1:nit_disp,
    %
    Drel_old = Drel;
    N = [Nperp,0,Npar]';
    %
    lambdas = (Nperp*bTs./ys).^2;
    Gamma_sn = besseli(n,lambdas,1);
    Gammap_sn = ((1./lambdas)*n - 1).*Gamma_sn + besseli(n+1,lambdas,1);
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
    D = N*N' - (N'*N)*I + K;
    %
    Drel = det(D); 
    %
    if abs(Drel) <= tol,
        break
    elseif abs(Drel) <= abs(Drel_old)%Richardson method
        Nperp = Nperp + sperp*Drel;
    else
        Nperp = Nperp - 2*sperp*Drel_old;
        sperp = -sperp;
    end
end
if it_disp == nit_disp,
    error('The root was not found');
end
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