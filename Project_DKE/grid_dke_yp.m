function [pn_f,dpn_f,pnm_S,dpnm_S,pnp_S,dpnp_S,pn_S,...
mhu_f,dmhu_f,mhum_S,dmhum_S,mhup_S,dmhup_S,mhu_S,...
xia,xrho_f,xdrho_f,xrhom_S,xdrhom_S,xrhop_S,xdrhop_S,xrho_S,r_dke,rho_display_out,ir_display_out]...
= grid_dke_yp(method,uniform,dke_mode,Rp_norm,xrho_S,nmhu_S_in,np_S_in,pnmax_S,sfac,snmhu,snp,rho_display_in);
% 
% Generates non uniform radial, pitch angle and momentum grids 
% In the case of a non-uniform grid, the code ensures that a minimum number of points are present 
% in the trapped region and near mhu = 1. Also, generates fine grids near the trapped/passing boundary
% for each radial position. There is a linear increase in the grid steps between two
% consecutives fine grids.
%
%   INPUTS: 
%
%		- xrho_S : flux radial grid
%		- rho_display_in: radial location at which data are displayed (graphic mode)
%		- Rp_norm : = Rp/ap, aspect ratio
%		- dke_mode : (1) resolution of the dke (2) of the FP equation
%		- nmhumin: number of points for uniform grid
%
%   OUTPUTS:
%
%		- mhu_f: pitch-angle grid for the distribution function (half grid) [1,nmhu]
%		- dmhu_f: 
%		- mhum_S:
%		- dmhum_S:
%		- mhup_S:
%		- dmhup_S:
%   	- mhu_S: pitch-angle grid for the distribution function (half grid)
%   	- xrho_dke: radial positions where FP equation to be solved
%  		- r_dke: index of the radial positions for DKE calculations
%		- rho_display_out: radial location at which data are displayed (graphic mode)
%		- ir_display_out: index of the radial location at which data are displayed (graphic mode)
%
% By Y. Peysson and J. Decker 05/02/03 CEA-DRFC 30/01/03 (yves.peysson@cea.fr) 
%New method by J. Decker 
if nargin < 9,
	error('Wrong number of input arguments in grid_dke_yp');
end
%
if uniform == 1,%if uniform grid called, the old method is used for the mhu-grid
	method = 0;
end
%
%Radial grid
%
nr_S = length(xrho_S);
nr_f = nr_S - 1;
%
if nr_S == 1,%Case of local studies, no fast electron transport
	if xrho_S == 0, xrho_S == 0.5;info_dke_yp(2,'WARNING: r/a = 0 not allowed, r/a = 0.05 enforced !');end
	xrho_f = xrho_S;
	xdrho_f = NaN;
	xdrho_S = NaN;
	xrhom_S = NaN;
	xdrhom_S = NaN;
	xrhop_S = NaN;
	xdrhop_S = NaN;
else
	if xrho_S(1) ~= 0,%add extra point for the flux grid if not entered
		xrho_S = [0,xrho_S];
		nr_S = nr_S + 1;
	end
	if xrho_S(nr_S) ~= 1,%add extra point for the flux grid if not entered
		xrho_S = [xrho_S,1];
		nr_S = nr_S + 1;
	end
	nr_f = nr_S - 1;
%
	xrho_f = (xrho_S(1:nr_S-1) + xrho_S(2:nr_S))/2;%point l+1/2 (f grid)
	xdrho_f = diff(xrho_S);
	xdrho_S = xrho_f(2:nr_f) - xrho_f(1:nr_f-1);
	xrhom_S = xrho_S(1:nr_S-1);%point i (flux grid)
	xdrhom_S = [2*xrho_f(1),xdrho_S];
	xrhop_S = xrho_S(2:nr_S);%point i+1 (flux grid)
	xdrhop_S = [xdrho_S,2*(xrho_S(nr_S) - xrho_f(nr_f))];
	xdrhom_S(xdrhom_S == 0) = eps;
	xdrhop_S(xdrhop_S == 0) = eps;
end
%
%Pitch-angle grid
%
sfac0 = sfac(1); % reduction factor for fine grid near mhu = 0
sfac1 = sfac(2); % reduction factor for fine grid near mhu = 1
sfact = sfac(3); % reduction factor for fine grid near mhu = mhut
%
snmhu0 = snmhu(1); % number of fine grid points near mhu = 0
snmhu1 = snmhu(2); % number of fine grid points near mhu = 1
snmhut = snmhu(3); % number of fine grid points near mhu = mhut
%
if method == 0,
    nmhumin = nmhu_S_in;
    dmhu = 2/nmhumin; % grid step for uniform grid
%
    sdmhu0 = dmhu/sfac0; % fine grid step near mhu = 0
    sdmhu1 = dmhu/sfac1; % fine grid step near mhu = 1
    sdmhut = dmhu/sfact; % fine grid step near mhu = mhut
%
% ---------- fine grid near mhu = 0 and  mhu = 1 ----------------
%
    xia = xrho_f/Rp_norm;
    xmhut = sqrt(2*xia./(1+xia));
    xmhut = xmhut(xmhut > 0 & xmhut < 1);
    mhutmin = min([xmhut,1]);
    mhutmax = max([0,xmhut]);
%    
% ------ ensures that there are always enough points near mhu = 0 and  mhu = 1 --------
%    
    if ((1/4 + snmhu0)*sdmhu0) > mhutmin 
	    sdmhu0 = mhutmin/(1/4 + snmhu0);
    else
	    sdmhu0 = sdmhu0;
    end
%
    if ((3/4 + snmhu1)*sdmhu1) > (1 - mhutmax)
	    sdmhu1 = (1 - mhutmax)/(3/4 + snmhu1);
    else
	    sdmhu1 = sdmhu1;
    end
%
    smhu0min = 0;
    smhu0max = snmhu0*sdmhu0;
    smhu0 = [smhu0min:sdmhu0:smhu0max]; % fine grid at the mhu=0 vicinity
%
    smhu1min = 1 - snmhu1*sdmhu1;
    smhu1max = 1;
    smhu1 = [smhu1min:sdmhu1:smhu1max]; % fine grid at the mhu=1 vicinity
%
% --------------- generates half mhu grid ---------------------------
%
    if xrho_f == 0
    	lmhu = trapeze_dke_jd(smhu0max,smhu1min,sdmhut,sfact);
    	mhu = [smhu0,lmhu,smhu1];
    else
    	mhu = smhu0;
    	if dke_mode == 0
    		sdmhut = min([sdmhut,diff(xmhut)/3]);
    	else
    		sdmhut = min([sdmhut,diff(xmhut)/6]);
    	end        
    	N = length(xmhut);
    	i = 1;
    	while ~isempty(xmhut(i:N))
    		if smhu0max > (xmhut(i) - (1/4 + snmhut)*sdmhut)
    			sdmhuti = sdmhu0;
    		elseif smhu1min < (xmhut(i) + (3/4 + snmhut)*sdmhut)
    			sdmhuti = sdmhu1;
    		else
    			sdmhuti = sdmhut;
    		end
%
    		rmhumin = xmhut(i) - (1/4 + snmhut)*sdmhuti;
    		rmhumax =  xmhut(i) + (3/4 + snmhut)*sdmhuti;
%
    		if i > 1 & max(mhu) > rmhumin % when two consecutive fine radial grid overlap
    			d = max(mhu) - rmhumin;
    			while d > 0
    				mhu = mhu(1:length(mhu)-1);
    				rmhumin = rmhumin + sdmhuti;
    				d = max(mhu) - rmhumin;
    			end
    			if (-d) > sdmhuti
    				lmhu = max(mhu) + (-d)/2;
    			else
    				lmhu = [];
    			end
    		else
    			mhu = mhu(mhu <= rmhumin);
            lmhumin = max(mhu);
            lmhumax = rmhumin;       
            lmhu = trapeze_dke_jd(lmhumin,lmhumax,sdmhuti,dmhu);	
         end 
         rmhu = [rmhumin:sdmhuti:rmhumax];
         mhu = [mhu,lmhu,rmhu];
         i = i+1;
      end
%
% fine grid near mhu = 1
%
      smhu1 = smhu1(smhu1 >= max(mhu));
      lmhumin = max(mhu);
      lmhumax = min(smhu1);  
      lmhu = trapeze_dke_jd(lmhumin,lmhumax,sdmhuti/2,dmhu);   
      mhu = [mhu,lmhu,smhu1];
   end
%
   mhum = mhu(2:length(mhu));
   mhu = [mhu(1),mhum(diff(mhu) > eps)];
   mhu_S = [-fliplr(mhu(2:length(mhu))),mhu];
%
%   Case of an uniform mhu grid
%   
   if uniform == 1,
   	mhu_S = [-1:2/(nmhumin+1):1];
   end
%
% calculates the radial positions for dke solutions
%
   if sum(xrho_f == 0) > 0
   	dke_mode = 0
   end
   if dke_mode == 1
   	i_dke = [];
   	i_rho = [];
   	r_dke =[];
   	for i = 1:length(xrho_f),
   		i_mhu = max(find(mhu < xmhut(i)));
   		i_dke = [i_dke, i_mhu];
   		if i > 1 & i_mhu == max(i_rho)
   			r_dke = [r_dke, length(i_rho)];
            i_rho = [i_rho, i_mhu + 1];
         elseif  i > 1 & i_mhu == max(i_rho) + 1
            r_dke = [r_dke, length(i_rho) + 1];
            i_rho = [i_rho, i_mhu, i_mhu + 1];
         else
            r_dke = [r_dke, length(i_rho) + 2];
            i_rho = [i_rho, i_mhu - 1, i_mhu, i_mhu + 1];
         end            
      end
      xrho_dke = 1./(2./(3/4*mhu(i_rho)+1/4*mhu(i_rho+1)).^2 - 1)*Rp_norm;
      xrho_S = NaN*xrho_S;
   else 
   	r_dke = [1:1:length(xrho_f)];
   	xrho_dke = xrho_f;
   end
%
   xrho_f = xrho_dke;%Final grid with extra points for solving the drift kinetic equation
%
   if nr_S > 1,
   	ir_display_out = find(min(abs(xrho_f(r_dke) - rho_display_in)) == abs(xrho_f(r_dke) - rho_display_in));
   	if length(ir_display_out) == 2, ir_display_out = min(ir_display_out); end
   else
   	ir_display_out = 1;
   end
else
%
%New optimized method for reducing the number of pitch-angle points.
%
    nmhumin = nmhu_S_in;
    dmhu = 2/(nmhumin-1); % grid step for uniform grid
    ypower = 1.5;
%
    sdmhu0 = dmhu/sfac0; % fine grid step near mhu = 0
    sdmhu1 = dmhu/sfac1; % fine grid step near mhu = 1
    sdmhut = dmhu/sfact; % fine grid step near mhut
%
    xia = xrho_f/Rp_norm;
    dxia = diff(xia);
%
    xmhut = sqrt(2*xia./(1+xia));
    mhutmin = min([xmhut,1]);
    mhutmax = max([0,xmhut]);
    N = length(xmhut);
%
    if snmhut > 1, 
        nrhot = 1;
    else
        nrhot = round(1/snmhut);%number of radial points per grid point
    end    
%    
% ------ ensures that there are always enough points near mhu = 0 and  mhu = 1 --------
%
    nymax = nmhu_S_in;
    yn = ypower.^(0:nymax-1);
    yyn = repmat(yn',[1,nymax]);
    lyn = sum(triu(yyn));
%
    if N == 1 | snmhut == 0
        dmhutmin = sdmhut;
        dmhutmax = sdmhut;
    else
        dmhutmin = min([(xmhut(2) - xmhut(1))/snmhut,sdmhut,mhutmin/(snmhut + 1/4)]);
        dmhutmax = min([(xmhut(N) - xmhut(N-1))/snmhut,sdmhut,(1-mhutmax)/(snmhut + 3/4)]);
    end
%
% dmhu ramp near mhu=0
%
    smhu0 = [];
    dmhu0 = dmhu;
    snmhu0 = max(snmhu0 - snmhut,0);
    xramp0 = (mhutmin - (snmhut + 1/4)*dmhutmin);
    smhu0 = [0,powerdiff_dke_jd(sdmhu0,sdmhu0,xramp0,dmhutmin,dmhu0,ypower),xramp0 + (1:snmhut)*dmhutmin];
    while length(smhu0) < snmhu0 + snmhut + 1
        dmhu0 = max(sdmhu0,dmhutmin);
        xramp0 = (mhutmin - (snmhut + 1/4)*dmhutmin);
        smhu0 = [0,powerdiff_dke_jd(sdmhu0,sdmhu0,xramp0,dmhutmin,dmhu0,ypower),xramp0 + (1:snmhut)*dmhutmin];
        if length(smhu0) < snmhu0 + snmhut + 1
            if dmhutmin < sdmhu0
                sdmhu0 = max(sdmhu0/ypower, dmhutmin);
            elseif dmhutmin > sdmhu0
                dmhutmin = max(sdmhu0, dmhutmin/ypower);
            else 
                dmhutmin = mhutmin/(1/4 + snmhut  + snmhu0);
                sdmhu0 = dmhutmin;
            end
        end
    end
%
% dmhu ramp near mhu=1
%
    smhu1 = [];
    dmhu1 = dmhu;
    snmhu1 = max(snmhu1 - snmhut,0);
    xramp1 = 1 - (mhutmax + (snmhut + 3/4)*dmhutmax);
    smhu1 = [mhutmax + (3/4 + (0:snmhut))*dmhutmax,powerdiff_dke_jd((mhutmax + (3/4 + snmhut)*dmhutmax),dmhutmax,1 - sdmhu1,sdmhu1,dmhu1,ypower) 1];
    while length(smhu1) < snmhu1 + snmhut + 1
        dmhu1 = max(sdmhu1,dmhutmax);
        xramp1 = 1 - (mhutmax + (snmhut + 3/4)*dmhutmax);
        smhu1 = [mhutmax + (3/4 + (0:snmhut))*dmhutmax,...
        powerdiff_dke_jd((mhutmax + (3/4 + snmhut)*dmhutmax),dmhutmax,1 - sdmhu1,sdmhu1,dmhu1,ypower) 1];
        if length(smhu1) < snmhu1 + snmhut + 1
            if dmhutmax < sdmhu1
                sdmhu1 = max(sdmhu1/ypower, dmhutmax);
            elseif dmhutmax > sdmhu1
                dmhutmax = max(sdmhu1, dmhutmax/ypower);
            else 
                dmhutmax = (1 - mhutmax)/(3/4 + snmhut  + snmhu1);
                sdmhu1 = dmhutmax;
            end
        end
    end
%
% --------------- generates half mhu grid ---------------------------
%
    mhu = smhu0;
    rmhumin = max(mhu);
    drmhumin = mhu(length(mhu)) - mhu(length(mhu)-1);
    for i=1:N-1,
        drmhu = xmhut(i+1)-xmhut(i);
        rdmhut = min(sdmhut,drmhu);
        rmhumax = xmhut(i+1)-rdmhut/4;
        dmhut = dmhu;
        rmhu = powerdiff_dke_jd(rmhumin,drmhumin,rmhumax,rdmhut,dmhut,ypower);
        while length(rmhu) < snmhut + 1,
            dmhut = max(drmhumin,rdmhut);
            rmhumax = xmhut(i+1)-rdmhut/4;
            rmhu = powerdiff_dke_jd(rmhumin,drmhumin,rmhumax,rdmhut,dmhut,ypower);
            if length(rmhu) < snmhut + 1;
                if drmhumin < rdmhut
                    rdmhut = max(rdmhut/ypower, drmhumin);
                elseif drmhumin > rdmhut
                    drmhumin = max(rdmhut, drmhumin/ypower);
                else 
                    rdmhut = ((3*xmhut(i+1) + xmhut(i))/4 - rmhumin)/snmhut;
                    drmhumin = rdmhut;
                end
            end
        end
        mhu = [mhu,rmhu(2:length(rmhu))];
        rmhumin = max(mhu);
        drmhumin = mhu(length(mhu)) - mhu(length(mhu)-1);
    end
    mhu = [mhu,smhu1];
%
    mhu = mhu(find(diff([-1,mhu]) > eps));
    mhu_S = [-fliplr(mhu(2:length(mhu))),mhu];
%
% calculates the radial positions for dke solutions
%
    if dke_mode == 1
%case yet to be implemented
    else 
        r_dke = [1:length(xrho_f)];
        xrho_dke = xrho_f;
    end
    xrho_f = xrho_dke;
    ir_display_out = min(find(min(abs(xrho_f(r_dke) - rho_display_in)) == abs(xrho_f(r_dke) - rho_display_in)));
end
%
rho_display_out = xrho_f(r_dke(ir_display_out));
%
nmhu_S = length(mhu_S);
nmhu_f = nmhu_S - 1;
%
mhum_S = mhu_S(1:nmhu_S-1);%point j (flux grid)
mhup_S = mhu_S(2:nmhu_S);%point j+1 (flux grid)
mhum_S(mhum_S == 0) = eps;%Avoid singularities (NaN)
mhup_S(mhup_S == 0) = eps;%Avoid singularities (NaN)
mhu_f = (mhum_S + mhup_S)/2;%point j+1/2 (f grid)
%
dmhu_f = diff(mhu_S);%point j+1/2 (f grid)
dmhu_S = mhu_f(2:nmhu_f) - mhu_f(1:nmhu_f-1);
dmhum_S = [2*(mhu_f(1)+1),dmhu_S];%point j (flux grid)
dmhup_S = [dmhu_S,2*(1-mhu_f(nmhu_f))];%point j+1 (flux grid)
%
dmhum_S(dmhum_S == 0) = eps;%Avoid singularities (NaN)
dmhup_S(dmhup_S == 0) = eps;%Avoid singularities (NaN)
%
%Momentum grid
%
if uniform == 1,
	pgridfactor = eps;%Uniform grid: pgridfactor << 1
else
	pgridfactor = snp;%Non-uniform grid pgridfactor > 1
end
%
if np_S_in < nmhu_S, 
    np_S = nmhu_S;
else
    np_S = np_S_in;
end
%
pn_S(1) = 0;
dpn_S_ref = pnmax_S/np_S;
dpn_S_0 = dpn_S_ref/20;%Momentum step close to p = 0
dpn_threshold = 0.1;
ip = 1;
while pn_S(ip) < pnmax_S,%Small steps close to p = 0
	dpn_S(ip) = (dpn_S_ref - dpn_S_0)*(1 - exp(-ip/pgridfactor)) + dpn_S_0;
	pn_S(ip+1) = pn_S(ip) + dpn_S(ip);
	ip = ip+1;
end
pn_S = pn_S(1:length(pn_S) - 1);
npn_S = length(pn_S);
%
npn_f = npn_S - 1;
pn_f = (pn_S(1:npn_S-1) + pn_S(2:npn_S))/2;%point i+1/2 (f grid)
dpn_f = diff(pn_S);%point i+1/2 (f grid)
%
dpn_S = pn_f(2:npn_f) - pn_f(1:npn_f-1);
pnm_S = pn_S(1:npn_S-1);%point i (flux grid)
pnm_S(pnm_S == 0) = eps;%Avoid singularities (NaN)
pnp_S = pn_S(2:npn_S);%point i+1 (flux grid)
pnp_S(pnp_S == 0) = eps;%Avoid singularities (NaN)
dpnm_S = [2*pn_f(1),dpn_S];
dpnp_S = [dpn_S,2*(pn_S(npn_S) - pn_f(npn_f))];
%
testdpn_f = find(dpn_f > dpn_threshold);
if isempty(testdpn_f) == 0, info_dke_yp(2,'WARNING: momentum step too large, results may be inaccurate !');end
%




