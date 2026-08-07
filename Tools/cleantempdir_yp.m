% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [flag] = cleantempdir_yp(owner,year,month,day)
%LUKE - Remove all temporary directories created by LUKE where temporary matrices are stored (see make_path_LOCAL.m or equivalent file)
%
% This function removes all temporary directories created by LUKE where temporary matrices are stored (see make_path_LOCAL.m or equivalent file)
%
% INPUT
%
%	- owner: name in the system (string) [1,n]
%		default: USER environment variable
%	- year: year number [1,1]
%		default: this year
%	- month: month number [1,1]
%		default: this month
%	- day: day number [1,1]
%		default: this month
%
% OUTPUT
%
%	- flag: number of directories or files removed [1,1]
%
if nargin > 4,error('Wrong number of input arguments in cleantempdir_yp.m');end
if nargin == 0,owner = getenv('USER');end
if nargin <= 1,datenum_ref = now;end
if nargin == 2,month = 1;day = 1;datenum_ref = datenum(year,month,day);end
if nargin == 3,day = 1;datenum_ref = datenum(year,month,day);end
if nargin == 4,datenum_ref = datenum(year,month,day);end
%
dkepath = load_structures_yp('dkepath','','');
%
flag = 0;
%
dirini = pwd;
if isempty(dkepath.temppathroot) || strcmp(dkepath.temppathroot,pwd),
	disp('WARNING: you cannot delete automatically working directories if the parent directory is your local directory !');
	return;
end
%
if isempty(strfind(dkepath.temppathroot,'scratch')) && isempty(strfind(dkepath.temppathroot,'tmp')),
	disp('WARNING: you cannot delete automatically working directories if the parent directory is not named ''scratch'' or ''tmp'' !');
	return;
end
%
cd(dkepath.temppathroot);
%
dirlist = dir;
for idir = 1:length(dirlist),
	list = ls('-al');
	if dirlist(idir).isdir,
		if ~isempty(strfind(list(1:strfind(list,dirlist(idir).name)),owner)),
			if dirlist(idir).datenum <= datenum_ref,
				flag = flag + rmdir(dirlist(idir).name,'s');
			end
		end
	end
end
%
if ~nargout,disp(['---> ',int2str(flag),' directories have been deleted in ',dkepath.temppathroot]);end
%
cd(dirini);

