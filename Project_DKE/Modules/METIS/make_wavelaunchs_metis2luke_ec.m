function launchs = make_wavelaunchs_metis2luke_ec(option,ecparam,equil)
%
% This function returns EC wave launching parameters
%
% by J. Decker and J.-F. Artaud, 02/02/2011
%
if ecparam.pec < ecparam.pecmin,% not enough power to account for wave
    launchs = cell(1,0);
    return
end
%
[qe,me,void,void,void,void,void,mc2] = pc_dke_yp;
%
offset = 0.01;
%
if ecparam.mode == 1,
    %
    % C3PO/LUKE case with one launcher and horizontal propagation. The
    % toroidal angle is chosen to match the prescribed poloidal location
    %
    launch.id = 'EC';
    launch.type = 'EC';
    %
    launch.dNpar0 = ecparam.dnpar0;%ray spectral width for Fokker-Planck calculations
    launch.mmode = ecparam.mmode;% (-1) for O mode (1) for X mode
    %
    launch.ns = ecparam.ns;
    launch.method = ecparam.method;
    %
    launch.yP_L = ecparam.pec;% wave power (W)
    %
    nr = length(equil.psi_apRp);
    %
    px = linspace(0,1,nr);% metis radial grid
    %
    xec = ecparam.xec;% radial position at deposition location
    polec = ecparam.polec*pi/180;% poloidal angle at deposition location (rad)
    omega_rf = ecparam.freqec*2*pi*1e9;%wave angular frequency (rad/s)
    alpha_L = ecparam.alpha_L*pi/180;% toroidal launching angle (rad)
    %
    pabs = ecparam.pabs;%momentum at absorption (for Doppler shift)
    %
    if isnan(polec) && isnan(omega_rf),
        error('One parameter among these two must be specified : poloidal location and EC frequency')
    end
    if ~isnan(polec) && ~isnan(alpha_L) && omega_rf > 0,
        disp('Warning : poloidal location, EC frequency, and toroidal launching angle cannot be specified independently. polodal location discarded')
        polec = NaN;
    end
    %
    R_L = 1.1*max(max(equil.Rp + equil.ptx));
    beta_L = pi/2;%horizontal propagation
    phi_L = ecparam.phi0;
    %
    % straight line to reach virtual launching point (on a vertical line
    % located at R = 1.1 Rmax where Rmax is the maximum R in the plasma)
    %
    s = linspace(0,2*equil.Rp,launch.ns);
    %
    Te_abs = interp1(px,equil.pTe,ecparam.xec,ecparam.method);
    betath = sqrt(Te_abs/mc2);
    %
    if ~isnan(polec),%Doppler shift used to determine frequency or launching angle
        %
        R_abs = equil.Rp + interp2(px,equil.theta,equil.ptx.',xec,polec,ecparam.method);
        Z_abs = equil.Zp + interp2(px,equil.theta,equil.pty.',xec,polec,ecparam.method);
        Bx_abs = interp2(px,equil.theta,equil.ptBx.',xec,polec,ecparam.method);
        By_abs = interp2(px,equil.theta,equil.ptBy.',xec,polec,ecparam.method);
        BPHI_abs = interp2(px,equil.theta,equil.ptBPHI.',xec,polec,ecparam.method);
        %
        B_abs = sqrt(Bx_abs^2 + By_abs^2 + BPHI_abs^2);
        %
        Z_L = Z_abs;%horizontal propagation
        %
        if R_abs < equil.Rp && abs(Z_L - equil.Zp)/max(equil.pty(:)) < offset,
            disp(['Warning : Propagation right across the center is problematic in C3PO. Small relative vertical shift of ',num2str(offset),' enforced.'])
            Z_L = Z_L + offset*max(equil.pty(:));
        end
        %
        if omega_rf > 0,%alpha from Doppler shift
            %
            B1_res = omega_rf*me/qe; 
            n_ec = fix(B1_res/B_abs);%harmonic number
            deltalnR = B1_res/(n_ec*B_abs) - 1;%relative B-field gap
            % 
            if deltalnR > 1/(2*n_ec),
                disp('Warning : prescribed absorption appears to be behind nominal resonance, alpha = 0 enforced')
                sinalpha_abs = 0;
            else
                sinalpha_abs = deltalnR/pabs/betath;%approximate Doppler shift estimation, based on Decker PoP 06 with pnp = 2
                if sinalpha_abs > 1.0,
                    disp('Warning : prescribed Doppler shift appears to be too large, local alpha limited to pi/2')
                    sinalpha_abs = 1.0;
                end
            end
            %
            alpha_abs = option.signe*option.sens*asin(sinalpha_abs);
            %
            [void,void,syR,void,void,syalpha] = raypath_prop_jd(R_abs,Z_abs,phi_L,alpha_abs,beta_L,s);
            %
            alpha_L = pi + interp1(syR,syalpha,R_L,'linear');
            %
        else%omega from Doppler shift
            %
            n_ec = -omega_rf/(2*pi*1e9);
            %
            if ~isnan(alpha_L),
                %
                [void,void,syR,void,void,syalpha] = raypath_prop_jd(R_L,Z_L,phi_L,alpha_L,beta_L,s);
                %
                alpha_abs = interp1(syR,syalpha,R_abs,'linear');
                %
                if isnan(alpha_abs),
                    disp('Warning : Doppler shift could not be determined, enforced to 0')
                    alpha_abs = 0;
                end
                %
            else % alpha_L determined from local alpha
                %
                if option.sens ~= 0,% ECCD
                    %
                    alpha_abs = option.signe*option.sens*30*pi/180;%approximate optimal angle
                    %
                else                % ECRH
                    %
                    alpha_abs = 0;
                    %
                end                    
                %
                [void,void,syR,void,void,syalpha] = raypath_prop_jd(R_abs,Z_abs,phi_L,alpha_abs,beta_L,s);
                %
                alpha_L = pi + interp1(syR,syalpha,R_L,'linear');                    
                %
            end
            %
            sinalpha_abs = abs(sin(alpha_abs));
            %
            deltalnR = sinalpha_abs*pabs*betath;%approximate Doppler shift estimation, based on Decker PoP 06 with pnp = 2
            %
            B_res = B_abs*(1 + deltalnR);%relative B-field gap
            %
            omega_rf = n_ec*B_res*qe/me;
            %
        end
        %
    else% deposition location from wave characteristics
        %
        tR_abs = equil.Rp + interp1(px,equil.ptx,xec,ecparam.method);
        tZ_abs = equil.Zp + interp1(px,equil.pty,xec,ecparam.method);
        tBx_abs = interp1(px,equil.ptBx,xec,ecparam.method);
        tBy_abs = interp1(px,equil.ptBx,xec,ecparam.method);
        tBPHI_abs = interp1(px,equil.ptBPHI,xec,ecparam.method);
        %
        [void,void,syR,void,void,syalpha] = raypath_prop_jd(R_L,0,phi_L,alpha_L,beta_L,s);
        %
        talpha_abs = interp1(syR,syalpha,tR_abs,'linear');
        %
        tsinalpha = abs(sin(talpha_abs));
        %
        tdeltalnR = tsinalpha*pabs*betath;%approximate Doppler shift estimation, based on Decker PoP 06 with pnp = 2
        %
        tB_abs = sqrt(tBx_abs.^2 + tBy_abs.^2 + tBPHI_abs.^2);
        %
        B1_res = omega_rf*me/qe; 
        n_ec = max(fix(B1_res./tB_abs));%harmonic number
        %
        tB1_res = n_ec.*tB_abs.*(1 + tdeltalnR);%relative B-field gap
        %
        tmask = 1:(length(tB1_res) + 1)/2;%upper midplane
        %
        Z_L = interp1(tB1_res(tmask),tZ_abs(tmask),B1_res);
        %
        if isnan(Z_L),
            disp('Warning : optimum Z_L not found, Z_L = 0 enforced')
            Z_L = 0;
        end            
        %
    end
    %
    launch.omega_rf = omega_rf;
    %
    if alpha_L > pi,
        alpha_L = alpha_L - 2*pi;
    end
    %
    if option.signe*option.sens*alpha_L > 0,
        disp('Warning : calculated launching angles not compatible with co/counter current prescrion, hence modified')
        alpha_L = -alpha_L;
    end
    %
    launch.yR_L = R_L;
    launch.yZ_L = Z_L;
    launch.yalpha_L = alpha_L;
    launch.ybeta_L = beta_L;
    launch.yphi_L = phi_L;
    %
    launchs{1} = launch;
    %
elseif ecparam.mode == 2,
    %
    % C3PO/LUKE case with detailed launcher structure
    %
    error('ecparam.mode = 2 not yet implemented')
    %
end
%