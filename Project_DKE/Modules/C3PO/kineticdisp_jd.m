function [Nperp,e_xyz,e_pmz,e_pyk,D,X,X_s,X_sn,...
          alphaphi_lin,phiT_xyz,phiP_xyz,phiT_pmz,phiP_pmz,phiT_pyk,phiP_pyk]...
    = kineticdisp_jd(sa,sy,sbeta,Npar,Nperp_in,herm_mode,display_mode,nmax,NZ,tol,method)
%
% This function solves the dispersion relation and the wave equation
% in the linear kinetic plasma model. It calculates the perpendicular index
% of refraction, the polarization, and the energy flow density as a 
% function of the wave frequency and the parallel index of refraction. 
%
% - (x,y,z): We assume that the magnetic field is in the z direction and 
%         the perpendicular index of refraction in the x direction. 
% - (p,m,z): p and m refer to the left hand and right hand rotating fields 
%         respectively.
% - (p,y,k): p and y are the transverse components of the polarization, 
%         with respect to the wave vector. k is the longitudinal component.
%
%   INPUTS: 
%
%       - sa: ratio (wps/w)^2 for each species [Ns,1]
%       - sy: ratio wcs/w for each species [Ns,1] 
%           >>> Warning: sy < 0 for negatively charged species
%       - sbeta: ratio (Ts/mc2)^(1/2) for each species [Ns,1]
%       - Npar: parallel index of refraction [1,1]       
%       - Nperp_in: perpendicular index of refraction (initial guess) [1,1] 
%           >>> default: 1    
%       - herm_mode: mode for the calculation: (0) full dielectric tensor 
%                                              (1) hermitian part 
%           >>> default: 0
%           >>> In the case herm_mode = 1, the power flow density and
%               the density of power absorbed are also calculated
%       - display_mode: (0) no display (1) partial (2) figures  
%           >>> default: 0
%       - nmax: maximum harmonic number
%           >>> default: 10
%       - NZ: number of grid points in Z function integration calculation 
%           >>> default: 1000
%       - tol: tolerance on the value of the dispersion relation 
%           >>> default: 1e-5
%       - method_type: 'newton', 'segments'
%           >>> default: 'newton'
%
%   OUTPUTS:
%
%       - Nperp: perpendicular index of refraction [1,1]
%       - e_xyz: polarization vector in the (x,y,z) coordinates [3,1]
%       - e_pmz: polarization vector in the (p,m,z) coordinates [3,1] 
%       - e_pyk: polarization vector in the (p,y,k) coordinates [3,1]  
%       - D: kinetic plasma dispersion tensor elements [3,3]
%       - X: kinetic plasma susceptibility tensor elements [3,3]
%       - X_s: kinetic plasma susceptibility tensor elements for species s 
%           [3,3,Ns]
%       - X_sn: kinetic plasma susceptibility tensor elements for species s 
%           and harmonic n [3,3,Ns,Nn]
%
%   if herm_mode = 1
%
%       - alphaphi_lin: density of power absorbed [1,1]
%           normalized to the (e0w/2)|E|^2
%       - phiT_xyz: kinetic energy flow density,(x,y,z) coordinates [3,1]
%       - phiP_xyz: Poynting energy flow density,(x,y,z) coordinates [3,1] 
%       - phiT_pmz: kinetic energy flow density,(p,m,z) coordinates [3,1] 
%       - phiP_pmz: Poynting energy flow density,(p,m,z) coordinates [3,1] 
%       - phiT_pyk: kinetic energy flow density,(p,y,k) coordinates [3,1] 
%       - phiP_pyk: Poynting energy flow density,(p,y,k) coordinates [3,1] 
%           flows normalized to the vaccuum wave value (e0c/2)|E|^2
%
% created 05/02/2003
% by Joan Decker <joan.decker@cea.fr> and 
%    Yves Peysson <yves.peysson@cea.fr>
% 
if nargin < 11,
   method = 'newton';
end
if nargin < 10,
   tol = 1e-5;
end
if nargin < 9,
   NZ = 1000;
end
if nargin < 8,
   nmax = 10;
end
if nargin < 7,
   display_mode = 0;
end
if nargin < 6,
   herm_mode = 0;
end
if nargin < 5,
   Nperp_in = 1;
end
if nargin < 4,
   error('Not enough arguments');
end
%
% Internal parameters
%
nit_disp = 50;%maximum number of iterations in root finding procedure
%
proxcoef = 1e-4;%proximity parameter for local derivative calculations
%(newton's method only)
%
mode = 0;%mode = 1 when root is localized
varfac = 100;%reduction factor in exponential range expansion
%
% Initializations
%
sa = sa(:);
sy = sy(:);
sbeta = sbeta(:);
%
Ns = length(sa);
%
if length(sy) ~= Ns || length(sbeta) ~= Ns,
    error('Argument size not compatible')
end
%
sy(sy.^2 == 1) = sy(sy.^2 == 1) + eps;%to avoid singularity
%
ss = sign(sy);
spar = sign(Npar);
%
n = (-nmax:nmax);
Nn = 2*nmax+1;
n0 = nmax+1;
%
% Calculation of the plasma dispersion function
%
zeta_sn = (1 - abs(sy)*n)./(sqrt(2)*abs(Npar)*(sbeta*ones(1,Nn)));
%
if exist(['erfcc.',mexext],'file') == 3,%fortran file
    Z_sn = zeros(Ns,Nn);
    for is = 1:Ns,
        %
        x = [zeta_sn(is,:),zeros(1,1024 - Nn)];
        %
        [yr,yi] = erfcc(Nn,real(x),imag(x));
        %
        Z_sn(is,:) = sqrt(pi)*(i*yr(1:Nn) - yi(1:Nn));
    end
    Zp_sn = -2*(1 + zeta_sn.*Z_sn);
    Zpp_sn = -2*(Z_sn - 2*zeta_sn.*(1 + zeta_sn.*Z_sn));
    %
    maskp_sn = abs(zeta_sn) > sqrt(1e-2/(2*eps));
    maskpp_sn = abs(zeta_sn) > sqrt(sqrt(1e-2/(4*eps)));
    %
    if any(maskp_sn),
        disp(['Warning : there are ',num2str(sum(maskp_sn(:))),'/',num2str(length(maskp_sn(:))),...
            ' points outside the plasma dispersion function first derivative calculation range'])
    end
    %
    if any(maskpp_sn),
        disp(['Warning : there are ',num2str(sum(maskpp_sn(:))),'/',num2str(length(maskpp_sn(:))),...
            ' points outside the plasma dispersion function second derivative calculation range'])
    end
    %
elseif exist('pdisp','file') == 3,%fortran file
    if display_mode >= 1,
       wb = waitbar(0,'Plasma dispersion function');
    end
    Z_sn = NaN*ones(Ns,Nn);
    for is = 1:Ns,
        Z_sn(is,:) = pdispm(zeta_sn(is,:));
        if display_mode >= 1,
           waitbar(in/Nn,wb);
        end
    end
    if display_mode >= 1,
       close(wb)
    end
    Zp_sn = -2*(1 + zeta_sn.*Z_sn);
    Zpp_sn = -2*(Z_sn - 2*zeta_sn.*(1 + zeta_sn.*Z_sn));
    %
else
    %
    % error('Please compile the function erfcc.f as a mex file.');
    %
    % disp('Warning: Zplasma must be checked first. Second derivative calculations are wrong for imag. part and for small arguments.')
    %
    [Z_sn,Zp_sn,Zpp_sn] = Zplasma(zeta_sn,NZ);
    %
end
%
%   Dielectric tensor elements
%
X_sn = zeros(3,3,Ns,Nn);
Y_sn = zeros(3,3,Ns,Nn);
%
Msa_sn = shiftdim(repmat(sa,[1,Nn,3,3]),2);
Mss_sn = reshape(repmat(ss,[1,Nn]),[1,1,Ns,Nn]);
Mn_sn = reshape(repmat(n,[Ns,1]),[1,1,Ns,Nn]);
%
Mzeta_sn = reshape(zeta_sn,[1,1,Ns,Nn]);
Mzeta0_sn = repmat(Mzeta_sn(:,:,:,n0),[3,3,1,Nn]);
MZ_sn = reshape(Z_sn,[1,1,Ns,Nn]);
MZp_sn = reshape(Zp_sn,[1,1,Ns,Nn]);
%
X_s = zeros(3,3,Ns);
%
X = zeros(3,3);
D = zeros(3,3);
%
I = eye(3);
%
Drel = NaN*ones(1,2*nit_disp+1);
Nperp = NaN*ones(1,2*(nit_disp+1));
%
Nperp(1) = Nperp_in;
%
for it_disp = 1:2*nit_disp+1,
    %
    N = [Nperp(it_disp),0,Npar].';
    %
    slambda = (Nperp(it_disp)*sbeta./sy).^2;
    Gamma_sn = besseli(n,slambda,1).*(exp(-i*imag(slambda))*ones(1,Nn));
    Gammap_sn = ((besseli(n+1,slambda,1) + besseli(n-1,slambda,1))/2 - besseli(n,slambda,1)).*(exp(-i*imag(slambda))*ones(1,Nn));
    %
    MGamma_sn = reshape(Gamma_sn,[1,1,Ns,Nn]);
    MGammap_sn = reshape(Gammap_sn,[1,1,Ns,Nn]);
    %
    Mlambda_sn = reshape(repmat(slambda,[1,Nn]),[1,1,Ns,Nn]);
    %
    Y_sn(1,1,:,:) = Mn_sn.^2.*MGamma_sn.*MZ_sn./Mlambda_sn;%Yxx
    Y_sn(1,2,:,:) = i*Mss_sn.*Mn_sn.*MGammap_sn.*MZ_sn;%Yxy
    Y_sn(1,3,:,:) = -spar.*Mn_sn.*MGamma_sn.*MZp_sn./sqrt(2*Mlambda_sn);%Yxz
    Y_sn(2,1,:,:) = -Y_sn(1,2,:,:);%Yyx
    Y_sn(2,2,:,:) = (Mn_sn.^2.*MGamma_sn./Mlambda_sn - 2*Mlambda_sn.*MGammap_sn).*MZ_sn;%Yyy
    Y_sn(2,3,:,:) = i*Mss_sn*spar.*sqrt(Mlambda_sn/2).*MGammap_sn.*MZp_sn;%Yyz
    Y_sn(3,1,:,:) = Y_sn(1,3,:,:);%Yzx
    Y_sn(3,2,:,:) = -Y_sn(2,3,:,:);%Yzy
    Y_sn(3,3,:,:) = -MGamma_sn.*Mzeta_sn.*MZp_sn;%Yzz
    %
    X_sn = Msa_sn.*Mzeta0_sn.*Y_sn;%Xsn
    %  
    X_s = sum(X_sn,4);%Xs
    %
    X = sum(X_s,3);
    %
    D = N*N.' - (N.'*N)*I + I + X;
    %
    if herm_mode == 1,
        D = (D + D')/2;
    end
    %
    Drel(it_disp) = det(D); 
    %
    if strcmp(method,'newton'),
        if rem(it_disp,2) == 1 && abs(Drel(it_disp)) <= tol,
            break
        elseif rem(it_disp,2) == 1,
            if it_disp == 1,
                Nperp(it_disp + 1) = (1 - proxcoef)*Nperp(it_disp);
            else
                Nperp(it_disp + 1) = (1 - proxcoef)*Nperp(it_disp) + proxcoef*Nperp(it_disp - 2);
            end
        else
            dDreldNperp = (Drel(it_disp) - Drel(it_disp - 1))/(Nperp(it_disp) - Nperp(it_disp - 1));
            if dDreldNperp == 0 || isnan(dDreldNperp)
                disp('WARNING : The calculation did not converge')
                Nperp(it_disp + 1) = Nperp(it_disp - 1);
                tol = Inf;
            else
                Nperp(it_disp + 1) = Nperp(it_disp - 1) - Drel(it_disp - 1)/dDreldNperp; 
            end
        end
    elseif strcmp(method,'segments'),
        if abs(Drel(it_disp)) <= tol,
            break
        end
        if mode == 0,
            if it_disp > 1 && Drel(it_disp)*Drel(it_disp - 1) < 0,
                mode = 1;
            elseif rem(it_disp,2) == 1,
                Nperp(it_disp + 1) = Nperp(1)*exp((it_disp + 1)/2/varfac);
            else
                Nperp(it_disp + 1) = Nperp(1)*exp(-it_disp/2/varfac);
            end
        end
        if mode == 1,
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
    disp('WARNING : The root was not found');
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
iEval = find(abs(Eval0) == min(abs(Eval0)),1,'last'); %select eigenvalue lambda=0 
%
Evec0 = Evec(:,iEval); %eigenvector
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
    alphaphi_lin = -i*e_xyz'*XA*e_xyz;
    %
    % energy flow density
    %
    dYdNperp_sn = zeros(3,3,Ns,Nn);
    %
    Mlambdap_sn = 2*Mlambda_sn/Nperp;
    Gammapp_sn = ((besseli(n+2,slambda,1) + besseli(n-2,slambda,1))/4 + 3*besseli(n,slambda,1)/2 - besseli(n+1,slambda,1) - besseli(n-1,slambda,1)).*(exp(-i*imag(slambda))*ones(1,Nn));
    MGammapp_sn = reshape(Gammapp_sn,[1,1,Ns,Nn]);
    %
    dYdNperp_sn(1,1,:,:) = Mn_sn.^2.*Mlambdap_sn.*(MGammap_sn - MGamma_sn./Mlambda_sn).*MZ_sn./Mlambda_sn;
    dYdNperp_sn(1,2,:,:) = i*Mss_sn.*Mn_sn.*Mlambdap_sn.*MGammapp_sn.*MZ_sn;
    dYdNperp_sn(1,3,:,:) = -spar.*Mn_sn.*Mlambdap_sn.*(MGammap_sn - MGamma_sn/2./Mlambda_sn).*MZp_sn./sqrt(2*Mlambda_sn);
    dYdNperp_sn(2,1,:,:) = -dYdNperp_sn(1,2,:,:);
    dYdNperp_sn(2,2,:,:) = Mlambdap_sn.*((Mn_sn.^2./Mlambda_sn - 2).*MGammap_sn - Mn_sn.^2.*MGamma_sn./Mlambda_sn.^2 - 2*Mlambda_sn.*MGammapp_sn).*MZ_sn;
    dYdNperp_sn(2,3,:,:) = i*Mss_sn*spar.*Mlambdap_sn.*sqrt(Mlambda_sn/2).*(MGammap_sn/2./Mlambda_sn + MGammapp_sn).*MZp_sn;
    dYdNperp_sn(3,1,:,:) = dYdNperp_sn(1,3,:,:);
    dYdNperp_sn(3,2,:,:) = -dYdNperp_sn(2,3,:,:);
    dYdNperp_sn(3,3,:,:) = -Mlambdap_sn.*MGammap_sn.*Mzeta_sn.*MZp_sn;
    %
    dXdNperp_sn = Msa_sn.*Mzeta0_sn.*dYdNperp_sn;
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
    Mzetap0_sn = -Mzeta0_sn/Npar;
    MZpp_sn = reshape(Zpp_sn,[1,1,Ns,Nn]);
    %
    dYdNpar_sn(1,1,:,:) = Mn_sn.^2.*MGamma_sn.*Mzetap_sn.*MZp_sn./Mlambda_sn;
    dYdNpar_sn(1,2,:,:) = i*Mss_sn.*Mn_sn.*MGammap_sn.*Mzetap_sn.*MZp_sn;
    dYdNpar_sn(1,3,:,:) = -spar.*Mn_sn.*MGamma_sn.*Mzetap_sn.*MZpp_sn./sqrt(2*Mlambda_sn);
    dYdNpar_sn(2,1,:,:) = -dYdNpar_sn(1,2,:,:);
    dYdNpar_sn(2,2,:,:) = (Mn_sn.^2.*MGamma_sn./Mlambda_sn - 2*Mlambda_sn.*MGammap_sn).*Mzetap_sn.*MZp_sn;
    dYdNpar_sn(2,3,:,:) = i*Mss_sn*spar.*sqrt(Mlambda_sn/2).*MGammap_sn.*Mzetap_sn.*MZpp_sn;
    dYdNpar_sn(3,1,:,:) = dYdNpar_sn(1,3,:,:);
    dYdNpar_sn(3,2,:,:) = -dYdNpar_sn(2,3,:,:);
    dYdNpar_sn(3,3,:,:) = -MGamma_sn.*Mzetap_sn.*(MZp_sn + Mzeta_sn.*MZpp_sn);
    %
    dXdNpar_sn = Msa_sn.*Mzetap0_sn.*Y_sn + Msa_sn.*Mzeta0_sn.*dYdNpar_sn;
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









