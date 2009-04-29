function [status,result] = write_equil_ITM(dkepath,user,machine,ver,numshot,numrun)
%LUKE - Function that writes a LUKE magnetic equilibrium structure into ITM MDS+ database using the CPO format
%
%Function that writes a LUKE magnetic equilibrium structure into ITM MDS+ database using the CPO format
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 6,error('Not enough input arguments in write_equil_ITM.m');end
%
if ~strcmp(dkepath.hostname,'efdaitm'),
	status = -2;
	result = ['Remote access to the ITM MDS+ database from ',dkepath.hostname,' not yet implemented !'];
	equil_LUKE = [];
	return;
end
%
[ustatus,uresult] = unix([dkepath.local_root,'scripts/set_itm_data_env ',user,' ',machine,' ',ver]);
if ustatus,
	status = -1;
	result = ['Unsuccessful connexion to the ITM MDS+ database for the machine: ',machine,', user: ',user,'and version:',ver];
	equil_LUKE = [];
	return;
end
%
status = 0;
result = '';
%
import ualmemory.javainterface.*;
%
nb = 1;
expIdx = UALAccess.create('euitm',numshot,numrun,numshot,0);
equil = CPO_create('equilibrium',nb);
val1D = [1:10];
val2D = [1:10; 11:20];
for i = 1: nb
	equil(i).datainfo.dataprovider = 'YB, FI';
	equil(i).codeparam.codename='test_equilibrium_put matlab';
	equil(i).global_param.li= 1.0 + i ;
	equil(i)=allocate_equilibrium(equil(i),'profiles_1d.pprime',val1D.*i);
	equil(i)=allocate_equilibrium(equil(i),'profiles_2d.psi_grid',val2D.*i);
	equil(i).time = time + i;
end
CPO_put(expIdx, equil);
closeBD(expIdx,'euitm',numshot,numrun);