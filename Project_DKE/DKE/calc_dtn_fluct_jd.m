function dtn_fluct = calc_dtn_fluct_jd(fluct,mksa)
%
field_name = fieldnames(fluct);
%
model = [];
epsi_rho = [];
epsi_theta = [];
epsi_phi = [];
%
test_field_name_ne = strfind(field_name,'ne');%test existence of density fluctuation
test_field_name_B = strfind(field_name,'B');%test existence of magnetic field fluctuation
%
flag_core_fluct = 0;
flag_edge_fluct = 0;
%
for i = 1:length(field_name),
    if ~isempty(test_field_name_ne{i}) || ~isempty(test_field_name_B{i}), flag_core_fluct = 1;end
end
%
if flag_core_fluct,
    for i = 1:length(field_name),
        if isstruct(fluct.(char(field_name(i)))) && (strcmp(char(field_name(i)),'B') || strcmp(char(field_name(i)),'ne'))
            for ifield = 1:length(fluct.(char(field_name(i)))),
                    model = [model,fluct.(char(field_name(i)))(ifield).model];
                if fluct.(char(field_name(i)))(ifield).model == 1,
                    error('Fluctuation model ''1'' is not implemented in wave_distribution_yp.m (ray tracing benchmark only). Check the function that builds the fluct structure.'); 
                elseif fluct.(char(field_name(i)))(ifield).model == 2,
                    epsi_rho = [epsi_rho,fluct.(char(field_name(i)))(ifield).epsi_rho];
                    epsi_theta = [epsi_theta,fluct.(char(field_name(i)))(ifield).epsi_theta]; 
                    epsi_phi = [epsi_phi,fluct.(char(field_name(i)))(ifield).epsi_phi]; 
                elseif fluct.(char(field_name(i)))(ifield).model == 3,
                    epsi_rho = [epsi_rho,fluct.(char(field_name(i)))(ifield).epsi_rho];
                    epsi_theta = [epsi_theta,fluct.(char(field_name(i)))(ifield).epsi_theta];
                elseif fluct.(char(field_name(i)))(ifield).model == 4 || fluct.(char(field_name(i)))(ifield).model == 5,
                    epsi_theta = [epsi_theta,fluct.(char(field_name(i)))(ifield).epsi_theta];
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
%     Nfluct_core = max(round(dkeparam.dtn/dtn_fluct_core),1);%Number of rays when dtn_fluct < dtn
%     itn_core = max(round(dtn_fluct_core/dkeparam.dtn),1);
%     %
%     disp(['Nfluct_core = ',int2str(Nfluct_core)]);
else
%     disp('No plasma fluctuations');
%     Nfluct_core = 1; 
%     itn_core = 1;
    dtn_fluct_core = Inf;
end
%
if isfield(fluct,'edge')% & flag_LH,
    %
    flag_edge_fluct = 1;
    %
    if isfield(fluct.edge,'dtn'),
        %
%         Nfluct_edge = max(round(dkeparam.dtn/fluct.edge.dtn),1);%Number of rays when dtn_fluct < dtn
        dtn_fluct_edge = fluct.edge.dtn;
%         itn_edge = max(round(fluct.edge.dtn/dkeparam.dtn),1);
%         disp(['Nfluct_edge = ',int2str(Nfluct_edge)]);
        %
    else
        flag_edge_fluct = 0;
%         disp('No fluctuations of the launched LH power spectrum');
%         Nfluct_edge = 1;
        dtn_fluct_edge = Inf;
%         itn_edge = 1;
    end
else
    flag_edge_fluct = 0;
%     disp('No fluctuations of the launched LH power spectrum');
%     Nfluct_edge = 1;
%     itn_edge = 1;
    dtn_fluct_edge = Inf;
end
%
%Nfluct = max(Nfluct_core,Nfluct_edge);
dtn_fluct = min(dtn_fluct_core,dtn_fluct_edge);
