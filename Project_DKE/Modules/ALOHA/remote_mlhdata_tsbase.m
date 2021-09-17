function [data_lh] = remote_mlhdata_tsbase(machine,port,shot,tmin,tmax,disp_mode)
%
%LUKE -  Function which load multiple LH signals from Tore Supra (or WEST) database for ALOHA power spectra calculations (output for upper and lower modules)
%        Output are averaged over time
%   Input:
%
%       machine : tokamak name
%		port : Q6A, Q6B for single LH antenna or Q6A+Q6B for both  LH
%		shot : shot number
%       tmin : tmin (s) for signals averaging
%       tmax : tmax (s) for signals averaging
%       disp_mode : 1 -> display all signals, 0 -> no display
%
%   Output:
%
%       data_lh : all LH data in the structure (raw and averaged quantities between tmin,tmax)
%
%   Note: if shot number is less than 43540 antennas denominations are (C2,C3) otherwise (C3,C4) for Tore Supra or (LH1,LH2) for WEST (shot number larger than 50000 for WEST)
%   Warning : very old LH discharges with (C1,C2) antennas are not considered here.
%
% Example #1 : data_lh = remote_mlhdata_tsbase('Q6A',27503,4.5,5.0,1);
% Example #2 : data_lh = remote_mlhdata_tsbase('Q6A+Q6B',28014,5.5,6.5,1);
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 6
    disp_mode = 0;
end
%
data_lh = []; 
%
data_lh.type = 'LH';%type of wave : Lower Hybrid
%
if shot < 27395 % (TS), Ip anti-clockwise, Bt clock-wise
    %
    antenna_names_Q6A = {'C1'};
    antenna_frequencies_Q6A = 3.7e9;%Hz
    row_z_positions_Q6A = [-0.152,-0.072,0.072,0.152];
    aloha_architectures_Q6A = {'antenne_C1'};%for ALOHA
    machine_name_Q6A = 'TS';
    probes_name_Q6A = {'GNLG1%1','GNLG1%2','GNLG1%3','GNLG1%4'};
    %
    antenna_names_Q6B = {'C2'};
    antenna_frequencies_Q6B = 3.7e9;%Hz
    row_z_positions_Q6B = [-0.152,-0.072,0.072,0.152];
    aloha_architectures_Q6B = {'antenne_C2'};%for ALOHA
    machine_name_Q6B = 'TS';
    probes_name_Q6B = {'GNLG2%1','GNLG2%2','GNLG2%3','GNLG2%4'}; 
    %
elseif shot >= 27395 && shot < 29000 % start date 08/09/1999 (TS), Ip anti-clockwise, Bt clock-wise
    %
    antenna_names_Q6A = {'C2'};
    antenna_frequencies_Q6A = 3.7e9;%Hz
    row_z_positions_Q6A = [-0.152,-0.072,0.072,0.152];
    aloha_architectures_Q6A = {'antenne_C2'};%for ALOHA
    machine_name_Q6A = 'TS';
    probes_name_Q6A = {'GNLG1%1','GNLG1%2','GNLG1%3','GNLG1%4'}; 
    %
    antenna_names_Q6B = {'C3'};
    antenna_frequencies_Q6B = 3.7e9;%Hz
    row_z_positions_Q6B = [-0.24,-0.16,-0.08,0.08,0.16,0.24];
    aloha_architectures_Q6B = {'antenne_C3'};%for ALOHA
    machine_name_Q6B = 'TS';
    probes_name_Q6B = {'GNLG2%1','GNLG2%2','GNLG2%3','GNLG2%4'};
    %
elseif shot >= 29000 && shot < 43540 % start date 27/11/2001 (TS CIEL), Ip clockwise, Bt clock-wise (coupler turned around for co-current drive)
    %
    antenna_names_Q6A = {'C2'};
    antenna_frequencies_Q6A = 3.7e9;%Hz
    row_z_positions_Q6A = [-0.152,-0.072,0.072,0.152];
    aloha_architectures_Q6A = {'antenne_C2'};
    machine_name_Q6A = 'TS';
    probes_name_Q6A = {'GNLG1%1','GNLG1%2','GNLG1%3','GNLG1%4'}; 
    %
    antenna_names_Q6B = {'C3'};
    antenna_frequencies_Q6B = 3.7e9;%Hz
    row_z_positions_Q6B = [-0.24,-0.16,-0.08,0.08,0.16,0.24];
    aloha_architectures_Q6B = {'antenne_C3'};%for ALOHA
    machine_name_Q6B = 'TS';
    probes_name_Q6B = {'GNLG2%1','GNLG2%2','GNLG2%3','GNLG2%4'};
    %
elseif shot >= 43540 && shot < 50000 % start date 29/09/2009 (TS CIEL), Ip clockwise, Bt clock-wise
    %
    antenna_names_Q6A = {'C3'};
    antenna_frequencies_Q6A = 3.7e9;%Hz
    row_z_positions_Q6A = [-0.24,-0.16,-0.08,0.08,0.16,0.24];
    aloha_architectures_Q6A = {'antenne_C3'};%for ALOHA
    machine_name_Q6A = 'TS';
    probes_name_Q6A = {'GNLG1%1','GNLG1%2','GNLG1%3','GNLG1%4'};
    %
    antenna_names_Q6B = {'C4'};
    antenna_frequencies_Q6B = 3.7e9;%Hz
    row_z_positions_Q6B = [-0.2480,-0.160,-0.0720,0.0720,0.160,0.2480];
    aloha_architectures_Q6B = {'antenne_C4'};%for ALOHA
    machine_name_Q6B = 'TS';
    probes_name_Q6B = {'GNLG2%1','GNLG2%2','GNLG2%3','GNLG2%4'};
    %
elseif shot >= 50000 % start date 12/12/2016 (WEST), Ip clockwise, Bt clock-wise
    %
    antenna_names_Q6A = {'LH1'};
    antenna_frequencies_Q6A = 3.7e9;%Hz
    row_z_positions_Q6A = [-0.24,-0.16,-0.08,0.08,0.16,0.24];
    aloha_architectures_Q6A = {'antenne_C3'};%for ALOHA
    machine_name_Q6A = 'WEST';
    probes_name_Q6A = {'GISLH%1','GISLH%2','GISLH%3','GISLH%4'};
    %
    antenna_names_Q6B = {'LH2'};
    antenna_frequencies_Q6B = 3.7e9;%Hz
    row_z_positions_Q6B = [-0.2480,-0.160,-0.0720,0.0720,0.160,0.2480];
    aloha_architectures_Q6B = {'antenne_C4'};%for ALOHA
    machine_name_Q6B = 'WEST';
    probes_name_Q6B = {'GISLH%5','GISLH%6','GISLH%7','GISLH%8'};
    %
end
%
type_signals_Q6A = {'gpinjc1','gphic1','gcrefc1','gphrc1'};
type_signals_Q6B = {'gpinjc2','gphic2','gcrefc2','gphrc2'};
%
if strcmp(port,'Q6A')
    %
    ports = {port};
    %
    antenna_names = antenna_names_Q6A;
    antenna_frequencies = antenna_frequencies_Q6A;
    row_z_positions = {row_z_positions_Q6A};
    aloha_architectures = aloha_architectures_Q6A;
    machine_name = machine_name_Q6A;
    probes_name = probes_name_Q6A;
    type_signals = type_signals_Q6A;
    %
elseif strcmp(port,'Q6B')
    %
    ports = {port};
    %
    antenna_names = antenna_names_Q6B;
    antenna_frequencies = antenna_frequencies_Q6B;
    row_z_positions = {row_z_positions_Q6B};
    aloha_architectures = aloha_architectures_Q6B;
    machine_name = machine_name_Q6B;
    probes_name = probes_name_Q6B;
    type_signals = type_signals_Q6B;
    %    
elseif strcmp(port,'Q6A+Q6B')
    %
    ports = {'Q6A','Q6B'};
    %
    antenna_names = [antenna_names_Q6A,antenna_names_Q6B];
    antenna_frequencies = [antenna_frequencies_Q6A,antenna_frequencies_Q6B];
    row_z_positions = {row_z_positions_Q6A,row_z_positions_Q6B};
    aloha_architectures = [aloha_architectures_Q6A,aloha_architectures_Q6B];
    machine_name = machine_name_Q6A;
    probes_name = [probes_name_Q6A,probes_name_Q6B];
    type_signals = [type_signals_Q6A,type_signals_Q6B];
    %
end
%
if ~strcmp(machine_name,machine)
    disp('ERROR : machine and shot number are inconsistent.')
    disp('Tore Supra : shot number < 50000')
    disp('WEST : shot number >= 50000')
    return
end
%
alldata = remote_mtsbase(shot,[type_signals,probes_name]);%get all TS or WEST experiental data
%
data = alldata(1:length(type_signals));
probes = alldata(length(type_signals)+1:end);
%
if ~exist('ports','var')
    disp(['ERROR : port definition is wrong. Should be Q6A, Q6B or Q6A+Q6B. It is ',port,'.'])
    return;
end
%
if exist('data','var') && isfield(data,'err')
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
mask_raw = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
mask_modules = [1,3,5,7,9,11,13,15,2,4,6,8,10,12,14,16];
mask_aloha = [15 13 11 9 7 5 3 1 16 14 12 10 8 6 4 2];%module reordering (see ALOHA documentation)
%
mask_upper = [1:8];%upper row 
mask_lower = [9:16];%lower row 
%
% Density probes in front of the antenna
%
% Tore Supra ne (m-3) (for shot < 43540, only three probes per antenna and shot > 43540, 4 probes per antenna
%
% - GNLG1%1 : top left (C2) C3 (view from inside)
% - GNLG1%2 : top right (C2) C3 (view from inside)
% - GNLG1%3 : bottom left (C2) C3 (view from inside)
% - GNLG1%4 : bottom right (C2) C3 (view from inside)
%
% - GNLG2%1 : top left (C3) C4 (view from inside)
% - GNLG2%2 : top right (C3) C4 (view from inside)
% - GNLG2%3 : bottom left (C3) C4 (view from inside)
% - GNLG2%4 : bottom right (C3) C4 (view from inside)
%
% WEST (saturation current -> density : ne (m-3) = 1.29*10^18*GISLH%x/sqrt(Te)/A, where A(mm2) = probe surface = 19.6 and Te(eV) = 9eV by default
%
% - GISLH%1 : top left LH1 (view from inside)
% - GISLH%2 : top right LH1 (view from inside)
% - GISLH%3 : bottom left LH1 (view from inside)
% - GISLH%4 : bottom right LH1 (view from inside)
%
% - GISLH%5 : top left LH2 (view from inside)
% - GISLH%6 : top right LH2 (view from inside)
% - GISLH%7 : bottom left LH2 (view from inside)
% - GISLH%8 : bottom right LH2 (view from inside)
%
facprobe = 1.29e18/sqrt(9)/19.6;%ne (m-3) = 1.29*10^18*GISLH%x/sqrt(Te)/A, where A(mm2) = probe surface = 19.6 and Te(eV) = 9eV
%
for ii = 1:length(ports)
    %
    % Antenna loop
    %
    data_lh(ii).machine = machine_name;
    data_lh(ii).shot = shot;
    %
    data_lh(ii).port = ports{ii};
    data_lh(ii).antenna = antenna_names{ii};
    data_lh(ii).antenna_frequency = antenna_frequencies(ii);
    data_lh(ii).rows_z_positions = row_z_positions{ii};
    data_lh(ii).aloha_architecture = aloha_architectures{ii};
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
        if ~isempty(probes(kk).yout2)
            %
            data_lh(ii).probe(jj).time = probes(kk).yout2(probes(kk).yout2(:,1) > 0,1);%keep only positive time
            %
            if strcmp(machine_name,'Tore Supra')
                %
                data_lh(ii).probe(jj).ne = probes(kk).yout1(probes(kk).yout2(:,1) > 0,1);
                %
            else
                %
                data_lh(ii).probe(jj).raw = probes(kk).yout1(probes(kk).yout2(:,1) > 0,1);
                data_lh(ii).probe(jj).ne = data_lh(ii).probe(jj).raw*facprobe;%saturation current to density
                %
            end
        end
        %
        data_lh(ii).mean.tmin = tmin;%time interval for mean calculations
        data_lh(ii).mean.tmax = tmax;%time interval for mean calculations
        %
        mean_signal_aloha = mean(data_lh(ii).signal(jj).aloha(data_lh(ii).signal(jj).time > data_lh(ii).mean.tmin & data_lh(ii).signal(jj).time < data_lh(ii).mean.tmax,:),1);        
        %
        if ~isempty(probes(kk).yout2)
            mean_probe = mean(data_lh(ii).probe(jj).ne(data_lh(ii).probe(jj).time > data_lh(ii).mean.tmin & data_lh(ii).probe(jj).time < data_lh(ii).mean.tmax));
        end
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
        %
        if exist('mean_probe','var')
            data_lh(ii).mean.probe(jj) = mean_probe;
        end
        %
    end
end
%
display_lhdata(data_lh,disp_mode);



