function n = fact_dke_jd(n)
%
% Factorial function compatible with singles.
% See factorial for more info.
%
% by J. Decker
%
N = n(:);
%
if any(fix(N) ~= N) || any(N < 0) || ~isreal(N)
  error('MATLAB:factorial:NNegativeInt', ...
        'N must be a matrix of non-negative integers.')
end
%
if isa(N,'double'),
    %
    n(N>170) = 171;
    m = max([1; n(:)]);
    N = [1 1 cumprod(2:m)];
    n(:) = N(n+1);
    % 
elseif isa(N,'single'),
    %
    n(N>34) = 35;
    m = max([1; n(:)]);
    N = [1 1 cumprod(2:m)];
    n(:) = N(n+1);
    % 
else
    error('Input must be double or single')
end
    



