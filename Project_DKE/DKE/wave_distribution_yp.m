function [waves,wavestructs,wavestructs_fluct_out] = wave_distribution_yp(dkepath,dkeparam,wavestructs,wavestructs_fluct_in,f0struct,mksa,itn,Pnonabs_ray)
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
Nfluct = max([1,round(dkeparam.Nfluct)]);
%
if isfield(wavestructs{1}.equil_fit,'fluct_fit'),
    %
    if isempty(wavestructs_fluct_in),%first time step
        %
        wavestructs_fluct_out = cell(1,Nfluct);        
        %
        for ifluct = 1:Nfluct,
            %
            wavestructs_fluct_out{ifluct} = wavestructs;%For parallel processing and recursive time evolution            
            %
            fluct_fit = fluctphase_yp(wavestructs_fluct_out{ifluct}{1}.equil_fit.fluct_fit);%For calculations with new random phase (core fluctuations). Edge fluctuations are done in main_rayinit_launch_jd.m
            %
            for iws = 1:length(wavestructs_fluct_out{ifluct}),
                %
                wavestructs_fluct_out{ifluct}{iws}.equil_fit.fluct_fit = fluct_fit;%Replicate the same fluctuation structure to all wavestructs (core fluctuations)
                %
                if isfield(fluct_fit,'edge'),%edge fluctuations (if any)
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
                if ~isinf(fluct_fit.dtn_fluct),
                    wavestructs_fluct_out{ifluct}{iws}.rayparam.tfinal = fluct_fit.dtn_fluct*wavestructs_fluct_out{ifluct}{iws}.launch.omega_rf/mksa.nhu_ref;%ray tracing duration cannot exceed the fluctuation correlation time (x 2.3 approximately)
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
            %if rem(itn,itn_core) == 0 && rem(ifluct,Nfluct_core) == 0 && flag_core_fluct,%refresh the phase on the dtn_fluct_core time scale
                fluct_fit = fluctphase_yp(wavestructs_fluct_out{ifluct}{1}.equil_fit.fluct_fit);%For calculations with new random phase (core fluctuations). Edge fluctuations are done in main_rayinit_launch_jd.m
            %end
            %
            for iws = 1:length(wavestructs),
                wavestructs_fluct_out{ifluct}{iws}.equil_fit.fluct_fit = fluct_fit;%Replicate the same fluctuation structure to all wavestructs (core fluctuations)
                %
                if strcmp(wavestructs_fluct_out{ifluct}{iws}.launch.type,'LH') && flag_edge_fluct,
                    %if rem(itn,itn_edge) == 0 && rem(ifluct,Nfluct_edge) == 0,
                        wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge.flag = 1;
                        rmfield(wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge,'Npar0');%in this case, the Npar0 is randomly chosen at next time step
                    %else
                    %    wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge.flag = 0;
                    %    wavestructs_fluct_out{ifluct}{iws}.equil.fluct.edge.Npar0 = wavestructs_fluct_in{ifluct}{iws}.equil.fluct.edge.Npar0;%Npar0 is maintained at next time step (
                    %end
                end
            end               
            %
        end          
    end      
else
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
if isfield(wavestructs{1}.equil_fit,'fluct_fit'),
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
if isfield(dkeparam,'clustermode') && isfield(dkeparam.clustermode,'wave_solver_yp'),
    dkecluster = dkeparam.clustermode.wave_solver_yp;
else
    dkecluster = [];
end
%
[dummy,waves] = mdce_luke(@wave_solver_yp,{dkepath,'',f0struct},2,wavestructs,dkecluster);
%
% to keep memory of the initial Npar0 from ray tracing (edge fluctuations for the LH wave only) for the next time step, depending upon dtn_fluct
%
if isfield(wavestructs{1}.equil_fit,'fluct_fit'),
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


