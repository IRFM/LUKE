function launch = main_launch_toray_jd(filename,omega_rf,P0,method);
%
% This function creates the launch structure based on TORAY input file "filename"
%
% OUTPUTS:
%
%   -structure launch:
%       - omega_rf : wave angular frequency (rad/s)
%       - yR_L : major radius position of launching (m)
%       - yZ_L : vertical position of launching (m)
%       - yphi_L : toroidal angle position of launching (rad), (R,Z,phi) right handed
%       - yalpha_L : horizontal angle with respect to R (rad)
%       - ybeta_L : vertical angle with respect to Z (rad) 
%       - yP_L : power launched in the ray (W)
%
% by J. Decker (RLE/MIT) <jodecker@mit.edu> and Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
if nargin < 4,
    method = 1;
end
%
launch.omega_rf = omega_rf;
%
if method == 1,
    %
    % method 1
    %
    [ny] = textread(filename,'%n',1);
    [yX_L,yY_L,yZ_L,ybeta_L,yalpha_L] = textread(filename,'%n%n%n%n%n',ny+1);
    %
    yX_L = yX_L(2:ny+1).'; 
    yY_L = yY_L(2:ny+1).';
    yZ_L = yZ_L(2:ny+1).';
    ybeta_L = ybeta_L(2:ny+1).';
    yalpha_L = yalpha_L(2:ny+1).';
    %
else
    %
    % method 2
    %
    fid = fopen(filename);
    ny = fscanf(fid,'%d',1);
    for iray = 1:ny,
        raydata = fscanf(fid,'%f',5);
        yX_L(iray) = raydata(1);
        yY_L(iray) = raydata(2);
        yZ_L(iray) = raydata(3);
        ybeta_L(iray) = raydata(4);
        yalpha_L(iray) = raydata(5);
    end
    fclose(fid);
end
%
% normalization
%
yalpha_L(yalpha_L <= -180) = yalpha_L(yalpha_L <= -180) + 2*180;
yalpha_L(yalpha_L > 180) = yalpha_L(yalpha_L > 180) - 2*180;
%
yX_L = yX_L/1e2;% toroidal X position (cm -> m)
yY_L = yY_L/1e2;% toroidal Y position (cm -> m)
yZ_L = yZ_L/1e2;% toroidal Z position (cm -> m)
ybeta_L = ybeta_L*pi/180;% vertical angle with respect to Z (deg -> rad)
yalpha_L = yalpha_L*pi/180;% horizontal angle with respect to R (deg -> rad)
%
yR_L = sqrt(yX_L.^2 + yY_L.^2);
yX_L(yX_L == 0) = eps;
yphi_L = atan(yY_L./yX_L) + pi*(yX_L < 0 & yY_L > 0) - pi*(yX_L < 0 & yY_L < 0);
%
launch.yR_L = yR_L;
launch.yZ_L = yZ_L;
launch.yphi_L = yphi_L;
launch.yalpha_L = yalpha_L;
launch.ybeta_L = ybeta_L;
%
launch.yP_L = P0/ny*ones(1,ny);
%




