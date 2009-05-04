function [equil_LUKE,status,result] = read_equil_ITM(numshot,numrun,time,method)
%LUKE - Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in read_equil_ITM.m');end
%
if nargin == 2,
	time = 1;%First time only
	method == 1;Time interpolation (1:linear,2:******,3:nearest neighbor)
end
%
if nargin == 3,
	method == 1;Time interpolation (1:linear,2:******,3:nearest neighbor)
end
%
status = 0;
result = '';
equil_LUKE = '';
%
try
	import ualmemory.javainterface.*;
	expIdx = openBD('euitm',numshot,numrun);%Open the database
	%
	if isnan(time),%All data are get
		equil = CPO_get(expIdx,'equilibrium');%Read magnetic equilibrium
		coreprof = CPO_get(expIdx,'coreprof');%Read data profile
	else
		equil = CPO_get(expIdx,'equilibrium',time,method);%Read magnetic equilibrium
		coreprof = CPO_get(expIdx,'coreprof',time,method);%Read data profile
	end
	%
	closeBD(expIdx,'euitm',numshot,numrun);%Close the currently open database
	%
	%--------------------------- Data conversion between ITM CPO's and C3PO/LUKE format ------------------
	%
	equil_LUKE.id = equil.datainfo.whatref.machine;
	equil_LUKE.theta = equil.profiles_2d.grid.dim2(:)';
	equil_LUKE.Rp = equil.global_param.mag_axis.position.r;
	equil_LUKE.Zp = equil.global_param.mag_axis.position.z;
	equil_LUKE.ptBx = equil.profiles_2d.br;
	equil_LUKE.ptBy = equil.profiles_2d.bz;
	equil_LUKE.ptBPHI = equil.profiles_2d.bphi;
	equil_LUKE.pty = equil.coord_sys.position.z - equil.global_param.mag_axis.position.z;
	%
	if isinf(equil.global_param.mag_axis.position.r),
		equil_LUKE.ptx = equil.coord_sys.position.r;
		equil_LUKE.psi_apRp = equil.profiles_1d.psi(:)';
	else
		equil_LUKE.ptx = equil.coord_sys.position.r - equil.global_param.mag_axis.position.r;
		equil_LUKE.ptx(end,1)
		equil.profiles_1d.psi(:)
		equil_LUKE.psi_apRp = equil.profiles_1d.psi(:)'*equil_LUKE.ptx(end,1)/equil.global_param.mag_axis.position.r;
	end
	%
	equil_LUKE.pTe = coreprof.te.value(:)';
	equil_LUKE.pne = coreprof.ne.value(:)';
	equil_LUKE.pzTi = transpose(coreprof.ti.value);
	equil_LUKE.pzni = transpose(coreprof.ni.value);
	equil_LUKE.zZi = coreprof.composition.zn(:)';
	equil_LUKE.zmi = coreprof.composition.amn(:)';
catch
	status = -1;
	result = 'Error while reading the ITM-MDS+ database. Data may not exist !';
end

