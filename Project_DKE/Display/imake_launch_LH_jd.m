function launch = imake_launch_LH_jd(basestr,equil,external,opt_gui)
%
% This function builts the launch structure for LH waves from external and/or user-specified data
%
if nargin < 4,
    opt_gui = 0;
end
if nargin < 3,
    external = '';
end
%
if nargin < 2,
    error('Not enough arguments')
end
%
signe.ip = sign(equil.psi_apRp(end));
signe.b0 = sign(equil.ptBPHI(1,1));
%
if ~isempty(external),
    %
    if strcmp(basestr,'TS'),
        %
        % !!!! Warning : older antenna configurations not yet operational
        %
        %if str2num(shotnum) > 0,% !!!! to be specified 
            %
            config = 'MIXTE';
            %
        %end
        %
        disp(['-----> The antenna configuration is : ',config]);
        %
        Plh(1) = 1e6*external.Plh_C2;
        Plh(2) = 1e6*external.Plh_C3;
        npar(1) = external.npar_C2;
        npar(2) = external.npar_C3;
        %             l_opt = input_dke_yp('Directivity of the wave',1,[0;1],'',[1,1]);
        l_opt = input_dke_yp('Do you want to include the negative lobe [y/n]','n',{'y','n'},'',[1,1]);
        %
        if strcmp(l_opt,'y'),
            lob = 'Yes';
        else 
            lob = 'No';
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
    config = basestr;
    %
    nant = 2;%maximum number of antennas in make_wavelaunchs_cronos_lh
    %
    Plh = 1e6*[1]*ones(1,nant);
    npar = -signe.ip*signe.b0*[2]*ones(1,nant);
    %
    lob = 'Yes';
    %
end
%
if strcmp(basestr,'TS') || strcmp(basestr,'JET'),% default values from make_wavelaunchs_cronos_lh
    %
    cons = Plh.*exp(i*npar);
    %
    cons_spec = NaN;
    %
    launchs = make_wavelaunchs_cronos_lh('','',cons,signe,config,lob);
    %
    a_str = '';
    for iw = 1:length(launchs),
        a_str = [a_str,' (',num2str(iw),') ',launchs{iw}.id,','];
    end
    %
    if iw > 1,
        %
        a_opt = input_dke_yp(['Please select an antenna :',a_str],1,1:iw,'',[1,1]);
        %
    else
        a_opt = 1;
    end
    %
    launch = launchs{a_opt};
    %
else % default values
    %
    launch.omega_rf = 2*pi*1e9*4.6;
    launch.LFS = 1;    
    launch.m0 = 0;
    %
    if isnan(launch.m0),
        launch.n0 = 0;
    else
        launch.n0 = NaN;
    end
    %
    launch.phi0 = 0;
    launch.bPlhtot = Plh(1);  
    launch.bNpar0 = npar(1);  
    launch.bdNpar0 = 0.2;
    launch.rZ0 = 0;  
    launch.id = '';
    %
end
%
if ~isempty(external),
    %
    return
    %
end
%
launch.i_ref = -1;%index of the flux surface where the rays are launched
%
launch.frequency_GHz = launch.omega_rf/(2*pi*1e9);
launch.phi0_deg = launch.phi0*180/pi;
launch.bPlhtot_MW = launch.bPlhtot/1e6;
launch = rmfield(launch,{'omega_rf','phi0','bPlhtot'});
%
launch = imod_struct_jd(launch,'launch',1,opt_gui);
%
launch.omega_rf = launch.frequency_GHz*(2*pi*1e9);
launch.phi0 = launch.phi0_deg*pi/180;
launch.bPlhtot = launch.bPlhtot_MW*1e6;
launch = rmfield(launch,{'frequency_GHz','phi0_deg','bPlhtot_MW'});
%
