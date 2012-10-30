function ray_proc = proc_ray_jd(ray)
%
% case of old rays
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
% c3po characteristics
%
ray_proc.c3po = proc_peak_jd(ray,ray.sP_2piRp_lin);
%
% luke characteristics
%
if isfield(ray,'sP_2piRp'),
    %    
    for itn = 1:length(ray.sP_2piRp),
        ray_proc.luke{itn} = proc_peak_jd(ray,ray.sP_2piRp{itn});
    end
    %
end
%
end
%
% *****************************************************************
%
function [ray_proc] = proc_peak_jd(ray,sP_2piRp)
%
sP_2piRp_h = [sP_2piRp(1),(sP_2piRp(1:end-1) + sP_2piRp(2:end))/2,sP_2piRp(end)];
sdP_2piRp = -diff(sP_2piRp_h);% specific absorption associated with each ray
%
ns = length(sdP_2piRp);
%
fnames = fieldnames(ray);
%
for ifield = 1:length(fnames),
    %
    fname = fnames{ifield};
    %
    if isnumeric(ray.(fname)) && length(size(ray.(fname))) <= 2 && size(ray.(fname),2) == ns,
        %
        ray_proc.(fname) = sum(ray.(fname).*repmat(sdP_2piRp,[size(ray.(fname),1),1]),2)/sum(sdP_2piRp);
        %
    elseif iscell(ray.(fname)),
        %
        for ic = 1:length(ray.(fname)),
            %
            if isnumeric(ray.(fname){ic}) && length(size(ray.(fname){ic})) <= 2 && size(ray.(fname){ic},2) == ns,
                ray_proc.(fname){ic} = sum(ray.(fname){ic}.*repmat(sdP_2piRp,[size(ray.(fname){ic},1),1]),2)/sum(sdP_2piRp);
            end
            %
        end
        %
    else
        %
        ray_proc.(fname) = ray.(fname);
        %
    end
    %
end
%
end
%