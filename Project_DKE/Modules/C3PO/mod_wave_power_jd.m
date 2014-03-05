function wave = mod_wave_power_jd(wave,P0,flag_lin,locwave_id,opt_save)
    %
    % INPUTS : 
    %   - wave      : original wave structure
    %   - P0        : new wave power (in W). If NaN, the power is not changed
    %   - flag_lin  : (true) : add "_lin" to linear ray power fields to comply with new formalism
    %   - locwaveid : add extra string at the end of wave.id. Otherwise, leave empty
    %   - opt_save  : save wave locally if opt_save == 1 or if opt_save is a non-empty string (which provides the file name [opt_save,'.mat'])
    %
    % OUTPUTS :
    %   - wave      : modified wave structure
    %
    if nargin < 5,
        opt_save = 0;
    end
    if nargin < 4,
        locwave_id = '';
    end
    if nargin < 3,
        flag_lin = false;
    end
    if nargin < 2,
        P0 = NaN;
    end
    %
    if isfield(wave,'rayinit') && isfield(wave.rayinit,'launch') && isfield(wave.rayinit.launch,'type') && strcmp(wave.rayinit.launch.type,'LH'),
        %
        % LH RT representation
        %
        P0_in = sum(wave.rayinit.launch.bPlhtot);
        %
        if ~isnan(P0),
            %
            Pfac = P0/P0_in;
            Pstr = ['_P0_',num2str(P0)];
            %
            % rayinit
            %
            wave.rayinit = mod_rayinit_power_jd(wave.rayinit,Pfac,Pstr);
            %
            % wave
            %
            if isfield(wave,'id'),
                wave.id = [wave.id,Pstr];
            else
                wave.id = wave.rayinit.id;
            end
            %
        end
        %
        if ~isempty(locwave_id),
            wave.id = [wave.id,locwave_id];
        end
        %
        % rays
        %
        for iray = 1:length(wave.rays),
            %
            ray = wave.rays{iray};
            %
            if flag_lin == 1,
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
            end
            %
            if ~isnan(P0),
                %
                ray.P0_2piRp = ray.P0_2piRp*Pfac; 
                %
                if isfield(ray,'sP_2piRp_lin'),
                    ray.sP_2piRp_lin = ray.sP_2piRp_lin*Pfac; 
                end
                %
                if isfield(ray,'sdP_2piRp_ds_lin'),
                    ray.sdP_2piRp_ds_lin = ray.sdP_2piRp_ds_lin*Pfac; 
                end
                %
                if isfield(ray,'sP_2piRp'),
                    ray.sP_2piRp = ray.sP_2piRp*Pfac; 
                end
                %
                if isfield(ray,'sdP_2piRp_ds'),
                    ray.sdP_2piRp_ds = ray.sdP_2piRp_ds*Pfac; 
                end
                %
                if isfield(ray,'rayinits'),
                    %
                    for irayinit = 1:length(ray.rayinits),
                        %
                        ray.rayinits{irayinit} = mod_rayinit_power_jd(ray.rayinits{irayinit},Pfac,Pstr);
                        %
                    end
                    %
                end
                %
            end
            %
            wave.rays{iray} = ray;
            %
        end
        %
    else
        error('wave structure not compatible with mod_wave_power_jd')
    end
    %
    if ischar(opt_save) && ~isempty(opt_save),
        save([opt_save,'.mat'],'wave');
    elseif opt_save == 1,
        save(['WAVE_',wave.id,'.mat'],'wave');
    end
    %
end
%
function rayinit = mod_rayinit_power_jd(rayinit,Pfac,Pstr)
    %
    % spectrum
    %
    if isfield(rayinit.launch,'spectrum'),
        if isfield(rayinit.launch.spectrum,'orig'),
            rayinit.launch.spectrum = rmfield(rayinit.launch.spectrum,{'orig'});
        end
        if isfield(rayinit.launch.spectrum,'Plhtot'),
            rayinit.launch.spectrum.Plhtot = rayinit.launch.spectrum.Plhtot*Pfac;
        end
    end
    %
    % launch
    %
    if isfield(rayinit.launch,'orig'),
        rayinit.launch = rmfield(rayinit.launch,{'orig'});
    end
    %
    if isfield(rayinit.launch,'id'),
        rayinit.launch.id = [rayinit.launch.id,Pstr];
    else
        rayinit.launch.id = [rayinit.launch.type,Pstr];
    end
    %
    rayinit.launch.bPlhtot = rayinit.launch.bPlhtot*Pfac;
    %
    % rayinit
    %
    if isfield(rayinit,'id'),
        rayinit.id = [rayinit.id,Pstr];
    else
        rayinit.id = ['C3PO_',rayinit.launch.id];
    end
    %
    rayinit.yP0_2piRp = rayinit.yP0_2piRp*Pfac;                                               
    %
end
%
