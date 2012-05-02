function [machine,user,ver] = which_MDSdatabase(dkepath,mute)
%LUKE - Function that check which ITM MDS+ database is connected
%
%Function that check which ITM MDS+ database is connected
%
%	Input:
%
%   - dkepath: LUKE path structure
%       (default: value for the computer in the LUKE/PATH_files database)
%   - mute: if set to 1, warning are displayed, if set to 0, quiet mode [1,1]
%       (default = 0)
%
%	Output:
%
%   - machine: tokamak name in the ITM MDS+ database [1,n]
%   - user: user of the ITM MDS+ database [1,n]
%   - ver: version of the data structure (UAL) in ITM MDS+ database [1,n]
% 
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin == 0
	dkepath = '';
    mute = 0;
end
%
if nargin == 1,
	mute = 0;
end
%
if isempty(dkepath),
    dkepath = load_structures_yp('dkepath','','');    
end
%
if ~strfind(dkepath.hostname,'efda-itm'),%one of the ITM gateway nodes
	if mute,warning(['Remote access to the ITM MDS+ database from ',dkepath.hostnames,' not yet implemented !']);end
	machine = '';
	user = '';
	ver = '';
	return
else
	%
	hdf5base = getenv('HDF5_BASE');
	mdstreebase = getenv('MDSPLUS_TREE_BASE_0');
	%
	if isempty(hdf5base) | isempty(mdstreebase),
		if mute,
            warning('Environment variables for ITM MDS+/HDF5 database are not set-up.');
        end
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
end