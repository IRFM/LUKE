function g = redistrib_jd(x,f,y,testsum)
%
% This function redistributes the function f defined on the cells limited
% by the grid x onto the cells limited bythe grid y
%
% INPUTS : 
%   - x : grid delimiting the original cells [nx,1];
%   - f : function evaluated on the original cells [nx-1,1];
%   - y : grid delimiting the output cells [ny,1];
%   - testsum : (1) test that integral is conserved (0) do not test [1,1]; 
%
% OUTPUTS : 
%   - g : function evaluated on the output cells [ny-1,1];
%
% by J. Decker, E. Nilsson and Y. Peysson
%
if nargin < 3,
    error('Not enough input arguments')
end
%
x = x(:);
f = f(:);
%
nx = length(x);
%
if nx < 2,
    error('The grid x should delimit at least one cell');
end
if length(f) ~= nx - 1
    error('The length of f must be nx - 1');
end
%
if nargin < 3,% assumes y=x
    g = f;
    return
end
%
y = y(:);
ny = length(y);
%
dx = diff(x);
dy = diff(y);
%
if any(dx <= 0),
    error('The grid x should be monotonically increasing.');
end
if any(dy <= 0),
    error('The grid y should be monotonically increasing.');
end
%
if y(1) > x(1) || y(end) < x(end),
    disp('WARNING : some contributions of f will be lost as the y grid does not completely overlap the x grid')
end
%
X = repmat(x.',[ny-1,1]);
Y = repmat(y,[1,nx-1]);
%
maskYminp = Y(2:end,:) < X(:,2:end);
maskYminm = Y(1:end-1,:) < X(:,1:end-1);
%
D = (Y(2:end,:).*maskYminp + X(:,2:end).*~maskYminp) - (Y(1:end-1,:).*~maskYminm + X(:,1:end-1).*maskYminm);% min(Xp,Yp) - max(Xm,Ym)
%
D(D < 0) = 0;
%
g = D*f./dy;
%
if nargin == 4 && testsum,
    %
    sx = sum(f.*dx);
    sy = sum(g.*dy);
    %
    disp(['The relative difference on the integral is : ',num2str(abs((sy - sx)/sx))])
    %
end



    
