function varargout = make_struct_jd(loadstruct,display_mode,fun,varargin)
%
% This function looks into "loadstruct" for the outputs of function "fun"
% If the outputs are present, they are returned
% Otherwise, they are calculated by "fun" using "varargin"
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and Y.Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
if isfield(loadstruct,fun) && isstruct(loadstruct.(fun)),% specific function outputs are recalled
    if display_mode >= 1,
        disp(['Outputs of the function ',fun,' retrieved from the structure ',inputname(1)]);
    end
    varargout = struct2cell(loadstruct.(fun));     
else % specific function outputs are calculated
    funhandle = str2func(fun);%make string into function handle
    varargout = cell(1,nargout);
    [varargout{:}] = funhandle(varargin{:});%evaluate function
end
