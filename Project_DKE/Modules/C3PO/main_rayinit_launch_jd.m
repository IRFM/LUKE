function rayinit = main_rayinit_launch_jd(equil,launch)
%
% This function creates the rayinit structure based on ray launching parameters. Straight ray
% propagation is assumed up to the last closed flux-surface for the EC wave
%
% INPUTS:
%   Launch structure fields:
%
%       - type = Type of wave (LH or EC;
%       - omega_rf = [4.6]*2*pi*1e9;%wave angular frequency (rad/s)
%
%   Specific to LH wave
%
%       - bPlhtot_2piRp: initial lineic power density in the ray (W/m) [1,n_lobe]
%       - bNpar0: Initial Npar value [1,n_lobe]
%       - bdNpar0: Initial dNpar value [1,n_lobe]
%       - ry0: vertical launching positions [m_pol,1]
%
%       - m0: initial poloidal mode number
%       - kz0: initial axial wabe vector
%       - z0: initial axial position
%       - i_ref: Initial radial position index
%       - LFS: (-1) high field side launching, (1) low field side launching
%
%   Specific to EC wave
%
%       - yx_L : major radius position of launching (m)
%       - yy_L : vertical position of launching (m)
%       - yz_L : axial position of launching (m), (R,Z,phi) or (x,y,z) right handed
%       - yalpha_L : horizontal angle with respect to R (rad)
%       - ybeta_L : vertical angle with respect to Z (rad) 
%       - yP_L_2piRp : lineic power density launched in the ray (W/m)
%       - dNpar0 :  initial power spectrum width. May be NaN
%       - ns : (1000)
%       - method: ('cubic')
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and Y. Peysson (IRFM/DSM/CEA) <yves.peysson@cea.fr>
%
if nargin < 2,
    error('Not enough input arguments in main_rayinit_launch_jd');
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
if ~isfield(launch,'m0'),
    launch.m0 = NaN;
end
%
if ~isfield(launch,'n0'),
	launch.n0 = NaN;
end
%
if ~isfield(launch,'kz0'),
    launch.kz0 = NaN;
end
%
if strcmp(launch.type,'EC') && ~isfield(launch,'dNpar0'),
    launch.dNpar0 = NaN;
end
if ~isfield(launch,'ns'),
    launch.ns = 1000;
end
if ~isfield(launch,'method'),
    launch.method = 'cubic';
end
%
if strcmp(launch.type,'EC'),
    %
    dNpar0 = launch.dNpar0;
    ns = launch.ns;
    method = launch.method;
    %
    if isfield(launch,'yP_L') && ~isinf(equil.Rp),
        yP0_2piRp = launch.yP_L/(2*pi*equil.Rp);%initial power in the ray (W) [1,n_lobe]
    elseif isfield(launch,'yP_L_2piRp')
        yP0_2piRp = launch.yP_L_2piRp;
    else
        error('ERROR in main_rayinit_launch_jd.m -> inconsistent launch input: use yP_L if Rp is finite only, or yP_L_2piRp otherwise.');
    end
    %
    ny = length(yP0_2piRp);
    %
    ptr = sqrt(equil.ptx.^2 + equil.pty.^2);
    smax = 2*max(max(ptr));
    s = linspace(0,smax,ns);
    %
    % Straight ray propagation to reach first closed flux surface
    %
    if isfield(launch,'yR_L') && ~isinf(equil.Rp),
        yx_L = launch.yR_L - equil.Rp;
    elseif isfield(launch,'yx_L')
        yx_L = launch.yx_L;
    else
        error('ERROR in main_rayinit_launch_jd.m -> inconsistent launch input: use yR_L if Rp is finite only, or yx_L otherwise.');
    end
    %    
    if isfield(launch,'yZ_L')
        yy_L = launch.yZ_L - equil.Zp;
    elseif isfield(launch,'yy_L')
        yy_L = launch.yy_L;
    end
    %    
    if isfield(launch,'yphi_L') && ~isinf(equil.Rp),
        yz_L = launch.yphi_L*equil.Rp;
    elseif isfield(launch,'yz_L')
        yz_L = launch.yz_L;
    else
        error('ERROR in main_rayinit_launch_jd.m -> inconsistent launch input: use yphi_L if Rp is finite only, or yz_L otherwise.');
    end
    %
    [sysh,sysy,syx,syy,syz,syalpha,sybeta,sygx,sygy,sygz] = raypath_prop_jd(equil.Rp,yx_L,yy_L,-yz_L,launch.yalpha_L,launch.ybeta_L,s);    
    %
    % The definition of z in raypath_prop_jd is opposite from the definition in DKE
    %
    syz = - syz;
    sygz = - sygz;
    %
    syr = sqrt(syx.^2 + syy.^2);
    syx(syx == 0) = eps;
    sytheta = atan(syy./syx) + pi*(syx < 0) + 2*pi*(syx > 0 & syy < 0);
    %
    % In vacuum N = g; 
    %
    syNx = sygx;
    syNy = sygy;
    syNz = sygz;
    %
    psi_apRp = equil.psi_apRp;
    psin = psi_apRp/psi_apRp(end);
    %
    rayinit.omega_rf = launch.omega_rf;
    %
    for iy = 1:ny,    
        %
        if ~isnan(yx_L(iy)),
            %
            %
            % interpolation for r at ray poloidal locations    
            %
            pstr = interp1(equil.theta,ptr.',sytheta(:,iy),method).';%r(psi,st)
            %
            % interpolation for psi at ray position (along cst theta lines)
            %
            %spsin = interp1(pstr,ppsin,sr,method);%psi(s)
            %
            spsin = zeros(1,ns);
            %
            for is = 1:ns 
                spsin(is) = interp1(pstr(:,is),psin,syr(is,iy),method,NaN);%psi(s)
            end
            %
            is0 = find(~isnan(spsin),1,'first');
            %
            psin0 = spsin(is0);
            %
            s0 = sqrt(sysh(is0,iy).^2 + sysy(is0,iy).^2);%distance along the ray from mirror to LCFS   
            %
            x0 = syx(is0,iy);
            y0 = syy(is0,iy);
            r0 = syr(is0,iy);
            theta0 = sytheta(is0,iy);
            z0 = syz(is0,iy);
            Nx0 = syNx(is0,iy);
            Ny0 = syNy(is0,iy);
            Nz0 = syNz(is0,iy);
            %
            rho0 = psi2rho_jd(equil,psin0);
            %
        else
            %
            s0 = 0;%distance along the ray from mirror to LCFS   
            %
            rho0 = 1;
            psin0 = 1;
            %
            tx = equil.ptx(end,:);
            ty = equil.pty(end,:);
            %
            mask = [find(ty(1:end - 1) < 0 & diff(ty) > 0),1 + [0,find(ty(1:end - 1) >= 0 & diff(ty) > 0)]]; 
            %
            y0 = yy_L(iy);
            x0 = interp1(ty(mask),tx(mask),y0,method,NaN);
            %
            if isnan(y0),
                error('The vertical launching position in beyond the LCFS');
            end
            %
            r0 = sqrt(x0.^2 + y0.^2);
            theta0 = atan(y0./x0) + pi*(x0 < 0) + 2*pi*(x0 > 0 & y0 < 0);
            z0 = - yz_L(iy);
            %
            Nx0 = sin(launch.ybeta_L(iy)).*cos(launch.yalpha_L(iy));
            Ny0 = cos(launch.ybeta_L(iy));
            Nz0 = sin(launch.ybeta_L(iy)).*sin(launch.yalpha_L(iy));
            %
        end
        %
        if ~isempty(psin0),
            %
            Bx0 = interp2(psin,equil.theta,equil.ptBx.',psin0,theta0,method);
            By0 = interp2(psin,equil.theta,equil.ptBy.',psin0,theta0,method);
            Bz0 = interp2(psin,equil.theta,equil.ptBPHI.',psin0,theta0,method);    
            %
            B0 = sqrt(Bx0.^2 + By0.^2 + Bz0.^2);
            Npar0 = (Nx0*Bx0 + Ny0*By0 + Nz0*Bz0)/B0;
            %
            Bp0 = sqrt(Bx0.^2 + By0.^2);
            cosalpha0 = (By0*x0 - Bx0*y0)/r0/Bp0;
            Ns0 = (Nx0*Bx0 + Ny0*By0)/Bp0;
            m0 = r0*Ns0*rayinit.omega_rf/clum/cosalpha0;
            %
            rayinit.yrho0(iy) = rho0;%Initial radial position at launch
            rayinit.ytheta0(iy) = theta0;%Initial poloidal position at launch
            rayinit.yz0(iy) = z0;%Initial axial position at launch
            rayinit.ym0(iy) = m0;%Initial poloidal mode number
            rayinit.ykz0(iy) = launch.kz0;%Initial toroidal mode number
            rayinit.yNpar0(iy) = Npar0;%Initial index of refraction
            rayinit.ydNpar0(iy) = dNpar0;%initial Ray spectral width
            rayinit.yP0_2piRp(iy) = yP0_2piRp(iy);%Lineic initial power density initial power in the ray (W/m)
            %
            rayinit.yib(iy) = iy;% beam index for tracking (fluctuations)
            %
            if ny == 1 && isfield(launch,'w0'),%beam waist  
                rayinit.w0 = launch.w0;
                if isfield(launch,'z_L'),%for divergence calculation
                    rayinit.z0 = launch.z_L - s0;%distance from LCFS to waist
                else
                    rayinit.z0 = 0;
                end
            else% the Gaussian beam representation is compatible with the one ray description only
                rayinit.w0 = NaN;
                rayinit.z0 = NaN;
            end
            %
            if isfield(launch,'epol_XYZ') && isfield(launch,'N_XYZ');
                %
                [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz] = colddisp_dke_jd(Npar0,launch.omega_rf,NaN,0,1,1,B0);
                %
                if isinf(equil.Rp),
                    BX0 = Bx0;
                    BY0 = -Bz0;
                else
                    BX0 = Bx0*cos(z0/equil.Rp) - Bz0*sin(z0/equil.Rp);
                    BY0 = -Bx0*sin(z0/equil.Rp) - Bz0*cos(z0/equil.Rp);
                end
                BZ0 = By0;
                %
                B0_XYZ = [BX0;BY0;BZ0];
                %
                z_XYZ = B0_XYZ/B0;
                y_XYZ = cross(B0_XYZ,launch.N_XYZ)/norm(cross(B0_XYZ,launch.N_XYZ));
                x_XYZ = cross(y_XYZ,z_XYZ);
                %
                M_xyzXYZ = [x_XYZ,y_XYZ,z_XYZ];
                ep_XYZ = M_xyzXYZ*ep_xyz;
                em_XYZ = M_xyzXYZ*em_xyz;
                %
                rayinit.ap2 = abs(launch.epol_XYZ'*ep_XYZ).^2;
                rayinit.am2 = abs(launch.epol_XYZ'*em_XYZ).^2;
            end
            %
        else
            rayinit.yrho0(iy) = NaN;%Initial radial position at launch
            rayinit.ytheta0(iy) = NaN;%Initial poloidal position at launch
            rayinit.yz0(iy) = NaN;%Initial axial position at launch
            rayinit.ym0(iy) = NaN;%Initial poloidal mode number
            rayinit.ykz0(iy) = NaN;%Initial toroidal mode number
            rayinit.yNpar0(iy) = NaN;%Initial index of refraction
            rayinit.ydNpar0(iy) = NaN;%initial Ray spectral width
            rayinit.yP0_2piRp(iy) = NaN;%Lineic initial power density initial power in the ray (W/m)
            rayinit.w0 = NaN;
            rayinit.z0 = NaN;
            rayinit.ap2 = NaN;
            rayinit.am2 = NaN;
        end
    end
    %
elseif strcmp(launch.type,'LH'),
    if isfield(launch,'bPlhtot') && ~isinf(equil.Rp),
        bP0_2piRp = launch.bPlhtot/(2*pi*equil.Rp);%initial power in the ray (W) [1,n_lobe]
    elseif isfield(launch,'bPlhtot_2piRp')
        bP0_2piRp = launch.bPlhtot_2piRp;
    else
        error('ERROR in main_rayinit_launch_jd.m -> inconsistent launch input: use bPlhtot if Rp is finite only, or bPlhtot_2piRp otherwise.');
    end
    %
    bNpar0 = launch.bNpar0;%Initial Npar value [1,n_lobe]
    bdNpar0 = launch.bdNpar0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    ry0 = launch.rZ0 - equil.Zp;
    rby0 = ry0(:)*ones(1,length(bP0_2piRp));%[m_pol,n_lobe]
    %
    % Ray initial characteristics
    %
    if ~isfield(launch,'i_ref') || isempty(launch.i_ref),
        launch.i_ref = -1;%Initial radial position index, relative to LCFS [1,1]
    end
    %
    if launch.i_ref < 0,
        launch.i_ref = length(equil.psi_apRp) + launch.i_ref;%Initial radial position index [1,1]
    end
    %
    tmask = diff(equil.pty(launch.i_ref,:))*launch.LFS > 0;
    %
    rbx0 = interp1(equil.pty(launch.i_ref,tmask),equil.ptx(launch.i_ref,tmask),rby0,'spline');
    rbx0(rbx0 == 0) = eps;
    rbtheta0 = atan(rby0./rbx0) + pi*(rbx0 < 0) + 2*pi*(rbx0 > 0 & rby0 < 0);
    %
    rho0 = psi2rho_jd(equil,equil.psi_apRp(launch.i_ref)/equil.psi_apRp(end),'spline');%Initial radial position at launch%
    %
    rayinit.omega_rf = launch.omega_rf;%wave frequency 
    %
    nb = size(rby0,2);% number of beams
    nr = size(rby0,1);% number of poloidal locations
    nm = length(launch.m0);% number of poloidal numbers
    %
    if all(imag(launch.m0) == 0),
        launch.m0 = launch.m0 + 1i/nm;%uniform power distribution
    end
    %
    % tail model
    %
    if ~isfield(launch,'tail'),% no tail model
        tail.mode = 0;
    else
        tail = launch.tail;
    end
    %
    for ib = 1:nb,% sum over lobes
        if imag(bNpar0(ib)) ~= 0,% case where Nz is prescribed instead of Npar - tail model only applies to Nz
            %
            bNy(ib) = real(bNpar0(ib));
            bNpar0(ib) = imag(bNpar0(ib));% nz
            %
        else
            bNy(ib) = NaN;
        end
    end
    %
    if tail.mode == 1,% Gaussian tail fluctuations
        %
        bfwhm = tail.bfwhm; 
        %
        if length(fwhm_npar0) == 1,% if tail bfwhm is the same for all lobes
            bfwhm = repmat(bfwhm,[1,nb]);
        end
        %
    elseif tail.mode == 2,% Linear tail fluctuations
        %
        bNparmax_tail = tail.bNparmax_tail;
        bopt_tail = real(tail.bopt_tail);
        %
        if length(bNparmax_tail) == 1,% if tail bNparmax is the same for all lobes
            bNparmax_tail = repmat(bNparmax_tail,[1,nb]);
        end
        %
        if length(bopt_tail) == 1,
            bopt_tail = repmat(bopt_tail,[1,nb]);
        end
        %
        bNparmax_tail(bNparmax_tail == 0) = 6.5/sqrt(equil.pTe(1));
        %
    elseif tail.mode == 3,% calc_tail_jd fluctuation or static model
        %
        bNparmax_tail = tail.bNparmax_tail;
        bn_tail = tail.bn_tail;
        bP_tail = tail.bP_tail;
        bopt_tail = tail.bopt_tail;
        %
        if length(bNparmax_tail) == 1,% if tail bNparmax is the same for all lobes
            bNparmax_tail = repmat(bNparmax_tail,[1,nb]);
        end
        %
        bNparmax_tail(bNparmax_tail == 0) = 6.5/sqrt(equil.pTe(1));
        %
        if length(bn_tail) == 1,
            bn_tail = repmat(bn_tail,[1,nb]);
        end
        %
        if length(bP_tail) == 1,
            bP_tail = repmat(bP_tail,[1,nb]);
        end
        %
        if length(bopt_tail) == 1,
            bopt_tail = repmat(bopt_tail,[1,nb]);
        end
        %
        for ib = 1:nb,% sum over lobes
            %
            [btNpar0_tail{ib},btdNpar0_tail{ib},btP0_2piRp_tail{ib}] = calc_tail_jd(bNpar0(ib),bdNpar0(ib),bP0_2piRp(ib),bNparmax_tail(ib),bn_tail(ib),bP_tail(ib),bopt_tail(ib));
            %
        end
        %
    end
    %
    iy = 0;
    %
    for ib = 1:nb,% sum over initial lobes
        for ir = 1:nr,% sum over vertical positions
            if tail.mode == 1,% Gaussian tail fluctuations
                %
                if ~isinf(tail.dtn),% fluctuating spectrum model
                    if bfwhm(ib) > 0,
                        tNpar0_tail = randg_yp(1,bNpar0(ib),bfwhm(ib));%New random npar0 around npar_antenna
                    else
                        tNpar0_tail = randg_yp(1,bNpar0(ib),bdNpar0(ib));%New random npar0 around npar_antenna
                    end   
                    %
                    tdNpar0_tail = bdNpar0(ib);
                    tP0_2piRp_tail = bP0_2piRp(ib);
                    %
                    disp(['Gaussian distribution -> npar_antenna: ',num2str(bNpar0(ib)),', new npar0: ',num2str(tNpar0_tail),' with Gaussian distribution FWHM = ',num2str(bfwhm(ib))]);
                else
                    error('static model for gaussian probability distribution not yet implemented.')%% TODO
                end
                %
            elseif tail.mode == 2,% Linear tail fluctuations
                %
                if ~isinf(tail.dtn),% fluctuating spectrum model
                    if sign(bNpar0(ib)) > 0 && bNpar0(ib) < bNparmax_tail(ib),
                        tNpar0_tail = randlin_yp(1,bopt_tail(ib),[bNpar0(ib),bNparmax_tail(ib)]);%New random npar0
                    elseif sign(bNpar0(ib)) < 0 && bNpar0(ib) > - bNparmax_tail(ib),
                        tNpar0_tail = randlin_yp(1,bopt_tail(ib),[-bNparmax_tail(ib),bNpar0(ib)]);%New random npar0
                    end  
                    %
                    tdNpar0_tail = bdNpar0(ib);
                    tP0_2piRp_tail = bP0_2piRp(ib);
                    %
                    disp(['Linear distribution -> npar_antenna: ',num2str(bNpar0(ib)),', new npar0: ',num2str(tNpar0_tail),' with linear distribution h = ',num2str(bopt_tail(ib)),', npar_max = ',num2str(bNparmax_tail(ib))]);
                else
                    error('Linear probability distribution only valid for fluctuating model.')
                end
                %
            elseif tail.mode == 3,% calc_tail_jd fluctuations or static model
                %
                if ~isinf(tail.dtn),% fluctuating spectrum model
                    %
                    if length(btNpar0_tail{ib}) > 1,
                        tNpar0_tail = randreject_yp(@fcalc_tail_yp,{btNpar0_tail{ib},btdNpar0_tail{ib},btP0_2piRp_tail{ib},bP0_2piRp(ib),[btNpar0_tail{ib}(1)-2*btdNpar0_tail{ib}(1)*sign(btNpar0_tail{ib}(1)),btNpar0_tail{ib}(end)+2.0*btdNpar0_tail{ib}(1)*sign(btNpar0_tail{ib}(end))]},1,0);
                    else
                        tNpar0_tail = randg_yp(1,bNpar0(ib),bdNpar0(ib));%New random npar0 around npar_antenna Gaussian shape)
                        %bNpar0_tail = bNpar0(ib);%npar0 = npar_antenna
                    end
                    %
                    tdNpar0_tail = bdNpar0(ib);
                    tP0_2piRp_tail = bP0_2piRp(ib);
                    %
                    disp(['Calculated distribution -> npar_antenna: ',num2str(bNpar0(ib)),', new npar0: ',num2str(tNpar0_tail),' with linear distribution h = ',num2str(bopt_tail(ib)),', npar_max = ',num2str(bNparmax_tail(ib))]);
                else
                    % static spectrum model
                    tNpar0_tail = btNpar0_tail{ib};
                    tdNpar0_tail = btdNpar0_tail{ib};
                    tP0_2piRp_tail = btP0_2piRp_tail{ib};
                    %
                end
            else% no tail model
                tNpar0_tail = bNpar0(ib);
                tdNpar0_tail = bdNpar0(ib);
                tP0_2piRp_tail = bP0_2piRp(ib);                
            end
            %
            for itail = 1:length(tNpar0_tail),% sum of tail lobes
                %
                if ~isnan(bNy(ib)),% Npar0 is in fact Nz readjust Npar0 with Ny
                    tNpar0_tail(itail) = bNy(ib) + 1i*tNpar0_tail(itail);
                end
                %
                for im = 1:nm,% sum over initial m
                    %
                    iy = iy + 1;
                    %
                    rayinit.yrho0(iy) = rho0;%Initial radial position at launch
                    rayinit.ytheta0(iy) = rbtheta0(ir,ib);%Initial poloidal position at launch
                	if isfield(launch,'z0')
                    	rayinit.yz0(iy) = launch.z0;%Initial axial position at launch
                   		rayinit.ykz0(iy) = launch.kz0;%Initial axial wave vector
                	elseif isfield(launch,'phi0') && ~isinf(equil.Rp),
                    	rayinit.yphi0(iy) = launch.phi0;%Initial toroidal position at launch
                    	rayinit.yn0(iy) = launch.n0;%Initial toroidal mode number
                	else
                    	error('ERROR in main_rayinit_launch_jd.m -> inconsistent launch input: use phi0 if Rp is finite only, or z0 otherwise.');
                	end
                	%
                	rayinit.ym0(iy) = real(launch.m0(im));%Initial poloidal mode number              
                    %
                    rayinit.yNpar0(iy) = tNpar0_tail(itail);%Initial index of refraction
                    rayinit.ydNpar0(iy) = tdNpar0_tail(itail);%initial Ray spectral width
                    rayinit.yP0_2piRp(iy) = tP0_2piRp_tail(itail)*imag(launch.m0(im))/nr;%Lineic initial power density initial power in the ray (W/m)
                    %
                    rayinit.yib(iy) = ib;
                    rayinit.yir(iy) = ir;
                    rayinit.yim(iy) = im;
                    rayinit.yit(iy) = itail;
                end
            end
        end
    end
else
    error('launch type not recognised')
end
%
rayinit.launch = launch;
%
