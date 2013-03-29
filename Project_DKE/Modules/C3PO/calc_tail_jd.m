function [Npar0_tail,dNpar0_tail,P0_2piRp_tail] = calc_tail_jd(Npar0,dNpar0,P0_2piRp,Nparmax_tail,n_tail,P_tail,opt_tail,display_mode)
%
% This function generates the series of rays to represent the spectral tail
%
% INPUTS : 
%
% 
%
if nargin < 8,
    display_mode = 0;
end
%
if nargin < 7,
    opt_tail = 1;%linear
end
%
if imag(Npar0) ~= 0,% case where nz is prescribed instead of Npar - only nz is tailed out
    %
    Ny = real(Npar0);
    Npar0 = imag(Npar0);% nz
    %
else
    Ny = NaN;
end
%
if Npar0 < 0,% working in positive spectrum
    s = -1;
    Npar0 = - Npar0;
else
    s = 1;
end
%
fac = exp(-1);%overlap factor
%
facln = sqrt(-log(fac));
%
if dNpar0 == 0 || imag(opt_tail) == 1,% uniform dNpar0 in the tail
    dNpar0_new = abs(Nparmax_tail - Npar0)/(1+2*n_tail)/facln;
else
    dNpar0_new = dNpar0;
end
%
N_ini = Npar0 + dNpar0_new*facln;
%
if Nparmax_tail <= N_ini,% no tail is required as single pass absorption is ensured
    n_tail = 0;
end
%
if n_tail == 0,% no tail
    %
    Npar0_tail = s*Npar0;
    dNpar0_tail = dNpar0;
    P0_2piRp_tail = P0_2piRp;
    %
    if ~isnan(Ny),
        Npar0_tail = Ny + 1i*Npar0_tail;
    end
    %
    return
end
%
N_sep = linspace(N_ini,Nparmax_tail,n_tail + 1);
%
Npar0_tail = [Npar0,(N_sep(2:end) + N_sep(1:end-1))/2];% lobes positions
%    
dNpar0_tail = [dNpar0_new,diff(N_sep)/(2*facln)];% lobes width
%
h_tail = real(opt_tail);% final power fraction of the tail
%
if isnan(P_tail),% power in first lobe follows tail evolution
    %
    P_tail = n_tail*(n_tail + h_tail)/(n_tail+1)^2;
    %
%     P0_2piRp_tail = P0_2piRp*((1-h_tail)*(2*n_tail+1:-2:1)/(n_tail+1)^2 ...
%       + h_tail*ones(1,n_tail+1)/(n_tail+1));% lobes power (linear distribution)
end
%
P0_2piRp_tail = P0_2piRp*[(1-P_tail),...
    (1-h_tail)*P_tail*(2*n_tail-1:-2:1)/n_tail^2 ...
  + h_tail*P_tail*ones(1,n_tail)/n_tail];% lobes power (linear distribution)
%
if display_mode == 2,
    %
    nx = 101;
    xlim = [Npar0-2*dNpar0_new,Nparmax_tail+dNpar0_new];
    %
    xN = linspace(xlim(1),xlim(2),nx);
    %
    xdPdN_0 = exp(-(xN - Npar0).^2/dNpar0.^2)/(sqrt(pi)*dNpar0);
    %
    for in = 1:n_tail + 1,
        xdPdN(in,:) = P0_2piRp_tail(in)/P0_2piRp*exp(-(xN - Npar0_tail(in)).^2/dNpar0_tail(in).^2)/(sqrt(pi)*dNpar0_tail(in));
    end
    %
    [sxdPdN] = feval(@fcalc_tail_yp,{Npar0_tail,dNpar0_tail,P0_2piRp_tail,P0_2piRp},xlim,xN);
    %
    leg = {'Orig.','Tail'};
    %
    figure(1),clf
    %
    graph1D_jd(xN,xdPdN_0,0,0,'','','',NaN,xlim,NaN,'-','none','b',2,20+14i);
    graph1D_jd(xN,sxdPdN,0,0,'N_{||}','dPdN_{||} (norm.)','',leg,xlim,NaN,'-','none','r',2,20+14i,gca,0.9,0.7,0.7);
    graph1D_jd(xN,xdPdN,0,0,'','','',NaN,xlim,NaN,'-','none','m',0.5,20+14i);
    %    
end
%
Npar0_tail = s*Npar0_tail;
%
if ~isnan(Ny),
    Npar0_tail = Ny + 1i*Npar0_tail;
end
%
