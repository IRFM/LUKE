function [xyvray,xyfinc,xyprop,yb] = propagation_jd(vsrays,xpsin,xdpsin,xpsin_S,theta,ppsin,ptR,ptBP,psia,method);
%
% This function couples the DKE code with a ray-tracing code. Ray
% caracteristics are evaluated at the DKE radial positions and the incidence
% factors are calculated. Rays that "turn back" are divided into several
% rays. 
% 
%   INPUTS: 
%
%       - vsrays: list of RF rays. {1,nb_rf}. vsrays{ib} = ray [nv,ns] is an
%           array of nv variables evaluated at ns propagation steps. It is
%           requires that nv=1 is "ss", distance along the ray, nv=2 is "spsin" 
%           normalized poloidal flux and nv=3 is "stheta" poloidal angle.  
%       - xpsin: distribution radial grid [1,nx]
%       - xdpsin: radial grid steps [1,nx]
%       - xpsin_S: flux radial grid [1,nx_S]
%       - method: interpolation method in psi (default = spline)
%
%   OUTPUTS
%
%       - xyvray: RF rays characteristics evaluated at radial grid positions
%       - xyfinc: RF rays incidence factor
%       - xyprop: RF rays propagation factor (1 if increasing psin, -1 if
%       decreasing psin, 0 if flux-surface (FS) is not visited by the ray)
%       - yb: list of ray starts in y grid and corresponding ray number. [2,nbb]
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 9
    method = 'spline';%interpolation technique in psi
end
%
nb_rf = length(vsrays);
%
xyvray = []; %ray properties
xyfinc = []; %incidence factor
xyprop = []; %propagation factor (NaN is ray start, +1 is increasing psi, -1 is decreasing psi, 0 is non-applicable)
yb = []; %list of ray starts
%
ibb = 0; %counting global number of ray
%
% Each ray has to be treated separately, because their lengths differ.
%
for ib = 1:nb_rf
    %
    vsray = vsrays{ib};
    ss = vsray(1,:);
    spsin = vsray(2,:);
    ns = length(ss);
    %    
    % positions where the ray enters and exits the plasma (at last closed FS)  
    %
    is0 = min(find(spsin <= 1)); %position where the ray enters the plasma 
    if isempty(is0)
        disp('Warning: one ray did not enter the plasma and was rejected')
        continue
    else
        ibb = ibb + 1;%starting a new ray in xy matrices
    end
    ismax = min([find(spsin > 1 & ss > ss(is0)) - 1,ns]); %position where the ray leaves the plasma (if applicable)
    %
    % throw away path outside the last closed FS   
    %
    vsray = vsray(:,is0:ismax);
    ss = ss(is0:ismax);
    spsin = spsin(is0:ismax);
%    
    ns = length(ss);   
%    
    is = 1;
%
    ipsin = max(find(xpsin_S < spsin(is)));%initial FS on ray trajectory (generally last FS, but not necessarily (ex: EBW))
    yb = [yb,[ibb;ib]];
    bdir = 0;
%
% distribution of the ray on flux-surfaces
%
    while is < ns 
        bpsinm = xpsin_S(ipsin); % lower bound of the current FS
        bpsin = xpsin(ipsin); % center of the current FS
        bpsinp = xpsin_S(ipsin + 1); % upper bound of the current FS
%        
% position where ray exits the current FS (or last point on the ray path if last visited FS is reached)
%
        islim = min([find((ss > ss(is)) & (spsin < bpsinm | spsin > bpsinp)),ns]); 
%        
        maskfs = is:islim; %ray trajectory within current FS
%
% dealing with extremums of spsin: if ray goes "around" the fs center within one fs, it is split at the extremum. 
%    
        dspfs = sign(diff(spsin(maskfs)));% "direction" of the ray in psi
        ndspfs = length(dspfs);
        ipextrfs = find(dspfs(1:ndspfs-1).*dspfs(2:ndspfs) < 0); %extremum positions in spsin(s)
        isextr = 0;
        while ~isempty(ipextrfs)
            if dspfs(ipextrfs(1))*(bpsin - spsin(ipextrfs(1) + is)) < 0 %ray goes "around" xpsin
                islim = is + ipextrfs(1); %split into two contributions
                maskfs = is:islim;
                isextr = 1;
                break
            else % ray "turns before" xpsin
                ipextrfs(1) = [];
            end
        end
%        
% propagation factor        
%        
        bdir_new = sign(spsin(islim) - spsin(is));
        if bdir_new*bdir == -1 %change of direction in psi leads to splitting of ray
            ibb = ibb + 1;
        end
        xyprop(ipsin,ibb) = bdir_new;
%        
% position where the ray reaches the center of the FS   
%
        is_f = min(find(abs(spsin(maskfs) - bpsin) == min(abs(spsin(maskfs) - bpsin)))) + is - 1;
%
        xyvray(ipsin,ibb,:) = reshape(vsray(:,is_f),[1,1,12]); %parameters vrays at center of FS
%
        bds = ss(islim) - ss(is);%path length of ray within the current FS
%
% local width of the FS: |dl| = |dpsi|/|grad psi| = |dpsin.psia|/|R.BP|
%
        thetab_f = vsray(3,is_f);
        Rb_f = interp2(theta,ppsin,ptR,thetab_f,bpsin,method);
        BPb_f = interp2(theta,ppsin,ptBP,thetab_f,bpsin,method);
%
        bdl = abs(xdpsin(ipsin)*psia./Rb_f./BPb_f); %width of the FS at theta = thetab
        xyfinc(ipsin,ibb) = bds/bdl; %incidence factor
%
% next FS
%
        if isextr == 0 % ray is not split at an extremum in psi: it either reaches another FS or stops
            if spsin(islim) < bpsin %reaches a more inward FS
                ipsin = ipsin - 1;
            else %reaches a more outward FS
                ipsin = ipsin + 1;
            end
        end
        is = islim;
        bdir = bdir_new;
    end
end
%
