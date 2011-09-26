function [waves,wavestructs,wavestructs_fluct_out,Nfluct] = wave_distribution_yp(dkepath,dkeparam,wavestructs,wavestructs_fluct_in,f0struct,mksa,itn,Pnonabs_ray)
%
% Split the M rays in each wavestructs into N*M rays with P/N power for averaging the effect of plasma fluctuations on ray propagation (C3PO code
% only). Use parallel processing for reducing the overall computational time
%
% INPUT
%    - dkepath structure
%    - dkeparam structure
%    - wavestructs structure
%    - wavestructs_in structure (modified by run_lukert)
%    - f0struct structure
%    - mksa structure
%    - itn: time step index [1,1]
%       (default = 1)
%    - Pnonabs_ray: Remaining rf power in the ray after the QL selfconsistency loop, units in linear power density not absorbed P/(2*pi*Rp) [1,nrays]
%
% OUTPUT:
%    - waves structure
%    - wavestructs structure (the last one is output since the phase has changed and corresponds to dkeparam.dtn !)
%    - wavestructs_out structure (modified for run_lukert)
%    - Nfluct: number of rays when dnt_fluct < dtn) [1,1]
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 6,
    error('Wrong number of input arguments in wave_distribution_yp.m.');
end
%
if nargin < 6,
    itn = 1;
end
%
flag_core_fluct = 0;
flag_edge_fluct = 0;
%
if isfield(wavestructs{1}.equil_fit,'fluct_fit'),
    %
    fluct_fit = wavestructs{1}.equil_fit.fluct_fit;
    %
    field_name = fieldnames(fluct_fit);
    %
    model = [];
    epsi_rho = [];
    epsi_theta = [];
    epsi_phi = [];
    %
    test_field_name_ne = strfind(field_name,'ne_fit');%test existence of density fluctuation
    test_field_name_B = strfind(field_name,'B_fit');%test existence of magnetic field fluctuation
    %
    for i = 1:length(field_name),
        if ~isempty(test_field_name_ne{i}) || ~isempty(test_field_name_B{i}), flag_core_fluct = 1;end
    end
    %
    if flag_core_fluct,
        for i = 1:length(field_name),
            if isstruct(fluct_fit.(char(field_name(i)))) && (strcmp(char(field_name(i)),'B_fit') || strcmp(char(field_name(i)),'ne_fit'))
                for ifield = 1:length(fluct_fit.(char(field_name(i)))),
                        model = [model,fluct_fit.(char(field_name(i)))(ifield).model];
                    if fluct_fit.(char(field_name(i)))(ifield).model == 1,
                        error('Fluctuation model ''1'' is not implemented in wave_distribution_yp.m (ray tracing benchmark only). Check the function that builds the fluct structure.'); 
                    elseif fluct_fit.(char(field_name(i)))(ifield).model == 2,
                        epsi_rho = [epsi_rho,fluct_fit.(char(field_name(i)))(ifield).epsi_rho];
                        epsi_theta = [epsi_theta,fluct_fit.(char(field_name(i)))(ifield).epsi_theta]; 
                        epsi_phi = [epsi_phi,fluct_fit.(char(field_name(i)))(ifield).epsi_phi]; 
                    elseif fluct_fit.(char(field_name(i)))(ifield).model == 3,
                        epsi_rho = [epsi_rho,fluct_fit.(char(field_name(i)))(ifield).epsi_rho];
                        epsi_theta = [epsi_theta,fluct_fit.(char(field_name(i)))(ifield).epsi_theta];
                    elseif fluct_fit.(char(field_name(i)))(ifield).model == 4 || fluct_fit.(char(field_name(i)))(ifield).model == 5,
                        epsi_theta = [epsi_theta,fluct_fit.(char(field_name(i)))(ifield).epsi_theta];
                    else
                        error('Fluctuation model >=6 not implemented in wave_distribution_yp.m, check the function.');
                    end
                end
            end
        end
        %
        if exist('epsi_rho'),
            dtn_rho = 2.14*mksa.nhu_ref*max(epsi_rho)/mksa.vde_ref;%See the documentation on plasma fluctuations for the coefficient 2.14 
        else
            dtn_rho = Inf;
        end
        if exist('epsi_theta'),
            dtn_theta = 2.14*mksa.nhu_ref*max(epsi_theta)/mksa.vde_ref;
        else
            dtn_theta = Inf;
        end
        if exist('epsi_phi'),
            dtn_phi = 2.14*mksa.nhu_ref*max(epsi_phi)/mksa.vde_ref;
        else
            dtn_phi = Inf;
        end
        %
        dtn_fluct_core = min([dtn_rho,dtn_theta,dtn_phi]);
        %
        Nfluct_core = max(round(dkeparam.dtn/dtn_fluct_core),1);%Number of rays when dtn_fluct < dtn
        itn_core = max(round(dtn_fluct_core/dkeparam.dtn),1);
        %
        disp(['Nfluct_core = ',int2str(Nfluct_core)]);
    else
        disp('No plasma fluctuations');
        Nfluct_core = 1; 
        itn_core = 1;
        dtn_fluct_core = Inf;
    end
    %
    flag_LH = 0;%check that LH wave is in one of the wavestruct
    %
    for iw = 1:length(wavestructs),
        if strcmp(wavestructs{iw}.launch.type,'LH'),
            flag_LH = 1;
        end
    end    
    %
    if isfield(fluct_fit,'edge') & flag_LH,
        %
        flag_edge_fluct = 1;
        %
        if isfield(fluct_fit.edge,'dtn'),
            %
            Nfluct_edge = max(round(dkeparam.dtn/fluct_fit.edge.dtn),1);%Number of rays when dtn_fluct < dtn
            dtn_fluct_edge = fluct_fit.edge.dtn;
            itn_edge = max(round(fluct_fit.edge.dtn/dkeparam.dtn),1);
            disp(['Nfluct_edge = ',int2str(Nfluct_edge)]);
            %
        else
            flag_edge_fluct = 0;
            disp('No fluctuations of the launched LH power spectrum');
            Nfluct_edge = 1;
            dtn_fluct_edge = Inf;
            itn_edge = 1;
        end
    else
        flag_edge_fluct = 0;
        disp('No fluctuations of the launched LH power spectrum');
        Nfluct_edge = 1;
        itn_edge = 1;
        dtn_fluct_edge = Inf;
    end
    %
    Nfluct = max(Nfluct_core,Nfluct_edge);
    dtn_fluct = min(dtn_fluct_core,dtn_fluct_edge);
    %
    if isempty(wavestructs_fluct_in),%first time step
        %
        wavestructs_fluct_out = cell(1,Nfluct);        
        %
        for ifluct = 1:Nfluct,
            %
            wavestructs_fluct_out{ifluct} = wavestructs;%For parallel processing and recursive time evolution            
            %
            if flag_core_fluct,%core fluctuations
                fluct_fit = fluctphase_yp(wavestructs_fluct_out{ifluct}{1}.equil_fit.fluct_fit);%For calculations with new random phase (core fluctuations). Edge fluctuations are done in main_rayinit_launch_jd.m
            end
            %
            for iws = 1:length(wavestructs_fluct_out{ifluct}),
                if flag_core_fluct,%core fluctuations (if any)
                    wavestructs_fluct_out{ifluct}{iws}.equil_fit.fluct_fit = fluct_fit;%Replicate the same fluctuation structure to all wavestructs (core fluctuations)
                end
                %
                if flag_edge_fluct,%edge fluctuations (if any)
                    wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge.flag = 1;
                else
                    wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge.flag = 0;  
                end
                %
                if isfield(wavestructs_fluct_out{ifluct}{iws}.launch,'bPlhtot'),%LH wave
                    wavestructs_fluct_out{ifluct}{iws}.launch.bPlhtot = wavestructs{iws}.launch.bPlhtot/Nfluct;%Total launched LH power is constant (sensitive to core and edge fluctuations)
                end
                %
                if isfield(wavestructs_fluct_out{ifluct}{iws}.launch,'yP_L'),%EC wave
                    wavestructs_fluct_out{ifluct}{iws}.launch.yP_L = wavestructs{iws}.launch.yP_L/Nfluct;%Total launched EC power is constant (sensitive to core fluctuations only)
                end
                %
                if ~isinf(dtn_fluct),
                    wavestructs_fluct_out{ifluct}{iws}.rayparam.tfinal = dtn_fluct*wavestructs_fluct_out{ifluct}{iws}.launch.omega_rf/mksa.nhu_ref;%ray tracing duration cannot exceed the fluctuation correlation time (x 2.3 approximately)
                end
                %
            end
        end
    else
        %
        wavestructs_fluct_out = wavestructs_fluct_in;%for recursive time evolution
        %
        for ifluct = 1:Nfluct,
            %
            if rem(itn,itn_core) == 0 && rem(ifluct,Nfluct_core) == 0 && flag_core_fluct,%refresh the phase on the dtn_fluct_core time scale
                fluct_fit = fluctphase_yp(wavestructs_fluct_out{ifluct}{1}.equil_fit.fluct_fit);%For calculations with new random phase (core fluctuations). Edge fluctuations are done in main_rayinit_launch_jd.m
            end
            %
            for iws = 1:length(wavestructs),
                wavestructs_fluct_out{ifluct}{iws}.equil_fit.fluct_fit = fluct_fit;%Replicate the same fluctuation structure to all wavestructs (core fluctuations)
                %
                if strcmp(wavestructs_fluct_out{ifluct}{iws}.launch.type,'LH') && flag_edge_fluct,
                    if rem(itn,itn_edge) == 0 && rem(ifluct,Nfluct_edge) == 0,
                        wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge.flag = 1;
                        rmfield(wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge,'Npar0');%in this case, the Npar0 is randomly chosen at next time step
                    else
                        wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge.flag = 0;
                        wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge.Npar0 = wavestructs_fluct_in{ifluct}{iws}.equil.fluct.edge.Npar0;%Npar0 is maintained at next time step (
                    end
                end
            end               
            %
        end          
    end      
else
    Nfluct = 1;
    dtn_fluct = Inf;
    wavestructs_fluct_out{1} = wavestructs;
    disp('No fluctuations.');
end
%
Ptot_inj_th = 0;
%
for iw = 1:length(wavestructs),
    if isfield(wavestructs{iw}.launch,'bPlhtot'),
        Ptot_inj_th = Ptot_inj_th + sum(wavestructs{iw}.launch.bPlhtot)/1e6;%LH power injected (MW)
    elseif isfield(wavestructs{iw}.launch,'yP_L'),
        Ptot_inj_th = Ptot_inj_th + sum(wavestructs{iw}.launch.yP_L)/1e6;%EC power injected (MW)
    end
end
%
Ptot_inj_old = 0;
Ptot_inj_new = 0;
%
iwave = 1;
%
if (flag_core_fluct | flag_edge_fluct),
    for ifluct = 1:Nfluct,
        for iws = 1:length(wavestructs),
            if isfield(wavestructs{iw}.launch,'bPlhtot'),%LH wave
                %
                for irays = 1:length(wavestructs{iws}.launch.bPlhtot),
                    Ptot_inj_old = Ptot_inj_old + wavestructs_fluct_out{ifluct}{iws}.launch.bPlhtot(irays);
                    %
                    if ~isempty(Pnonabs_ray),%for itn > 1 only
                        wavestructs_fluct_out{ifluct}{iws}.launch.bPlhtot(irays) = wavestructs{iws}.launch.bPlhtot(irays)/Nfluct + Pnonabs_ray(iwave)*2*pi*wavestructs{1}.equil.Rp;%Total launched LH power is constant (sensitive to core and edge fluctuations)
                    end
                    %
                    Ptot_inj_new = Ptot_inj_new + wavestructs_fluct_out{ifluct}{iws}.launch.bPlhtot(irays);
                %
                    iwave = iwave + 1;
                end
            end
            %
            if isfield(wavestructs{iw}.launch,'yP_L'),%EC wave
                %
                for irays = 1:length(wavestructs{iws}.launch.yP_L),%LH wave
                    Ptot_inj_old = Ptot_inj_old + wavestructs_fluct_out{ifluct}{iws}.launch.yP_L(irays);
                    %
                    if ~isempty(Pnonabs_ray),%for itn > 1 only
                        wavestructs_fluct_out{ifluct}{iws}.launch.yP_L(irays) = wavestructs{iws}.launch.yP_L(irays)/Nfluct + Pnonabs_ray(iwave)*2*pi*wavestructs{1}.equil.Rp;%Total launched LH power is constant (sensitive to core and edge fluctuations)
                    end
                    %
                    Ptot_inj_new = Ptot_inj_new + wavestructs_fluct_out{ifluct}{iws}.launch.yP_L(irays);
                %
                    iwave = iwave + 1;
                end
            end  
        end
    end 
end
%
disp(['---> Injected rf power : ',num2str(Ptot_inj_th),' (MW)']);
disp(['---> Injected rf power @ itn = ',int2str(itn),' : ',num2str(Ptot_inj_old/1e6),' (MW)']);
disp(['---> Injected rf power @ itn = ',int2str(itn+1),' : ',num2str(Ptot_inj_new/1e6),' (MW)']);
disp(['---> Power ratio = ',num2str(Ptot_inj_new/Ptot_inj_old)]);
%
if isfield(dkeparam,'clustermode'),
    if isfield(dkeparam.clustermode,'wave_random_yp'),dkecluster = dkeparam.clustermode.wave_random_yp;end
end
%
[dummy,waves] = mdce_luke(@wave_random_yp,{dkepath,dkeparam,wavestructs,f0struct},3,wavestructs_fluct_out,dkecluster);
%
% to keep memory of the initial Npar0 from ray tracing (edge fluctuations for the LH wave only) for the next time step, depending upon dtn_fluct
%
if (flag_core_fluct || flag_edge_fluct) && flag_LH,
    for ifluct = 1:Nfluct,
        for iws = 1:length(wavestructs),
            %
            iwave = iws + length(wavestructs)*(ifluct - 1);
            Npar0 = [];
            %
            for iray = 1:length(waves{iwave}.rays),
                Npar0 = [Npar0,waves{iwave}.rays{iray}.sNpar(1)];
            end
            %
            if isfield(wavestructs_fluct_out{ifluct}{iws}.launch,'bPlhtot'),%LH wave only 
                wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge.Npar0 = real(Npar0);
            end
            %
        end
    end  
end


