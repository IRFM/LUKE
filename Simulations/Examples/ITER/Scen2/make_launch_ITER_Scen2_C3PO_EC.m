% script make_wavestruct_Scen2_C3PO_EC
%
clear all
clear mex
clear functions
close all
warning('off','all')
pause(1)
%
% *********************** Specify LUKE structures *****************************
%
locid_launch = '';%launch local ID
path_launch = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%
% LAUNCH parameters
%
id = 'NTM_32';
freq_GHz = 170;
%
R_L = 6.4848;
Z_L = 4.110;
P_L = 20;% [MW] 
%
cone_div = 1.08;% equivalent exp(-2) power cone divergence
cone_ori = -0.5;% equivalent cone origin
%
z_L = 0.35;% focal point
%
alpha_prater = -63.5;% angle between N_P and horizontal plane
beta_prater = 22;% angle between N and poloidal plane
%
ns = 1000;
method = 'cubic';
%
%************************************************************************************************************************************
%
[dkepath] = load_structures_yp('dkepath',id_dkepath,path_dkepath);
%
% launch structure
%
launch.id = [id,locid_launch];
launch.type = 'EC';
launch.omega_rf = [freq_GHz]*2*pi*1e9;%wave angular frequency (rad/s)
%
launch.yR_L = R_L;
launch.yZ_L = Z_L;
launch.yphi_L = 0;
launch.yalpha_L = sign(beta_prater)*pi - atan(tand(beta_prater)/cosd(alpha_prater));
launch.ybeta_L = acos(cosd(beta_prater)*sind(alpha_prater));
launch.yP_L = P_L*1e6;
launch.dNpar0 = NaN;
launch.ns = ns;
launch.method = method;
%
launch.w0 = 0.3/(freq_GHz*pi*cone_div*pi/180);
launch.z_L = z_L;
%
%************************************************************************************************************************************
%
filename = ['LAUNCH_',launch.id,'.mat'];
%
save([path_launch,filename],'launch');
%
