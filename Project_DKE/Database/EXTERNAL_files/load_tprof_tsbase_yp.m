function  [ap,Rp,Zp,Bt,Ip,qmin,eq,qopt,Zi,mi,fi,Te0,Tea,eTe1,eTe2,ne0,nea,ene1,ene2,Ti0,Tia,eTi1,eTi2,Zeff0,Zeffa,eZeff,xZeff,Vloop,LH_out,EC_out] = load_tprof_tsbase_yp(shotnum,shotime,tmin,tmax,basestr);
%
%   Load processed experimental data (tprof treatment) of the tokamak Tore Supra for building a magnetic equilibrium with HELENA code (mex file version)
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM,joan.decker@cea.fr)
%
method = 'spline';
%
if strcmp(basestr,'TS'),
	%
	shotnum = str2num(shotnum) + certif/10;  
	%
	[tprof.ap,tprof.t] = tsbase(shotnum,'SPROFAMIN');%Plasma minor radius (m)
	[tprof.Rp,tprof.t] = tsbase(shotnum,'SPROFRMAJ');%Plasma major radius (m)
	[tprof.Zp,tprof.t] = tsbase(shotnum,'SPROFZPOS');%Plasma vertical position (m)
	%
	[tprof.Bt,tprof.t] = tsbase(shotnum,'SPROFBTOR');%Toroidal magnetic field (T)
	[tprof.Ip,tprof.t] = tsbase(shotnum,'SPROFIP');%Plasma current (MA)
	[tprof.qpsi,tprof.t] = tsbase(shotnum,'GPROFQ');%safety factor qpsi profile
	%
	[tprof.vloop,tprof.t] = tsbase(shotnum,'SPROFVS');%Loop voltage (V)
	[tprof.Zeff,tprof.t] = tsbase(shotnum,'SPROFZEFF');%Effective charge
	[tprof.Zmain] = tsbase(shotnum,'SPROFZMAIN');%Charges of the main ions
	[tprof.Mmain] = tsbase(shotnum,'SPROFMMAIN');%Atomic masses of the main ions (uma)
	[tprof.Cmain] = tsbase(shotnum,'SPROFCMAIN');%Concentrations of the main ions
	[tprof.Zimp] = tsbase(shotnum,'SPROFZIMP');%Charges of the impurities
	[tprof.Mimp] = tsbase(shotnum,'SPROFMIMP');%Atomic masses of impurities (uma)
	%
	[tprof.Te,tprof.t,tprof.rho] = tsbase(shotnum,'GPROFTEFIT');%ELectron temperature (keV)
	[tprof.ne,tprof.t,tprof.rho] = tsbase(shotnum,'GPROFNEFIT');%ELectron density profile (m-3)
	[tprof.Ti,tprof.t,tprof.rho] = tsbase(shotnum,'GPROFTIFIT_');%Ion temperature profile (keV)
	[tprof.ni,tprof.t,tprof.rho] = tsbase(shotnum,'GPROFNIFIT');%Ion density profile (m-3)
	%
	if isempty(tprof.ap) | isempty(tprof.Rp) |isempty(tprof.Zp) |isempty(tprof.Bt) |isempty(tprof.Ip) |isempty(tprof.qpsi) |isempty(tprof.vloop) | isempty(tprof.Zeff) | isempty(tprof.Zmain) | isempty(tprof.Mmain) | isempty(tprof.Cmain) | isempty(tprof.Zimp) | isempty(tprof.Mimp) | isempty(tprof.Te) | isempty(tprof.ne) | isempty(tprof.ni),
		ap = [];
		Rp = [];
		Zp = [];
		Bt = [];
		Ip = [];
		qmin = [];
		eq = [];
		qopt = [];
		Zi = [];
		mi = [];
		fi = [];	
		Te0 = [];
		Tea = [];
		eTe1 = [];
		eTe2 = [];
		ne0 = [];
		nea = [];
		ene1 = [];
		ene2 = [];
		Ti0 = [];
		Tia = [];
		eTi1 = [];
		eTi2 = [];
		Zeff0 = [];
		Zeffa = [];
		eZeff = [];
		xZeff = [];
		Vloop = [];
		LH_out = [];
		EC_out = [];
		disp(['WARNING: tprof data are not documented for the shot #',int2str(shotnum),'. Contact T. Aniel or the CDIV.']);
		return
	end
	%
	if isempty(tprof.Ti),
	    tprof.Ti = tprof.Te/2;%Rather good approximation for Tore SUpra
	end
	%
	% Build data for C3PO/LUKE
	%
	% Time interpolation (at the time slice shotime)
	%
	ap = interp_tprof_time_fxdrg(tprof.t,tprof.ap,shotime,method);%Time interpolation
	Rp = interp_tprof_time_fxdrg(tprof.t,tprof.Rp,shotime,method);%Time interpolation
	Zp = interp_tprof_time_fxdrg(tprof.t,tprof.Zp,shotime,method);%Time interpolation
	%
	Bt = interp_tprof_time_fxdrg(tprof.t,tprof.Bt,shotime,method);%Time interpolation
	Ip = interp_tprof_time_fxdrg(tprof.t,tprof.Ip,shotime,method);%Time interpolation
	qpsi = interp_tprof_time_fxdrg(tprof.t,tprof.qpsi,shotime,method);%Time interpolation
	%
	% Time averaging between tmin and tmax
	%
	Te_tmin = interp_tprof_time_fxdrg(tprof.t,tprof.Te,tmin,method);%Time interpolation
	Te_tmax = interp_tprof_time_fxdrg(tprof.t,tprof.Te,tmax,method);%Time interpolation
	ne_tmin = interp_tprof_time_fxdrg(tprof.t,tprof.ne,tmin,method);%Time interpolation
	ne_tmax = interp_tprof_time_fxdrg(tprof.t,tprof.ne,tmax,method);%Time interpolation
	Ti_tmin = interp_tprof_time_fxdrg(tprof.t,tprof.Ti,tmin,method);%Time interpolation
	Ti_tmax = interp_tprof_time_fxdrg(tprof.t,tprof.Ti,tmax,method);%Time interpolation
	ni_tmin = interp_tprof_time_fxdrg(tprof.t,tprof.ni,tmin,method);%Time interpolation
	ni_tmax = interp_tprof_time_fxdrg(tprof.t,tprof.ni,tmax,method);%Time interpolation
	%
	vloop_tmin = interp_tprof_time_fxdrg(tprof.t,tprof.vloop,tmin,method);%Time interpolation
	vloop_tmax = interp_tprof_time_fxdrg(tprof.t,tprof.vloop,tmax,method);%Time interpolation
	Zeff_tmin = interp_tprof_time_fxdrg(tprof.t,tprof.Zeff,tmin,method);%Time interpolation
	Zeff_tmax = interp_tprof_time_fxdrg(tprof.t,tprof.Zeff,tmax,method);%Time interpolation
	%
	dt = [tmin;tprof.t(find((tprof.t > tmin).*(tprof.t < tmax)));tmax];
	%
	Te = mean([Te_tmin;tprof.Te(find((tprof.t > tmin).*(tprof.t < tmax)),:);Te_tmax]);%Mean value
	ne = mean([ne_tmin;tprof.ne(find((tprof.t > tmin).*(tprof.t < tmax)),:);ne_tmax]);%Mean value
	Ti = mean([Ti_tmin;tprof.Ti(find((tprof.t > tmin).*(tprof.t < tmax)),:);Ti_tmax]);%Mean value
	ni = mean([ni_tmin;tprof.ni(find((tprof.t > tmin).*(tprof.t < tmax)),:);ni_tmax]);%Mean value
	%	
	Vloop = mean([vloop_tmin;tprof.vloop(find((tprof.t > tmin).*(tprof.t < tmax)),:);vloop_tmax]);%Mean value
	Zeff = mean([Zeff_tmin;tprof.Zeff(find((tprof.t > tmin).*(tprof.t < tmax)),:);Zeff_tmax]);%Mean value
	%
	% Fit
	%
	[qmin,qmax,eq,qopt,chi2_q] = fit_qprofile_fxdrg(tprof.rho,qpsi);%Fit q-profile
	[Te0,Tea,eTe1,eTe2,chi2_Te] = fit_profile_fxdrg(tprof.rho,Te,1,[2,2]);%Fit Te profile
	[ne0,nea,ene1,ene2,chi2_ne] = fit_profile_fxdrg(tprof.rho,ne,1,[2,2]);%Fit ne profile
	[Ti0,Tia,eTi1,eTi2,chi2_Ti] = fit_profile_fxdrg(tprof.rho,Ti,1,[2,2]);%Fit Ti profile
	[ni0,nia,eni1,eni2,chi2_ni] = fit_profile_fxdrg(tprof.rho,ni,1,[2,2]);%Fit ni profile
	%
	% Atomic data
	%
	[sZmain,iZmain] = sort(tprof.Zmain);%Z ascending order sorting
	[sZimp,iZimp] = sort(tprof.Zimp);%Z ascending order sorting
	sMmain = tprof.Mmain(iZmain);
	sCmain = tprof.Mmain(iZmain);
	sMimp = tprof.Mimp(iZimp);
	%
	isZmain1 = find(sZmain == 1);%Identify Hydrogen isotopes
	isZmain2 = find(sZmain > 1);%Identify other main ions (like Helium)
	[ssZmain1,isZmain1] = sort(sZmain(isZmain1));%ascending order sorting
	[ssZmain2,isZmain2] = sort(sZmain(isZmain2));%ascending order sorting
	%
	% No tritium in Tore Supra
	%
	if isempty(isZmain1),%Helium,...
		Zi = [1,1;1;sZmain;sZimp]';%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
	    mi = [1;2;3;sMmain;tprof.Mimp(iZimp)]';%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
	    fi = [0;0;0]';%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)   
	else,%Hydrogen isotopes exist in the plasma
	    if length(isZmain1) == 1,%One type of main ion
	        Zi = [1;1;1;sZmain(isZmain2);sZimp]';%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
	        mi = [1;2;3;tprof.Mmain(isZmain2);tprof.Mimp(iZimp)]';%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
			%
	        if tprof.Mmain(isZmain1) == 1,%hydrogen
	            fi = [1;0;0]';%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)  
	        elseif tprof.Mmain(isZmain1) == 2,%hydrogen,%Deuterium
	            fi = [0;1;0]';%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)  
	        end
	    else,%two types of main ion (max)
	        Zi = [sZmain(isZmain1);1;sZmain(isZmain2);sZimp]';%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
	        mi = [tprof.Mmain(isZmain1);3;tprof.Mmain(isZmain2);tprof.Mimp(iZimp)]';%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
	        fi = [tprof.Cmain(isZmain1);0]';%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)  
			fi(2) = 1 - fi(1);
	    end
	end
	%
	%
	% Flat Zeff profile for Tore Supra
	%
	Zeff0 = Zeff;
	Zeffa = Zeff;
	eZeff = 0;
	xZeff = NaN;
	%
	% Load LH power and phase
	%
	[LH_in.Plh_C2,LH_in.t_Plh_C2] = tsbase(shotnum,'GPHYB%1');%LH power from C2 antenna (MW)
	[LH_in.Plh_C3,LH_in.t_Plh_C3] = tsbase(shotnum,'GPHYB%2');%LH power from C3 antenna (MW)
	[LH_in.phaselh_C2,LH_in.t_phaselh_C2] = tsbase(shotnum,'GPHASHYB%1');%LH phasing from C2 antenna (deg)
	[LH_in.phaselh_C3,LH_in.t_phaselh_C3] = tsbase(shotnum,'GPHASHYB%2');%LH phasing from C2 antenna (deg)
	%
	% Time averaging between tmin and tmax
	%
	Plh_C2_tmin = interp_tprof_time_fxdrg(LH_in.t_Plh_C2,LH_in.Plh_C2,tmin,method);%Time interpolation
	Plh_C2_tmax = interp_tprof_time_fxdrg(LH_in.t_Plh_C2,LH_in.Plh_C2,tmax,method);%Time interpolation
	dt_Plh_C2 = [tmin;LH_in.t_Plh_C2(find((LH_in.t_Plh_C2 > tmin).*(LH_in.t_Plh_C2 < tmax)));tmax];
	LH_out.Plh_C2 = mean([Plh_C2_tmin;LH_in.Plh_C2(find((LH_in.t_Plh_C2 > tmin).*(LH_in.t_Plh_C2 < tmax)),:);Plh_C2_tmax]);%Mean value
	%
	phaselh_C2_tmin = interp_tprof_time_fxdrg(LH_in.t_phaselh_C2,LH_in.phaselh_C2,tmin,method);%Time interpolation
	phaselh_C2_tmax = interp_tprof_time_fxdrg(LH_in.t_phaselh_C2,LH_in.phaselh_C2,tmax,method);%Time interpolation
	dt_phaselh_C2 = [tmin;LH_in.t_phaselh_C2(find((LH_in.t_phaselh_C2 > tmin).*(LH_in.t_phaselh_C2 < tmax)));tmax];
	LH_out.phaselh_C2 = mean([phaselh_C2_tmin;LH_in.phaselh_C2(find((LH_in.t_phaselh_C2 > tmin).*(LH_in.t_phaselh_C2 < tmax)),:);phaselh_C2_tmax]);%Mean value
	%
	Plh_C3_tmin = interp_tprof_time_fxdrg(LH_in.t_Plh_C3,LH_in.Plh_C3,tmin,method);%Time interpolation
	Plh_C3_tmax = interp_tprof_time_fxdrg(LH_in.t_Plh_C3,LH_in.Plh_C3,tmax,method);%Time interpolation
	dt_Plh_C3 = [tmin;LH_in.t_Plh_C3(find((LH_in.t_Plh_C3 > tmin).*(LH_in.t_Plh_C3 < tmax)));tmax];
	LH_out.Plh_C3 = mean([Plh_C3_tmin;LH_in.t_Plh_C3(find((LH_in.Plh_C3 > tmin).*(LH_in.t_Plh_C3 < tmax)),:);Plh_C3_tmax]);%Mean value
	%
	phaselh_C3_tmin = interp_tprof_time_fxdrg(LH_in.t_phaselh_C3,LH_in.phaselh_C3,tmin,method);%Time interpolation
	phaselh_C3_tmax = interp_tprof_time_fxdrg(LH_in.t_phaselh_C3,LH_in.phaselh_C3,tmax,method);%Time interpolation
	dt_phaselh_C3 = [tmin;LH_in.t_phaselh_C3(find((LH_in.t_phaselh_C3 > tmin).*(LH_in.t_phaselh_C3 < tmax)));tmax];
	LH_out.phaselh_C3 = mean([phaselh_C3_tmin;LH_in.phaselh_C3(find((LH_in.t_phaselh_C3 > tmin).*(LH_in.t_phaselh_C3 < tmax)),:);phaselh_C3_tmax]);%Mean value
	%
	LH_out.npar_C2 = 1.83 + LH_out.phaselh_C2/200;%From A. Ekedahl using SWANN output (5/7/2004)
	LH_out.npar_C3 = 2.03 + (LH_out.phaselh_C3 + 90)/310;%From A. Ekedahl using SWANN output (5/7/2004)
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
        % Powers in kW (from M. Lennholm)
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
    end
else
	disp('Not yet implemented for this machine.')
	return
end

