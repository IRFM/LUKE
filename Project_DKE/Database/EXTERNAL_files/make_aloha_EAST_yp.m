function [antenna] = make_aloha_EAST_yp(aloha,antenna_measured)
%
optim.tolfun = 1e-2;% tolerance on targets
optim.tolx = 1e-2;% tolerance on inputs
optim.nitmax = 20;%
%
if length(aloha.power_in_modules) == 4, % 2.45 GHZ antenna
    sc = EAST_ALOHA_scenario_2dot45GHz;    
elseif length(aloha.power_in_modules) == 6, % 4.60 GHZ antenna
    sc = EAST_ALOHA_scenario_4dot60GHz;
else
    error('Wrong definition of EAST LH antenna')
end
%
sc.antenna.a_ampl = sqrt(aloha.power_in_modules(:)*1000);%power is given in kW form external
sc.antenna.a_phase = pi*aloha.module_phasing(:)/180;
%
if isfield(antenna_measured,'edge_ne') & isfield(antenna_measured,'rc')
    calcspectrum_opt = input_dke_yp('Calculation of the ALOHA power spectrum from edge density [0] or reflection coefficient [1] in external structure or from manual data input [2] ? ',0,0:2,'',[1,1]);
elseif isfield(antenna_measured,'edge_ne') & ~isfield(antenna_measured,'rc')
    calcspectrum_opt = input_dke_yp('Calculation of the ALOHA power spectrum from edge density [0] in external structure or from manual data input [1] ? ',0,0:1,'',[1,1]);
    if calcspectrum_opt == 1,
        calcspectrum_opt = 2;
    end
elseif ~isfield(antenna_measured,'edge_ne') & isfield(antenna_measured,'rc')
    calcspectrum_opt = input_dke_yp('Calculation of the ALOHA power spectrum from reflection coefficient [0] in external structure or from manual data input [1] ? ',0,0:1,'',[1,1]);
    if calcspectrum_opt == 1,
        calcspectrum_opt = 2;
    end
elseif ~isfield(antenna_measured,'edge_ne') & ~isfield(antenna_measured,'rc')
    calcspectrum_opt = 2;
end
%
if calcspectrum_opt == 0,
    edge_ne = antenna_measured.edge_ne;
    rc = '';
elseif calcspectrum_opt == 1,
    edge_ne = '';
    rc = antenna_measured.rc;
    %
    optim.tolfun = input_dke_yp('Termination tolerance on the function value ? ',optim.tolfun,'','',[1,1]);
    optim.tolx = input_dke_yp('Termination tolerance on x ? ',optim.tolx,'','',[1,1]);
    optim.nitmax = input_dke_yp('Maximum number of iterations allowed ? ',optim.nitmax,'','',[1,1]);
    %
elseif calcspectrum_opt == 2,
    edge_ne = input_dke_yp('Edge density in front of the antenna ? ',1e17,'','',[1,1]);
    rc = '';
end
%
opt_gui = false;
select.style = struct;
%
dkepath = load_structures_yp('dkepath','','');
%
scheduler.remnum = iselect_jd(dkepath.remprofiles,'Remote calculation mode (mdce_remote): ',opt_gui,select.style,1)-1;
if scheduler.remnum == 0,%local distribution
    flag_mdce = 1:length(dkepath.distprofiles);% all mdce modes
else
    flag_mdce = 1:3;% remcomputing within mdce_remote disabled
end        
%
scheduler.mode = iselect_jd(dkepath.distprofiles(flag_mdce),'Distributed computing mode : ',opt_gui,select.style,1) - 1;
%
if scheduler.mode > 2,
   scheduler.mode = 2 - scheduler.mode;
end
%
antenna = build_aloha_power_spectrum_yp(sc,edge_ne,rc,optim,dkepath,scheduler);
%


