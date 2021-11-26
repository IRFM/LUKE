function gkE = dresp_dke_mehxr(res,phf,kd,k)
%
%       Calculation of the energy response function of a semiconductor
%       detector with lower cutoff energy
%       
%       Input:
%
%               - res: charge-sharing parameter (dimensionless) [m,1]
%               - phf: detector resolution (width of the detector's
%               S-curve) (keV) [m,p]
%               - kd: reference energies for detector resolution [m,p]
%               - k: photon energy (keV) [1,n]
%
%       Output:
%       
%               - gkE: full detector's response matrix (keV-1) [n,n]
%
%
%by T. BARBUI <tbarbui@pppl.gov>
%
if nargin < 4,
   error('Wrong number of input arguments for dresp_dke_yp');
end
%
if min(size(k)) > 1,
        error('k must be a vector');
end
k = k(:);
k = k';
nk = length(k);
E = k;
%
gkE = zeros(nk,nk);
%
sigma = (interp1(kd,phf,k,'linear'))';
f=res(1);
%
%first index: threshold energy k
%second index: photon energy E
for i=1:nk
        gkE(i,:) = abs(0.5*(erfc((k(i)-E)/(sqrt(2)*sigma(i)))).*(1 + 2*f*(1 - k(i)./E))/(1 + f));
end


