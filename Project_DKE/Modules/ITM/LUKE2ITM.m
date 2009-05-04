function [varargout] = LUKE2ITM(dkepath,struct_name,cell_name)
%LUKE - Function that gives the correspondance between the name of a LUKE structure and its number in the ITM MDS+ database
%
%Function that gives the correspondance between the name of a LUKE structure and its number in the ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in LUKE2ITM.m');end
%
[struct_names,struct_paths] = LUKEITM(dkepath,struct_name);
%
if nargin < 3,
	varargout{1} = length(struct_names);
else
	%
	varargout{1} = '';
	varargout{2} = '';
	%
	for is = 1:length(struct_names)
		if strcmp(struct_names{is},cell_name),
			varargout{1} = is;
			varargout{2} = struct_paths{is};
			break;
		end
	end
end