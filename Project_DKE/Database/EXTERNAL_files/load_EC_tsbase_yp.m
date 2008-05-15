function  [flag,EC_out] = load_EC_tsbase_yp(shotnum,certif,shotime,tmin,tmax,basestr);
%
%   Load processed experimental data (TFCE treatment) of the tokamak Tore
%   Supra 
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM,joan.decker@cea.fr)
%
method = 'spline';
flag = 1;
%
if strcmp(basestr,'TS'),
	%
	shotnum = str2num(shotnum) + certif/10;  
	%
	% Load EC parameters from diagnostic directly (from J. F. Artaud for METIS)
	%
    [xika1,tbad] = tsbase(shotnum,'sika1');% gyrotron A1 cathode current
	[xHAUTTOR,tHAUTTOR] = tsbase(shotnum,'SHAUTTOR');% Toroidal injection angle top mirror (A1) hysteresis corrected
	if ~isempty(xika1) & ~isempty(xHAUTTOR)
        [prxA1,tA1] = tsbase(shotnum,'spia1');% gyrotron A1 power (anode current)
        [prxA2,tA2] = tsbase(shotnum,'spia2');% gyrotron A2 power (anode current)
        [sonde,tsonde] = tsbase(shotnum,'sonderf');% RF probe on reflectometer
        [xHAUTPOL,tHAUTPOL] = tsbase(shotnum,'SHAUTPOL');% Poloidal injection angle top mirror (A1) hysteresis corrected
        [xMILTOR,tMILTOR] = tsbase(shotnum,'SMILTOR');% Toroidal injection angle central mirror (A2) hysteresis corrected
        [xMILPOL,tMILPOL] = tsbase(shotnum,'SMILPOL');% Poloidal injection angle central mirror (A2) hysteresis corrected
        %
        % Powers in W (from M. Lennholm)
        %
        factA1 = 1;% Calibration factor to be applied to A1
        factA2 = 1;% Calibration factor to be applied to A2
        PA1 = max(0,1e6*prxA1/factA1);% A1 power in W
        PA2 = max(0,1e6*prxA2/factA2);% A2 power in W
        Ptot = PA1 + PA2;% total power (W)
        %
        % Mirror positions (m)
        %
        EC_out.RA2 = 3.5300;
        EC_out.RA1 = 3.5300;
        EC_out.ZA2 = 0;
        EC_out.ZA1 = 0.2000;
        %
        % Time averaging between tmin and tmax
        %
        PA1_tmin = interp_tprof_time_fxdrg(tA1,PA1,tmin,method);%Time interpolation
        PA1_tmax = interp_tprof_time_fxdrg(tA1,PA1,tmax,method);%Time interpolation
        dt_PA1 = [tmin;tA1(find((tA1 > tmin).*(tA1 < tmax)));tmax];
        EC_out.PA1 = mean([PA1_tmin;PA1(find((tA1 > tmin).*(tA1 < tmax)),:);PA1_tmax]);%Mean value
        %	   
        phiA1_tmin = interp_tprof_time_fxdrg(tHAUTTOR,xHAUTTOR,tmin,method);%Time interpolation
        phiA1_tmax = interp_tprof_time_fxdrg(tHAUTTOR,xHAUTTOR,tmax,method);%Time interpolation
        dt_phiA1 = [tmin;tHAUTTOR(find((tHAUTTOR > tmin).*(tHAUTTOR < tmax)));tmax];
        EC_out.phiA1 = mean([phiA1_tmin;xHAUTTOR(find((tHAUTTOR > tmin).*(tHAUTTOR < tmax)),:);phiA1_tmax]);%Mean value
        %	   
        thetaA1_tmin = interp_tprof_time_fxdrg(tHAUTPOL,xHAUTPOL,tmin,method);%Time interpolation
        thetaA1_tmax = interp_tprof_time_fxdrg(tHAUTPOL,xHAUTPOL,tmax,method);%Time interpolation
        dt_thetaA1 = [tmin;tHAUTPOL(find((tHAUTPOL > tmin).*(tHAUTPOL < tmax)));tmax];
        EC_out.thetaA1 = mean([thetaA1_tmin;xHAUTPOL(find((tHAUTPOL > tmin).*(tHAUTPOL < tmax)),:);thetaA1_tmax]);%Mean value
        %
        PA2_tmin = interp_tprof_time_fxdrg(tA2,PA2,tmin,method);%Time interpolation
        PA2_tmax = interp_tprof_time_fxdrg(tA2,PA2,tmax,method);%Time interpolation
        dt_PA2 = [tmin;tA2(find((tA2 > tmin).*(tA2 < tmax)));tmax];
        EC_out.PA2 = mean([PA2_tmin;PA2(find((tA2 > tmin).*(tA2 < tmax)),:);PA2_tmax]);%Mean value
        %	   
        phiA2_tmin = interp_tprof_time_fxdrg(tMILTOR,xMILTOR,tmin,method);%Time interpolation
        phiA2_tmax = interp_tprof_time_fxdrg(tMILTOR,xMILTOR,tmax,method);%Time interpolation
        dt_phiA2 = [tmin;tMILTOR(find((tMILTOR > tmin).*(tMILTOR < tmax)));tmax];
        EC_out.phiA2 = mean([phiA2_tmin;xMILTOR(find((tMILTOR > tmin).*(tMILTOR < tmax)),:);phiA2_tmax]);%Mean value
        %	   
        thetaA2_tmin = interp_tprof_time_fxdrg(tMILPOL,xMILPOL,tmin,method);%Time interpolation
        thetaA2_tmax = interp_tprof_time_fxdrg(tMILPOL,xMILPOL,tmax,method);%Time interpolation
        dt_thetaA2 = [tmin;tMILPOL(find((tMILPOL > tmin).*(tMILPOL < tmax)));tmax];
        EC_out.thetaA2 = mean([thetaA2_tmin;xMILPOL(find((tMILPOL > tmin).*(tMILPOL < tmax)),:);thetaA2_tmax]);%Mean value
	else
        EC_out.RA2 = 3.5300;
        EC_out.RA1 = 3.5300;
        EC_out.ZA2 = 0;
        EC_out.ZA1 = 0.2000;
		EC_out.PA1 = '';
		EC_out.phiA1 = '';
		EC_out.thetaA1 = '';
		EC_out.PA2 = '';
		EC_out.phiA2 = '';
		EC_out.thetaA2 = '';
        flag = 0;
    end
else
	disp('Not yet implemented for this machine.')
	return
end

