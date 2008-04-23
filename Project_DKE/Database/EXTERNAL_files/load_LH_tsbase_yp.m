function  [flag,LH_out] = load_LH_tsbase_yp(shotnum,certif,shotime,tmin,tmax,basestr);
%
%   Load processed experimental data (THYB treatment) of the tokamak Tore
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
	if ~isempty(LH_in.Plh_C2),
		Plh_C2_tmin = interp_tprof_time_fxdrg(LH_in.t_Plh_C2,LH_in.Plh_C2,tmin,method);%Time interpolation
		Plh_C2_tmax = interp_tprof_time_fxdrg(LH_in.t_Plh_C2,LH_in.Plh_C2,tmax,method);%Time interpolation
		dt_Plh_C2 = [tmin;LH_in.t_Plh_C2(find((LH_in.t_Plh_C2 > tmin).*(LH_in.t_Plh_C2 < tmax)));tmax];
		LH_out.Plh_C2 = mean([Plh_C2_tmin;LH_in.Plh_C2(find((LH_in.t_Plh_C2 > tmin).*(LH_in.t_Plh_C2 < tmax)),:);Plh_C2_tmax]);%Mean value
	%
		phaselh_C2_tmin = interp_tprof_time_fxdrg(LH_in.t_phaselh_C2,LH_in.phaselh_C2,tmin,method);%Time interpolation
		phaselh_C2_tmax = interp_tprof_time_fxdrg(LH_in.t_phaselh_C2,LH_in.phaselh_C2,tmax,method);%Time interpolation
		dt_phaselh_C2 = [tmin;LH_in.t_phaselh_C2(find((LH_in.t_phaselh_C2 > tmin).*(LH_in.t_phaselh_C2 < tmax)));tmax];
		LH_out.phaselh_C2 = mean([phaselh_C2_tmin;LH_in.phaselh_C2(find((LH_in.t_phaselh_C2 > tmin).*(LH_in.t_phaselh_C2 < tmax)),:);phaselh_C2_tmax]);%Mean value	
		LH_out.npar_C2 = 1.83 + LH_out.phaselh_C2/200;%From A. Ekedahl using SWANN output (5/7/2004)
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
		LH_out.npar_C3 = 2.03 + (LH_out.phaselh_C3 + 90)/310;%From A. Ekedahl using SWANN output (5/7/2004)
    else
        LH_out.Plh_C2 = '';
		LH_out.phaselh_C2 = '';
		LH_out.npar_C2 = '';
		LH_out.Plh_C3 = '';
		LH_out.phaselh_C3 = '';
		LH_out.npar_C3 = '';
        flag = 0;
	end
else
	disp('Not yet implemented for this machine.')
	return
end

