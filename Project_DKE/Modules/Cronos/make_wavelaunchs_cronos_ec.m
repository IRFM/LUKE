function [launchs] = make_wavelaunchs_cronos_ec(equil,par,cons)
%
% Create the structure launch for EC waves for LUKE in CRONOS
%
% by J. Decker <joan.decker@cea.fr> (CEA-DRFC) and Y.Peysson <yves.peysson@cea.fr> (CEA-DRFC)
%
si = sign(equil.psi_apRp(end));%sign of Iphi
%
nw = length(par.freq_ghz);%number of EC beams
%
% parameters for free space ray propagation towards first closed FS
%
ns = 1000;
method = 'cubic';
%
% one launch for each beam
%
dNpar0 = 0.05;%!!!!!! for now. calculation as a function of gaussian beam properties under way.
%
iww = 0;
%
for iw = 1:nw,
    %
    launch.id = num2str(iw);
    launch.type = 'EC';
    launch.omega_rf = par.freq_ghz(iw)*2*pi*1e9;
    launch.ns = ns;
    launch.method = method;
    %
    launch.yP_L = abs(cons(iw));
    launch.yR_L = par.rant(iw);
    launch.yZ_L = par.zant(iw);
    launch.yphi_L = 0;
    %
    if par.angle_var(iw) == 1,
        %
        angle_mul  = angle(cons(iw));
        angle_pol = fix(abs(angle_mul) .* 1e7) .* 1e-4 - 360;;
        angle_tor = (abs(angle_mul) .* 1e7 - fix(abs(angle_mul) .* 1e7)) .* 1e3 - 360;
        %        
    else
        %
        angle_pol = par.angle_pol(iw);
        angle_tor = par.angle_tor(iw);
        %
    end
    %
    launch.yalpha_L = pi - si*angle_tor*pi/180;% angle_tor>0 for co-current
    if launch.yalpha_L > pi,
        launch.yalpha_L = launch.yalpha_L -2*pi;
    end
    %
    launch.ybeta_L = pi/2 - angle_pol*pi/180;
    %
    launch.mmode = -1^(par.modpolar(iw) == 2);%(1) for X mode
    launch.dNpar0 = dNpar0;
    launch.a_sdNpar = 0.0;%NO Spectral broadening for EC WAVES
    %
    if launch.yP_L > 0,
        iww = iww + 1;
        launchs{iww} = launch;
    end
end
%
