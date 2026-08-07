% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [antenna] = make_aloha_EAST_yp(aloha,antenna_measured)
%
optim.tolfun = 1e-2;% tolerance on targets
optim.tolx = 1e-2;% tolerance on inputs
optim.nitmax = 30;%
%
if size(aloha.power_in_modules,2) == 4, % 2.45 GHZ antenna
    sc = EAST_ALOHA_scenario_2dot45GHz;    
elseif size(aloha.power_in_modules,2) == 6, % 4.60 GHZ antenna
    sc = EAST_ALOHA_scenario_4dot60GHz;
else
    error('Wrong definition of EAST LH antenna')
end
%
%
% Calculate the coupling (ie the plasma impedance). Once the plasma impedance is calculated, because of the underlying linearity,
% we can change the antenna excitation (power, phasing) to determine RC and power spectrum for a specific excitation. (J. Hillairet)
%
sc.antenna.a_ampl = sqrt(aloha.power_in_modules*1000);%power is given in kW form external (first row is considered for coupling calculations)
sc.antenna.a_phase = pi*aloha.module_phasing/180;
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
    %
    if size(aloha.power_in_modules,1) > 1,% all rows are considered
        if size(aloha.power_in_modules) == size(antenna_measured.rc)
            rc = antenna_measured.rc;
        else
            if size(antenna_measured.rc,1) == 1 || size(antenna_measured.rc,2) == 1
                rc = ones(size(aloha.power_in_modules,1),1)*antenna_measured.rc(:)';
                if size(aloha.power_in_modules) ~= size(rc)
                    error('Measured RC coefficients data for EAST LH antenna are inconsistent');
                end
            else
                error('Measured RC coefficients data for EAST LH antenna are inconsistent');
            end
        end
    else
        rc = antenna_measured.rc;            
    end
    %
    optim.tolfun = input_dke_yp('Termination tolerance on the function value ? ',optim.tolfun,'','',[1,1]);
    optim.tolx = input_dke_yp('Termination tolerance on x ? ',optim.tolx,'','',[1,1]);
    optim.nitmax = input_dke_yp('Maximum number of iterations allowed ? ',optim.nitmax,'','',[1,1]);
    init_ne = input_dke_yp('Initial density (low density side (1e17 m-3) or high density side (5e18 m-3) ? ',1e17,'','',[1,1]);%to be far from a possible minimum in RC as finction of ne
    %
    sc.plasma.ne0 = init_ne;
    %
elseif calcspectrum_opt == 2,
    edge_ne = input_dke_yp('Edge density in front of the antenna ? ',1e18,'','',[1,1]);
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
if ~isfield(antenna,'job')
    %
    if size(aloha.power_in_modules,1) > 1
        %
        RC{1} = antenna.aloha.results.RC;
        dP_nz{1} = antenna.aloha.results.dP_nz;
        %
        for ii=2:size(aloha.power_in_modules,1)
            %
            antenna.aloha.antenna.a_ampl = sqrt(aloha.power_in_modules(ii,:)*1000)';%power is given in kW form external (first row is considered for coupling calculations)
            antenna.aloha.antenna.a_phase = pi*aloha.module_phasing(ii,:)'/180;
            %
            antenna.aloha = aloha_compute_RC(antenna.aloha); % update RC coefficients
            antenna.aloha = aloha_compute_spectrum(antenna.aloha);% update power spectrum coefficients
            %
            RC{ii} = antenna.aloha.results.RC;
            dP_nz{ii} = antenna.aloha.results.dP_nz;
            %
        end
    end 
    %
    antenna.aloha.results.RC = RC;
    antenna.aloha.results.dP_nz = dP_nz;
    %
end




