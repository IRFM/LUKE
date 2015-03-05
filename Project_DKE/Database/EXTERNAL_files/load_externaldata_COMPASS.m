function external = load_externaldata_COMPASS(external_in,opt_gui)
    %
    % This function loads data from COMPASS database
    %
    % INPUTS : 
    %   - if nargin == 0, return default external_in to be modified interactively in iload_externaldata_jd

    %   - external_in : input structure.
    %   - opt_gui     : option for GUI within function (interactive mode only)
    %       
    %
    if nargin == 0,
        %
        % default values
        %
        external.shotnum = 0;
        external.shotime = 0;
        %
        % description & user halp
        %
        external.info.shotnum = 'Shot number';
        external.info.shotime = 'Shot time (s)';
        % 
        % expert mode
        %
        external.expert.shotnum = 0;
        external.expert.shotime = 0;
        %
        % range of values
        %
        external.values.shotnum = [0;Inf];
        external.values.shotime = [0;Inf];
        %
        return
        %
    end
    %
    if nargin < 2,
        opt_gui = false;
    end
    %
    shotnum = external_in.shotnum;
    shotime = external_in.shotime;
    %
    % ******************************************************************
    %
    external = '';
    basestr = 'COMPASS';
    %
    if exist('cdb_client','file') == 2,%when we are on Abacus
        %
        data_out = compass2luke(shotnum);
        %
    else
        [filename,pathname] = igetfile_jd(opt_gui,'*.mat',['Please select the COMPASS data file for shot # ',shotnum],'',0);
        %
        if filename ~= 0,
            load([pathname,filename],'data_out');
        else
            disp(' ');disp('--> Read remotely from COMPASS database');disp(' ');
            [remote,profilestr] = load_remoteprofiles_jd('IPP_ABACUS',false,true,'direct',NaN,true);%read remotely from COMPASS database 
            [err_data,~,data_out] = matremote_jd('compass2luke',{shotnum},remote,matstandardjob_jd('runmat'));        
            %
            if err_data ~= 0,
                return
            end
        end
    end
    %
    if shotime == 0,% EFIT time grid reference, if shotime is not specified
        ishotime = round(length(data_out.efit.li.time_axis.data)/2);
        shotime = data_out.efit.li.time_axis.data(ishotime)/1e3;% ms -> s
        disp(' ');disp(['WARNING: The shot time has been enforced to ',num2str(shotime),' (s)']);disp(' ');
    else,%nearest value
        ishotime = interp1(data_out.efit.li.time_axis.data,[1:length(data_out.efit.li.time_axis.data)],shotime,'nearest')
        shotime = data_out.efit.li.time_axis.data(ishotime)/1e3;% ms -> s
        disp(' ');disp(['WARNING: The nearest shot time is ',num2str(shotime),' (s)']);disp(' ');
    end
    %
    % smoothing and interpolation (reference EFIT time grid)
    %
    %
    % EFIT data (see the definitions on the COMPASS website
    % https://www.tok.ipp.cas.cz/webcdb/data_sources/EFIT)
    %
    triangularity_lower_lcfs.t = data_out.efit.triangularity_lower_lcfs.time_axis.data(ishotime)/1e3;% ms -> s
    triangularity_lower_lcfs.data = data_out.efit.triangularity_lower_lcfs.data(ishotime);
    li.t = data_out.efit.li.time_axis.data(ishotime)/1e3;% ms -> s
    li.data = data_out.efit.li.data(ishotime);%internal inductance
    Ip.t = data_out.efit.Ip.time_axis.data(ishotime)/1e3;% ms -> s
    Ip.data = data_out.efit.Ip.data(ishotime);% A
    q.t = data_out.efit.q.time_axis.data(ishotime)/1e3;% ms -> s
    q.data = data_out.efit.q.data(ishotime,:);
    %
    psi_RZ.t = data_out.efit.psi_RZ.time_axis.data(ishotime)/1e3;% ms -> s
    psi_RZ.data = data_out.efit.psi_RZ.data(ishotime,:,:);% Wb/rad
    psi_RZ.R = data_out.efit.psi_RZ.axis1.data(ishotime,:);% m 
    psi_RZ.Z = data_out.efit.psi_RZ.axis2.data(ishotime,:);% m
    psi_n.data = data_out.efit.psi_n.data;% Wb/rad
    psi_mag_axis.t = data_out.efit.psi_mag_axis.time_axis.data(ishotime)/1e3;% ms -> s
    psi_mag_axis.data = data_out.efit.psi_mag_axis.data(ishotime);
    psi_lcfs.t = data_out.efit.psi_lcfs.time_axis.data(ishotime)/1e3;% ms -> s
    psi_lcfs.data = data_out.efit.psi_lcfs.data(ishotime);
    %
    R_mag_axis.t = data_out.efit.R_mag_axis.time_axis.data(ishotime)/1e3;% ms -> s
    R_mag_axis.data = data_out.efit.R_mag_axis.data(ishotime,:,:);% m
    Z_mag_axis.t = data_out.efit.Z_mag_axis.time_axis.data(ishotime)/1e3;% ms -> s
    Z_mag_axis.data = data_out.efit.Z_mag_axis.data(ishotime,:,:);% m
    R_geom_axis.t = data_out.efit.R_geom_axis.time_axis.data(ishotime)/1e3;% ms -> s
    R_geom_axis.data = data_out.efit.R_geom_axis.data(ishotime,:,:);% m
    Z_geom_axis.t = data_out.efit.Z_geom_axis.time_axis.data(ishotime)/1e3;% ms -> s
    Z_geom_axis.data = data_out.efit.Z_geom_axis.data(ishotime,:,:);% m
    %
    B_vac_R_geom.t = data_out.efit.B_vac_R_geom.time_axis.data(ishotime)/1e3;% ms -> s
    B_vac_R_geom.data = data_out.efit.B_vac_R_geom.data(ishotime,:,:);% m
    RBphi.t = data_out.efit.RBphi.time_axis.data(ishotime)/1e3;% ms -> s
    RBphi.data = data_out.efit.RBphi.data(ishotime,:,:);% m
    FFprime.t = data_out.efit.FFprime.time_axis.data(ishotime)/1e3;% ms -> s
    FFprime.data = data_out.efit.FFprime.data(ishotime,:,:);% m
    pprime_static.t = data_out.efit.pprime_static.time_axis.data(ishotime)/1e3;% ms -> s
    pprime_static.data = data_out.efit.pprime_static.data(ishotime,:,:);% m
    p_stat.t = data_out.efit.p_stat.time_axis.data(ishotime)/1e3;% ms -> s
    p_stat.data = data_out.efit.p_stat.data(ishotime,:,:);% m
    %
    if isfield(data_out,'ne') && isfield(data_out,'te'),%Thomson scattering
        pne.t = shotime;
        pne.x = data_out.ne.axis1.data;%Vertical TS measuring points (m)
        pne.data = interp1(data_out.ne.time_axis.data/1e3,data_out.ne.data,shotime,'linear');% m^-3
        pne.data = compass_ts_profile_fit(pne,psi_RZ,psi_n.data,psi_lcfs.data,psi_mag_axis.data);% m^-3
        %
        pTe.t = shotime;
        pTe.x = data_out.te.axis1.data;%Vertical TS measuring points (m)
        pTe.data = interp1(data_out.te.time_axis.data/1e3,data_out.te.data/1e3,shotime,'linear');% keV
        pTe.data = compass_ts_profile_fit(pTe,psi_RZ,psi_n.data,psi_lcfs.data,psi_mag_axis.data);% keV
    else
        pne.t = [];
        pne.data = [];
        pTe.t = [];
        pTe.data = [];
    end
    %
    % Magnetic data
    %
    U_loop.t = shotime;
    %U_loop.data = interp1(data_out.U_loop.time_axis.data/1e3,sgolayfilt(data_out.U_loop.data, 1,min(2*round(length(data_out.U_loop.time_axis.data)/400)-1,10001)),shotime,'linear');% V
    t_resample = 100;
    U_loop.data = interp1(data_out.U_loop.time_axis.data(t_resample/2:t_resample:end-t_resample/2)/1e3,compass_resample_data(data_out.U_loop.data,t_resample),shotime,'linear');% V
    %close all,plot(data_out.U_loop.time_axis.data/1e3,data_out.U_loop.data,'b',data_out.U_loop.time_axis.data/1e3,sgolayfilt(data_out.U_loop.data, 1,min(2*round(length(data_out.U_loop.time_axis.data)/400)-1,10001)),'r')
    I_plasma.t = shotime;
    %I_plasma.data = interp1(data_out.I_plasma.time_axis.data/1e3,sgolayfilt(data_out.I_plasma.data, 1,min(2*round(length(data_out.I_plasma.time_axis.data)/400)-1,10001)),shotime,'linear');% A
    I_plasma.data = interp1(data_out.I_plasma.time_axis.data(t_resample/2:t_resample:end-t_resample/2)/1e3,compass_resample_data(data_out.I_plasma.data,t_resample),shotime,'linear');% A
    %close all,plot(data_out.I_plasma.time_axis.data/1e3,data_out.I_plasma.data,'b',data_out.I_plasma.time_axis.data/1e3,sgolayfilt(data_out.I_plasma.data, 1,min(2*round(length(data_out.I_plasma.time_axis.data)/400)-1,10001)),'r')
    %
    % return structure external
    %
    external.basestr = basestr;
    external.shotnum = num2str(shotnum);
    external.shotime = shotime;
    %
    external.ohm.Vloop = U_loop.data;
    %
    external.equil.shotnum = external.shotnum;
    external.equil.shotime = external.shotime;
    %
    external.equil.magnetic.I_plasma = I_plasma.data;
    %
    external.equil.magnetic.efit.triangularity_lower_lcfs = triangularity_lower_lcfs.data;
    external.equil.magnetic.efit.li = li.data;
    external.equil.magnetic.efit.Ip = Ip.data;
    external.equil.magnetic.efit.q = q.data;
    %
    external.equil.magnetic.efit.psi_RZ = reshape(psi_RZ.data,[length(psi_RZ.R),length(psi_RZ.Z)]);% Wb/rad
    external.equil.magnetic.efit.psi_n = psi_n.data;
    external.equil.magnetic.efit.psi_mag_axis = psi_mag_axis.data;
    external.equil.magnetic.efit.psi_lcfs = psi_lcfs.data;
    %
    external.equil.magnetic.efit.R = psi_RZ.R;% m
    external.equil.magnetic.efit.Z = psi_RZ.Z;% m
    external.equil.magnetic.efit.R_mag_axis = R_mag_axis.data;% m
    external.equil.magnetic.efit.Z_mag_axis = Z_mag_axis.data;% m
    external.equil.magnetic.efit.R_geom_axis = R_geom_axis.data;% m
    external.equil.magnetic.efit.Z_geom_axis = Z_geom_axis.data;% m
    %
    external.equil.magnetic.efit.B_vac_R_geom = B_vac_R_geom.data;% m
    external.equil.magnetic.efit.RBphi = RBphi.data;% m
    external.equil.magnetic.efit.FFprime = FFprime.data;% m
    external.equil.magnetic.efit.pprime_static = pprime_static.data;% m
    external.equil.magnetic.efit.p_stat = p_stat.data;% m
    %
    external.equil.prof.pne = pne.data;
    external.equil.prof.pTe = pTe.data;
    %
    external.equil.prof.pspsin = psi_n.data;
    external.equil.prof.pne = pne.data;
    external.equil.prof.pTe = pTe.data;
    external.equil.prof.pTi = pTe.data/2;%Ti = Te/2
    external.equil.prof.Zeff = 2;%Zeff = 2
    external.equil.prof.fi = [0,1,0];%Deuterium plasma only
    external.equil.prof.zZi = [1,1,1,6];%carbon main impurity
    external.equil.prof.zmi = [1,2,3,12];%carbon main impurity
    %
    external.id = ['COMPASS_',external.shotnum,'_',num2str(shotime,'%6.4f')];
    %
    if isnan_jd(external,0),
        disp('Warning : NaNs were found in the structure ''external'' : ')
    end
    %
end

function [data_out] = compass_ts_profile_fit(data_in,psi_RZ,psi_n,psi_lcfs,psi_mag_axis)
    %
    % Thomson scattering profile smoothing (remove spurious points)
    %
    x = data_in.x;
    ts = data_in.data;
    %
    %psi1  = psi_lcfs;
    %psi0  = psi_mag_axis;
    %
    psi_ts = interp2(psi_RZ.R,psi_RZ.Z,squeeze(psi_RZ.data).',0.56,x,'spline');%psi value where TS measures
    psin_ts = (psi_ts - psi_mag_axis)/(psi_lcfs - psi_mag_axis);%normalized psi where TS measures
    %
    ipoints = find(x < 0.18);%0.33
    %
    ts_ptot = ts(ipoints);
    %
    figure,subplot(2,1,1)
    title('Thomson scattering density profile')     
    hold on     
    plot(x(ipoints),ts(ipoints) ,'rx');
    plot(x,ts,'b');
    %     ylim([0 4e19]);
    ylabel('Profile values');
    xlabel('Z coordinate [m]');
    hold off
    %
    ts_psin = psin_ts(ipoints); 
    %
    sfactor = 0.999;     
    ptot_fit = fit(psin_ts(ipoints), ts_ptot.', 'smoothingspline', 'SmoothingParam', sfactor);
    data_out = ptot_fit(psi_n);
    %
    subplot(2,1,2) % first subplot
    hold on
    plot(psin_ts(ipoints), ts_ptot.', 'rx')
    plot(psi_n, data_out, 'b')
    %     ylim([0 4e19])
    ylabel('Profile values')
    xlabel('Normalized \psi')
    hold off
    %
end

function res = compass_resample_data(data, ww)

    % fast resample data using a running average filter
    %
    % data: vector of data
    % ww: window width

    % enforce column vector
    % TODO adjust automatically for row/column vectors
    data = reshape(data, [], 1);
    % cut the last data points
    % TODO properly treat the last data points
    n_mod = mod(length(data), ww);
    data = data(1:end-n_mod);
    % reshape the data and calculate the mean
    data = reshape(data, ww, []);
    res = mean(data, 1);

end

