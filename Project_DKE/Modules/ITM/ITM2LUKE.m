function [varargout] = ITM2LUKE(dkepath,struct_name,mds_id)
%LUKE - Function that gives the correspondance between the name of a LUKE structure and its number in the ITM MDS+ database
%
%Function that gives the correspondance between the name of a LUKE structure and its number in the ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in ITM2LUKE.m');end
%
[struct_names,struct_paths] = LUKEITM(dkepath,struct_name);
%
if nargin == 1,
	varargout{1} = length(struct_names);
else
	if mds_id > length(struct_names),
		varargout{1} = '';
		varargout{2} = '';
	else
		varargout{1} = struct_names{mds_id};
		varargout{2} = struct_paths{mds_id};
	end
end