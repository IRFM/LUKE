function dtn_fluct = calc_dtn_fluct_jd(fluct,mksa)
%
field_name = fieldnames(fluct);
%
model = [];
epsi_rho = [];
epsi_theta = [];
epsi_phi = [];
%
test_field_name_ne = strfind(field_name,'ne');%test existence of electron density fluctuation
test_field_name_B = strfind(field_name,'B');%test existence of magnetic field fluctuation
%
flag_naequilp = 0;
flag_npar0_lh = 0;
%
for i = 1:length(field_name),
    if ~isempty(test_field_name_ne{i}) || ~isempty(test_field_name_B{i}), flag_naequilp = 1;end
end
%
if flag_naequilp,
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
    dtn_fluct_naequilp = min([dtn_rho,dtn_theta,dtn_phi]);
    %
else
    dtn_fluct_naequilp = Inf;
end
%
if isfield(fluct,'npar0_lh'),
    %
    flag_npar0_lh = 1;
    %
    if isfield(fluct.npar0_lh,'dtn'),
        dtn_fluct_npar0_lh = fluct.npar0_lh.dtn;
        %
    else
        flag_npar0_lh = 0;
        dtn_fluct_npar0_lh = Inf;
    end
else
    flag_npar0_lh = 0;
    dtn_fluct_npar0_lh = Inf;
end
%
dtn_fluct = min(dtn_fluct_naequilp,dtn_fluct_npar0_lh);
