function gkE = dresp_dke_yp(res,phf,kd,k)
%
%       Calculation of the energy response function of detector (scintillator
%       coupled with a photo-multiplier or diode). Compton scattering, photoelectric
%       absorption and detector resolution due to counting noise are 
%       taken into account.
%
%       Input:
%
%               - res: fit parameters of the energy resolution of the detectors [m,2]
%               - phf: photofraction determined using the "MCDET.for" Monte-carlo hard x-ray absorption
%                          code at energies kd [m,p]
%               - kd: reference energies for the photofraction [m,p]
%               - k: photon energy (keV) [1,n]
%
%       Output:
%       
%               - gkE: full detector's response matrix (keV-1) [n,n]
%
%
%by Y.PEYSSON CEA-DRFC 27/06/1991 <peysson@fedv09.cad.cea.fr>
%revised for MatLab 4.1 (25/08/1994) 
%
if nargin < 4,
        infoyp(2,'Wrong number of input arguments for dresp_dke_yp');
        return;
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
if min(size(k)) > 1,
        error('k must be a vector');
        return;
end
k = k(:);
k = k';
nk = length(k);
deltak = k(2)-k(1);
E = k;
%
gkE = zeros(nk,nk);
gkEph = zeros(nk,nk);
gkEph0 = zeros(nk,nk);
gkEco = zeros(nk,nk);
%
Rk = (interp1(kd,phf,k,'spline'))';
dEk = (res(1)*k.^res(2)).*k;
Ec = (2*k.^2)./(2*k+mc2);
dEc = (res(1)*Ec.^res(2)).*Ec;
ic = fix(Ec/(k(2)-k(1)));
%
for i=1:nk,
        if dEk(i)~=0,
                gkEph(i,:) = Rk(i)*2*sqrt(log(2)/pi)*exp(-4*log(2)*(E-k(i)).^2/dEk(i)^2)/dEk(i);
                if ic(i)==0,
                        gkE(i,:) = gkEph(i,:);
                else
                        E1 = E(1:ic(i));E2 = E(ic(i)+1:nk);sE1 = size(E1);
                        gkEco1(i,:) = ((1-Rk(i))*2*sqrt(log(2)/pi)*(1/(0.5+2*sqrt(log(2)/pi)*Ec(i)/dEc(i))))*ones(1,sE1(2))/dEc(i);
                        gkEco2(i,:) = (1-Rk(i))*2*sqrt(log(2)/pi)*(1/(0.5+2*sqrt(log(2)/pi)*Ec(i)/dEc(i)))*exp(-4*log(2)*(E2-Ec(i)).^2/dEc(i)^2)/dEc(i);
                        gkEco(i,:) = [gkEco1(i,:),gkEco2(i,:)];gkEco1 = [];gkEco2 = [];
                        gkE(i,:) = gkEph(i,:)+gkEco(i,:);
                end
        else
                gkEph0 = speye(i,nk);
                gkEph(i,:) = Rk(i)*gkEph0(i,:)/deltak;
                if ic(i)==0,
                        gkE(i,:) = gkEph(i,:);
                else
                        E1 = E(1:ic(i));E2 = E(ic(i)+1:nk);sE1 = size(E1);sE2 = size(E2);
                        gkEco1(i,:) = ((1-Rk(i))/Ec(i))*ones(1,sE1(2));
                        gkEco2(i,:) = 0.0*ones(1,sE2(2));
                        gkEco(i,:) = [gkEco1(i,:),gkEco2(i,:)];gkEco1 = [];gkEco2 = [];
                        gkE(i,:) = gkEph(i,:)+gkEco(i,:);
                end
        end
end


