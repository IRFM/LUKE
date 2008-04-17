function  [ap,Rp,Zp,Bt,Ip,qmin,eq,qopt,Zi,mi,fi,Te0,Tea,eTe1,eTe2,ne0,nea,ene1,ene2,Ti0,Tia,eTi1,eTi2,Zeff0,Zeffa,eZeff,xZeff] = load_tprof_tsbase_yp(shotnum,shotime);
%
%   Load processed experimental data (tprof treatment) of the tokamak Tore Supra for building a magnetic equilibrium with HELENA code (mex file version)
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM,joan.decker@cea.fr)
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
if isempty(tprof.Ti),
    tprof.Ti = tprof.Te/2;%Rather good approximation for Tore SUpra
end
[tprof.ni,tprof.t,tprof.rho] = tsbase(shotnum,'GPROFNIFIT');%Ion density profile (m-3)
%
ap = interp_tprof_time(tprof,'ap',shotime,method);%Time interpolation
Rp = interp_tprof_time(tprof,'Rp',shotime,method);%Time interpolation
Zp = interp_tprof_time(tprof,'Zp',shotime,method);%Time interpolation
%
Bt = interp_tprof_time(tprof,'Bt',shotime,method);%Time interpolation
Ip = interp_tprof_time(tprof,'Ip',shotime,method);%Time interpolation
qpsi = interp_tprof_time(tprof,'qpsi',shotime,method);%Time interpolation
%
vloop = interp_tprof_time(tprof,'vloop',shotime,method);%Time interpolation
Zeff = interp_tprof_time(tprof,'Zeff',shotime,method);%Time interpolation
%
Te = interp_tprof_time(tprof,'Te',shotime,method);%Time interpolation
ne = interp_tprof_time(tprof,'ne',shotime,method);%Time interpolation
ni = interp_tprof_time(tprof,'ni',shotime,method);%Time interpolation
%
[qmin,eq,qopt,chi2_q] = fit_q_profile_fxdrg(tprof.rho,qpsi,method);%Fit q-profile
[Te0,Tea,eTe1,eTe2,chi2_Te] = fit_profile_fxdrg(tprof.rho,Te,method);%Fit Te profile
[ne0,nea,ene1,ene2,chi2_ne] = fit_profile_fxdrg(tprof.rho,ne,method);%Fit ne profile
[Ti0,Tia,eTi1,eTi2,chi2_Ti] = fit_profile_fxdrg(tprof.rho,Ti,method);%Fit Ti profile
[ni0,nia,eni1,eni2,chi2_ni] = fit_profile_fxdrg(tprof.rho,ni,method);%Fit ni profile
%
% Build data for C3PO/LUKE
%
[sZmain,iZmain] = sort(tprof.Zmain);%Z ascending order sorting
[sZimp,iZimp] = sort(tprof.Zimp);%Z ascending order sorting
sMmain = tprof.Mmain(iZmain);
sCmain = tprof.Mmain(iZmain);
sMimp = tprof.Mimp(iZimp);
%
isZmain1 = find(sZmain == 1);%Identify Hydrogen isotopes
isZmain2 = find(sZmain > 1);%Identify other main ions (like Helium)
[ssZmain1,isZmain1] = sort(sZmain(iZmain1));%ascending order sorting
[ssZmain2,isZmain2] = sort(sZmain(iZmain2));%ascending order sorting
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
if sum(fi) > 1,error('Error in main ion concentrations.');end
%


