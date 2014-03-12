function [rays] = loop_main_C3PO_jd(iray,equil,equil_fit,id_wave,omega_rf,rayinit,rayparam,flag,waveparam,C3POdisplay,f0struct,fluct_fit)
%C3PO - Set ray initial characteristics and launches the C3PO ray-tracing code (loop function for distributed computing environment)
%
%This function calculates the ray initial characteristics and launches the C3PO ray-tracing code
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) and 
%
% this function is called for a single ray
%
rayinit.yrho0 = rayinit.yrho0(iray);
rayinit.ytheta0 = rayinit.ytheta0(iray);
%
if isfield(rayinit,'yphi0') && ~isinf(equil_fit.Rp),
    rayinit.yz0 = rayinit.yphi0*equil_fit.Rp;
    rayinit = rmfield(rayinit,'yphi0');
elseif isfield(rayinit,'yphi0') && isinf(equil_fit.Rp),
    error('ERROR in loop_main_C3PO_jd.m: inconsistent rayinit input: use yphi0 if Rp is finite only, or yz0 elsewhere.');
end
%
rayinit.yz0 = rayinit.yz0(iray);
%
rayinit.ym0 = rayinit.ym0(iray);
%
if isfield(rayinit,'yn0') && ~isinf(equil_fit.Rp),
    rayinit.ykz0 = rayinit.yn0/equil_fit.Rp;%backward compatibility for the toroidal coordinates
    rayinit = rmfield(rayinit,'yn0');
elseif isfield(rayinit,'yn0') && isinf(equil_fit.Rp),
    error('ERROR in loop_main_C3PO_jd.m: inconsistent rayinit input: use yn0 if Rp is finite only, or ykz0 elsewhere.');
end
%
rayinit.ykz0 = rayinit.ykz0(iray);
%
rayinit.yNpar0 = rayinit.yNpar0(iray);
rayinit.ydNpar0 = rayinit.ydNpar0(iray);
rayinit.yP0_2piRp = rayinit.yP0_2piRp(iray);
%
if isfield(rayinit,'yib'),
    rayinit.yib = rayinit.yib(iray);
end
%
if isfield(rayinit,'yir'),
    rayinit.yir = rayinit.yir(iray);
end
%
if isfield(rayinit,'yim'),
    rayinit.yim = rayinit.yim(iray);
end
%
if isfield(rayinit,'yit'),
    rayinit.yit = rayinit.yit(iray);
end
%
if isfield(rayinit,'yXfrac'),
    rayinit.yXfrac = rayinit.yXfrac(iray);
else
    rayinit.yXfrac = NaN;
end
%
tau_lim_init = rayparam.tau_lim;%Initial optical depth limit
kmode = waveparam.kmode;
ydNpar0 = rayinit.ydNpar0;
%
if isfield(rayinit,'launch'),
    launch0 = rayinit.launch;
else
    launch0 = '';
end
%
if isfield(launch0,'mmode') && launch0.mmode ~= waveparam.mmode,
    disp('WARNING : waveparam.mmode enforced with the value from launch0.mmode');
    waveparam.mmode = launch0.mmode;
end
%
rays{1}.P0_2piRp = rayinit.yP0_2piRp;%Initial lineic power density in the ray (W/m) [1,1]
%
rays{1}.sx = [];% Ray location (horizontal) along the propagation [1,ns]
rays{1}.sy = [];% Ray location (vertical) along the propagation [1,ns]
rays{1}.sz = [];% Ray location (axial or torodial) along the propagation [1,ns]
%
rays{1}.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
%
rays{1}.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
rays{1}.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
rays{1}.sphi = [];% Ray location (toroidal angle) along the propagation [1,ns]
%
rays{1}.skx = [];% Ray wave vector (major radius) along the propagation [1,ns]
rays{1}.sky = [];% Ray wave vector (vertical) along the propagation [1,ns]
rays{1}.skz = [];% Ray wave vector (axial or toroidal) along the propagation [1,ns]
%
rays{1}.skrho = [];% Ray wave number (radial) along the propagation [1,ns]
rays{1}.sm = [];% Ray wave number (poloidal) along the propagation [1,ns]
rays{1}.sn = [];% Ray wave number (toroidal) along the propagation [1,ns]
%
rays{1}.sNpar = [];% Ray parallel wave number [1,ns]
rays{1}.sNperp = [];% Ray perpendicular wave number [1,ns]
rays{1}.sdNpar = [];% Ray spectral width in Npar [1,ns] 
%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. ->
%       square spectrum (centered on sNpar)
rays{1}.sepol_pmz = zeros(3,0);% polarization vector [3,ns] complex
rays{1}.sphi_xyz = zeros(3,0);% normalized power flow [3,ns]
%
rays{1}.spmode = [];%(1) cold mode p, (0) cold mode m (p is the slow LH wave)  
%
rays{1}.sr = [];% Ray radial position [1,ns] (m)
rays{1}.srho = [];% Ray normalized radial position [1,ns]
%
rays{1}.salphaphi_lin = [];% Ray absorption coefficient [1,ns]
rays{1}.stau_lin = [];% Ray optical depth [1,ns]
%
rays{1}.seikval = [];% Eikonal approximation validity (OK if less than 1) [1,ns]
rays{1}.sD = [];% Dispersion relation [1,ns]
%
rays{1}.sB = [];% Total magnetic field along the ray [1,ns] (T)
rays{1}.sBRHO = [];% Radial magnetic field along the ray [1,ns] (T)
rays{1}.sBP = [];% Poloidal magnetic field along the ray [1,ns] (T)
rays{1}.sBz = [];% Toroidal or axial magnetic field along the ray [1,ns] (T)

rays{1}.sTe = [];% Electron temperature along the ray [1,ns] (keV)
rays{1}.sne = [];% Electron density along the ray [1,ns] (m-3)
rays{1}.szTi = zeros(length(equil_fit.zZi),0);% Ion temperatures along the ray [ni,ns] (keV)
rays{1}.szni = zeros(length(equil_fit.zZi),0);% Ion densities along the ray [ni,ns] (m-3)
%
rays{1}.swpe2 = [];%Normalized electron plasma frequency
rays{1}.swce2 = [];%Normalized electron gyro frequency
%
rayinit.tau0_lin = 0;%initial optical depth
rayinit.ss0 = 0;%initial ray length
%
rays{1}.rayinits{1} = rayinit;
%
if isnan(rayinit.yXfrac),% polarization enforced by waveparam.mmode
    mmode = sign(waveparam.mmode);%initial polarization
else%
    %  polarization enforced by rayinit.yXfrac. 
    %
    mmodethres = 1 - abs(waveparam.mmode);% waveparam.mmode sets the threshold for considering both polarizations.
    %
    if rayinit.yXfrac <= mmodethres || rayinit.yXfrac >= (1 - mmodethres),% approximate to dominant mode
        mmode = sign(rayinit.yXfrac - 1/2);
    else% split power according to rayinit.yXfrac
        mmode = [rayinit.yXfrac,1-rayinit.yXfrac];%[Xfrac, Ofrac]
    end
end
%
if length(mmode) == 1,% one mode only
    rays{1}.rayinits{1}.mmode = mmode;
else% split power according to mmode
    %
    rays{2} = rays{1};% copy ray parameters
    %
    rays{1}.rayinits{1}.mmode = 1;% X mode
    rays{1}.rayinits{1}.yP0_2piRp = rays{1}.rayinits{1}.yP0_2piRp*mmode(1);
    rays{1}.P0_2piRp = rays{1}.P0_2piRp*mmode(1);
    %
    rays{2}.rayinits{1}.mmode = -1;% O mode
    rays{2}.rayinits{1}.yP0_2piRp = rays{2}.rayinits{1}.yP0_2piRp*mmode(2);
    rays{2}.P0_2piRp = rays{2}.P0_2piRp*mmode(2);
    %
end  
%
% --------------
%
% rayparam.reflection :
% 	* 0 : no reflection
%	* 1 : reflections in C3PO on LCFS (LH waves...)
%	* -n : up to n reflections on vessel internal wall
%   * (+1i) : calc rayinit for last reflection, no new C3PO calculation (ex: stray emission)
%
lastref = imag(rayparam.reflection);% calc rayinit for last reflection, no new C3PO calculation (ex: stray emission)
rayparam.reflection = real(rayparam.reflection);
%
nref = max([0,-rayparam.reflection]);
rayparam.reflection = max([rayparam.reflection,0]);% take only positive or null in C3PO
%
if nref > 0,
	C3POdisplay.ray = 0;
end
%
for iref = 1:nref + 1,% vessel reflection index
	%
    nrays = length(rays);
    oldrays = zeros(1,nrays);
    newrays = cell(1,0);
    %
	for irayref = 1:nrays,% each ray generated by vessel reflection must be considered separately
		%
        if length(rays{irayref}.rayinits) < iref,% this ray is absorbed or not reflected
            continue
        end
        %
        rayinit = rays{irayref}.rayinits{end};
        %
		y0 = init_RT_jd(equil_fit,...
            rayinit.yrho0,rayinit.ytheta0,rayinit.yz0,omega_rf,...
            rayinit.yNpar0,rayinit.ym0,rayinit.ykz0,rayinit.mmode,kmode,fluct_fit).';
        %
		if C3POdisplay.ray,
			info_dke_yp(2,['Initial conditions of ray #',int2str(iray),' are calculated']);
		end
		%
		if isreal(y0(4)) && abs(y0(4)) > 0,%ray enters the plasma
            %
            rayparam.tau_lim = tau_lim_init - rayinit.tau0_lin;% the absorption criterion accounts for previous steps
			%
			[tout, yout, yproc] = raytracing_yp(rayparam,equil_fit,y0,f0struct,fluct_fit,flag);            
			%
			if C3POdisplay.ray,
				info_dke_yp(2,['Trajectory of ray #',int2str(iray),' is calculated']);
			end
			%
			filename_in = [id_wave,'_ray_',int2str(iray)];
            %
			[iabs_out,srho,stheta,sx,sy,sz,sNpar,sNperp,sepol_pmz,sphi_xyz,spmode,sD,ss,salphaphi_lin,sB,sBRHO,sBP,sBz,sTe,sne,szTi,szni,sr,salpha,sgradrhon,stau_lin,seikval,skrho,sm,skz,sn,swpe2,swce2] = raypostprocessing_yp(tout,yout,yproc,rayparam,equil_fit,fluct_fit,C3POdisplay.text,C3POdisplay.ray,C3POdisplay.p_opt,filename_in);
            %
			if C3POdisplay.ray == 1,
				pause(5)
            end
			%
			% building ray for FP calculations
			%
			rays{irayref}.sx = [rays{irayref}.sx,sx.'];% Ray location (horizontal) along the propagation [1,ns]
			rays{irayref}.sy = [rays{irayref}.sy,sy.'];% Ray location (vertical) along the propagation [1,ns]
			rays{irayref}.sz = [rays{irayref}.sz,sz.'];% Ray location (axial) along the propagation [1,ns]
            %
			rays{irayref}.ss = [rays{irayref}.ss,rayinit.ss0 + ss.'];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
			rays{irayref}.stheta = [rays{irayref}.stheta,stheta.'];% Ray location (poloidal angle) along the propagation [1,ns]
            %
            if ~isinf(equil_fit.Rp),
                sphi = sz/equil_fit.Rp;
            else
                sphi = NaN(size(sz));
            end
            %
            rays{irayref}.sphi = [rays{irayref}.sphi,sphi.'];
			%
			rays{irayref}.skrho = [rays{irayref}.skrho,skrho.'];% Ray radial wave vector [1,ns]
			rays{irayref}.sm = [rays{irayref}.sm,sm.'];% Ray poloidal wave number [1,ns]
            rays{irayref}.skz = [rays{irayref}.skz,skz.'];% Ray axial wave vector [1,ns]
			rays{irayref}.sn = [rays{irayref}.sn,sn.'];% Ray toroidal wave number [1,ns]
			%
			rays{irayref}.sNpar = [rays{irayref}.sNpar,sNpar.'];% Ray parallel wave number [1,ns]
			rays{irayref}.sNperp = [rays{irayref}.sNperp,sNperp.'];% Ray perpendicular wave number [1,ns]
			rays{irayref}.sdNpar = [rays{irayref}.sdNpar,ydNpar0*ones(1,length(srho))];% Ray spectral width in Npar [1,ns] 
			%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. ->
			%       square spectrum (centered on sNpar)
			rays{irayref}.sepol_pmz = [rays{irayref}.sepol_pmz,sepol_pmz.'];% polarization vector [3,ns] complex
			rays{irayref}.sphi_xyz = [rays{irayref}.sphi_xyz,sphi_xyz.'];% normalized power flow [3,ns]
			%
			rays{irayref}.spmode = [rays{irayref}.spmode,spmode.'];%(1) cold mode p, (0) cold mode m (p is the slow LH wave)  
			%
			rays{irayref}.sr = [rays{irayref}.sr,sr.'];% Ray radial position [1,ns] (m)
			rays{irayref}.srho = [rays{irayref}.srho,srho.'];% Ray normalized radial position [1,ns]
			%
			rays{irayref}.salphaphi_lin = [rays{irayref}.salphaphi_lin,salphaphi_lin.'];% Ray absorption coefficient [1,ns]
			rays{irayref}.stau_lin = [rays{irayref}.stau_lin,rayinit.tau0_lin + stau_lin.'];% Ray optical depth [1,ns]
            %
            rays{irayref}.seikval = [rays{irayref}.seikval,seikval.'];% Eikonal approximation validity (OK if less than 1) [1,ns]
            rays{irayref}.sD = [rays{irayref}.sD,sD.'];% Dispersion relation [1,ns]
			%
			rays{irayref}.sB = [rays{irayref}.sB,sB.'];% Total magnetic field along the ray [1,ns] (T)
			rays{irayref}.sBRHO = [rays{irayref}.sBRHO,sBRHO.'];% Radial magnetic field along the ray [1,ns] (T)
			rays{irayref}.sBP = [rays{irayref}.sBP,sBP.'];% Poloidal magnetic field along the ray [1,ns] (T)
			rays{irayref}.sBz = [rays{irayref}.sBz,sBz.'];% Toroidal magnetic field along the ray [1,ns] (T)
			
			rays{irayref}.sTe = [rays{irayref}.sTe,sTe.'];% Electron temperature along the ray [1,ns] (keV)
			rays{irayref}.sne = [rays{irayref}.sne,sne.'];% Electron density along the ray [1,ns] (m-3)
			rays{irayref}.szTi = [rays{irayref}.szTi,szTi.'];% Ion temperatures along the ray [ni,ns] (keV)
			rays{irayref}.szni = [rays{irayref}.szni,szni.'];% Ion densities along the ray [ni,ns] (m-3)
            %
            rays{irayref}.swpe2 = [rays{irayref}.swpe2,swpe2];%Normalized electron plasma frequency
            rays{irayref}.swce2 = [rays{irayref}.swce2,swce2];%Normalized electron gyro frequency
            %
			if (iref <= nref || lastref) && yout(end,1) > 1 - 2*rayparam.dS && ~isinf(equil.Rp),% ray reaches edge before full absorption and a reflection is enforced
				%
                sR = sx + equil.Rp;
                sZ = sy + equil.Zp;
                %
				R_end = sR(end); 
				phi_end = sphi(end);
				Z_end = sZ(end);		
				%
				X_end = R_end.*cos(phi_end);
				Y_end = -R_end.*sin(phi_end);%note phi is of opposite sign to usual convention (it is clockwise from top)
				%
				krho_end = yout(end,4);
				m_end = yout(end,5);
				n_end = yout(end,6);
				%
				gradrhon_end = sgradrhon(end);
				alpha_end = salpha(end);
				theta_end = stheta(end);
				r_end = sr(end);
				%  
				kR_end = krho_end*gradrhon_end*cos(theta_end - alpha_end)/equil_fit.ap - m_end*sin(theta_end)/r_end;
				kZ_end = krho_end*gradrhon_end*sin(theta_end - alpha_end)/equil_fit.ap + m_end*cos(theta_end)/r_end;
				kphi_end = n_end/R_end;
				%
				kX_end = kR_end*cos(phi_end) - kphi_end*sin(phi_end);
				kY_end = -kR_end*sin(phi_end) - kphi_end*cos(phi_end);
				%
				P_end = [X_end;Y_end;Z_end];
				K_end = [kX_end;kY_end;kZ_end];
                %
                % calculate the polarization in the zero-density limit so that K is perpendicular to E
                %
                B_end = sB(end);
                BPHI_end = sBz(end);
                Bx_end = sBP(end)*sin(alpha_end - theta_end);%note that sBP is signed
                By_end = sBP(end)*cos(alpha_end - theta_end);
                %
                BX_end = Bx_end*cos(phi_end) - BPHI_end*sin(phi_end);
                BY_end = -Bx_end*sin(phi_end) - BPHI_end*cos(phi_end);
                BZ_end = By_end;
                %
                B_end_XYZ = [BX_end;BY_end;BZ_end];
                %
                N_end = K_end/norm(K_end);%index of refraction is 1 in vacuum
                %
                z_XYZ = B_end_XYZ/B_end;
                y_XYZ = cross(B_end_XYZ,N_end)/norm(cross(B_end_XYZ,N_end));
                x_XYZ = cross(y_XYZ,z_XYZ);
                %
                M_xyzXYZ = [x_XYZ,y_XYZ,z_XYZ];
                %
                Npar_end = N_end.'*z_XYZ;%value in vacuum
                %
                [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz] = colddisp_dke_jd(Npar_end,omega_rf,NaN,0,1,1,B_end);
                %
                ep_XYZ = M_xyzXYZ*ep_xyz;
                em_XYZ = M_xyzXYZ*em_xyz;
                %
                if spmode(end) == 1,
                    E_end = ep_XYZ;
                else
                    E_end = em_XYZ;
                end
                %          
                %E_end = sepol_pmz(end,:).';
				%
                nrefvac = 10;% number of vacuum reflections allowed
                launch_back = '';
                %
                for i=1:nrefvac% to allow reflections without reentering the plasma
                    %
                    %try
                        save rayend.mat P_end N_end E_end
                        %keyboard
                        [P_ref,N_ref,E_ref] = reflection_jd(equil,P_end,N_end,E_end);
                    %catch
                        %keyboard
                    %end
                    %
                    R_ref = sqrt(P_ref(1).^2 + P_ref(2).^2);
                    Z_ref = P_ref(3);
                    phi_ref = -atan(P_ref(2)./P_ref(1)) + pi*(P_ref(1) < 0) - 2*pi*(P_ref(1) < 0 && P_ref(2) > 0);% -pi < phi < pi
                    %	
                    NR_ref = N_ref(1)*cos(phi_ref) - N_ref(2)*sin(phi_ref);
                    Nphi_ref = -N_ref(1)*sin(phi_ref) - N_ref(2)*cos(phi_ref);
                    NZ_ref = N_ref(3);
                    %
                    launch = launch0;
                    launch.launch_back = launch_back;
                    %
                    launch.yR_L = R_ref;
                    launch.yZ_L = Z_ref;
                    launch.yphi_L = phi_ref;
                    launch.yalpha_L = - atan(Nphi_ref/NR_ref) + pi*(NR_ref < 0) - 2*pi*(NR_ref < 0 && Nphi_ref > 0);% -pi < alpha < pi
                    launch.ybeta_L = acos(NZ_ref);% 0 < beta < pi
                    %
                    launch.N_XYZ = N_ref;
                    launch.epol_XYZ = E_ref;
                    %
                    rayinit = main_rayinit_launch_jd(equil,launch);
                    %
                    if ~isnan(rayinit.yrho0),% the ray reenters the plasma
                        break
                    else
                        launch_back = launch;
                        P_end = P_ref;
                        N_end = N_ref;
                        E_end = E_ref;
                    end
                end
                %
                rayinit.tau0_lin = rays{irayref}.stau_lin(end);
                rayinit.ss0 = rays{irayref}.ss(end);
				%
                if iref == nref + 1,% end of calculation, just add last point of reflection,
                    %
                    rays{irayref}.rayinits = [rays{irayref}.rayinits,rayinit];
                    %
                elseif ~isempty(rayinit.yrho0) && ~isnan(rayinit.yrho0),% The reflected ray reaches the plasma, new rays are formed
					%
                    ray = rays{irayref};
                    %
                    rayX = ray;
                    rayO = ray;
                    %
                    rayX.P0_2piRp = ray.P0_2piRp*rayinit.am2;
                    %
                    rayO.P0_2piRp = ray.P0_2piRp*rayinit.ap2;
                    %
                    rayinit.mmode = 1;
                    rayX.rayinits = [rayX.rayinits,rayinit];
                    %
                    rayinit.mmode = -1;
                    rayO.rayinits = [rayO.rayinits,rayinit];
                    %                    
                    newrays = [newrays,rayX,rayO];% two new rays obtained from duplicating original ray
                    oldrays(irayref) = 1;% old duplicated ray to be removyed
                    %                    
				end
			end
        else
            disp('Pb krho at the edge. No ray tracing');
        end
    end
	%
    rays = [rays(oldrays == 0),newrays];
	%
end

