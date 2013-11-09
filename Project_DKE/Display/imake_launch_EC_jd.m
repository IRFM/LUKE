function launch = imake_launch_EC_jd(basestr,equil,external,opt_gui,select)
%
% This function builts the launch structure for LH waves from external and/or user-specified data
%
if nargin < 5,
    select = struct;
end
if nargin < 4,
    opt_gui = false;
end
if nargin < 3,
    external = '';
end
%
if nargin < 2,
    error('Not enough arguments')
end
%
if ~isempty(external),
    %
    if strcmp(basestr,'EAST'),
        %
        Pec = [];
        %
        if isfield(external,'mirror_140GHz')
            Pec = [Pec,external.mirror_140GHz.total_launched_power.power*1e6];
        end
        %
        if isfield(external,'mirror_170GHz')
            Pec = [Pec,external.mirror_170GHz.total_launched_power.power*1e6];
        end
        %
        disp(['----> Injected EC power: ',num2str(Pec/1e6),' MW']);
        %
        fexternal = fieldnames(external);
        %
        if isfield(select,'a_opt'),
            a_opt = select.a_opt;
        else
            a_str = '';
            for iw = 1:length(fexternal),
                a_str = [a_str,' (',num2str(iw),') ',fexternal{iw},','];
            end
            %
            if iw > 1,
                %
                a_opt = input_dke_yp(['Please select a mirror :',a_str],1,1:iw,'',[1,1]);
                %
            else
                a_opt = 1;
            end
        end
        %
        frequency = external.(fexternal{a_opt}).frequency;
        position = external.(fexternal{a_opt}).position;
        %
        launch.id = fexternal{a_opt};
        launch.phi0 = 0;
        launch.omega_rf = 2*pi*1e9*frequency.fec;
        %
        ny = 1;%Number of rays
        %
        launch.yZ_L = position.Z;  
        launch.yR_L = position.R;  
        launch.yphi_L = pi/180.*position.phi;  
        launch.yalpha_L = pi/180.*position.alpha;
        launch.ybeta_L = pi/180.*position.beta;
        launch.yP_L = Pec;
        %
        if length(launch.yP_L) == 1,
            launch.yP_L = launch.yP_L*ones(1,ny)/ny;
        elseif any(size(launch.yP_L) ~= [1,ny]),
            error('Wrong dimension for power array')
        end
        %
        if ny == 1,
            launch.w0 = position.beam_width; 
            launch.z0 = position.length_focus; 
        end
        %
    else
        %
        error(['-----> wave data not yet implemented for :',basestr]);
        %
    end
    %
else
    %
    launch.omega_rf = 2*pi*1e9*input_dke_yp('Wave frequency (GHz)',[],[0;Inf],'',[1,1]);
    %
    ny = input_dke_yp('Number of rays',1,1:20,'',[1,1]);  
    %
    launch.yZ_L = input_dke_yp('Vertical position of launching (m)',0*ones(1,ny),[-Inf;Inf],'',[1,ny]);  
    launch.yR_L = input_dke_yp('Major radius position of launching \n  (enter ''NaN'' if launching from LCFS on LFS) (m)',NaN*ones(1,ny),[],'',[1,ny]);  
    launch.yphi_L = pi/180*input_dke_yp('Toroidal position of launching (deg)',0*ones(1,ny),[-180;180],'',[1,ny]);  
    launch.yalpha_L = pi/180*input_dke_yp('Horizontal launching angle (with respect to R axis) (deg)',180*ones(1,ny),[-180;180],'',[1,ny]);  
    launch.ybeta_L = pi/180*input_dke_yp('Vertical launching angle (with respect to Z axis) (deg)',90*ones(1,ny),[0;180],'',[1,ny]);  
    launch.yP_L = 1e6*input_dke_yp('Power in each ray (MW)\n  (scalar for total power uniform distributed)',1,[0;Inf],'',[1,1]);  
    %
    if length(launch.yP_L) == 1,
        launch.yP_L = launch.yP_L*ones(1,ny)/ny;
    elseif any(size(launch.yP_L) ~= [1,ny]),
        error('Wrong dimension for power array')
    end
    %
    if ny == 1,
        launch.w0 = input_dke_yp('Beam width (m)',[],[0;Inf],'',[1,1]);
        launch.z0 = input_dke_yp('Distance to focal point (m)',0,[-Inf;Inf],'',[1,1]);
    end
    %
    launch.id = input_dke_yp('Provide an id for this launching structure','');
    %
end
%


