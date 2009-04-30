function [status,result] = write_equil_ITM(equil,numshot,numrun)
%LUKE - Function that writes a LUKE magnetic equilibrium structure into ITM MDS+ database using the CPO format
%
%Function that writes a LUKE magnetic equilibrium structure into ITM MDS+ database using the CPO format
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 3,error('Not enough input arguments in write_equil_ITM.m');end
%
status = 0;
result = '';
%
import ualmemory.javainterface.*;
%
nb = 2;
expIdx = UALAccess.create('euitm',numshot,numrun,numshot,0);
equilCPO = CPO_create('equilibrium',nb);
val1D = [1:10];
val2D = [1:10; 11:20];
time = 1;
for i = 1: nb
	equilCPO(i).datainfo.dataprovider = 'YB, FI';
	equilCPO(i).codeparam.codename='test_equilibrium_put matlab';
	equilCPO(i).global_param.li= 1.0 + i ;
	equilCPO(i)=allocate_equilibrium(equilCPO(i),'profiles_1d.pprime',val1D.*i);
	equilCPO(i)=allocate_equilibrium(equilCPO(i),'profiles_2d.psi_grid',val2D.*i);
	equilCPO(i).time = time + i;
end
CPO_put(expIdx,equilCPO);
closeBD(expIdx,'euitm',numshot,numrun);