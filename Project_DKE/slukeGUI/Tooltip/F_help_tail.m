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
function varargout = F_help_tail(key)
%   F_help_tail()
%   help = F_help_tail(key)
%
%plot help for tail substruct or find help for specific field of the 
%substruct defined in key

tp.dtn      = "";
tp.mode     = "";
tp.bNparmax_tail = "";
tp.bn_tail  = "";
tp.bP_tail  = "Artificial shift of the main lobe of the LH power spectrum : 0 nothing done, < 1 : reduction of the absolute value, > 1 increase of the absolute value";
tp.bopt_tail= "";

if ~exist('key','var'),     key = {};   end

help = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end