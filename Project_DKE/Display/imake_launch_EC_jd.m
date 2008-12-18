function launch = imake_launch_EC_jd
%
% This function builts the launch structure for LH waves from user-specified data
%
launch.omega_rf = 2*pi*1e9*input_dke_yp('Wave frequency (GHz)',[],[0;Inf],'',[1,1]);
%
ny = input_dke_yp('Number of rays',1,1:20,'',[1,1]);  
%
launch.yZ_L = input_dke_yp('Vertical position of launching (m)',0*ones(1,ny),[-Inf;Inf],'',[1,ny]);  
launch.yR_L = input_dke_yp('Major radius position of launching \n  (enter ''NaN'' if launching from LCFS on LFS) (m)',NaN*ones(1,ny),[],'',[1,ny]);  
launch.yphi_L = pi/180*input_dke_yp('Toroidal position of launching (deg)',0*ones(1,ny),[-180;180],'',[1,ny]);  
launch.yalpha_L = pi/180*input_dke_yp('Horizontal launching angle (with respect to R axis) (deg)',180*ones(1,ny),[-180;180],'',[1,ny]);  
launch.ybeta_L = pi/180*input_dke_yp('Vertical launching angle (with respect to Z axis) (deg)',90*ones(1,ny),[0;180],'',[1,ny]);  
launch.yP_L = 1e6*input_dke_yp('Power in each ray (MW)\n  (scalar for total power uniform distributed)',1,[0;Inf],'',[1,1]);  
%
if length(launch.yP_L) == 1,
    launch.yP_L = launch.yP_L*ones(1,ny)/ny;
elseif any(size(launch.yP_L) ~= [1,ny]),
    error('Wrong dimension for power array')
end
%
if ny == 1,
    launch.w0 = input_dke_yp('Beam width (m)',[],[0;Inf],'',[1,1]);
end
%
launch.id = input_dke_yp('Provide an id for this launching structure','');
%
