function [machine,user,ver] = which_MDSdatabase(dkepath)
%LUKE - Function that check which ITM MDS+ database is connected
%
%Function that check which ITM MDS+ database is connected
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 1,error('Not enough input arguments in which_MDSdatabase.m');end
%
if ~strcmp(dkepath.hostname,'efdaitm'),
	warning(['Remote access to the ITM MDS+ database from ',dkepath.hostname,' not yet implemented !']);
	machine = '';
	user = '';
	ver = '';
	return
end
%
hdf5base = getenv('HDF5_BASE');
mdstreebase = getenv('MDSPLUS_TREE_BASE_0');
%
if isempty(hdf5base) | isempty(mdstreebase),
	warning('Environment variables for ITM MDS+/HDF5 database are not set-up.')
	machine = '';
	user = '';
	ver = '';
	return
end
%
is = 1;
str = {};
remain = hdf5base;
while true
	[strtemp,remain] = strtok(remain,'/');	
	if isempty(strtemp),break;end
	str{is} = strtemp;
	is = is + 1;
end
%
if strcmp(str{1},'afs'),%Private MDS+ database (may be own by any ITM user)
	ver = str{length(str)-1};
	machine = str{length(str)-2};
	user = str{length(str)-6};
else,%Public MDS+ database
	ver = str{length(str)-1};
	machine = str{length(str)-2};
	user = str{length(str)-3};
end	
