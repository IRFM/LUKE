function rayinit = main_rayinit_launch_jd(equil,launch)
%
% This function creates the rayinit structure based on ray launching parameters. Straight ray
% propagation is assumed up to the last closed flux-surface.
%
% INPUTS:
%   Launch structure fields:
%
%       - type = Type of wave (LH or EC;
%       - omega_rf = [4.6]*2*pi*1e9;%wave angular frequency (rad/s)
%
%   Specific to LH wave
%
%       - bPlhtot: initial power in the ray (W) [1,n_lobe]
%       - bNpar0: Initial Npar value [1,n_lobe]
%       - bdNpar0: Initial dNpar value [1,n_lobe]
%       - rZ0: vertical launching positions [m_pol,1]
%
%       - m0: initial poloidal mode number
%       - n0: initial toroidal mode number
%       - phi0: toroidal angle position
%       - i_ref: Initial radial position index
%       - LFS: (-1) high field side launching, (1) low field side launching
%
%   Specific to EC wave
%
%       - yR_L : major radius position of launching (m)
%       - yZ_L : vertical position of launching (m)
%       - yphi_L : toroidal angle position of launching (rad), (R,Z,phi) right handed
%       - yalpha_L : horizontal angle with respect to R (rad)
%       - ybeta_L : vertical angle with respect to Z (rad) 
%       - yP_L : power launched in the ray (W)
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
if ~isfield(launch,'n0'),
    launch.n0 = NaN;
end
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
    ny = length(launch.yP_L);
    %
    ptr = sqrt(equil.ptx.^2 + equil.pty.^2);
    smax = 2*max(max(ptr));
    s = linspace(0,smax,ns);
    %
    % Straight ray propagation to reach first closed flux surface
    %
    [sysh,sysZ,syR,syZ,syphi,syalpha,sybeta,sygR,sygZ,sygphi] = raypath_prop_jd(launch.yR_L,launch.yZ_L,-launch.yphi_L,launch.yalpha_L,launch.ybeta_L,s);
    % The definition of phi in raypath_prop_jd is opposite from the definition in DKE
    syx = syR - equil.Rp;
    syy = syZ - equil.Zp;
    syphi = - syphi;
    sygphi = - sygphi;
    %
    syr = sqrt(syx.^2 + syy.^2);
    syx(syx == 0) = eps;
    sytheta = atan(syy./syx) + pi*(syx < 0) + 2*pi*(syx > 0 & syy < 0);
    %
    % In vacuum N = g; 
    %
    syNx = sygR;
    syNy = sygZ;
    syNphi = sygphi;
    %
    yP0_2piRp = launch.yP_L/(2*pi*equil.Rp);
    %
    psi_apRp = equil.psi_apRp;
    psin = psi_apRp/psi_apRp(end);
    %
    rayinit.omega_rf = launch.omega_rf;
    %
    for iy = 1:ny,    
        %
        if ~isnan(launch.yR_L(iy)),
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
            s0 = sqrt(sysh(is0,iy).^2 + sysZ(is0,iy).^2);%distance along the ray from mirror to LCFS   
            %
            x0 = syx(is0,iy);
            y0 = syy(is0,iy);
            r0 = syr(is0,iy);
            theta0 = sytheta(is0,iy);
            phi0 = syphi(is0,iy);
            Nx0 = syNx(is0,iy);
            Ny0 = syNy(is0,iy);
            Nphi0 = syNphi(is0,iy);
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
            y0 = launch.yZ_L(iy) - equil.Zp;
            x0 = interp1(ty(mask),tx(mask),y0,method,NaN);
            %
            if isnan(y0),
                error('The vertical launching position in beyond the LCFS');
            end
            %
            r0 = sqrt(x0.^2 + y0.^2);
            theta0 = atan(y0./x0) + pi*(x0 < 0) + 2*pi*(x0 > 0 & y0 < 0);
            phi0 = - launch.yphi_L(iy);
            %
            Nx0 = sin(launch.ybeta_L(iy)).*cos(launch.yalpha_L(iy));
            Ny0 = cos(launch.ybeta_L(iy));
            Nphi0 = sin(launch.ybeta_L(iy)).*sin(launch.yalpha_L(iy));
            %
        end
        %
        if ~isempty(psin0),
            %
            Bx0 = interp2(psin,equil.theta,equil.ptBx.',psin0,theta0,method);
            By0 = interp2(psin,equil.theta,equil.ptBy.',psin0,theta0,method);
            BPHI0 = interp2(psin,equil.theta,equil.ptBPHI.',psin0,theta0,method);    
            %
            B0 = sqrt(Bx0.^2 + By0.^2 + BPHI0.^2);
            Npar0 = (Nx0*Bx0 + Ny0*By0 + Nphi0*BPHI0)/B0;
            %
            Bp0 = sqrt(Bx0.^2 + By0.^2);
            cosalpha0 = (By0*x0 - Bx0*y0)/r0/Bp0;
            Ns0 = (Nx0*Bx0 + Ny0*By0)/Bp0;
            m0 = r0*Ns0*rayinit.omega_rf/clum/cosalpha0;
            %
            rayinit.yrho0(iy) = rho0;%Initial radial position at launch
            rayinit.ytheta0(iy) = theta0;%Initial poloidal position at launch
            rayinit.yphi0(iy) = phi0;%Initial toroidal position at launch
            rayinit.ym0(iy) = m0;%Initial poloidal mode number
            rayinit.yn0(iy) = launch.n0;%Initial toroidal mode number
            rayinit.yNpar0(iy) = Npar0;%Initial index of refraction
            rayinit.ydNpar0(iy) = dNpar0;%initial Ray spectral width
            rayinit.yP0_2piRp(iy) = yP0_2piRp(iy);%Lineic initial power density initial power in the ray (W/m)
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
                BX0 = Bx0*cos(phi0) - BPHI0*sin(phi0);
                BY0 = -Bx0*sin(phi0) - BPHI0*cos(phi0);
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
            rayinit.yphi0(iy) = NaN;%Initial toroidal position at launch
            rayinit.ym0(iy) = NaN;%Initial poloidal mode number
            rayinit.yn0(iy) = NaN;%Initial toroidal mode number
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
    %
    bP0 = launch.bPlhtot;%initial power in the ray (W) [1,n_lobe]
    bNpar0 = launch.bNpar0;%Initial Npar value [1,n_lobe]
    bdNpar0 = launch.bdNpar0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    ry0 = launch.rZ0 - equil.Zp;
    rby0 = ry0(:)*ones(1,length(bP0));%[m_pol,n_lobe]
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
    bP0_2piRp = bP0/(2*pi*equil.Rp);
    %
    if all(imag(launch.m0) == 0),
        launch.m0 = launch.m0 + 1i/nm;%uniform power distribution
    end
    %
    iy = 0;
    %
    for ib = 1:nb,
        for ir = 1:nr,
            for im = 1:nm,
                %
                iy = iy + 1;
                %
                rayinit.yrho0(iy) = rho0;%Initial radial position at launch
                rayinit.ytheta0(iy) = rbtheta0(ir,ib);%Initial poloidal position at launch
                rayinit.yphi0(iy) = launch.phi0;%Initial toroidal position at launch
                rayinit.ym0(iy) = real(launch.m0(im));%Initial poloidal mode number
                rayinit.yn0(iy) = launch.n0;%Initial toroidal mode number
                %
                rayinit.yNpar0(iy) = bNpar0(ib);%Initial index of refraction (default values, no fluctuations)
                %
                % Statistical initial condition (edge fluctuation)
                %
                if isfield(equil,'fluct'),
                    if isfield(equil.fluct,'edge'),
                        if isfield(equil.fluct.edge,'hwhm_npar') && isfield(equil.fluct.edge,'dtn'),
                            if ~isempty(equil.fluct.edge.hwhm_npar) && ~isinf(equil.fluct.edge.dtn),
                                if isfield(equil.fluct.edge,'flag'),
                                    if equil.fluct.edge.flag,%random npar0 with Gaussian distribution for each lobe
                                        rayinit.yNpar0(iy) = randg_yp(1,bNpar0(ib),equil.fluct.edge.hwhm_npar);%New random Npar0
                                    else
                                        rayinit.yNpar0(iy) = equil.fluct.edge.Npar0(iy);%reload previous Npar0
                                    end
                                    %
                                    disp(['Reference npar0: ',num2str(bNpar0(ib)),', new npar0: ',num2str(rayinit.yNpar0(iy)),' with Gaussian distribtion HWHM=',num2str(equil.fluct.edge.hwhm_npar)]);
                                    %
                                end
                            end
                        end
                    end
                end
                %
                rayinit.ydNpar0(iy) = bdNpar0(ib);%initial Ray spectral width
                rayinit.yP0_2piRp(iy) = bP0_2piRp(ib)*imag(launch.m0(im))/nr;%Lineic initial power density initial power in the ray (W/m)
                %
            end
        end
    end
else
    error('launch type not recognised')
end
%
rayinit.launch = launch;
%
