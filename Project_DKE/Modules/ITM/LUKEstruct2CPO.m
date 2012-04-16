function [CPO_struct] = LUKEstrust2CPO(numshot,numrun,timeslice,struct_name,rawdata,procdata,CPO_struct)
%LUKE - Function that copy LUKE structure into the corresponding CPO's in the ITM MDS+ database
%
%Function that copy LUKE structure into the corresponding CPO's in the ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 6,error('Not enough input arguments in LUKE2CPO_struct_yp.m');end
%
if strcmp('waves',struct_name),
	%
	ibeam = 1;
	%
	ix = findstr(rawdata.dkepath.luke_root,'/');
	%
	it = length(CPO_struct) + 1;
	%
	CPO_struct(it).datainfo.dataprovider = rawdata.dkepath.luke_root(ix(5)+1:ix(6)-1);
	CPO_struct(it).datainfo.putdate = date;
	CPO_struct(it).datainfo.whatref.machine = which_MDSdatabase;
	CPO_struct(it).datainfo.whatref.shot = numshot;
	CPO_struct(it).datainfo.whatref.run = numrun;
	%
	for iwaves = 1:length(rawdata.dke_out.waves)
		CPO_struct(it).coherentwave(iwaves).composition.amn = rawdata.equilDKE.zmi(:);
		CPO_struct(it).coherentwave(iwaves).composition.zn = rawdata.equilDKE.zZi(:);
		CPO_struct(it).coherentwave(iwaves).composition.zion = rawdata.equilDKE.zZi(:);
		CPO_struct(it).coherentwave(iwaves).composition.imp_flag = zeros(size(rawdata.equilDKE.zZi(:)));
		%
		CPO_struct(it).coherentwave(iwaves).global_param.frequency = rawdata.dke_out.waves{1}.omega_rf/2/pi;
		CPO_struct(it).coherentwave(iwaves).global_param.name = '';
		CPO_struct(it).coherentwave(iwaves).global_param.type = rawdata.dke_out.waves{1}.rayinit.launch.type;
		CPO_struct(it).coherentwave(iwaves).global_param.f_assumption = 1;
		CPO_struct(it).coherentwave(iwaves).global_param.power_tot = procdata.scalar.p_rf_2piRp*2*pi*rawdata.equilDKE.Rp*1e6;
		CPO_struct(it).coherentwave(iwaves).global_param.power_e = procdata.scalar.p_rf_2piRp*2*pi*rawdata.equilDKE.Rp*1e6;
		CPO_struct(it).coherentwave(iwaves).global_param.cur_tor = procdata.scalar.I_tot*1e6;%positive co-current
		CPO_struct(it).coherentwave(iwaves).global_param.code_type = 1;
		%
		CPO_struct(it).coherentwave(iwaves).grid_1d.psi = rawdata.equilDKE.xpsin(:)*rawdata.equilDKE.psia_apRp/rawdata.equilDKE.ap*rawdata.equilDKE.Rp*2*pi;
		%
		CPO_struct(it).coherentwave(iwaves).profiles_1d.powd_tot = procdata.radial.P_rf(:);
		CPO_struct(it).coherentwave(iwaves).profiles_1d.powd_e = procdata.radial.P_rf(:);
		CPO_struct(it).coherentwave(iwaves).profiles_1d.curd_tor = procdata.radial.J_tot(:);
		CPO_struct(it).coherentwave(iwaves).profiles_1d.pow_tot = procdata.radial.xp_rf_2piRp*rawdata.equilDKE.Rp*2*pi;
		CPO_struct(it).coherentwave(iwaves).profiles_1d.pow_e = procdata.radial.xp_rf_2piRp*rawdata.equilDKE.Rp*2*pi;
		CPO_struct(it).coherentwave(iwaves).profiles_1d.curd_par = '';
		CPO_struct(it).coherentwave(iwaves).profiles_1d.cur_tor = '';
		%	
		for irays = 1:length(rawdata.dke_out.waves{iwaves}.rays)
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).npoints = length(rawdata.dke_out.waves{iwaves}.rays{irays}.sx);
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).power = rawdata.dke_out.waves{iwaves}.rays{irays}.P0_2piRp*2*pi*rawdata.equilDKE.Rp;
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).dnpar = rawdata.dke_out.waves{iwaves}.rays{irays}.sdNpar(:);
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).length = rawdata.dke_out.waves{iwaves}.rays{irays}.ss(:);
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).position.r = rawdata.dke_out.waves{iwaves}.rays{irays}.sx(:) + rawdata.equilDKE.Rp;
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).position.z = rawdata.dke_out.waves{iwaves}.rays{irays}.sy(:) + rawdata.equilDKE.Zp;
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).position.phi = rawdata.dke_out.waves{iwaves}.rays{irays}.sphi(:);
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).position.psi = rawdata.dke_out.waves{iwaves}.rays{irays}.spsin(:)*rawdata.equilDKE.psia_apRp/rawdata.equilDKE.ap*rawdata.equilDKE.Rp*2*pi;
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).position.theta = rawdata.dke_out.waves{iwaves}.rays{irays}.stheta(:);
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).wavevector.kr = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).wavevector.kz = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).wavevector.kphi = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).wavevector.npar = rawdata.dke_out.waves{iwaves}.rays{irays}.sNpar(:);
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).wavevector.ntor = rawdata.dke_out.waves{iwaves}.rays{irays}.sn(:);
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).wavevector.var_ntor = 0;
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).polarization.epol_p_re = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).polarization.epol_p_im = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).polarization.epol_m_re = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).polarization.epol_m_im = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).polarization.epol_par_re = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).polarization.epol_par_im = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).powerflow.phi_perp = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).powerflow.phi_par = '';
			CPO_struct(it).coherentwave(iwaves).beamtracing(ibeam).powerflow.power_e = '';
			%
			ibeam = ibeam + 1;
		end
	end
	%
	CPO_struct(it).codeparam.codename = LUKEversion_jd;
	CPO_struct(it).codeparam.codeversion = LUKEversion_jd;
	%
	CPO_struct(it).time = timeslice;
else
	error(['There is no CPO with the name ',struct_name,' in the ITM MDS+ database']);
end
