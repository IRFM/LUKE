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
function varargout = make_struct_jd(loadstruct,display_mode,fun,varargin)
%
% This function looks into "loadstruct" for the outputs of function "fun"
% If the outputs are present, they are returned
% Otherwise, they are calculated by "fun" using "varargin"
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
