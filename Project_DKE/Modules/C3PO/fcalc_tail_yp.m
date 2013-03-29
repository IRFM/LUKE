function [fx,normfx] = fcalc_tail_yp(args_in,x_range,x,testmode)
%
% Function for script randreject_yp. Calculate the launched n||0 power
% spectrum for the LH wave. Need output of calc_tail_jd.m 
%
% Input:
%
%   - args_in : input arguments of fcalc_tail_yp 
%   - x_range : range of the random variable [3,1] or [1,3] for example. If [1,3], f(1)/f(3) = 1/h, and if [3,1], f(1)/f(3) = h.
%
% Output:
%
%   - fx : p.d.f. of the random variable x [N,1]
%   - normfx :  numerical norm of the p.d.f fx [1,1]
%
% by Y.Peysson (CEA-IRFM) <yves.peysson@cea.fr> and J. Decker (CEA-IRFM) <joan.decker@cea.fr>
%
if nargin < 3,
    error('Wrong number of input arguments in fcalc_tail_yp.m');
end
%
Npar0_tail = args_in{1};
dNpar0_tail = args_in{2};
P0_2piRp_tail = args_in{3};
P0_2piRp = args_in{4};
%
n_tail = length(Npar0_tail);
%
for in = 1:n_tail,
	xdPdN(in,:) = P0_2piRp_tail(in)/P0_2piRp*exp(-(x - Npar0_tail(in)).^2/dNpar0_tail(in).^2)/(sqrt(pi)*dNpar0_tail(in));
end
%
fx = sum(xdPdN);fx = fx(:);
%
% Test that fx is normalized to one in the interval defined by x_range
%
if nargin > 3,
    if testmode,
        x_test = linspace(x_range(1),x_range(2),10000);
        %
        for in = 1:n_tail,
            xdPdN_test(in,:) = P0_2piRp_tail(in)/P0_2piRp*exp(-(x_test - Npar0_tail(in)).^2/dNpar0_tail(in).^2)/(sqrt(pi)*dNpar0_tail(in));
        end
        %
        fx_test = sum(xdPdN_test);
        %
        normfx = trapz(x_test,fx_test);
    end
else
    normfx = NaN;
end
