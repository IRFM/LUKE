function [X,dXdNpar,dXdNperp] = hottensor_jd(sa,sy,sbeta,Npar,Nperp,herm_mode,nmax,NZ)
%
% This function calculates the kinetic plasma susceptibility tensor. 
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
%       - Nperp: perpendicular index of refraction [1,1] 
%       - herm_mode: mode for the calculation: (0) full susceptibility tensor 
%                                              (1) hermitian part 
%           >>> default: 0
%       - nmax: maximum harmonic number
%           >>> default: 10
%       - NZ: number of grid points in Z function integration calculation 
%           >>> default: 1000
%
%   OUTPUTS:
%
%       - X: kinetic plasma susceptibility tensor elements [3,3]
%       - dXdNpar: derivative of X with respect to Npar
%       - dXdNperp: derivative of X with respect to Nperp
%
% created 05/02/2003
% by Joan Decker <joan.decker@cea.fr> and 
%    Yves Peysson <yves.peysson@cea.fr>
% 
if nargin < 8,
   NZ = 1000;
end
if nargin < 7,
   nmax = 10;
end
if nargin < 6,
   herm_mode = 0;
end
if nargin < 5,
   error('Not enough arguments');
end
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
else
    %
    error('Please compile the function erfcc.f as a mex file.');
    %
    % Warning: Zplasma must be checked first. Second derivative
    % calculations are wrong for imag. part and for small arguments.
    %
    %[Z_sn,Zp_sn,Zpp_sn] = Zplasma(zeta_sn,NZ);
    %
end
%
%   Dielectric tensor elements
%
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
slambda = (Nperp*sbeta./sy).^2;
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
if herm_mode == 1,
    %
    X = (X + X')/2;
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
end
