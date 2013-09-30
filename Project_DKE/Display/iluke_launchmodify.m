function wavestruct = iluke_launchmodify(wavestruct,style)
%
launch = wavestruct.launch;
%
if isfield(launch,'orig'),
    orig = launch.orig;
    launch = rmfield(launch,'orig');
else
    orig = launch;
end
%
type = launch.type;
launch = rmfield(launch,'type');
%
if strcmp(type,'EC'),
    %
    launch.frequency_GHz = launch.omega_rf/(2*pi*1e9);
    launch.yP_L_kW = launch.yP_L/1e3;
    launch.yphi_L_deg = launch.yphi_L*180/pi;
    launch.yalpha_L_deg = launch.yalpha_L*180/pi;
    launch.ybeta_L_deg = launch.ybeta_L*180/pi;
    %
    launch = rmfield(launch,{'omega_rf','yP_L','yphi_L','yalpha_L','ybeta_L'});
    if isfield(launch,'angles'),
        launch = rmfield(launch,'angles');
    end
    %
elseif strcmp(type,'LH'),
    %
    launch.frequency_GHz = launch.omega_rf/(2*pi*1e9);
    launch.bPlhtot_MW = launch.bPlhtot/1e6;
    launch.phi0_deg = launch.phi0*180/pi;
    rZ0 = launch.rZ0;
    nrZ0 = length(rZ0);
    if nrZ0 > 3,
        launch.nrZ0 = nrZ0;
        if all(rZ0 > 0),
            launch.module = 'upper';
        elseif all(rZ0 < 0),
            launch.module = 'lower';
        else
            launch.module = 'full antenna';
        end
        launch = rmfield(launch,'rZ0');
    end
    %
    if any(imag(launch.bNpar0) ~= 0),% = ny + i*nz
        launch.bNy = real(launch.bNpar0);
        launch.bNz = imag(launch.bNpar0);
        launch = rmfield(launch,'bNpar0');
    end
    %
    if isfield(launch,'tail') && isfield(launch.tail,'bopt_tail'),
        launch.tail.h_tail = real(launch.tail.bopt_tail);
        launch.tail.opt_dnpar0 = imag(launch.tail.bopt_tail) == 1;
        launch.tail = rmfield(launch.tail,'bopt_tail');
    end                
    %
    launch = rmfield(launch,{'omega_rf','bPlhtot','phi0'});
    if isfield(launch,'aloha'),
        launch = rmfield(launch,'aloha');
    end
    %
end
%
[launch,mod] = imod_struct_jd(launch,'launch',1,true,struct,style);%lukeobj.infopanel.handle
%
if any(mod),
    %
    if strcmp(type,'EC'),
        %
        launch.omega_rf = launch.frequency_GHz*(2*pi*1e9);
        launch.yP_L = launch.yP_L_kW*1e3;
        launch.yphi_L = launch.yphi_L_deg*pi/180;
        launch.yalpha_L = launch.yalpha_L_deg*pi/180;
        launch.ybeta_L = launch.ybeta_L_deg*pi/180;
        %
        launch = rmfield(launch,{'frequency_GHz','yP_L_kW','yphi_L_deg','yalpha_L_deg','ybeta_L_deg'});
        %
    elseif strcmp(type,'LH'),
        %
        if nrZ0 > 3,
            mrZ0 = mean(rZ0);
            rZ0 = rZ0 - mrZ0;% setup raws with respect to center
            %
            % antenna is assumed to be vertically symmetric
            %
            if rem(nrZ0,2) == 0,      
                rZ0min = rZ0(nrZ0/2+1) - (rZ0(nrZ0/2+2) - rZ0(nrZ0/2+1))/2;
            else
                rZ0min = rZ0((nrZ0+1)/2+1) - (rZ0((nrZ0+1)/2+2) - rZ0((nrZ0+1)/2+1))/2;
            end
            %
            rZ0max = rZ0(nrZ0) + (rZ0(nrZ0) - rZ0(nrZ0-1))/2;
            %
            if rem(launch.nrZ0,2) == 0,    
                rZ0_S = linspace(rZ0min,rZ0max,launch.nrZ0/2 + 1);
                rZ0 = (rZ0_S(1:end-1) + rZ0_S(2:end))/2;
                rZ0 = [-fliplr(rZ0),rZ0];
            else
                rZ0_S = linspace(rZ0min,rZ0max,(launch.nrZ0-1)/2 + 1);
                rZ0 = (rZ0_S(1:end-1) + rZ0_S(2:end))/2;
                rZ0 = [-fliplr(rZ0),0,rZ0];
            end            
            %
            if strcmp(launch.module,'upper'),
                rZ0 = rZ0(rZ0 >= 0);
            elseif strcmp(launch.module,'lower'),
                rZ0 = rZ0(rZ0 <= 0);
            end
            %
            rZ0 = rZ0 + mrZ0;
            %
            launch = rmfield(launch,{'nrZ0','module'});
            %
            launch.rZ0 = rZ0;
            %
        end
        %
        launch.omega_rf = launch.frequency_GHz*(2*pi*1e9);
        launch.bPlhtot = launch.bPlhtot_MW*1e6;
        launch.phi0 = launch.phi0_deg*pi/180;
        %
        launch = rmfield(launch,{'frequency_GHz','bPlhtot_MW','phi0_deg'});
        %
        if isfield(launch,'bNy') && isfield(launch,'bNz'),
            launch.bNpar0 = launch.bNy + 1i*launch.bNz;
            launch = rmfield(launch,{'bNy','bNz'});
        end
        %
        if isfield(launch,'tail') && isfield(launch.tail,'h_tail') && isfield(launch.tail,'opt_dnpar0'),
            launch.tail.bopt_tail = launch.tail.h_tail + 1i*launch.tail.opt_dnpar0;
            launch.tail = rmfield(launch.tail,{'h_tail','opt_dnpar0'});
        end                
    end
    %
    launch.type = type;
    launch.orig = orig;
    %
    wavestruct.launch = launch;
    wavestruct.id = [wavestruct.wavesolver,'_',wavestruct.launch.id];
    %
end
