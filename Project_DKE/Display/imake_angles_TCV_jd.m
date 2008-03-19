function angles = imake_angles_TCV_jd(data,shotnum),
%
% This function takes the data from TCV data file and creates the angles
% structure
%
angles = '';
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
% TCV launchers data
%
% L1_P1_R = 1.3072;
% L1_P1_Z = 0.0537; %!!!!! -0.0587 ???
% L1_P1_theta = 52.013*pi/180; % = 0.9078
% L1_P2_R = 1.1906;
% L1_P2_Z = -0.0695; %!!!!! 0.0645 ???
% L1_P2_d = 0.01; %mirror thickness
% L1_P3_Z = -0.0025;
%
% L3_P1_R = 1.3072;
% L3_P1_Z = 0.5087; %!!!!! 0.3988 ???
% L3_P1_theta = 52.013*pi/180; % = 0.9078
% L3_P2_R = 1.1906;
% L3_P2_Z = 0.3855; %!!!!! 0.5220 ???
% L3_P2_d = 0.01; %mirror thickness
% L3_P3_Z = 0.4525; %!!!!! 0.4550 ???
%


