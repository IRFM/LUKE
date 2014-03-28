function launch = imake_launch_KSTAR_jd(external,opt_gui,style)
%
% This function creates a launch structure based on the launched angles and
% posision in KSTAR.
%
launch = struct;
%
launch.type = 'EC';
%
if ~isempty(external),
    %
    % TODO (see for example imake_launch_EAST_jd)
    %
else
    %
    l_opt = iselect_jd({'110 GHz','170 GHz'},'Specify launcher',opt_gui,style,1);%{'84 GHz','110 GHz','140 GHz','170 GHz'}
    %
    if l_opt == 1,% 110 GHz
        %
        launch.id = '110GHz';
        %
        launch.omega_rf = 2*pi*1e9*(110);
        %
        launch.yP_L = 1e6*(0.3);
        %
        launch.yZ_L = -0.252;  
        launch.yR_L = 2.8;  
        launch.yphi_L = pi/180*(0);  
        %
        launch.yalpha_L = pi/180*(180);  
        launch.ybeta_L = pi/180*(90);
        %
        launch.w0 = 0.02; 
        launch.z0 = 0;% flat mirror
        %
    elseif l_opt == 2,% 170 GHz
        %
        launch.id = '170GHz';
        %
        launch.omega_rf = 2*pi*1e9*(170);
        %
        launch.yP_L = 1e6*(0.8);
        %
        launch.yZ_L = -0.252;  
        launch.yR_L = 2.8;  
        launch.yphi_L = pi/180*(0);  
        %
        launch.yalpha_L = pi/180*(180);  
        launch.ybeta_L = pi/180*(90);
        %
        launch.w0 = 0.02; 
        launch.z0 = 0;% flat mirror
        %
    end
    %
    launch.dNpar0 = NaN;%Calculated from waist and focal point
    %
end
%