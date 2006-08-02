function [y] = ppval_yp(pp,x)
%
% Non vectorial polynomial piecewise calculation for testing the C language
% implementation in the ray-tracing
%
% INPUT
%    - pp: piecewise polynomial structure
%    - x: values on which y function calculated [1,n]
%
% OUTPUT
%
%    - y: function calculated from piecewise polynomials (m dimensions if pp.dim > 1) if [m,n] 
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
x = x(:);
y = zeros(length(x),pp.dim);
%
for i = 1:length(x),
    for j = 1:pp.pieces;
        if x(i)>=pp.breaks(j) & x(i)<=pp.breaks(j+1),
            for k = 1:pp.dim,
                if pp.order == 2,
                    y(i,k) = pp.coefs(k+(j-1)*pp.dim,1)*(x(i) - pp.breaks(j)) + pp.coefs(j+(k-1)*pp.dim,2);
                elseif pp.order == 3,
                    y(i,k) = pp.coefs(k+(j-1)*pp.dim,1)*(x(i) - pp.breaks(j))^2 + pp.coefs(k+(j-1)*pp.dim,2)*(x(i) - pp.breaks(j)) + pp.coefs(k+(j-1)*pp.dim,3);
                elseif pp.order == 4,
                    y(i,k) = pp.coefs(k+(j-1)*pp.dim,1)*(x(i) - pp.breaks(j))^3 + pp.coefs(k+(j-1)*pp.dim,2)*(x(i) - pp.breaks(j))^2 + pp.coefs(k+(j-1)*pp.dim,3)*(x(i) - pp.breaks(j)) + pp.coefs(k+(j-1)*pp.dim,4);
                end
            end
        end
    end
end
%






