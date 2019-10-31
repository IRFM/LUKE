function  [flag,LH_out] = load_LH_tsbase_yp(basestr,shotnum,shotime,tmin,tmax)
%
%   Load Lower Hybrid experimental data of the tokamak Tore Supra for ALOHA simulations and power spectrum calculations
%
%   Antenna structure (16 modules): 
%
%   15-13-11-09-07-05-03-01 (top row of 3 waveguides in the poloidal direction)
%   16-14-12-10-08-06-04-02 (bottom row of 3 waveguides in the poloidal direction)
% 
%ALOHA_ondemand (Q6A,Q6B -> t1-t2)
%

%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr)
%
method = 'spline';
flag = 1;
%
if nargin < 4,
    tmin = shotime;
end
%
if nargin < 5,
     tmax = shotime;
end
%
if strcmp(basestr,'TS') || strcmp(basestr,'WEST'),
	%
    certif = 0;%default certification
	shotnum = shotnum + certif/10;  
	%
	% Load LH power and phase
	%    
    % TODO : C1 and C2 for the first period of Tore Supra
    %
    if round(shotnum) <= 43540
        %
        LH_in.antenna1 = 'C2';%Tore Supra: C2 Q6A
        LH_in.antenna2 = 'C3';%Tore Supra: C3 Q6B 
        %
    elseif round(shotnum) > 43540 & round(shotnum) <= 50000,%Tore Supra: C3 Q6A, C4 Q6B
        %
        LH_in.antenna1 = 'C3';%Tore Supra: C3 Q6A
        LH_in.antenna2 = 'C4';%Tore Supra: C4 Q6B
        %
    elseif round(shotnum) > 50000
        LH_in.antenna1 = 'LH1';%WEST: LH1 Q6A
        LH_in.antenna2 = 'LH2';%WEST: LH2 Q6B
    end
    %   
    [shotdate,LH_in.phyb1,LH_in.t_phyb1] = remote_tsbase(shotnum,'GPHYB%1');%LH power from C2 antenna (MW)
    [shotdate,LH_in.phyb2,LH_in.t_phyb2] = remote_tsbase(shotnum,'GPHYB%2');%LH power from C2 antenna (MW)
    %
    [shotdate,LH_in.gpinjc1m,LH_in.t_gpinjc1m] = remote_tsbase(shotnum,'GPINJC1');%Mean LH phasing from antenna 1 (deg)
    [shotdate,LH_in.gpinjc2m,LH_in.t_gpinjc2m] = remote_tsbase(shotnum,'GPINJC2');%Mean LH phasing from antenna 2 (deg)
    %
    [shotdate,LH_in.meanphaselh1,LH_in.t_meanphaselh1] = remote_tsbase(shotnum,'GPHASHYB%1');%Mean LH phasing from antenna 1 (deg)
    [shotdate,LH_in.meanphaselh2,LH_in.t_meanphaselh2] = remote_tsbase(shotnum,'GPHASHYB%2');%Mean LH phasing from antenna 2 (deg)
    %
    [shotdate,LH_in.phaselh1m,LH_in.t_phaselh1m] = remote_tsbase(shotnum,'GPHIC1');%Raw incident LH phasing from antenna 1 for all modules (deg)
    [shotdate,LH_in.phaselh2m,LH_in.t_phaselh2m] = remote_tsbase(shotnum,'GPHIC2');%Raw incident LH phasing from antenna 2 for all modules (deg)
    %
    [shotdate,LH_in.rclh1m,LH_in.t_rclh1m] = remote_tsbase(shotnum,'GCREFC1');%Reflection coefficients from antenna 1 for all modules (%)
    [shotdate,LH_in.rclh2m,LH_in.t_rclh2m] = remote_tsbase(shotnum,'GCREFC2');%Reflection coefficients from antenna 2 for all modules (%)
    %
    if round(shotnum) > 50000
        [shotdate,LH_in.plhf1m,LH_in.t_plhf1m] = remote_tsbase(shotnum,'GPFORWC1');LH_in.plhf1m = LH_in.plhf1m /1000;%Forward LH power from antenna 1 for all modules (MW)
        [shotdate,LH_in.plhf2m,LH_in.t_plhf1m] = remote_tsbase(shotnum,'GPFORWC2');LH_in.plhf2m = LH_in.plhf2m/1000;%Forward LH power from antenna 2 for all modules (MW)
        %
        [shotdate,LH_in.plhb1m,LH_in.t_plhb1m] = remote_tsbase(shotnum,'GPREFLC1');LH_in.plhb1m = LH_in.plhb1m/1000;%Backward LH power from antenna 1 for all modules (MW)
        [shotdate,LH_in.plhb2m,LH_in.t_plhb2m] = remote_tsbase(shotnum,'GPREFLC2');LH_in.plhb2m = LH_in.plhb2m/1000;%Backward LH power from antenna 2 for all modules (MW)
    end
    %
    [shotdate,LH_in.nlg1,LH_in.t_nlg1] = remote_tsbase(shotnum,'GNLG1');%Density in front of the antenna 1
    [shotdate,LH_in.nlg2,LH_in.t_nlg2] = remote_tsbase(shotnum,'GNLG2');%Density in front of the antenna 2
    [shotdate,LH_in.islh,LH_in.t_islh] = remote_tsbase(shotnum,'GISLH');%saturation current from the density probes near the antennas 1 and 2
    %
    LH_out.in = LH_in;
    %
    LH_out.phyb1 = interp_tprof_time_fxdrg(LH_in.t_phyb1,LH_in.phyb1,shotime,tmin,tmax,method);%Time interpolation
    LH_out.phyb2 = interp_tprof_time_fxdrg(LH_in.t_phyb2,LH_in.phyb2,shotime,tmin,tmax,method);%Time interpolation
    % 
    LH_out.pinjc1m = interp_tprof_time_fxdrg(LH_in.t_gpinjc1m,LH_in.gpinjc1m,shotime,tmin,tmax,method);%Time interpolation
    LH_out.pinjc2m = interp_tprof_time_fxdrg(LH_in.t_gpinjc2m,LH_in.gpinjc2m,shotime,tmin,tmax,method);%Time interpolation
    %
    LH_out.meanphaselh1 = interp_tprof_time_fxdrg(LH_in.t_meanphaselh1,LH_in.meanphaselh1,shotime,tmin,tmax,method);%Time interpolation
    LH_out.meanphaselh2 = interp_tprof_time_fxdrg(LH_in.t_meanphaselh2,LH_in.meanphaselh2,shotime,tmin,tmax,method);%Time interpolation
    %
    LH_out.phaselh1m = interp_tprof_time_fxdrg(LH_in.t_phaselh1m,LH_in.phaselh1m,shotime,tmin,tmax,method);%Time interpolation
    LH_out.phaselh2m = interp_tprof_time_fxdrg(LH_in.t_phaselh2m,LH_in.phaselh2m,shotime,tmin,tmax,method);%Time interpolation
    %
    LH_out.rclh1m = interp_tprof_time_fxdrg(LH_in.t_rclh1m,LH_in.rclh1m,shotime,tmin,tmax,method);%Time interpolation
    LH_out.rclh2m = interp_tprof_time_fxdrg(LH_in.t_rclh2m,LH_in.rclh2m,shotime,tmin,tmax,method);%Time interpolation
    %
    if round(shotnum) > 50000
        LH_out.plhf1m = interp_tprof_time_fxdrg(LH_in.t_plhf1m,LH_in.plhf1m,shotime,tmin,tmax,method);%Time interpolation
        LH_out.plhf2m = interp_tprof_time_fxdrg(LH_in.t_plhf2m,LH_in.plhf2m,shotime,tmin,tmax,method);%Time interpolation
        %
        LH_out.plhb1m = interp_tprof_time_fxdrg(LH_in.t_plhb1m,LH_in.plhb1m,shotime,tmin,tmax,method);%Time interpolation
        LH_out.plhb2m = interp_tprof_time_fxdrg(LH_in.t_plhb2m,LH_in.plhb2m,shotime,tmin,tmax,method);%Time interpolation
    end
    %
    LH_out.nlg1 = interp_tprof_time_fxdrg(LH_in.t_nlg1,LH_in.nlg1,shotime,tmin,tmax,method);%Time interpolation
    LH_out.nlg2 = interp_tprof_time_fxdrg(LH_in.t_nlg2,LH_in.nlg2,shotime,tmin,tmax,method);%Time interpolation
    LH_out.islh = interp_tprof_time_fxdrg(LH_in.t_islh,LH_in.islh,shotime,tmin,tmax,method);%Time interpolation
    %
    % for ALOHA simulations
    %
    LH_out.antenna_measured_1.rc = [LH_out.rclh1m([15,13,11,9,7,3,1]);LH_out.rclh1m([16,14,10,8,6,4,2])];
    LH_out.antenna_measured_2.rc = [LH_out.rclh2m([15,13,11,9,7,3,1]);LH_out.rclh2m([16,14,10,8,6,4,2])];
    %
    LH_out.antenna_measured_1.edge_ne = LH_out.nlg1;%%TODO: put measured signal%%
    LH_out.antenna_measured_2.edge_ne = LH_out.nlg2;%%TODO%%
    %
    LH_out.antenna_measured_1.edge_ne_isat = 1.29*10^18*LH_out.islh(1:4)/sqrt(10)/19.6;
    LH_out.antenna_measured_2.edge_ne_isat = 1.29*10^18*LH_out.islh(5:8)/sqrt(10)/19.6;
    %
    LH_out.aloha_1.power_in_modules = [LH_out.pinjc1m([15,13,11,9,7,3,1]);LH_out.pinjc1m([16,14,10,8,6,4,2])];
    LH_out.aloha_2.power_in_modules = [LH_out.pinjc2m([15,13,11,9,7,3,1]);LH_out.pinjc2m([16,14,10,8,6,4,2])];
    LH_out.aloha_1.module_phasing = [LH_out.phaselh1m([15,13,11,9,7,3,1]);LH_out.phaselh1m([16,14,10,8,6,4,2])];
    LH_out.aloha_2.module_phasing = [LH_out.phaselh2m([15,13,11,9,7,3,1]);LH_out.phaselh2m([16,14,10,8,6,4,2])];
    %
    LH_out.frequency_1.flh = 3.7;
    LH_out.frequency_1.unit = 'GHz';
    LH_out.frequency_2.flh = 3.7;
    LH_out.frequency_2.unit = 'GHz';
    %
    LH_out.position_1.R = [];
    LH_out.position_1.Z = [0.241,0.159,0.077,-0.077,-0.159,-0.241];
    LH_out.position_1.unit = 'm';
    LH_out.position_2.R = [];
    LH_out.position_2.Z = [0.241,0.159,0.077,-0.077,-0.159,-0.241];
    LH_out.position_2.unit = 'm';
    %
else
    error('ERROR: load_LH_tsbase_yp.m matlab function is restricted to Tore Supra and WEST tokamaks');
end

    