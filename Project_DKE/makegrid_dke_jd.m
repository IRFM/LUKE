function x = makegrid_dke_jd(xmin,nmin,dxmin,xmax,nmax,dxmax,ntot,dtop,grid_power);
%
% This function generates a non-uniform grid.
%
%   INPUTS:
%
%       - xmin: initial grid position
%       - nmin: minimum number of fine grid points near xmin
%       - dxmin: minimum grid step near xmin
%       - xmax: final grid position 
%       - nmax: minimum number of fine grid points near xmax
%       - dxmax: minimum grid step near xmax
%       - ntot: minimum total number of points, including ends 
%       - dtop: maximum grid step
%       - grid_power: maximum ratio between size of two consecutive steps
%       (y_power > sqrt(2) encouraged)
%
%   OUTPUTS:
%
%       - x: non-uniform grid
%
%  by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
if nargin < 9
    error('not enough arguments')
end
%
if ntot > nmin + nmax
    warning('ntot = nmin + nmax enforced')
    ntot = nmin + nmax;
end
%
if abs((dxmax - dxmin)/dxmax) < 1e-10
    dxmax = dxmin;
end
%
xtot = xmax - xmin;
%
if dxmax < dxmin
    nc = nmin;
    nmin = nmax;
    nmax = nc;
    %
    dxc = dxmin;
    dxmin = dxmax;
    dxmax = dxc;
    %
    clear nc dxc
    inv = 1;
else
    inv = 0;
end
%
grid_ok = 0;
%
xin = powerdiff_dke_jd(nmin*dxmin, dxmin, xtot - nmax*dxmax, dxmax, dtop, grid_power);
if isempty(xin),
    while grid_ok == 0 & dxmax > dxmin  
        for imax = nmax:-1:0,
            xin = powerdiff_dke_jd(nmin*dxmin, dxmin, xtot - imax*dxmax, dxmax, dxmax, grid_power);
            if isempty(xin) | length(xin) < (ntot - nmin - imax + 1) | diff(xin(length(xin)-1:length(xin))) < dxmin, 
                for imin = 1:(ntot - imax - nmin - 1),
                    xin = powerdiff_dke_jd((nmin + imin)*dxmin, dxmin, xtot - imax*dxmax, dxmax, dxmax, grid_power);
                    if length(xin) >= (ntot - imax - nmin - imin + 1) & diff(xin(length(xin)-1:length(xin))) >= dxmin,
                        nmin = nmin + imin;
                        grid_ok = 1;
                        break
                    end
                end
            else 
                grid_ok = 1;
            end
            if grid_ok == 1,
                nmax = imax;
                break
            end
        end
        if grid_ok == 0,
            dxmax = max([dxmin,dxmax/grid_power]);
        end
    end
    if grid_ok == 0,
        nmin = 1;
        nmax = 1;
        xintot = xtot - nmin*dxmin - nmax*dxmin;
        itot = max([ntot - nmin - nmax,ceil(xintot/dxmin),1]);
        dxin = xintot/itot;
        if dxin > dxmin/grid_power
            xin = linspace(nmin*dxmin,xtot - nmax*dxmin,itot + 1);
        else
            nmin = 0;
            nmax = 0;
            ntot = max([ntot,ceil(xtot/dxmin)]);
            xin = linspace(0,xtot,ntot + 1);
        end
    end
end
%
rampmin = (0: 1:nmin-1)*dxmin;
rampmax = xtot - (nmax-1:-1:0)*dxmax;
%
x = [rampmin,xin,rampmax];  
dx = diff(x);
%
if inv == 0;
    x = cumsum([xmin,dx]);
else
    x = cumsum([xmin,fliplr(dx)]);
end
%
x(length(x)) = xmax;%to compensate numerical errors from cumsum.
