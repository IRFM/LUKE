% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function yb = broaden_dke_yp(x,y,width)
% LUKE - Columnwise normalized Gaussian profile broadening
%
%       Numerical Gaussian profile broadening for stabilizing current density or
%       energy transport equations when initial profile is too sharp.
%       Important for CRONOS stability
%
%       Input:
%
%               - x: normalized radial coordinate [m,1]
%               - y: input profiles [m,n]
%               - width: half-width of the Gaussian function at [1,1]
%
%       Output:
%       
%               - yb: output broad profiles [m,n]
%
if nargin < 2,
   error('Wrong number of input arguments for broaden_dke_yp');
end
%
if nargin == 2,
    yb = y;
    return;
end
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


