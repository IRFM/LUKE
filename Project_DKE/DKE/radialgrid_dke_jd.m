function [xpsin_f,xpsin_f_dke,xdpsin_f_dke,xpsinm_S_dke,xdpsinm_S_dke,xpsinp_S_dke,xdpsinp_S_dke,xpsin_S_dke,r_dke,ir_display_out]...
    = radialgrid_dke_jd(dke_mode,xpsin_S_dke,dpsin_dke,psin_display_in);
% 
% Generates a non uniform radial grid. 
%
%   INPUTS: 
%
%		- dke_mode : (1) resolution of the dke (0) of the FP equation
%		- xpsin_S_dke : flux radial grid
%		- dpsin_dke : maximum space between two consecutive points for DKE
%		radial derivative calculations
%		- psin_display_in: radial location at which data are displayed
%		(graphic mode)
%
%   OUTPUTS:
%
%       - xpsin_f: positions where FP equation is to be solved [1,nr]
%       - xpsin_f_dke: positions where DKE equation is to be solved
%       [1,nr_dke]
%       - xdpsin_f_dke: 
%       - xpsinm_S_dke: 
%       - xdpsinm_S_dke: 
%       - xpsinp_S_dke: 
%       - xdpsinp_S_dke: 
%       - xpsin_S_dke: 
%  		- r_dke: index of the radial positions for DKE calculations
%		- rho_display_out: radial location at which data are displayed
%		(graphic mode)
%		- ir_display_out: index of the radial location at which data are
%		displayed (graphic mode)
%
% by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and Yves Peysson
% <yves.peysson@cea.fr> (CEA/DRFC)
%
xpsin_S_dke = sort(xpsin_S_dke);
nr_S = length(xpsin_S_dke);
psinmin = 1e-3;
psinmax = 1-psinmin;
%
if nr_S == 1,%Case of local studies, no fast electron transport
	if xpsin_S_dke < psinmin, 
        xpsin_S_dke = psinmin;
        info_dke_yp(2,['WARNING: psin = 0 not allowed, psin = ',num2str(psinmin),' enforced !']);
    end
	if xpsin_S_dke > psinmax, 
        xpsin_S_dke = psinmax;
        info_dke_yp(2,['WARNING: psin = 0 not allowed, psin = ',num2str(psinmax),' enforced !']);
    end
%
	xpsin_f_dke = xpsin_S_dke;
	xdpsin_f_dke = NaN;
	xpsinm_S_dke = NaN;
	xdpsinm_S_dke = NaN;
	xpsinp_S_dke = NaN;
	xdpsinp_S_dke = NaN;
%    
    nr_f = 1;
else%Case of global studies, fast electron transport allowed 
	if xpsin_S_dke(1) ~= 0,%add extra point for the flux grid if not entered
		xpsin_S_dke = [0,xpsin_S_dke];
		nr_S = nr_S + 1;
	end
	if xpsin_S_dke(nr_S) ~= 1,%add extra point for the flux grid if not entered
		xpsin_S_dke = [xpsin_S_dke,1];
		nr_S = nr_S + 1;
	end
    maskmin = max(find((xpsin_S_dke(1) + xpsin_S_dke(2:nr_S))/2 <= psinmin)) + 1;
    if ~isempty(maskmin), %remove points too close from 0: ensures xpsin_f_dke >= psimin;
        xpsin_S_dke = [xpsin_S_dke(1), 2*psinmin - xpsin_S_dke(1), xpsin_S_dke(maskmin+1:nr_S)];
    end
    nr_S = length(xpsin_S_dke);
    maskmax = min(find((xpsin_S_dke(1:nr_S-1) + xpsin_S_dke(nr_S))/2 >= psinmax));
    if ~isempty(maskmax), %remove points too close from 1: ensures xpsin_f_dke <= psimax;
        xpsin_S_dke = [xpsin_S_dke(1:maskmax-1), 2*psinmax - xpsin_S_dke(nr_S), xpsin_S_dke(nr_S)];
    end  
    nr_S = length(xpsin_S_dke);
	nr_f = nr_S - 1;
%
	xpsin_f_dke = (xpsin_S_dke(1:nr_S-1) + xpsin_S_dke(2:nr_S))/2;%point l+1/2 (f grid)
	xdpsin_f_dke = diff(xpsin_S_dke);
	xdpsin_S_dke = xpsin_f_dke(2:nr_f) - xpsin_f_dke(1:nr_f-1);
	xpsinm_S_dke = xpsin_S_dke(1:nr_S-1);%point i (flux grid)
	xdpsinm_S_dke = [2*xpsin_f_dke(1),xdpsin_S_dke];
	xpsinp_S_dke = xpsin_S_dke(2:nr_S);%point i+1 (flux grid)
	xdpsinp_S_dke = [xdpsin_S_dke,2*(1 - xpsin_f_dke(nr_f))];
	xdpsinm_S_dke(xdpsinm_S_dke == 0) = eps;
	xdpsinp_S_dke(xdpsinp_S_dke == 0) = eps;
end
%
ir_dke_display_out = find(abs(xpsin_f_dke - psin_display_in) == min(abs(xpsin_f_dke - psin_display_in)));
%
% for DKE calculations, extra radial points are needed close to each
%   position for the purpose of radial derivative
%
if dke_mode == 1%DKE calculations
    if (xpsin_f_dke(1) - dpsin_dke < psinmin) | (xpsin_f_dke(nr_f) + dpsin_dke > psinmax)
        dpsin_dke = psinmin/2;
    end
   % first left dke point
    xpsin_f = [xpsin_f_dke(1) - dpsin_dke,xpsin_f_dke(1)];
    ir_dke = 2;
    r_dke = ir_dke;
    if (nr_f > 1) & (xpsin_f_dke(2) > xpsin_f_dke(1) + dpsin_dke + eps)
        xpsin_f = [xpsin_f,xpsin_f_dke(1) + dpsin_dke];
        ir_dke = ir_dke + 1;
    end
    for ir_f = 2:nr_f
       % left dke point
        if max(xpsin_f) < xpsin_f_dke(ir_f) - dpsin_dke - eps,
            xpsin_f = [xpsin_f,xpsin_f_dke(ir_f) - dpsin_dke];
            ir_dke = ir_dke + 1;
        elseif max(r_dke) < ir_dke %if one and only one fp point between two dke point, it is centered
            xpsin_f(ir_dke) = (xpsin_f_dke(ir_f - 1) + xpsin_f_dke(ir_f))/2;
        end
       % central dke point
        xpsin_f = [xpsin_f,xpsin_f_dke(ir_f)];
        ir_dke = ir_dke + 1;
        r_dke = [r_dke,ir_dke];       
       % right dke point
        if (ir_f < nr_f) & (xpsin_f_dke(ir_f + 1) > xpsin_f_dke(ir_f) + dpsin_dke + eps) 
            xpsin_f = [xpsin_f,xpsin_f_dke(ir_f) + dpsin_dke];
            ir_dke = ir_dke + 1;
        end
    end
   % last right dke point
    xpsin_f = [xpsin_f,xpsin_f_dke(nr_f) + dpsin_dke];
    ir_dke = ir_dke + 1;
else%FP calculations only
    xpsin_f = xpsin_f_dke;
    r_dke = cumsum(ones(1,nr_f)); 
end
%
ir_display_out = r_dke(ir_dke_display_out);
%