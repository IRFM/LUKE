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
function varargout = F_help_param_pol(key)
%   F_help_param_pol()
%   help = F_help_param_pol(key)
%
%plot help for param_pol substruct or find help for specific field of
%the substruct defined in key

tp.Pin_in   = "corrected initial total power. If NaN take value ALOHA else the value is enforced by Pin_in (W). Consider globalspectrum to get the total LH power. ";

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end