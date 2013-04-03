function [y,y_th,py_th] = randreject_yp(fun_handle,args_in,N,display_mode)
%
% Calculate N times the random variable x whose p.d.f. is f(x). f(x) may
% not be normalized to unity on the integration domain [xmin,xmax], where
% xmin < xmax.
%
% Input:
%
%   - fun_handle : handle to the function f(x) which may be parametrized and must be expressed as f(a1,a2,a3,...,[xmin,xmax],x). It is better that f(x) is normalized to unity on the integration domain [xmin,xmax].
%   - args_in : N-1 first arguments of the function f(a1,a2,a3,...,[xmin,xmax],x): a1,a2,a3,...,[xmin,xmax]. The last arguments of args_in must be the range of the random variable [xmin,xmax] on which f(x) is calculated.
%   - N : number of trials [1,1]
%     (default = 100000)
%   - display_mode : display the numerical and theoretical p.d.f and display the distribution is > 0 and is the number of bin of the histogram (0: no, > 1, yes) [1,1]
%     (default = 0)
%
% Output:
%
%   - y : random variable [N,1]
%   - y_th : theoretical random variable [N,1]
%   - py_th : theoretical p.d.f. normalized to 1 [N,1]
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
if nargin < 2,
    error('Wrong number of input arguments in randreject_yp.m');
elseif nargin < 3,
    N = 100000;
    display_mode = 0;
elseif nargin < 4,
    display_mode = 0;
end
%
y = NaN(N,1);
%
if nargin == 4,
    if display_mode,
        if display_mode < round(N/100),
            disp(['WARNING: display_mode parameter must exceed be of the order of ',int2str(round(N/100)),' for a correct histogramm.']);
            display_mode = round(N/100);
        else
            disp(['WARNING: not enough trials for drawing a correct histogramm -> display_mode parameter set to zero.']);
            display_mode = 0;
        end
    end
end
%
arg_range = args_in{length(args_in)};
%
if isnan(arg_range) | isempty(arg_range), 
    error('Error: the range of the input argument must be given');
end
%
arg_index = length(args_in)+1;
%
if arg_range(1) < arg_range(2),
    xmax = fminbnd(@(x) (-1)*fun_handle(args_in(1:length(args_in)-1),[arg_range(1),arg_range(2)],x),arg_range(1),arg_range(2));
else
    xmax = fminbnd(@(x) (-1)*fun_handle(args_in(1:length(args_in)-1),[arg_range(1),arg_range(2)],x),arg_range(2),arg_range(1));
end  
%
if ~isempty(xmax)
    c = feval(fun_handle,args_in(1:length(args_in)-1),[arg_range(1),arg_range(2)],xmax); 
else
    error('Error in determining the maximum of the function in the interval in randreject_yp.m.')
end
%
while isnan(sum(y)),
    %
    y0 = (arg_range(2) - arg_range(1))*NaN(sum(isnan(y)),1) + arg_range(1);
    y1 = (arg_range(2) - arg_range(1))*rand(sum(isnan(y)),1) + arg_range(1);
    y2 = rand(sum(isnan(y)),1);
    %
    mask0 = y2 < feval(fun_handle,args_in(1:length(args_in)-1),[arg_range(1),arg_range(2)],y1)/c; 
    %
    y0(mask0) = y1(mask0);
    %
    inan = find(isnan(y) == 1);
    y(inan) = y0;
end
%
if display_mode,
    y_th = (arg_range(2) - arg_range(1))*linspace(0,1,N) + arg_range(1);
    py_th = feval(fun_handle,args_in(1:length(args_in)-1),[arg_range(1),arg_range(2)],y_th);
    norm_th = trapz(y_th,py_th);
    %
    if N/display_mode > display_mode,%for good statistics, display_mode is the number of bin for the histogram
        [h1,y1] = hist(y,display_mode);
        py = h1*display_mode/N/(max(y1) - min(y1));
        norm = trapz(y1,py);
        close all
        figure(1),plot(y1,py,'b',y_th,py_th,'r')
        axis([min(arg_range(1),arg_range(2)),max(arg_range(1),arg_range(2)),min(py),max(py)])
        xlabel('y');ylabel('f(y)');
        if arg_range(2) > arg_range(1),
            title(['Distribution function between ',num2str(arg_range(1)),' and ',num2str(arg_range(2))])
            legend(['Numerical, norm. = ',num2str(norm)],['Theoretical, norm. = ',num2str(norm_th)],'Location','SouthWest')
        else
            title(['Distribution function between ',num2str(arg_range(1)),' and ',num2str(arg_range(2))])
            legend(['Numerical, norm. = ',num2str(norm)],['Theoretical, norm. = ',num2str(norm_th)],'Location','NorthWest')
        end
    else
        warning('Not enough points for histogram display');
    end
else
    y_th = NaN;
    py_th = NaN;
    norm_th = NaN;
end