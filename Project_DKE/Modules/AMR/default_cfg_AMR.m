function [AMRcfg,antennacfg] = default_cfg_AMR()
%
% Creates a structure containing all cfg entries with their default values
%
fin = fopen('ebe6_defaults.txt','r');
tline = fgetl(fin);
while tline ~= -1
    if tline(1) == '['
        sec = tline(2:end-1);
    else
        k = findstr('=', tline);
        it = tline(1:k-1);
        val = str2double(tline(k+1:end));
        if isnan(val)
            val = tline(k+1:end);
        end
        AMRcfg.(sec).(it) = val;
    end
    tline = fgetl(fin);
end
fclose(fin);

% antenna cgf
antennacfg.general.noOfCircles = 4;
antennacfg.general.raysPerCircle = 6;
antennacfg.general.turnCircles = false;
antennacfg.general.n_window_points = 30;

antennacfg.antenna_0.model = 'gaussian';
antennacfg.antenna_0.power = 1.0;
antennacfg.antenna_0.toroidal_angles = [0.0];
antennacfg.antenna_0.poloidal_angles = [0.0];
antennacfg.antenna_0.angles_E_equatorial = [0.0];
antennacfg.antenna_0.angle_scan = 'none';
antennacfg.antenna_0.n_tor_angles = 13;
antennacfg.antenna_0.n_pol_angles = 8;
antennacfg.antenna_0.n_E_eq_angles = 1;
antennacfg.antenna_0.polarization = 'linear';
antennacfg.antenna_0.frequencies = [33.0];
antennacfg.antenna_0.IRealTest = 0;
antennacfg.antenna_0.vacuum_window = false;

antennacfg.antenna_0.x_waist = 0.83;
antennacfg.antenna_0.y_waist = 0;
antennacfg.antenna_0.z_waist = 0;
antennacfg.antenna_0.waist_radius = 0.025;
antennacfg.antenna_0.fix_divergence = false;
antennacfg.antenna_0.fixed_divergence = 0;
antennacfg.antenna_0.gauss_assymetry = 0;
antennacfg.antenna_0.gauss_radius_enlargement = 1;
antennacfg.antenna_0.gauss_width = 1;

