function  [ap,Rp,Zp,Bt,Ip,qmin,eq,qopt,Zi,mi,fi,Te0,Tea,eTe1,eTe2,ne0,nea,ene1,ene2,Ti0,Tia,eTi1,eTi2,Zeff0,Zeffa,eZeff,xZeff] = load_tprof_tsbase_yp(shotnum,shotime,tmin,tmax,basestr);
%
%   Load processed experimental data (tprof treatment) of the tokamak Tore Supra for building a magnetic equilibrium with HELENA code (mex file version)
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM,joan.decker@cea.fr)
%
method = 'spline';
%
if strcmp(basestr,'TS'),
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
	if isempty(tprof.Ti),
	    tprof.Ti = tprof.Te/2;%Rather good approximation for Tore SUpra
	end
	[tprof.ni,tprof.t,tprof.rho] = tsbase(shotnum,'GPROFNIFIT');%Ion density profile (m-3)
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
	vloop = mean([vloop_tmin;tprof.vloop(find((tprof.t > tmin).*(tprof.t < tmax)),:);vloop_tmax]);%Mean value
	Zeff = mean([Zeff_tmin;tprof.Zeff(find((tprof.t > tmin).*(tprof.t < tmax)),:);Zeff_tmax]);%Mean value
	%
	% Fit
	%
	[qmin,qmax,eq,qopt,chi2_q] = fit_qprofile_fxdrg(tprof.rho,qpsi);%Fit q-profile
	[Te0,Tea,eTe1,eTe2,chi2_Te] = fit_profile_fxdrg(tprof.rho,Te,1,[2,1]);%Fit Te profile
	[ne0,nea,ene1,ene2,chi2_ne] = fit_profile_fxdrg(tprof.rho,ne,1,[2,1]);%Fit ne profile
	[Ti0,Tia,eTi1,eTi2,chi2_Ti] = fit_profile_fxdrg(tprof.rho,Ti,1,[2,1]);%Fit Ti profile
	[ni0,nia,eni1,eni2,chi2_ni] = fit_profile_fxdrg(tprof.rho,ni,1,[2,1]);%Fit ni profile
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
else
	disp('Not yet implemented for this machine.')
	return
end

