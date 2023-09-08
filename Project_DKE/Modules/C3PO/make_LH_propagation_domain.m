%
clear all
close all
%
machine = 'WEST';%tokamak name 'PBX-M', 'TRIAM-1M', 'HL-2A', 'ITER', 'TS','WEST','EAST','CMOD'
%
ray = '';
%
nparmax = 20;
resolution = 0;%low resolution (fast calculations): 0, high resolution (slow calculations): 0
%
% PBX-M (ref pao94)
%
if strcmp(machine,'PBX-M')
    %
    npar0 = 2.4;
    omega_rf = 4.6e9*2*pi;%angular frequency (rad/s)
    load('EQUIL_PBXM_B1p53_Ip117_nl1p425_Te0p7_q00p8.mat');
    %
elseif strcmp(machine,'EAST')
    %
    omega_rf = 4.6e9*2*pi;%angular frequency (rad/s)
    npar0 = 1.8;
    load('EQUIL_EAST_060041_005100.mat');
    %
elseif strcmp(machine,'CMOD')
    %
    omega_rf = 4.6e9*2*pi;%angular frequency (rad/s)
    npar0 = 1.55;
    load('EQUIL_CMOD_1101104011_01220.mat');
    %
elseif strcmp(machine,'ITER')
    %
    omega_rf = 5e9*2*pi;%angular frequency (rad/s)
    npar0 = 1.8;
    load('EQUIL_ITER_Scen4.mat');
    %
elseif strcmp(machine,'WEST')
    %
    omega_rf = 3.7e9*2*pi;%angular frequency (rad/s)
    npar0 = 2.0;
    load('EQUIL_WEST_55539_3.9369.mat');
    %load('EQUIL_WEST_54952_4.44_4.55_1_METIS_LH_ALOHA_10L_#1.mat');
    %equil = equil{1};
    %
    %load('/Users/yves/Travail/Projets/LUKE_Simulations/WEST/WEST_55878/SLUKE_EQUILS/EQUIL_WEST_55878_8_9_1_LH_flat-top_ALOHA_+_TAIL_2L_PSCREENING_TPB_ripple_#6.mat');
    %load('/Users/yves/Travail/Projets/LUKE_Simulations/WEST/WEST_55080/SLUKE_EQUILS/EQUIL_WEST_55080_8_9_1_LH_flat-top_ALOHA_+_TAIL_2L_PSCREENING_TPB_ripple_#6.mat');
    %equil = equil{1};
    %
    %
    %load('EQUIL_WEST_55878_8_9_1_LH_flat-top_ALOHA_+_TAIL_2L_PSCREENING_TPB_ripple_#6');
    %equil = equil{1};
    %
    %load('LUKE_DATA_WEST_55539_9.9369_ADAS_C3PO_LH_EPAR.mat')
    %ray = waves{1}.rays{1};
    %load('LUKE_DATA_WEST_54952_4.3339_ADAS_CLXP_SCRE_C3PO_LH.mat');
    %ray = waves{1}.rays{1};
    %load('LUKE_DATA_WEST_54952_4.3339_ADAS_Tx1p3_ADAS_CLXP_SCRE_C3PO_C3_npar2.mat')
    %ray = waves{1}.rays{1};
    %
    %
    %npar0 = 1.99;
    %load('EQUIL_WEST_54952_4.4339s_NICE.mat');
    %
    %equil = correct_equil_yp(equil,{'pTe','pzTi'});
    %
elseif strcmp(machine,'TS')
    %
    omega_rf = 3.7e9*2*pi;%angular frequency (rad/s)
    npar0 = 2.0;
    load('EQUIL_TS_32299_100.1733.mat');
    %
elseif strcmp(machine,'TRIAM-1M')
    %
    omega_rf = 2.45e9*2*pi;%angular frequency (rad/s)
    phase = 110;%waveguide phasing 70,90, 110,130,150
    %npar0 = 1.96;
    %load('EQUIL_TRIAM_B5_Ip27_nl20_Te11_q01.mat');
    %{
    load(['LUKE_DATA_TRIAM_B5_Ip27_nl20_Te11_C3PO_dphi_',num2str(phase),'_P_23kW_TAIL_st_ct_Nmax_0_n_5_P_0.5_opt_0+1i_TAIL_st_ct_Nmax_0_n_5_P_0.5_opt_0+1i_TAIL_st_ct_Nmax_0_n_5_P_0.5_opt_0+1i_EM01.mat'])
    ray = waves{1}.rays{1};
    %
    load(['LUKE_DATA_TRIAM_B5_Ip27_nl20_Te11_Rp013_ADAS_C3PO_dphi_110_P_23kW_TAIL_st_ct_Nmax_0_n_5_P_0.5_opt_0+1i_TAIL_st_ct_Nmax_0_n_5_P_0.5_opt_0+1i_TAIL_st_ct_Nmax_0_n_5_P_0.5_opt_0+1i.mat'])
    equil = rmfield(equil,'ADAS');
    ray = waves{1}.rays{1};
    %
    load('EQUIL_TRIAM_B5_Ip27_nl82_Te11.mat');
    npar0 = 1.96;
    %}
    load('EQUIL_TRIAM_B5_Ip500_nl20_Te11.mat');
    npar0 = 1.96;
    %
elseif strcmp(machine,'HL-2A')
    %
    omega_rf = 3.7e9*2*pi;%angular frequency (rad/s)
    %
    load('/Volumes/Triolet/Simulations/HL2A_35261/HL2A_35261.00800/LUKE_DATA_HL2A_035261_00800_CYL_ADAS_C3PO_antenna_3p70Ghz_n2p95.mat');
    equil = rmfield(equil,'ADAS');
   % equil = rmfield(equil,'coulog');
    %equil = rmfield(equil,'screening');
    %
    ray = waves{1}.rays{1};
    %
    %npar0 = 1.6;
    %load('/Volumes/Triolet/Simulations/HL2A_35261/HL2A_35261.00800/EQUIL_HL2A_035261_00800_CYL.mat')
else
    disp(['The machine ',machine,' is not recognized']);
    return
end
%
disp(['Tokamak : ',machine])
%
if ~isempty(ray)
    disp(['N||0 (from ray) = ',num2str(abs(real(ray.sNpar(1))))]);
    npar0 = abs(real(ray.sNpar(1)));
else
    disp(['N||0 = ',num2str(npar0)]);
end
%
[na,gamma_KAM_exact,gamma_KAM_approximate,open_upperboundaries_propagationdomain,intersection,Npar_gap_min,R_kinematic_gap_min] = LH_acces_yp(equil,omega_rf,ray,npar0,nparmax,resolution);
%
    