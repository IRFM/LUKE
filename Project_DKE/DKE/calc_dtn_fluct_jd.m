function [dtnmin_fluct,dtns_fluct] = calc_dtn_fluct_jd(fluct,wavestructs,mksa)
%
%
flucttypes = fieldnames(fluct);
%
dtns_fluct = struct;
dtnmin_fluct = Inf;
%
% equilibrium fluctuations
%
for ifluct = 1:length(flucttypes),% for each fluctuation type (ne, Be, etc)
    %
    flucttype = flucttypes{ifluct};
    %
    for imodel = 1:length(fluct.(flucttype)),% for each fluctuation model (ripple, drift, etc)
        %
        if fluct.(flucttype)(imodel).model == 0,
            epsi_rho = Inf;
            epsi_theta = Inf;
            epsi_phi = Inf;
        elseif fluct.(flucttype)(imodel).model == 1,
            error('Fluctuation model ''1'' is not implemented (ray tracing benchmark only). Check the function that builds the fluct structure.'); 
        elseif fluct.(flucttype)(imodel).model == 2,
            epsi_rho = fluct.(flucttype)(imodel).epsi_rho;
            epsi_theta = fluct.(flucttype)(imodel).epsi_theta; 
            epsi_phi = fluct.(flucttype)(imodel).epsi_phi; 
        elseif fluct.(flucttype)(imodel).model == 3,
            epsi_rho = fluct.(flucttype)(imodel).epsi_rho;
            epsi_theta = fluct.(flucttype)(imodel).epsi_theta;
            epsi_phi = Inf;
        elseif fluct.(flucttype)(imodel).model == 4 || fluct.(flucttype)(imodel).model == 5,
            epsi_rho = Inf;
            epsi_theta = fluct.(flucttype)(imodel).epsi_theta;
            epsi_phi = Inf;
        else
            error('Fluctuation model >=6 not implemented.');
        end
        %
        dtns_fluct.(flucttype)(imodel).dtn_rho = 2.14*mksa.nhu_ref*max(epsi_rho)/mksa.vde_ref;%See the documentation on plasma fluctuations for the coefficient 2.14 
        dtns_fluct.(flucttype)(imodel).dtn_theta = 2.14*mksa.nhu_ref*max(epsi_theta)/mksa.vde_ref;
        dtns_fluct.(flucttype)(imodel).dtn_phi = 2.14*mksa.nhu_ref*max(epsi_phi)/mksa.vde_ref;
        %
        dtnmin_fluct = min([dtnmin_fluct,dtns_fluct.(flucttype)(imodel).dtn_rho,dtns_fluct.(flucttype)(imodel).dtn_theta,dtns_fluct.(flucttype)(imodel).dtn_phi]);
        %
    end
end
%
% spectrum fluctuations
%
for iw = 1:length(wavestructs),
    if isfield(wavestructs{iw}.launch,'tail') && isfield(wavestructs{iw}.launch.tail,'dtn'),
        dtns_fluct.npar0_lh(iw).dtn = 2.14*wavestructs{iw}.launch.tail.dtn;
    else
        dtns_fluct.npar0_lh(iw).dtn = Inf;
    end
    %
    dtnmin_fluct = min([dtnmin_fluct,dtns_fluct.npar0_lh(iw).dtn]);
    %
end 
%
