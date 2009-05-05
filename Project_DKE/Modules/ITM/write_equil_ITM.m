function [status,result] = write_equil_ITM(equil,numshot,numrun,time)
%LUKE - Function that writes a LUKE magnetic equilibrium structure into ITM MDS+ database using the CPO format
%
%Function that writes a LUKE magnetic equilibrium structure into ITM MDS+ database using the CPO format
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 3,error('Not enough input arguments in write_equil_ITM.m');end
if nargin == 3,
	time = [0];%Only one default time slice is written in the ITM MDS+ database 
end
%
status = 0;
result = '';
%
import ualmemory.javainterface.*;
%
ntime = length(time);
%
try,
	expIdx = UALAccess.create('euitm',numshot,numrun,numshot,0);
	equilCPO = CPO_create('equilibrium',ntime);
	coreprofCPO = CPO_create('coreprof',ntime);
	%
	for it = 1:ntime,
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 'equilibrium' CPO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		% datainfo element
		%
		equilCPO(it).datainfo.dataprovider = 'Yves Peysson & Joan Decker, CEA/DSM/IRFM';
		equilCPO(it).datainfo.putdate = date;
		equilCPO(it).datainfo.source = 'LUKE package';
		equilCPO(it).datainfo.comment = 'For validation use';
		equilCPO(it).datainfo.isref = 0;
		equilCPO(it).datainfo.whatref.user = 'LUKE code';
		equilCPO(it).datainfo.whatref.machine = equil.id;
		equilCPO(it).datainfo.whatref.shot = numshot;
		equilCPO(it).datainfo.whatref.run = numrun;
%		equilCPO(it).datainfo.whatref.occurence = 0;
		%
		% eqgeometry element
		%		
		equilCPO(it).eqgeometry.source = '';
		equilCPO(it).eqgeometry.boundarytype = '';
		equilCPO(it).eqgeometry.boundary.r = '';
		equilCPO(it).eqgeometry.boundary.z = '';
		equilCPO(it).eqgeometry.geom_axis.r = equil.Rp;
		equilCPO(it).eqgeometry.geom_axis.z = equil.Zp;
		equilCPO(it).eqgeometry.a_minor = equil.ptx(end,1);
%		equilCPO(it).eqgeometry.elongation = '';
%		equilCPO(it).eqgeometry.tria_upper = '';
%		equilCPO(it).eqgeometry.tria_lower = '';
%		equilCPO(it).eqgeometry.xpts.r = '';
%		equilCPO(it).eqgeometry.xpts.z = '';
%		equilCPO(it).eqgeometry.left_low_st.r = '';
%		equilCPO(it).eqgeometry.left_low_st.z = '';
%		equilCPO(it).eqgeometry.right_low_st.r = '';
%		equilCPO(it).eqgeometry.right_low_st.z = '';
%		equilCPO(it).eqgeometry.left_up_st.r = '';
%		equilCPO(it).eqgeometry.left_up_st.z = '';
%		equilCPO(it).eqgeometry.right_up_st.r = '';
%		equilCPO(it).eqgeometry.right_up_st.z = '';
%		equilCPO(it).eqgeometry.active_limit.r = '';
%		equilCPO(it).eqgeometry.active_limit.z = '';
		%
		% global_param element
		%
%		equilCPO(it).global_param.beta_pol = '';
%		equilCPO(it).global_param.beta_tor = '';
%		equilCPO(it).global_param.beta_normal = '';
%		equilCPO(it).global_param.i_plasma = '';
%		equilCPO(it).global_param.li = '';
%		equilCPO(it).global_param.volume = '';
%		equilCPO(it).global_param.area = '';
%		equilCPO(it).global_param.psi_ax = equil.psi_apRp(1);
		if isinf(equil.Rp),
			equilCPO(it).global_param.psi_bound = equil.psi_apRp(end);%Cylindrical case
		else
			equilCPO(it).global_param.psi_bound = equil.psi_apRp(end)*equil.Rp/equil.ptx(end,1);,%Toroidal case		
		end
		equilCPO(it).global_param.mag_axis.position.r = equil.Rp;
		equilCPO(it).global_param.mag_axis.position.z = equil.Zp;
		equilCPO(it).global_param.mag_axis.bphi = equil.ptBPHI(1,1);
%		equilCPO(it).global_param.mag_axis.q = '';
%		equilCPO(it).global_param.q95 = '';
%		equilCPO(it).global_param.q_min = '';
		%
		% profiles_1d element
		%
		if isinf(equil.Rp),
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.psi',equil.psi_apRp);%Cylindrical case
		else
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.psi',equil.psi_apRp*equil.Rp/equil.ptx(end,1));%Toroidal case	
		end
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.phi','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.pressure','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.F_dia','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.pprime','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.ffprime','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.jphi','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.jparallel','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.q','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.r_inboard','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.r_outboard','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.rho_tor','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.rho_vol','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.elongation','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.tria_upper','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.tria_lower','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.volume','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.vprime','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.area','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.aprime','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.ftrap','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.gm1','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.gm2','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.gm3','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.gm4','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.gm5','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.gm6','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.gm7','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.gm8','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_1d.gm9','');
		%
		% profiles_2d element
		%
		equilCPO(it).profiles_2d.grid_type = '(poloidal psi,theta)';
		if isinf(equil.Rp),
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.grid.dim1',equil.psi_apRp);%Cylindrical case
		else
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.grid.dim1',equil.psi_apRp*equil.Rp/equil.ptx(end,1));%Toroidal case	
		end
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.grid.dim2',equil.theta);
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.grid.connect','');
		if isinf(equil.Rp),
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.psi_grid',equil.psi_apRp(:)*ones(size(equil.theta)));%Cylindrical case
		else
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.psi_grid',(equil.psi_apRp(:)*ones(size(equil.theta)))*equil.Rp/equil.ptx(end,1));%Toroidal case	
		end
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.jphi_grid','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.jpar_grid','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.br',equil.ptBx);
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.bz',equil.ptBy);
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'profiles_2d.bphi',equil.ptBPHI);
		%
		% coord_sys element
		%
		equilCPO(it).coord_sys.grid_type = '(poloidal psi,theta)';
		if isinf(equil.Rp),
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.grid.dim1',equil.psi_apRp(:));%Cylindrical case
		else
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.grid.dim1',equil.psi_apRp(:)*equil.Rp/equil.ptx(end,1));%Toroidal case	
		end
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.grid.dim2',equil.theta);
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.jacobian','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.g_11','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.g_12','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.g_13','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.g_22','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.g_23','');
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.g_33','');
		if isinf(equil.Rp),
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.position.r',equil.ptx);
		else
			equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.position.r',equil.ptx+equil.Rp);
		end		
		equilCPO(it) = allocate_equilibrium(equilCPO(it),'coord_sys.position.z',equil.pty+equil.Zp);		
		%
		% codeparam element
		%
		equilCPO(it).codeparam.codename ='LUKE';		
		equilCPO(it).codeparam.codeversion = [LUKEversion_jd,' - MATLAB ',version];		
		equilCPO(it).codeparam.parameters = '';		
		equilCPO(it).codeparam.output_diag = '';		
		equilCPO(it).codeparam.output_flag = 0;		
		%
		% time element
		%
		equilCPO(it).time = time(it);
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 'coreprof' CPO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		% datainfo element
		%
		coreprofCPO(it).datainfo.dataprovider = 'Yves Peysson & Joan Decker, CEA/DSM/IRFM';
		coreprofCPO(it).datainfo.putdate = date;
		coreprofCPO(it).datainfo.source = 'LUKE package';
		coreprofCPO(it).datainfo.comment = 'For validation use';
		coreprofCPO(it).datainfo.isref = 0;
		coreprofCPO(it).datainfo.whatref.user = 'LUKE code';
		coreprofCPO(it).datainfo.whatref.machine = equil.id;
		coreprofCPO(it).datainfo.whatref.shot = numshot;
		coreprofCPO(it).datainfo.whatref.run = numrun;
%		coreprofCPO(it).datainfo.whatref.occurence = 1;
		%
%		coreprofCPO(it).rho_tor_norm = '';
%		coreprofCPO(it).rho_tor = '';
%		coreprofCPO(it).drhodt = '';
		%
		% toroidal_field element
		%
%		coreprofCPO(it).toroidal_field.b0 = '';
%		coreprofCPO(it).toroidal_field.b0prime = '';
%		coreprofCPO(it).toroidal_field.r0 = '';
%		coreprofCPO(it).toroidal_field.time = '';
		%
		% composition element
		%
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'composition.amn',equil.zmi);
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'composition.zn',equil.zZi);
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'composition.zion',equil.zZi);
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'composition.imp_flag',zeros(size(equil.zZi)));
		%
		% psi element
		%
		if isinf(equil.Rp),
			coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.value',equil.psi_apRp);%Cylindrical case
		else
			coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.value',equil.psi_apRp*equil.Rp/equil.ptx(end,1));%Toroidal case	
		end
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.source','LUKE code');
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.flag',3);
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.boundary.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.boundary.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.boundary.type','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.boundary.rho','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.jni.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.jni.integral','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.jni.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.sigma_par.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'psi.sigma_par.source','');
		%
		% te element
		%
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.value',equil.pTe);
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.source','LUKE code');	
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.flag',3);
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.boundary.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.boundary.source','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.boundary.type','');	
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.boundary.rho_tor','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.source_term.value','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.source_term.integral','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.source_term.source','');	
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.transp_coef.diff','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.transp_coef.vconv','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.transp_coef.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.flux.dv','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.flux_interp','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'te.time_deriv','');		
		%
		% ti element
		%
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.value',transpose(equil.pzTi));
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.source',repmat('LUKE code',length(equil.zZi),1));	
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.flag',3*ones(size(equil.zZi)));
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.boundary.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.boundary.source','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.boundary.type','');	
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.boundary.rho_tor','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.source_term.value','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.source_term.integral','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.source_term.source','');	
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.transp_coef.diff','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.transp_coef.vconv','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.transp_coef.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.flux.dv','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.flux_interp','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ti.time_deriv','');		
		%
		% ne element
		%
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.value',equil.pne);
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.source','LUKE code');	
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.flag',3);
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.boundary.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.boundary.source','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.boundary.type','');	
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.boundary.rho_tor','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.source_term.value','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.source_term.integral','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.source_term.source','');	
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.transp_coef.diff','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.transp_coef.vconv','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.transp_coef.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.flux.dv','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.flux_interp','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ne.time_deriv','');		
		%
		% ni element
		%
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.value',transpose(equil.pzni));
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.source',repmat('LUKE code',length(equil.zZi),1));	
		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.flag',3*ones(size(equil.zZi)));
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.boundary.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.boundary.source','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.boundary.type','');	
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.boundary.rho_tor','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.source_term.value','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.source_term.integral','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.source_term.source','');	
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.transp_coef.diff','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.transp_coef.vconv','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.transp_coef.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.flux.dv','');		
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.flux_interp','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'ni.time_deriv','');		
		%
		% profiles_1d element
		%
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pe.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pe.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pi.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pi.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pr_th.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pr_th.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pr_perp.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pr_perp.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pr_parallel.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.pr_parallel.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.jtot.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.jtot.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.jini.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.jini.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.joh.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.joh.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.vloop.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.vloop.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.sigmapar.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.sigmapar.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.qoh.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.qoh.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.eparallel.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.eparallel.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.e_b.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.e_b.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.q.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.q.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.shear.value''');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.shear.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.ns.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.ns.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.mtor.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.mtor.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.wtor.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.wtor.source','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.zeff.value','');
%		coreprofCPO(it) = allocate_coreprof(coreprofCPO(it),'profiles_1d.zeff.source','');						
		%
		% globalparam element
		%
%		coreprofCPO(it).globalparam.current_tot = '';
%		coreprofCPO(it).globalparam.current_bnd = '' ;		
%		coreprofCPO(it).globalparam.vloop = '';	
%		coreprofCPO(it).globalparam.li = '';	
		%
		% codeparam element
		%
		coreprofCPO(it).codeparam.codename ='LUKE';		
		coreprofCPO(it).codeparam.codeversion = [LUKEversion_jd,' - MATLAB ',version];		
		coreprofCPO(it).codeparam.parameters = '';		
		coreprofCPO(it).codeparam.output_diag = '';		
		coreprofCPO(it).codeparam.output_flag = 0;		
		%
		% time element
		%
		coreprofCPO(it).time = time(it);
	end
	%
	CPO_put(expIdx,equilCPO);
	CPO_put(expIdx,coreprofCPO);
	closeBD(expIdx,'euitm',numshot,numrun);
catch
	status = -1;
	result = 'WARNING: LUKE magnetic equilibrium unsuccessfully writen in the ITM-MDS+ database.';
end
%









