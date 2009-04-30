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
nb = length(time);
%
try,
	expIdx = UALAccess.create('euitm',numshot,numrun,numshot,0)
	equilCPO = CPO_create('equilibrium',nb);
	coreprofCPO = CPO_create('coreprof',nb);
	%
	for i = 1:nb,
		equilCPO(i).datainfo.dataprovider = 'YB, FI';
		equilCPO(i).codeparam.codename='test_equilibrium_put matlab';
		equilCPO(i).global_param.li= 1.0 + i ;
		equilCPO(i)=allocate_equilibrium(equilCPO(i),'profiles_1d.pprime',[1:10]);
		equilCPO(i)=allocate_equilibrium(equilCPO(i),'profiles_2d.psi_grid',[1:10;11:20]);
		equilCPO(i).time = time(i);
		%
		coreprofCPO(i).datainfo.dataprovider = 'YB';	
		coreprofCPO(i).codeparam.codename='test_equilibrium_put matlab';
		coreprofCPO(i).time = time(i);
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









