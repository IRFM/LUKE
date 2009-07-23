function [momentumDKE] = momentumgrid_dke_jd(dkeparam,equilDKE,radialDKE);
% 
% Generates non uniform pitch angle and momentum grids 
% In the case of a non-uniform grid, the code ensures that a minimum number of points are present 
% in the trapped region and near mhu = 1. Also, generates fine grids near the trapped/passing boundary
% for each radial position. 
%
%   INPUTS: 
%
% 	- uniform: (0) Non-uniform grid, (1) uniform grid
%       - grid_power: Power for step variation. (grid_power > 1) NOTE: grid_power = 0 for old method with linear step variation 
%	- dke_mode: Resolution of the (1) DKE equation ,(0) FP equation
%	- r_dke: Indices of points for DKE calculation 
%	- xmhu0T2: Trapped/passing boundaries in mhu space for all radial positions
%	- nmhu_S_in: Number of angular values for the flux grid
%	- np_S_in: Number of momentum values for the flux grid
%	- pnmax_S: Maximum value of the flux momentum grid
%	- sfac: reduction factors
%	- snmhu: numbers of fine grid points in mhu
%	- snp: reduction factor for the fine grid points in p
%	- np_S_ref: position in the mpomentum grid where dpn_S is twice the minimum value
%
%   OUTPUTS:
%
%       - pn_f: momentum half-grid (distribution function)
%       - dpn_f: 
%       - pnm_S: 
%       - dpnm_S: 
%       - pnp_S: 
%       - dpnp_S: 
%       - pn_S: momentum full grid (flux)
%	- mhu_f: pitch-angle half-grid (distribution function)
%       - dmhu_f: 
%       - mhum_S: 
%       - dmhum_S: 
%       - mhup_S: 
%       - dmhup_S: 
%	- mhu_S: pitch-angle full-grid (flux)
%
%  by Joan Decker <jodecker@mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
if nargin < 3,
	error('Wrong number of input arguments in momentumgrid_dke_jd');
end
%
dke_mode = dkeparam.dke_mode;
bounce_mode = dkeparam.bounce_mode;
uniform = dkeparam.grid_uniformity;
grid_power = dkeparam.grid_power;
grid_method = dkeparam.grid_method;
nmhu_S_in = dkeparam.nmhu_S;
np_S_in = dkeparam.np_S;
pnmax_S = dkeparam.pnmax_S;
snp = dkeparam.snp; 
np_S_ref = dkeparam.np_S_ref;
sfac0 = dkeparam.sfac0;% reduction factor for fine grid near mhu = 0
sfac1 = dkeparam.sfac1; % reduction factor for fine grid near mhu = 1
sfact = dkeparam.sfact; % reduction factor for fine grid near mhu = mhut
snmhu0 = dkeparam.snmhu0;% number of fine grid points near mhu = 0
snmhu1 = dkeparam.snmhu1;% number of fine grid points near mhu = 1
snmhut = dkeparam.snmhut;% number of fine grid points near mhu = mhut
%
r_dke = radialDKE.r_dke;
xmhu0T2 =  equilDKE.xmhu0T2;
%
%Pitch-angle grid
%
if abs(uniform) ~= 1,%Non-uniform grid
    if grid_power == 0,
        nmhumin = nmhu_S_in;
        dmhu = 2/nmhumin; % grid step for uniform grid
    %
        sdmhu0 = dmhu/sfac0; % fine grid step near mhu = 0
        sdmhu1 = dmhu/sfac1; % fine grid step near mhu = 1
        sdmhut = dmhu/sfact; % fine grid step near mhu = mhut
    %
    % ---------- fine grid near mhu = 0 and  mhu = 1 ----------------
    %
        xmhut = sqrt(xmhu0T2);
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
    %
        sdmhu0 = dmhu/sfac0; % fine grid step near mhu = 0
        sdmhu1 = dmhu/sfac1; % fine grid step near mhu = 1
        sdmhut = dmhu/sfact; % fine grid step near mhut
    %
        xmhut = sqrt(xmhu0T2);
        N = length(xmhut);
    %
        if bounce_mode > 0,
            mhu = makegrid_dke_jd(0,snmhu0,sdmhu0,xmhut(1),snmhut,sdmhut,snmhu0,dmhu,grid_power);
            for ix=1:N-1,
                %sdmhutmin = diff(mhu(length(mhu) - 1:length(mhu)));
                %snmhut_new = max([snmhut - fix(log(sdmhut/sdmhutmin)/log(grid_power)),1]);
                mhu = [mhu,makegrid_dke_jd(xmhut(ix),snmhut,sdmhut,xmhut(ix+1),snmhut,sdmhut,1,dmhu,grid_power)];
            end
            %sdmhutmin = diff(mhu(length(mhu) - 1:length(mhu)));
            mhu = [mhu,makegrid_dke_jd(xmhut(N),snmhut,sdmhut,1,snmhu1,sdmhu1,snmhu1,dmhu,grid_power)];
        else
            mhu = makegrid_dke_jd(0,snmhu0,sdmhu0,1,snmhu1,sdmhu1,snmhu0+snmhu1,dmhu,grid_power);
        end
    %
        mhu = sort(mhu(find(diff([-1,mhu]) > 10*eps)));%Sorting for RFP since the trapped domain is not monotonic with the minor radius
        mhu_S = [-fliplr(mhu(2:length(mhu))),mhu];
    %
    end
    %
else,%for test only with uniform grid
    mhu_S_pos = linspace(0,1,floor((nmhu_S_in + 1)/2));
    mhu_S = [-fliplr(mhu_S_pos(2:length(mhu_S_pos))),mhu_S_pos];
%   nmhu_S = length(mhu_S);
%	mhu_f = (mhu_S(1:nmhu_S-1) + mhu_S(2:nmhu_S))/2;
%   nmhu_f = length(mhu_f);
%	dmhu_f = diff(mhu_S);
%	dmhu_S = [2*(mhu_f(1)+1),diff(mhu_f),2*(1-mhu_f(nmhu_f))];
%	mhum_S = mhu_S(1:nmhu_f);
%	mhup_S = mhu_S(2:nmhu_f+1);
%	dmhum_S = dmhu_S(1:nmhu_f);
%	dmhup_S = dmhu_S(2:nmhu_f+1);
end
%
nmhu_S = length(mhu_S);
nmhu_f = nmhu_S - 1;
%
% added to avoid imaginary numbers later
%
mhu_S(1) = -1;
mhu_S(nmhu_S) = 1;
%
mhum_S = mhu_S(1:nmhu_S-1);%point j (flux grid)
mhup_S = mhu_S(2:nmhu_S);%point j+1 (flux grid)
onemmhu2m_S = 1.0 - mhum_S.*mhum_S;
onemmhu2p_S = 1.0 - mhup_S.*mhup_S;
mhum_S(mhum_S == 0) = eps;%Avoid singularities (NaN)
mhup_S(mhup_S == 0) = eps;%Avoid singularities (NaN)
onemmhu2m_S(onemmhu2m_S == 0) = eps;%Avoid singularities (NaN)
onemmhu2p_S(onemmhu2p_S == 0) = eps;%Avoid singularities (NaN)
%
mhu_f = (mhum_S + mhup_S)/2;%point j+1/2 (f grid)
onemmhu2_f = 1.0 - mhu_f.*mhu_f;
mhumm_f = [mhu_f(1),mhu_f(1:end-1)];
mhupp_f = [mhu_f(2:end),mhu_f(end)]
dmhu_f = diff(mhu_S);%point j+1/2 (f grid)
dmhumm_f = [dmhu_f(1),dmhu_f(1:end-1)];
dmhupp_f = [dmhu_f(2:end),dmhu_f(end)];
%
dmhu_S = mhu_f(2:nmhu_f) - mhu_f(1:nmhu_f-1);
dmhum_S = [2*(mhu_f(1)+1),dmhu_S];%point j (flux grid)
dmhup_S = [dmhu_S,2*(1-mhu_f(nmhu_f))];%point j+1 (flux grid)
dmhum_S(dmhum_S == 0) = eps;%Avoid singularities (NaN)
dmhup_S(dmhup_S == 0) = eps;%Avoid singularities (NaN)
%
%Momentum grid
%
if uniform == 1,
	pgridfactor = 1;%Uniform grid: pgridfactor = 1
	np_S_ref = 20;
else
	pgridfactor = snp;%Non-uniform grid pgridfactor > 1
end
%
%if np_S_in < nmhu_S, 
%    np_S = nmhu_S;
%else
    np_S = np_S_in;
%end
%
pn_S(1) = 0;
dpn_S_ref = pnmax_S/(np_S - 1);
dpn_S_0 = dpn_S_ref/pgridfactor;%Momentum step close to p = 0
dpn_threshold = 0.1;
ip = 1;
while pn_S(ip) <= pnmax_S + dpn_S_ref*1e-3,%Small steps close to p = 0
%   dpn_S(ip) = (dpn_S_ref-dpn_S_0)*tanh((np_S - ip - np_S_ref)/25)/2 + (dpn_S_ref+dpn_S_0)/2;
	dpn_S(ip) = (dpn_S_ref-dpn_S_0)*tanh((ip-np_S_ref))/2 + (dpn_S_ref+dpn_S_0)/2;
	pn_S(ip+1) = pn_S(ip) + dpn_S(ip);
	ip = ip+1;
end
pn_S = pn_S(1:length(pn_S) - 1);
npn_S = length(pn_S);
%
npn_f = npn_S - 1;
pn_f = (pn_S(1:npn_S-1) + pn_S(2:npn_S))/2;%point i+1/2 (f grid)
dpn_f = diff(pn_S);%point i+1/2 (f grid)
pnmm_f = [eps,pn_f(1:npn_f-1)];
dpnmm_f  = [dpn_f(1),dpn_f(1:npn_f-1)];
pnpp_f = [pn_f(2:npn_f),pn_f(npn_f)];
dpnpp_f  = [dpn_f(2:npn_f),dpn_f(npn_f)];
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
%if isempty(testdpn_f) == 0, info_dke_yp(2,'WARNING: momentum step too large, results may be inaccurate !');end
%
momentumDKE.pn = pn_f;
momentumDKE.pn2 = pn_f.*pn_f;
momentumDKE.pn3 = pn_f.*pn_f.*pn_f;
momentumDKE.dpn = dpn_f;
%
momentumDKE.pnm = pnm_S;
momentumDKE.pn2m = pnm_S.*pnm_S;
momentumDKE.pn3m = pnm_S.*pnm_S.*pnm_S;
momentumDKE.dpnm = dpnm_S;
%
momentumDKE.pnp = pnp_S;
momentumDKE.pn2p = pnp_S.*pnp_S;
momentumDKE.pn3p = pnp_S.*pnp_S.*pnp_S;
momentumDKE.dpnp = dpnp_S;
%
momentumDKE.pnmm = pnmm_f;
momentumDKE.pn2mm = pnmm_f.*pnmm_f;
momentumDKE.pn3mm = pnmm_f.*pnmm_f.*pnmm_f;
momentumDKE.dpnmm = dpnmm_f;
%
momentumDKE.pnpp = pnpp_f;
momentumDKE.pn2pp = pnpp_f.*pnpp_f;
momentumDKE.pn3pp = pnpp_f.*pnpp_f.*pnpp_f;
momentumDKE.dpnpp = dpnpp_f;
%
momentumDKE.pn_S = pn_S;
%
momentumDKE.mhu = mhu_f;
momentumDKE.mhu2 = mhu_f.*mhu_f;
momentumDKE.onemmhu2 = onemmhu2_f;
momentumDKE.dmhu = dmhu_f;
%
momentumDKE.mhum = mhum_S;
momentumDKE.mhu2m = mhum_S.*mhum_S;
momentumDKE.onemmhu2m = onemmhu2m_S;
momentumDKE.dmhum = dmhum_S;
%
momentumDKE.mhumm = mhumm_f;
momentumDKE.dmhumm = dmhumm_f;
%
momentumDKE.mhup = mhup_S;
momentumDKE.mhu2p = mhup_S.*mhup_S;
momentumDKE.onemmhu2p = onemmhu2p_S;
momentumDKE.dmhup = dmhup_S;
%
momentumDKE.mhupp = mhupp_f;
momentumDKE.dmhupp = dmhupp_f;
%
momentumDKE.mhu_S = mhu_S;
%



