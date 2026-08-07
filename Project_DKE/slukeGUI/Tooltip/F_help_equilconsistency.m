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
function varargout = F_help_equilconsistency(key)
%   F_help_equilconsistency()
%   help = F_help_equilconsistency(key)
%
%plot help for equilconsistency substruct or find help for specific field of equilconsistency
%defined in key

tp.comment  = "Comments on the equilconsistency";
tp.auto_mode= "";
tp.display_mode = "";
tp.prho     = "";
tp.mtheta   = "interpolation factor (the interpolation will be done on m times points on theta direction)";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end       
