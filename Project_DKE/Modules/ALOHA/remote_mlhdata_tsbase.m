function [data_lh] = remote_mlhdata_tsbase(port,shot,tmin,tmax,disp_mode)
%
%LUKE -  Function which load multiple LH signals from Tore Supra (or WEST) database for ALOHA power spectra calculations (output for upper and lower modules)
%        Output are averaged over time
%   Input:
%
%		port : Q6A, Q6B for single LH antenna or Q6A+Q6B for both  LH
%		shot : shot number
%       tmin : tmin (s) for signals averaging
%       tmax : tmax (s) for signals averaging
%       disp_mode : 1 -> display all signals, 0 -> no display
%
%   Output:
%
%       data_lh : all LH data in the structure (raw and averaged
%       quantities between tmin,tmax
%
%   Note: if shot number is less than 43540 antennas denominations are (C2,C3) otherwise (C3,C4) for Tore Supra or (LH1,LH2) for WEST (shot number larger than 50000 for WEST)
%   Warning : very old LH discharges with (C1,C2) antennas are not considered here.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 5
    disp_mode = 0;
end
%
data_lh = []; 
%
if strcmp(port,'Q6A')
    %
    ports = {port};
    %
    if shot < 43540
        antenna_names = {'C2'};
        aloha_architectures = {'antenne_C2'};
        machine_name = 'Tore Supra';
    elseif shot > 43540 && shot < 50000
        antenna_names = {'C3'};
        aloha_architectures = {'antenne_C3'};
        machine_name = 'Tore Supra';
    else
        antenna_names = {'LH1'};
        aloha_architectures = {'antenne_C3'};
        machine_name = 'WEST';
    end
    %
    type_signals = {'gpinjc1','gphic1','gcrefc1','gphrc1'};
    %
    data = remote_mtsbase(shot,type_signals);
    %
end
%
if strcmp(port,'Q6B')
    %
    ports = {port};
    %
    if shot < 43540
        antenna_names = {'C3'};
        aloha_architectures = {'antenne_C3'};
        machine_name = 'Tore Supra';
    elseif shot > 43540 && shot < 50000
        antenna_names = {'C4'};
        aloha_architectures = {'antenne_C4'};
        machine_name = 'Tore Supra';
    else
        antenna_names = {'LH2'};
        aloha_architectures = {'antenne_C4'};
        machine_name = 'WEST';
    end
    %
    type_signals = {'gpinjc2','gphic2','gcrefc2','gphrc2'};
    %
    data = remote_mtsbase(shot,type_signals);
    %
end
%
if strcmp(port,'Q6A+Q6B')
    %
    ports = {'Q6A','Q6B'};
    %
    if shot < 43540
        antenna_names = {'C2','C3'};
        aloha_architectures = {'antenne_C2','antenne_C3'};
        machine_name = 'Tore Supra';
    elseif shot > 43540 && shot < 50000
        antenna_names = {'C3','C4'};
        aloha_architectures = {'antenne_C3','antenne_C4'};
        machine_name = 'Tore Supra';
    else
        antenna_names = {'LH1','LH2'};
        aloha_architectures = {'antenne_C3','antenne_C4'};
        machine_name = 'WEST';
    end
    %
    type_signals = {'gpinjc1','gphic1','gcrefc1','gphrc1','gpinjc2','gphic2','gcrefc2','gphrc2'};
    %
    data = remote_mtsbase(shot,type_signals);
    %
end
%
if isfield(data,'err')
    disp(data.err);
    data_lh.err = data.err;
    return;
end
%
% Tore Supra / WEST antenna description
%
% Output structure for gpinjc1, gpinjc2,gphic1, gphic2, gcrefc1, gcrefc2 signals : [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
%
% Module numbering (Upper and Lower) from left to right (8 first indexes -> U) [1,3,5,7,9,11,13,15,2,4,6,8,10,12,14,16]
% ALOHA numbering (see ALOHA documentation) from right to left (8 first indexes -> U) -> [15 13 11 9 7 5 3 1 16 14 12 10 8 6 4 2]
%
% Upper row numbering : [1:8]
% Lower row numbering : [9:16];
%
% module #1 : [1H,1L] -> ALOHA : [15,16] 
% module #2 : [2H,2L] -> ALOHA : [13,14]
% module #3 : [3H,3L] -> ALOHA : [11,12]
% module #4 : [4H,4L] -> ALOHA : [9,10]
% module #5 : [5H,5L] -> ALOHA : [7,8]
% module #6 : [6H,6L] -> ALOHA : [5,6]
% module #7 : [7H,7L] -> ALOHA : [3,4]
% module #7 : [8H,8L] -> ALOHA : [1,2]
%
mask_modules = [1,3,5,7,9,11,13,15,2,4,6,8,10,12,14,16];
mask_aloha = [15 13 11 9 7 5 3 1 16 14 12 10 8 6 4 2];%module reordering (see ALOHA documentation)
%
mask_upper = [1:8];%upper row 
mask_lower = [9:16];%lower row 
%
for ii = 1:length(ports)
    %
    % Antenna loop
    %
    data_lh(ii).machine = machine_name;
    data_lh(ii).shot = shot;
    %
    data_lh(ii).port = ports{ii};
    data_lh(ii).antennas = antenna_names{ii};
    data_lh(ii).aloha_architectures = aloha_architectures{ii};
    %
    data_lh(ii).mask.modules = mask_modules;
    data_lh(ii).mask.aloha = mask_aloha;
    data_lh(ii).mask.upper = mask_upper;
    data_lh(ii).mask.lower = mask_lower;
    %
    for jj = 1:4
        %
        % Signal loop
        %
        kk = (ii-1)*4 + jj;
        %
        data_lh(ii).type_signal{jj}= type_signals{kk};
        %
        data_lh(ii).signal(jj).time = data(kk).yout2(data(kk).yout2(:,1) > 0,1);%keep only positive time
        data_lh(ii).signal(jj).raw = data(kk).yout1(data(kk).yout2(:,1) > 0,:);
        data_lh(ii).signal(jj).modules = data(kk).yout1(data(kk).yout2(:,1) > 0,data_lh(ii).mask.modules);
        data_lh(ii).signal(jj).aloha = data(kk).yout1(data(kk).yout2(:,1) > 0,data_lh(ii).mask.aloha);
        %
        data_lh(ii).mean.tmin = tmin;%time interval for mean calculations
        data_lh(ii).mean.tmax = tmax;%time interval for mean calculations
        %
        mean_signal_aloha = mean(data_lh(ii).signal(jj).aloha(data_lh(ii).signal(jj).time > data_lh(ii).mean.tmin & data_lh(ii).signal(jj).time < data_lh(ii).mean.tmax,data_lh(ii).mask.aloha));
        %
        if strfind(type_signals{kk},'gpinjc')
            %
            data_lh(ii).mean.power_mean_aloha_upper = mean_signal_aloha(data_lh(ii).mask.upper)';%kW
            data_lh(ii).mean.power_mean_aloha_lower = mean_signal_aloha(data_lh(ii).mask.lower)';%kW
            %
            data_lh(ii).mean.amplitude_mean_aloha_upper = sqrt(data_lh(ii).mean.power_mean_aloha_upper*1e3);%1e3 : kW -> W
            data_lh(ii).mean.amplitude_mean_aloha_lower = sqrt(data_lh(ii).mean.power_mean_aloha_lower*1e3);%1e3 : kW -> W
            %
        end
        %
        if strfind(type_signals{kk},'gphic')
            %
            data_lh(ii).mean.phase_mean_aloha_upper = pi/180*mean_signal_aloha(data_lh(ii).mask.upper)';%deg -> rad
            data_lh(ii).mean.phase_mean_aloha_lower = pi/180*mean_signal_aloha(data_lh(ii).mask.lower)';%deg -> rad 
            %
        end
        %
        if strfind(type_signals{kk},'gcrefc')
            %
            data_lh(ii).mean.rc_mean_aloha_upper = mean_signal_aloha(data_lh(ii).mask.upper)';
            data_lh(ii).mean.rc_mean_aloha_lower = mean_signal_aloha(data_lh(ii).mask.lower)'; 
            %
        end
        %
        if strfind(type_signals{kk},'gphrc')
            %
            data_lh(ii).mean.phase_rc_mean_aloha_upper = mean_signal_aloha(data_lh(ii).mask.upper)';
            data_lh(ii).mean.phase_rc_mean_aloha_lower = mean_signal_aloha(data_lh(ii).mask.lower)'; 
            %
        end
    end
end
%
if disp_mode
    display_lhdata(data_lh,[]);
end


