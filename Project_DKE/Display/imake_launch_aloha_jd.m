function launch = imake_launch_aloha_jd(basestr,aloha,opt_gui)
%
% This function creates the launch structure from ALOHA data
%
launchsfile = ['get_launchs_',basestr];
%
if exist(launchsfile,'file'),
    %
    launchs = feval(launchsfile);
    %
    if length(launchs) == 1,
        ilaunch = 1;
    else
        launchstr = 'Select antenna : \n';
        for ilaunch = 1:length(launchs),
            launchstr = [launchstr,'(',num2str(ilaunch),') : ',launchs{ilaunch}.id,'\n'];
        end
        %
        ilaunch = input_dke_yp(launchstr,1,1:ilaunch);
        %
    end
    %
    launch = launchs{ilaunch};
    %
else %default values
    %
    freq_GHz = 3.7;
    %
    launch.id = 'Default';
    launch.type = 'LH';
    %
    launch.omega_rf = freq_GHz*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
    launch.directivity = 0.7;%Antenna directivity [1,1]
    launch.dNpar0 = 0.2;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    %
    launch.rZ0 = 0;%vertical launching positions (m) [1,m_pol]
    % 
    launch.m0 = 0;%initial poloidal mode number [1,1]
    launch.phi0 = 0;%toroidal angle position [1,1]
    launch.i_ref = -1;%Initial radial position index [1,1]
    launch.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
    launch.mmode = -1;% (-1) for slow wave, (1) for fast wave
    %
end
%
launch.frequency_GHz = launch.omega_rf/(2*pi*1e9);
launch = imod_struct_jd(rmfield(launch,'omega_rf'),'launch',1,opt_gui);
launch.omega_rf = launch.frequency_GHz*(2*pi*1e9);
launch = rmfield(launch,'frequency_GHz');
%
P_tot_0 = sum(antenna.dP_nz)*antenna.dnz/1e6;
P_tot = input_dke_yp('Confirm the total power (MW) : ',P_tot_0);
redfac = P_tot/P_tot_0;
%
[bNpar0,bdNpar0,bPlhtot] = proc_aloha_spec_jd(antenna.nz,NaN,antenna.dP_nz,redfac,param,opt_optim);
%
launch.bdNpar0 = bdNpar0;
launch.bNpar0 = bNpar0;
launch.bPlhtot = bPlhtot;
%





    
    
    