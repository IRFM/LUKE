function [x] = powerdiff_dke_jd(x1,dx1,x2,dx2,dxmax,y)
%by Joan Decker (MIT/RLE, jodecker@mit.edu)
%modified by Yves peysson (CEA/DRFC, yves.peysson@cea.fr) 22/07/03
%
%
if dx2 < dx1
    dxc = dx1;
    dx1 = dx2;
    dx2 = dxc;
    inv = 1;
else
    inv = 0;
end
%
deltax = x2 - x1;
%
N = floor((log(max(dxmax,dx2)) - log(dx1))/log(y)) + 1;
%
yn = y.^(1:N);
yyn = repmat(yn',[1,N]);
lyn = sum(triu(yyn));
%
rdxramp = dx2/dx1;
nrdxramp = max([ceil(log(rdxramp)/log(y)) - 1,0]);
if nrdxramp > 1
    xramp = (lyn(nrdxramp-1) + 1)*dx2/yn(nrdxramp);
elseif nrdxramp == 1
    xramp = dx2/yn(nrdxramp);
else
    xramp = 0;
end
solution = 0;
if deltax < max(xramp + dx2/yn(nrdxramp + 1))
    if nrdxramp == 1 & deltax >= max(xramp)
        if deltax <= dx1*y
            solution = 1;
        end
    end
    if nrdxramp > 1 & deltax >= max(xramp)
        solution = 1;
    end
    if solution == 0,
        warning('empty output from powerdiff');
        x = [];
        break
    end
end
%
dx0 = dxmax;
%
rdx1 = dx0/dx1;
nrdx1 = floor(log(rdx1)/log(y));
%
rdx2 = dx0/dx2;
nrdx2 = floor(log(rdx2)/log(y));
%
if nrdx1 > 0
    dx1_max = yn(nrdx1)*dx1;
    xramp1 = lyn(nrdx1)*dx1;
else
    dx1_max = dx1;
    xramp1 = 0;
end
if nrdx2 > 0
    dx2_max = yn(nrdx2)*dx2;
    xramp2 = lyn(nrdx2)*dx2;
else
    dx2_max = dx2;
    xramp2 = 0;
end
%
d = deltax - xramp1 - xramp2;
dx = [];
dx2ramp = [];
dx2_new = dx2/y;
dx1_new = dx1/y;
x = NaN;
while isempty(dx);
    if d < 0
        if dx2_max >= dx1_max & (nrdx2 > 0)
            nrdx2 = nrdx2 - 1;
            if nrdx2 > 0
                dx2_max = yn(nrdx2)*dx2;
                xramp2 = lyn(nrdx2)*dx2;
            else
                dx2_max = dx2;
                xramp2 = 0;
            end
        elseif nrdx1 > 0
            nrdx1 = nrdx1 - 1;
            if nrdx1 > 0
                dx1_max = yn(nrdx1)*dx1;
                xramp1 = lyn(nrdx1)*dx1;
            else
                dx1_max = dx1;
                xramp1 = 0;
            end
        end
        dx0 = min(dx1_max,dx2_max)*y;
    else
        ndx0 = ceil(d/dx0);
        dx0_new = d/(ndx0);
        if (dx0_new >= dx1_max) & (dx0_new >= dx2_max | (nrdx2 == 0 & dx0_new >= dx2_new))
            dx = [dx1*yn(1:nrdx1),ones(1,ndx0)*dx0_new,dx2ramp,dx2*yn(nrdx2:-1:1)];
            break
        else
            if nrdx2 == 0
                if dx1_max < dx2_new
                    dx2ramp = [dx2_new, dx2ramp];
                    xramp2 = xramp2 + dx2_new;
                    dx2_new = dx2_new/y;
                elseif nrdx1 > 0
                    nrdx1 = nrdx1 - 1;
                    if nrdx1 > 0
                        dx1_max = yn(nrdx1)*dx1;
                        xramp1 = lyn(nrdx1)*dx1;
                    else
                        dx1_max = dx1;
                        xramp1 = 0;
                    end
                    dx0 = dx1_max*y;
                else
                    if dx0_new > dx1_new 
                        if dx0_new > dx2_new
                            dx1_max = dx1_new;
                        elseif dx1_new < dx2_new
                            dx2ramp = [dx2_new, dx2ramp];
                            xramp2 = xramp2 + dx2_new;
                            dx2_new = dx2_new/y;
                        end        
                    else
                        warning('empty output from powerdiff');
                        x = [];
                        break
                    end
                end
            else
                if dx1_max >= dx2_max
                    nrdx1 = nrdx1 - 1;
                else
                    nrdx2 = nrdx2 - 1;
                end
                if nrdx1 > 0
                    dx1_max = yn(nrdx1)*dx1;
                    xramp1 = lyn(nrdx1)*dx1;
                else
                    dx1_max = dx1;
                    xramp1 = 0;
                end
                if nrdx2 > 0
                    dx2_max = yn(nrdx2)*dx2;
                    xramp2 = lyn(nrdx2)*dx2;
                else
                    dx2_max = dx2;
                    xramp2 = 0;
                end
                dx0 = min(dx1_max,dx2_max)*y;
            end
        end
    end
    d = deltax - xramp1 - xramp2;
end
if isempty(x)
    break
end
if inv == 0;
    x = cumsum([x1,dx]);
else
    x = cumsum([x1,fliplr(dx)]);
end







