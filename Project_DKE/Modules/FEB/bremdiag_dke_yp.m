function [] = bremdiag_dke_yp(tokamak,vschords,xpsin,xdpsin,xpsin_S,method);
%
% This function couples the DKE code with a HXR tomographic system for line-integrated non-thermal bremsstrahlung calculations.
% 
%   INPUTS: 
%
%       - vschord: list of RF rays. {1,nb_rf}. vschord{ib} = ray [nv,ns] is an
%           array of nv variables evaluated at ns propagation steps. It is
%           requires that nv=1 is "s", distance along the ray, nv=2 is "R" 
%           toroidal radius and nv=3 is "Z" vertical position.  
%       - xpsin: distribution radial grid [1,nx]
%       - xdpsin: radial grid steps [1,nx]
%       - xpsin_S: flux radial grid [1,nx_S]
%       - method: interpolation method in psi (default = spline)
%
%   OUTPUTS
%
%       - xythetab: chord poloidal angle evaluated at radial grid positions
%       - xyfinc: chord length at radial grid positions
%       - xytilt: RF rays propagation factor (1 if increasing psin, -1 if
%       decreasing psin, 0 if flux-surface (FS) is not visited by the ray)
%       - yb: list of ray starts in y grid and corresponding ray number. [2,nbb]
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%


%[xyvray,xythetab,xyfinc,xyprop,yb]
%%%%%%%%Appel temporaire fonction bremdiag_dke_yp('TS',vschords,xpsin_dke,xdpsin_dke,xpsin_S_dke);



if nargin < 6
    method = 'spline';%interpolation technique in psi
end
%
[theta,ppsin,psia,ptR,ptZ,ptBR,ptBZ] = equilibrium_jd(tokamak);
%
nt = length(theta);
nb_chord = size(vschords,3);
n_f = length(xdpsin);
%
Rp = ptR(1,1);
Zp = ptZ(1,1);
%
ptr = sqrt((ptR - Rp).^2 + (ptZ - Zp).^2); %minor radius on the (psi,stheta) grid
ptBP = sqrt(ptBR.^2 + ptBZ.^2); %poloidal magntic field on the (psi,stheta) grid
%
chord_param = zeros(2*n_f-1,3,nb_chord);%Chord parameters
%
% Each chord has to be treated separately, because their lengths differ.
%
for i_chord = 20:22;%nb_chord,
    vschord = vschords(:,:,i_chord);%chord characteristics
	 vschord = vschord(:,~isnan(vschord(2,:)));%Remove part of chord that is outside the reference circle
    [nv,ns] = size(vschord);
%
    ss = vschord(1,:);
    sR = vschord(2,:);
    sZ = vschord(3,:);
%
% chord position in (r,theta) coordinates
%
    sR = sR + eps*(sR == Rp);%to avoid singularities
    sZ = sZ + eps*(sZ == Zp);%to avoid singularities
    sr = sqrt((sR - Rp).^2 + (sZ - Zp).^2);%minor radius
    st = atan((sZ - Zp)./(sR - Rp)) + pi - pi*(sR > Rp).*sign(sZ - Zp);%poloidal angle [0,2*pi]
%
% Interpolation for r at chord poloidal locations            
%
    pstr = interp1(theta,ptr',st,method)';%r(psi,st)
%
% Interpolation for psi at chord position (along cst theta lines)
%
%    spsin = interp1(pstr,ppsin,sr,method);%psi(s)
    for is = 1:ns, 
        spsin(is) = interp1(pstr(:,is),ppsin,sr(is),method);%psi(s)
    end
%    
% positions where the chord enters and exits the plasma (at last closed FS)  
%
    is0 = min(find(spsin <= 1));% Position where the chord enters the plasma 
    if isempty(is0)
        info_dke_yp(2,['WARNING: chord #',int2str(i_chord),' don''t enter the plasma and is rejected'])
        continue;
    end
       dbstop 88
    ismax = min([find(spsin > 1 & ss > ss(is0)) - 1,ns]);%Position where the chord leaves the plasma
%
% throw away path outside the last closed FS   
%
    vschord = vschord(:,is0:ismax);
    ss = ss(is0:ismax);ns = length(ss);  
    sR = sR(is0:ismax);
    sZ = sZ(is0:ismax);
    sr = sr(is0:ismax);
    st = st(is0:ismax);
    spsin = spsin(is0:ismax);
% 
    i_chord
    lchord1(i_chord) = sqrt(sR(length(sR))^2+sZ(length(sZ))^2) - sqrt(sR(1)^2+sZ(1)^2);%Total chord length in the plasma
	 lchord2(i_chord) = ss(length(ss)) - ss(1);%Total chord length in the plasma
%    
    is = 1;
%
    ipsin = max(find(xpsin_S < spsin(is)));%initial FS on chord (generally last FS)
    ipsin_f = n_f + 1 - ipsin;%Index for position in the matrix chord_param
%
% distribution of the chord on flux-surfaces
%
    while is < ns, 
        bpsinm = xpsin_S(ipsin);% Lower bound of the current FS
        bpsin = xpsin(ipsin);% Center of the current FS
        bpsinp = xpsin_S(ipsin + 1);% Upper bound of the current FS
%        
% position where chord exits the current FS (or last point on the chord if last visited FS is reached)
%
        islim = min([find((ss > ss(is)) & (spsin < bpsinm | spsin > bpsinp)),ns]);         
        maskfs = is:islim;% Chord within current FS
%
% dealing with extremums of spsin: if chord goes "around" the fs center within one fs 
%    
        dspfs = sign(diff(spsin(maskfs)));% "direction" of the ray in psi
        ndspfs = length(dspfs);
        ipextrfs = find(dspfs(1:ndspfs-1).*dspfs(2:ndspfs) < 0); %extremum positions in spsin(s)
        isextr = 0;
%        while ~isempty(ipextrfs)
%            if dspfs(ipextrfs(1))*(bpsin - spsin(ipextrfs(1) + is)) < 0 %chord goes "around" xpsin
%                islim = is + ipextrfs(1); %split into two contributions
%                maskfs = is:islim;
%                isextr = 1;
%                break
%            else % ray "turns before" xpsin
%                irextrfs(1) = [];
%            end
%        end
%        
% position where the chord reaches the center of the FS   
%
        is_f = min(find(abs(spsin(maskfs) - bpsin) == min(abs(spsin(maskfs) - bpsin)))) + is - 1;
		  chord_param(ipsin_f,1,i_chord) = ss(islim) - ss(is);%path length of chord within the current FS
%		  chord_param(ipsin_f,2,i_chord) = ;%Poloidal angle of chord within the current FS
%		  chord_param(ipsin_f,3,i_chord) = ;%Cosine between the chord direction and the opposite direction (because electron charge is negative) of the local current density within the current FS	  
%
% next FS
%
       if spsin(islim) < bpsin %reaches a more inward FS
          ipsin = ipsin - 1;
			 ipsin_f = n_f + 1 - ipsin;		 
       else %reaches a more outward FS
          ipsin = ipsin + 1;
			 ipsin_f = n_f - 1 + ipsin;
      end
      is = islim;
    end
end
    
dbstop 158  
disp('fin')    

%





