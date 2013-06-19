function [XXthetastar1,XXthetastar2,XXsig] = thetastar_dke_en(equilDKE,gridDKE,Zmomcoef,ohm,radialDKE)
%
% Calculation of the critical poloidal angle value theta_star for runaway avalanches
%
% INPUT:
%
%   - equil: magnetic equilibrium structure
%   - gridDKE: grid structure
%   - Zmomcoef: momentum dynamics structure
%   - radialDKE: radial grid structure
%
% OUTPUT:
%
%   - XXthetastar1: poloidal angle value theta_star between 0 and pi
%       [np,nmhu,nr] on each flux surface ie [np,nmhu,length(B)]
%   - XXthetastar2: poloidal angle value theta_star between pi and 2*pi
%   -the sum sig [npn,nmhu,l]
%
% By E. Nilsson (CEA-IRFM, emelie.nilsson@cea.fr) Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker
% (CEA-DRFC, joan.decker@cea.fr) 
%
method='linear';%'linear';
npn = size(gridDKE.XXmhu,1);
nmhu = size(gridDKE.XXmhu,2);
npsi=size(equilDKE.XBx,1); %nr of radial positions

theta=equilDKE.mtheta;
ntheta = length(theta);
xpsin = equilDKE.xpsin;
ap=equilDKE.ap;
Rp=equilDKE.Rp;Zp=equilDKE.Zp;
B0=equilDKE.xB0;
%B0=sqrt(equilDKE.XBx(:,1).^2 + equilDKE.XBy(:,1).^2 + equilDKE.XBphi(:,1).^2); %min bfield
Bmax=sqrt(equilDKE.XBx(:,(ntheta+1)/2).^2 + equilDKE.XBy(:,(ntheta+1)/2).^2 + equilDKE.XBphi(:,(ntheta+1)/2)).^2;
XXthetastar1=NaN(npn,nmhu,npsi);
XXthetastar2=NaN(npn,nmhu,npsi);
XXBstar=NaN(npn,nmhu,npsi);
dPsi1=NaN(npn,nmhu,npsi);
dPsi2=NaN(npn,nmhu,npsi);
Brk1=NaN(npn,nmhu,npsi);
Brk2=NaN(npn,nmhu,npsi);
Bzk1=NaN(npn,nmhu,npsi);
Bzk2=NaN(npn,nmhu,npsi);
%
for l=1:length(B0)
    Br=equilDKE.XBx(l,:);
    Bz=equilDKE.XBy(l,:);
    Bphi=equilDKE.XBphi(l,:);
    Bp=sqrt(Br.^2+Bz.^2);        %poloidal Bfield
    Bt=abs(Bphi);                %toroidal Bfield
    B=sqrt(Bt.^2+Bp.^2);
    XXBstar(:,:,l)=2*B0(l)./(1-gridDKE.XXmhu(:,:,1).^2)./(1 + Zmomcoef.XXgamma(:,:,1));
    %xi0(:,:,l)=sqrt(1+(gridDKE.XXmhu.^2-1).*B0(l)/B(l));
    %XXBstar(:,:,l)=2*B0(l)./(1-xi0(:,:,l).^2)./(1 + Zmomcoef.XXgamma(:,:,1));
    for ip=1:npn
        for im=1:nmhu
            if XXBstar(ip,im,l)>=B0(l) && XXBstar(ip,im,l)<=Bmax(l) %criterion, XXBstar>=XXB0 and XXBstar<=Bmax
                XXthetastar1(ip,im,l)=interp1(B(1:(ntheta+1)/2),theta(1:(ntheta+1)/2),XXBstar(ip,im,l),method);     %calc theta_k* <pi
                XXthetastar2(ip,im,l)=interp1(B((ntheta+1)/2:end),theta((ntheta+1)/2:end),XXBstar(ip,im,l),method);%calc theta_k* >pi
                [dummy, I] = min(abs(theta-XXthetastar1(ip,im,l))); %find nearest neighbor
                dPsi1(ip,im,l)=(B(I)-XXBstar(ip,im,l))/(theta(I)-XXthetastar1(ip,im,l))/B0(l); %calc psi' for theta)k*1
                [dummy, J] = min(abs(theta-XXthetastar2(ip,im,l)));
                dPsi2(ip,im,l)=(B(J)-XXBstar(ip,im,l))/(theta(J)-XXthetastar2(ip,im,l))/B0(l); %calc psi' for theta)k*2
                Brk1(ip,im,l)=interp1(theta,Br,XXthetastar1(ip,im,l),method);
                Brk2(ip,im,l)=interp1(theta,Br,XXthetastar2(ip,im,l),method);
                Bzk1(ip,im,l)=interp1(theta,Bz,XXthetastar1(ip,im,l),method);
                Bzk2(ip,im,l)=interp1(theta,Bz,XXthetastar2(ip,im,l),method);
            end
        end
    end
    
end
%
Rk1=ap.*cos(XXthetastar1)+Rp;
Rk2=ap.*cos(XXthetastar2)+Rp;
Zk1=ap.*sin(XXthetastar1)+Zp;
Zk2=ap.*sin(XXthetastar2)+Zp;
%
if any(XXthetastar1(:)<0) || any(XXthetastar1(:)>pi) || any(XXthetastar2(:)<pi) || any(XXthetastar2(:)>2*pi)
     disp('Warning! Theta* out of range (theta* [0,2pi])')
 else
    XXsig=((Rk1-Rp).^2+(Zk1-Zp).^2)./abs(-Bzk1.*(Rk1-Rp)+Brk1.*(Zk1-Zp)).*1./abs(dPsi1)+...
        ((Rk2-Rp).^2+(Zk2-Zp).^2)./abs(-Bzk2.*(Rk2-Rp)+Brk2.*(Zk2-Zp)).*1./abs(dPsi2); %sum in 1.50 lukedoc, k=1,2
end
