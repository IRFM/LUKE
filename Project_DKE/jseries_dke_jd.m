function XJ = jseries_dke_jd(mhutrap,mhu,m)
%
% Calculates series J2m for bounce integrals
% 
%   INPUTS:
%       
%       - mhutrap: cosine of the trapping pitch angle [1,1]
%       - mhu: grid in pitch angle cosines [1,nmhu]
%       - m: m-1 is the maximun order for the series [1,1]
%
%   OUTPUTS:
%       
%       - XJ: matrix of the series [m+1,nmhu]
%
% Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
nmhu = length(mhu);
XJ = zeros(m+1,nmhu);
k = zeros(1,nmhu);
e = zeros(1,nmhu);
r = zeros(1,nmhu);
r2 = zeros(1,nmhu);
mhu2 = mhu.*mhu;
mhutrap2 = mhutrap^2;
%
if mhutrap < 0 or mhutrap > 1,
    error('mhutrap must be between 0 and 1')
end
if prod(mhu-mhutrap) == 0,
    imhu = find(mhu2 == mhutrap2);
    dmhu = diff(mhu);
	 mhutrap = mhutrap - eps;%In order to avoid numerical singularity at mhutrap
	 mhutrap2 = mhutrap^2;
end
%
maskm = mhu2<mhutrap2;
maskp = mhu2>mhutrap2;
r = maskm.*mhu/mhutrap + maskp.*mhutrap./mhu;
r2 = r.^2;
%   
[k,e] = ellipke(r2);
%
XJ(1,:) = maskm.*abs(r).*k + maskp.*k;
if m>0,
    XJ(2,:) = maskm.*abs(r).*(k-e) + maskp./r2.*(k-e);
    if m>1,
        for i=2:m,
            XJ(i+1,:) = 1/(2*i - 1)*((2*i - 2)*(1 + mhu2/mhutrap2).*XJ(i,:) - (2*i - 3)*mhu2/mhutrap2.*XJ(i-1,:));
		end
    end
end
if sum(sum(isnan(XJ)))~=0,error('NaN results in the J2m functions for bounce integrals');end

