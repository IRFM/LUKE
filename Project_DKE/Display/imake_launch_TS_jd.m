function launch = imake_launch_TS_jd(data,l_opt)
%
% This function takes the data from TCV data file or user input
% and creates the angles structure
%
if nargin < 2,
    l_opt = NaN;
end
%
if isnan(l_opt),
    l_opt = input('Select the launcher number? (1) top mirror - (2) central mirror : ');
end
%
if isempty(l_opt) || ~isnumeric(l_opt) || ~any(l_opt == 1:2),
    disp('-----> Invalid launcher selection.');
    return
end
%
freq = [118]*1e9;%EC frequency on TS
%
if ~isempty(data),
    %
    if l_opt == 1,
        %
        yR_L = data.EC.RA1;
        yZ_L = data.EC.ZA1;
        yphi_L = 0;
        %
        if data.EC.phiA1 > 0,
            yalpha_L = data.EC.phiA1*pi/180 - pi;
        else
            yalpha_L = data.EC.phiA1*pi/180 + pi;
        end
        %
        ybeta_L = pi/2 - data.EC.thetaA1*pi/180;
        %
        yP_L = data.EC.PA1;
        %
    else
        %
        yR_L = data.EC.RA2;
        yZ_L = data.EC.ZA2;
        yphi_L = 0;
        %
        if data.EC.phiA2 > 0,
            yalpha_L = data.EC.phiA2*pi/180 - pi;
        else
            yalpha_L = data.EC.phiA2*pi/180 + pi;
        end
        ybeta_L = pi/2 - data.EC.thetaA2*pi/180;
        %
        yP_L = data.EC.PA2;
        %
    end
    %
else
    %
    % TS launchers data
    %
    % The mirror position is fixed
    %
    yR_L = 3.5300;
    %
    if l_opt == 1,
        %
        yZ_L = 0.2000; %top mirror
        %
    else
        %
        yZ_L = 0; %central mirror
        %
    end
    %
    yphi_L = 0;
    %
    yalpha_L = input('provide the angle alpha (with R) [deg] (0 < alpha < 360) [180] : ');
    %
    if isempty(yalpha_L),
        yalpha_L = 180;
    end
    %
    if ~isnumeric(yalpha_L) || (yalpha_L < 0) || (yalpha_L > 360),
        disp('-----> Invalid angle alpha.');
        return
    end
    %
    if yalpha_L > 180,
        yalpha_L = yalpha_L - 360;
    end
    %
    yalpha_L = yalpha_L*pi/180;
    %
    ybeta_L = input('provide the angle beta (with Z) [deg] (0 < alpha < 180) [90] : ');
    %
    if isempty(ybeta_L),
        ybeta_L = 90;
    end
    %
    if ~isnumeric(ybeta_L) || (ybeta_L < 0) || (ybeta_L > 180),
        disp('-----> Invalid angle beta.');
        return
    end
    %
    ybeta_L = ybeta_L*pi/180;
    %
    yP_L = input('provide the beam power [MW] : ');
    %
    if isempty(yP_L) || ~isnumeric(yP_L),
        disp('-----> Invalid power.');
        return
    end
    %
    yP_L = yP_L*1e6;
    %
end
%
id = ['EC_L',num2str(l_opt)];
%
launch.id = id;
launch.yR_L = yR_L;
launch.yZ_L = yZ_L;
launch.yphi_L = yphi_L;
launch.yalpha_L = yalpha_L;
launch.ybeta_L = ybeta_L;
%
launch.omega_rf = freq*2*pi;
%
launch.yP_L = yP_L;
%


