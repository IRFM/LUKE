function angles = imake_angles_TCV_jd(data,shotnum),
%
% This function takes the data from TCV data file or user input
% and creates the angles structure
%
angles = '';
%
if ~isempty(data),
    %
    ishot = find(data.shot == str2num(shotnum));
    %
    if isempty(ishot),
        disp(['-----> launching data not found for shot :',shotnum]);
        return
    end
    %
    if length(ishot) > 1,
        disp(['-----> WARNING : Several entries are found for shot :',shotnum,', first entry selected']);
        ishot = ishot(1);
    end
    %
    launch_list = data.laun;
    %
    l_opt = input(['Launcher? (',num2str(launch_list),') : ']);
    if isempty(l_opt) | ~isnumeric(l_opt) | ~any(l_opt == launch_list),
        disp('-----> Invalid launcher selection');
        return
    end
    %
    eval(['angles_i = data.angles_',num2str(l_opt),'(ishot);'])
    %
    if ~strcmp(shotnum,angles_i.id),
        disp('-----> Shot number mismatch. Verify data file');
        return
    end
    %
    % if l_opt == 1,
    %     w_opt_g = 1;%bottom launcher is 2nd harmonic by default
    % elseif l_opt == 2,
    %     w_opt_g = 1;%middle launcher is 2nd harmonic by default
    % elseif l_opt == 3,
    %     w_opt_g = 2;%top launcher is 3nd harmonic by default
    % end
    %
    % w_opt = input(['Wave Frequency? 1 (82.7 GHz), 2 (118 GHz) [',num2str(w_opt_g),']: ']);
    % if isempty(w_opt) 
    %     w_opt = w_opt_g;
    % end
    % if ~isnumeric(w_opt) | ~any(w_opt == [1,2]),
    %     disp('-----> Invalid frequency selection');
    %     return
    % elseif w_opt == 1,
    %     freq = 82.7e9;
    %     id = 'H2';
    % elseif w_opt == 2,
    %     freq = 118e9;    
    %     id = 'H3';
    % end
    %
    freq = input(['Confirm wave frequency (GHz)? [',num2str(angles_i.freq/1e9),']: '])*1e9;
    if isempty(freq) 
        freq = angles_i.freq;
    end
    %
    if freq ~= angles_i.freq,
        disp(['-----> WARNING: frequency has been changed from ',num2str(angles_i.freq/1e9),' GHZ to ',num2str(freq/1e9),' GHZ']);
        angles_i.freq = freq;
    end
    %
    id = ['L',num2str(l_opt)];
    %
    angles.freq = angles_i.freq;
    angles.P0 = angles_i.P0;
    angles.P1_R = angles_i.P1_R;
    angles.P1_theta = angles_i.P1_theta;
    angles.P2_R = angles_i.P2_R;
    angles.P2_d = angles_i.P2_d;
    %angles.P1_Z = 2*angles_i.P3_Z - angles_i.P1_Z;
    %angles.P2_Z = 2*angles_i.P3_Z - angles_i.P2_Z;
    angles.P1_Z = angles_i.P1_Z;
    angles.P2_Z = angles_i.P2_Z;
    angles.P3_Z = angles_i.P3_Z;
    angles.P3_tor = angles_i.P3_tor;
    %
    angles.theta = angles_i.theta;%(end) temporary, wait for bug to be fixed
    angles.phi = angles_i.phi;%(end) temporary, wait for bug to be fixed
    angles.theta_eff = angles_i.theta_eff;%(end) temporary, wait for bug to be fixed
    angles.phi_eff = angles_i.phi_eff;
    %
    angles.id = id;
    %
else
    %
    l_opt = input(['Select the launcher number? (1-6) : ']);
    if isempty(l_opt) || ~isnumeric(l_opt) || ~any(l_opt == [1:6]),
        disp('-----> Invalid launcher selection.');
        return
    end
    %
    % TCV launchers data
    %
    if any(l_opt == [1,4]),
        %
        P1_R = 1.30723;
        P1_Z = -0.05865;
        P1_theta = 52.013*pi/180; % = 0.9078
        P2_R = 1.19056;
        P2_Z = 0.0645;
        P2_d = 0.01; %mirror thickness
        P3_Z = -0.0025;
        %
    elseif any(l_opt == [2,3,5,6]),
        %
        P1_R = 1.30723;
        P1_Z = 0.39885;
        P1_theta = 52.013*pi/180; % = 0.9078
        P2_R = 1.1906;
        P2_Z = 0.5220;
        P2_d = 0.01; %mirror thickness
        P3_Z = 0.4550;
        %
    end
    %
    l_data = input([ 'Please confirm/specify the launcher characteristics ',...
                    '\n (press ''enter'' if OK of specify data vector)',... 
                    '\n[P1_R,P1_Z,P1_theta,P2_R,P2_Z,P2_d,P3_Z] = [',...
                    num2str(P1_R),',',num2str(P1_Z),',',num2str(P1_theta),',',...
                    num2str(P2_R),',',num2str(P2_Z),',',num2str(P2_d),',',num2str(P3_Z),'] : ']);
    %
    if ~isempty(l_data),
        if ~isnumeric(l_data) || length(l_data ~= 7),
            disp('-----> Invalid launcher data.');
            return
        end
        %
        P1_R = l_data(1);
        P1_Z = l_data(2);
        P1_theta = l_data(3);
        P2_R = l_data(4);
        P2_Z = l_data(5);
        P2_d = l_data(6);
        P3_Z = l_data(7);
        %
    end
    %
    theta = input('Specify mirror angle theta (degrees)? [0]: ')*pi/180;
    if isempty(theta) 
        theta = 0;
    end
    if ~isnumeric(theta),
        disp('-----> Invalid angle specification.');
        return
    end
    %
    phi = input('Specify llauncher angle phi (degrees)? [0]: ')*pi/180;
    if isempty(phi) 
        phi = 0;
    end
    if ~isnumeric(phi),
        disp('-----> Invalid angle specification.');
        return
    end
    %
    freq = input('Specify wave frequency (GHz)? [82.7]: ')*1e9;
    if isempty(freq) 
        freq = 82.7e9;
    end
    if ~isnumeric(freq),
        disp('-----> Invalid frequency specification.');
        return
    end
    %
    P0 = input('Specify wave power (kW)? [500]: ')*1e3;
    if isempty(P0) 
        P0 = 500e3;
    end
    if ~isnumeric(P0),
        disp('-----> Invalid power specification.');
        return
    end
    %
    id = ['L',num2str(l_opt)];
    %
    angles.freq = freq;
    angles.P0 = P0;
    %
    angles.P1_R = P1_R;
    angles.P1_theta = P1_theta;
    angles.P2_R = P2_R;
    angles.P2_d = P2_d;
    angles.P1_Z = P1_Z;
    angles.P2_Z = P2_Z;
    angles.P3_Z = P3_Z;
    %
    angles.theta = theta;%(end) temporary, wait for bug to be fixed
    angles.phi = phi;%(end) temporary, wait for bug to be fixed
    %
    angles.id = id;
    %
end
%


