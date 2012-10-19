function waves_out = proc_wave_alphaphi_luke_jd(output,waves,opt_abs)
%
if nargin < 3 || isempty(output),
    opt_abs = 0;% only correct data
end
if nargin < 2,
    if ~isempty(output),
        waves = output.dke_out.waves;
    else
        waves = {};
    end
end
%
for iw = 1:length(waves),
    for ib = 1:length(waves{iw}.rays),
        ray = waves{iw}.rays{ib};
        %
        if isfield(ray,'stau') && ~isfield(ray,'stau_lin'),
            ray.stau_lin = ray.stau;
            ray = rmfield(ray,'stau');
        end
        %
        if isfield(ray,'sP_2piRp') && ~isfield(ray,'sP_2piRp_lin'),
            ray.sP_2piRp_lin = ray.sP_2piRp;
            ray = rmfield(ray,'sP_2piRp');
        end
        %
        if isfield(ray,'sdP_2piRp_ds') && ~isfield(ray,'sdP_2piRp_ds_lin'),
            ray.sdP_2piRp_ds_lin = ray.sdP_2piRp_ds;
            ray = rmfield(ray,'sdP_2piRp_ds');
        end
        %
        waves{iw}.rays{ib} = ray;
    end
end
%
if opt_abs == 1,
    waves_out = alphaphi_luke_jd(waves,output.dke_out,output.ZP0,output.equilDKE,output.mksa);
else
    waves_out = waves;
end
%
