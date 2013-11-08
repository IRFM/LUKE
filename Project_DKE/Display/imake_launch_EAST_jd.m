function launch = imake_launch_EAST_jd(external,opt_gui,style)
%
% This function creates a launch structure based on the launched angles and
% posision in TCV.
%
launch = struct;
%
launch.type = 'EC';
%
if ~isempty(external),
    %
    launch.id = external.id;
    %
    launch.omega_rf = 2*pi*1e9*external.frequency.fec;
    launch.yP_L = 1e6*external.total_launched_power.power;
    %
    launch.yZ_L = external.position.Z;  
    launch.yR_L = external.position.R;  
    launch.yphi_L = pi/180*external.position.phi;  
    %
    launch.yalpha_L = pi/180*external.position.alpha;
    launch.ybeta_L = pi/180*external.position.beta;
    %
    launch.w0 = external.position.beam_width; 
    launch.z0 = external.position.length_focus; 
    %
    launch.dNpar0 = NaN;%Calculated from waist and focal point
    %
    if strcmp(external.position.polarization,'X'),
        launch.mmode = 1;% Polarization : (1) m (-1) p, (O/X mode: -1/+1),
    else
        launch.mmode = -1;
    end
    %
    launch.external = external;
    %
else
    %
    l_opt = iselect_jd({'140 GHz','170 GHz'},'Specify launcher',opt_gui,style,1);
    %
    if l_opt == 1,% 140 GHz
        %
        launch.id = 'mirror_140GHz';
        %
        launch.omega_rf = 2*pi*1e9*(140);
        %
        launch.yP_L = 1e6*(1);
        %
        launch.yZ_L = 0.3;  
        launch.yR_L = 3;  
        launch.yphi_L = pi/180*(0);  
        %
        launch.yalpha_L = pi/180*(-160);  
        launch.ybeta_L = pi/180*(110);
        %
        launch.w0 = 0.0136; 
        launch.z0 = 0.0940; 
        %
    else
        %
        launch.id = 'mirror_170GHz';
        %
        launch.omega_rf = 2*pi*1e9*(170);
        %
        launch.yP_L = 1e6*(1);
        %
        launch.yZ_L = 0.3;  
        launch.yR_L = 3;  
        launch.yphi_L = pi/180*(0);  
        %
        launch.yalpha_L = pi/180*(-160);  
        launch.ybeta_L = pi/180*(110);
        %
        launch.w0 = 0.0136; 
        launch.z0 = 0.0940; 
        %
    end
    %
    launch.dNpar0 = NaN;%Calculated from waist and focal point
    %
end
%