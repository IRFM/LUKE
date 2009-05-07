function [LUKE_struct] = CPO2LUKE_struct_yp(struct_name,CPO_struct)
%LUKE - Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in CPO2LUKE_struct_yp.m');end
%
if strcmp('equilibrium',struct_name),
	LUKE_struct.id = CPO_struct.datainfo.whatref.machine;
	LUKE_struct.theta = CPO_struct.profiles_2d.grid.dim2(:)';
	LUKE_struct.Rp = CPO_struct.global_param.mag_axis.position.r;
	LUKE_struct.Zp = CPO_struct.global_param.mag_axis.position.z;
	LUKE_struct.ptBx = CPO_struct.profiles_2d.br;
	LUKE_struct.ptBy = CPO_struct.profiles_2d.bz;
	LUKE_struct.ptBPHI = CPO_struct.profiles_2d.bphi;
	LUKE_struct.pty = CPO_struct.coord_sys.position.z - CPO_struct.global_param.mag_axis.position.z;
	%
	if isinf(CPO_struct.global_param.mag_axis.position.r),
		LUKE_struct.ptx = CPO_struct.coord_sys.position.r;
		LUKE_struct.psi_apRp = CPO_struct.profiles_1d.psi(:)';
	else
		LUKE_struct.ptx = CPO_struct.coord_sys.position.r - CPO_struct.global_param.mag_axis.position.r;
		LUKE_struct.psi_apRp = CPO_struct.profiles_1d.psi(:)'*LUKE_struct.ptx(end,1)/CPO_struct.global_param.mag_axis.position.r;
	end
	%
elseif strcmp('coreprof',struct_name),
	LUKE_struct.pTe = CPO_struct.te.value(:)';
	LUKE_struct.pne = CPO_struct.ne.value(:)';
	LUKE_struct.pzTi = transpose(CPO_struct.ti.value);
	LUKE_struct.pzni = transpose(CPO_struct.ni.value);
	LUKE_struct.zZi = CPO_struct.composition.zn(:)';
	LUKE_struct.zmi = CPO_struct.composition.amn(:)';
elseif strcmp('launchs',struct_name),

else
	error(['There is no CPO with the name ',struct_name,' in the ITM MDS+ database']);
end
