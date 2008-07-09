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
%               - phf: photofraction determined using the "mcdet.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
%               - kd: reference energies for the photofraction [m,p]
%               - k: photon energy (keV) [1,n]
%
%       Output:
%       
%               - gkE: full detector's response matrix (keV-1) [n,n]
%
%
%by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
%
if nargin < 4,
   error('Wrong number of input arguments for dresp_dke_yp');
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
if min(size(k)) > 1,
        error('k must be a vector');
end
k = k(:);
k = k';
nk = length(k);
deltak = k(2)-k(1);
E = k;
%
gkE = zeros(nk,nk);
%
Rk = (interp1(kd,phf,k,'spline'))';
dEk = (res(1)*k.^res(2)).*k;
Ec = (2*k.^2)./(2*k+mc2);
dEc = (res(1)*Ec.^res(2)).*Ec;
%
for i=1:nk,
        ic = max(find(E<=Ec(i)));
        if isempty(ic),ic = 0;end
        %
        if dEk(i)~=0,
                gkEph = Rk(i)*2*sqrt(log(2)/pi)*exp(-4*log(2)*(E - k(i)).^2/dEk(i)^2)/dEk(i);
                if ic==0,
                        gkE(i,:) = gkEph/Rk(i);
                else
                        E1 = E(1:ic);
                        E2 = E(ic+1:nk);
                        gkEco1 = (1 - Rk(i))/(0.5*dEc(i)/2/sqrt(log(2)/pi) + Ec(i))*ones(1,size(E1,2));
                        gkEco2 = (1 - Rk(i))/(0.5*dEc(i)/2/sqrt(log(2)/pi) + Ec(i))*exp(-4*log(2)*(E2 - E2(1)).^2/dEc(i)^2);
                        gkEco = [gkEco1,gkEco2];
                        gkE(i,:) = gkEph + gkEco;
                end
        else
                gkEph0 = speye(i,nk);
                gkEph = Rk(i)*gkEph0/deltak;
                if ic==0,
                        gkE(i,:) = gkEph/Rk(i);
                else
                        E1 = E(1:ic);
                        E2 = E(ic+1:nk);                    
                        gkEco1 = ((1 - Rk(i))/Ec(i))*ones(1,size(E1,2));
                        gkEco2 = 0.0*ones(1,size(E2,2));
                        gkEco = [gkEco1,gkEco2];
                        gkE(i,:) = gkEph + gkEco;
                end
        end
end


